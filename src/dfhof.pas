{$INCLUDE doomrl.inc}
unit dfhof;
interface
uses Classes, XMLRead, XMLWrite, DOM, vnode, vxml, vxmldata, MD5, dfdata, vuitypes;

const MaxHofEntries = 500;
      MaxID         = 1023;

//     CRC_PRIME_099 = 62189;
     
const PlayerFile = 'player.wad';
      ScoreFile  = 'score.wad';
      RANKEXP    = 1;
      RANKSKILL  = 2;


const RankArray : array[1..2] of AnsiString = ('exp_ranks','skill_ranks');

{ THOF }

type THOF = object
  SkillRank  : Word;
  ExpRank    : Word;

  procedure Init;
  procedure Add( const Name : AnsiString; aScore : LongInt; const aKillerID : AnsiString; Level, DLev : Word; nChal : AnsiString );
  function RankCheck( out aResult : THOFRank ) : Boolean;
  function GetPagedReport : TUIPagedReport;
  function GetHOFReport : TUIHOFReport;
  procedure Done;

  function GetCount( aXPathQuery : string; aContext : TDOMNode = nil ) : DWord;
  function GetChildCount( aXPathQuery : string; aContext : TDOMNode = nil ) : DWord;

  function AddCounted( const aRootID, aLeafID, aElementID : AnsiString; aAmount : DWord = 1 ) : Boolean;
  function GetCounted( const aRootID, aLeafID, aElementID : AnsiString ) : DWord;
private
  FScore      : TScoreFile;
  FPlayerInfo : TVXMLDataFile;

  procedure Save; overload;
  // TODO : remove
  function GetBadgeCount( aBadgeLevel : DWord ) : DWord;
  function GetScores( aFilter : char; out aFilterName : AnsiString ) : TUIStringArray;

  function GetRankReqCount( const aRankArray : AnsiString; aRankLevel : DWord ) : DWord;
  function GetRankReqDescription( const aRankArray : AnsiString; aRankLevel : DWord; aRankReq :DWord ) : AnsiString;
  function IsRankReqCompleted( const aRankArray : AnsiString; aRankLevel : DWord; aRankReq : DWord ) : Boolean;
  function GetRankReqCurrent( const aRankArray : AnsiString; aRankLevel : DWord; aRankReq : DWord ) : DWord;
  function GetRankReqTotal( const aRankArray : AnsiString; aRankLevel : DWord; aRankReq : DWord ) : DWord;

  function CheckRank(rank,current : Byte) : boolean;

  function GetDiffKills( aDiff : AnsiString ) : string;
  function GetDiffScore( aDiff : AnsiString ) : string;
  function GetDiffDeaths( aDiff : AnsiString ) : string;

  function GetChalDesc(Chal : Byte; aDiffLevel : AnsiString; aVictoryType: AnsiString) : string;

  function GetCountStr( aXPathQuery : string; aContext : TDOMNode = nil ) : String;
  function IncreaseXMLCount( aContainer : TDOMElement; const aElementID : string; const aID : string; aAmount : DWord ) : TDOMElement;
  function IncreaseXMLCount( aContainer : TDOMElement; const aElementID : string; aAmount : DWord ) : TDOMElement;
  function  GetRank( aRankName : string ) : Word;
  procedure SetRank( aRankName: string; aValue : Byte );

  function GameResultBetter( const ResultOld, ResultNew : String ) : boolean;
  function GameResultAtLeast( const ResultAtLeast, ResultNew : String ) : boolean;

private
   ChallengeChars : set of Byte;
   ChallengeStr   : string;
end;

var HOF : THOF;

implementation

uses math, sysutils, strutils, variants, vluasystem, doombase, dfplayer, vdebug, vutil, vrltools, zstream;

const HOFOpen : Boolean = False;

function THOF.GetBadgeCount( aBadgeLevel : DWord ): DWord;
var iCount   : DWord;
    iCounter : DWord;
    iBadges  : LongInt;
begin
  if aBadgeLevel = 0 then Exit( 0 );
  iBadges := LuaSystem.Get(['badges','__counter']);
  iCount := 0;
  for iCounter := 1 to iBadges do
  begin
    if (LuaSystem.Get(['badges',iCounter,'level']) = aBadgeLevel) and
       (GetCounted( 'badges', 'badge', LuaSystem.Get(['badges',iCounter,'id']) ) > 0) then
      Inc( iCount );
  end;
  Exit( iCount );
end;

function THOF.GetScores(aFilter: char; out aFilterName: AnsiString ): TUIStringArray;
var iCount, iAmount       : DWord;
    iDiff, iDiffFilter    : DWord;
    iChal, iChalFilter    : string;
    iString, iColor       : string;
    iElement              : TScoreEntry;
    iScore, iLevel, iDlev : DWord;
    iName, iKill          : AnsiString;
    iKlassChar            : Char;
