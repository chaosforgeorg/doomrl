{$INCLUDE doomrl.inc}
unit dfoutput;
interface
uses SysUtils, Classes,
     vluastate, vutil, dfdata, vmath, vrltools, vimage, vgltypes,
     vnode, vcolor, vluaconfig, vgenerics,
     viotypes, vuitypes, vtextmap, vrlmsg,
     doomspritemap, doomanimation, doomio;

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
    procedure addCellAnimation( aDuration : DWord; aDelay : DWord; aCoord : TCoord2D; aSprite : TSprite; aValue : Integer );
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
    function ChooseTarget( aActionName : string; aRange : byte; aLimitRange : Boolean; aTargets : TAutoTarget; aShowLast : Boolean = False ) : TCoord2D;

    procedure Focus( aCoord : TCoord2D );

    procedure Mark( aCoord : TCoord2D; aColor : Byte; aChar : Char; aDuration : DWord; aDelay : DWord = 0);

    procedure CreateMessageWriter( INI : TLuaConfig );
    destructor Destroy; override;
    class procedure RegisterLuaAPI( State : TLuaState );

    function GetLookDescription( aWhere : TCoord2D ) : AnsiString;

    procedure ASCIILoader( aStream : TStream; aName : Ansistring; aSize : DWord );

    procedure OnRedraw;
    procedure OnUpdate( aTime : DWord );
    procedure SetTextMap( aMap : ITextMap );

    procedure UpdateMinimap;
    procedure SetMinimapScale( aScale : Byte );

  private
    FStoredHint : AnsiString;
    FHint       : AnsiString;

    FTextMap    : TTextMap;
    FMessages   : TRLMessages;

    FASCII      : TASCIIImageMap;
    FHudEnabled : Boolean;

    // ASCII Only!
    FTargetLast     : Boolean;
    FTarget         : TCoord2D;
    FTargetRange    : Byte;
    FTargetEnabled  : Boolean;

    // GFX only animations
    FAnimations : TAnimationManager;
    FWaiting    : Boolean;

    FMinimapImage   : TImage;
    FMinimapTexture : DWord;
    FMinimapScale   : Integer;
    FMinimapGLPos   : TGLVec2i;

  private
    function Chunkify( const aString : AnsiString; aStart : Integer; aColor : TIOColor ) : TUIChunkBuffer;
    procedure LookDescription( aWhere : TCoord2D );
//    procedure SlideDown(DelayTime : word; var NewScreen : TGFXScreen);
  public
    property ASCII      : TASCIIImageMap read FASCII;
    property HudEnabled : Boolean        read FHudEnabled write FHudEnabled;
  end;

var UI : TDoomUI = nil;


implementation

uses math, dateutils,
     vdebug, vsystems, vluasystem, vvision, vconuirl, vuiconsole, vtig, vglimage,
     doombase, doomlua,
     dfplayer, dflevel, dfmap, dfitem;

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
  FillWord(Blood,25*80,Word(BloodPic));
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
  FWaiting := False;
  FTextMap := nil;
  FStoredHint := '';
  FHint       := '';
  FAnimations := nil;
  FMessages   := nil;
  if GraphicsVersion then FAnimations := TAnimationManager.Create;
  FASCII := TASCIIImageMap.Create( True );

  FTargetEnabled := False;
  FTargetLast    := False;

  FMinimapScale    := 0;
  FMinimapTexture  := 0;
  FMinimapGLPos    := TGLVec2i.Create( 0, 0 );
  FMinimapImage    := nil;

  if GraphicsVersion then
  begin
    FMinimapImage    := TImage.Create( 128, 32 );
    FMinimapImage.Fill( NewColor( 0,0,0,0 ) );
    SetMinimapScale( IO.MiniScale );
  end;
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
  FTextMap.AddAnimation( TTextBlinkAnimation.Create(IOGylph( iChr, Color ),Duration,aDelay));
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
    then FTextMap.AddAnimation( TTextRayAnimation.Create( Doom.Level, aSource, aTarget, IOGylph( aPic, aColor ), aDuration, aDelay, Player.Vision ) )
    else FTextMap.AddAnimation( TTextBulletAnimation.Create( Doom.Level, aSource, aTarget, IOGylph( aPic, aColor ), aDuration, aDelay, Player.Vision ) );
