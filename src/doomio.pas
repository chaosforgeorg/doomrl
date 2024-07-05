{$INCLUDE doomrl.inc}
unit doomio;
interface
uses {$IFDEF WINDOWS}Windows,{$ENDIF} Classes, SysUtils, vio,
     vsystems, vrltools, vluaconfig, vglquadrenderer,
     doomspritemap, doomviews, doomaudio,
     viotypes, vioevent, vioconsole, vuielement;

type TCommandSet = set of Byte;
     TKeySet     = set of Byte;

type TDoomOnProgress = procedure ( aProgress : DWord ) of object;


type TDoomIO = class( TIO )
  constructor Create; reintroduce;
  procedure Configure( aConfig : TLuaConfig; aReload : Boolean = False ); virtual;
  function RunUILoop( aElement : TUIElement = nil ) : DWord; override;
  procedure FullUpdate; override;
  destructor Destroy; override;
  procedure Screenshot( aBB : Boolean );

  function EventWaitForMore : Boolean;

  procedure LoadStart( aAdd : DWord = 0 );
  function LoadCurrent : DWord;
  procedure LoadProgress( aProgress : DWord );
  procedure LoadStop;
  procedure Update( aMSec : DWord ); override;

  procedure WaitForEnter;
  function WaitForCommand( const aSet : TCommandSet ) : Byte;
  function WaitForKey( const aSet : TKeySet ) : Byte;
  procedure WaitForKeyEvent( out aEvent : TIOEvent; aMouseClick : Boolean = False; aMouseMove : Boolean = False );
  function CommandEventPending : Boolean;

  procedure SetTempHint( const aText : AnsiString );
  procedure SetHint( const aText : AnsiString );

protected
  procedure DrawHud;
  procedure ColorQuery(nkey,nvalue : Variant);
  function ScreenShotCallback( aEvent : TIOEvent ) : Boolean;
  function BBScreenShotCallback( aEvent : TIOEvent ) : Boolean;
protected
  FAudio       : TDoomAudio;
  FTime        : QWord;
  FLoading     : TUILoadingScreen;
  FMTarget     : TCoord2D;
  FKeyCode     : TIOKeyCode;

  FHudEnabled  : Boolean;
  FStoredHint  : AnsiString;
  FHint        : AnsiString;

public
  property KeyCode    : TIOKeyCode read FKeyCode    write FKeyCode;
  property Audio      : TDoomAudio read FAudio;
  property MTarget    : TCoord2D   read FMTarget    write FMTarget;
end;

var IO : TDoomIO;

procedure EmitCrashInfo( const aInfo : AnsiString; aInGame : Boolean  );

implementation

uses video, dateutils, variants,
     vlog, vdebug, vutil, vuiconsole,
     vsdlio, vglconsole, vtig,
     doombase, dfdata, dfoutput, dfplayer;

{ TDoomIO }

constructor TDoomIO.Create;
var iStyle      : TUIStyle;
begin
  FLoading := nil;
  IO := Self;
  FTime := 0;
  FAudio := TDoomAudio.Create;
  FHudEnabled := False;
  FStoredHint := '';
  FHint       := '';


  FIODriver.SetTitle('Doom, the Roguelike','DoomRL');

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

  inherited Create( FIODriver, FConsole, iStyle );
  LoadStart;

  UI := TDoomUI.Create;
  IO := Self;
  FConsole.Clear;
  FConsole.HideCursor;
  FConsoleWindow := nil;
  FullUpdate;
end;

procedure TDoomIO.Configure ( aConfig : TLuaConfig; aReload : Boolean ) ;
begin
  aConfig.ResetCommands;
  aConfig.LoadKeybindings('Keybindings');
  // TODO : configurable
  if GodMode then
    RegisterDebugConsole( VKEY_F1 );
  FIODriver.RegisterInterrupt( VKEY_F9, @ScreenShotCallback );
  FIODriver.RegisterInterrupt( VKEY_F10, @BBScreenShotCallback );
  if Option_MessageBuffer < 20 then Option_MessageBuffer := 20;
  FAudio.Configure( aConfig, aReload );
  if aReload then
    aConfig.EntryFeed('Colors', @ColorQuery );