begin
  iDiffFilter := 0;
  iChalFilter := '';

  case aFilter of
   'e' : iDiffFilter := DIFF_EASY;
   'm' : iDiffFilter := DIFF_MEDIUM;
   'h' : iDiffFilter := DIFF_HARD;
   'u' : iDiffFilter := DIFF_VERYHARD;
   'n' : iDiffFilter := DIFF_NIGHTMARE;
   '-' : iChalFilter := '----';
  else
    if Ord(aFilter) in ChallengeChars then
      iChalFilter := AnsiString(LuaSystem.Get(['chal',Pos(aFilter,ChallengeStr),'abbr']));
  end;


  if iChalFilter = '----'
    then aFilterName := 'unchallenged'
    else aFilterName := iChalFilter;

  if iDiffFilter > 0 then aFilterName := LuaSystem.Get(['diff',iDiffFilter,'code']);

  iAmount := FScore.Entries;
  Result := TUIStringArray.Create;

  for iCount := 1 to iAmount do
  begin
    iElement := FScore[ iCount ];
    iDiff    := StrToInt( iElement.GetAttribute('difficulty') );
    iChal    := iElement.GetAttribute('challenge');

    if (iDiffFilter > 0) and (iDiff <> iDiffFilter) then Continue;
    if (iChalFilter <> '') and (iChalFilter <> '----') and ( iChalFilter <> iChal ) then Continue;
    if (iChalFilter = '----') and (iChal <> '') then Continue;

    iScore := math.Max( StrToInt( iElement.GetAttribute('score') ), 0 );
    iLevel := StrToInt( iElement.GetAttribute('level') );
    iDLev  := StrToInt( iElement.GetAttribute('depth') );
    iName  := iElement.GetAttribute('name');
    iKill  := iElement.GetAttribute('killed');

    if iCount = FScore.LastEntry then
      iColor := '@l'
    else
      iColor := '@y';

    iString := LuaSystem.Get(['diff',iDiff,'code']) + ' ';
    iString += iColor + Padded(IntToStr(iScore),8);
    iString += Padded(iName,17) + ' ';

    iKlassChar := 'C';
    if iElement.hasAttribute('klass') then iKlassChar := LuaSystem.Get(['klasses',AnsiString(iElement.GetAttribute('klass')),'char']);

    iString += iKlassChar + '@<'+Padded(IntToStr(iLevel),3);
    iString += iColor + Padded(iKill,34);
    iString += iColor + 'L@L'+Padded(IntToStr(iDLev),4);
    if iChal <> '' then iString += '@y'+iChal;

    Result.Push( '  '+iString );
  end;
end;


function THOF.GetDiffScore( aDiff : AnsiString ) : string;
var iMax     : string;
    iElement : TDOMElement;
    iWins    : string;
    iPlural  : string;
begin
  iElement := FPlayerInfo.XML.GetElement('player/games/game[@id="'+aDiff+'"]');
  if iElement = nil then Exit('none');
  iMax     := iElement.GetAttribute('max');
  if iMax = '' then Exit('none');
  if Pos( ':', iMax ) > 0 then Exit('reached level '+ExtractDelimited(2, iMax, [':']));

  iWins := GetCountStr( 'win[@id="total"]', iElement );
  if iWins = '1' then iPlural := ''
    else iPlural := 's';

  if iMax = 'sacrifice' then Exit('half won ('+iWins+' win'+iPlural+' total)');
  if iMax = 'win'       then Exit('won ('+iWins+' win'+iPlural+' total)');
  if iMax = 'final'     then Exit('fully won ('+iWins+' win'+iPlural+' total)');
  Exit('Error!');
end;

function THOF.GetDiffDeaths( aDiff : AnsiString ) : string;
var iCount   : DWord;
    iWins    : DWord;
    iElement : TDOMElement;
begin
  iElement := FPlayerInfo.XML.GetElement('player/games/game[@id="'+aDiff+'"]');
  if iElement = nil then Exit('none');
  iCount   := StrToInt(iElement.GetAttribute('count'));
  iWins    := GetCount( 'win[@id="total"]', iElement );
  Exit(IntToStr(iCount - iWins));
end;

function THOF.GetDiffKills( aDiff : AnsiString ) : string;
var iCount : string;
begin
  iCount := GetCountStr('player/kills/killtype[@id="'+aDiff+'"]');
  if iCount = '0'
    then Exit('none')
    else Exit( iCount );
end;

function THOF.GetChalDesc(Chal : Byte; aDiffLevel : AnsiString; aVictoryType: AnsiString) : string;
var iElement   : TDOMElement;
    iMax       : String;
    iSacrifice : DWord;
    iWin       : DWord;
    iFinal     : DWord;
begin
  if Chal = 0
    then iElement := FPlayerInfo.XML.GetElement('player/challenges/challenge[@id="unchallenged"]/game[@id="'+aDiffLevel+'"]')
    else iElement := FPlayerInfo.XML.GetElement('player/challenges/challenge[@id="'+LuaSystem.Get(['chal',Chal,'abbr'])+'"]/game[@id="'+aDiffLevel+'"]');
  if (iElement = nil) then
    begin
      if aVictoryType = 'partial' then Exit('@lnone')
	  else Exit('');
	end;
  iMax     := iElement.GetAttribute('max');
  if iMax = '' then Exit('@lnone');
  if (Pos( ':', iMax ) > 0) and (aVictoryType = 'partial') then Exit('@Rlevel '+ExtractDelimited(2, iMax, [':']));

  iSacrifice := GetCount('win[@id="sacrifice"]', iElement);
  iWin       := GetCount('win[@id="win"]', iElement);
  iFinal     := GetCount('win[@id="final"]', iElement);

  iMax := '';
  // FIXME I have no idea why not having the terminal number causes text to be chewed up.
  case aVictoryType of
    'partial' : if iSacrifice > 0
                  then iMax += '@lPart @<'+IntToStr(iSacrifice)+'@y'
                  else iMax += '@dPart 0';
    'standard': if iWin > 0
                  then iMax += '@lStnd @<'+IntToStr(iWin)+'@y'
                  else iMax += '@dStnd 0';
    'full'    : if iFinal > 0
                  then iMax += '@lFull @<'+IntToStr(iFinal)+'@y'
                  else iMax += '@dFull 0';
    'total'   : iMax += '@yTotl @<'+IntToStr(iSacrifice+iWin+iFinal)+'@y';
  end;

  // XXX Why is this line necessary?
  Delete( iMax, Length(iMax)-1, 3 );
  Exit( iMax );

end;

function THOF.GetCount(aXPathQuery: string; aContext : TDOMNode = nil ): DWord;
begin
  Exit( StrToIntDef( GetCountStr( aXPathQuery, aContext ), 0 ) );
end;

