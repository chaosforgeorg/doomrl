{$INCLUDE doomrl.inc}
unit doomgfxio;
interface
uses vglquadrenderer, vgltypes, vluaconfig, vioevent, viotypes, vuielement, vimage,
     vrltools, vutil, vtextures, vvector,
     doomio, doomspritemap, doomanimation, doomminimap, dfdata, dfthing;

type

{ TDoomGFXIO }

 TDoomGFXIO = class( TDoomIO )
    constructor Create; reintroduce;
    procedure Reconfigure( aConfig : TLuaConfig ); override;
    procedure Configure( aConfig : TLuaConfig; aReload : Boolean = False ); override;
    procedure Update( aMSec : DWord ); override;
    function PushLayer( aLayer : TInterfaceLayer ) : TInterfaceLayer; override;
    function OnEvent( const iEvent : TIOEvent ) : Boolean; override;
    procedure UpdateMinimap;
    destructor Destroy; override;

    procedure WaitForAnimation; override;
    function AnimationsRunning : Boolean; override;
    procedure AnimationWipe; override;
    procedure Blink( aColor : Byte; aDuration : Word = 100; aDelay : DWord = 0); override;
    procedure addScreenShakeAnimation( aDuration : DWord; aDelay : DWord; aStrength : Single ); override;
    procedure addMoveAnimation( aDuration : DWord; aDelay : DWord; aUID : TUID; aFrom, aTo : TCoord2D; aSprite : TSprite; aBeing : Boolean ); override;
    procedure addMeleeAnimation( aDuration : DWord; aDelay : DWord; aUID : TUID; aFrom, aTo : TCoord2D; aSprite : TSprite ); override;
    procedure addScreenMoveAnimation( aDuration : DWord; aTo : TCoord2D ); override;
    procedure addCellAnimation( aDuration : DWord; aDelay : DWord; aCoord : TCoord2D; aSprite : TSprite; aValue : Integer ); override;
    procedure addItemAnimation( aDuration : DWord; aDelay : DWord; aItem : TThing; aValue : Integer ); override;
    procedure addKillAnimation( aDuration : DWord; aDelay : DWord; aBeing : TThing ); override;
    procedure addMissileAnimation( aDuration : DWord; aDelay : DWord; aSource, aTarget : TCoord2D; aColor : Byte; aPic : Char; aDrawDelay : Word; aSprite : TSprite; aRay : Boolean = False ); override;
    procedure addMarkAnimation( aDuration : DWord; aDelay : DWord; aCoord : TCoord2D; aSprite : TSprite; aColor : Byte; aPic : Char ); override;
    procedure addSoundAnimation( aDelay : DWord; aPosition : TCoord2D; aSoundID : DWord ); override;
    function getUIDPosition( aUID : TUID; var aPosition : TVec2i ) : Boolean;

    procedure DeviceChanged;
    function DeviceCoordToConsoleCoord( aCoord : TIOPoint ) : TIOPoint; override;
    function ConsoleCoordToDeviceCoord( aCoord : TIOPoint ) : TIOPoint; override;
    procedure RenderUIBackground( aUL, aBR : TIOPoint; aOpacity : Single = 0.85 ); override;
    procedure SetTarget( aTarget : TCoord2D; aColor : Byte; aRange : Byte ); override;
    procedure SetAutoTarget( aTarget : TCoord2D ); override;
    procedure Focus( aCoord : TCoord2D ); override;
    procedure FinishTargeting; override;

 protected
    procedure ExplosionMark( aCoord : TCoord2D; aColor : Byte; aDuration : DWord; aDelay : DWord ); override;
    function FullScreenCallback( aEvent : TIOEvent ) : Boolean;
    procedure ResetVideoMode;
    procedure RecalculateScaling( aInitialize : Boolean );
    procedure CalculateConsoleParams;
    procedure SetMinimapScale( aScale : Byte );
  private
    FQuadSheet   : TGLQuadList;
    FTextSheet   : TGLQuadList;
    FPostSheet   : TGLQuadList;
    FQuadRenderer: TGLQuadRenderer;
    FProjection  : TMatrix44;
    FFontMult    : Byte;
    FTileMult    : Byte;
    FMiniScale   : Byte;
    FLinespace   : Word;
    FVPadding    : DWord;
    FCellX       : Integer;
    FCellY       : Integer;
    FFontSizeX   : Integer;
    FFontSizeY   : Integer;
    FFullscreen  : Boolean;

    FGPLeft      : TVec2f;
    FGPRight     : TVec2f;
    FGPCamera    : Single;

    FLastMouseTime : QWord;
    FMouseLock     : Boolean;
    FMCursor       : TDoomMouseCursor;
    FMinimap       : TDoomMinimap;

    FAnimations     : TAnimationManager;
    FTextures       : TTextureManager;
  public
    property QuadSheet : TGLQuadList read FQuadSheet;
    property TextSheet : TGLQuadList read FTextSheet;
    property PostSheet : TGLQuadList read FPostSheet;
    property FontMult  : Byte read FFontMult;
    property TileMult  : Byte read FTileMult;
    property MCursor   : TDoomMouseCursor read FMCursor;
    property Textures  : TTextureManager read FTextures;
  end;

