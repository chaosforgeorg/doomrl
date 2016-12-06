{$INCLUDE doomrl.inc}
{
----------------------------------------------------
DFMAP.PAS -- Map data and handling for DownFall
Copyright (c) 2002 by Kornel "Anubis" Kisielewicz
----------------------------------------------------
}
unit dfmap;
interface
uses vutil, vmath, dfdata;

type TCellHook  = (CellHook_OnEnter, CellHook_OnExit, CellHook_OnAct, CellHook_OnDescribe, CellHook_OnDestroy);
     TCellHooks = set of TCellHook;
const CellHooks : array[TCellHook] of string = ('OnEnter', 'OnExit', 'OnAct', 'OnDescribe', 'OnDestroy');

type TMap = object
       d : array[ 1..MaxX, 1..MaxY ] of Byte;
       r : array[ 1..MaxX, 1..MaxY ] of Byte;
     end;

type TCell = class
  PicChr      : Char;
  PicLow      : Char;
  Sprite      : TSprite;
  BloodSprite : TSprite;
  LightColor  : Byte;
  DarkColor   : Byte;
  BloodColor  : Byte;
  Desc        : AnsiString;
  BlDesc      : AnsiString;
  DR          : Byte;
  HP          : Byte;
  Flags       : TFlags;
  Hooks       : TCellHooks;
  bloodto     : AnsiString;
  destroyto   : AnsiString;
  raiseto     : AnsiString;
end;
            

type

{ TCells }

TCells = class
           private
           data     : array of TCell;
           MaxCells : Byte;
           function getCell(Index : Byte) : TCell;
           public
           procedure RegisterCell(cellNum : byte);
           property Cells[Index : Byte] : TCell read getCell; default;
           property Max : Byte read MaxCells;
           destructor Destroy; override;
         end;

var Cells : TCells;

implementation

uses SysUtils, vluasystem, vcolor, vdebug;

procedure TCells.RegisterCell(cellNum: byte);
var ColorID : AnsiString;
    Hook    : TCellHook;
begin
  if cellNum >= High( data ) then
  begin
    SetLength( data, vmath.Max( High( data ) * 2, 100 ) );
    MaxCells := cellNum;
  end;
  if cellNum > MaxCells then MaxCells := cellNum;

  data[cellNum] := TCell.Create;
  with LuaSystem.GetTable(['cells',cellNum]) do
  try
    ColorID := getString('id');
    if IsString('color_id') then ColorID := getString('color_id');
    
    data[ cellNum ].Hooks := [];
    for Hook in TCellHooks do
      if isFunction( CellHooks[ Hook ] ) then
        Include( data[cellNum].Hooks,Hook );

    data[cellNum].PicChr    := getChar('ascii');
    data[cellNum].PicLow    := getChar('asciilow');
    data[cellNum].DarkColor := getInteger('color_dark');
    data[cellNum].LightColor:= getInteger('color');
    data[cellNum].BloodColor:= getInteger('blcolor');
    data[cellNum].Desc      := getString('name');
    data[cellNum].BlDesc    := getString('blname');
    data[cellNum].DR        := getInteger('armor');
    data[cellNum].HP        := getInteger('hp');
    data[cellNum].Flags     := getFlags('flags');
    data[cellNum].bloodto   := getString('bloodto');
    data[cellNum].destroyto := getString('destroyto');
    data[cellNum].raiseto   := getString('raiseto');

    data[cellNum].Sprite.SpriteID := getInteger('sprite');
    data[cellNum].Sprite.CosColor := not isNil( 'coscolor' );
    data[cellNum].Sprite.Glow     := not isNil( 'glow' );
    data[cellNum].Sprite.Overlay  := not isNil( 'overlay' );
    data[cellNum].Sprite.Large    := F_LARGE in data[cellNum].Flags;

    if data[cellNum].Sprite.CosColor then data[cellNum].Sprite.Color := NewColor( GetVec4f('coscolor') );
    if data[cellNum].Sprite.Overlay  then data[cellNum].Sprite.Color := NewColor( GetVec4f('overlay') );
    if data[cellNum].Sprite.Glow     then data[cellNum].Sprite.Color := NewColor( GetVec4f('glow') );

    data[cellNum].BloodSprite.SpriteID := getInteger('blsprite',0);
  finally
    Free;
  end;

  if (not Option_HighASCII) then data[cellNum].PicChr := data[cellNum].PicLow;

  if ColorOverrides.Exists(ColorID+'_light') then
    data[cellNum].LightColor := ColorOverrides[ColorID+'_light'];
  if ColorOverrides.Exists(ColorID+'_dark') then
    data[cellNum].DarkColor:= ColorOverrides[ColorID+'_dark'];
end;

function TCells.getCell( Index : Byte ) : TCell;
begin
  Exit( data[ Index ] );
end;

destructor TCells.Destroy;
var c : TCell;
begin
  for c in data do
    c.Free;
end;


end.
