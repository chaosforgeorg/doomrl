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
  property Size   : DWord   read FSize;
end;

type TCoord2DArray = specialize TGArray< TCoord2D >;

type TSpritePart = ( F, T, B, L, R, TL, TR, BL, BR );
     TSpritePartSet = set of TSpritePart;

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
  procedure PushSpriteDoodad( aX,aY : Byte; const aSprite : TSprite; aLight : Integer = -1 );
  procedure PushSpriteFX( aX,aY : Byte; const aSprite : TSprite );
  procedure PushSpriteFXRotated( aX,aY : Integer; const aSprite : TSprite; aRotation : Single );
  procedure PushSpriteTerrain( aX,aY : Byte; const aSprite : TSprite; aZ : Integer; aTSX : Single = 0; aTSY : Single = 0 );
  function ShiftValue( aFocus : TCoord2D ) : TCoord2D;
  procedure SetTarget( aTarget : TCoord2D; aColor : TColor; aDrawPath : Boolean );
  procedure ClearTarget;
  procedure ToggleGrid;
  function GetCellRotationMask( cell: TCoord2D ): Byte;
  destructor Destroy; override;
private
  FGridActive     : Boolean;
  FMaxShift       : TPoint;
  FMinShift       : TPoint;
  FFluidX         : Single;
  FFluidY         : Single;
  FTileSize       : Word;
  FTimer          : DWord;
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
  FFramebuffer    : TGLFramebuffer;
  FPostProgram    : TGLProgram;
  FFullscreen     : TGLFullscreenTriangle;
  FLutTexture     : Cardinal;
private
  procedure ApplyEffect;
  procedure UpdateLightMap;
  procedure PushTerrain;
  procedure PushObjects;
  procedure PushSprite( aX, aY : Integer; const aSprite : TSprite; aLight : Byte; aZ : Integer );
  procedure PushMultiSpriteTerrain( aX,aY : Byte; const aSprite : TSprite; aZ : Integer; aRotation : Byte );
  procedure PushSpriteTerrainPart( aX,aY : Byte; const aSprite : TSprite; aZ : Integer; aPart : TSpritePart = F );
  function VariableLight( aWhere : TCoord2D ) : Byte;
  function GetSprite( aSprite : TSprite ) : TSprite;
  function GetSprite( aCell, aStyle : Byte ) : TSprite;
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
     doomtextures, doomio, doomgfxio, doombase,
     dfmap, dfitem, dfbeing, dfplayer;

function SpritePartSetFill( aPart : TSpritePart ) : TSpritePartSet;
begin
  case aPart of
    T : Exit( [B] );
    B : Exit( [T] );
    L : Exit( [R] );
    R : Exit( [L] );
    TL: Exit( [B,TR] );
    TR: Exit( [B,TL] );
    BL: Exit( [T,BR] );
    BR: Exit( [T,BL] );
  end;
  Exit( [] );
end;

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
end;

procedure TDoomSpriteMap.Recalculate;
var iIO : TDoomGFXIO;
begin
  iIO := (IO as TDoomGFXIO);
  FTileSize := 32 * iIO.TileMult;
  FSpriteEngine.FGrid.Init(FTileSize,FTileSize);
  FMinShift := Point(0,0);
  FMaxShift := Point(Max(FTileSize*MAXX-iIO.Driver.GetSizeX,0),Max(FTileSize*MAXY-iIO.Driver.GetSizeY,0));

  if IO.Driver.GetSizeY > 20*FTileSize then
  begin
    FMinShift.Y := -( IO.Driver.GetSizeY - 20*FTileSize ) div 2;
    FMaxShift.Y := FMinShift.Y;
  end
  else
  begin
    FMinShift.Y -= 18*iIO.FontMult*2;
    FMaxShift.Y += 18*iIO.FontMult*3;
  end;
  FFramebuffer.Resize( iIO.Driver.GetSizeX, iIO.Driver.GetSizeY );

  FPostProgram.Bind;
    FPostProgram.SetUniformi( 'utexture', 0 );
    FPostProgram.SetUniformi( 'ulut', 1 );
    FPostProgram.SetUniformf( 'screen_size', IO.Driver.GetSizeX, IO.Driver.GetSizeY );
  FPostProgram.UnBind;
