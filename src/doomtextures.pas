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
begin
  Textures[ 'logo' ].Blend := True;
  Textures[ 'background' ].Blend := True;
  Textures[ 'lut_clear' ].Blend := True;
  Textures[ 'lut_iddqd' ].Blend := True;
  Textures[ 'lut_enviro' ].Blend := True;
  Textures[ 'lut_berserk' ].Blend := True;
  Textures[ 'lut_clear' ].Is3D := True;
  Textures[ 'lut_iddqd' ].Is3D := True;
  Textures[ 'lut_enviro' ].Is3D := True;
  Textures[ 'lut_berserk' ].Is3D := True;
  AddImage( 'doomguy_glow',              GenerateGlow( Textures['doomguy_shadow'].Image ), Option_Blending );
  AddImage( 'enemies_glow',              GenerateGlow( Textures['enemies_shadow'].Image ), Option_Blending );
  AddImage( 'enemies_big_glow',          GenerateGlow( Textures['enemies_big_shadow'].Image ), Option_Blending );
  AddImage( 'guns_and_pickups_glow',     GenerateGlow( Textures['guns_and_pickups_shadow'].Image ), Option_Blending );
  AddImage( 'doors_and_decorations_glow',GenerateGlow( Textures['doors_and_decorations_shadow'].Image ), Option_Blending );

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

