{$INCLUDE doomrl.inc}
unit dfoutput;
interface
uses SysUtils, Classes,
     vluastate, vutil, dfdata, vmath, vrltools,
     vnode, vcolor, vluaconfig, vgenerics,
     viotypes,
     vuitypes, doomspritemap, doomanimation, doomio, doomui;

type TASCIIImageMap = specialize TGObjectHashMap<TUIStringArray>;


type

{ TDoomUI }

 TDoomUI = class(TVObject)
    // Initialization of all data.
    constructor Create(FullScreen : Boolean = False);
    // Graphical effect of a screen flash, of the given color, and Duration in
    // miliseconds.
    procedure Blink(Color : Byte; Duration : Word = 100; aDelay : DWord = 0);

    procedure BloodSlideDown(DelayTime : word);

    // ToDo : this is unused... maybe use it somewhere?
    //procedure ClearKeyBuffer;

    //procedure Save;
    procedure addMoveAnimation( aDuration : DWord; aDelay : DWord; aUID : TUID; aFrom, aTo : TCoord2D; aSprite : TSprite );
    procedure addMissileAnimation( aDuration : DWord; aDelay : DWord; aSource, aTarget : TCoord2D; aColor : Byte; aPic : Char; aDrawDelay : Word; aSprite : TSprite; aRay : Boolean = False );
    procedure addMarkAnimation( aDuration : DWord; aDelay : DWord; aCoord : TCoord2D; aColor : Byte; aPic : Char );
    procedure addSoundAnimation( aDelay : DWord; aPosition : TCoord2D; aSoundID : DWord );
    procedure addScreenMoveAnimation( aDuration : DWord; aDelay : DWord; aTo : TCoord2D );
    procedure WaitForAnimation;
    function AnimationsRunning : Boolean;
    procedure GFXAnimationDraw;
    procedure GFXAnimationUpdate( aTime : DWord );

    procedure SetTempHint( const aText : AnsiString );
    procedure SetHint( const aText : AnsiString );
    procedure Msg( const aText : AnsiString );
    procedure Msg( const aText : AnsiString; const aParams : array of const );
    procedure MsgEnter( const aText : AnsiString );
    procedure MsgEnter( const aText : AnsiString; const aParams : array of const );
    function  MsgConfirm( const aText : AnsiString; aStrong : Boolean = False ) : Boolean;
    function  MsgChoice( const aText : AnsiString; const aChoices : TKeySet ) : Byte;
    function  MsgCommandChoice( const aText : AnsiString; const aChoices : TKeySet ) : Byte;
    function  MsgGetRecent : TUIChunkBuffer;
    procedure MsgReset;
    // TODO: Coult this be removed as well?
    procedure MsgUpDate;
    procedure ErrorReport( const aText : AnsiString );

    procedure ClearAllMessages;

    procedure Explosion( aSequence : Integer; aWhere : TCoord2D; aRange, aDelay : Integer; aColor : byte; aExplSound : Word; aFlags : TExplosionFlags = [] );

    procedure LookMode;
    function ChooseDirection(aActionName : string) : TDirection;
    function ChooseTarget( aActionName : string; aRange : byte; aTargets : TAutoTarget; aShowLast : Boolean = False ) : TCoord2D;

    procedure Focus( aCoord : TCoord2D );

    procedure Mark( aCoord : TCoord2D; aColor : Byte; aChar : Char; aDuration : DWord; aDelay : DWord = 0);

    procedure CreateMessageWriter( INI : TLuaConfig );
    destructor Destroy; override;
    class procedure RegisterLuaAPI( State : TLuaState );

    function GetLookDescription( aWhere : TCoord2D ) : AnsiString;

    procedure ASCIILoader( aStream : TStream; aName : Ansistring; aSize : DWord );
  private
    FHint       : AnsiString;
    FGameUI     : TDoomGameUI;
    FLastTick   : TDateTime;
    FASCII      : TASCIIImageMap;

    // GFX only animations
    FAnimations : TAnimationManager;
    Waiting     : Boolean;

    procedure LookDescription( aWhere : TCoord2D );