implementation

uses {$IFDEF WINDOWS}windows,{$ENDIF}
     classes, sysutils,
     vdebug, vlog, vmath, vdf, vgl3library, vsdl2library,
     vglimage, vsdlio, vbitmapfont, vcolor, vglconsole, vioconsole,
     dfplayer,
     doombase, doomconfiguration;

var ConsoleSizeX : Integer = 80;
    ConsoleSizeY : Integer = 25;


procedure TDoomGFXIO.RecalculateScaling( aInitialize : Boolean );
var iWidth        : Integer;
    iHeight       : Integer;
    iOldFontMult  : Integer;
    iOldMiniScale : Integer;
begin
  iWidth      := FIODriver.GetSizeX;
  iHeight     := FIODriver.GetSizeY;
  iOldFontMult  := FFontMult;
  iOldMiniScale := FMiniScale;
  FFontMult   := Configuration.GetInteger( 'font_multiplier' );
  FTileMult   := Configuration.GetInteger( 'tile_multiplier' );
  FMiniScale  := Configuration.GetInteger( 'minimap_multiplier' );

  if FFontMult = 0 then
  begin
    if FFontSizeX = 8 then
    begin
      if (iWidth >= 1920) and (iHeight >= 1080)
        then FFontMult := 3
        else FFontMult := 2;
    end
    else
      if (iWidth >= 1600) and (iHeight >= 900)
        then FFontMult := 2
        else FFontMult := 1;
  end;
  if FTileMult  = 0 then
    if (iWidth >= 1050) and (iHeight >= 1050)
      then FTileMult := 2
      else FTileMult := 1;
  if FMiniScale = 0 then
  begin
    FMiniScale := iWidth div 220;
    FMiniScale := Max( 3, FMiniScale );
    FMiniScale := Min( 9, FMiniScale );
  end;

  if aInitialize then Exit;

  if FMiniScale <> iOldMiniScale then
    SetMinimapScale( FMiniScale );

  SpriteMap.Recalculate;
  if Player <> nil then
    SpriteMap.NewShift := SpriteMap.ShiftValue( Player.Position );

  if FFontMult <> iOldFontMult then
  begin
    CalculateConsoleParams;
    TGLConsoleRenderer( FConsole ).SetPositionScale( (FIODriver.GetSizeX - ConsoleSizeX*FFontSizeX*FFontMult) div 2, 0, FLineSpace, FFontMult );
  end;
end;

constructor TDoomGFXIO.Create;
var iCoreData   : TVDataFile;
    iImage      : TImage;
    iFontTexture: TTextureID;
    iFont       : TBitmapFont;
    iStream     : TStream;
    iSDLFlags   : TSDLIOFlags;
    iMode       : TIODisplayMode;
    iFontName   : Ansistring;
    iFontFormat : Ansistring;
    iWidth      : Integer;
    iHeight     : Integer;

