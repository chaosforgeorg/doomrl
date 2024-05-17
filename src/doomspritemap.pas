{$INCLUDE doomrl.inc}
unit doomspritemap;
interface
uses Classes, SysUtils,
     vutil, vgltypes, vrltools, vgenerics, vcolor, vglquadrenderer, vglprogram,
     vglfullscreentriangle, vnode, vspriteengine, vtextures, vglframebuffer, dfdata;

// TODO : remove
const SpriteCellRow = 16;

const DRL_Z_FX     = 16000;
      DRL_Z_LAYER  = 1000;
      DRL_Z_LINE   = 10;
      DRL_Z_ZERO   = 0;
      DRL_Z_ENVIRO = DRL_Z_LAYER;
      DRL_Z_DOODAD = DRL_Z_LAYER * 2;
      DRL_Z_ITEMS  = DRL_Z_LAYER * 3;
      DRL_Z_BEINGS = DRL_Z_LAYER * 4;
      DRL_Z_LARGE  = DRL_Z_LAYER * 5;

type TDoomMouseCursor = class( TVObject )
  constructor Create;
  procedure SetTextureID( aTexture : TTextureID; aSize : DWord );
  procedure Draw( x, y : Integer; aTicks : DWord; aTarget : TGLQuadList );
private
  FTextureID : TTextureID;
  FSize      : DWord;
  FActive    : Boolean;
public
  property Active : Boolean read FActive write FActive;
end;

type TCoord2DArray = specialize TGArray< TCoord2D >;

type

{ TDoomSpriteMap }

 TDoomSpriteMap = class( TVObject )
  constructor Create;
  procedure Recalculate;
  procedure Update( aTime : DWord; aProjection : TMatrix44 );
  procedure Draw;
  procedure PrepareTextures;
  procedure ReassignTextures;
  function DevicePointToCoord( aPoint : TPoint ) : TPoint;
  procedure PushSpriteBeing( aX, aY : Integer; const aSprite : TSprite; aLight : Byte );
  procedure PushSpriteFX( aX,aY : Byte; const aSprite : TSprite );
  procedure PushSpriteFXRotated( aX,aY : Integer; const aSprite : TSprite; aRotation : Single );
  procedure PushSpriteTerrain( aX,aY : Byte; const aSprite : TSprite; aZ : Integer; aTSX : Single = 0; aTSY : Single = 0 );
  function ShiftValue( aFocus : TCoord2D ) : TCoord2D;
  procedure SetTarget( aTarget : TCoord2D; aColor : TColor; aDrawPath : Boolean );
  procedure ClearTarget;
  procedure ToggleGrid;
  function GetCellShift(cell: TCoord2D): Byte;
  destructor Destroy; override;
private
  FGridActive     : Boolean;
  FMaxShift       : TPoint;
  FMinShift       : TPoint;
  FFluidX         : Single;
  FFluidY         : Single;
  FTileSize       : Word;
  FFluidTime      : Double;
  FTargeting      : Boolean;
  FTarget         : TCoord2D;
  FTargetList     : TCoord2DArray;
  FTargetColor    : TColor;
  FNewShift       : TCoord2D;
  FShift          : TCoord2D;
  FLastCoord      : TCoord2D;
  FSpriteEngine   : TSpriteEngine;
  FTexturesLoaded : Boolean;
  FLightMap       : array[0..MAXX] of array[0..MAXY] of Byte;
  FCellCodeBase   : array[0..15] of Byte;
  FFramebuffer    : TGLFramebuffer;
  FPostProgram    : TGLProgram;
  FFullscreen     : TGLFullscreenTriangle;
  FLutTexture     : Cardinal;
private
  procedure ApplyEffect;
  procedure UpdateLightMap;
  procedure PushTerrain;
  procedure PushObjects;
  procedure PushSprite( aX, aY : Integer; const aSprite : TSprite; aLight : Byte; aLayer : Byte; aZ : Integer );
  function VariableLight( aWhere : TCoord2D ) : Byte;
public
  property Loaded : Boolean read FTexturesLoaded;
  property MaxShift : TPoint read FMaxShift;
  property MinShift : TPoint read FMinShift;

  property TileSize : Word read FTileSize;
  property Shift : TCoord2D read FShift;
  property NewShift : TCoord2D write FNewShift;
end;

var SpriteMap : TDoomSpriteMap = nil;

implementation

uses math, vmath, viotypes, vvision, vgl3library,
     doomtextures, doomio, doombase,
     dfoutput, dfmap, dfitem, dfbeing, dfplayer;

function ColorToGL( aColor : TColor ) : TGLVec3b;
begin
  ColorToGL.X := aColor.R;
  ColorToGL.Y := aColor.G;
  ColorToGL.Z := aColor.B;
end;

{ TDoomMouseCursor }

constructor TDoomMouseCursor.Create;
begin
  inherited Create;
  FActive := True;
  FSize   := 0;
end;