//    procedure SlideDown(DelayTime : word; var NewScreen : TGFXScreen);
  public
    property ASCII  : TASCIIImageMap read FASCII;
    property GameUI : TDoomGameUI read FGameUI;
  end;

var UI : TDoomUI = nil;


implementation

uses doomlua, dateutils, vdebug, vsystems, vluasystem, vconuirl, video, doombase, dfplayer, dflevel, dfmap, vvision;

{
procedure OutPutRestore;
var vx,vy : byte;
begin
  if GraphicsVersion then Exit;
  for vx := 1 to 80 do for vy := 1 to 25 do VideoBuf^[(vx-1)+(vy-1)*ScreenSizeX] := GFXCapture[vy,vx];
end;
}

//type TGFXScreen = array[1..25,1..80] of Word;
//var  GFXCapture : TGFXScreen;


procedure TDoomUI.BloodSlideDown(DelayTime : word);
{
const BloodPic : TPictureRec = (Picture : ' '; Color : 16*Red);
var Temp  : TGFXScreen;
    Blood : TGFXScreen;
    vx,vy : byte;
}
begin
  if Option_NoBloodSlide or GraphicsVersion then
  begin
    exit;
  end;
{
  for vx := 1 to 80 do for vy := 1 to 25 do Temp [vy,vx] := VideoBuf^[(vx-1)+(vy-1)*ScreenSizeX];
  OutputRestore;
  {$HINTS OFF}
  FillWord(Blood,25*80,Word(BloodPic));
  {$HINTS ON}
  SlideDown(DelayTime,Blood);
  SlideDown(DelayTime,Temp);
}
end;

{
procedure TDoomUI.SlideDown(DelayTime : word; var NewScreen : TGFXScreen);
var Pos  : array[1..80] of Byte;
    cn,t, vx,vy : byte;
  procedure MoveColumn(x : byte);
  var y : byte;
  begin
    if pos[x]+1 > 25 then Exit;
    for y := 24 downto pos[x]+1 do
      VideoBuf^[(x-1)+y*LongInt(ScreenSizeX)] := VideoBuf^[(x-1)+(y-1)*LongInt(ScreenSizeX)];
    VideoBuf^[(x-1)+pos[x]*LongInt(ScreenSizeX)] := NewScreen[pos[x]+1,x];
    Inc(pos[x]);
  end;

begin
  if GraphicsVersion then Exit;
  for cn := 1 to 80  do Pos[cn] := 0;
  for cn := 1 to 160 do MoveColumn(Random(80)+1);
  t := 1;
  repeat
    Inc(t);
    IO.Delay(DelayTime);
    for cn := 1 to 80 do MoveColumn(cn);
  until t = 25;
  for vx := 1 to 80 do for vy := 1 to 25 do VideoBuf^[(vx-1)+(vy-1)*ScreenSizeX] := NewScreen[vy,vx];

end;
}

{ TDoomUI }

constructor TDoomUI.Create(FullScreen: Boolean);
begin
  inherited Create;
  Waiting := False;
  FGameUI := nil;
  FHint := '';
  FAnimations := nil;
  if GraphicsVersion then FAnimations := TAnimationManager.Create;
  FASCII := TASCIIImageMap.Create( True );
end;

procedure TDoomUI.Blink(Color : Byte; Duration : Word = 100; aDelay : DWord = 0);
var iChr : Char;
begin
  if GraphicsVersion then
  begin
    FAnimations.AddAnimation(TDoomBlink.Create(Duration,aDelay,Color));
    Exit;
  end;
  if Option_HighASCII then iChr := Chr(219) else iChr := '#';
  FGameUI.Map.AddAnimation( TConUIBlinkAnimation.Create(IOGylph( iChr, Color ),Duration,aDelay));
end;

procedure TDoomUI.GFXAnimationUpdate( aTime : DWord );
begin
  if not GraphicsVersion then Exit;
  FAnimations.Update( aTime );
end;

