{$INCLUDE doomrl.inc}
unit doomio;
interface
uses {$IFDEF WINDOWS}Windows,{$ENDIF} Classes, SysUtils, vgenerics, vio,
     vsystems, vmath, vrltools, vluaconfig, vglquadsheet, doomspritemap, doomviews,
     viotypes, vbitmapfont, vioevent, vioconsole, vuielement, vuitypes;

type TCommandSet = set of Byte;
     TKeySet     = set of Byte;

type TDoomOnProgress = procedure ( aProgress : DWord ) of object;
     TAnsiStringArray = specialize TGArray< AnsiString >;

type TDoomIO = class( TIO )
  constructor Create; reintroduce;
  procedure Configure( aConfig : TLuaConfig; aReload : Boolean = False );
  function RunUILoop( aElement : TUIElement = nil ) : DWord; override;
  destructor Destroy; override;
  procedure Screenshot( aBB : Boolean );

  procedure PlaySound( SoundID : Word; coord : TCoord2D );
  procedure PlayMusic( const MusicID : Ansistring );
  procedure PlayMusicOnce( const MusicID : Ansistring );
  function ResolveSoundID( const ResolveIDs: array of AnsiString ) : Word;
  function EventWaitForMore( aSender : TUIElement ) : Boolean;

  procedure WADLoaded;
  procedure LoadStart;
  function LoadCurrent : DWord;
  procedure LoadProgress( aProgress : DWord );
  procedure LoadStop;
  procedure Update( aMSec : DWord ); override;

  function GetCommand : Byte;
  procedure WaitForEnter;
  function WaitForCommand( const aSet : TCommandSet; aTimeOut : DWord = 0 ) : Byte;
  function WaitForKey( const aSet : TKeySet ) : Byte;
  function WaitForKeyEvent( out aEvent : TIOEvent; aMouseClick : Boolean = False; aMouseMove : Boolean = False; aTimeOut : DWord = 0 ) : Boolean;
  function CommandEventPending : Boolean;

private
  procedure ReuploadTextures;
  procedure CalculateConsoleParams;
  procedure GraphicsDraw;
  procedure SoundQuery(nkey,nvalue : Variant);
  procedure MusicQuery(nkey,nvalue : Variant);
  procedure ColorQuery(nkey,nvalue : Variant);
protected
  function FullScreenCallback( aEvent : TIOEvent ) : Boolean;
  function ScreenShotCallback( aEvent : TIOEvent ) : Boolean;
  function BBScreenShotCallback( aEvent : TIOEvent ) : Boolean;
public // REMOVE
  FMsgFont    : TBitmapFont;
private
  FLoading    : TUILoadingScreen;
  FMCursor    : TDoomMouseCursor;
  FQuadSheet  : TGLQuadSheet;
  FTextSheet  : TGLQuadSheet;
  FPostSheet  : TGLQuadSheet;
  FSettings   : array [Boolean] of
  record
    Width  : Integer;
    Height : Integer;
    FMult  : Integer;
    TMult  : Integer;
    MiniM  : Integer;
  end;
  FMTarget     : TCoord2D;
  FVPadding    : DWord;
  FFontMult    : Byte;
  FTileMult    : Byte;
  FMiniScale   : Byte;
  FLinespace   : Word;
  FKeyCode     : TIOKeyCode;
  FLastTick    : TDateTime;
  FSoundKeys   : TAnsiStringArray;
  FSoundValues : TAnsiStringArray;
  FMusicKeys   : TAnsiStringArray;
  FMusicValues : TAnsiStringArray;
public
  property QuadSheet : TGLQuadSheet read FQuadSheet;
  property TextSheet : TGLQuadSheet read FTextSheet;
  property PostSheet : TGLQuadSheet read FPostSheet;
  property MiniScale : Byte read FMiniScale;
  property FontMult  : Byte read FFontMult;
  property TileMult  : Byte read FTileMult;
  property MCursor   : TDoomMouseCursor read FMCursor;
  property MTarget   : TCoord2D read FMTarget;
