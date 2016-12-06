{$INCLUDE doomrl.inc}
unit doomtextures;
interface
uses SysUtils, Classes, vtextures, vimage;

type TTextureID = vtextures.TTextureID;

type TDoomTextures = class( TTextureManager )
  constructor Create;
//  procedure LoadFont( aFont : TStream; aSize : DWord; aMetrics : TStream );
  procedure PrepareTextures;
private
  function GenerateGlow( Shadow : TImage ) : TImage;
end;

var Textures : TDoomTextures = nil;

implementation

uses vmath, vcolor, dfdata;

{ TDoomTextures }

constructor TDoomTextures.Create;
begin
  inherited Create( Option_Blending );
end;

{
procedure TDoomTextures.LoadFont ( aFont : TStream; aSize : DWord; aMetrics : TStream ) ;
begin
  //  GLFonts[1] := TGLBitmapFont.Create( Font, Size, Metrics );
end;
}

procedure TDoomTextures.PrepareTextures;
var iColorKey : TColor;
    iBase     : TImage;

    function SheetInv( aBase : TImage ) : TImage;
    begin
      SheetInv := aBase.Clone;
      SheetInv.LinearSaturation( 0 );
      SheetInv.Invert;
    end;

    function SheetBerserk( aBase : TImage ) : TImage;
    begin
      SheetBerserk := aBase.Clone;
      SheetBerserk.Contrast( 30 );
      SheetBerserk.LinearSaturation( 0 );
      SheetBerserk.LinearSaturation( 1.5,0.1,0.15 );
    end;

    function SheetEnviro( aBase : TImage ) : TImage;
    begin
      SheetEnviro := aBase.Clone;
      SheetEnviro.SimpleSaturation( 0.1 );
      SheetEnviro.Saturation( 0.1, 1.0, 0.1 );
    end;

begin
  Textures[ 'logo' ].Blend := True;
  Textures[ 'background' ].Blend := True;
  iBase     := Textures['spritesheet'].Image;
  iColorKey := iBase.Color[0];
  iBase.SubstituteColor( iColorKey, ColorZero );

  AddImage( 'spritesheet_inv',     SheetInv( iBase ), Option_Blending );
  AddImage( 'spritesheet_berserk', SheetBerserk( iBase ), Option_Blending );
  AddImage( 'spritesheet_enviro',  SheetEnviro( iBase ), Option_Blending );

  AddImage( 'spritesheet_glow',    GenerateGlow( Textures['spritesheet_shadow'].Image ), Option_Blending );

  Upload;
end;

function TDoomTextures.GenerateGlow ( Shadow : TImage ) : TImage;
const GaussSize = 1;
var Glow        : TImage;
    X,Y,P,XX,YY : Integer;
    RX,RY       : Integer;
    Value       : Integer;
begin
  Glow := TImage.Create( Shadow.SizeX, Shadow.SizeY );
  Glow.Fill( ColorZero );
  XX := 1 * 4;
  YY := Glow.SizeX * 4;
  for X := 1 to Glow.SizeX - 2 do
    for Y := 1 to Glow.SizeY - 2 do
    begin
      P  := (Integer(Glow.SizeX)*Y + X) * 4;
      RX := ( Shadow.Data[ P-YY ] - Shadow.Data[ P+YY ] );
      RY := ( Shadow.Data[ P+XX ] - Shadow.Data[ P-XX ] );
      Value := Clamp( Round( 0.1 * Sqrt( RX * RX + RY * RY ) ), 0, 255 );
      Glow.Data[ P   ] := Value;
      Glow.Data[ P+1 ] := Value;
      Glow.Data[ P+2 ] := Value;
      Glow.Data[ P+3 ] := Value;
    end;
  GenerateGlow := Glow.Clone;
  for X := GaussSize to Glow.SizeX - 1 - GaussSize do
    for Y := GaussSize to Glow.SizeY - 1 - GaussSize do
    begin
      Value := 0;
      for RX := -GaussSize to GaussSize do
        for RY := -GaussSize to GaussSize do
          Value += Glow.Data[ (Integer(Glow.SizeX)*(Y+RY) + (X+RX)) * 4 ];
      Value := Clamp( Value div ( GaussSize * GaussSize ), 0, 255 );
      P  := (Integer(Glow.SizeX)*Y + X) * 4;
      GenerateGlow.Data[ P   ] := Value;
      GenerateGlow.Data[ P+1 ] := Value;
      GenerateGlow.Data[ P+2 ] := Value;
      GenerateGlow.Data[ P+3 ] := Value;
    end;
  FreeAndNil( Glow );
end;

end.