end;

procedure TDoomSpriteMap.Update ( aTime : DWord; aProjection : TMatrix44 ) ;
begin
  FShift := FNewShift;
  {$PUSH}
  {$Q-}
  FTimer += aTime;
  {$POP}
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
    iIO      : TDoomGFXIO;
const TargetSprite : TSprite = (
  Color     : (R:0;G:0;B:0;A:255);
  GlowColor : (R:0;G:0;B:0;A:0);
  SpriteID  : HARDSPRITE_SELECT;
  Flags     : [ SF_COSPLAY ];
  Frames    : 0;
  Frametime : 0;
);

begin
  iIO := IO as TDoomGFXIO;
  FSpriteEngine.FPos.X := FShift.X;
  FSpriteEngine.FPos.Y := FShift.Y;

  if iIO.MCursor.Active and iIO.Driver.GetMousePos( iPoint ) then
  begin
    iPoint := DevicePointToCoord( iPoint );
    iCoord := NewCoord2D(iPoint.X,iPoint.Y);
    if Doom.Level.isProperCoord( iCoord ) then
    begin
      if (FLastCoord <> iCoord) and (not IO.AnimationsRunning) then
      begin
        IO.SetTempHint(Doom.Level.GetLookDescription(iCoord));
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
    FLayers[ DRL_SPRITESHEET_ENVIRO ] := TSpriteDataSet.Create( FSpriteEngine, true,  false, DRL_COLS, 36 );
    FLayers[ DRL_SPRITESHEET_DOODAD ] := TSpriteDataSet.Create( FSpriteEngine, true,  true,  DRL_COLS, 9 );
    FLayers[ DRL_SPRITESHEET_ITEMS  ] := TSpriteDataSet.Create( FSpriteEngine, true,  true,  DRL_COLS, 5 );
    FLayers[ DRL_SPRITESHEET_BEINGS ] := TSpriteDataSet.Create( FSpriteEngine, false, true,  DRL_COLS, 6 );
    FLayers[ DRL_SPRITESHEET_PLAYER ] := TSpriteDataSet.Create( FSpriteEngine, true,  true,  DRL_COLS, 2 );
    FLayers[ DRL_SPRITESHEET_LARGE  ] := TSpriteDataSet.Create( FSpriteEngine, false, true,  DRL_COLS, 12 );
    FLayers[ DRL_SPRITESHEET_FX     ] := TSpriteDataSet.Create( FSpriteEngine, true,  true,  DRL_COLS, 2 );
    FLayerCount := 7;
  end;

  ReassignTextures;
end;

procedure TDoomSpriteMap.ReassignTextures;
begin
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
  iLayer    := FSpriteEngine.FLayers[ aSprite.SpriteID div 100000 ];
  iSpriteID := aSprite.SpriteID mod 100000;

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
    if SF_OVERLAY in aSprite.Flags then iColor.SetAll( ColorToGL( aSprite.Color ) );
    Normal.Push( @iCoord, @iTex, @iColor, DRL_Z_FX );
    if SF_COSPLAY in aSprite.Flags then
    begin
      iColor.SetAll( ColorToGL( aSprite.Color ) );
      Cosplay.Push( @iCoord, @iTex, @iColor, DRL_Z_FX );
    end;

    if SF_GLOW in aSprite.Flags then
    begin
      iColor.SetAll( ColorToGL( aSprite.GlowColor ) );
      Glow.Push( @iCoord, @iTex, @iColor, DRL_Z_FX );
    end;
  end;
end;

procedure TDoomSpriteMap.PushSprite( aX, aY : Integer; const aSprite : TSprite; aLight : Byte; aZ : Integer ) ;
var iSize     : Byte;
    ip        : TGLVec2i;
    iLayer    : TSpriteDataSet;
    iSpriteID : DWord;