procedure TDoomMouseCursor.SetTextureID ( aTexture : TTextureID; aSize : DWord ) ;
begin
  FTextureID := aTexture;
  FSize      := aSize;
end;

procedure TDoomMouseCursor.Draw ( x, y : Integer; aTicks : DWord; aTarget : TGLQuadList ) ;
var iColor : TGLVec4f;
begin
  if ( FSize = 0 ) or ( not FActive ) then Exit;

  iColor.Init( 1.0, ( Sin( aTicks / 100 ) + 1.0 ) / 2 , 0.1, 1.0 );
  aTarget.PushTexturedQuad(
    TGLVec2i.Create(x,y),
    TGLVec2i.Create(x+FSize,y+FSize),
    iColor,
    TGLVec2f.Create(0,0), TGLVec2f.Create(1,1),
    Textures[ FTextureID ].GLTexture
    );
end;


const
VCleanVertexShader : Ansistring =
'#version 330 core'+#10+
'layout (location = 0) in vec2 position;'+#10+
#10+
'void main() {'+#10+
'gl_Position = vec4(position.x, position.y, 0.0, 1.0);'+#10+
'}'+#10;
VPostFragmentShader : Ansistring =
'#version 330 core'+#10+
'uniform sampler2D utexture;'+#10+
'uniform sampler3D ulut;'+#10+
'uniform vec2 screen_size;'+#10+
'out vec4 frag_color;'+#10+
#10+
'void main() {'+#10+
'vec2 uv    = gl_FragCoord.xy / screen_size;'+#10+
'frag_color = texture( ulut, texture(utexture, uv).xyz );'+#10+
//'frag_color = texture(utexture, uv);'+#10+
'}'+#10;

{ TDoomSpriteMap }

constructor TDoomSpriteMap.Create;
var iCellRow : Byte;
begin
  FTargeting := False;
  FTargetList := TCoord2DArray.Create();
  FFluidTime := 0;
  FLutTexture := 0;
  FTarget.Create(0,0);
  FTexturesLoaded := False;
  FSpriteEngine := TSpriteEngine.Create;
  FGridActive     := False;
  FLastCoord.Create(0,0);

  FFramebuffer  := TGLFramebuffer.Create( IO.Driver.GetSizeX, IO.Driver.GetSizeY );
  FPostProgram  := TGLProgram.Create(VCleanVertexShader, VPostFragmentShader);
  FFullscreen   := TGLFullscreenTriangle.Create;

  Recalculate;

  iCellRow := SpriteCellRow;

  FCellCodeBase[0      ] := 3*iCellRow+  iCellRow+2; // missing!
  FCellCodeBase[1      ] := 3*iCellRow+  iCellRow+2;
  FCellCodeBase[  2    ] := 3*iCellRow+4*iCellRow+2;
  FCellCodeBase[1+2    ] := 3*iCellRow+3*iCellRow+2;
  FCellCodeBase[    4  ] := 3*iCellRow+4*iCellRow+0;
  FCellCodeBase[1+  4  ] := 3*iCellRow+3*iCellRow+0;
  FCellCodeBase[  2+4  ] := 3*iCellRow+          1;
  FCellCodeBase[1+2+4  ] := 3*iCellRow+2*iCellRow+1;

  FCellCodeBase[      8] := 3*iCellRow+  iCellRow+1;
  FCellCodeBase[1    +8] := 3*iCellRow+  iCellRow  ;
  FCellCodeBase[  2  +8] := 3*iCellRow+          2;
  FCellCodeBase[1+2  +8] := 3*iCellRow+2*iCellRow+2;
  FCellCodeBase[    4+8] := 3*iCellRow+          0;
  FCellCodeBase[1+  4+8] := 3*iCellRow+2*iCellRow+0;
  FCellCodeBase[  2+4+8] := 3*iCellRow+3*iCellRow+1;
  FCellCodeBase[1+2+4+8] := 3*iCellRow+4*iCellRow+1;
end;

procedure TDoomSpriteMap.Recalculate;
begin
  FTileSize := 32 * IO.TileMult;
  FSpriteEngine.FGrid.Init(FTileSize,FTileSize);
  FMinShift := Point(0,0);
  FMaxShift := Point(Max(FTileSize*MAXX-IO.Driver.GetSizeX,0),Max(FTileSize*MAXY-IO.Driver.GetSizeY,0));

  if IO.Driver.GetSizeY > 20*FTileSize then
  begin
    FMinShift.Y := -( IO.Driver.GetSizeY - 20*FTileSize ) div 2;
    FMaxShift.Y := FMinShift.Y;
  end
  else
  begin
    FMinShift.Y -= 18*IO.FontMult*2;
    FMaxShift.Y += 18*IO.FontMult*3;
  end;
  FFramebuffer.Resize( IO.Driver.GetSizeX, IO.Driver.GetSizeY );

  FPostProgram.Bind;
    FPostProgram.SetUniformi( 'utexture', 0 );
    FPostProgram.SetUniformi( 'ulut', 1 );
    FPostProgram.SetUniformf( 'screen_size', IO.Driver.GetSizeX, IO.Driver.GetSizeY );
  FPostProgram.UnBind;