end;

function TDoomIO.RunUILoop( aElement : TUIElement = nil ) : DWord;
begin
  FHudEnabled := False;
  FConsole.HideCursor;
  Result := inherited RunUILoop( aElement );
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
begin
  FreeAndNil( FAudio );
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

  iName := 'DoomRL';
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
var iCon : TUIConsole;
begin
  iCon.Init( FConsole );
  iCon.Clear;

  UI.OnRedraw;

  if FHint <> '' then
    VTIG_FreeLabel( ' '+FHint+' ', Point( -1-Length( FHint ), 3 ), Yellow );
end;

procedure TDoomIO.SetHint ( const aText : AnsiString ) ;
begin
  FStoredHint := aText;
  FHint       := aText;
end;

procedure TDoomIO.SetTempHint ( const aText : AnsiString ) ;
begin
  if aText = ''
    then FHint := FStoredHint
    else FHint := aText;
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

function TDoomIO.EventWaitForMore : Boolean;
begin
  if Option_MorePrompt then
  begin
    SetHint('[more]');
    WaitForCommand([INPUT_OK,INPUT_MLEFT]);
    SetHint('');
  end;
  UI.MsgUpdate;
  Exit( True );
end;

procedure TDoomIO.LoadStart( aAdd : DWord = 0 );
begin
  if FLoading = nil then
  begin
    FLoading := TUILoadingScreen.Create(FUIRoot,100);
    FLoading.Max := FLoading.Max + aAdd;
  end;
end;

function TDoomIO.LoadCurrent : DWord;
begin
  if Assigned( FLoading ) then Exit( FLoading.Current );
  Exit( 0 );
end;

procedure TDoomIO.LoadProgress ( aProgress : DWord ) ;
begin
  if Assigned( FLoading ) then FLoading.OnProgress( aProgress );
  FullUpdate;
end;

procedure TDoomIO.LoadStop;
begin
  FreeAndNil( FLoading );
end;

procedure TDoomIO.Update( aMSec : DWord );
begin
  FTime += aMSec;
  FAudio.Update( aMSec );
  if FHudEnabled then
    UI.OnUpdate( aMSec );
  FUIRoot.OnUpdate( aMSec );
  FUIRoot.Render;

  VTIG_EndFrame;
  VTIG_Render;

  FConsole.Update;
end;

procedure TDoomIO.WaitForEnter;
begin
  WaitForCommand([INPUT_OK,INPUT_MLEFT]);
end;

function TDoomIO.WaitForCommand ( const aSet : TCommandSet ) : Byte;
var iCommand : Byte;
    iEvent   : TIOEvent;
    iPoint   : TIOPoint;