end;

var IO : TDoomIO;

procedure EmitCrashInfo( const aInfo : AnsiString; aInGame : Boolean  );

implementation

uses video, vlog, vdebug,
     variants, vdf, dateutils,
     vutil,
     vsound, vimage, vglimage,
     vfmodsound,
     vsdlsound,
     vuiconsole, vcolor,
     vtextio, vtextconsole,
     vsdlio, vglconsole,
     vgllibrary, vglulibrary,
     doomtextures,  doombase,
     dfdata, dfoutput, dfplayer;

{ TDoomIO }

constructor TDoomIO.Create;
var iStyle      : TUIStyle;
    iCoreData   : TVDataFile;
    iImage      : TImage;
    iFontTexture: TTextureID;
    iFont       : TBitmapFont;
    iStream     : TStream;
    iFullscreen : Boolean;
    iCurrentWH  : TIOPoint;
    iDoQuery    : Boolean;
    iSDLFlags   : TSDLIOFlags;
  procedure ParseSettings( aFull : Boolean; const aPrefix : AnsiString; aDef : TIOPoint );
  begin
    with FSettings[ aFull ] do
    begin
      Width  := Config.Configure( aPrefix+'Width', aDef.X );
      Height := Config.Configure( aPrefix+'Height', aDef.Y );
      FMult  := Config.Configure( aPrefix+'FontMult', -1 );
      TMult  := Config.Configure( aPrefix+'TileMult', -1 );
      MiniM  := Config.Configure( aPrefix+'MiniMapSize', -1 );
      if Width  = -1 then Width  := iCurrentWH.X;
      if Height = -1 then Height := iCurrentWH.Y;
      if FMult  = -1 then
        if (Width >= 1600) and (Height >= 900)
          then FMult := 2
          else FMult := 1;
      if TMult  = -1 then
        if (Width >= 1050) and (Height >= 1050)
          then TMult := 2
          else TMult := 1;
      if MiniM = -1 then
      begin
        MiniM := Width div 220;
        MiniM := Max( 3, MiniM );
        MiniM := Min( 9, MiniM );
      end;
    end;
  end;