end;

procedure TDoomSpriteMap.Update ( aTime : DWord; aProjection : TMatrix44 ) ;
begin
  FShift := FNewShift;
  FFluidTime += aTime*0.0001;
  FFluidX := 1-(FFluidTime - Floor( FFluidTime ));
  FFluidY := (FFluidTime - Floor( FFluidTime ));
  ApplyEffect;
  UpdateLightMap;
  FSpriteEngine.Update( aProjection );
  PushTerrain;
  PushObjects;
end;

procedure TDoomSpriteMap.Draw;
var iPoint   : TPoint;
    iCoord   : TCoord2D;
const TargetSprite : TSprite = (
  Large    : False;
  Overlay  : False;
  CosColor : True;
  Glow     : False;
  Color    : (R:0;G:0;B:0;A:255);
  GlowColor: (R:0;G:0;B:0;A:0);
  SpriteID : HARDSPRITE_SELECT;
);

begin
  FSpriteEngine.FPos.X := FShift.X;
  FSpriteEngine.FPos.Y := FShift.Y;

  if IO.MCursor.Active and IO.Driver.GetMousePos( iPoint ) then
  begin
    iPoint := DevicePointToCoord( iPoint );
    iCoord := NewCoord2D(iPoint.X,iPoint.Y);
    if Doom.Level.isProperCoord( iCoord ) then
    begin
      if (FLastCoord <> iCoord) and (not UI.AnimationsRunning) then
      begin
        UI.SetTempHint(UI.GetLookDescription(iCoord));
        FLastCoord := iCoord;
      end;

      TargetSprite.Color := ColorBlack;
      if Doom.Level.isVisible( iCoord ) then
        TargetSprite.Color.G := Floor(100*(Sin( FFluidTime*50 )+1)+50)
      else
        TargetSprite.Color.R := Floor(100*(Sin( FFluidTime*50 )+1)+50);
      SpriteMap.PushSpriteFX( iPoint.X, iPoint.Y, TargetSprite );
    end;
  end;

  if FLutTexture <> 0 then
  begin
    FFramebuffer.BindAndClear;
    FSpriteEngine.Draw;
    FFramebuffer.UnBind;

    FPostProgram.Bind;
      glActiveTexture( GL_TEXTURE0 );
      glBindTexture( GL_TEXTURE_2D, FFramebuffer.GetTextureID );
      glActiveTexture( GL_TEXTURE1 );
      glBindTexture( GL_TEXTURE_3D, FLutTexture );

      FFullscreen.Render;

      glActiveTexture( GL_TEXTURE0 );
      glBindTexture( GL_TEXTURE_2D, 0 );
      glActiveTexture( GL_TEXTURE1 );
      glBindTexture( GL_TEXTURE_3D, 0 );
    FPostProgram.UnBind;
  end
  else
    FSpriteEngine.Draw;
end;

procedure TDoomSpriteMap.PrepareTextures;
begin
  if FTexturesLoaded then Exit;
  FTexturesLoaded := True;

  Textures.PrepareTextures;

  with FSpriteEngine do
  begin
    FOldLayers[ 1 ] := TSpriteDataSet.Create( FSpriteEngine, true, false, 16, 32 );
    FOldLayers[ 2 ] := TSpriteDataSet.Create( FSpriteEngine, true, true, 16, 32 );
    FOldLayers[ 3 ] := TSpriteDataSet.Create( FSpriteEngine, true, true, 16, 32 );
    FOldLayers[ 4 ] := TSpriteDataSet.Create( FSpriteEngine, true, true, 16, 32 );
    FOldLayerCount := 4;
  end;

  with FSpriteEngine do
  begin
    FLayers[ DRL_SPRITESHEET_ENVIRO ] := TSpriteDataSet.Create( FSpriteEngine, true,  false, DRL_SENVIRO_COLS, 36 );
    FLayers[ DRL_SPRITESHEET_DOODAD ] := TSpriteDataSet.Create( FSpriteEngine, true,  true,  DRL_SDOODAD_COLS, 9 );
    FLayers[ DRL_SPRITESHEET_ITEMS  ] := TSpriteDataSet.Create( FSpriteEngine, true,  true,  DRL_SITEMS_COLS, 5 );
    FLayers[ DRL_SPRITESHEET_BEINGS ] := TSpriteDataSet.Create( FSpriteEngine, false, true,  DRL_SBEINGS_COLS, 3 );
    FLayers[ DRL_SPRITESHEET_PLAYER ] := TSpriteDataSet.Create( FSpriteEngine, true,  true,  DRL_SPLAYER_COLS, 2 );
    FLayers[ DRL_SPRITESHEET_LARGE  ] := TSpriteDataSet.Create( FSpriteEngine, false, true,  DRL_SLARGE_COLS, 6 );
    FLayers[ DRL_SPRITESHEET_FX     ] := TSpriteDataSet.Create( FSpriteEngine, true,  true,  DRL_SFX_COLS, 2 );
    FLayerCount := 7;
  end;

  ReassignTextures;