function THOF.GetChildCount(aXPathQuery: string; aContext: TDOMNode): DWord;
var iXMLElement  : TDOMElement;
begin
  if aContext = nil then aContext := FPlayerInfo.XML;
  iXMLElement := FPlayerInfo.XML.GetElement( aXPathQuery, aContext );
  if (iXMLElement = nil) then Exit(0) else Exit( iXMLElement.ChildNodes.Count );
end;

function THOF.GetCountStr(aXPathQuery: string; aContext : TDOMNode = nil ): string;
var iXMLElement  : TDOMElement;
begin
  if aContext = nil then aContext := FPlayerInfo.XML;
  iXMLElement := FPlayerInfo.XML.GetElement( aXPathQuery, aContext );
  if (iXMLElement = nil) then Exit('0');
  GetCountStr := iXMLElement.GetAttribute('count');
  if GetCountStr = '' then Exit('1');
end;

function THOF.GetRank(aRankName: string): Word;
var iXMLElement  : TDOMElement;
begin
  iXMLElement := FPlayerInfo.XML.GetElement( 'player/ranks/rank[@id="'+aRankName+'"]' );
  if (iXMLElement = nil) then Exit(0) else Exit( StrToInt(iXMLElement.GetAttribute('value') ));
end;

procedure THOF.SetRank(aRankName: string; aValue: Byte);
var iXMLElement  : TDOMElement;
    iXMLEntry    : TDOMElement;
begin
  iXMLElement := TDOMElement(FPlayerInfo.XML.DocumentElement.FindNode('ranks'));
  if iXMLElement = nil then
  begin
    iXMLElement := FPlayerInfo.XML.CreateElement('ranks');
    FPlayerInfo.XML.DocumentElement.AppendChild( iXMLElement );
  end;
  iXMLEntry := FPlayerInfo.XML.GetElement( 'rank[@id="'+aRankName+'"]', iXMLElement );
  if iXMLEntry = nil then
  begin
    iXMLEntry := FPlayerInfo.XML.CreateElement('rank');
    iXMLEntry.SetAttribute('id',aRankName);
    iXMLElement.AppendChild( iXMLEntry );
  end;
  iXMLEntry.SetAttribute('value',IntToStr(aValue));
end;

function THOF.AddCounted( const aRootID, aLeafID, aElementID : AnsiString; aAmount : DWord = 1 ): Boolean;
var XMLEntry : TDOMElement;
begin
  AddCounted := GetCounted( aRootID, aLeafID, aElementID ) = 0;
  XMLEntry := IncreaseXMLCount( FPlayerInfo.XML.DocumentElement, aRootID, aAmount );
  IncreaseXMLCount( XMLEntry, aLeafID, aElementID, aAmount );
end;

function THOF.GetCounted( const aRootID, aLeafID, aElementID : AnsiString ): DWord;
begin
  Exit( GetCount( 'player/'+aRootID+'/'+aLeafID+'[@id="'+aElementID+'"]' ) );
end;

function THOF.GetPagedReport : TUIPagedReport;
  function IsNone(l : LongInt) : string;
  begin
    if l = 0 then Exit('@lnone')
             else Exit('@y'+IntToStr(l));
  end;
const BadgeLevelName : array[1..6] of string = (' Bronze ',' Silver ','  Gold  ','Platinum','Diamond ','Angelic ');
var
   Page     : TUIStringArray;

   count    : DWord;
   iTotal   : DWord;
   iFound   : DWord;
   cn,cn2,c : LongInt;
   iDiffID  : AnsiString;
   iDiffCnt : DWord;
   iChalCnt : DWord;
   iPages   : DWord;
   iElement : TDOMElement;
   iBadges  : LongInt;
   iString  : AnsiString;
   iDesc    : AnsiString;

procedure AddPage( const aTitle : TUIString; aContent : TUIStringArray; const aHeader : TUIString = '' );
begin
  Result.Pages.Push( aContent );
  Result.Titles.Push( aTitle );
  Result.Headers.Push( aHeader );
end;

procedure PushRank( aContent : TUIStringArray; const aRankID : AnsiString; aCurrent : Byte );
var iReq     : DWord;
    iCurrent : DWord;
    iTotal   : DWord;
begin
  if aCurrent+1 < LuaSystem.Get([aRankID,'__counter']) then
  begin
    aContent.Push('  @rTo achieve @y'+LuaSystem.Get([aRankID,aCurrent+2,'name'])+'@r rank:@y');
    for iReq := 1 to GetRankReqCount(aRankID,aCurrent+1) do
    begin
      iCurrent := GetRankReqCurrent( aRankID,aCurrent+1,iReq );
      iTotal   := GetRankReqTotal  ( aRankID,aCurrent+1,iReq );
      if iCurrent < iTotal
        then Page.Push('   @r-- '+GetRankReqDescription( aRankID,aCurrent+1,iReq )+'@r (@y'+IntToStr(iCurrent)+'@r/@y'+IntToStr(iTotal)+'@r)' )
        else Page.Push('   @d-- '+StripEncoding( GetRankReqDescription( aRankID,aCurrent+1,iReq ) ) );
    end;
  end;
  aContent.Push('');
end;

