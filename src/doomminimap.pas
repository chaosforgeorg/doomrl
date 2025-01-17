{$INCLUDE doomrl.inc}
unit doomminimap;
interface
uses vrltools, vcolor, vvector, vimage, vglquadrenderer;

type TDoomMinimap = class
  constructor Create;
  procedure Redraw;
  procedure Render( aTarget : TGLQuadList );
  procedure SetScale( aScale : Byte );
  procedure SetOpacity( aOpacity : Byte );
  procedure SetPosition( aPos : TVec2i );
  destructor Destroy; override;
private
  function GetColor ( aCoord : TCoord2D ) : TColor;
private
  FImage   : TImage;
  FTexture : DWord;
  FOpacity : Integer;
  FScale   : Integer;
  FGLPos   : TVec2i;
end;

implementation

uses math, sysutils, viotypes, vglimage, dfdata, dfitem, dfbeing, dfmap, doombase;

constructor TDoomMinimap.Create;
begin
  FOpacity  := 2;
  FScale    := 0;
  FTexture  := 0;
  FGLPos    := TVec2i.Create( 0, 0 );
  FImage    := TImage.Create( 128, 32 );
  FImage.Fill( NewColor( 0,0,0,0 ) );
end;

procedure TDoomMinimap.Redraw;
var x, y : DWord;
begin
  if Doom.State = DSPlaying then
  begin
    for x := 0 to MAXX+1 do
      for y := 0 to MAXY+1 do
        FImage.ColorXY[x,y] := GetColor( NewCoord2D( x, y ) );
    if FTexture = 0
      then FTexture := UploadImage( FImage, False )
      else ReUploadImage( FTexture, FImage, False );
  end;
end;

procedure TDoomMinimap.Render( aTarget : TGLQuadList );
const UnitTex : TVec2f = ( Data : ( 1, 1 ) );
      ZeroTex : TVec2f = ( Data : ( 0, 0 ) );
begin
  aTarget.PushTexturedQuad(
    FGLPos,
    FGLPos + Vec2i( FScale*128, FScale*32 ), ZeroTex, UnitTex, FTexture );
end;

procedure TDoomMinimap.SetScale( aScale : Byte );
begin
  FScale := aScale;
end;

procedure TDoomMinimap.SetOpacity( aOpacity : Byte );
begin
  FOpacity := aOpacity;
  Redraw;
end;

procedure TDoomMinimap.SetPosition( aPos : TVec2i );
begin
  FGLPos := aPos;
end;

destructor TDoomMinimap.Destroy;
begin
  FreeAndNil( FImage );
  inherited Destroy;
end;

function TDoomMinimap.GetColor ( aCoord : TCoord2D ) : TColor;
const DefColor : TColor = ( R : 0; G : 0; B : 0; A : 100 );
var iColor : Byte;
    iItem  : TItem;
    iBeing : TBeing;
    iOMult : Byte;
begin
  with Doom.Level do
  begin
    if not isProperCoord( aCoord ) then Exit( DefColor );
    iOMult := 1;
    iColor := Black;
    iBeing := Being[ aCoord ];
    iItem  := Item[ aCoord ];

    if BeingVisible( aCoord, iBeing ) or BeingExplored( aCoord, iBeing ) or BeingIntuited( aCoord, iBeing ) then
    begin
      iOMult := 2;
      if iBeing.isPlayer
        then iColor := LightGreen
        else iColor := LightRed;
    end
    else if ItemVisible( aCoord, iItem ) or ItemExplored( aCoord, iItem ) then
      iColor := LightBlue
    else if CellExplored( aCoord ) then
    begin
      if not isVisible( aCoord ) then
      begin
        with Cells[ getCell(aCoord) ] do
        if CF_BLOCKMOVE in Flags then
          iColor := DarkGray
        else
        if CF_STAIRS in Flags then
        begin
          iColor := Yellow;
          iOMult := 2;
        end;
      end
      else
        with Cells[ getCell(aCoord) ] do
        if CF_LIQUID in Flags then
          iColor := Blue
        else
        if CF_STAIRS in Flags then
        begin
          iColor := Yellow;
          iOMult := 2;
        end
        else
        if CF_BLOCKMOVE in Flags then
          iColor := LightGray
        else
          iColor := DarkGray;
    end;

    if iColor = Black then
    begin
      Result   := DefColor;
      Result.A := FOpacity * 25;
      Exit;
    end;
    Result := NewColor( iColor );
    Result.A := Min( FOpacity * 50 * iOMult, 250 );
  end;
end;


end.