end;

procedure TDoomUI.addMarkAnimation(aDuration: DWord; aDelay: DWord;
  aCoord: TCoord2D; aColor: Byte; aPic: Char);
begin
  if Doom.State <> DSPlaying then Exit;
  if GraphicsVersion
    then FAnimations.addAnimation( TDoomMark.Create(aDuration, aDelay, aCoord ) )
    else FTextMap.AddAnimation( TTextMarkAnimation.Create( aCoord, IOGylph( aPic, aColor ), aDuration, aDelay ) );
end;

procedure TDoomUI.addSoundAnimation(aDelay: DWord; aPosition: TCoord2D;
  aSoundID: DWord);
begin
  if Doom.State <> DSPlaying then Exit;
  if GraphicsVersion
    then FAnimations.addAnimation( TDoomSoundEvent.Create( aDelay, aPosition, aSoundID ) )
    else FTextMap.AddAnimation( TDoomSoundEvent.Create( aDelay, aPosition, aSoundID ) )
end;

procedure TDoomUI.addScreenMoveAnimation(aDuration: DWord; aDelay: DWord; aTo: TCoord2D);
begin
  if Doom.State <> DSPlaying then Exit;
  if not GraphicsVersion then Exit;
  FAnimations.addAnimation( TDoomScreenMove.Create( aDuration, aDelay, aTo ) );
end;

procedure TDoomUI.addCellAnimation( aDuration : DWord; aDelay : DWord; aCoord : TCoord2D; aSprite : TSprite; aValue : Integer );
begin
  if Doom.State <> DSPlaying then Exit;
  if not GraphicsVersion then Exit;
  FAnimations.addAnimation( TDoomAnimateCell.Create( aDuration, aDelay, aCoord, aSprite, aValue ) );
end;

function TDoomUI.AnimationsRunning : Boolean;
begin
  if Doom.State <> DSPlaying then Exit(False);
  if GraphicsVersion
    then Exit( not FAnimations.Finished )
    else Exit( not FTextMap.AnimationsFinished );
end;

procedure TDoomUI.GFXAnimationDraw;
begin
  if not GraphicsVersion then Exit;
  FAnimations.Draw;
end;

procedure TDoomUI.WaitForAnimation;
begin
  if FWaiting then Exit;
  if Doom.State <> DSPlaying then Exit;
  FWaiting := True;
  while AnimationsRunning do
  begin
    IO.Delay(5);
  end;
  if GraphicsVersion
    then FAnimations.Clear
    else FTextMap.ClearAnimations;
  FWaiting := False;
  Doom.Level.RevealBeings;
end;

procedure TDoomUI.SetHint ( const aText : AnsiString ) ;
begin
  FStoredHint := aText;
  FHint       := aText;
end;

procedure TDoomUI.SetTempHint ( const aText : AnsiString ) ;
begin
  if aText = ''
    then FHint := FStoredHint
    else FHint := aText;
end;

procedure TDoomUI.Msg( const aText : AnsiString );
begin
  if FMessages <> nil then FMessages.Add(aText);
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
  Exit( FMessages.Content );
end;

procedure TDoomUI.MsgReset;
begin
  FMessages.Reset;
  FMessages.Update;
end;

procedure TDoomUI.MsgUpDate;
begin
  FMessages.Update;
  UI.SetTempHint('');
end;

procedure TDoomUI.ErrorReport(const aText: AnsiString);
begin
  MsgEnter('@RError:@> '+aText);
  Msg('@yError written to error.log, please report!@>');
end;

procedure TDoomUI.ClearAllMessages;
begin
  FMessages.Clear;
end;

procedure TDoomUI.Explosion(aSequence : Integer; aWhere: TCoord2D; aRange, aDelay: Integer;
  aColor: byte; aExplSound: Word; aFlags: TExplosionFlags);
var iExpl     : TTextExplosionArray;
    iCoord    : TCoord2D;
    iDistance : Byte;
    iVisible  : boolean;
    iLevel    : TLevel;