begin
  Result.Pages   := TUIPageArray.Create( True );
  Result.Titles  := TUIStringArray.Create;
  Result.Headers := TUIStringArray.Create;
  Result.Title   := 'DoomRL Player Info';

  iDiffCnt := LuaSystem.Get([ 'diff', '__counter' ]);

  // ---------------------------------------------------------------------------

  Page := TUIStringArray.Create;

  Page.Push('  @rExperience rank: @y'+LuaSystem.Get([ 'exp_ranks', ExpRank+1, 'name' ]) );
  Page.Push('  @rSkill rank     : @y'+LuaSystem.Get([ 'skill_ranks', SkillRank+1, 'name' ]) );
  Page.Push('  @rGames won      : @y'+IntToStr(GetCount('player/games/win[@id="total"]'))+
           '  (' +IntToStr(GetCount('player/games/win[@id="sacrifice"]')) + ' partial, ' +
                 IntToStr(GetCount('player/games/win[@id="win"]')) + ' standard, ' +
                 IntToStr(GetCount('player/games/win[@id="final"]')) + ' full)' );
  Page.Push('  @rAll kills      : @y'+IntToStr(GetCount('player/kills'))+
            '  ('+IntToStr(GetCount('player/kills/killtype[@id="weapon-melee"]')) + ' melee, '+
                  IntToStr(GetCount('player/kills/killtype[@id="weapon-pistol"]')) + ' pistol)');
  Page.Push('  @rTotal game time: @y'+DurationString(GetCount('player/time')));
  Page.Push('');

  PushRank( Page, RankArray[RANKSKILL], SkillRank );
  PushRank( Page, RankArray[RANKEXP],   ExpRank );

  //Page.Push('');

  Page.Push('  @rDifficulty level achievements');
  for cn := 1 to iDiffCnt do
  begin
    iDiffID := LuaSystem.Get([ 'diff', cn, 'id' ]);
    Page.Push('   @r'+Padded(LuaSystem.Get([ 'diff', cn, 'name' ]),21)+': @y'+Padded(GetDiffScore(iDiffID),25)+
                '@r Deaths: @y'+Padded(GetDiffDeaths(iDiffID),4)+
                 '@r Kills: @y'+Padded(GetDiffKills(iDiffID),6));
  end;

  AddPage('',Page);

  // ---------------------------------------------------------------------------
  Page := TUIStringArray.Create;

  for cn := 2 to LuaSystem.Get(['beings','__counter']) do
  begin
    iElement := FPlayerInfo.XML.GetElement('player/kills/killbeing[@id="'+LuaSystem.Get(['beings',cn,'id'])+'"]');
    if iElement = nil then Continue;

    iString := '  @r'+Padded(LuaSystem.Get(['beings',cn,'name']),16);
    iString += Padded(IsNone(StrToInt(iElement.GetAttribute('count'))),9);

    for cn2 := 1 to LuaSystem.Get([ 'diff', '__counter' ]) do
      iString += Padded(IsNone(GetCount( 'killtype[@id="'+LuaSystem.Get([ 'diff', cn2, 'id' ])+'"]', iElement)),8);

    iString += Padded(IsNone(GetCount( 'killtype[@id="weapon-melee"]', iElement)),8);
    iString += Padded(IsNone(GetCount( 'killtype[@id="weapon-pistol"]', iElement)),8);
    iString += Padded(IsNone(GetCount( 'killtype[@id="weapon-shotgun"]', iElement)),8);
    iString += Padded(IsNone(GetCount( 'killtype[@id="weapon-chain"]', iElement)),8);

    Page.Push( iString );
  end;

  AddPage('Kills',Page, '  @r'+Padded('Monster name',16)+Padded('TOTAL',7)
            +Padded('Easy',6)+Padded('Med',6)+Padded('Hard',6)+Padded('VHard',6)+Padded('NMare',6)
            +Padded('Melee',6)+Padded('Pist',6)+Padded('Shotg',6)+Padded('Chain',6));

  // ---------------------------------------------------------------------------
  Page := TUIStringArray.Create;

  iChalCnt := LuaSystem.Get( ['chal','__counter'] );
  for cn := 1 to (iChalCnt+1)*4 do
  begin
    if (cn mod 4) = 1 then
	  begin
	    if cn = 1
	      then iString := '   @r'+Padded('Standard Game',24)+'@y'
	      else iString := '   @r'+Padded(LuaSystem.Get(['chal',Floor(cn div 4),'name']),24)+'@y';
	  end
	else iString := Padded('',27)+'@y';
	
    for cn2 := 2 to iDiffCnt do
    begin
	  case ( (cn - 1) mod 4 ) + 1 of
	    1: iDesc := GetChalDesc(Floor((cn-1) div 4),LuaSystem.Get([ 'diff', cn2, 'id' ]),'partial');
		2: iDesc := GetChalDesc(Floor((cn-1) div 4),LuaSystem.Get([ 'diff', cn2, 'id' ]),'standard');
		3: iDesc := GetChalDesc(Floor((cn-1) div 4),LuaSystem.Get([ 'diff', cn2, 'id' ]),'full');
		4: iDesc := GetChalDesc(Floor((cn-1) div 4),LuaSystem.Get([ 'diff', cn2, 'id' ]),'total');
	  end;
      iString += iDesc + StringOfChar(' ', 13-Length(StripEncoding(iDesc)));
    end;
    Page.Push( iString );
  end;
  AddPage('Victories',Page, '   @r'+Padded('Difficulty',24)
               +Padded('Medium',13)+Padded('Hard',13)+Padded('Very Hard',13)+Padded('Nightmare',13));

  // ---------------------------------------------------------------------------
  Page := TUIStringArray.Create;

  for cn := 1 to LuaSystem.Get(['medals','__counter']) do
  begin
    if LuaSystem.Get(['medals',cn,'hidden']) then Continue;
    Count := GetCounted('medals','medal',LuaSystem.Get(['medals',cn,'id']));
    if Count = 0 then iString := '   @d' else iString := '   @y';
    iString += LuaSystem.Get(['medals',cn,'name']);
    if Count = 0 then iString += ' (@L-@d)' else iString += ' (@L'+IntToStr(Count)+'@y)';

    Page.Push( Padded(iString,40)+'@l'+LuaSystem.Get(['medals',cn,'desc']));
  end;
  Page.Push('');
  for cn := 1 to LuaSystem.Get(['medals','__counter']) do
  begin
    if not LuaSystem.Get(['medals',cn,'hidden']) then Continue;
    Count := GetCounted('medals','medal',LuaSystem.Get(['medals',cn,'id']));
    if Count = 0 then
    begin
      Page.Push( '     @d----');
      Continue;
    end;
    iString := '   @y'+LuaSystem.Get(['medals',cn,'name'])+' (@L'+IntToStr(Count)+'@y)';
    Page.Push( Padded(iString,40)+'@l'+LuaSystem.Get(['medals',cn,'desc']));
  end;

  cn := 0; cn2 := 0;
  iElement := FPlayerInfo.XML.GetElement('player/medals');
  if iElement <> nil then
  begin
    cn  := StrToInt(iElement.GetAttribute('count'));
    cn2 := iElement.ChildNodes.Count;
  end;

  AddPage('Medals',Page,'@r   Total medals received  : @y'+Padded(IntToStr(cn),7)+'@rTotal different medals  : @y'+IntToStr(cn2)+'@r/@y'+IntToStr(LuaSystem.Get(['medals','__counter'])));

  // ---------------------------------------------------------------------------
  Page := TUIStringArray.Create;

  c := 0;
  cn2 := 0;
  iString := '';

  for cn := 1 to LuaSystem.Get(['items','__counter']) do
  with LuaSystem.getTable(['items',cn]) do
  try
    if getBoolean('is_exotic') then
    begin
      Inc(c);
      Inc(cn2);
      Count := GetCounted('uniques','unique',getString('id'));
      if Count = 0
        then iString += '@d'+getString('name')+' (@L-@d)'
        else iString += '@y'+getString('name')+' (@L'+IntToStr(Count)+'@y)';
      if cn2 mod 2 = 1
        then iString := '   '+Padded(iString,40)
        else begin Page.Push(iString); iString := ''; end;
    end;
  finally
    Free;
  end;

  if iString <> '' then begin Page.Push(iString); iString := ''; end;
  cn2 := 0;
  Page.Push('');
  for cn := 1 to LuaSystem.Get(['items','__counter']) do
  with LuaSystem.getTable(['items',cn]) do
  try
    if getBoolean('is_unique') then
    begin
      Inc(c);
      Inc(cn2);
      Count := GetCounted('uniques','unique',getString('id'));
      if Count = 0
        then iString += '@d  ---- @L@d'
        else iString += '@y'+getString('name')+' (@L'+IntToStr(Count)+'@y)';
      if cn2 mod 2 = 1
        then iString := '   '+Padded(iString,40)
        else begin Page.Push(iString); iString := ''; end;
    end;
  finally
    Free;
  end;
  if iString <> '' then Page.Push(iString);

  cn := 0; cn2 := 0;
  iElement := FPlayerInfo.XML.GetElement('player/uniques');
  if iElement <> nil then
  begin
    cn  := StrToInt(iElement.GetAttribute('count'));
    cn2 := iElement.ChildNodes.Count;
  end;

  AddPage('Items',Page,'@r   Total specials found  : @y'+Padded(IntToStr(cn),7)+'@rTotal different specials  : @y'+IntToStr(cn2)+'@r/@y'+IntToStr(c));

  // ---------------------------------------------------------------------------
  Page := TUIStringArray.Create;

  c := 0;
  iString := '';

  for cn2 := 0 to 2 do
  begin
    case cn2 of
      0 : Page.Push('@y  Basic assemblies');
      1 : Page.Push('@y  Advanced assemblies');
      2 : Page.Push('@y  Master assemblies');
    end;
    Page.Push('');
    for cn := 1 to LuaSystem.Get(['mod_arrays','__counter']) do
    with LuaSystem.GetTable(['mod_arrays',cn]) do
    try
      if getInteger('level') = cn2 then
      begin
        Inc(c);
        Count := GetCount('player/assemblies/assembly[@id="'+getString('id')+'"]');
        if Count = 0
          then
            begin
               if cn2 = 0
                 then iString += '   @d'+getString('name')+' (@L-@d)'
                 else iString += '   @d  -- ? -- (@L-@d)'
            end
          else iString += Padded('   @y'+getString('name')+' (@L'+IntToStr(Count)+'@y)',40) + '@l' + getString('desc');
        Page.Push(iString);
        iString := '';
      end;
    finally
      Free;
    end;
    if cn2 <> 2 then Page.Push('');
  end;


  cn := 0; cn2 := 0;
  iElement := FPlayerInfo.XML.GetElement('player/assemblies');
  if iElement <> nil then
  begin
    cn  := StrToInt(iElement.GetAttribute('count'));
    cn2 := iElement.ChildNodes.Count;
  end;

  AddPage('Assemblies',Page,'@r   Total assembled       : @y'+Padded(IntToStr(cn),7)+'@rTotal different assemblies: @y'+IntToStr(cn2)+'@r/@y'+IntToStr(c));


  // ---------------------------------------------------------------------------


  iBadges := LuaSystem.Get(['badges','__counter']);
  iPages  := 5;
  if (GetBadgeCount(6) >= 1) or (GetBadgeCount(5) >= 1) then iPages := 6;
  for cn2 := 1 to iPages do
  begin
    Page := TUIStringArray.Create;

    iTotal := 0;
    iFound := 0;
    for cn := 1 to iBadges do
    with LuaSystem.GetTable(['badges',cn]) do
    try
      if getInteger('level') = cn2 then
      begin
        iTotal += 1;
        if GetCounted( 'badges', 'badge', getString('id') ) > 0 then
        begin
          iFound += 1;
          iString := '   @y'+getString('name');
        end
        else
          iString := '   @d'+getString('name');
        Page.Push( Padded(iString,34) + '@l -- ' + getString('desc') );
      end;
    finally
      Free;
    end;

    AddPage('Badges - '+BadgeLevelName[cn2], Page, Padded('@r   Total '+Trim(BadgeLevelName[cn2])+' badges received',36)+' : @y'+IntToStr(iFound)+'@r/@y'+IntToStr(iTotal));
  end;

  // ---------------------------------------------------------------------------
  iBadges := LuaSystem.Get(['awards','__counter'],0);
  if iBadges > 0 then
  begin
    Page := TUIStringArray.Create;
    for cn := 1 to iBadges do
    begin
      if cn > 1 then Page.Push('');
      iFound  := LuaSystem.GetTableSize(['awards',cn,'levels']);
      iDiffID := LuaSystem.Get(['awards',cn,'id']);
      iTotal  := 0;
      for cn2 := iFound downto 1 do
      begin
        if GetCounted( 'awards', 'award', iDiffID + '_' + IntToStr(cn2) ) > 0 then
        begin
          iTotal := cn2;
          Break;
        end;
      end;

      if iTotal > 0
        then iString := Padded('   @y'+LuaSystem.Get(['awards',cn,'name'])+' ('+LuaSystem.Get(['awards',cn,'levels',iTotal,'name'])+')',38)
        else iString := Padded('   @d'+LuaSystem.Get(['awards',cn,'name'])+' (none yet)',38);
      Page.Push( Padded(iString,38)+ ' @dModule: @l'+LuaSystem.Get(['awards',cn,'mname']));
      if iTotal >= iFound
        then Page.Push('   @dMaximum award level reached. Award received for: @l'+LuaSystem.Get(['awards',cn,'levels',iTotal,'name'] ))
        else Page.Push('   @dTo achieve @L'+LuaSystem.Get(['awards',cn,'levels',iTotal+1,'name'])+'@d level you need to: @l'+LuaSystem.Get(['awards',cn,'levels',iTotal+1,'desc'] ));
    end;
    AddPage('Custom Awards', Page);
  end;