begin
  FLoading := nil;
  IO := Self;
  FVPadding := 0;
  FFontMult := 1;
  FTileMult := 1;
  FMCursor := nil;
  FQuadSheet := nil;
  FTextSheet := nil;
  FPostSheet := nil;
  Textures   := nil;

  if GraphicsVersion then
  begin
    {$IFDEF WINDOWS}
    if not GodMode then
    begin
      FreeConsole;
      vdebug.DebugWriteln := nil;
    end
    else
    begin
      Logger.AddSink( TConsoleLogSink.Create( LOGDEBUG, True ) );
    end;
    {$ENDIF}
    iFullScreen := Config.Configure( 'StartFullscreen', False ) or ForceFullscreen;
    {$IFDEF WINDOWS}
    iDoQuery := Config.Configure( 'FullscreenQuery', True );
    if iDoQuery then
      iFullScreen := MessageBox( 0, 'Do you want to run in fullscreen mode?'#10'You can toggle fullscreen any time by pressing Alt-Enter.'#10#10'You can also set the defaults in config.lua, to avoid this dialog.','DoomRL - Run fullscreen?', MB_YESNO or MB_ICONQUESTION ) = IDYES;
    {$ENDIF}

    if not TSDLIODriver.GetCurrentResolution( iCurrentWH ) then
      iCurrentWH.Init(800,600);

    ParseSettings( False, 'Windowed', vutil.Point(800,600) );
    ParseSettings( True, 'Fullscreen', vutil.Point(-1,-1) );

    with FSettings[ iFullscreen ] do
    begin
      iSDLFlags := [ SDLIO_OpenGL ];
      if iFullscreen then Include( iSDLFlags, SDLIO_Fullscreen );
      FIODriver := TSDLIODriver.Create( Width, Height, 32, iSDLFlags );
      FFontMult := FMult;
      FTileMult := TMult;
      FMiniScale:= MiniM;
    end;

    Textures   := TDoomTextures.Create;

    if GodMode then
      iImage := LoadImage('font10x18.png')
    else
    begin
      iCoreData := TVDataFile.Create(DataPath+'doomrl.wad');
      iCoreData.DKKey := LoveLace;
      iStream := iCoreData.GetFile( 'font10x18.png', 'fonts' );
      iImage := LoadImage( iStream, iStream.Size );
      FreeAndNil( iStream );
      FreeAndNil( iCoreData );
    end;
    iFontTexture := Textures.AddImage( 'font10x18', iImage, Option_Blending );
    Textures[ iFontTexture ].Image.SubstituteColor( ColorBlack, ColorZero );
    Textures[ iFontTexture ].Upload;

    iFont := TBitmapFont.CreateFromGrid( iFontTexture, 32, 256-32, 32 );
    CalculateConsoleParams;
    FConsole := TGLConsoleRenderer.Create( iFont, 80, 25, FLineSpace, [VIO_CON_CURSOR] );
    TGLConsoleRenderer( FConsole ).SetPositionScale( (FIODriver.GetSizeX - 80*10*FFontMult) div 2, 0, FLineSpace, FFontMult );
    LoadGLU;
    gluOrtho2D(0, FIODriver.GetSizeX, FIODriver.GetSizeY,0 );
    SpriteMap  := TDoomSpriteMap.Create;
    FQuadSheet := TGLQuadSheet.Create;
    FTextSheet := TGLQuadSheet.Create;
    FPostSheet := TGLQuadSheet.Create;
    FMCursor   := TDoomMouseCursor.Create;
    TSDLIODriver( FIODriver ).ShowMouse( False );
  end
  else
  begin
    FIODriver := TTextIODriver.Create( 80, 25 );
    if (FIODriver.GetSizeX < 80) or (FIODriver.GetSizeY < 25) then
      raise EIOException.Create('Too small console available, resize your console to 80x25!');
    FConsole  := TTextConsoleRenderer.Create( 80, 25, [VIO_CON_BGCOLOR, VIO_CON_CURSOR] );
  end;

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

  inherited Create( FIODriver, FConsole, iStyle );
  LoadStart;

  UI := TDoomUI.Create;
  IO := Self;
  FConsole.Clear;
  FConsole.HideCursor;
  FLastTick := Now;
  FConsoleWindow := nil;
  FullUpdate;
end;

procedure TDoomIO.Configure ( aConfig : TLuaConfig; aReload : Boolean ) ;
var iCount   : DWord;
    iProgress: DWord;
begin
  aConfig.ResetCommands;
  aConfig.LoadKeybindings('Keybindings');

  // TODO : configurable
  if GodMode then
    RegisterDebugConsole( VKEY_F1 );
  FIODriver.RegisterInterrupt( VKEY_F9, @ScreenShotCallback );
  FIODriver.RegisterInterrupt( VKEY_F10, @BBScreenShotCallback );
  if GraphicsVersion then
  begin
    FIODriver.RegisterInterrupt( IOKeyCode( VKEY_ENTER, [ VKMOD_ALT ] ), @FullScreenCallback );
    FIODriver.RegisterInterrupt( IOKeyCode( VKEY_F12, [ VKMOD_CTRL ] ), @FullScreenCallback );
  end;

  if Option_MessageBuffer < 20 then Option_MessageBuffer := 20;

  if SoundVersion and (Option_SoundEngine <> 'NONE') then
  begin
    Option_SoundVol := aConfig.Configure('SoundVolume',Option_SoundVol);
    Option_MusicVol := aConfig.Configure('MusicVolume',Option_MusicVol);

    if Option_Music or Option_Sound then
    begin
      if Option_SoundVol > 25 then Option_SoundVol := 25;
      if Option_MusicVol > 25 then Option_MusicVol := 25;
      if not aReload then
      begin
        if Option_SoundEngine = 'FMOD'
          then Sound := Systems.Add(TFMODSound.Create) as TSound
          else Sound := Systems.Add(TSDLSound.Create(Option_SDLMixerFreq, Option_SDLMixerFormat, Option_SDLMixerChunkSize ) ) as TSound;
      end
      else
        Sound.Reset;
      Sound.SetSoundVolume(5*Option_SoundVol);
      Sound.SetMusicVolume(5*Option_MusicVol);

      if aReload then
      begin
        FSoundKeys   := TAnsiStringArray.Create;
        FSoundValues := TAnsiStringArray.Create;
        FMusicKeys   := TAnsiStringArray.Create;
        FMusicValues := TAnsiStringArray.Create;
        if Option_Music then
          aConfig.EntryFeed('Music', @MusicQuery );
        if Option_Sound then
          aConfig.RecEntryFeed('Sound', @SoundQuery );

        LoadStart;
        FLoading.Max := (FSoundKeys.Size+FMusicKeys.Size) div 2 +FLoading.Max;
        iProgress    := 0;

        if FSoundKeys.Size > 0 then
          for iCount := 0 to FSoundKeys.Size - 1 do
          begin
            Sound.RegisterSample(DataPath+FSoundValues[iCount],FSoundKeys[iCount]);
            Inc( iProgress );
            if iProgress mod 20 = 0 then
              LoadProgress( iProgress div 2 );
          end;

        if FMusicKeys.Size > 0 then
          for iCount := 0 to FMusicKeys.Size - 1 do
          begin
            Sound.RegisterMusic(DataPath+FMusicValues[iCount],FMusicKeys[iCount]);
            Inc( iProgress );
            if iProgress mod 20 = 0 then
              LoadProgress( iProgress div 2 );
          end;
        LoadProgress( iProgress div 2 );
        FreeAndNil( FSoundKeys );
        FreeAndNil( FSoundValues );
        FreeAndNil( FMusicKeys );
        FreeAndNil( FMusicValues );
      end;
    end;
  end;

  if aReload then
    aConfig.EntryFeed('Colors', @ColorQuery );

end;

function TDoomIO.RunUILoop( aElement : TUIElement = nil ) : DWord;
begin
  if (UI <> nil) and (UI.GameUI <> nil) then UI.GameUI.Enabled := False;
  if IO.MCursor <> nil then IO.MCursor.Active := True;
  FConsole.HideCursor;
  Result := inherited RunUILoop( aElement );
  if (UI <> nil) and (UI.GameUI <> nil) then UI.GameUI.Enabled := True;
end;

destructor TDoomIO.Destroy;
begin
  FreeAndNil( FMCursor );

  FreeAndNil( SpriteMap );
  FreeAndNil( Textures );
  FreeAndNil( FQuadSheet );
  FreeAndNil( FTextSheet );
  FreeAndNil( FPostSheet );

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

procedure TDoomIO.SoundQuery(nkey,nvalue : Variant);
var Key, Value : AnsiString;
begin
  Key   := LowerCase(nKey);
  Value := nValue;
  FSoundKeys.Push( Key );
  FSoundValues.Push( Value );
end;

procedure TDoomIO.MusicQuery(nkey,nvalue : Variant);
var Key, Value : AnsiString;
begin
  Key   := LowerCase(nKey);
  Value := nValue;
  FMusicKeys.Push( Key );
  FMusicValues.Push( Value );
end;

procedure TDoomIO.ColorQuery(nkey,nvalue : Variant);
begin
    ColorOverrides[nkey] := nvalue;
end;

function TDoomIO.FullScreenCallback ( aEvent : TIOEvent ) : Boolean;
var iFullscreen : Boolean;
    iSDLFlags   : TSDLIOFlags;
begin
  iFullscreen := TSDLIODriver(FIODriver).FullScreen;
  iFullscreen := not iFullscreen;
  with FSettings[ iFullscreen ] do
  begin
    iSDLFlags := [ SDLIO_OpenGL ];
    if not TSDLIODriver(FIODriver).FullScreen then Include( iSDLFlags, SDLIO_Fullscreen );
    TSDLIODriver(FIODriver).ResetVideoMode( Width, Height, 32, iSDLFlags );
    FTileMult := TMult;
    FFontMult := FMult;
    FMiniScale:= MiniM;
  end;
  ReuploadTextures;
  CalculateConsoleParams;
  TGLConsoleRenderer( FConsole ).SetPositionScale( (FIODriver.GetSizeX - 80*10*FFontMult) div 2, 0, FLineSpace, FFontMult );
  TGLConsoleRenderer( FConsole ).HideCursor;
  if (UI <> nil) and (UI.GameUI <> nil) then UI.GameUI.SetMinimapScale(FMiniScale);
  FUIRoot.DeviceChanged;
  SpriteMap.Recalculate;
  if Player <> nil then
    SpriteMap.NewShift := SpriteMap.ShiftValue( Player.Position );
  Exit( True );
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

procedure TDoomIO.PlaySound( SoundID : Word; coord : TCoord2D );
var Volume : Byte;
    Pan    : Byte;
    Dist   : Word;
    Pos    : TCoord2D;
begin
  if SoundID = 0 then Exit;
  if (not SoundVersion) or (not Option_Sound) or SoundOff then Exit;

  Pos := Player.Position;

  Dist := Distance(coord,Pos);
  if Dist <= 1 then Volume := 127 else
                    Volume := Clamp((25 - Dist) * 6,0,127);
  if Volume <> 0 then
    if Volume < 30 then Volume := 30;

  Pan := Clamp((coord.x-Pos.x) * 15,-128,127)+128;
  Sound.PlaySample(SoundID,Volume,Pan);
end;


function TDoomIO.ResolveSoundID(const ResolveIDs: array of AnsiString): Word;
var c : DWord;
begin
  if (not SoundVersion) or (not Option_Sound) or SoundOff then Exit(0);
  for c := Low(ResolveIDs) to High(ResolveIDs) do
    if ResolveIDs[c] <> '' then
    begin
      Result := Sound.GetSampleID(ResolveIDs[c]);
      if Result <> 0 then Exit( Result );
    end;
  Exit(0);
end;

function TDoomIO.EventWaitForMore ( aSender : TUIElement ) : Boolean;
begin
  if Option_MorePrompt then
  begin
    UI.SetHint('[more]');
    WaitForCommand([COMMAND_OK,COMMAND_MLEFT]);
    UI.SetHint('');
  end;
  UI.MsgUpdate;
  Exit( True );
end;

procedure TDoomIO.WADLoaded;
begin
  if GraphicsVersion then
  begin
    if IO.MCursor <> nil then MCursor.SetTextureID( Textures.TextureID['cursor'], 32 );
    FMsgFont := Lua.LoadFont( 'message' );
  end;
end;

procedure TDoomIO.LoadStart;
begin
  if FLoading = nil then
    FLoading := TUILoadingScreen.Create(FUIRoot,100);
end;

function TDoomIO.LoadCurrent : DWord;
begin
  if Assigned( FLoading ) then Exit( FLoading.Current );
  Exit( 0 );
end;

procedure TDoomIO.LoadProgress ( aProgress : DWord ) ;
begin
  if Assigned( FLoading ) then FLoading.OnProgress( aProgress );
  IO.FullUpdate;
end;

procedure TDoomIO.LoadStop;
begin
  FreeAndNil( FLoading );
end;

procedure TDoomIO.ReuploadTextures;
begin
  Textures.Upload;
  SpriteMap.ReassignTextures;
end;

procedure TDoomIO.CalculateConsoleParams;
begin
  FLineSpace := Max((FIODriver.GetSizeY - 25*18*FFontMult - 2*FVPadding) div 25 div FFontMult,0);
end;

procedure TDoomIO.Update( aMSec : DWord );
var iMousePos : TUIPoint;
begin
  if GraphicsVersion then
  begin
    if (Doom <> nil) and (UI <> nil) then UI.GFXAnimationUpdate( aMSec );
    if GraphicsVersion then GraphicsDraw;
    if FQuadSheet <> nil then FQuadSheet.Draw;
  end;
  FUIRoot.OnUpdate( aMSec );
  FUIRoot.Render;
  if FTextSheet <> nil then FTextSheet.Draw;
  FConsole.Update;
  if FPostSheet <> nil then FPostSheet.Draw;
  if (FMCursor <> nil) and (FMCursor.Active) and FIODriver.GetMousePos(iMousePos) then
  begin
    FMCursor.Draw( iMousePos.X, iMousePos.Y, FLastUpdate );
  end;
end;

procedure TDoomIO.GraphicsDraw;
var iMeasure  : TDateTime;
    iTickTime : DWord;
    iSizeY    : DWord;
    iSizeX    : DWord;
begin
  iMeasure := Now;
  iTickTime := MilliSecondsBetween( iMeasure, FLastTick );
  FLastTick := iMeasure;

  iSizeY    := FIODriver.GetSizeY-2*FVPadding;
  iSizeX    := FIODriver.GetSizeX;
  glViewport( 0, FVPadding, iSizeX, iSizeY );

  glEnable( GL_TEXTURE_2D );
  glDisable( GL_DEPTH_TEST );
  glEnable( GL_BLEND );

  glMatrixMode( GL_PROJECTION );
  glPushMatrix();
  glLoadIdentity();
  gluOrtho2D(0, iSizeX, iSizeY, 0);

  glMatrixMode( GL_MODELVIEW );
  glPushMatrix();
  glLoadIdentity();
  glColor4f(1.0,1.0,1.0,1.0);
  glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );

  if (Doom <> nil) and (Doom.State = DSPlaying) then
  begin
    FConsole.HideCursor;
    //if not UI.AnimationsRunning then SpriteMap.NewShift := SpriteMap.ShiftValue( Player.Position );
    SpriteMap.Update( iTickTime );
    UI.GFXAnimationDraw;
    SpriteMap.Draw;
  end;

  iSizeY    := FIODriver.GetSizeY-2*FVPadding;
  iSizeX    := FIODriver.GetSizeX;
  glViewport( 0, FVPadding, iSizeX, iSizeY );
  glMatrixMode( GL_PROJECTION );
  glPushMatrix();
  glLoadIdentity();
  gluOrtho2D( 0, iSizeX, iSizeY, 0);
  glMatrixMode( GL_MODELVIEW );
  glPushMatrix();
  glLoadIdentity();
