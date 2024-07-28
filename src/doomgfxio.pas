{$INCLUDE doomrl.inc}
unit doomgfxio;
interface
uses vglquadrenderer, vgltypes, vluaconfig, vioevent, viotypes, vuielement, vimage,
     vrltools, vutil,
     doomio, doomspritemap, doomanimation, dfdata;

type TDoomGFXIO = class( TDoomIO )
    constructor Create; reintroduce;
    procedure Configure( aConfig : TLuaConfig; aReload : Boolean = False ); override;
    procedure Update( aMSec : DWord ); override;
    function RunUILoop( aElement : TUIElement = nil ) : DWord; override;
    function OnEvent( const event : TIOEvent ) : Boolean; override;
    procedure UpdateMinimap;
    destructor Destroy; override;
    function ChooseTarget( aActionName : string; aRange: byte; aLimitRange : Boolean; aTargets: TAutoTarget; aShowLast: Boolean): TCoord2D; override;

    procedure WaitForAnimation; override;
    function AnimationsRunning : Boolean; override;
    procedure Mark( aCoord : TCoord2D; aColor : Byte; aChar : Char; aDuration : DWord; aDelay : DWord = 0 ); override;
    procedure Blink( aColor : Byte; aDuration : Word = 100; aDelay : DWord = 0); override;
    procedure addMoveAnimation( aDuration : DWord; aDelay : DWord; aUID : TUID; aFrom, aTo : TCoord2D; aSprite : TSprite ); override;
    procedure addScreenMoveAnimation( aDuration : DWord; aDelay : DWord; aTo : TCoord2D ); override;
    procedure addCellAnimation( aDuration : DWord; aDelay : DWord; aCoord : TCoord2D; aSprite : TSprite; aValue : Integer ); override;
    procedure addMissileAnimation( aDuration : DWord; aDelay : DWord; aSource, aTarget : TCoord2D; aColor : Byte; aPic : Char; aDrawDelay : Word; aSprite : TSprite; aRay : Boolean = False ); override;
    procedure addMarkAnimation( aDuration : DWord; aDelay : DWord; aCoord : TCoord2D; aColor : Byte; aPic : Char ); override;
    procedure addSoundAnimation( aDelay : DWord; aPosition : TCoord2D; aSoundID : DWord ); override;

    procedure DeviceChanged;
    function DeviceCoordToConsoleCoord( aCoord : TIOPoint ) : TIOPoint; override;
    function ConsoleCoordToDeviceCoord( aCoord : TIOPoint ) : TIOPoint; override;
    procedure RenderUIBackground( aUL, aBR : TIOPoint ); override;
  protected
    procedure ExplosionMark( aCoord : TCoord2D; aColor : Byte; aDuration : DWord; aDelay : DWord ); override;
    procedure SetTarget( aTarget : TCoord2D; aColor : Byte; aRange : Byte ); override;
    function FullScreenCallback( aEvent : TIOEvent ) : Boolean;
    procedure ReuploadTextures;
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
    FFontSizeX   : Byte;
    FFontSizeY   : Byte;

    FSettings   : array [Boolean] of
    record
      Width  : Integer;
      Height : Integer;
      FMult  : Integer;
      TMult  : Integer;
      MiniM  : Integer;
    end;

    FLastMouseTime : QWord;
    FMouseLock     : Boolean;
    FMCursor       : TDoomMouseCursor;

    FMinimapImage   : TImage;
    FMinimapTexture : DWord;
    FMinimapScale   : Integer;
    FMinimapGLPos   : TGLVec2i;

    FAnimations     : TAnimationManager;
  public
    property QuadSheet : TGLQuadList read FQuadSheet;
    property TextSheet : TGLQuadList read FTextSheet;
    property PostSheet : TGLQuadList read FPostSheet;
    property FontMult  : Byte read FFontMult;
    property TileMult  : Byte read FTileMult;
    property MCursor   : TDoomMouseCursor read FMCursor;
  end;

implementation

uses {$IFDEF WINDOWS}windows,{$ENDIF}
     classes, sysutils, math,
     vdebug, vlog, vmath, vdf, vgl3library, vtigstyle,
     vglimage, vsdlio, vbitmapfont, vcolor, vglconsole, vioconsole,
     dfplayer,
     doombase, doomtextures;

const ConsoleSizeX = 80;
      ConsoleSizeY = 25;