end;

function THOF.GetHOFReport : TUIHOFReport;
begin
  Result.Title   := 'DoomRL Hall of Fame';
  Result.Footer  := '@<a@>,@<emhun@>,@<'+ChallengeStr+'-@>,@<<Enter>@>';
  Result.Filters := 'a-emhun'+ChallengeStr;
  Result.Callback:= @(GetScores)
end;

procedure THOF.Init;
var cn  : DWord;
    let : Char;
begin
  SkillRank := 0;
  ExpRank   := 0;

  FScore := TScoreFile.Create(ConfigurationPath+ScoreFile, MaxHOFEntries );
  FScore.SetCRC( '344ef'+{ModuleID+}'3321', '738af'+{ModuleID+}'92-5' );
  FScore.SetBackup(  ConfigurationPath+'backup'+PathDelim, Option_ScoreBackups );
  FScore.Load;

  FPlayerInfo := TVXMLDataFile.Create( ConfigurationPath+PlayerFile, 'player' );
  FPlayerInfo.SetCRC( '344ef'+{ModuleID+}'3321', '738af'+{ModuleID+}'92-5' );
  FPlayerInfo.SetBackup(  ConfigurationPath+'backup'+PathDelim, Option_PlayerBackups );
  FPlayerInfo.Load;

  SkillRank := GetRank('skill');
  ExpRank   := GetRank('exp');

  HOFOpen := True;

  ChallengeChars := [];
  ChallengeStr   := '';
  for cn := 1 to LuaSystem.Get( ['chal','__counter'] ) do
  begin
    let := LuaSystem.Get(['chal',cn,'let']);
    Include( ChallengeChars, Ord(let) );
    ChallengeStr += let;
  end;
