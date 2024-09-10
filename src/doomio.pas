{$INCLUDE doomrl.inc}
unit doomio;
interface
uses {$IFDEF WINDOWS}Windows,{$ENDIF} Classes, SysUtils,
     vio, vsystems, vrltools, vluaconfig, vglquadrenderer, vmessages,
     vuitypes, vluastate,  viotypes, vioevent, vioconsole, vuielement, vgenerics, vutil,
     dfdata, doomspritemap, doomaudio, doomkeybindings, doomloadingview;

const TIG_EV_NONE      = 0;
      TIG_EV_DROP      = 1;
      TIG_EV_INVENTORY = 2;
      TIG_EV_EQUIPMENT = 3;
      TIG_EV_CHARACTER = 4;
      TIG_EV_TRAITS    = 5;
      TIG_EV_QUICK_0   = 10;
      TIG_EV_QUICK_1   = 11;
      TIG_EV_QUICK_2   = 12;
      TIG_EV_QUICK_3   = 13;
      TIG_EV_QUICK_4   = 14;
      TIG_EV_QUICK_5   = 15;
      TIG_EV_QUICK_6   = 16;
      TIG_EV_QUICK_7   = 17;
      TIG_EV_QUICK_8   = 18;
      TIG_EV_QUICK_9   = 19;

type TCommandSet = set of Byte;
     TKeySet     = set of Byte;

type TDoomOnProgress      = procedure ( aProgress : DWord ) of object;
type TASCIIImageMap       = specialize TGObjectHashMap<TUIStringArray>;
type TInterfaceLayerStack = specialize TGArray<TInterfaceLayer>;

type TDoomIO = class( TIO )
  constructor Create; reintroduce;
  procedure Reconfigure( aConfig : TLuaConfig ); virtual;
  procedure Configure( aConfig : TLuaConfig; aReload : Boolean = False ); virtual;
  procedure WaitForLayer( aHideHUD : Boolean );
  procedure FullUpdate; override;
  destructor Destroy; override;
  procedure Screenshot( aBB : Boolean );

  procedure EventMore;

  procedure LoadStart( aAdd : DWord = 0 );
  function LoadCurrent : DWord;
  procedure LoadProgress( aProgress : DWord );
  procedure LoadStop;
  procedure Update( aMSec : DWord ); override;

  function EventToInput( const aEvent : TIOEvent ) : TInputKey;
  function CommandEventPending : Boolean;

  procedure SetHint( const aText : AnsiString );

  procedure Focus( aCoord: TCoord2D );

  procedure LookDescription( aWhere : TCoord2D );

  procedure Msg( const aText : AnsiString );
  procedure Msg( const aText : AnsiString; const aParams : array of const );
  function  MsgGetRecent : TMessageBuffer;
  procedure MsgReset;
  // TODO: Could this be removed as well?
  procedure MsgUpDate;
  procedure ErrorReport( const aText : AnsiString );

  procedure ClearAllMessages;
  procedure ASCIILoader( aStream : TStream; aName : Ansistring; aSize : DWord );

  procedure BloodSlideDown( aDelayTime : Word );

  procedure WaitForAnimation; virtual;
  function AnimationsRunning : Boolean; virtual; abstract;
  procedure Mark( aCoord : TCoord2D; aColor : Byte; aChar : Char; aDuration : DWord; aDelay : DWord = 0 ); virtual; abstract;
  procedure Blink( aColor : Byte; aDuration : Word = 100; aDelay : DWord = 0); virtual; abstract;
  procedure addScreenShakeAnimation( aDuration : DWord; aDelay : DWord; aStrength : Single ); virtual;
  procedure addMoveAnimation( aDuration : DWord; aDelay : DWord; aUID : TUID; aFrom, aTo : TCoord2D; aSprite : TSprite ); virtual;
  procedure addScreenMoveAnimation( aDuration : DWord; aTo : TCoord2D ); virtual;
  procedure addCellAnimation( aDuration : DWord; aDelay : DWord; aCoord : TCoord2D; aSprite : TSprite; aValue : Integer ); virtual;
  procedure addMissileAnimation( aDuration : DWord; aDelay : DWord; aSource, aTarget : TCoord2D; aColor : Byte; aPic : Char; aDrawDelay : Word; aSprite : TSprite; aRay : Boolean = False ); virtual; abstract;
  procedure addMarkAnimation( aDuration : DWord; aDelay : DWord; aCoord : TCoord2D; aColor : Byte; aPic : Char ); virtual; abstract;
  procedure addSoundAnimation( aDelay : DWord; aPosition : TCoord2D; aSoundID : DWord ); virtual; abstract;
  procedure Explosion( aSequence : Integer; aWhere : TCoord2D; aRange, aDelay : Integer; aColor : byte; aExplSound : Word; aFlags : TExplosionFlags = [] ); virtual;

  class procedure RegisterLuaAPI( State : TLuaState );

  function PushLayer( aLayer : TInterfaceLayer ) : TInterfaceLayer; virtual;
  function IsTopLayer( aLayer : TInterfaceLayer ) : Boolean;
  function IsModal : Boolean;
  procedure Tick( aDTick : Integer );
  procedure Clear;
  function OnEvent( const event : TIOEvent ) : Boolean; override;

  function DeviceCoordToConsoleCoord( aCoord : TIOPoint ) : TIOPoint; virtual;
  function ConsoleCoordToDeviceCoord( aCoord : TIOPoint ) : TIOPoint; virtual;
  procedure RenderUIBackground( aUL, aBR : TIOPoint; aOpacity : Single = 0.85 ); virtual;
  procedure FullLook( aID : Ansistring );
  procedure SetTarget( aTarget : TCoord2D; aColor : Byte; aRange : Byte ); virtual; abstract;
  procedure SetAutoTarget( aTarget : TCoord2D ); virtual; abstract;