begin
  FLastMouseTime := 0;
  FMouseLock     := True;

  FLoading := nil;
  IO := Self;

  FVPadding := 0;
  FFontMult := 1;
  FTileMult := 1;
  FMCursor  := nil;
  FTextures := nil;

  FGPRight.Init();
  FGPLeft.Init();
  FGPCamera := 0.0;

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
  FFullscreen := Configuration.GetBoolean( 'fullscreen' );
  iWidth      := Configuration.GetInteger( 'screen_width' );
  iHeight     := Configuration.GetInteger( 'screen_height' );

  iSDLFlags := [ SDLIO_OpenGL, SDLIO_Gamepad ];
  if FFullscreen then Include( iSDLFlags, SDLIO_Fullscreen );
  FIODriver := TSDLIODriver.Create( iWidth, iHeight, 32, iSDLFlags );

  begin
    Log('Display modes (%d)', [FIODriver.DisplayModes.Size] );
    Log('-------');
    for iMode in FIODriver.DisplayModes do
      Log('%d x %d @%d', [ iMode.Width, iMode.Height, iMode.Refresh ] );
    Log('-------');
  end;

  FTextures  := TTextureManager.Create( Option_Blending );

  if Option_ForceRaw then
  begin
    iFontFormat := ReadFileString( 'data' + DirectorySeparator + CoreModuleID + DirectorySeparator + 'fonts' + DirectorySeparator + 'default' );
  end
  else
  begin
    iCoreData := TVDataFile.Create( DataPath + CoreModuleID + '.wad');
    iCoreData.DKKey := LoveLace;
    iStream := iCoreData.GetFile( 'default', 'fonts' );
    iFontFormat := ReadFileString( iStream, iCoreData.GetFileSize( 'default', 'fonts' ) );
    FreeAndNil( iStream );
  end;

  SScanf( iFontFormat, '%s %d %d %d %d', [@iFontName, @FFontSizeX, @FFontSizeY, @ConsoleSizeX, @ConsoleSizeY ] );

  if Option_ForceRaw then
    iImage := LoadImage( 'data' + DirectorySeparator + CoreModuleID + DirectorySeparator + 'fonts' + DirectorySeparator + iFontName )
  else
  begin
    iStream := iCoreData.GetFile( iFontName, 'fonts' );
    iImage := LoadImage( iStream, iStream.Size );
    FreeAndNil( iStream );
    FreeAndNil( iCoreData );
  end;
  iFontTexture := FTextures.AddImage( iFontName, iImage, Option_Blending );
  FTextures[ iFontTexture ].Image.SubstituteColor( ColorBlack, ColorZero );
  FTextures[ iFontTexture ].Upload;

  iFont := TBitmapFont.CreateFromGrid( iFontTexture, 32, 256-32, 32 );

  FMinimap      := TDoomMinimap.Create;
  RecalculateScaling( True );

  CalculateConsoleParams;
  FConsole := TGLConsoleRenderer.Create( iFont, ConsoleSizeX, ConsoleSizeY, FLineSpace, [VIO_CON_CURSOR, VIO_CON_BGCOLOR, VIO_CON_EXTCOLOR ] );

  TGLConsoleRenderer( FConsole ).SetPositionScale(
    (FIODriver.GetSizeX - ConsoleSizeX*FFontSizeX*FFontMult) div 2,
    0,
    FLineSpace,
    FFontMult
  );
  SpriteMap  := TDoomSpriteMap.Create;
  TSDLIODriver( FIODriver ).ShowMouse( False );
                                                    //RRGGBBAA
  inherited Create;
  FMCursor      := TDoomMouseCursor.Create;

  FQuadSheet := TGLQuadList.Create;
  FTextSheet := TGLQuadList.Create;
  FPostSheet := TGLQuadList.Create;
  FQuadRenderer := TGLQuadRenderer.Create;

  SetMinimapScale( FMiniScale );

  FAnimations := TAnimationManager.Create;
end;

procedure TDoomGFXIO.Reconfigure(aConfig: TLuaConfig);
var iWidth   : Integer;
    iHeight  : Integer;
    iOpacity : Integer;
begin
  iWidth  := Configuration.GetInteger('screen_width');
  iHeight := Configuration.GetInteger('screen_height');
  iOpacity:= Configuration.GetInteger( 'minimap_opacity' );
  FMinimap.SetOpacity( iOpacity );

  if ( ( iWidth > 0 ) and ( iWidth <> FIODriver.GetSizeX ) ) or
     ( ( iHeight > 0 ) and ( iHeight <> FIODriver.GetSizeY ) ) or
     ( Configuration.GetBoolean('fullscreen') <> FFullscreen ) then
  begin
    FFullscreen := Configuration.GetBoolean('fullscreen');
    ResetVideoMode;
  end
  else
    RecalculateScaling( False );
  DeviceChanged;
  TGLConsoleRenderer( FConsole ).HideCursor;

  inherited Reconfigure(aConfig);