end;

function THOF.GameResultBetter( const ResultOld, ResultNew : String ) : boolean;
  function NameToVal( const Str : String ) : DWord;
  begin
    if Length(Str) = 0 then Exit(0);
    if Pos(':',Str) <> 0 then Exit( StrToInt(ExtractDelimited( 2, Str, [':'] ) ) );
    if Str = 'sacrifice' then Exit( 10000 );
    if Str = 'win'       then Exit( 20000 );
    if Str = 'final'     then Exit( 30000 );
    Exit(0);
  end;
begin
  if ResultOld = ResultNew then Exit(False);
  Exit( NameToVal( ResultOld ) < NameToVal( ResultNew ) );
end;

function THOF.GameResultAtLeast(const ResultAtLeast, ResultNew : String): boolean;
  function NameToVal( const Str : String ) : DWord;
  begin
    if Length(Str) = 0 then Exit(0);
    if Pos(':',Str) <> 0 then Exit( StrToInt(ExtractDelimited( 2, Str, [':'] ) ) );
    if Str = 'sacrifice' then Exit( 10000 );
    if Str = 'win'       then Exit( 20000 );
    if Str = 'final'     then Exit( 30000 );
    Exit(0);
  end;
begin
  if ResultAtLeast = ResultNew then Exit(True);
  Exit( NameToVal( ResultNew ) >= NameToVal( ResultAtLeast ) );
end;

function THOF.IncreaseXMLCount( aContainer : TDOMElement; const aElementID : string; const aID : string; aAmount : DWord ) : TDOMElement;
var iXMLElement  : TDOMElement;
begin
  if aAmount = 0 then Exit( nil );
  iXMLElement := FPlayerInfo.XML.GetElement(aElementID + '[@id="'+aID+'"]', aContainer);
  if iXMLElement = nil then
  begin
    iXMLElement := aContainer.OwnerDocument.CreateElement( aElementID );
    iXMLElement.SetAttribute( 'id', aID );
    iXMLElement.SetAttribute( 'count', IntToStr( aAmount ) );
    aContainer.AppendChild( iXMLElement );
  end
  else
    iXMLElement.SetAttribute('count', IntToStr(StrToIntDef(iXMLElement.GetAttribute('count'),0) + LongInt(aAmount)));
  Exit( iXMLElement );
end;

function THOF.IncreaseXMLCount( aContainer : TDOMElement; const aElementID : string; aAmount : DWord ) : TDOMElement;
var iXMLElement  : TDOMElement;
    iCurrent     : LongInt;