begin
  if not GraphicsVersion then
  begin
    FTextMap.FreezeMarks;
    iExpl := nil;
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
        else FTextMap.AddAnimation( TTextExplosionAnimation.Create( iCoord, '*', iExpl, iDistance*aDelay+aSequence ) );
    end;
  if aRange >= 10 then iVisible := True;

  if not GraphicsVersion then
     FTextMap.AddAnimation( TTextClearMarkAnimation.Create( aRange*aDelay+aSequence ) );

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
    Key := IO.WaitForCommand(INPUT_MOVE+[INPUT_GRIDTOGGLE,INPUT_ESCAPE,INPUT_MORE,INPUT_MMOVE,INPUT_MRIGHT, INPUT_MLEFT]);
    if (Key = INPUT_GRIDTOGGLE) and GraphicsVersion then SpriteMap.ToggleGrid;
    if Key in [ INPUT_MMOVE, INPUT_MRIGHT, INPUT_MLEFT ] then Target := IO.MTarget;
    if Key in [ INPUT_ESCAPE, INPUT_MRIGHT ] then Break;
    if Key <> INPUT_MORE then
    begin
      lc := Target;
      Dir := InputDirection( Key );
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
        FMessages.Pop;
        Msg('Out of range!');
        Continue;
      end;
      if Option_BlindMode then
      if lc = Target then
      begin
        TargetColor := NewColor( Red );
        FMessages.Pop;
        Msg('Out of range!');
      end;
     end;
     if (Key in [ INPUT_MORE, INPUT_MLEFT ]) and iLevel.isVisible( Target ) then
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
    Key := IO.WaitForCommand(INPUT_MOVE+[INPUT_GRIDTOGGLE,INPUT_ESCAPE,INPUT_MLEFT,INPUT_MRIGHT]);
    if (Key = INPUT_GRIDTOGGLE) and GraphicsVersion then SpriteMap.ToggleGrid;
    if Key in INPUT_MOVE then
    begin
      ChooseDirection := InputDirection(Key);
      iDone := True;
    end;
    if (Key = INPUT_MLEFT) then
    begin
      iTarget := IO.MTarget;
      if (Distance( iTarget, Position) = 1) then
      begin
        ChooseDirection.Create(Position, iTarget);
        iDone := True;
      end;
    end;
    if (Key in [INPUT_MRIGHT,INPUT_ESCAPE]) then
    begin
      ChooseDirection.Create(DIR_CENTER);
      iDone := True;
    end;
  until iDone;
end;

function TDoomUI.ChooseTarget(aActionName : string; aRange: byte;
  aLimitRange : Boolean; aTargets: TAutoTarget; aShowLast: Boolean): TCoord2D;
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
    FTargetLast := True;

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

    if GraphicsVersion and (SpriteMap <> nil) then
      SpriteMap.SetTarget( iTarget, NewColor( iTargetColor ), True )
    else
    begin
      FTargetEnabled := True;
      FTarget        := iTarget;
      FTargetRange   := iTargetRange;
      // TODO: this clashes with TIG
      IO.Console.ShowCursor;
      IO.Console.MoveCursor( iTarget.x+1, iTarget.y+2 );
    end;

    Key := IO.WaitForCommand(INPUT_MOVE+[INPUT_GRIDTOGGLE, INPUT_ESCAPE,INPUT_MORE,INPUT_FIRE,INPUT_ALTFIRE,INPUT_TACTIC, INPUT_MMOVE,INPUT_MRIGHT, INPUT_MLEFT]);
    if (Key = INPUT_GRIDTOGGLE) and GraphicsVersion then SpriteMap.ToggleGrid;
    if Key in [ INPUT_MMOVE, INPUT_MRIGHT, INPUT_MLEFT ] then
       begin
         iTarget := IO.MTarget;
         iDist := Distance(iTarget.x, iTarget.y, Position.x, Position.y);
         if aLimitRange and (iDist > aRange - 1) then
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
    if Key in [ INPUT_ESCAPE, INPUT_MRIGHT ] then begin iTarget.x := 0; Break; end;
    if Key = INPUT_TACTIC then iTarget := aTargets.Next;
    if (Key in INPUT_MOVE) then
    begin
      Dir := InputDirection( Key );
      if (iLevel.isProperCoord( iTarget + Dir ))
        and ((not aLimitRange) or (Distance((iTarget + Dir).x, (iTarget + Dir).y, Position.x, Position.y) <= aRange-1)) then
        iTarget += Dir;
    end;
    if (Key = INPUT_MORE) then
    begin
      with iLevel do
      if Being[ iTarget ] <> nil then
         Being[ iTarget ].FullLook;
    end;
    LookDescription( iTarget );
  until Key in [INPUT_FIRE, INPUT_ALTFIRE, INPUT_MLEFT];
  MsgUpDate;

  if GraphicsVersion and (SpriteMap <> nil) then
    SpriteMap.ClearTarget
  else
    FTargetEnabled := False;

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
    else FTextMap.AddAnimation( TTextMarkAnimation.Create( aCoord, IOGylph( aChar, aColor ), aDuration, aDelay ) );
