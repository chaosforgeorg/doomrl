{$INCLUDE doomrl.inc}
unit doomtextures;
interface
uses SysUtils, Classes, vtextures, vimage;

type TTextureID = vtextures.TTextureID;

type TDoomTextures = class( TTextureManager )
  constructor Create;
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