begin
  iXMLElement := TDOMElement(aContainer.FindNode(aElementID));
  if iXMLElement = nil then
  begin
    iXMLElement := aContainer.OwnerDocument.CreateElement(aElementID);
    iXMLElement.SetAttribute('count','0');
    aContainer.AppendChild( iXMLElement );
  end;
  iCurrent     := StrToIntDef(iXMLElement.GetAttribute('count'),0);
  iXMLElement.SetAttribute('count',IntToStr(iCurrent + LongInt(aAmount)));

  Exit( iXMLElement );
end;

procedure THOF.Add( const Name : AnsiString; aScore : LongInt; const aKillerID : AnsiString; Level, DLev : Word; nChal : AnsiString );
var cn : DWord;

    XMLElement : TDOMElement;
    XMLSubElement : TDOMElement;
    XMLEntry   : TDOMElement;
    iScoreEntry : TScoreEntry;
    VS,VSS : String;
    iGameResultID : AnsiString;
    iString : String;
    iGameResult : String;
    iKills : DWord;
    iWeaponID : DWord;
    iChalAbbr  : string;
    iChalInc : shortint;
    iDiffID : string;
    iWeaponGroup    : AnsiString;
    iKillsEntry     : TKillTableIterator.TPairType;
    iKillTypesEntry : TKillTableEntryIterator.TPairType;

  function WeaponGroup( const aID : AnsiString ) : AnsiString;
  begin
    if aID = 'other' then Exit('other');
    if aID = 'melee' then Exit('weapon-melee');
    Exit( LuaSystem.Get(['items',aID,'group'] ) );
  end;

begin
  iGameResultID := LuaSystem.ProtectedCall(['DoomRL','get_result_id'],[]);
  if not NoPlayerRecord then
  begin
    iDiffID       := LuaSystem.Get([ 'diff', Doom.Difficulty, 'id' ]);
    iChalInc      := 0;
    iChalAbbr     := 'unchallenged';
    if nChal <> '' then
    begin
      iChalAbbr := LuaSystem.Get(['chal',nChal,'abbr']);
      iChalInc := 1;
    end;

    XMLEntry := IncreaseXMLCount( FPlayerInfo.XML.DocumentElement, 'deaths', 1 );
    IncreaseXMLCount( XMLEntry, 'death', iChalAbbr, 1 );
    IncreaseXMLCount( XMLEntry, 'death', iGameResultID, 1 );
    if (aKillerID <> '') and (aKillerID <> Player.ID) then
      IncreaseXMLCount( XMLEntry, 'death', LuaSystem.Get(['beings',aKillerID,'id']), 1 );

    // KILLS

    XMLEntry := IncreaseXMLCount( FPlayerInfo.XML.DocumentElement, 'kills', Player.FKills.Count );

    for iKillsEntry in Player.FKills do
    begin
      iKills := iKillsEntry.Value.Count;
      if iKills = 0 then Continue;

      XMLElement := IncreaseXMLCount( XMLEntry, 'killbeing', iKillsEntry.Key, iKills );
      IncreaseXMLCount( XMLElement, 'killtype', iDiffID, iKills );

      for iKillTypesEntry in iKillsEntry.Value do
      begin
        iWeaponGroup := WeaponGroup(iKillTypesEntry.Key);
        IncreaseXMLCount( XMLElement, 'killtype', iWeaponGroup, iKillTypesEntry.Value );
        IncreaseXMLCount( XMLEntry, 'killtype', iWeaponGroup, iKillTypesEntry.Value );
        if (iKillTypesEntry.Key <> 'melee') and (iKillTypesEntry.Key <> 'other') then
          IncreaseXMLCount( XMLEntry, 'killtype', iKillTypesEntry.Key, iKillTypesEntry.Value );
      end;
    end;

    IncreaseXMLCount( XMLEntry, 'killtype', iDiffID, Player.FKills.Count );
    IncreaseXMLCount( XMLEntry, 'killtype', iChalAbbr, Player.FKills.Count );

    // GAMES
    iGameResult := LuaSystem.ProtectedCall(['DoomRL','get_short_result_id'],[iGameResultID,DLev]);
    XMLEntry := IncreaseXMLCount( FPlayerInfo.XML.DocumentElement, 'games', 1 );
    if Doom.GameWon then
    begin
      IncreaseXMLCount( XMLEntry, 'win', iGameResult, 1 );
      IncreaseXMLCount( XMLEntry, 'win', 'total', 1 );
    end;
    XMLElement := IncreaseXMLCount( XMLEntry, 'game', iDiffID, 1 );
    iString := XMLElement.GetAttribute('max');
    if GameResultBetter( iString, iGameResult ) then XMLElement.SetAttribute('max',iGameResult);
    if Doom.GameWon then
    begin
      IncreaseXMLCount( XMLElement, 'win', iGameResult, 1 );
      IncreaseXMLCount( XMLElement, 'win', 'total', 1 );
    end;

    // CHALLENGES
    XMLEntry := IncreaseXMLCount( FPlayerInfo.XML.DocumentElement, 'challenges', iChalInc );
    XMLElement := IncreaseXMLCount( XMLEntry, 'challenge', iChalAbbr, 1 );
    iString := XMLElement.GetAttribute('max');
    if GameResultBetter( iGameResult, iString ) then XMLElement.SetAttribute('max',iGameResult);
    if Doom.GameWon then
    begin
      IncreaseXMLCount( XMLElement, 'win', iGameResult, 1 );
      IncreaseXMLCount( XMLElement, 'win', 'total', 1 );
    end;
    XMLSubElement := IncreaseXMLCount( XMLElement, 'game', iDiffID, 1 );
    iString := XMLSubElement.GetAttribute('max');
    if GameResultBetter( iString, iGameResult ) then XMLSubElement.SetAttribute('max',iGameResult);
    if Doom.GameWon then
    begin
      IncreaseXMLCount( XMLSubElement, 'win', iGameResult, 1 );
      IncreaseXMLCount( XMLSubElement, 'win', 'total', 1 );
    end;
  end;

  if not NoScoreRecord then
  begin
    VS := LuaSystem.ProtectedCall(['DoomRL','get_result_description'],[iGameResultID,true]);

    iScoreEntry := FScore.Add( aScore );
    if iScoreEntry <> nil then
    begin
      //Score.Add(Name,aScore,Level,DLev,Doom.Difficulty,VS,VSS,LuaSystem.Get(['klasses',Player.Klass,'id']));
      iScoreEntry.SetAttribute('name', Name );
      iScoreEntry.SetAttribute('level', IntToStr(Level) );
      iScoreEntry.SetAttribute('depth', IntToStr(DLev) );
      iScoreEntry.SetAttribute('klass', LuaSystem.Get(['klasses',Player.Klass,'id']) );
      iScoreEntry.SetAttribute('killed', VS );
      iScoreEntry.SetAttribute('difficulty', IntToStr(Doom.Difficulty) );
      if nChal <> '' then
        iScoreEntry.SetAttribute('challenge', LuaSystem.Get(['chal',nChal,'abbr']) );
    end;
  end;
  Save;