begin
  iLayer    := FSpriteEngine.FLayers[ aSprite.SpriteID div 100000 ];
  iSpriteID := aSprite.SpriteID mod 100000;

  iSize := 1;
  if SF_LARGE in aSprite.Flags then
  begin
    iSize := 2;
    aX -= FTileSize div 2;
    aY -= FTileSize;
  end;
  ip := TGLVec2i.Create(aX,aY);
  with iLayer do
  begin
// TODO: facing
    if SF_OVERLAY in aSprite.Flags
      then Normal.PushXY( iSpriteID, iSize, ip, aSprite.Color, aZ )
      else Normal.PushXY( iSpriteID, iSize, ip, NewColor( aLight, aLight, aLight ), aZ );
    if ( SF_COSPLAY in aSprite.Flags ) and (Cosplay <> nil) then
      Cosplay.PushXY( iSpriteID, iSize, ip, aSprite.Color, aZ );
    if ( SF_GLOW in aSprite.Flags ) and (Glow <> nil) then
      Glow.PushXY( iSpriteID, iSize, ip, aSprite.GlowColor, aZ );
  end;
end;

procedure TDoomSpriteMap.PushMultiSpriteTerrain( aX,aY : Byte; const aSprite : TSprite; aZ : Integer; aRotation : Byte );
var iSprite   : TSprite;
    iSpriteID : DWord;
    iPart     : TSpritePart;
    iPS       : TSpritePart;
    iParts    : TSpritePartSet;
    iMaskOut  : TSpritePartSet;
  function BaseCase( aMask : Byte ) : DWord;
  begin
    case aMask of
      %00000010 : Exit( aSprite.SpriteID + 1*SpriteCellRow + 2 ); // wall up
      %00001000 : Exit( aSprite.SpriteID + 4*SpriteCellRow + 2 ); // wall left
      %00001010 : Exit( aSprite.SpriteID + 3*SpriteCellRow + 2 ); // wall left up
      %00010000 : Exit( aSprite.SpriteID + 4*SpriteCellRow + 0 ); // wall right
      %00010010 : Exit( aSprite.SpriteID + 3*SpriteCellRow + 0 ); // wall right up
      %00011000 : Exit( aSprite.SpriteID +                 + 1 ); // wall left right
      %00011010 : Exit( aSprite.SpriteID + 2*SpriteCellRow + 1 ); // wall left right up

      %01000000 : Exit( aSprite.SpriteID + 1*SpriteCellRow + 1 ); // wall down
      %01000010 : Exit( aSprite.SpriteID + 1*SpriteCellRow + 0 ); // wall down up
      %01001000 : Exit( aSprite.SpriteID +                 + 2 ); // wall down left
      %01001010 : Exit( aSprite.SpriteID + 2*SpriteCellRow + 2 ); // wall down up left
      %01010000 : Exit( aSprite.SpriteID +                 + 0 ); // wall down right
      %01010010 : Exit( aSprite.SpriteID + 2*SpriteCellRow + 0 ); // wall up down right
      %01011000 : Exit( aSprite.SpriteID + 3*SpriteCellRow + 1 ); // wall down right left
      %01011010 : Exit( aSprite.SpriteID + 4*SpriteCellRow + 1 ); // wall cross

      %00001011 : Exit( aSprite.SpriteID + (-3+2)*SpriteCellRow + 2 ); // wall left+up
      %00010110 : Exit( aSprite.SpriteID + (-3+2)*SpriteCellRow + 0 ); // wall right+up
      %01101000 : Exit( aSprite.SpriteID + (-3  )*SpriteCellRow + 2 ); // wall left+down
      %11010000 : Exit( aSprite.SpriteID + (-3  )*SpriteCellRow + 0 ); // wall right+down

      %00011111 : Exit( aSprite.SpriteID + (-3+2)*SpriteCellRow + 1 ); // wall full up
      %11111000 : Exit( aSprite.SpriteID + (-3  )*SpriteCellRow + 1 ); // wall full down
      %11010110 : Exit( aSprite.SpriteID + (-3+1)*SpriteCellRow + 0 ); // wall full right
      %01101011 : Exit( aSprite.SpriteID + (-3+1)*SpriteCellRow + 2 ); // wall full left
      %11111111 : Exit( aSprite.SpriteID + (-3+1)*SpriteCellRow + 1 ); // wall full
    end;
    Exit( 0 );
  end;