end;

function TDoomIO.GetCommand : Byte;
var Special    : Variant;
begin
  if Config.isPaused then
  begin
     Special := Config.Resume;
     if VarIsOrdinal(Special) and (not VarIsType( Special, varBoolean ) )
        then GetCommand := Special
        else GetCommand := COMMAND_YIELD;
  end
  else
    GetCommand := WaitForCommand([]);

  if GetCommand <> COMMAND_YIELD then
    UI.MsgUpDate;

  if GetCommand = COMMAND_INVALID then
  begin
    Special := Config.RunKey( FKeyCode );
    if VarIsOrdinal(Special) and (not VarIsType( Special, varBoolean ) ) then GetCommand := Special;
  end;

  Exit( GetCommand );
end;


procedure TDoomIO.WaitForEnter;
begin
  WaitForCommand([COMMAND_OK,COMMAND_MLEFT]);
end;

function TDoomIO.WaitForCommand ( const aSet : TCommandSet; aTimeOut : DWord = 0 ) : Byte;
var iCommand : Byte;
    iEvent   : TIOEvent;
    iPoint   : TIOPoint;
    iStart   : DWord;
    iWait    : DWord;
begin
  iStart := FLastUpdate;
  repeat
    if (aTimeOut <> 0) and (FLastUpdate - iStart > aTimeOut) then Exit( 0 );
    iCommand := 0;
    iWait := 0;
    if aTimeOut <> 0 then iWait := Max( aTimeOut - (FLastUpdate - iStart), 0 );
    WaitForKeyEvent( iEvent, GraphicsVersion, GraphicsVersion and (COMMAND_MMOVE in aSet), iWait );
    if (iEvent.EType = VEVENT_SYSTEM) then
      if Option_LockClose
         then Exit( COMMAND_QUIT )
         else Exit( COMMAND_HARDQUIT );

    if (iEvent.EType = VEVENT_MOUSEMOVE) then
    begin
      iPoint := SpriteMap.DevicePointToCoord( iEvent.MouseMove.Pos );
      FMTarget.Create( iPoint.X, iPoint.Y );
      if Doom.Level.isProperCoord( FMTarget ) then
        Exit( COMMAND_MMOVE );
    end;
    if iEvent.EType = VEVENT_MOUSEDOWN then
    begin
      iPoint := SpriteMap.DevicePointToCoord( iEvent.Mouse.Pos );
      FMTarget.Create( iPoint.X, iPoint.Y );
      if Doom.Level.isProperCoord( FMTarget ) then
      begin
        case iEvent.Mouse.Button of
          VMB_BUTTON_LEFT     : Exit( COMMAND_MLEFT );
          VMB_BUTTON_MIDDLE   : Exit( COMMAND_MMIDDLE );
          VMB_BUTTON_RIGHT    : Exit( COMMAND_MRIGHT );
          VMB_WHEEL_UP        : Exit( COMMAND_MSCRUP );
          VMB_WHEEL_DOWN      : Exit( COMMAND_MSCRDOWN );
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