end;

function THOF.RankCheck( out aResult : THOFRank ) : Boolean;
begin
  if NoPlayerRecord then Exit( False );

    // check self-imposed challanges!
  aResult.SkillRank := SkillRank;
  aResult.ExpRank   := ExpRank;

  try
    while CheckRank(RANKEXP,ExpRank)     do Inc(ExpRank);
    while CheckRank(RANKSKILL,SkillRank) do Inc(SkillRank);
  except
    on e : EDOMError do
      Log( e.Message );
  end;

  if aResult.SkillRank = SkillRank then aResult.SkillRank := 0 else aResult.SkillRank := SkillRank;
  if aResult.ExpRank   = ExpRank   then aResult.ExpRank := 0   else aResult.ExpRank := ExpRank;

  SetRank('skill', SkillRank);
  SetRank('exp', ExpRank);

  Exit( (aResult.SkillRank <> 0) or (aResult.ExpRank <> 0) );
end;

procedure THOF.Done;
begin
  Save;
  FreeAndNil( FScore );
  FreeAndNil( FPlayerInfo );
  HOFOpen := False;
end;


procedure THOF.Save;
var iSeconds : DWord;
begin
  if not HOFOpen then Exit;

  iSeconds := Round( (MSecNow() - ProgramRealTime) / 1000 );
  ProgramRealTime := MSecNow();
  IncreaseXMLCount( FPlayerInfo.XML.DocumentElement, 'time', iSeconds );

  FScore.Save;
  FPlayerInfo.Save;
end;

function THOF.GetRankReqCount(const aRankArray: AnsiString; aRankLevel: DWord ): DWord;
begin
  Exit( LuaSystem.GetTableSize( [ aRankArray, aRankLevel+1, 'reqs' ] ) );
end;

function THOF.GetRankReqDescription(const aRankArray: AnsiString; aRankLevel: DWord; aRankReq: DWord): AnsiString;
var iAmount : DWord;
    iParam  : Variant;
    iReq    : AnsiString;
begin
  with LuaSystem.GetTable( [ aRankArray, aRankLevel+1, 'reqs', aRankReq ] ) do
  try
    iParam  := GetField( 'param' );
    iAmount := GetInteger( 'amount', 1 );
    iReq    := GetString( 'req' );
  finally
    Free;
  end;
  Exit( LuaSystem.ProtectedCall( ['requirements', iReq, 'description'], [iAmount, iParam] ) );
end;

function THOF.IsRankReqCompleted(const aRankArray: AnsiString; aRankLevel: DWord; aRankReq: DWord): Boolean;
var iAmount : DWord;
    iParam  : Variant;
    iReq    : AnsiString;
begin
  with LuaSystem.GetTable( [ aRankArray, aRankLevel+1, 'reqs', aRankReq ] ) do
  try
    iParam  := GetField( 'param' );
    iAmount := GetInteger( 'amount', 1 );
    iReq    := GetString( 'req' );
  finally
    Free;
  end;
  Exit( LuaSystem.ProtectedCall( ['requirements', iReq, 'progress'], [iParam] ) >= iAmount );
end;

function THOF.GetRankReqCurrent(const aRankArray: AnsiString; aRankLevel: DWord; aRankReq: DWord): DWord;
var iParam  : Variant;
    iReq    : AnsiString;
begin
  with LuaSystem.GetTable( [ aRankArray, aRankLevel+1, 'reqs', aRankReq ] ) do
  try
    iParam  := GetField( 'param' );
    iReq    := GetString( 'req' );
  finally
    Free;
  end;
  Exit( LuaSystem.ProtectedCall( ['requirements', iReq, 'progress'], [iParam] ) );
end;

function THOF.GetRankReqTotal(const aRankArray: AnsiString; aRankLevel: DWord; aRankReq: DWord): DWord;
begin
  Exit( LuaSystem.Get( [ aRankArray, aRankLevel+1, 'reqs', aRankReq, 'amount' ], 1 ) );
end;

function THOF.CheckRank(rank, current : Byte) : Boolean;
var iCount : DWord;
begin
  if Current+1 >= LuaSystem.Get([RankArray[ rank ],'__counter']) then Exit( False );
  iCount := GetRankReqCount( RankArray[ rank ], Current+1 );
  if iCount = 0 then Exit( True );
  for iCount := 1 to iCount do
    if not IsRankReqCompleted( RankArray[ rank ], Current+1, iCount ) then Exit( False );
  Exit( True );
end;

end.