end;

procedure TDoomUI.CreateMessageWriter(INI: TLuaConfig);
begin
  if FMessages <> nil then Exit;
  if not GraphicsVersion then
    FTextMap := TTextMap.Create( IO.Console, Rectangle( 2,3,MAXX,MAXY ) );
  FMessages := TRLMessages.Create(2, @IO.EventWaitForMore, @Chunkify, Option_MessageBuffer );

  FHudEnabled := False;
  if Option_MessageColoring then
    INI.EntryFeed( 'Messages', @FMessages.AddHighlightCallback );
end;

destructor TDoomUI.Destroy;
begin
  FreeAndNil( FTextMap );
  FreeAndNil( FMessages );
  FreeAndNil( FAnimations );
  FreeAndNil( FASCII );
  FreeAndNil( FMinimapImage );
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
  FMessages.Pop;
  Msg('You see : '+LookDesc );
end;

function TDoomUI.Chunkify( const aString : AnsiString; aStart : Integer; aColor : TIOColor ) : TUIChunkBuffer;
var iCon       : TUIConsole;
    iChunkList : TUIChunkList;
    iPosition  : TUIPoint;
    iColor     : TUIColor;
begin
  iCon.Init( IO.Console );
  iPosition  := Point(aStart,0);
  iColor     := aColor;
  iChunkList := nil;
  iCon.ChunkifyEx( iChunkList, iPosition, iColor, aString, iColor, Point(78,2) );
  Exit( iCon.LinifyChunkList( iChunkList ) );
end;

procedure TDoomUI.OnRedraw;
const UnitTex : TGLVec2f = ( Data : ( 1, 1 ) );
      ZeroTex : TGLVec2f = ( Data : ( 0, 0 ) );
var iCount      : DWord;
    i, iMax     : DWord;
    iCon        : TUIConsole;
    iColor      : TUIColor;
    iHPP        : Integer;
    iPos        : TIOPoint;
    iBottom     : Integer;
    iTargetLine : TVisionRay;
    iCurrent    : TCoord2D;
    iLevel      : TLevel;
    iAbsolute   : TIORect;
    iP1, iP2    : TIOPoint;

  procedure Paint ( aCoord : TCoord2D; aColor : TUIColor; aChar : Char = ' ') ;
  var iPos        : TUIPoint;
  begin
    iPos := Point( aCoord.x + 1, aCoord.y + 2 );
    if aChar = ' ' then aChar := IO.Console.GetChar( iPos.X, iPos.Y );
    if StatusEffect = StatusInvert
       then VTIG_FreeChar( aChar, iPos, Black, LightGray )
       else VTIG_FreeChar( aChar, iPos, aColor );
  end;

  function ArmorColor( aValue : Integer ) : TUIColor;
  begin
    case aValue of
     -100.. 25  : Exit(LightRed);
      26 .. 49  : Exit(Yellow);
      50 ..1000 : Exit(LightGray);
      else Exit(LightGray);
    end;
  end;
  function NameColor( aValue : Integer ) : TUIColor;
  begin
    case aValue of
     -100.. 25  : Exit(LightRed);
      26 .. 49  : Exit(Yellow);
      50 ..1000 : Exit(LightBlue);
      else Exit(LightGray);
    end;
  end;
  function WeaponColor( aWeapon : TItem ) : TUIColor;
  begin
    if aWeapon.IType = ITEMTYPE_MELEE then Exit(lightgray);
    if ( aWeapon.Ammo = 0 ) and not ( aWeapon.Flags[ IF_NOAMMO ] ) then Exit(LightRed);
    Exit(LightGray);
  end;
  function ExpString : AnsiString;
  begin
    if Player.ExpLevel >= MaxPlayerLevel - 1 then Exit('MAX');
    Exit(IntToStr(Clamp(Floor(((Player.Exp-ExpTable[Player.ExpLevel]) / (ExpTable[Player.ExpLevel+1]-ExpTable[Player.ExpLevel]))*100),0,99))+'%');
  end;