begin
  iSprite := aSprite;
  iSpriteID := BaseCase( aRotation );
  if iSpriteID > 0 then
  begin
    iSprite.SpriteID := iSpriteID;
    PushSpriteTerrain( aX, aY, iSprite, aZ );
    Exit;
  end;
  iSpriteID := 0;
  iPart     := F;
  iParts    := [];
  iMaskOut  := [];
  case aRotation of
    %00000000 :
      begin
        // Special case for column
        iSprite.SpriteID := aSprite.SpriteID + 1*SpriteCellRow + 2;
        PushSpriteTerrainPart( aX, aY, iSprite, aZ, B );
        iSprite.SpriteID := aSprite.SpriteID + 1*SpriteCellRow + 1;
        PushSpriteTerrainPart( aX, aY, iSprite, aZ, T );
        Exit;
      end;
    %01011111 : begin iSpriteID := aSprite.SpriteID + 3 * SpriteCellRow + 1; iPart := B; end;
    %11111010 : begin iSpriteID := aSprite.SpriteID + 2 * SpriteCellRow + 1; iPart := T; end;
    %11011110 : begin iSpriteID := aSprite.SpriteID + 2 * SpriteCellRow + 2; iPart := L; end;
    %01111011 : begin iSpriteID := aSprite.SpriteID + 2 * SpriteCellRow + 0; iPart := R; end;

    %11111110 : begin iSpriteID := aSprite.SpriteID + 4 * SpriteCellRow + 1; iPart := TL; end;
    %11111011 : begin iSpriteID := aSprite.SpriteID + 4 * SpriteCellRow + 1; iPart := TR; end;
    %11011111 : begin iSpriteID := aSprite.SpriteID + 4 * SpriteCellRow + 1; iPart := BL; end;
    %01111111 : begin iSpriteID := aSprite.SpriteID + 4 * SpriteCellRow + 1; iPart := BR; end;

    %01111110 : begin iSpriteID := aSprite.SpriteID + 4 * SpriteCellRow + 1; iParts := [BR,TL]; iMaskOut := [BL,TR]; end;
    %11011011 : begin iSpriteID := aSprite.SpriteID + 4 * SpriteCellRow + 1; iParts := [BL,TR]; iMaskOut := [BR,TL]; end;

    %00011011 : begin iSpriteID := aSprite.SpriteID + 2*SpriteCellRow + 1; iParts := [B,TR]; iMaskOut := [TL]; end; // wall left right up
    %00011110 : begin iSpriteID := aSprite.SpriteID + 2*SpriteCellRow + 1; iParts := [B,TL]; iMaskOut := [TR]; end; // wall left right up

    %01101010 : begin iSpriteID := aSprite.SpriteID + 2*SpriteCellRow + 2; iParts := [R,TL]; iMaskOut := [BL]; end; // wall down up left
    %01001011 : begin iSpriteID := aSprite.SpriteID + 2*SpriteCellRow + 2; iParts := [R,BL]; iMaskOut := [TL]; end; // wall down up left

    %11010010 : begin iSpriteID := aSprite.SpriteID + 2*SpriteCellRow + 0; iParts := [L,TR]; iMaskOut := [BR]; end; // wall up down right
    %01010110 : begin iSpriteID := aSprite.SpriteID + 2*SpriteCellRow + 0; iParts := [L,BR]; iMaskOut := [TR]; end; // wall up down right

    %11011000 : begin iSpriteID := aSprite.SpriteID + 3*SpriteCellRow + 1; iParts := [T,BL]; iMaskOut := [BR]; end; // wall down right left
    %01111000 : begin iSpriteID := aSprite.SpriteID + 3*SpriteCellRow + 1; iParts := [T,BR]; iMaskOut := [BL]; end; // wall down right left

    %01011110 : begin iSpriteID := aSprite.SpriteID + 4 * SpriteCellRow + 1; iParts := [B,TL]; iMaskOut := [TR]; end;
    %01111010 : begin iSpriteID := aSprite.SpriteID + 4 * SpriteCellRow + 1; iParts := [T,BR]; iMaskOut := [BL]; end;
    %01011011 : begin iSpriteID := aSprite.SpriteID + 4 * SpriteCellRow + 1; iParts := [B,TR]; iMaskOut := [TL]; end;
    %11011010 : begin iSpriteID := aSprite.SpriteID + 4 * SpriteCellRow + 1; iParts := [T,BL]; iMaskOut := [BR]; end;
  end;
  if iSpriteID = 0 then Exit;

  iSprite.SpriteID := iSpriteID;
  if iParts = [] then
  begin
    PushSpriteTerrainPart( aX, aY, iSprite, aZ, iPart );
    iMaskOut := SpritePartSetFill( iPart );
  end
  else
  begin
    for iPS in iParts do
      PushSpriteTerrainPart( aX, aY, iSprite, aZ, iPS );
  end;

  iSprite.SpriteID := aSprite.SpriteID + (-3+1)*SpriteCellRow + 1;
  for iPS in iMaskOut do
    PushSpriteTerrainPart( aX, aY, iSprite, aZ, iPS );
  Exit;