protected
  procedure ExplosionMark( aCoord : TCoord2D; aColor : Byte; aDuration : DWord; aDelay : DWord ); virtual; abstract;
  procedure DrawHud; virtual;
  procedure ColorQuery(nkey,nvalue : Variant);
  function ScreenShotCallback( aEvent : TIOEvent ) : Boolean;
  function BBScreenShotCallback( aEvent : TIOEvent ) : Boolean;
  function Chunkify( const aString : AnsiString; aStart : Integer; aColor : TIOColor ) : TUIChunkBuffer;
protected
  FAudio       : TDoomAudio;
  FMessages    : TMessages;
  FTime        : QWord;
  FLoading     : TLoadingView;
  FMTarget     : TCoord2D;
  FKeyCode     : TIOKeyCode;
  FASCII       : TASCIIImageMap;
  FLayers      : TInterfaceLayerStack;
  FUIMouseLast : TIOPoint;
  FUIMouse     : TIOPoint;

  FHudEnabled  : Boolean;
  FWaiting     : Boolean;
  FTargeting   : Boolean;
  FHint        : AnsiString;
  FHintOverlay : AnsiString;

  // Textmode only
  FTargetLast     : Boolean;
  FTargetEnabled  : Boolean;

public
  property KeyCode     : TIOKeyCode     read FKeyCode    write FKeyCode;
  property Audio       : TDoomAudio     read FAudio;
  property MTarget     : TCoord2D       read FMTarget    write FMTarget;
  property ASCII       : TASCIIImageMap read FASCII;
  property HintOverlay : AnsiString     read FHintOverlay write FHintOverlay;
  property Targeting   : Boolean        read FTargeting   write FTargeting;
  property Time        : QWord          read FTime;

  // Textmode only
  property TargetEnabled : Boolean        read FTargetEnabled write FTargetEnabled;
  property TargetLast    : Boolean        read FTargetLast    write FTargetLast;
end;

var IO : TDoomIO;

procedure EmitCrashInfo( const aInfo : AnsiString; aInGame : Boolean  );

implementation

uses math, video, dateutils, variants,
     vsound, vluasystem, vlog, vdebug, vuiconsole, vmath, vtigstyle,
     vsdlio, vglconsole, vtig, vtigio,
     dflevel, dfplayer, dfitem,
     doomconfiguration, doombase, doommoreview, doomchoiceview, doomlua,
     doomhudviews, doomplotview;

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


procedure TDoomIO.BloodSlideDown( aDelayTime : Word );
{
const BloodPic : TPictureRec = (Picture : ' '; Color : 16*Red);
var Temp  : TGFXScreen;
    Blood : TGFXScreen;
    vx,vy : byte;
}
begin
  if GraphicsVersion then
    if Player <> nil then
      SpriteMap.NewShift := SpriteMap.ShiftValue( Player.Position );

{
  for vx := 1 to 80 do for vy := 1 to 25 do Temp [vy,vx] := VideoBuf^[(vx-1)+(vy-1)*ScreenSizeX];
  OutputRestore;
  FillWord(Blood,25*80,Word(BloodPic));
  SlideDown(DelayTime,Blood);
  SlideDown(DelayTime,Temp);
}
end;

procedure TDoomIO.WaitForAnimation;
begin
  if FWaiting then Exit;
  if Doom.State <> DSPlaying then Exit;
  FWaiting := True;
  while AnimationsRunning do
  begin
    IO.Delay(5);
  end;
  FWaiting := False;
  Doom.Level.RevealBeings;
end;

procedure TDoomIO.addScreenShakeAnimation( aDuration : DWord; aDelay : DWord; aStrength : Single );
begin

end;

procedure TDoomIO.addMoveAnimation( aDuration : DWord; aDelay : DWord; aUID : TUID; aFrom, aTo : TCoord2D; aSprite : TSprite );
begin

end;

procedure TDoomIO.addScreenMoveAnimation( aDuration : DWord; aTo : TCoord2D );
begin

end;

procedure TDoomIO.addCellAnimation( aDuration : DWord; aDelay : DWord; aCoord : TCoord2D; aSprite : TSprite; aValue : Integer );
begin

end;

procedure TDoomIO.Explosion( aSequence : Integer; aWhere: TCoord2D; aRange, aDelay: Integer;
  aColor: byte; aExplSound: Word; aFlags: TExplosionFlags);
var iCoord    : TCoord2D;
    iDistance : Byte;
    iVisible  : boolean;
    iLevel    : TLevel;