procedure TDoomUI.addMoveAnimation ( aDuration : DWord; aDelay : DWord; aUID : TUID; aFrom, aTo : TCoord2D; aSprite : TSprite );
begin
  if Doom.State <> DSPlaying then Exit;
  if not GraphicsVersion then Exit;
  FAnimations.AddAnimation(TDoomMove.Create(aDuration, aDelay, aUID, aFrom, aTo, aSprite));
end;

procedure TDoomUI.addMissileAnimation(aDuration: DWord; aDelay: DWord; aSource,
  aTarget: TCoord2D; aColor: Byte; aPic: Char; aDrawDelay: Word;
  aSprite: TSprite; aRay: Boolean);
begin
  if Doom.State <> DSPlaying then Exit;
  if GraphicsVersion then
  begin
    FAnimations.addAnimation(
      TDoomMissile.Create( aDuration, aDelay, aSource,
        aTarget, aDrawDelay, aSprite, aRay ) );
    Exit;
  end;
  if aRay
    then FGameUI.Map.AddAnimation( TConUIRayAnimation.Create( Doom.Level, aSource, aTarget, IOGylph( aPic, aColor ), aDuration, aDelay, Player.Vision ) )
    else FGameUI.Map.AddAnimation( TConUIBulletAnimation.Create( Doom.Level, aSource, aTarget, IOGylph( aPic, aColor ), aDuration, aDelay, Player.Vision ) );
end;

procedure TDoomUI.addMarkAnimation(aDuration: DWord; aDelay: DWord;
  aCoord: TCoord2D; aColor: Byte; aPic: Char);
begin
  if Doom.State <> DSPlaying then Exit;
  if GraphicsVersion
    then FAnimations.addAnimation( TDoomMark.Create(aDuration, aDelay, aCoord ) )
    else FGameUI.Map.AddAnimation( TConUIMarkAnimation.Create( aCoord, IOGylph( aPic, aColor ), aDuration, aDelay ) );
end;

procedure TDoomUI.addSoundAnimation(aDelay: DWord; aPosition: TCoord2D;
  aSoundID: DWord);
begin
  if Doom.State <> DSPlaying then Exit;
  if GraphicsVersion
    then FAnimations.addAnimation( TDoomSoundEvent.Create( aDelay, aPosition, aSoundID ) )
    else FGameUI.Map.AddAnimation( TDoomSoundEvent.Create( aDelay, aPosition, aSoundID ) )
end;

procedure TDoomUI.addScreenMoveAnimation(aDuration: DWord; aDelay: DWord; aTo: TCoord2D);
begin
  if Doom.State <> DSPlaying then Exit;
  if not GraphicsVersion then Exit;
  FAnimations.addAnimation( TDoomScreenMove.Create( aDuration, aDelay, aTo ) );
end;

function TDoomUI.AnimationsRunning : Boolean;
begin
  if Doom.State <> DSPlaying then Exit(False);
  if GraphicsVersion
    then Exit( not FAnimations.Finished )
    else Exit( not FGameUI.Map.AnimationsFinished );
end;

procedure TDoomUI.GFXAnimationDraw;
begin
  if not GraphicsVersion then Exit;
  FAnimations.Draw;
end;

procedure TDoomUI.WaitForAnimation;
begin
  if Waiting then Exit;
  if Doom.State <> DSPlaying then Exit;
  Waiting := True;
  while AnimationsRunning do
  begin
    IO.Delay(5);
  end;
  if GraphicsVersion
    then FAnimations.Clear
    else FGameUI.Map.ClearAnimations;
  Waiting := False;
  Doom.Level.RevealBeings;
end;

procedure TDoomUI.SetHint ( const aText : AnsiString ) ;
begin
  FHint := aText;
  FGameUI.Hint.SetText( aText );
end;

procedure TDoomUI.SetTempHint ( const aText : AnsiString ) ;
begin
  if aText = ''
    then FGameUI.Hint.SetText( FHint )
    else FGameUI.Hint.SetText( aText );
end;

procedure TDoomUI.Msg( const aText : AnsiString );
begin
  if FGameUI <> nil then
    FGameUI.Messages.Add(aText);