end;

procedure TDoomSpriteMap.ReassignTextures;
var iCosColor : DWord;
    iGlow     : DWord;
    iSheet    : DWord;
begin
  iSheet    := Textures.Textures['spritesheet'].GLTexture;
  iCosColor := Textures.Textures['spritesheet_color'].GLTexture;
  iGlow     := Textures.Textures['spritesheet_glow'].GLTexture;

  with FSpriteEngine do
  begin
    FOldTextureSet.Layer[ 1 ].Normal  := iSheet;
    FOldTextureSet.Layer[ 1 ].Cosplay := iCosColor;
    FOldTextureSet.Layer[ 2 ].Normal  := iSheet;
    FOldTextureSet.Layer[ 2 ].Cosplay := iCosColor;
    FOldTextureSet.Layer[ 2 ].Glow    := iGlow;
    FOldTextureSet.Layer[ 3 ] := FOldTextureSet.Layer[ 2 ];
    FOldTextureSet.Layer[ 4 ] := FOldTextureSet.Layer[ 2 ];
  end;

  with FSpriteEngine do
  begin
    FTextureSet.Layer[ DRL_SPRITESHEET_ENVIRO ].Normal  := Textures.Textures['levels'].GLTexture;
    FTextureSet.Layer[ DRL_SPRITESHEET_ENVIRO ].Cosplay := Textures.Textures['levels_mask'].GLTexture;

    FTextureSet.Layer[ DRL_SPRITESHEET_DOODAD ].Normal  := Textures.Textures['doors_and_decorations'].GLTexture;
    FTextureSet.Layer[ DRL_SPRITESHEET_DOODAD ].Cosplay := Textures.Textures['doors_and_decorations_mask'].GLTexture;
    FTextureSet.Layer[ DRL_SPRITESHEET_DOODAD ].Glow    := Textures.Textures['doors_and_decorations_glow'].GLTexture;

    FTextureSet.Layer[ DRL_SPRITESHEET_ITEMS ].Normal   := Textures.Textures['guns_and_pickups'].GLTexture;
    FTextureSet.Layer[ DRL_SPRITESHEET_ITEMS ].Cosplay  := Textures.Textures['guns_and_pickups_mask'].GLTexture;
    FTextureSet.Layer[ DRL_SPRITESHEET_ITEMS ].Glow     := Textures.Textures['guns_and_pickups_glow'].GLTexture;

    FTextureSet.Layer[ DRL_SPRITESHEET_BEINGS ].Normal  := Textures.Textures['enemies'].GLTexture;
    //FTextureSet.Layer[ DRL_SPRITESHEET_BEINGS ].Cosplay := Textures.Textures['enemies_mask'].GLTexture;
    FTextureSet.Layer[ DRL_SPRITESHEET_BEINGS ].Glow    := Textures.Textures['enemies_glow'].GLTexture;

    FTextureSet.Layer[ DRL_SPRITESHEET_PLAYER ].Normal  := Textures.Textures['doomguy'].GLTexture;
    FTextureSet.Layer[ DRL_SPRITESHEET_PLAYER ].Cosplay := Textures.Textures['doomguy_mask'].GLTexture;
    FTextureSet.Layer[ DRL_SPRITESHEET_PLAYER ].Glow    := Textures.Textures['doomguy_glow'].GLTexture;

    FTextureSet.Layer[ DRL_SPRITESHEET_LARGE ].Normal   := Textures.Textures['enemies_big'].GLTexture;
    //FTextureSet.Layer[ DRL_SPRITESHEET_LARGE ].Cosplay  := Textures.Textures['enemies_big_mask'].GLTexture;
    FTextureSet.Layer[ DRL_SPRITESHEET_LARGE ].Glow     := Textures.Textures['enemies_big_glow'].GLTexture;

    FTextureSet.Layer[ DRL_SPRITESHEET_FX ].Normal      := Textures.Textures['fx'].GLTexture;
    FTextureSet.Layer[ DRL_SPRITESHEET_FX ].Cosplay     := Textures.Textures['fx_mask'].GLTexture;
  end;

end;

function TDoomSpriteMap.DevicePointToCoord ( aPoint : TPoint ) : TPoint;
begin
  Result.x := Floor((aPoint.x + FShift.X) / FTileSize)+1;
  Result.y := Floor((aPoint.y + FShift.Y) / FTileSize)+1;
end;

procedure TDoomSpriteMap.PushSpriteFXRotated ( aX, aY : Integer;
  const aSprite : TSprite; aRotation : Single ) ;