end;

destructor TDoomGFXIO.Destroy;
begin
  FreeAndNil( FMCursor );
  FreeAndNil( FQuadSheet );
  FreeAndNil( FTextSheet );
  FreeAndNil( FPostSheet );
  FreeAndNil( FQuadRenderer );

  FreeAndNil( FMinimap );
  FreeAndNil( FAnimations );

  FreeAndNil( SpriteMap );
  FreeAndNil( FTextures );

  inherited Destroy;
end;

procedure TDoomGFXIO.WaitForAnimation;
begin
  inherited WaitForAnimation;
  FAnimations.Clear;
end;

function TDoomGFXIO.AnimationsRunning : Boolean;
begin
  if Doom.State <> DSPlaying then Exit(False);
  Exit( not FAnimations.Finished );
end;

procedure TDoomGFXIO.AnimationWipe;
begin
  FAnimations.Clear;
end;

procedure TDoomGFXIO.Blink( aColor : Byte; aDuration : Word = 100; aDelay : DWord = 0);
begin
  if Setting_Flash then
    FAnimations.AddAnimation( TDoomBlink.Create(aDuration,aDelay,aColor) );
end;

procedure TDoomGFXIO.addScreenShakeAnimation( aDuration : DWord; aDelay : DWord; aStrength : Single );
begin
  if Doom.State <> DSPlaying then Exit;
  if Setting_ScreenShake then
    if not TDoomScreenShake.Update( aDuration, aDelay, aStrength ) then
      FAnimations.addAnimation( TDoomScreenShake.Create( aDuration, aDelay, aStrength ) );
end;

procedure TDoomGFXIO.addMoveAnimation ( aDuration : DWord; aDelay : DWord; aUID : TUID; aFrom, aTo : TCoord2D; aSprite : TSprite; aBeing : Boolean );
begin
  if Doom.State <> DSPlaying then Exit;
  FAnimations.AddAnimation(TDoomMove.Create(aDuration, aDelay, aUID, aFrom, aTo, aSprite, aBeing ));
end;

procedure TDoomGFXIO.addMeleeAnimation ( aDuration : DWord; aDelay : DWord; aUID : TUID; aFrom, aTo : TCoord2D; aSprite : TSprite );
begin
  if Doom.State <> DSPlaying then Exit;
  FAnimations.AddAnimation(TDoomMove.Create(aDuration, aDelay, aUID, aFrom, aTo, aSprite, True, 0.5));
  FAnimations.AddAnimation(TDoomMove.Create(aDuration, aDelay, aUID, aTo, aFrom, aSprite, True, -0.5));
  if Player.UID = aUID then WaitForAnimation;
end;

function TDoomGFXIO.getUIDPosition( aUID : TUID; var aPosition : TVec2i ) : Boolean;
var iAnimation : TAnimation;
begin
  for iAnimation in FAnimations.Animations do
    if ( iAnimation.UID = aUID ) and ( iAnimation.Delay = 0 ) then
      if iAnimation is TDoomMove then
      begin
        aPosition := ( iAnimation as TDoomMove ).LastPosition;
        Exit( True );
      end;
  Exit( False );
end;

procedure TDoomGFXIO.addScreenMoveAnimation(aDuration: DWord; aTo: TCoord2D);
begin
  if Doom.State <> DSPlaying then Exit;
  if not TDoomScreenMove.Update( aDuration, aTo ) then
    FAnimations.addAnimation( TDoomScreenMove.Create( aDuration, aTo ) );
end;

procedure TDoomGFXIO.addCellAnimation( aDuration : DWord; aDelay : DWord; aCoord : TCoord2D; aSprite : TSprite; aValue : Integer );
begin
  if Doom.State <> DSPlaying then Exit;
  FAnimations.addAnimation( TDoomAnimateCell.Create( aDuration, aDelay, aCoord, aSprite, aValue ) );
end;