constructor TDoomGFXIO.Create;
var iCoreData   : TVDataFile;
    iImage      : TImage;
    iFontTexture: TTextureID;
    iFont       : TBitmapFont;
    iStream     : TStream;
    iFullscreen : Boolean;
    iCurrentWH  : TIOPoint;
    iDoQuery    : Boolean;
    iSDLFlags   : TSDLIOFlags;
    iMode       : TIODisplayMode;
    iFontName   : Ansistring;

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
  FLastMouseTime := 0;
  FMouseLock     := True;

  FLoading := nil;
  IO := Self;

  FVPadding := 0;
  FFontMult := 1;
  FTileMult := 1;
  FMCursor  := nil;
  Textures  := nil;

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

  begin
    Log('Display modes (%d)', [FIODriver.DisplayModes.Size] );
    Log('-------');
    for iMode in FIODriver.DisplayModes do
      Log('%d x %d @%d', [ iMode.Width, iMode.Height, iMode.Refresh ] );
    Log('-------');
  end;

  Textures   := TDoomTextures.Create;

  iFontName := 'font10x18.png';
  FFontSizeX := 10;
  FFontSizeY := 18;
  if GodMode then
    iImage := LoadImage(iFontName)
  else
  begin
    iCoreData := TVDataFile.Create(DataPath+'doomrl.wad');
    iCoreData.DKKey := LoveLace;
    iStream := iCoreData.GetFile( iFontName, 'fonts' );
    iImage := LoadImage( iStream, iStream.Size );
    FreeAndNil( iStream );
    FreeAndNil( iCoreData );
  end;
  iFontTexture := Textures.AddImage( iFontName, iImage, Option_Blending );
  Textures[ iFontTexture ].Image.SubstituteColor( ColorBlack, ColorZero );
  Textures[ iFontTexture ].Upload;

  iFont := TBitmapFont.CreateFromGrid( iFontTexture, 32, 256-32, 32 );
  CalculateConsoleParams;
  FConsole := TGLConsoleRenderer.Create( iFont, ConsoleSizeX, ConsoleSizeY, FLineSpace, [VIO_CON_CURSOR, VIO_CON_BGCOLOR, VIO_CON_EXTCOLOR ] );

  TGLConsoleRenderer( FConsole ).SetPositionScale(
    (FIODriver.GetSizeX - ConsoleSizeX*FFontSizeX*FFontMult) div 2,
    0,
    FLineSpace,
    FFontMult
  );
  SpriteMap  := TDoomSpriteMap.Create;
  FMCursor      := TDoomMouseCursor.Create;
  TSDLIODriver( FIODriver ).ShowMouse( False );
                                                    //RRGGBBAA
  VTIGDefaultStyle.Color[ VTIG_BACKGROUND_COLOR ]          := $10000000;
  VTIGDefaultStyle.Color[ VTIG_SELECTED_BACKGROUND_COLOR ] := $442222FF;

  inherited Create;

  FQuadSheet := TGLQuadList.Create;
  FTextSheet := TGLQuadList.Create;
  FPostSheet := TGLQuadList.Create;
  FQuadRenderer := TGLQuadRenderer.Create;

  FMinimapScale    := 0;
  FMinimapTexture  := 0;
  FMinimapGLPos    := TGLVec2i.Create( 0, 0 );
  FMinimapImage    := TImage.Create( 128, 32 );
  FMinimapImage.Fill( NewColor( 0,0,0,0 ) );

  SetMinimapScale( FMiniScale );

  FAnimations := TAnimationManager.Create;
end;

destructor TDoomGFXIO.Destroy;
begin
  FreeAndNil( FMCursor );
  FreeAndNil( FQuadSheet );
  FreeAndNil( FTextSheet );
  FreeAndNil( FPostSheet );
  FreeAndNil( FQuadRenderer );

  FreeAndNil( FMinimapImage );
  FreeAndNil( FAnimations );

  FreeAndNil( SpriteMap );
  FreeAndNil( Textures );

  inherited Destroy;
end;

function TDoomGFXIO.ChooseTarget( aActionName : string; aRange: byte; aLimitRange : Boolean; aTargets: TAutoTarget; aShowLast: Boolean ): TCoord2D;
begin
  ChooseTarget := inherited ChooseTarget( aActionName, aRange, aLimitRange, aTargets, aShowLast );
  SpriteMap.ClearTarget;
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