end;

procedure TDoomSpriteMap.PushSpriteTerrainPart( aX,aY : Byte; const aSprite : TSprite; aZ : Integer; aPart : TSpritePart = F );
var i         : Byte;
    iColors   : TGLRawQColor;
    iGridF    : TGLVec2f;
    iPosition : TGLVec2i;
    iPa, iPb  : TGLVec2i;
    iLayer    : TSpriteDataSet;
    iSpriteID : DWord;
    iLight    : array[0..3] of Byte;
    iStart    : TGLVec2f;
    iEnd      : TGLVec2f;
    iPStart   : TGLVec2f;
    iPEnd     : TGLVec2f;
  procedure Push( aData : TSpriteDataVTC );
  begin
    aData.PushPart( iSpriteID, iPa, iPb, @iColors, aZ, iStart, iEnd );
  end;

  function BilinearLight( aPos : TGLVec2f ) : Byte;
  var iX1, iX2 : Single;
  begin
    iX1 := ( 1 - aPos.X ) * iLight[0] + aPos.X * iLight[3];
    iX2 := ( 1 - aPos.X ) * iLight[1] + aPos.X * iLight[2];
    Exit( Round( ( 1 - aPos.Y ) * iX1 + aPos.Y * iX2 ) );
  end;
const TOP : Single = 8.0 / 32.0;
begin
  iLayer    := FSpriteEngine.FLayers[ aSprite.SpriteID div 100000 ];
  iSpriteID := aSprite.SpriteID mod 100000;

  iLight[0] := FLightMap[aX-1,aY-1];
  iLight[1] := FLightMap[aX-1,aY  ];
  iLight[2] := FLightMap[aX  ,aY  ];
  iLight[3] := FLightMap[aX  ,aY-1];

  iStart    := TGLVec2f.Create(0,0);
  iEnd      := TGLVec2f.Create(1,1);

  case aPart of
    T : iEnd.Y := TOP;
    B : iStart.Y := TOP;
    L : iEnd.X := 0.5;
    R : iStart.X := 0.5;
    TL : iEnd.Init( 0.5, TOP );
    TR : begin iEnd.Y := TOP; iStart.X := 0.5; end;
    BL : begin iEnd.X := 0.5; iStart.Y := TOP; end;
    BR : iStart.Init( 0.5, TOP );
  end;

  iColors.Data[0] := TGLVec3b.CreateAll( BilinearLight( iStart ) );
  iColors.Data[1] := TGLVec3b.CreateAll(BilinearLight( TGLVec2f.Create( iStart.X, iEnd.Y ) ) );
  iColors.Data[2] := TGLVec3b.CreateAll(BilinearLight( iEnd ) );
  iColors.Data[3] := TGLVec3b.CreateAll(BilinearLight( TGLVec2f.Create( iEnd.X, iStart.Y ) ) );

  iGridF    := TGLVec2f.Create( FSpriteEngine.FGrid.X, FSpriteEngine.FGrid.Y );
  iPosition := TGLVec2i.Create( (aX-1)*FTileSize, (aY-1)*FTileSize );
  iPStart   := iGridF * iStart;
  iPEnd     := iGridF * iEnd;
  iPa       := iPosition + TGLVec2i.Create( Round( iPStart.X ), Round( iPStart.Y ) );
  iPb       := iPosition + TGLVec2i.Create( Round( iPEnd.X ), Round( iPEnd.Y ) );
  with iLayer do
  begin
    Push( Normal );

    if ( SF_COSPLAY in aSprite.Flags ) and (Cosplay <> nil) then
    begin
      for i := 0 to 3 do
      begin
        // TODO : This should be one line!
        iColors.Data[ i ].X := Clamp( Floor( ( aSprite.Color.R / 255 ) * iColors.Data[ i ].X  ), 0, 255 );
        iColors.Data[ i ].Y := Clamp( Floor( ( aSprite.Color.G / 255 ) * iColors.Data[ i ].Y  ), 0, 255 );
        iColors.Data[ i ].Z := Clamp( Floor( ( aSprite.Color.B / 255 ) * iColors.Data[ i ].Z  ), 0, 255 );
      end;
      Push( Cosplay );
    end;
  end;