procedure TDoomGFXIO.addItemAnimation( aDuration : DWord; aDelay : DWord; aItem : TThing; aValue : Integer );
begin
  if Doom.State <> DSPlaying then Exit;
  FAnimations.addAnimation( TDoomAnimateItem.Create( aDuration, aDelay, aItem.UID, aValue ) );
end;

procedure TDoomGFXIO.addKillAnimation( aDuration : DWord; aDelay : DWord; aBeing : TThing );
begin
  if Doom.State <> DSPlaying then Exit;
  if SF_PAINANIM in aBeing.Sprite.Flags then
    FAnimations.addAnimation( TDoomAnimateKill.Create( aDuration, aDelay, aBeing.UID ) );
end;


procedure TDoomGFXIO.addMissileAnimation(aDuration: DWord; aDelay: DWord; aSource,
  aTarget: TCoord2D; aColor: Byte; aPic: Char; aDrawDelay: Word;
  aSprite: TSprite; aRay: Boolean);
begin
  if Doom.State <> DSPlaying then Exit;
  FAnimations.addAnimation(
    TDoomMissile.Create( aDuration, aDelay, aSource,
      aTarget, aDrawDelay, aSprite, aRay ) );
end;

procedure TDoomGFXIO.addMarkAnimation(aDuration: DWord; aDelay: DWord;
  aCoord: TCoord2D; aSprite : TSprite; aColor: Byte; aPic: Char);
begin
  if Doom.State <> DSPlaying then Exit;
  FAnimations.addAnimation( TDoomMark.Create(aDuration, aDelay, aCoord, aSprite ) )
end;

procedure TDoomGFXIO.addSoundAnimation(aDelay: DWord; aPosition: TCoord2D; aSoundID: DWord);
begin
  if Doom.State <> DSPlaying then Exit;
  FAnimations.addAnimation( TDoomSoundEvent.Create( aDelay, aPosition, aSoundID ) )
end;

procedure TDoomGFXIO.ExplosionMark( aCoord : TCoord2D; aColor : Byte; aDuration : DWord; aDelay : DWord );
begin
  FAnimations.AddAnimation( TDoomExplodeMark.Create(aDuration,aDelay,aCoord,aColor) )
end;

procedure TDoomGFXIO.SetTarget( aTarget : TCoord2D; aColor : Byte; aRange : Byte );
begin
  SpriteMap.SetTarget( aTarget, NewColor( aColor ), True )
end;

procedure TDoomGFXIO.SetAutoTarget( aTarget : TCoord2D );
begin
  inherited SetAutoTarget( aTarget );
  SpriteMap.SetAutoTarget( aTarget )
end;

procedure TDoomGFXIO.Focus( aCoord : TCoord2D );
var iDiff     : TCoord2D;
const RangeX = 9;
      RangeY = 7;
begin
  inherited Focus( aCoord );
  if FTargeting and (not FMCursor.Active) and ( aCoord <> Player.Position ) then
  begin
    iDiff := aCoord - Player.Position;
    if iDiff.X > RangeX then iDiff.X -= RangeX else if iDiff.X < -RangeX then iDiff.X += RangeX else iDiff.X := 0;
    if iDiff.Y > RangeY then iDiff.Y -= RangeY else if iDiff.Y < -RangeY then iDiff.Y += RangeY else iDiff.Y := 0;
    if ( iDiff.X <> 0 ) or ( iDiff.Y <> 0 ) then
    begin
      SpriteMap.NewShift := SpriteMap.ShiftValue( Player.Position + iDiff );
    end;
  end;
end;

procedure TDoomGFXIO.FinishTargeting;
begin
  inherited FinishTargeting;
  SpriteMap.NewShift := SpriteMap.ShiftValue( Player.Position );
end;

procedure TDoomGFXIO.Configure( aConfig : TLuaConfig; aReload : Boolean = False );
begin
  inherited Configure( aConfig, aReload );

  FIODriver.RegisterInterrupt( IOKeyCode( VKEY_ENTER, [ VKMOD_ALT ] ), @FullScreenCallback );
  FIODriver.RegisterInterrupt( IOKeyCode( VKEY_F12, [ VKMOD_CTRL ] ), @FullScreenCallback );
  DeviceChanged;
end;

