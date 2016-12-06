{$INCLUDE doomrl.inc}
{
----------------------------------------------------
DFTHING.PAS -- Basic Thing object for DownFall
Copyright (c) 2002 by Kornel "Anubis" Kisielewicz
----------------------------------------------------
}
unit dfthing;
interface
uses SysUtils, Classes, vluaentitynode, vutil, vrltools, vluatable, dfdata, doomhooks;

type

{ TThing }

TThing = class( TLuaEntityNode )
  constructor Create( const aID : AnsiString );
  constructor CreateFromStream( Stream : TStream ); override;
  procedure playBasicSound(const SoundID : string);
  procedure CallHook( Hook : Byte; const Params : array of Const );
  function CallHookCheck( Hook : Byte; const Params : array of Const ) : Boolean;
  function GetSprite : TSprite; virtual;
  procedure WriteToStream( Stream : TStream ); override;
protected
  procedure LuaLoad( Table : TLuaTable ); virtual;
protected
  FSprite     : TSprite;
  {$TYPEINFO ON}
public
  property Sprite     : TSprite  read FSprite  write FSprite;
end;

implementation

uses typinfo, variants,
     vluasystem, vcolor, vdebug,
     doomlua, doombase, doomio;

constructor TThing.Create( const aID : AnsiString );
begin
  inherited Create( aID );
end;

procedure TThing.LuaLoad(Table: TLuaTable);
var iColorID : AnsiString;
    iRes     : TResistance;
    iResist  : TLuaTable;
begin
  FGylph.ASCII := Table.getChar('ascii');
  FGylph.Color := Table.getInteger('color');
  Name         := Table.getString('name');

  FSprite.SpriteID := Table.getInteger('sprite',0);
  FSprite.CosColor := not Table.isNil( 'coscolor' );
  FSprite.Overlay  := not Table.isNil( 'overlay' );
  FSprite.Glow     := not Table.isNil( 'glow' );
  FSprite.Large    := F_LARGE    in FFlags;

  iColorID := FID;
  if Table.IsString('color_id') then iColorID := Table.getString('color_id');

  if ColorOverrides.Exists(iColorID) then
    FGylph.Color := ColorOverrides[iColorID];

  if FSprite.Overlay  then FSprite.Color     := NewColor( Table.GetVec4f('overlay' ) );
  if FSprite.CosColor then FSprite.Color     := NewColor( Table.GetVec4f('coscolor' ) );
  if FSprite.Glow     then FSprite.GlowColor := NewColor( Table.GetVec4f('glow' ) );
end;

procedure TThing.playBasicSound(const SoundID: string);
begin
  IO.PlaySound( IO.ResolveSoundID( [FID+'.'+SoundID, SoundID] ), FPosition );
end;

procedure TThing.CallHook ( Hook : Byte; const Params : array of const ) ;
begin
  if Hook in FHooks         then LuaSystem.ProtectedRunHook(Self, HookNames[Hook], Params );
  if Hook in ChainedHooks   then
    Doom.Level.CallHook( Hook, ConcatConstArray( [ Self ], Params ) );
end;

function TThing.CallHookCheck ( Hook : Byte; const Params : array of const ) : Boolean;
begin
  if Hook in ChainedHooks then if not Doom.Level.CallHookCheck( Hook, ConcatConstArray( [ Self ], Params ) ) then Exit( False );
  if Hook in FHooks then if not LuaSystem.ProtectedRunHook(Self, HookNames[Hook], Params ) then Exit( False );
  Exit( True );
end;

function TThing.GetSprite: TSprite;
begin
  Exit(FSprite);
end;

procedure TThing.WriteToStream( Stream: TStream );
begin
  inherited WriteToStream( Stream );
  Stream.Write( FSprite,     SizeOf( FSprite ) );
end;

constructor TThing.CreateFromStream( Stream: TStream );
begin
  inherited CreateFromStream( Stream );
  Stream.Read( FSprite,     SizeOf( FSprite ) );
end;

end.