end;


procedure TDoomSpriteMap.PushSpriteBeing( aX, aY : Integer; const aSprite : TSprite; aLight : Byte ) ;
var z : Integer;
begin
  z := aY * DRL_Z_LINE;
  if SF_LARGE in aSprite.Flags then
    z += DRL_Z_LARGE
  else
    z += DRL_Z_BEINGS;
  PushSprite( aX, aY, aSprite, aLight, z );
end;

procedure TDoomSpriteMap.PushSpriteDoodad( aX,aY : Byte; const aSprite : TSprite; aLight : Integer = -1 );
var iLight  : Byte;
    iSprite : TSprite;
    iZ      : DWord;
begin
  iSprite := GetSprite( aSprite );
  if aLight = -1 then
    iLight := VariableLight( NewCoord2D( aX, aY ) )
  else
    iLight := Byte( aLight );
  if SF_COSPLAY in iSprite.Flags then
    iSprite.Color := ScaleColor( iSprite.Color, Byte(iLight) );
  iZ := aY * DRL_Z_LINE;
  PushSprite( (aX-1)*FTileSize, (aY-1)*FTileSize, iSprite, iLight, iZ + DRL_Z_DOODAD );
end;

procedure TDoomSpriteMap.PushSpriteFX( aX, aY : Byte; const aSprite : TSprite ) ;
begin
  PushSprite( (aX-1) * FTileSize, (aY-1) * FTileSize, aSprite, 255, DRL_Z_FX );
end;

procedure TDoomSpriteMap.PushSpriteTerrain( aX, aY : Byte; const aSprite : TSprite; aZ : Integer; aTSX : Single; aTSY : Single ) ;
var i         : Byte;
    iColors   : TGLRawQColor;
    ip        : TGLVec2i;
    iLayer    : TSpriteDataSet;
    iSpriteID : DWord;
    iLight    : array[0..3] of Byte;
begin
  iLayer    := FSpriteEngine.FLayers[ aSprite.SpriteID div 100000 ];
  iSpriteID := aSprite.SpriteID mod 100000;

  iLight[0] := FLightMap[aX-1,aY-1];
  iLight[1] := FLightMap[aX-1,aY  ];
  iLight[2] := FLightMap[aX  ,aY  ];
  iLight[3] := FLightMap[aX  ,aY-1];

  for i := 0 to 3 do
    iColors.Data[i] := TGLVec3b.CreateAll( iLight[i] );

  ip := TGLVec2i.Create( (aX-1)*FTileSize, (aY-1)*FTileSize );
  with iLayer do
  begin
    Normal.PushXY( iSpriteID, 1, ip, @iColors, aTSX, aTSY, aZ );

    if ( SF_COSPLAY in aSprite.Flags ) and (Cosplay <> nil) then
    begin
      for i := 0 to 3 do
      begin
        // TODO : This should be one line!
        iColors.Data[ i ].X := Clamp( Floor( ( aSprite.Color.R / 255 ) * iColors.Data[ i ].X  ), 0, 255 );
        iColors.Data[ i ].Y := Clamp( Floor( ( aSprite.Color.G / 255 ) * iColors.Data[ i ].Y  ), 0, 255 );
        iColors.Data[ i ].Z := Clamp( Floor( ( aSprite.Color.B / 255 ) * iColors.Data[ i ].Z  ), 0, 255 );
      end;
      Cosplay.PushXY( iSpriteID, 1, ip, @iColors, aTSX, aTSY, aZ );
    end;
  end;