var iCoord    : TGLRawQCoord;
    iTex      : TGLRawQTexCoord;
    iColor    : TGLRawQColor;
    iTP       : TGLVec2f;
    iSizeH    : Word;
    iLayer    : TSpriteDataSet;
    iSpriteID : DWord;
  function Rotated( pX, pY : Float ) : TGLVec2i;
  begin
    Rotated.x := Round( pX * cos( aRotation ) - pY * sin( aRotation ) + aX );
    Rotated.y := Round( pY * cos( aRotation ) + pX * sin( aRotation ) + aY );
  end;
begin
  iLayer    := FSpriteEngine.FOldLayers[ 4 ];
  iSpriteID := aSprite.SpriteID;
  if iSpriteID >= 100000 then
  begin
    iLayer    := FSpriteEngine.FLayers[ iSpriteID div 100000 ];
    iSpriteID := iSpriteID mod 100000;
  end;

  iSizeH := FTileSize div 2;

  iCoord.Data[ 0 ] := Rotated( -iSizeH, -iSizeH );
  iCoord.Data[ 1 ] := Rotated( -iSizeH, +iSizeH );
  iCoord.Data[ 2 ] := Rotated( +iSizeH, +iSizeH );
  iCoord.Data[ 3 ] := Rotated( +iSizeH, -iSizeH );

  iTP := TGLVec2f.CreateModDiv( (iSpriteID-1), iLayer.Normal.RowSize );

  iTex.init(
    iTP * iLayer.Normal.TexUnit,
    iTP.Shifted(1) * iLayer.Normal.TexUnit
  );

  with iLayer do
  begin
    iColor.FillAll( 255 );
    if aSprite.Overlay then iColor.SetAll( ColorToGL( aSprite.Color ) );
    Normal.Push( @iCoord, @iTex, @iColor, DRL_Z_FX );
    if aSprite.CosColor then
    begin
      iColor.SetAll( ColorToGL( aSprite.Color ) );
      Cosplay.Push( @iCoord, @iTex, @iColor, DRL_Z_FX );
    end;

    if aSprite.Glow then
    begin
      iColor.SetAll( ColorToGL( aSprite.GlowColor ) );
      Glow.Push( @iCoord, @iTex, @iColor, DRL_Z_FX );
    end;
  end;
end;

procedure TDoomSpriteMap.PushSprite( aX, aY : Integer; const aSprite : TSprite; aLight : Byte; aLayer : Byte; aZ : Integer ) ;
var iSize     : Byte;
    ip        : TGLVec2i;
    iLayer    : TSpriteDataSet;
    iSpriteID : DWord;
begin
  iLayer    := FSpriteEngine.FOldLayers[ aLayer ];
  iSpriteID := aSprite.SpriteID;
  if iSpriteID >= 100000 then
  begin
    iLayer    := FSpriteEngine.FLayers[ iSpriteID div 100000 ];
    iSpriteID := iSpriteID mod 100000;
  end;

  iSize := 1;
  if aSprite.Large then
  begin
    iSize := 2;
    aX -= FTileSize div 2;
    aY -= FTileSize;
  end;
  ip := TGLVec2i.Create(aX,aY);
  with iLayer do
  begin
// TODO: facing
    if aSprite.Overlay
      then Normal.PushXY( iSpriteID, iSize, ip, aSprite.Color, aZ )
      else Normal.PushXY( iSpriteID, iSize, ip, NewColor( aLight, aLight, aLight ), aZ );
    if aSprite.CosColor and (Cosplay <> nil) then
      Cosplay.PushXY( iSpriteID, iSize, ip, aSprite.Color, aZ );
    if aSprite.Glow and (Glow <> nil) then
      Glow.PushXY( iSpriteID, iSize, ip, aSprite.GlowColor, aZ );
  end;
end;

procedure TDoomSpriteMap.PushSpriteBeing( aX, aY : Integer; const aSprite : TSprite; aLight : Byte ) ;
var z : Integer;
begin
  z := aY * DRL_Z_LINE;
  if aSprite.Large then
    z += DRL_Z_LARGE
  else
    z += DRL_Z_BEINGS;
  PushSprite( aX, aY, aSprite, aLight, 3, z );
end;

procedure TDoomSpriteMap.PushSpriteFX( aX, aY : Byte; const aSprite : TSprite ) ;
begin
  PushSprite( (aX-1) * FTileSize, (aY-1) * FTileSize, aSprite, 255, 4, DRL_Z_FX );
end;

procedure TDoomSpriteMap.PushSpriteTerrain( aX, aY : Byte; const aSprite : TSprite; aZ : Integer; aTSX : Single; aTSY : Single ) ;
var i, iSize  : Byte;
    iColors   : TGLRawQColor;
    ip        : TGLVec2i;
    iLayer    : TSpriteDataSet;
    iSpriteID : DWord;