begin
  if FHudEnabled then
  begin
    iCon.Init( IO.Console );
    iCon.Clear;

    if Assigned( FTextMap ) then
      FTextMap.OnRedraw;

    if FHint <> '' then
      VTIG_FreeLabel( ' '+FHint+' ', Point( -1-Length( FHint ), 3 ), Yellow );

    if Player <> nil then
    begin
      iPos    := Point( 2,23 );
      iBottom := 25;
      iHPP    := Round((Player.HP/Player.HPMax)*100);

      VTIG_FreeLabel( 'Armor :',                            iPos + Point(28,0), DarkGray );
      VTIG_FreeLabel( Player.Name,                          iPos + Point(1,0),  NameColor(iHPP) );
      VTIG_FreeLabel( 'Health:      Exp:   /      Weapon:', iPos + Point(1,1),  DarkGray );
      VTIG_FreeLabel( IntToStr(iHPP)+'%',                   iPos + Point(9,1),  Red );
      VTIG_FreeLabel( TwoInt(Player.ExpLevel),              iPos + Point(19,1), LightGray );
      VTIG_FreeLabel( ExpString,                            iPos + Point(22,1), LightGray );

      if Player.Inv.Slot[efWeapon] = nil
        then VTIG_FreeLabel( 'none',                                iPos + Point(36,1), LightGray )
        else VTIG_FreeLabel( Player.Inv.Slot[efWeapon].Description, iPos + Point(36,1), WeaponColor(Player.Inv.Slot[efWeapon]) );

      if Player.Inv.Slot[efTorso] = nil
        then VTIG_FreeLabel( 'none',                                iPos + Point(36,0), LightGray )
        else VTIG_FreeLabel( Player.Inv.Slot[efTorso].Description,  iPos + Point(36,0), ArmorColor(Player.Inv.Slot[efTorso].Durability) );

      iColor := Red;
      if Doom.Level.Empty then iColor := Blue;
      VTIG_FreeLabel( Doom.Level.Name, iPos + Point(61,2), iColor );
      if Doom.Level.Name_Number >= 100 then VTIG_FreeLabel( 'Lev'+IntToStr(Doom.Level.Name_Number), iPos + Point(73,2), iColor )
      else if Doom.Level.Name_Number <> 0 then VTIG_FreeLabel( 'Lev'+IntToStr(Doom.Level.Name_Number), iPos + Point(74,2), iColor );

      with Player do
      for iCount := 1 to MAXAFFECT do
        if FAffects.IsActive(iCount) then
        begin
          if FAffects.IsExpiring(iCount)
            then iColor := Affects[iCount].Color_exp
            else iColor := Affects[iCount].Color;
          VTIG_FreeLabel( Affects[iCount].name, Point( iPos.X+((Byte(iCount)-1)*4)+14, iBottom ), iColor )
        end;

      with Player do
        if (FTactic.Current = TacticRunning) and (FTactic.Count < 6) then
          VTIG_FreeLabel( TacticName[FTactic.Current], Point(iPos.x+1, iBottom ), Brown )
        else
          VTIG_FreeLabel( TacticName[FTactic.Current], Point(iPos.x+1, iBottom ), TacticColor[FTactic.Current] );
    end;
    if FTargetEnabled then
    begin
      iLevel := Doom.Level;
      if FTargetLast then
        Paint( Player.TargetPos, Yellow );
      if ( Player.Position <> FTarget ) then
      begin
        iColor := Green;
        iTargetLine.Init( iLevel, Player.Position, FTarget );
        repeat
          iTargetLine.Next;
          iCurrent := iTargetLine.GetC;
          if not iLevel.isProperCoord( iCurrent ) then Break;
          if not iLevel.isVisible( iCurrent ) then iColor := Red;
          if iColor = Green then if iTargetLine.Cnt > FTargetRange then icolor := Yellow;
          if iTargetLine.Done then Paint( iCurrent, iColor, 'X' )
                              else Paint( iCurrent, iColor, '*' );
          if iLevel.cellFlagSet( iCurrent, CF_BLOCKMOVE ) then iColor := Red;
        until (iTargetLine.Done) or (iTargetLine.cnt > 30);
      end;
    end;

    if GraphicsVersion then
    begin
      if (FMinimapImage <> nil) and (FMinimapScale <> 0) then
        IO.QuadSheet.PushTexturedQuad( FMinimapGLPos, FMinimapGLPos + TGLVec2i.Create( FMinimapScale*128, FMinimapScale*32 ), ZeroTex, UnitTex, FMinimapTexture );

      iAbsolute := Rectangle( 1,1,78,25 );
      iP1 := IO.Root.ConsoleCoordToDeviceCoord( iAbsolute.Pos );
      iP2 := IO.Root.ConsoleCoordToDeviceCoord( Point( iAbsolute.x2+1, iAbsolute.y+2 ) );
      IO.QuadSheet.PushColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.1 ) );

      iP1 := IO.Root.ConsoleCoordToDeviceCoord( Point( iAbsolute.x, iAbsolute.y2-2 ) );
      iP2 := IO.Root.ConsoleCoordToDeviceCoord( Point( iAbsolute.x2+1, iAbsolute.y2+2 ) );
      IO.QuadSheet.PushColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.1 ) );
    end;

    iMax := Min( LongInt( FMessages.Scroll+FMessages.VisibleCount ), FMessages.Content.Size );
    if FMessages.Content.Size > 0 then
    for i := 1+FMessages.Scroll to iMax do
    begin
      iColor := DarkGray;
      if i > iMax - FMessages.Active then iColor := LightGray;
      iCon.Print( Point(1,i-FMessages.Scroll), FMessages.Content[ i-1 ], iColor, Black, Rectangle( 1,1, 78, 25 ) );
    end;

    {
    VTIG_Begin( 'messages', Point(78,2), Point( 1,1 ) );
    iMax := Min( LongInt( FMessages.Scroll+FMessages.VisibleCount ), FMessages.Content.Size );
    if FMessages.Content.Size > 0 then
    for i := 1+FMessages.Scroll to iMax do
    begin
      iColor := FForeColor;
      if i > iMax - FMessages.Active then iColor := iCon.BoldColor( FForeColor );
      for iChunk in FMessages.Content[ i-1 ] do
        VTIG_Text( iChunk.Content + ' ' );
  //      VTIG_FreeLabel( iChunk.Content, iChunk.Position + Point(1,i-FMessages.Scroll) , iColor );
    end;
    VTIG_End;
    }

  end;