end;

procedure TDoomUI.Msg( const aText : AnsiString; const aParams : array of const );
begin
  Msg( Format( aText, aParams ) );
end;

procedure TDoomUI.MsgEnter( const aText: AnsiString);
begin
  Msg(aText+' Press <Enter>...');
  IO.WaitForEnter;
  MsgUpDate;
end;

procedure TDoomUI.MsgEnter( const aText: AnsiString; const aParams: array of const);
begin
  Msg( aText+' Press <Enter>...', aParams );
  IO.WaitForEnter;
  MsgUpDate;
end;

function TDoomUI.MsgConfirm( const aText: AnsiString; aStrong : Boolean = False): Boolean;
var Key : byte;
begin
  if aStrong then Msg(aText+' [Y/n]')
             else Msg(aText+' [y/n]');
  if aStrong then Key := IO.WaitForKey([Ord('Y'),Ord('N'),Ord('n')])
             else Key := IO.WaitForKey([Ord('Y'),Ord('y'),Ord('N'),Ord('n')]);
  MsgConfirm := Key in [Ord('Y'),Ord('y')];
  MsgUpDate;
end;

function TDoomUI.MsgChoice ( const aText : AnsiString; const aChoices : TKeySet ) : Byte;
var ChoiceStr : string;
    Count     : Byte;
begin
  ChoiceStr := '';
  for Count := 0 to 255 do
    if Count in aChoices then
      if Count in [31..126] then ChoiceStr += Chr(Count);

  Msg(aText + ' ['+ChoiceStr+']');
  MsgChoice := IO.WaitForKey( aChoices );
end;

function TDoomUI.MsgCommandChoice ( const aText : AnsiString; const aChoices : TKeySet ) : Byte;
begin
  Msg(aText);
  repeat
    Result := IO.WaitForCommand( aChoices );
  until Result in aChoices;
end;

function TDoomUI.MsgGetRecent : TUIChunkBuffer;
begin
  Exit( FGameUI.Messages.Content );
end;

procedure TDoomUI.MsgReset;
begin
  FGameUI.Messages.Reset;
  FGameUI.Messages.Update;
end;

procedure TDoomUI.MsgUpDate;
begin
  FGameUI.Messages.Update;
  UI.SetTempHint('');
end;

procedure TDoomUI.ErrorReport(const aText: AnsiString);
begin
  MsgEnter('@RError:@> '+aText);
  Msg('@yError written to error.log, please report!@>');
end;

procedure TDoomUI.ClearAllMessages;
begin
  FGameUI.Messages.Clear;
end;

procedure TDoomUI.Explosion(aSequence : Integer; aWhere: TCoord2D; aRange, aDelay: Integer;
  aColor: byte; aExplSound: Word; aFlags: TExplosionFlags);
var iExpl     : TConUIExplosionArray;
    iCoord    : TCoord2D;
    iDistance : Byte;
    iVisible  : boolean;
    iLevel    : TLevel;