begin
  iLayer    := FSpriteEngine.FOldLayers[ 1 ];
  iSpriteID := aSprite.SpriteID;
  if iSpriteID >= 100000 then
  begin
    iLayer    := FSpriteEngine.FLayers[ iSpriteID div 100000 ];
    iSpriteID := iSpriteID mod 100000;
  end;

  iSize := 1;
  if aSprite.Large then
  begin
    iSize := 2;
    aX -= FTileSize div 2;
    aY -= FTileSize;
  end;

  {$WARNINGS OFF}
  iColors.Data[0] := TGLVec3b.CreateAll( FLightMap[aX-1,aY-1] );
  iColors.Data[1] := TGLVec3b.CreateAll( FLightMap[aX-1,aY  ] );
  iColors.Data[2] := TGLVec3b.CreateAll( FLightMap[aX  ,aY  ] );
  iColors.Data[3] := TGLVec3b.CreateAll( FLightMap[aX  ,aY-1] );
  {$WARNINGS ON}

  ip := TGLVec2i.Create( (aX-1)*FTileSize, (aY-1)*FTileSize );
  with iLayer do
  begin
    Normal.PushXY( iSpriteID, iSize, ip, @iColors, aTSX, aTSY );

    if aSprite.CosColor and (Cosplay <> nil) then
    begin
      for i := 0 to 3 do
      begin
        // TODO : This should be one line!
        iColors.Data[ i ].X := Clamp( Floor( ( aSprite.Color.R / 255 ) * iColors.Data[ i ].X  ), 0, 255 );
        iColors.Data[ i ].Y := Clamp( Floor( ( aSprite.Color.G / 255 ) * iColors.Data[ i ].Y  ), 0, 255 );
        iColors.Data[ i ].Z := Clamp( Floor( ( aSprite.Color.B / 255 ) * iColors.Data[ i ].Z  ), 0, 255 );
      end;
      Cosplay.PushXY( iSpriteID, iSize, ip, @iColors, aTSX, aTSY );
    end;
  end;
end;

function TDoomSpriteMap.ShiftValue ( aFocus : TCoord2D ) : TCoord2D;
begin
  ShiftValue.X := S5Interpolate(FMinShift.X,FMaxShift.X, (aFocus.X-2)/(MAXX-3));
  if FMaxShift.Y - FMinShift.Y > 4*FTileSize then
  begin
    if aFocus.Y < 6 then
      ShiftValue.Y := FMinShift.Y
    else if aFocus.Y > MAXY-6 then
      ShiftValue.Y := FMaxShift.Y
    else
      ShiftValue.Y := S3Interpolate(FMinShift.Y,FMaxShift.Y,(aFocus.Y-6)/(MAXY-12));

  end
  else
    ShiftValue.Y := S3Interpolate(FMinShift.Y,FMaxShift.Y,(aFocus.Y-2)/(MAXY-3));
end;

procedure TDoomSpriteMap.SetTarget ( aTarget : TCoord2D; aColor : TColor; aDrawPath : Boolean ) ;
var iTargetLine : TVisionRay;
    iCurrent    : TCoord2D;
begin
  FTargeting   := True;
  FTarget      := aTarget;
  FTargetColor := aColor;

  FTargetList.Clear;

  if (Player.Position <> FTarget) and (aDrawPath) then
  begin
    iTargetLine.Init( Doom.Level, Player.Position, FTarget );
    repeat
      iTargetLine.Next;
      iCurrent := iTargetLine.GetC;

      if not iTargetLine.Done then
        FTargetList.Push( iCurrent );
    until (iTargetLine.Done) or (iTargetLine.cnt > 30);
  end;
  FTargetList.Push( FTarget );
end;

procedure TDoomSpriteMap.ClearTarget;
begin
  FTargeting := False;
end;

procedure TDoomSpriteMap.ToggleGrid;
begin
  FGridActive     := not FGridActive;
end;

destructor TDoomSpriteMap.Destroy;
begin
  FreeAndNil( FSpriteEngine );
  FreeAndNil( FTargetList );
  FreeAndNil( FFramebuffer );
  FreeAndNil( FPostProgram );
  FreeAndNil( FFullscreen );
  inherited Destroy;
end;

procedure TDoomSpriteMap.ApplyEffect;
begin
  case StatusEffect of
    StatusRed    : FLutTexture := Textures['lut_berserk'].GLTexture;
    StatusGreen  : FLutTexture := Textures['lut_enviro'].GLTexture;
    StatusInvert : FLutTexture := Textures['lut_iddqd'].GLTexture;
    else FLutTexture := 0;
  end;
end;

procedure TDoomSpriteMap.UpdateLightMap;
var Y,X : DWord;
  function Get( X, Y : Byte ) : Byte;
  var c : TCoord2D;
  begin
    c.Create( X, Y );
    if not Doom.Level.isExplored( c ) then Exit( 0 );
    Exit( VariableLight(c) );
  end;

begin
  for X := 0 to MAXX do
    for Y := 0 to MAXY do
      if (X*Y = 0) or (X = MAXX) or (Y = MAXY) then
        FLightMap[X,Y] := 0
      else
      begin
        FLightMap[X,Y] := ( Get(X,Y) + Get(X,Y+1) + Get(X+1,Y) + Get(X+1,Y+1) ) div 4;
      end;