end;

function TDoomSpriteMap.ShiftValue ( aFocus : TCoord2D ) : TCoord2D;
const YFactor = 6;
begin
  ShiftValue.X := S5Interpolate(FMinShift.X,FMaxShift.X, (aFocus.X-2)/(MAXX-3));
  if FMaxShift.Y - FMinShift.Y > 4*FTileSize then
  begin
    if aFocus.Y < YFactor then
      ShiftValue.Y := FMinShift.Y
    else if aFocus.Y > MAXY-YFactor then
      ShiftValue.Y := FMaxShift.Y
    else
      ShiftValue.Y := S3Interpolate(FMinShift.Y,FMaxShift.Y,(aFocus.Y-YFactor)/(MAXY-10));

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

function TDoomSpriteMap.GetCellRotationMask(cell: TCoord2D): Byte;
var iT,iB,iL,iR : Boolean;
  function StickyCode( Coord : TCoord2D ) : Boolean;
  begin
    if not Doom.Level.isProperCoord( Coord ) then Exit(True);
    if ((CF_STICKWALL in Cells[Doom.Level.CellBottom[ Coord ]].Flags) or
      ((Doom.Level.CellTop[ Coord ] <> 0) and
      (CF_STICKWALL in Cells[Doom.Level.CellTop[ Coord ]].Flags))) then Exit( True );
    Exit( False );
  end;
  function AddIf( aBool : Boolean; aValue : Byte ) : Byte;
  begin
    if aBool then Exit( aValue ) else Exit( 0 );
  end;
begin
  iT := StickyCode( cell.ifInc(  0, -1 ) );
  iB := StickyCode( cell.ifInc(  0,  1 ) );
  iL := StickyCode( cell.ifInc( -1,  0 ) );
  iR := StickyCode( cell.ifInc(  1,  0 ) );
  GetCellRotationMask :=
    AddIf( ( iT and iL ) and StickyCode( cell.ifInc( -1,-1) ),  1 ) +
    AddIf( iT, 2 ) +
    AddIf( ( iT and iR ) and StickyCode( cell.ifInc(  1,-1) ),  4 ) +
    AddIf( iL, 8 ) +

    AddIf( iR, 16 ) +
    AddIf( ( iB and iL ) and StickyCode( cell.ifInc( -1,1) ),  32 ) +
    AddIf( iB, 64 ) +
    AddIf( ( iB and iR ) and StickyCode( cell.ifInc(  1,1) ),  128 );
end;