begin
  repeat
    iCommand := 0;
    WaitForKeyEvent( iEvent, GraphicsVersion, GraphicsVersion and (INPUT_MMOVE in aSet) );
    if (iEvent.EType = VEVENT_SYSTEM) then
      if Option_LockClose
         then Exit( INPUT_QUIT )
         else Exit( INPUT_HARDQUIT );

    if (iEvent.EType = VEVENT_MOUSEMOVE) then
    begin
      iPoint := SpriteMap.DevicePointToCoord( iEvent.MouseMove.Pos );
      FMTarget.Create( iPoint.X, iPoint.Y );
      if Doom.Level.isProperCoord( FMTarget ) then
        Exit( INPUT_MMOVE );
    end;
    if iEvent.EType = VEVENT_MOUSEDOWN then
    begin
      iPoint := SpriteMap.DevicePointToCoord( iEvent.Mouse.Pos );
      FMTarget.Create( iPoint.X, iPoint.Y );
      if Doom.Level.isProperCoord( FMTarget ) then
      begin
        case iEvent.Mouse.Button of
          VMB_BUTTON_LEFT     : Exit( INPUT_MLEFT );
          VMB_BUTTON_MIDDLE   : Exit( INPUT_MMIDDLE );
          VMB_BUTTON_RIGHT    : Exit( INPUT_MRIGHT );
          VMB_WHEEL_UP        : Exit( INPUT_MSCRUP );
          VMB_WHEEL_DOWN      : Exit( INPUT_MSCRDOWN );
        end;
        if (aSet = []) then Exit(iCommand);
      end;
    end
    else
    begin
      FKeyCode := IOKeyEventToIOKeyCode( iEvent.Key );
      iCommand := Config.Commands[ FKeyCode ];
      if (aSet = []) and ((FKeyCode mod 256) <> 0) then Exit( iCommand );
    end;
  until (iCommand in aSet);
  Exit( iCommand )
end;

function TDoomIO.WaitForKey ( const aSet : TKeySet ) : Byte;
var iKey   : Byte;
    iEvent : TIOEvent;
begin
  repeat
    WaitForKeyEvent( iEvent );
    if (iEvent.EType = VEVENT_SYSTEM) and (iEvent.System.Code = VIO_SYSEVENT_QUIT) then Exit( 1 );
    iKey := Ord( iEvent.Key.ASCII );
    if iEvent.Key.Code = vioevent.VKEY_ESCAPE then iKey := 1; // TODO: temp! remove!
    if aSet = [] then Exit( iKey );
  until iKey in aSet;
  Exit( iKey );
end;

procedure TDoomIO.WaitForKeyEvent ( out aEvent : TIOEvent;
  aMouseClick : Boolean; aMouseMove : Boolean );
var iEndLoop : TIOEventTypeSet;
    iPeek    : TIOEvent;
    iResult  : Boolean;
begin
  iEndLoop := [VEVENT_KEYDOWN];
  if aMouseClick then Include( iEndLoop, VEVENT_MOUSEDOWN );
  if aMouseMove  then Include( iEndLoop, VEVENT_MOUSEMOVE );
  repeat
    while not FIODriver.EventPending do
    begin
      FullUpdate;
      FIODriver.Sleep(10);
    end;
    if not FIODriver.PollEvent( aEvent ) then continue;
    if ( aEvent.EType = VEVENT_MOUSEMOVE ) and FIODriver.EventPending then
    begin
      repeat
        iResult := FIODriver.PeekEvent( iPeek );
        if ( not iResult ) or ( iPeek.EType <> VEVENT_MOUSEMOVE ) then break;
        FIODriver.PollEvent( aEvent );
      until (not FIODriver.EventPending);
    end;
    if OnEvent( aEvent ) or FUIRoot.OnEvent( aEvent ) then aEvent.EType := VEVENT_KEYUP;
    if (aEvent.EType = VEVENT_SYSTEM) and (aEvent.System.Code = VIO_SYSEVENT_QUIT) then
      Exit;
  until aEvent.EType in iEndLoop;
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
    iErrorMessage := 'DoomRL crashed!'#10#10'Reason : '+aInfo+#10#10
     +'If this reason doesn''t seem your fault, please submit a bug report at http://forum.chaosforge.org/'#10
     +'Be sure to include the last entries in your error.log that will get created once you hit OK.'
     +Iff(aInGame and Option_SaveOnCrash,#10'DoomRL will also attempt to save your game, so you may continue on the next level.');
    MessageBox( 0, PChar(iErrorMessage),
     'DoomRL - Fatal Error!', MB_OK or MB_ICONERROR );
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
      Writeln( 'DoomRL will also attempt to save your game, so you may continue on' );
      Writeln( 'the next level.' );
    end;
    Readln;
  end;
end;

end.