begin
  if not GraphicsVersion then
  begin
    FGameUI.Map.FreezeMarks;
    SetLength( iExpl, 4 );
    iExpl[0].Time := aDelay;
    iExpl[1].Time := aDelay;
    iExpl[2].Time := aDelay;
    iExpl[3].Time := aDelay;
    case aColor of
      Blue    : begin iExpl[3].Color := Blue;    iExpl[0].Color := LightBlue;  iExpl[1].Color := White; end;
      Magenta : begin iExpl[3].Color := Magenta; iExpl[0].Color := Red;        iExpl[1].Color := Blue; end;
      Green   : begin iExpl[3].Color := Green;   iExpl[0].Color := LightGreen; iExpl[1].Color := White; end;
      LightRed: begin iExpl[3].Color := LightRed;iExpl[0].Color := Yellow;     iExpl[1].Color := White; end;
       else     begin iExpl[3].Color := Red;     iExpl[0].Color := LightRed;   iExpl[1].Color := Yellow; end;
    end;
    iExpl[2].Color := iExpl[0].Color;
  end;

  iLevel := Doom.Level;
  if not iLevel.isProperCoord( aWhere ) then Exit;

  if aExplSound <> 0 then
    addSoundAnimation( aSequence, aWhere, aExplSound );

  for iCoord in NewArea( aWhere, aRange ).Clamped( iLevel.Area ) do
    begin
      if aRange < 10 then if iLevel.isVisible(iCoord) then iVisible := True else Continue;
      if aRange < 10 then if not iLevel.isEyeContact( iCoord, aWhere ) then Continue;
      iDistance := Distance(iCoord, aWhere);
      if iDistance > aRange then Continue;
      if GraphicsVersion
        then FAnimations.AddAnimation( TDoomExplodeMark.Create(3*aDelay,aSequence+aDelay*iDistance,iCoord,aColor) )
        else FGameUI.Map.AddAnimation( TConUIExplosionAnimation.Create( iCoord, '*', iExpl, iDistance*aDelay+aSequence ) );
    end;
  if aRange >= 10 then iVisible := True;

  if not GraphicsVersion then
     FGameUI.Map.AddAnimation( TConUIClearMarkAnimation.Create( aRange*aDelay+aSequence ) );

  // TODO : events
  if efAfterBlink in aFlags then
  begin
    Blink(LightGreen,50,aSequence+aDelay*aRange);
    Blink(White,50,aSequence+aDelay*aRange+60);
  end;

  if not iVisible then if aRange > 3 then
    UI.Msg( 'You hear an explosion!' );
//    Animations.Add(TDoomMessage.Create('You hear an explosion!'),Sequence+EDelay*Range);
end;



procedure TDoomUI.LookMode;
var Key    : byte;
    Dir    : TDirection;
    lc     : TCoord2D;
    TargetColor : TColor;
    Target  : TCoord2D;
    iLevel  : TLevel;
begin
  iLevel := Doom.Level;
  Target := Player.Position;
  TargetColor := NewColor( White );
  LookDescription( Target );
  repeat
    if SpriteMap <> nil then SpriteMap.SetTarget( Target, TargetColor, False );
    TargetColor := NewColor( White );
    Key := IO.WaitForCommand(COMMANDS_MOVE+[COMMAND_GRIDTOGGLE,COMMAND_ESCAPE,COMMAND_MORE,COMMAND_MMOVE,COMMAND_MRIGHT, COMMAND_MLEFT]);
    if (Key = COMMAND_GRIDTOGGLE) and GraphicsVersion then SpriteMap.ToggleGrid;
    if Key in [ COMMAND_MMOVE, COMMAND_MRIGHT, COMMAND_MLEFT ] then Target := IO.MTarget;
    if Key in [ COMMAND_ESCAPE, COMMAND_MRIGHT ] then Break;
    if Key <> COMMAND_MORE then
    begin
      lc := Target;
      Dir := CommandDirection( Key );
      if iLevel.isProperCoord(lc + Dir) then
      begin
        Target := lc + Dir;
        LookDescription( Target );
        Focus( Target );
      end
      else
      if Option_BlindMode then
      begin
        TargetColor := NewColor( Red );
        FGameUI.Messages.Pop;
        Msg('Out of range!');
        Continue;
      end;
      if Option_BlindMode then
      if lc = Target then
      begin
        TargetColor := NewColor( Red );
        FGameUI.Messages.Pop;
        Msg('Out of range!');
      end;
     end;
     if (Key in [ COMMAND_MORE, COMMAND_MLEFT ]) and iLevel.isVisible( Target ) then
     begin
       with iLevel do
       if Being[Target] <> nil then
          Being[Target].FullLook;
       Focus( Target );
       LookDescription( Target );
     end;
  until False;
  MsgUpDate;
  if SpriteMap <> nil then SpriteMap.ClearTarget;
end;

function TDoomUI.ChooseDirection(aActionName : string): TDirection;
var Key : byte;
    Position : TCoord2D;
    iTarget : TCoord2D;
    iDone : Boolean;