procedure TDoomGFXIO.Mark( aCoord: TCoord2D; aColor: Byte; aChar: Char; aDuration: DWord; aDelay: DWord );
begin
  FAnimations.AddAnimation( TDoomMark.Create( aDuration, aDelay, aCoord ) );
end;

procedure TDoomGFXIO.Blink( aColor : Byte; aDuration : Word = 100; aDelay : DWord = 0);
begin
  FAnimations.AddAnimation( TDoomBlink.Create(aDuration,aDelay,aColor) );
end;

procedure TDoomGFXIO.addMoveAnimation ( aDuration : DWord; aDelay : DWord; aUID : TUID; aFrom, aTo : TCoord2D; aSprite : TSprite );
begin
  if Doom.State <> DSPlaying then Exit;
  FAnimations.AddAnimation(TDoomMove.Create(aDuration, aDelay, aUID, aFrom, aTo, aSprite));
end;

procedure TDoomGFXIO.addScreenMoveAnimation(aDuration: DWord; aDelay: DWord; aTo: TCoord2D);
begin
  if Doom.State <> DSPlaying then Exit;
  FAnimations.addAnimation( TDoomScreenMove.Create( aDuration, aDelay, aTo ) );
end;

procedure TDoomGFXIO.addCellAnimation( aDuration : DWord; aDelay : DWord; aCoord : TCoord2D; aSprite : TSprite; aValue : Integer );
begin
  if Doom.State <> DSPlaying then Exit;
  FAnimations.addAnimation( TDoomAnimateCell.Create( aDuration, aDelay, aCoord, aSprite, aValue ) );
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
  aCoord: TCoord2D; aColor: Byte; aPic: Char);
begin
  if Doom.State <> DSPlaying then Exit;
  FAnimations.addAnimation( TDoomMark.Create(aDuration, aDelay, aCoord ) )
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

procedure TDoomGFXIO.Configure( aConfig : TLuaConfig; aReload : Boolean = False );
begin
  inherited Configure( aConfig, aReload );

  FIODriver.RegisterInterrupt( IOKeyCode( VKEY_ENTER, [ VKMOD_ALT ] ), @FullScreenCallback );
  FIODriver.RegisterInterrupt( IOKeyCode( VKEY_F12, [ VKMOD_CTRL ] ), @FullScreenCallback );
  DeviceChanged;
end;

procedure TDoomGFXIO.Update( aMSec : DWord );
const UnitTex : TGLVec2f = ( Data : ( 1, 1 ) );
      ZeroTex : TGLVec2f = ( Data : ( 0, 0 ) );
var iMousePos : TIOPoint;
    iPoint    : TIOPoint;
    iValueX   : Single;
    iValueY   : Single;
    iActiveX  : Integer;
    iActiveY  : Integer;
    iMaxX     : Integer;
    iMaxY     : Integer;
    iShift    : TCoord2D;
    iSizeY    : DWord;
    iSizeX    : DWord;
    iMinus    : Integer;
    iAbsolute : TIORect;
    iP1, iP2  : TIOPoint;
begin
  if not Assigned( FQuadRenderer ) then Exit;

  if (FMCursor.Active) and FIODriver.GetMousePos( iPoint ) and (not FMouseLock) and (not isModal) then
  begin
    iMaxX   := FIODriver.GetSizeX;
    iMaxY   := FIODriver.GetSizeY;
    iValueX := 0;
    iValueY := 0;
    iActiveX := iMaxX div 8;
    iActiveY := iMaxY div 8;
    if iPoint.X < iActiveX       then iValueX := ((iActiveX -       iPoint.X) / iActiveX);
    if iPoint.X > iMaxX-iActiveX then iValueX := ((iActiveX -(iMaxX-iPoint.X)) /iActiveX);
    if iPoint.X < iActiveX then iValueX := -iValueX;
    if iMaxY < MAXY*FTileMult*32 then
    begin
      if iPoint.Y < iActiveY       then iValueY := ((iActiveY -        iPoint.Y) / iActiveY) / 2;
      if iPoint.Y > iMaxY-iActiveY then iValueY := ((iActiveY -(iMaxY-iPoint.Y)) /iActiveY) / 2;
      if iPoint.Y < iActiveY then iValueY := -iValueY;
    end;

    iShift := SpriteMap.Shift;
    if (iValueX <> 0) or (iValueY <> 0) then
    begin
      iShift := NewCoord2D(
        Clamp( SpriteMap.Shift.X + Ceil( iValueX * aMSec ), SpriteMap.MinShift.X, SpriteMap.MaxShift.X ),
        Clamp( SpriteMap.Shift.Y + Ceil( iValueY * aMSec ), SpriteMap.MinShift.Y, SpriteMap.MaxShift.Y )
      );
      SpriteMap.NewShift := iShift;
      FMouseLock :=
        ((iShift.X = SpriteMap.MinShift.X) or (iShift.X = SpriteMap.MaxShift.X))
     and ((iShift.Y = SpriteMap.MinShift.Y) or (iShift.Y = SpriteMap.MaxShift.Y));
    end;
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
    FQuadSheet.PushTexturedQuad(
      FMinimapGLPos,
      FMinimapGLPos + TGLVec2i.Create( FMinimapScale*128, FMinimapScale*32 ),
      ZeroTex, UnitTex, FMinimapTexture );

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

  if FTextSheet <> nil then FQuadRenderer.Render( FTextSheet );
  if (FPostSheet <> nil) and (FMCursor <> nil) and (FMCursor.Active) and FIODriver.GetMousePos(iMousePos) then
  begin
    FMCursor.Draw( iMousePos.X, iMousePos.Y, FLastUpdate, FPostSheet );
  end;
  if FPostSheet <> nil then FQuadRenderer.Render( FPostSheet );