procedure TDoomSpriteMap.PushTerrain;
var DMinX, DMaxX : Word;
    Bottom  : Word;
    Z            : Integer;
    Y,X,L        : DWord;
    C            : TCoord2D;
    Spr          : TSprite;
    iStyle       : Byte;
    iDeco        : Byte;
    iCell        : TCell;

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
        Z      := Y * DRL_Z_LINE;
        iStyle := Doom.Level.CStyle[ c ];
        Spr    := GetSprite( Bottom, iStyle );
        if SF_FLOW in Spr.Flags
          then PushSpriteTerrain( X, Y, Spr, Z, FFluidX, FFluidY )
          else
          begin
            if SF_MULTI in Spr.Flags then
              PushMultiSpriteTerrain( X, Y, Spr, Z, Doom.Level.Rotation[ c ] )
             else
              PushSpriteTerrain( X, Y, Spr, Z );
          end;
        if (SF_FLUID in Spr.Flags) and (Doom.Level.Rotation[c] <> 0) then
        begin
          Spr := GetSprite( Doom.Level.FloorCell, Doom.Level.FloorStyle );
          Spr.SpriteID += Doom.Level.Rotation[c];
          PushSpriteTerrain( X, Y, Spr, Z + DRL_Z_ENVIRO );
        end;
        if Doom.Level.LightFlag[ c, LFBLOOD ] and (Cells[Bottom].BloodSprite.SpriteID <> 0) then
          PushSpriteDoodad( X, Y, Cells[Bottom].BloodSprite );
        iDeco := Doom.Level.Deco[c];
        if iDeco <> 0then
        begin
          iCell := Cells[ Bottom ];
          if iCell.Deco[ iDeco ].SpriteID <> 0 then
          begin
            PushSpriteTerrain( X, Y, iCell.Deco[ iDeco ], Z + DRL_Z_ENVIRO + 1 );
          end;
        end;
        if (SF_FLOOR in Spr.Flags) then
        begin
          Spr := GetSprite( Doom.Level.FloorCell, Doom.Level.FloorStyle );
          PushSpriteTerrain( X, Y, Spr, Z - 1 );
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
      if (Top <> 0) and Doom.Level.CellExplored(c) and ( not Doom.Level.LightFlag[ c, LFANIMATING ] ) then
      begin
        if CF_STAIRS in Cells[Top].Flags then
          PushSpriteDoodad( X, Y, Cells[Top].Sprite[0], 255 )
        else
          PushSpriteDoodad( X, Y, GetSprite( Top, Doom.Level.CStyle[c] ) );
      end;

      iItem := Doom.Level.Item[c];
      if Doom.Level.ItemVisible(c, iItem) or Doom.Level.ItemExplored(c, iItem) then
      begin
        if Doom.Level.ItemVisible(c, iItem) then L := 255 else L := 70;
        PushSprite( (X-1)*FTileSize, (Y-1)*FTileSize, GetSprite( iItem.Sprite ), L, Z + DRL_Z_ITEMS );
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
          PushSprite( (X-1)*FTileSize, (Y-1)*FTileSize, GetSprite( iBeing.Sprite ), 255, Z + DRL_Z_BEINGS )
        else if Doom.Level.BeingExplored(c, iBeing) then
          PushSprite( (X-1)*FTileSize, (Y-1)*FTileSize, GetSprite( iBeing.Sprite ), 40, Z + DRL_Z_BEINGS )
        else if Doom.Level.BeingIntuited(c, iBeing) then
          PushSprite( (X-1)*FTileSize, (Y-1)*FTileSize, NewSprite( HARDSPRITE_MARK, NewColor( Magenta ) ), 25, Z + DRL_Z_BEINGS )

    end;

  if FTargeting then
    with FSpriteEngine.FLayers[ DRL_SPRITESHEET_FX ] do
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
    with FSpriteEngine.FLayers[ DRL_SPRITESHEET_FX ] do
    begin
      Normal.Push( HARDSPRITE_GRID, TGLVec2i.Create( X, Y ), NewColor( 50, 50, 50, 50 ), DRL_Z_ITEMS );
    end;

end;

function TDoomSpriteMap.VariableLight(aWhere: TCoord2D): Byte;
begin
  if not Doom.Level.isVisible( aWhere ) then Exit( 70 ); //20
  Exit( Min( 100+Doom.Level.Vision.getLight(aWhere)*20, 255 ) );
end;

function TDoomSpriteMap.GetSprite( aSprite : TSprite ) : TSprite;
var iFrame : DWord;
begin
  Result := aSprite;
  if Result.Frames > 0 then
  begin
    iFrame := ( ( FTimer div Result.Frametime ) mod Result.Frames );
    if SF_LARGE in Result.Flags then
      Result.SpriteID += DRL_COLS * 2 * iFrame
    else
      Result.SpriteID += DRL_COLS * iFrame;
  end;
end;

function TDoomSpriteMap.GetSprite( aCell, aStyle : Byte ) : TSprite;
var iCell  : TCell;
begin
  iCell   := Cells[ aCell ];
  if iCell.Sprite[ aStyle ].SpriteID <> 0 then
    Exit( iCell.Sprite[ aStyle ] );
  Exit( iCell.Sprite[ 0 ] );
end;

end.