begin
  Position := Player.Position;
  Msg( aActionName + ' -- Choose direction...' );
  iDone := False;
  repeat
    Key := IO.WaitForCommand(COMMANDS_MOVE+[COMMAND_GRIDTOGGLE,COMMAND_ESCAPE,COMMAND_MLEFT,COMMAND_MRIGHT]);
    if (Key = COMMAND_GRIDTOGGLE) and GraphicsVersion then SpriteMap.ToggleGrid;
    if Key in COMMANDS_MOVE then
    begin
      ChooseDirection := CommandDirection(Key);
      iDone := True;
    end;
    if (Key = COMMAND_MLEFT) then
    begin
      iTarget := IO.MTarget;
      if (Distance( iTarget, Position) = 1) then
      begin
        ChooseDirection.Create(Position, iTarget);
        iDone := True;
      end;
    end;
    if (Key in [COMMAND_MRIGHT,COMMAND_ESCAPE]) then
    begin
      ChooseDirection.Create(DIR_CENTER);
      iDone := True;
    end;
  until iDone;
end;

function TDoomUI.ChooseTarget(aActionName : string; aRange: byte;
  aTargets: TAutoTarget; aShowLast: Boolean): TCoord2D;
var Key : byte;
    Dir : TDirection;
    Position : TCoord2D;
    iTarget : TCoord2D;
    iTargetColor : Byte;
    iTargetRange : Byte;
    iTargetLine  : TVisionRay;
    iLevel : TLevel;
    iDist : Byte;
    iBlock : Boolean;
begin
  iLevel      := Doom.Level;
  Position    := Player.Position;
  iTarget     := aTargets.Current;
  iTargetRange:= aRange;
  iTargetColor := Green;

  Msg( aActionName );
  MsgUpDate;
  Msg('You see : ');

  if aShowLast then
    FGameUI.SetLastTarget( Player.TargetPos );

  LookDescription( iTarget );
  repeat
    if iTarget <> Position then
      begin
        iTargetLine.Init(iLevel, Position, iTarget);
        iBlock := false;
        repeat
          iTargetLine.Next;
          if iLevel.cellFlagSet(iTargetLine.GetC, CF_BLOCKMOVE) then iBlock := true;
        until iTargetLine.Done;
      end
    else iBlock := False;
    if iBlock then iTargetColor := Red else iTargetColor := Green;
    FGameUI.SetTarget( iTarget, iTargetColor, iTargetRange );

    Key := IO.WaitForCommand(COMMANDS_MOVE+[COMMAND_GRIDTOGGLE, COMMAND_ESCAPE,COMMAND_MORE,COMMAND_FIRE,COMMAND_ALTFIRE,COMMAND_TACTIC, COMMAND_MMOVE,COMMAND_MRIGHT, COMMAND_MLEFT]);
    if (Key = COMMAND_GRIDTOGGLE) and GraphicsVersion then SpriteMap.ToggleGrid;
    if Key in [ COMMAND_MMOVE, COMMAND_MRIGHT, COMMAND_MLEFT ] then
       begin
         iTarget := IO.MTarget;
         iDist := Distance(iTarget.x, iTarget.y, Position.x, Position.y);
         if iDist > aRange-1 then
           begin
             iDist := 0;
             iTargetLine.Init(iLevel, Position, iTarget);
             while iDist < (aRange - 1) do
               begin
                    iTargetLine.Next;
                    iDist := Distance(iTargetLine.GetSource.x, iTargetLine.GetSource.y,  iTargetLine.GetC.x, iTargetLine.GetC.y);
               end;
             if Distance(iTargetLine.GetSource.x, iTargetLine.GetSource.y, iTargetLine.GetC.x, iTargetLine.GetC.y) > aRange-1
             then iTarget := iTargetLine.prev
             else iTarget := iTargetLine.GetC;
           end;
       end;
    if Key in [ COMMAND_ESCAPE, COMMAND_MRIGHT ] then begin iTarget.x := 0; Break; end;
    if Key = COMMAND_TACTIC then iTarget := aTargets.Next;
    if (Key in COMMANDS_MOVE) then
    begin
      Dir := CommandDirection( Key );
      if (iLevel.isProperCoord( iTarget + Dir ))
        and (Distance((iTarget + Dir).x, (iTarget + Dir).y, Position.x, Position.y) <= aRange-1) then
        iTarget += Dir;
    end;
    if (Key = COMMAND_MORE) then
    begin
      with iLevel do
      if Being[ iTarget ] <> nil then
         Being[ iTarget ].FullLook;
    end;
    LookDescription( iTarget );
  until Key in [COMMAND_FIRE, COMMAND_ALTFIRE, COMMAND_MLEFT];
  MsgUpDate;
  FGameUI.ResetTarget;
  ChooseTarget := iTarget;