end;

function TDoomSpriteMap.GetCellShift(cell: TCoord2D): Byte;
var Base, CellRow : Byte;
const ExtCode = [ 1+2, 1+4, 2+8, 4+8, 1+2+4, 1+2+8, 1+4+8, 2+4+8, 1+2+4+8 ];
  function StickyCode( Coord : TCoord2D; Res : Byte ) : Byte;
  begin
    if not Doom.Level.isProperCoord( Coord ) then Exit(Res);
    if ((CF_STICKWALL in Cells[Doom.Level.CellBottom[ Coord ]].Flags) or
      ((Doom.Level.CellTop[ Coord ] <> 0) and
      (CF_STICKWALL in Cells[Doom.Level.CellTop[ Coord ]].Flags))) then Exit( Res );
    Exit( 0 );
  end;
begin
  Base :=
    StickyCode( cell.ifInc( 0,-1), 1 ) +
    StickyCode( cell.ifInc(-1, 0), 2 ) +
    StickyCode( cell.ifInc(+1, 0), 4 ) +
    StickyCode( cell.ifInc( 0,+1), 8 );
  CellRow := SpriteCellRow;
  if Base in ExtCode then
  case Base of
    1+2   : if StickyCode( cell.IfInc( -1, -1 ), 1 ) <> 0 then Exit( 2*CellRow+2 );
    1+4   : if StickyCode( cell.IfInc( +1, -1 ), 1 ) <> 0 then Exit( 2*CellRow+0 );
    2+8   : if StickyCode( cell.IfInc( -1, +1 ), 1 ) <> 0 then Exit( 2 );
    4+8   : if StickyCode( cell.IfInc( +1, +1 ), 1 ) <> 0 then Exit( 0 );
    1+2+4 : if (
      ( StickyCode( cell.IfInc( -1, -1 ), 1 ) <> 0 ) and
      ( StickyCode( cell.IfInc( +1, -1 ), 1 ) <> 0 )
      ) then Exit( 2*CellRow+1 );
    1+2+8 : if (
      ( StickyCode( cell.IfInc( -1, -1 ), 1 ) <> 0 ) and
      ( StickyCode( cell.IfInc( -1, +1 ), 1 ) <> 0 )
      ) then Exit( CellRow+2 );
    1+4+8 : if (
      ( StickyCode( cell.IfInc( +1, -1 ), 1 ) <> 0 ) and
      ( StickyCode( cell.IfInc( +1, +1 ), 1 ) <> 0 )
      ) then Exit( CellRow+0 );
    2+4+8 : if (
      ( StickyCode( cell.IfInc( -1, +1 ), 1 ) <> 0 ) and
      ( StickyCode( cell.IfInc( +1, +1 ), 1 ) <> 0 )
      ) then Exit( 1 );
    1+2+4+8 : if (
      ( StickyCode( cell.IfInc( -1, -1 ), 1 ) <> 0 ) and
      ( StickyCode( cell.IfInc( -1, +1 ), 1 ) <> 0 ) and
      ( StickyCode( cell.IfInc( +1, -1 ), 1 ) <> 0 ) and
      ( StickyCode( cell.IfInc( +1, +1 ), 1 ) <> 0 )
      ) then Exit( CellRow+1 );
  end;
  Exit( FCellCodeBase[ Base ] );
end;


procedure TDoomSpriteMap.PushTerrain;
var DMinX, DMaxX : Word;
    Bottom  : Word;
    Z            : Integer;
    Y,X,L        : DWord;
    C            : TCoord2D;
    Spr          : TSprite;
    function Mix( L, C : Byte ) : Byte;
    begin
      Exit( Clamp( Floor( ( L / 255 ) * C ) * 255, 0, 255 ) );
    end;

begin
  DMinX := FShift.X div FTileSize + 1;
  DMaxX := Min(FShift.X div FTileSize + (IO.Driver.GetSizeX div FTileSize + 1),MAXX);

  for Y := 1 to MAXY do
    for X := DMinX to DMaxX do
    begin
      c.Create(X,Y);
      if not Doom.Level.CellExplored(c) then Continue;
      Bottom := Doom.Level.CellBottom[c];
      if Bottom <> 0 then
      begin
        Z   := Y * DRL_Z_LINE;
        Spr := Cells[Bottom].Sprite;
        if CF_MULTISPRITE in Cells[Bottom].Flags then
          Spr.SpriteID += Doom.Level.Rotation[c] - 3*SpriteCellRow;
        if F_GTSHIFT in Cells[Bottom].Flags
          then PushSpriteTerrain( X, Y, Spr, Z, FFluidX, FFluidY )
          else PushSpriteTerrain( X, Y, Spr, Z );
        if (F_GFLUID in Cells[Bottom].Flags) and (Doom.Level.Rotation[c] <> 0) then
        begin
          Spr := Cells[Doom.Level.FFloorCell].Sprite;
          Spr.SpriteID += Doom.Level.Rotation[c];
          PushSpriteTerrain( X, Y, Spr, Z + DRL_Z_ENVIRO );
        end;
        if Doom.Level.LightFlag[ c, LFBLOOD ] and (Cells[Bottom].BloodSprite.SpriteID <> 0) then
        begin
          Spr := Cells[Bottom].BloodSprite;
          L := VariableLight(c);
          if Spr.CosColor then
            Spr.Color := ScaleColor( Spr.Color, Byte(L) );
          PushSprite( (X-1)*FTileSize, (Y-1)*FTileSize, Spr, L, 2, Z + DRL_Z_DOODAD );
        end;
      end;
    end;