procedure TDoomGFXIO.Update( aMSec : DWord );
var iMousePoint : TIOPoint;
    iMousePos   : TVec2i;
    iMax        : TVec2i;
    iActive     : TVec2i;
    iValue      : TVec2f;
    iSizeY      : DWord;
    iSizeX      : DWord;
    iMinus      : Integer;
    iAbsolute   : TIORect;
    iP1, iP2    : TIOPoint;
    iMouse      : Boolean;
begin
  if not Assigned( FQuadRenderer ) then Exit;

  if FTime - FLastMouseTime > 3000 then
  begin
    FMCursor.Active := False;
    if not isModal then
      FHintOverlay := '';
  end;

  iMouse := Setting_Mouse and (FMCursor <> nil) and (FMCursor.Active) and FIODriver.GetMousePos( iMousePoint );

  if iMouse and (not FMouseLock) and (not isModal) and (Setting_MouseEdgePan) and (FGPCamera = 0.0) then
  begin
    iMousePos := Vec2i( iMousePoint.X, iMousePoint.Y );
    iMax      := Vec2i( FIODriver.GetSizeX, FIODriver.GetSizeY );
    iActive   := Vec2i( iMax.X div 8, iMax.Y div 8 );
    iValue    := Vec2f;
    if iMousePos.X < iActive.X        then iValue.X :=-((iActive.X -        iMousePos.X) / iActive.X);
    if iMousePos.X > iMax.X-iActive.X then iValue.X := ((iActive.X -(iMax.X-iMousePos.X)) /iActive.X);
    if iMousePos.Y < iActive.Y        then iValue.Y :=-((iActive.Y -        iMousePos.Y) / iActive.Y) / 2;
    if iMousePos.Y > iMax.Y-iActive.Y then iValue.Y := ((iActive.Y -(iMax.Y-iMousePos.Y)) /iActive.Y) / 2;

    if (iValue.X <> 0) or (iValue.Y <> 0) then
    begin
      SpriteMap.NewShift := Clamp( SpriteMap.Shift + Ceil( iValue.Scaled( aMSec ) ), SpriteMap.MinShift, SpriteMap.MaxShift );
      FMouseLock :=
        ((SpriteMap.NewShift.X = SpriteMap.MinShift.X) or (SpriteMap.NewShift.X = SpriteMap.MaxShift.X))
     and ((SpriteMap.NewShift.Y = SpriteMap.MinShift.Y) or (SpriteMap.NewShift.Y = SpriteMap.MaxShift.Y));
    end;
  end;

  // Lean mode
  {
  if (not isModal) and (( FGPRight.X <> 0.0 ) or (FGPRight.Y <> 0.0 )) then
  begin
    FGPCamera := Minf( FGPCamera + aMSec * 0.005, Maxf( Abs(FGPRight.X), Abs(FGPRight.Y) ) );
    iActive := SpriteMap.ShiftValue( Player.Position );
    iMax    := Vec2i( FIODriver.GetSizeX div 2, FIODriver.GetSizeX div 2 );
    SpriteMap.NewShift := Clamp( iActive + Round(FGPRight * Vec2f(iMax).Scaled(FGPCamera)) , SpriteMap.MinShift, SpriteMap.MaxShift );
  end
  else if FGPCamera > 0.0 then
  begin
    SpriteMap.NewShift := SpriteMap.ShiftValue( Player.Position );
    FGPCamera := 0.0;
  end;
  }
  // Pan mode
  if (not isModal) and (( FGPRight.X <> 0.0 ) or (FGPRight.Y <> 0.0 )) then
  begin
    SpriteMap.NewShift := Clamp( SpriteMap.Shift + Ceil( FGPRight.Scaled( aMSec ) ), SpriteMap.MinShift, SpriteMap.MaxShift );
  end;

  FAnimations.Update( aMSec );

  iSizeY    := FIODriver.GetSizeY-2*FVPadding;
  iSizeX    := FIODriver.GetSizeX;
  glViewport( 0, FVPadding, iSizeX, iSizeY );

  glEnable( GL_TEXTURE_2D );
  glDisable( GL_DEPTH_TEST );
  glEnable( GL_BLEND );
  glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
  FProjection := GLCreateOrtho( 0, iSizeX, iSizeY, 0, -16384, 16384 );

  if (Doom <> nil) and (Doom.State = DSPlaying) then
  begin
    if FConsoleWindow = nil then
       FConsole.HideCursor;
    //if not UI.AnimationsRunning then SpriteMap.NewShift := SpriteMap.ShiftValue( Player.Position );
    SpriteMap.Update( aMSec, FProjection );
    FAnimations.Draw;
    glEnable( GL_DEPTH_TEST );
    SpriteMap.Draw;
    glDisable( GL_DEPTH_TEST );
  end;

  if FHudEnabled then
  begin
    FMinimap.Render( FQuadSheet );

    iAbsolute := vutil.Rectangle( 1,1,ConsoleSizeX,ConsoleSizeY );
    iP1 := ConsoleCoordToDeviceCoord( iAbsolute.Pos );
    iP2 := ConsoleCoordToDeviceCoord( vutil.Point( iAbsolute.x2+1, iAbsolute.y+2 ) );
    QuadSheet.PushColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.8 ) );

    iMinus := 1;
    if StatusEffect = StatusInvert then
      iMinus := 2;
    iP1 := ConsoleCoordToDeviceCoord( vutil.Point( iAbsolute.x, iAbsolute.y2-iMinus ) );
    iP2 := ConsoleCoordToDeviceCoord( vutil.Point( iAbsolute.x2+1, iAbsolute.y2+2 ) );
    QuadSheet.PushColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.8 ) );
  end;


  FQuadRenderer.Update( FProjection );
  FQuadRenderer.Render( FQuadSheet );
  inherited Update( aMSec );

  if  FTextSheet <> nil             then FQuadRenderer.Render( FTextSheet );
  if (FPostSheet <> nil) and iMouse then FMCursor.Draw( iMousePoint, FLastUpdate, FPostSheet );
  if  FPostSheet <> nil             then FQuadRenderer.Render( FPostSheet );