end;

procedure TDoomUI.Focus(aCoord: TCoord2D);
begin
  IO.Console.ShowCursor;
  IO.Console.MoveCursor(aCoord.x+1,aCoord.y+2);
end;

procedure TDoomUI.Mark(aCoord: TCoord2D; aColor: Byte; aChar: Char; aDuration: DWord; aDelay: DWord);
begin
  if GraphicsVersion
    then FAnimations.AddAnimation(TDoomMark.Create( aDuration, aDelay, aCoord ) )
    else FGameUI.Map.AddAnimation( TConUIMarkAnimation.Create( aCoord, IOGylph( aChar, aColor ), aDuration, aDelay ) );
end;

procedure TDoomUI.CreateMessageWriter(INI: TLuaConfig);
begin
  if FGameUI <> nil then Exit;
  FGameUI := TDoomGameUI.Create( IO.Root, Rectangle(0,0,80,25) );
  if Option_MessageColoring then
    INI.EntryFeed( 'Messages', @FGameUI.Messages.AddHighlightCallback );
  FGameUI.Enabled := False;
end;

destructor TDoomUI.Destroy;
begin
  FreeAndNil( FAnimations );
  FreeAndNil( FASCII );
  inherited Destroy;
end;

function TDoomUI.GetLookDescription ( aWhere : TCoord2D ) : AnsiString;
var iCellID : DWord;
  procedure AddInfo( const what : AnsiString );
  begin
    if Result = '' then Result := what
                   else Result += ' | ' + what;
  end;
begin
  if Doom.Level.isVisible( aWhere ) then
   with Doom.Level do
    begin
      Result := '';
      if Being[ aWhere ] <> nil then
      with Being[ aWhere ] do
        AddInfo( GetName( false ) + ' (' + WoundStatus + ')' );
      if Item[ aWhere ] <> nil then
        if Item[ aWhere ].isLever then AddInfo( Player.DescribeLever( Item[ aWhere ] ) )
                                  else AddInfo( Item[ aWhere ].GetName( false ) );
      if CellHook_OnDescribe in Cells[ Cell[ aWhere ] ].Hooks then
         AddInfo( CallHook( aWhere, CellHook_OnDescribe ) )
      else
      begin
        iCellID := GetCell(aWhere);
        if LightFlag[ aWhere, LFBLOOD ] and (Cells[ iCellID ].bldesc <> '')
          then AddInfo( Cells[ GetCell(aWhere) ].bldesc )
          else AddInfo( Cells[ GetCell(aWhere) ].desc );
      end;
    end
  else Result := 'out of vision';
end;

procedure TDoomUI.ASCIILoader ( aStream : TStream; aName : Ansistring; aSize : DWord ) ;
var iImage   : TUIStringArray;
    iCounter : DWord;
    iAmount  : DWord;
begin
  Log('Registering ascii file '+aName+'...');
  iAmount := aStream.ReadDWord;
  iImage := TUIStringArray.Create;
  for iCounter := 1 to Min(iAmount,25) do
    iImage.Push( aStream.ReadAnsiString );
  FASCII.Items[LowerCase(LeftStr(aName,Length(aName)-4))] := iImage;
end;

