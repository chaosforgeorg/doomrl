{$INCLUDE doomrl.inc}
unit doommainmenuview;
interface
uses vutil, vtextures, doomio;

type TMainMenuViewMode = ( MAINMENU_FIRST, MAINMENU_INTRO, MAINMENU_MENU, MAINMENU_DONE );

type TMainMenuView = class( TInterfaceLayer )
  constructor Create( aInitial : TMainMenuViewMode = MAINMENU_FIRST );
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
protected
  procedure Render;
protected
  FMode        : TMainMenuViewMode;
  FSize        : TPoint;
  FFirst       : Ansistring;
  FIntro       : Ansistring;

  FBGTexture   : TTextureID;
  FLogoTexture : TTextureID;
end;

implementation

uses math, sysutils,
     vtig, vimage, vgltypes, vluasystem,
     dfdata,
     doomgfxio;

constructor TMainMenuView.Create( aInitial : TMainMenuViewMode = MAINMENU_FIRST );
var iText : Text;
begin
  VTIG_EventClear;
  VTIG_ResetSelect( 'help_view' );

  FSize    := Point( 80, 25 );
  FMode    := aInitial;

  if FMode = MAINMENU_FIRST then
  begin
    if not FileExists( WritePath + 'drl.prc' ) then
    begin
      Assign(iText, WritePath + 'drl.prc');
      Rewrite(iText);
      Writeln(iText,'DRL was already run.');
      Close(iText);

      FFirst := AnsiString( LuaSystem.ProtectedCall( ['DoomRL','first_text'], [] ) );
    end
    else
      FMode := MAINMENU_INTRO;
  end;

  if GraphicsVersion then
  begin
    FBGTexture   := (IO as TDoomGFXIO).Textures.TextureID['background'];
    FLogoTexture := (IO as TDoomGFXIO).Textures.TextureID['logo'];
  end;

  if FMode in [MAINMENU_FIRST,MAINMENU_INTRO] then
    FIntro := AnsiString( LuaSystem.ProtectedCall( ['DoomRL','logo_text'], [] ) );
end;

procedure TMainMenuView.Update( aDTime : Integer );
var iCount  : Integer;
    iString : AnsiString;
begin
  if GraphicsVersion then Render;

  VTIG_Clear;

  if not GraphicsVersion then
    if FMode = MAINMENU_INTRO then
      if IO.Ascii.Exists('logo') then
      begin
        iCount := 0;
        for iString in IO.Ascii['logo'] do
        begin
          VTIG_FreeLabel( iString, Point( 17, iCount ) );
          Inc( iCount );
        end;
      end;

  if FMode = MAINMENU_INTRO then
  begin
    VTIG_FreeLabel( '{rDRL version {R'+VERSION_STRING+'}}', Point( 28, 9 ) );
    VTIG_FreeLabel( '{rby {RKornel Kisielewicz}}', Point( 28, 10 ) );
    VTIG_FreeLabel( '{rgraphics by {RDerek Yu}}', Point( 28, 11 ) );
    VTIG_FreeLabel( '{rand {RLukasz Sliwinski}}', Point( 28, 12 ) );
  end;

  if FMode = MAINMENU_FIRST then
    VTIG_FreeLabel( FFirst, Rectangle(5,2,70,23) );

  if FMode = MAINMENU_INTRO then
    VTIG_FreeLabel( FIntro, Rectangle(2,14,77,11) );

  if VTIG_EventCancel or VTIG_EventConfirm then
  begin
    if FMode = MAINMENU_INTRO then
      FMode := MAINMENU_DONE;
    if FMode = MAINMENU_FIRST then
      FMode := MAINMENU_INTRO;
  end;
end;

procedure TMainMenuView.Render;
var iIO             : TDoomGFXIO;
    iMin, iMax      : TGLVec2f;
    iSize, iSz, iTC : TGLVec2f;
    iImage          : TImage;
begin
  iIO := IO as TDoomGFXIO;
  Assert( iIO <> nil );

  iImage := iIO.Textures.Texture[ FBGTexture ].Image;
  iTC.Init( iImage.RawX / iImage.SizeX, iImage.RawY / iImage.SizeY );
  iSize.Init( IO.Driver.GetSizeX, IO.Driver.GetSizeY );
  iMin.Init( 0,0 );
  iMax := iSize - GLVec2f( 1, 1 );

  if (iImage.RawX / iImage.RawY) > (iSize.X / iSize.Y) then
  begin
    iSz.X  := iImage.RawX * (IO.Driver.GetSizeY / iImage.RawY);
    iMin.X := ( IO.Driver.GetSizeX - iSz.X ) / 2;
    iMax.X := iMin.X + iSz.X;
  end
  else
  begin
    iSz.Y  := iImage.RawY * (IO.Driver.GetSizeX / iImage.RawX);
    iMin.Y := ( IO.Driver.GetSizeY - iSz.Y ) / 2;
    iMax.Y := iMin.Y + iSz.Y;
  end;

  iIO.QuadSheet.PushTexturedQuad(
    GLVec2i(Floor(iMin.X), Floor(iMin.Y)),
    GLVec2i(Floor(iMax.X), Floor(iMax.Y)),
    GLVec2f(0,0),iTC,
    iIO.Textures.Texture[ FBGTexture ].GLTexture
  );

  if FMode = MAINMENU_FIRST then
    IO.RenderUIBackground( Point(4,1), Point(76,24), 0.7 );

  if FMode = MAINMENU_INTRO then
  begin
    iImage := iIO.Textures.Texture[ FLogoTexture ].Image;
    iMin.Y  := Floor(iSize.Y / 25) * (-8);
    if (FMode <> MAINMENU_INTRO)
      then begin iMax.Y  := Floor(iSize.Y / 25) * 24; iMin.Y := Floor(iSize.Y / 25) * (-10); end
      else iMax.Y  := Floor(iSize.Y / 25) * 18;
    iMin.X  := (iSize.X - (iMax.Y - iMin.Y)) / 2;
    iMax.X  := (iSize.X + (iMax.Y - iMin.Y)) / 2;

    iIO.QuadSheet.PushTexturedQuad(
      GLVec2i(Floor(iMin.X), Floor(iMin.Y)),
      GLVec2i(Floor(iMax.X), Floor(iMax.Y)),
      GLVec2f( 0,0 ), GLVec2f( 1,1 ),
      iIO.Textures.Texture[ FLogoTexture ].GLTexture
    );

    if FMode = MAINMENU_INTRO then
    begin
      IO.RenderUIBackground( Point(25,9), Point(55,13), 0.7 );
      IO.RenderUIBackground( Point(1,14), Point(79,25), 0.7 );
    end;

  end;

end;


function TMainMenuView.IsFinished : Boolean;
begin
  Exit( FMode = MAINMENU_DONE );
end;

function TMainMenuView.IsModal : Boolean;
begin
  Exit( True );
end;

end.