function TDoomIO.WaitForKeyEvent ( out aEvent : TIOEvent;
  aMouseClick : Boolean; aMouseMove : Boolean; aTimeOut : DWord ) : Boolean;
var iEndLoop : TIOEventTypeSet;
    iStart   : DWord;
begin
  iEndLoop := [VEVENT_KEYDOWN];
  iStart   := FLastUpdate;
  if aMouseClick then Include( iEndLoop, VEVENT_MOUSEDOWN );
  if aMouseMove  then Include( iEndLoop, VEVENT_MOUSEMOVE );
  repeat
    if (aTimeOut <> 0) and (FLastUpdate - iStart > aTimeOut) then Exit( False );
    repeat
      FullUpdate;
      FIODriver.Sleep(10);
    until FIODriver.EventPending;
    FIODriver.PollEvent( aEvent );
    if FUIRoot.OnEvent( aEvent ) then aEvent.EType := VEVENT_KEYUP;
    if (aEvent.EType = VEVENT_SYSTEM) and (aEvent.System.Code = VIO_SYSEVENT_QUIT) then
      Exit( True );
  until aEvent.EType in iEndLoop;
  Exit( True );
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

procedure TDoomIO.PlayMusic(const MusicID : Ansistring);
begin
  if (not SoundVersion) or (not Option_Music) then Exit;
  try
    if MusicID = '' then Sound.Silence;
    if MusicOff then Exit;
    if Sound.MusicExists(MusicID) then Sound.PlayMusic(MusicID)
                                  else PlayMusic('level'+IntToStr(Random(23)+2));
  except
    on e : Exception do
    begin
      Log('PlayMusic raised exception (' + E.ClassName + '): ' + e.message);
      UI.Msg( 'PlayMusic raised exception: ' + e.message );
    end;
  end;
end;

procedure TDoomIO.PlayMusicOnce(const MusicID : Ansistring);
begin
  if (not SoundVersion) or (not Option_Music) then Exit;
  try
    if MusicID = '' then Sound.Silence;
    if MusicOff then Exit;
    if Sound.MusicExists(MusicID) then Sound.PlayMusicOnce(MusicID);
  except
      on e : Exception do
      begin
        Log('PlayMusicOnce raised exception (' + E.ClassName + '): ' + e.message);
        UI.Msg( 'PlayMusic raised exception: ' + e.message );
      end;
  end;
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