end;

procedure TDoomGFXIO.ResetVideoMode;
var iSDLFlags   : TSDLIOFlags;
    iWidth      : Integer;
    iHeight     : Integer;
begin
  iSDLFlags := [ SDLIO_OpenGL ];
  iWidth    := Configuration.GetInteger('screen_width');
  iHeight   := Configuration.GetInteger('screen_height');
  if FFullscreen then Include( iSDLFlags, SDLIO_Fullscreen );
  TSDLIODriver(FIODriver).ResetVideoMode( iWidth, iHeight, 32, iSDLFlags );
  RecalculateScaling( True );
  CalculateConsoleParams;
  TGLConsoleRenderer( FConsole ).SetPositionScale( (FIODriver.GetSizeX - ConsoleSizeX*FFontSizeX*FFontMult) div 2, 0, FLineSpace, FFontMult );
  TGLConsoleRenderer( FConsole ).HideCursor;
  SetMinimapScale(FMiniScale);
  DeviceChanged;
  SpriteMap.Recalculate;
  if Player <> nil then
    SpriteMap.NewShift := SpriteMap.ShiftValue( Player.Position );
end;

function TDoomGFXIO.FullScreenCallback ( aEvent : TIOEvent ) : Boolean;
begin
  FFullscreen := not TSDLIODriver(FIODriver).FullScreen;
  ResetVideoMode;
  Exit( True );
end;

procedure TDoomGFXIO.CalculateConsoleParams;
begin
  FLineSpace := Max((FIODriver.GetSizeY - ConsoleSizeY*FFontSizeY*FFontMult - 2*FVPadding) div ConsoleSizeY div FFontMult,0);
end;