procedure TDoomUI.LookDescription(aWhere: TCoord2D);
var LookDesc : string;
begin
  LookDesc := GetLookDescription( aWhere );
  if Option_BlindMode then LookDesc += ' | '+BlindCoord( aWhere - Player.Position );
  if Doom.Level.isVisible(aWhere) and (Doom.Level.Being[aWhere] <> nil) then LookDesc += ' | [@<m@>]ore';
  FGameUI.Messages.Pop;
  Msg('You see : '+LookDesc );
end;

function lua_ui_set_hint(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  if Option_Hints then
    UI.SetHint( State.ToString( 1 ) );
  Result := 0;
end;

(**************************** LUA UI *****************************)

{$HINTS OFF} // To supress Hint: Parameter "x" not found

function lua_ui_blood_slide(L: Plua_State): Integer; cdecl;
begin
  UI.BloodSlideDown(20);
  Result := 0;
end;

{$HINTS ON}

function lua_ui_blink(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  UI.Blink(State.ToInteger(1),State.ToInteger(2));
  Result := 0;
end;

function lua_ui_plot_screen(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  IO.RunUILoop( TConUIPlotViewer.Create( IO.Root, State.ToString(1), Rectangle( Point(10,5), 62, 15 ) ) );
  Result := 0;
end;

function lua_ui_msg(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  UI.Msg(State.ToString(1));
  Result := 0;
end;

function lua_ui_msg_clear(L: Plua_State): Integer; cdecl;
begin
  UI.MsgReset();
  Result := 0;
end;

function lua_ui_msg_enter(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  if State.StackSize = 0 then Exit(0);
  UI.MsgEnter(State.ToString(1));
  Result := 0;
end;

function lua_ui_msg_confirm(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  if State.StackSize = 0 then Exit(0);
  State.Push( UI.MsgConfirm(State.ToString(1), State.ToBoolean(2) ) );
  Result := 1;
end;

function lua_ui_msg_choice(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    Choices : TKeySet;
    ChStr   : AnsiString;
    Choice  : Byte;
begin
  State.Init(L);
  if State.StackSize < 2 then Exit(0);
  ChStr := State.ToString(2);
  if Length(ChStr) < 2 then Exit(0);

  Choices := [];
  for Choice := 1 to Length(ChStr) do
    Include(Choices,Ord(ChStr[Choice]));

  ChStr := Chr( UI.MsgChoice( State.ToString(1), Choices ) );
  State.Push(ChStr);
  Result := 1;
end;

function lua_ui_msg_history(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    Idx   : Integer;
    Msg   : AnsiString;
begin
  State.Init(L);
  if State.StackSize = 0 then Exit(0);
  Idx := State.ToInteger(1)+1;
  if Idx > UI.MsgGetRecent.Size then
    State.PushNil
  else
  begin
    Msg := ChunkListToString( UI.MsgGetRecent[-Idx] );
    if Msg <> '' then
      State.Push( Msg )
    else
      State.PushNil;
  end;
  Result := 1;
end;

const lua_ui_lib : array[0..10] of luaL_Reg = (
      ( name : 'msg';         func : @lua_ui_msg ),
      ( name : 'msg_clear';   func : @lua_ui_msg_clear ),
      ( name : 'msg_enter';   func : @lua_ui_msg_enter ),
      ( name : 'msg_choice';  func : @lua_ui_msg_choice ),
      ( name : 'msg_confirm'; func : @lua_ui_msg_confirm ),
      ( name : 'msg_history'; func : @lua_ui_msg_history ),
      ( name : 'blood_slide'; func : @lua_ui_blood_slide),
      ( name : 'blink';       func : @lua_ui_blink),
      ( name : 'plot_screen'; func : @lua_ui_plot_screen),
      ( name : 'set_hint';    func : @lua_ui_set_hint ),
      ( name : nil;          func : nil; )
);

class procedure TDoomUI.RegisterLuaAPI( State : TLuaState );
begin
  State.Register( 'ui', lua_ui_lib );
end;



initialization

{with VDefaultWindowStyle do
begin
  MainColor     := Red;
  BoldColor     := Yellow;
  InactiveColor := DarkGray;
end;}

end.