end;

procedure TDoomSpriteMap.PushObjects;
var DMinX, DMaxX : Word;
    Y,X,Top,L    : DWord;
    Z            : Integer;
    C            : TCoord2D;
    iBeing       : TBeing;
    iItem        : TItem;
    Spr          : TSprite;
    iColor       : TColor;
begin
  DMinX := FShift.X div FTileSize + 1;
  DMaxX := Min(FShift.X div FTileSize + (IO.Driver.GetSizeX div FTileSize + 1),MAXX);

  for Y := 1 to MAXY do
    for X := DMinX to DMaxX do
    begin
      c.Create(X,Y);
      Z   := Y * DRL_Z_LINE;
      Top     := Doom.Level.CellTop[c];
      if (Top <> 0) and Doom.Level.CellExplored(c) then
      begin
        L := VariableLight(c);
        if CF_STAIRS in Cells[Top].Flags then L := 255;
        Spr := Cells[Top].Sprite;
        if Spr.CosColor then
          Spr.Color := ScaleColor( Spr.Color, Byte(L) );
        PushSprite( (X-1)*FTileSize, (Y-1)*FTileSize, Spr, L, 2, Z + DRL_Z_DOODAD );
      end;

      iItem := Doom.Level.Item[c];
      if Doom.Level.ItemVisible(c, iItem) or Doom.Level.ItemExplored(c, iItem) then
      begin
        if Doom.Level.ItemVisible(c, iItem) then L := 255 else L := 70;
        PushSprite( (X-1)*FTileSize, (Y-1)*FTileSize, iItem.Sprite, L, 2, Z + DRL_Z_ITEMS );
      end;
    end;

  for Y := 1 to MAXY do
    for X := DMinX to DMaxX do
    begin
      c.Create(X,Y);
      Z   := Y * DRL_Z_LINE;
      iBeing := Doom.Level.Being[c];
      if (iBeing <> nil) and (iBeing.AnimCount = 0) then
        if Doom.Level.BeingVisible(c, iBeing) then
          PushSprite( (X-1)*FTileSize, (Y-1)*FTileSize, iBeing.Sprite, 255, 3, Z + DRL_Z_BEINGS )
        else if Doom.Level.BeingExplored(c, iBeing) then
          PushSprite( (X-1)*FTileSize, (Y-1)*FTileSize, iBeing.Sprite, 40, 3, Z + DRL_Z_BEINGS )
        else if Doom.Level.BeingIntuited(c, iBeing) then
          PushSprite( (X-1)*FTileSize, (Y-1)*FTileSize, NewSprite( HARDSPRITE_MARK, NewColor( Magenta ) ), 25, 3, Z + DRL_Z_BEINGS )

    end;

  if FTargeting then
    with FSpriteEngine.FOldLayers[ 3 ] do
    begin
      iColor := NewColor( 0, 128, 0 );
      if FTargetList.Size > 0 then
      for L := 0 to FTargetList.Size-1 do
      begin
        if (not Doom.Level.isVisible( FTargetList[L] )) or
           (not Doom.Level.isEmpty( FTargetList[L], [ EF_NOBLOCK, EF_NOVISION ] )) then
          iColor := NewColor( 128, 0, 0 );
        Cosplay.Push( HARDSPRITE_SELECT, TGLVec2i.Create(FTargetList[L].X, FTargetList[L].Y ), iColor, DRL_Z_FX );
      end;
      if FTargetList.Size > 0 then
        Cosplay.Push( HARDSPRITE_MARK, TGLVec2i.Create( FTarget.X, FTarget.Y ), FTargetColor, DRL_Z_FX );
    end;

  if FGridActive then
  for Y := 1 to MAXY do
    for X := DMinX to DMaxX do
    with FSpriteEngine.FOldLayers[ 4 ] do
    begin
      Normal.Push( HARDSPRITE_GRID, TGLVec2i.Create( X, Y ), NewColor( 50, 50, 50, 50 ), DRL_Z_ITEMS );
    end;

end;

function TDoomSpriteMap.VariableLight(aWhere: TCoord2D): Byte;
begin
  if not Doom.Level.isVisible( aWhere ) then Exit( 70 ); //20
  Exit( Min( 100+Doom.Level.Vision.getLight(aWhere)*20, 255 ) );
end;

end.