function TDoomGFXIO.OnEvent( const iEvent : TIOEvent ) : Boolean;
var iValue : Integer;
begin
  if ( iEvent.EType = VEVENT_PADAXIS ) then
  begin
    iValue := iEvent.PadAxis.Value;
    if iValue > 32000  then iValue := 32000;
    if iValue < -32000 then iValue := -32000;
    if ( iValue < 5000 ) and ( iValue > -5000 ) then iValue := 0;
    case iEvent.PadAxis.Axis of
      VPAD_AXIS_RIGHT_X : FGPRight.X := iValue / 32000;
      VPAD_AXIS_RIGHT_Y : FGPRight.Y := iValue / 32000;
      VPAD_AXIS_LEFT_X  : FGPLeft.X  := iValue / 32000;
      VPAD_AXIS_LEFT_Y  : FGPLeft.Y  := iValue / 32000;
    end;
  end;

  if ( iEvent.EType = VEVENT_PADDEVICE ) then
  begin
    FGPRight.Init();
    FGPLeft.Init();
  end;

  if iEvent.EType in [ VEVENT_MOUSEMOVE, VEVENT_MOUSEDOWN ] then
  begin
    if ( FMCursor <> nil ) then FMCursor.Active := Setting_Mouse;
    FLastMouseTime := FTime;
    FMouseLock     := False;

    if ( iEvent.EType = VEVENT_MOUSEMOVE ) and ( VMB_BUTTON_MIDDLE in iEvent.MouseMove.ButtonState ) then
        if ( Doom.State = DSPlaying ) and ( not isModal ) then
        begin
          SpriteMap.NewShift := Clamp(
            Vec2i(
              SpriteMap.NewShift.X - iEvent.MouseMove.RelPos.X,
              SpriteMap.NewShift.Y - iEvent.MouseMove.RelPos.Y
            )
            , SpriteMap.MinShift, SpriteMap.MaxShift );

          //SDL_WarpMouseInWindow( SDLIO.NativeWindow,
          //  iEvent.MouseMove.Pos.X - iEvent.MouseMove.RelPos.X,
          //  iEvent.MouseMove.Pos.Y - iEvent.MouseMove.RelPos.Y
          //);
          // Immediately remove the synthetic event
          //while ( SDL_PeepEvents( @iDiscardEvent, 1, SDL_GETEVENT, SDL_MOUSEMOTION, SDL_MOUSEMOTION) > 0 ) do;
        end;
  end;
  Exit( inherited OnEvent( iEvent ) )
end;

function TDoomGFXIO.PushLayer(  aLayer : TInterfaceLayer ) : TInterfaceLayer;
begin
  if FMCursor <> nil then
  begin
    if FMCursor.Size = 0 then
      FMCursor.SetTextureID( FTextures.TextureID['cursor'], 32 );
    FMCursor.Active := Setting_Mouse;
  end;
  Result := inherited PushLayer( aLayer );
end;

procedure TDoomGFXIO.UpdateMinimap;
begin
  FMinimap.Redraw;
end;

procedure TDoomGFXIO.SetMinimapScale ( aScale : Byte ) ;
begin
  FMinimap.SetScale( aScale );
  FMinimap.SetPosition( Vec2i(
    FIODriver.GetSizeX - aScale*(MAXX+2) - 10,
    FIODriver.GetSizeY - aScale*(MAXY+2) - ( 10 + FFontMult*20*3 )
  ) );
  FMinimap.Redraw;
end;

procedure TDoomGFXIO.DeviceChanged;
begin
  FUIRoot.DeviceChanged;
  FCellX := (FConsole.GetDeviceArea.Dim.X) div (FConsole.SizeX);
  FCellY := (FConsole.GetDeviceArea.Dim.Y) div (FConsole.SizeY);
end;

function TDoomGFXIO.DeviceCoordToConsoleCoord( aCoord : TIOPoint ) : TIOPoint;
begin
  aCoord := aCoord - FConsole.GetDeviceArea.Pos;
  aCoord.x := ( aCoord.x div FCellX );
  aCoord.y := ( aCoord.y div FCellY );
  Exit( PointUnit + aCoord );
end;

function TDoomGFXIO.ConsoleCoordToDeviceCoord( aCoord : TIOPoint ) : TIOPoint;
begin
  aCoord := aCoord - PointUnit;
  aCoord.x := ( aCoord.x * FCellX );
  aCoord.y := ( aCoord.y * FCellY );
  Exit( FConsole.GetDeviceArea.Pos + aCoord );
end;

procedure TDoomGFXIO.RenderUIBackground( aUL, aBR : TIOPoint; aOpacity : Single = 0.85 );
var iP1,iP2 : TIOPoint;
begin
  iP1 := ConsoleCoordToDeviceCoord( aUL + PointUnit );
  iP2 := ConsoleCoordToDeviceCoord( aBR + PointUnit );
  QuadSheet.PushColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,aOpacity ) );
end;


end.