end;

procedure TDoomUI.OnUpdate( aTime : DWord );
begin
  if FHudEnabled and Assigned( FTextMap ) then
    FTextMap.OnUpdate( aTime );
end;

procedure TDoomUI.SetTextMap( aMap : ITextMap );
begin
  Assert( Assigned( FTextMap ) );
  FTextMap.SetMap( aMap );
end;

procedure TDoomUI.UpdateMinimap;
var x, y : DWord;
begin
  if (Doom.State = DSPlaying) and GraphicsVersion and (FMinimapImage <> nil) then
  begin
    for x := 0 to MAXX+1 do
      for y := 0 to MAXY+1 do
        FMinimapImage.ColorXY[x,y] := Doom.Level.GetMiniMapColor( NewCoord2D( x, y ) );
    if FMinimapTexture = 0
      then FMinimapTexture := UploadImage( FMinimapImage, False )
      else ReUploadImage( FMinimapTexture, FMinimapImage, False );
  end;
end;

procedure TDoomUI.SetMinimapScale ( aScale : Byte ) ;
begin
  if GraphicsVersion and (FMinimapImage <> nil) then
  begin
    FMinimapScale := aScale;
    FMinimapGLPos.Init( IO.Driver.GetSizeX - FMinimapScale*(MAXX+2) - 10, IO.Driver.GetSizeY - FMinimapScale*(MAXY+2) - ( 10 + IO.FontMult*20*3 ) );
    UpdateMinimap;
  end;
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