begin
  iLevel := Doom.Level;
  if not iLevel.isProperCoord( aWhere ) then Exit;

  if aRange > 0 then
    addScreenShakeAnimation( Clamp( 100 * aRange, 300, 500 ), aSequence, Clampf( 2.0 * aRange, 2.0, 5.0 ) );

  if aExplSound <> 0 then
    addSoundAnimation( aSequence, aWhere, aExplSound );

  for iCoord in NewArea( aWhere, aRange ).Clamped( iLevel.Area ) do
    begin
      if aRange < 10 then if iLevel.isVisible(iCoord) then iVisible := True else Continue;
      if aRange < 10 then if not iLevel.isEyeContact( iCoord, aWhere ) then Continue;
      iDistance := Distance(iCoord, aWhere);
      if iDistance > aRange then Continue;
      ExplosionMark( iCoord, aColor, 3*aDelay, aSequence+iDistance*aDelay );
    end;
  if aRange >= 10 then iVisible := True;

  // TODO : events
  if efAfterBlink in aFlags then
  begin
    Blink(LightGreen,50,aSequence+aDelay*aRange);
    Blink(White,50,aSequence+aDelay*aRange+60);
  end;

  if not iVisible then if aRange > 3 then
    IO.Msg( 'You hear an explosion!' );
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

{ TDoomIO }