end;

function TDoomGFXIO.FullScreenCallback ( aEvent : TIOEvent ) : Boolean;
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
  TGLConsoleRenderer( FConsole ).SetPositionScale( (FIODriver.GetSizeX - ConsoleSizeX*FFontSizeX*FFontMult) div 2, 0, FLineSpace, FFontMult );
  TGLConsoleRenderer( FConsole ).HideCursor;
  SetMinimapScale(FMiniScale);
  DeviceChanged;
  SpriteMap.Recalculate;
  if Player <> nil then
    SpriteMap.NewShift := SpriteMap.ShiftValue( Player.Position );
  Exit( True );
end;

procedure TDoomGFXIO.ReuploadTextures;
begin
  Textures.Upload;
  SpriteMap.ReassignTextures;
end;

procedure TDoomGFXIO.CalculateConsoleParams;
begin
  FLineSpace := Max((FIODriver.GetSizeY - ConsoleSizeY*FFontSizeY*FFontMult - 2*FVPadding) div ConsoleSizeY div FFontMult,0);
end;

function TDoomGFXIO.OnEvent( const event : TIOEvent ) : Boolean;
begin
  if event.EType in [ VEVENT_MOUSEMOVE, VEVENT_MOUSEDOWN ] then
  begin
    if FMCursor <> nil then FMCursor.Active := True;
    FLastMouseTime := FTime;
    FMouseLock     := False;
  end;
  Exit( inherited OnEvent( event ) )
end;

function TDoomGFXIO.RunUILoop( aElement : TUIElement = nil ) : DWord;
begin
  if FMCursor <> nil then
  begin
    if FMCursor.Size = 0 then
      FMCursor.SetTextureID( Textures.TextureID['cursor'], 32 );
    FMCursor.Active := True;
  end;
  Exit( inherited RunUILoop( aElement ) );
end;

procedure TDoomGFXIO.UpdateMinimap;
var x, y : DWord;
begin
  if Doom.State = DSPlaying then
  begin
    for x := 0 to MAXX+1 do
      for y := 0 to MAXY+1 do
        FMinimapImage.ColorXY[x,y] := Doom.Level.GetMiniMapColor( NewCoord2D( x, y ) );
    if FMinimapTexture = 0
      then FMinimapTexture := UploadImage( FMinimapImage, False )
      else ReUploadImage( FMinimapTexture, FMinimapImage, False );
  end;
end;

procedure TDoomGFXIO.SetMinimapScale ( aScale : Byte ) ;
begin
  FMinimapScale := aScale;
  FMinimapGLPos.Init( FIODriver.GetSizeX - FMinimapScale*(MAXX+2) - 10, FIODriver.GetSizeY - FMinimapScale*(MAXY+2) - ( 10 + FFontMult*20*3 ) );
  UpdateMinimap;
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

procedure TDoomGFXIO.RenderUIBackground( aUL, aBR : TIOPoint );
var iP1,iP2 : TIOPoint;
begin
  iP1 := ConsoleCoordToDeviceCoord( aUL + PointUnit );
  iP2 := ConsoleCoordToDeviceCoord( aBR + PointUnit );
  QuadSheet.PushColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.85 ) );
end;


end.