constructor TDoomIO.Create;
var iStyle      : TUIStyle;
begin
  FLoading := nil;
  IO := Self;
  FTime := 0;
  FAudio    := TDoomAudio.Create;
  FMessages := TMessages.Create( 2, 77, @IO.EventMore, Option_MessageBuffer );
  FASCII    := TASCIIImageMap.Create( True );
  FLayers   := TInterfaceLayerStack.Create;

  FWaiting    := False;
  FHudEnabled := False;
  FTargeting  := False;
  FHint       := '';

  FIODriver.SetTitle('DRL','DRL');

  iStyle := TUIStyle.Create('default');
  iStyle.Add('','fore_color', LightGray );
  iStyle.Add('','selected_color', Yellow );
  iStyle.Add('','inactive_color', DarkGray );
  iStyle.Add('','selinactive_color', Yellow );

  iStyle.Add('menu','fore_color', Red );
  iStyle.Add('plot_viewer','fore_color', Red );
  iStyle.Add('','back_color', Black );
  iStyle.Add('','scroll_chars', '^v' );
  iStyle.Add('','icon_color', White );
  iStyle.Add('','opaque', False );
  iStyle.Add('','frame_color', DarkGray );
  if (not Option_HighASCII) and ( not GraphicsVersion )
     then iStyle.Add('','frame_chars', '-|-|/\\/-|^v' )
     else iStyle.Add('','frame_chars', #196+#179+#196+#179+#218+#191+#192+#217+#196+#179+'^v' );
  iStyle.Add('window','fore_color', Red );
  iStyle.Add('','frame_color', Red );
  iStyle.Add('full_window','fore_color', LightRed );
  iStyle.Add('full_window','frame_color', Red );
  iStyle.Add('full_window','fore_color', LightRed );
  iStyle.Add('full_window','title_color', LightRed );
  iStyle.Add('full_window','footer_color', LightRed );
  iStyle.Add('input','fore_color', LightBlue );
  iStyle.Add('input','back_color', Blue );
  iStyle.Add('text','fore_color', LightGray );
  iStyle.Add('text','back_color', ColorNone );

  VTIG_Initialize( FConsole, FIODriver, False );

  VTIGDefaultStyle.Frame[ VTIG_BORDER_FRAME ] := #196+#196+'  '+#196+#196+#196+#196;
//  VTIGDefaultStyle.Frame[ VTIG_BORDER_FRAME ] := '--  ----';
  VTIGDefaultStyle.Color[ VTIG_TITLE_COLOR ]  := YELLOW;
  VTIGDefaultStyle.Color[ VTIG_FRAME_COLOR ]  := RED;
  VTIGDefaultStyle.Color[ VTIG_FOOTER_COLOR ] := LIGHTRED;
  VTIGDefaultStyle.Color[ VTIG_SELECTED_TEXT_COLOR ] := YELLOW;
  VTIGDefaultStyle.Color[ VTIG_SCROLL_COLOR ] := YELLOW;
  if GraphicsVersion then
  begin
    VTIGDefaultStyle.Color[ VTIG_BACKGROUND_COLOR ]          := $10000000;
    VTIGDefaultStyle.Color[ VTIG_SELECTED_BACKGROUND_COLOR ] := $442222FF;
    VTIGDefaultStyle.Color[ VTIG_INPUT_TEXT_COLOR ]          := LightGray;
    VTIGDefaultStyle.Color[ VTIG_INPUT_BACKGROUND_COLOR ]    := $442222FF;
  end
  else
  begin
    VTIGDefaultStyle.Color[ VTIG_SELECTED_BACKGROUND_COLOR ] := DarkGray;
    VTIGDefaultStyle.Color[ VTIG_SELECTED_DISABLED_COLOR ]   := Black;
  end;

  TIGStyleColored   := VTIGDefaultStyle;
  TIGStyleColored.Color[ VTIG_TEXT_COLOR ] := VTIGDefaultStyle.Color[ VTIG_FOOTER_COLOR ];
  TIGStyleColored.Color[ VTIG_BOLD_COLOR ] := VTIGDefaultStyle.Color[ VTIG_TITLE_COLOR ];

  TIGStyleFrameless := VTIGDefaultStyle;
  TIGStyleFrameless.Frame[ VTIG_BORDER_FRAME ] := '';

  inherited Create( FIODriver, FConsole, iStyle );
  LoadStart;
  FUIMouseLast := Point(-1,-1);
  FUIMouse     := Point(-1,-1);

  IO := Self;
  FConsole.Clear;
  FConsole.HideCursor;
  FConsoleWindow := nil;
  FUIRoot.UpdateOnRender := False;
  FullUpdate;

  FTargetEnabled := False;
  FTargetLast    := False;
end;

function TDoomIO.PushLayer( aLayer : TInterfaceLayer ) : TInterfaceLayer;
begin
  FHintOverlay := '';
  FConsole.HideCursor;
  FLayers.Push( aLayer );
  Result := aLayer;
end;

function TDoomIO.IsTopLayer( aLayer : TInterfaceLayer ) : Boolean;
begin
  Exit( ( FLayers.Size > 0 ) and ( FLayers.Top = aLayer ) );
end;

function TDoomIO.IsModal : Boolean;
var iLayer : TInterfaceLayer;
begin
  for iLayer in FLayers do
    if iLayer.IsModal then Exit( True );
  Exit( False );
end;

procedure TDoomIO.Tick( aDTick : Integer );
var iLayer : TInterfaceLayer;
begin
  for iLayer in FLayers do
    iLayer.Tick( aDTick );
end;

procedure TDoomIO.Clear;
var iLayer : TInterfaceLayer;
begin
  for iLayer in FLayers do
    iLayer.Free;
  FLayers.Clear;
end;

function TDoomIO.OnEvent( const event : TIOEvent ) : Boolean;
var i      : Integer;
    iEvent : TIOEvent;
    iWide  : WideString;
    iInput : TInputKey;
begin
  if ( event.EType = VEVENT_TEXT ) then
  begin
    iWide := UTF8Decode( UTF8String( event.Text.Text ) );
    VTIG_GetIOState.EventState.AppendText( PWideChar( iWide ) );
  end;

  if ( event.EType = VEVENT_KEYDOWN ) then
    case event.Key.Code of
      VKEY_UP     : VTIG_GetIOState.EventState.SetState( VTIG_IE_UP, True );
      VKEY_DOWN   : VTIG_GetIOState.EventState.SetState( VTIG_IE_DOWN, True );
      VKEY_LEFT   : VTIG_GetIOState.EventState.SetState( VTIG_IE_LEFT, True );
      VKEY_RIGHT  : VTIG_GetIOState.EventState.SetState( VTIG_IE_RIGHT, True );
      VKEY_HOME   : VTIG_GetIOState.EventState.SetState( VTIG_IE_HOME, True );
      VKEY_END    : VTIG_GetIOState.EventState.SetState( VTIG_IE_END, True );
      VKEY_PGUP   : VTIG_GetIOState.EventState.SetState( VTIG_IE_PGUP, True );
      VKEY_PGDOWN : VTIG_GetIOState.EventState.SetState( VTIG_IE_PGDOWN, True );
      VKEY_ESCAPE : VTIG_GetIOState.EventState.SetState( VTIG_IE_CANCEL, True );
      VKEY_ENTER  : VTIG_GetIOState.EventState.SetState( VTIG_IE_CONFIRM, True );
      VKEY_SPACE  : VTIG_GetIOState.EventState.SetState( VTIG_IE_SELECT, True );
      VKEY_BACK   : VTIG_GetIOState.EventState.SetState( VTIG_IE_BACKSPACE, True );
      VKEY_TAB    : VTIG_GetIOState.EventState.SetState( VTIG_IE_TAB, True );
      VKEY_0      : VTIG_GetIOState.EventState.SetState( VTIG_IE_0, True );
      VKEY_1      : VTIG_GetIOState.EventState.SetState( VTIG_IE_1, True );
      VKEY_2      : VTIG_GetIOState.EventState.SetState( VTIG_IE_2, True );
      VKEY_3      : VTIG_GetIOState.EventState.SetState( VTIG_IE_3, True );
      VKEY_4      : VTIG_GetIOState.EventState.SetState( VTIG_IE_4, True );
      VKEY_5      : VTIG_GetIOState.EventState.SetState( VTIG_IE_5, True );
      VKEY_6      : VTIG_GetIOState.EventState.SetState( VTIG_IE_6, True );
      VKEY_7      : VTIG_GetIOState.EventState.SetState( VTIG_IE_7, True );
      VKEY_8      : VTIG_GetIOState.EventState.SetState( VTIG_IE_8, True );
      VKEY_9      : VTIG_GetIOState.EventState.SetState( VTIG_IE_9, True );
    end;

  if ( event.EType in [ VEVENT_MOUSEDOWN, VEVENT_MOUSEUP ] ) then
  begin
    iEvent := event;
    iEvent.Mouse.Pos := DeviceCoordToConsoleCoord( event.Mouse.Pos );
    VTIG_GetIOState.MouseState.HandleEvent( iEvent );
    if ( event.EType = VEVENT_MOUSEDOWN ) and ( event.Mouse.Button = VMB_BUTTON_LEFT ) then
      VTIG_GetIOState.EventState.SetState( VTIG_IE_MCONFIRM, True );
  end;

  if ( event.EType in [ VEVENT_MOUSEMOVE ] ) then
    FUIMouse := DeviceCoordToConsoleCoord( event.MouseMove.Pos );

  iInput := EventToInput( event );
  if iInput <> INPUT_NONE then
    if not FLayers.IsEmpty then
      for i := FLayers.Size - 1 downto 0 do
        if not FLayers[i].isFinished then
          if FLayers[i].HandleInput( iInput ) then
            Exit( True );

  if not FLayers.IsEmpty then
    for i := FLayers.Size - 1 downto 0 do
      if not FLayers[i].isFinished then
        if FLayers[i].HandleEvent( event ) then
          Exit( True );

  Exit( False );
end;

function TDoomIO.DeviceCoordToConsoleCoord( aCoord : TIOPoint ) : TIOPoint;
begin
  Exit( aCoord );
end;

function TDoomIO.ConsoleCoordToDeviceCoord( aCoord : TIOPoint ) : TIOPoint;
begin
  Exit( aCoord );
end;

procedure TDoomIO.RenderUIBackground( aUL, aBR : TIOPoint; aOpacity : Single = 0.85 );
begin
  // noop
end;

procedure TDoomIO.FullLook( aID : Ansistring );
begin
  FConsole.HideCursor;
  PushLayer( TMoreView.Create( aID ) );
end;

procedure TDoomIO.Reconfigure( aConfig : TLuaConfig );
var iInput : TInputKey;
begin
  FAudio.Reconfigure;
  aConfig.ResetCommands;
  if aConfig.TableExists('Keytable') then
    aConfig.LoadKeybindings('Keytable');

  for iInput in TInputKey do
    if KeyInfo[iInput].ID <> '' then
      aConfig.Commands[ Configuration.GetInteger(KeyInfo[iInput].ID) ] := Word(iInput);
end;

procedure TDoomIO.Configure ( aConfig : TLuaConfig; aReload : Boolean ) ;
begin
  // TODO : configurable

  if GodMode then
    RegisterDebugConsole( VKEY_F1 );
  FIODriver.RegisterInterrupt( VKEY_F9, @ScreenShotCallback );
  FIODriver.RegisterInterrupt( VKEY_F10, @BBScreenShotCallback );

  if Option_MessageBuffer < 20 then Option_MessageBuffer := 20;
  FAudio.Configure( aConfig, aReload );

  if aReload then
    aConfig.EntryFeed('Colors', @ColorQuery );
  if Option_MessageColoring then
    aConfig.EntryFeed( 'Messages', @FMessages.AddHighlightCallback );
end;

procedure TDoomIO.WaitForLayer( aHideHUD : Boolean );
begin
  if aHideHUD then
    FHudEnabled := False;
  repeat
    Sleep(10);
    FullUpdate;
    HandleEvents;
  until FLayers.IsEmpty;
  if aHideHUD then
    FHudEnabled := True;
end;

procedure TDoomIO.FullUpdate;
begin
  VTIG_NewFrame;
  if FHudEnabled then
    DrawHud;
  inherited FullUpdate;
end;

destructor TDoomIO.Destroy;
var iLayer : TInterfaceLayer;
begin
  FreeAndNil( FAudio );
  FreeAndNil( FMessages );
  FreeAndNil( FASCII );

  if FLayers <> nil then
    for iLayer in FLayers do
      iLayer.Free;
  FreeAndNil( FLayers );
  IO := nil;
  inherited Destroy;
end;

procedure TDoomIO.Screenshot ( aBB : Boolean );
var iFName : AnsiString;
    iName  : AnsiString;
    iExt   : AnsiString;
    iCount : DWord;
    iCon   : TUIConsole;
begin
  if GraphicsVersion
     then iExt := '.png'
     else iExt := '.txt';

  iName := 'DRL';
  if Player <> nil then iName := Player.Name;
  iFName := 'screenshot'+PathDelim+ToProperFilename('['+FormatDateTime(Option_TimeStamp,Now)+'] '+iName)+iExt;
  iCount := 1;
  while FileExists(iFName) do
  begin
    iFName := 'screenshot'+PathDelim+ToProperFilename('['+FormatDateTime(Option_TimeStamp,Now)+'] '+iName)+'-'+IntToStr(iCount)+iExt;
    Inc(iCount);
  end;

  Log('Writing screenshot...: '+iFName);
  if not GraphicsVersion then
  begin
    iCon.Init( FConsole );
    if aBB then iCon.ScreenShot(iFName,1)
           else iCon.ScreenShot(iFName);
  end
  else
  begin
    TSDLIODriver(FIODriver).ScreenShot(iFName);
  end;
    {  if aBB then UI.Msg('BB Screenshot created.')
             else UI.Msg('Screenshot created.');}
end;

procedure TDoomIO.DrawHud;
var iCon        : TUIConsole;
    i, iMax     : DWord;
    iColor      : TUIColor;
    iHPP        : Integer;
    iPos        : TIOPoint;
    iBottom     : Integer;
    iLevelName  : string[64];
    iCNormal    : DWord;
    iCBold      : DWord;

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
  iCNormal := DarkGray;
  iCBold   := LightGray;

  iCon.Init( FConsole );
  if GraphicsVersion then
    iCon.Clear;

  if Player <> nil then
  begin
    iPos    := Point( 2,FConsole.SizeY-3 );
    iBottom := FConsole.SizeY-1;
    if GraphicsVersion then
    begin
      iPos    := Point( 2,FConsole.SizeY-2 );
      iBottom := FConsole.SizeY-3;
    end;
    iHPP    := Round((Player.HP/Player.HPMax)*100);

    VTIG_FreeLabel( 'Armor :',                            iPos + Point(28,0), iCNormal );
    VTIG_FreeLabel( Player.Name,                          iPos + Point(1,0),  NameColor(iHPP) );
    VTIG_FreeLabel( 'Health:      Exp:   /      Weapon:', iPos + Point(1,1),  iCNormal );
    VTIG_FreeLabel( IntToStr(iHPP)+'%',                   iPos + Point(9,1),  Red );
    VTIG_FreeLabel( TwoInt(Player.ExpLevel),              iPos + Point(19,1), iCBold );
    VTIG_FreeLabel( ExpString,                            iPos + Point(22,1), iCBold );

    if Player.Inv.Slot[efWeapon] = nil
      then VTIG_FreeLabel( 'none',                                iPos + Point(36,1), iCBold )
      else VTIG_FreeLabel( Player.Inv.Slot[efWeapon].Description, iPos + Point(36,1), WeaponColor(Player.Inv.Slot[efWeapon]) );

    if Player.Inv.Slot[efTorso] = nil
      then VTIG_FreeLabel( 'none',                                iPos + Point(36,0), iCBold )
      else VTIG_FreeLabel( Player.Inv.Slot[efTorso].Description,  iPos + Point(36,0), ArmorColor(Player.Inv.Slot[efTorso].Durability) );

    iColor := Red;
    if Doom.Level.Empty then iColor := Blue;
    iLevelName := Doom.Level.Name;
    if Doom.Level.Name_Number > 0 then
      iLevelName += ' Lev '+IntToStr( Doom.Level.Name_Number );
    VTIG_FreeLabel( iLevelName, Point( -2-Length( iLevelName), iBottom ), iColor );

    with Player do
    for i := 1 to MAXAFFECT do
      if FAffects.IsActive(i) then
      begin
        if FAffects.IsExpiring(i)
          then iColor := Affects[i].Color_exp
          else iColor := Affects[i].Color;
        VTIG_FreeLabel( Affects[i].name, Point( iPos.X+((Byte(i)-1)*4)+14, iBottom ), iColor )
      end;

    with Player do
      if (FTactic.Current = TacticRunning) and (FTactic.Count < 6) then
        VTIG_FreeLabel( TacticName[FTactic.Current], Point(iPos.x+1, iBottom ), Brown )
      else
        VTIG_FreeLabel( TacticName[FTactic.Current], Point(iPos.x+1, iBottom ), TacticColor[FTactic.Current] );
  end;


  if FHintOverlay <> ''
    then VTIG_FreeLabel( ' '+FHintOverlay+' ', Point( -1-Length( FHintOverlay ), 2 ), Yellow )
    else if FHint <> ''
      then VTIG_FreeLabel( ' '+FHint+' ', Point( -1-Length( FHint ), 2 ), Yellow );


  for i := 1 to 2 do
  begin
    if i > FMessages.Size then Continue;
    VTIG_HighColor := i <= FMessages.Active;
    VTIG_FreeLabel( FMessages.Content[ -i ], Point(1,2-i), iCNormal );
    VTIG_HighColor := False;
  end;
end;

procedure TDoomIO.SetHint ( const aText : AnsiString ) ;
begin
  FHint       := aText;
end;

procedure TDoomIO.ColorQuery(nkey,nvalue : Variant);
begin
    ColorOverrides[nkey] := nvalue;
end;

function TDoomIO.ScreenShotCallback ( aEvent : TIOEvent ) : Boolean;
begin
  ScreenShot( False );
  Exit(True);
end;

function TDoomIO.BBScreenShotCallback ( aEvent : TIOEvent ) : Boolean;
begin
  ScreenShot( True );
  Exit(True);
end;

function TDoomIO.Chunkify( const aString : AnsiString; aStart : Integer; aColor : TIOColor ) : TUIChunkBuffer;
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

procedure TDoomIO.ASCIILoader ( aStream : TStream; aName : Ansistring; aSize : DWord ) ;
var iNewImage   : TUIStringArray;
    iCounter    : DWord;
    iAmount     : DWord;
    iIdent      : Ansistring;
begin
  iIdent  := LowerCase(LeftStr(aName,Length(aName)-4));
  Log('Registering ascii file '+aName+' as '+iIdent+'...');
  iAmount := aStream.ReadDWord;
  iNewImage  := TUIStringArray.Create;
  for iCounter := 1 to Min(iAmount,25) do
    iNewImage.Push( aStream.ReadAnsiString );
  FASCII.Items[iIdent] := iNewImage;
end;

procedure TDoomIO.EventMore;
begin
  if Option_MorePrompt then
  begin
    IO.PushLayer( TMoreLayer.Create( True ) );
    IO.WaitForLayer( False );
  end;
end;

procedure TDoomIO.LoadStart( aAdd : DWord = 0 );
begin
  if FLoading = nil then
    FLoading := PushLayer( TLoadingView.Create( 100 ) ) as TLoadingView;
  FLoading.Max := FLoading.Max + aAdd;
end;

function TDoomIO.LoadCurrent : DWord;
begin
  if Assigned( FLoading ) then Exit( FLoading.Current );
  Exit( 0 );
end;

procedure TDoomIO.LoadProgress ( aProgress : DWord ) ;
begin
  if Assigned( FLoading ) then FLoading.Current := aProgress;
  FullUpdate;
end;

procedure TDoomIO.LoadStop;
begin
  if Assigned( FLoading ) then
  begin
    FLoading.Finished := True;
    FLoading := nil;
  end;
end;

procedure TDoomIO.Update( aMSec : DWord );
var iLayer  : TInterfaceLayer;
    iMEvent : TIOEvent;

  procedure ClearFinished;
  var i,j : Integer;
  begin
    i := 0;
    while i < FLayers.Size do
      if FLayers[i].IsFinished then
      begin
        FLayers[i].Free;
        if i < FLayers.Size - 1 then
          for j := i to FLayers.Size - 2 do
            FLayers[j] := FLayers[j + 1];
        FLayers.Pop;
      end
      else
        Inc( i );
  end;

begin
  if Assigned( Sound ) then
    Sound.Update;

  if FUIMouse <> FUIMouseLast then
  begin
    iMEvent.EType:= VEVENT_MOUSEMOVE;
    iMEvent.MouseMove.Pos := FUIMouse;
    FUIMouseLast := FUIMouse;
    VTIG_GetIOState.MouseState.HandleEvent( iMEvent );
  end;

  ClearFinished;
  for iLayer in FLayers do
    iLayer.Update( Integer( aMSec ) );
  ClearFinished;

  FTime += aMSec;
  FAudio.Update( aMSec );
  FUIRoot.OnUpdate( aMSec );
  FUIRoot.Render;

  VTIG_EndFrame;
  VTIG_Render;
  VTIG_EventClear;
end;

function TDoomIO.EventToInput( const aEvent : TIOEvent ) : TInputKey;
var iPoint : TPoint;
begin
  if (aEvent.EType = VEVENT_SYSTEM) then
    if Option_LockClose
       then Exit( INPUT_QUIT )
       else Exit( INPUT_HARDQUIT );
  if (aEvent.EType = VEVENT_MOUSEMOVE) then
  begin
    iPoint := SpriteMap.DevicePointToCoord( aEvent.MouseMove.Pos );
    FMTarget.Create( iPoint.X, iPoint.Y );
    if Doom.Level.isProperCoord( FMTarget ) then
      Exit( INPUT_MMOVE );
  end;
  if aEvent.EType = VEVENT_MOUSEDOWN then
  begin
    iPoint := SpriteMap.DevicePointToCoord( aEvent.Mouse.Pos );
    FMTarget.Create( iPoint.X, iPoint.Y );
    if Doom.Level.isProperCoord( FMTarget ) then
    begin
      case aEvent.Mouse.Button of
        VMB_BUTTON_LEFT     : Exit( INPUT_MLEFT );
        VMB_BUTTON_MIDDLE   : Exit( INPUT_MMIDDLE );
        VMB_BUTTON_RIGHT    : Exit( INPUT_MRIGHT );
        VMB_WHEEL_UP        : Exit( INPUT_MSCRUP );
        VMB_WHEEL_DOWN      : Exit( INPUT_MSCRDOWN );
      end;
    end;
  end;
  if aEvent.EType = VEVENT_KEYDOWN then
  begin
    FKeyCode := IOKeyEventToIOKeyCode( aEvent.Key );
    if (FKeyCode mod 256) <> 0
      then Exit( TInputKey( Config.Commands[ FKeyCode ] ) );
  end;
  Exit( INPUT_NONE );
end;

function TDoomIO.CommandEventPending : Boolean;
var iEvent : TIOEvent;
begin
  repeat
    if not FIODriver.PeekEvent( iEvent ) then Exit( False );
    if iEvent.EType in [ VEVENT_MOUSEMOVE, VEVENT_MOUSEUP ] then
    begin
      FIODriver.PollEvent( iEvent );
      Continue;
    end;
  until True;
  Exit( iEvent.EType in [ VEVENT_KEYDOWN, VEVENT_MOUSEDOWN ] );
end;

procedure TDoomIO.Focus(aCoord: TCoord2D);
begin
  FConsole.MoveCursor(aCoord.x+1,aCoord.y+2);
end;

procedure TDoomIO.LookDescription(aWhere: TCoord2D);
var LookDesc : string;
begin
  LookDesc := Doom.Level.GetLookDescription( aWhere );
  if Option_BlindMode then LookDesc += ' | '+BlindCoord( aWhere - Player.Position );
  if Doom.Level.isVisible(aWhere) and (Doom.Level.Being[aWhere] <> nil) then LookDesc += ' | [{Lm}]ore';
  FHintOverlay := LookDesc;
end;

procedure TDoomIO.Msg( const aText : AnsiString );
begin
  if FMessages <> nil then FMessages.Add(aText);
end;

procedure TDoomIO.Msg( const aText : AnsiString; const aParams : array of const );
begin
  Msg( Format( aText, aParams ) );
end;

function TDoomIO.MsgGetRecent : TMessageBuffer;
begin
  Exit( FMessages.Content );
end;

procedure TDoomIO.MsgReset;
begin
  FMessages.Reset;
  FMessages.Update;
end;

procedure TDoomIO.MsgUpDate;
begin
  FMessages.Update;
  FHintOverlay := '';
end;

procedure TDoomIO.ErrorReport(const aText: AnsiString);
begin
  Msg('@RError:@> '+aText);
  PushLayer( TMoreLayer.Create( False ) );
  WaitForLayer( False );
  Msg('@yError written to error.log, please report!@>');
end;

procedure TDoomIO.ClearAllMessages;
begin
  FMessages.Clear;
end;

(**************************** LUA UI *****************************)

function lua_ui_set_hint(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  if not Setting_HideHints then
    IO.SetHint( State.ToString( 1 ) );
  Result := 0;
end;

{$HINTS OFF} // To supress Hint: Parameter "x" not found

function lua_ui_blood_slide(L: Plua_State): Integer; cdecl;
begin
  IO.BloodSlideDown(20);
  Result := 0;
end;

{$HINTS ON}

function lua_ui_blink(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  IO.Blink(State.ToInteger(1),State.ToInteger(2));
  Result := 0;
end;

function lua_ui_plot_screen(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  IO.PushLayer( TPlotView.Create( State.ToString(1), State.ToInteger(2) ) );
  IO.WaitForLayer( True );
  Result := 0;
end;

function lua_ui_msg(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  IO.Msg(State.ToString(1));
  Result := 0;
end;

function lua_ui_msg_clear(L: Plua_State): Integer; cdecl;
begin
  IO.MsgReset();
  Result := 0;
end;

function lua_ui_msg_enter(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  if State.StackSize = 0 then Exit(0);
  IO.Msg(State.ToString(1));
  IO.PushLayer( TMoreLayer.Create( False ) );
  IO.WaitForLayer( False );
  IO.MsgUpDate;
  Result := 0;
end;

function lua_ui_msg_history(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    Idx   : Integer;
    Msg   : AnsiString;
begin
  State.Init(L);
  if State.StackSize = 0 then Exit(0);
  Idx := State.ToInteger(1)+1;
  if Idx > IO.MsgGetRecent.Size then
    State.PushNil
  else
  begin
    Msg := IO.MsgGetRecent[-Idx];
    if Msg <> '' then
      State.Push( Msg )
    else
      State.PushNil;
  end;
  Result := 1;
end;

function lua_ui_strip_encoding(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  if State.StackSize = 0 then Exit(0);
  State.Push( VTIG_StripTags( State.ToString(1) ) );
  Result := 1;
end;

function lua_ui_choice(L: Plua_State): Integer; cdecl;
var State     : TDoomLuaState;
    iView     : TChoiceView;
    i, iCount : Integer;
    iEntry    : TChoiceViewChoice;
begin
  State.Init(L);
  if State.StackSize < 1 then Exit(0);
  if not State.IsTable( 1 ) then State.Error('Table expected as parameter 1!');

  with TLuaTable.Create( L, 1 ) do
    try
      iView := TChoiceView.Create;
      if IsString('title')      then iView.Title  := GetString( 'title' );
      if IsString('header')     then iView.Header := GetString( 'header' );
      if not IsNil('cancel')    then iView.Cancel := GetValue( 'cancel' );
      if not IsNil('escape')    then iView.Escape := GetBoolean( 'escape' );
      if not IsTable('entries') then State.Error('Choice call without entries!');
      iCount := GetTableSize('entries');
      for i := 1 to iCount do
        with GetTable(['entries',i]) do
        try
          iEntry.Name    := GetString( 'name', 'ERROR' );
          iEntry.Desc    := GetString( 'desc', '' );
          iEntry.Enabled := GetBoolean( 'enabled', True );
          iEntry.Value   := i;
          if not IsNil('value') then iEntry.Value := GetValue( 'value' );
          iView.Add( iEntry );
        finally
          Free;
        end;
    finally
      Free;
    end;
  IO.PushLayer( iView );
  repeat
    IO.FullUpdate;
    IO.HandleEvents;
  until not IO.IsTopLayer( iView );
  State.PushVariant(TChoiceView.Result);
  Result := 1;
end;

const lua_ui_lib : array[0..10] of luaL_Reg = (
      ( name : 'msg';           func : @lua_ui_msg ),
      ( name : 'msg_clear';     func : @lua_ui_msg_clear ),
      ( name : 'msg_enter';     func : @lua_ui_msg_enter ),
      ( name : 'msg_history';   func : @lua_ui_msg_history ),
      ( name : 'choice';        func : @lua_ui_choice ),
      ( name : 'blood_slide';   func : @lua_ui_blood_slide),
      ( name : 'blink';         func : @lua_ui_blink),
      ( name : 'plot_screen';   func : @lua_ui_plot_screen),
      ( name : 'set_hint';      func : @lua_ui_set_hint ),
      ( name : 'strip_encoding';func : @lua_ui_strip_encoding ),
      ( name : nil;          func : nil; )
);

class procedure TDoomIO.RegisterLuaAPI( State : TLuaState );
begin
  State.Register( 'ui', lua_ui_lib );
end;

procedure EmitCrashInfo ( const aInfo : AnsiString; aInGame : Boolean ) ;
function Iff(expr : Boolean; const str : AnsiString) : AnsiString;
begin
  if expr then exit(str) else exit('');
end;
var iErrorMessage : AnsiString;
begin
  {$IFDEF WINDOWS}
  if GraphicsVersion then
  begin
    iErrorMessage := 'DRL crashed!'#10#10'Reason : '+aInfo+#10#10
     +'If this reason doesn''t seem your fault, please submit a bug report at http://forum.chaosforge.org/'#10
     +'Be sure to include the last entries in your error.log that will get created once you hit OK.'
     +Iff(aInGame and Option_SaveOnCrash,#10'DRL will also attempt to save your game, so you may continue on the next level.');
    MessageBox( 0, PChar(iErrorMessage),
     'DRL - Fatal Error!', MB_OK or MB_ICONERROR );
  end
  else
  {$ENDIF}
  begin
    DoneVideo;
    Writeln;
    Writeln;
    Writeln;
    Writeln('Abnormal program termination!');
    Writeln;
    Writeln('Reason : ',aInfo);
    Writeln;
    Writeln('If this reason doesn''t seem your fault, please submit a bug report at' );
    Writeln('http://forum.chaosforge.org/, be sure to include the last entries in');
    Writeln('your error.log that will get created once you hit Enter.');
    if aInGame and Option_SaveOnCrash then
    begin
      Writeln( 'DRL will also attempt to save your game, so you may continue on' );
      Writeln( 'the next level.' );
    end;
    Readln;
  end;
end;

end.

