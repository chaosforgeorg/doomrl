{$INCLUDE doomrl.inc}
{
----------------------------------------------------
DFLEVEL.PAS -- Level data and handling for Downfall
Copyright (c) 2002 by Kornel "Anubis" Kisielewicz
----------------------------------------------------
}
unit dflevel;
interface
uses SysUtils, Classes, vluaentitynode, vutil, vvision, vcolor, vmath, viotypes, vrltools, vnode, vluamapnode, vmaparea,
     dfdata, dfmap, dfthing, dfbeing, dfitem, dfoutput, vconuirl,
     doomhooks;

const CellWalls   : TCellSet = [];
      CellFloors  : TCellSet = [];

type

{ TLevel }

TLevel = class(TLuaMapNode, IConUIASCIIMap)
    LNum        : Word;
    SpecExit    : AnsiString;
    LTime       : DWord;
    Empty       : Boolean;
    DangerLevel : Word;
    ToHitBonus  : ShortInt;
    FFloorCell  : Word;
    FFeeling    : AnsiString;
    constructor Create; reintroduce;
    procedure Init( nStyle : byte; nLNum : Word;nName : string; nSpecExit : string; nDepth : Word; nDangerLevel : Word);
    procedure AfterGeneration( aGenerated : Boolean );
    procedure PreEnter;
    procedure RecalcFluids;
    procedure Leave;
    procedure Clear;
    procedure FullClear;
    procedure Tick;
    procedure NukeTick;
    procedure NukeCell( where : TCoord2D );
     
    function blocksVision( const coord : TCoord2D ) : boolean; override;
	
	{ Determines if the cell is explored by the player. }
	function CellExplored( coord : TCoord2D ) : boolean;
	
	{ Determine if the coord has an item visible to the player. }
	function ItemVisible( coord: TCoord2D; aItem: TItem ) : boolean;
	
	{ Determine if the coord has an item explored by the player. }
    { In console mode, these items are gray; in graphics they are darker. }
	function ItemExplored( coord: TCoord2D; aItem: TItem ) : boolean;
	
	{ Determine if the coord has a being visible to the player. }
	function BeingVisible( coord: TCoord2D; aBeing: TBeing ) : boolean;
	
    { Determine if the coord has a being explored by the player. }
    { In console mode, there is no difference, but in graphics they are darker. }
    function BeingExplored( coord: TCoord2D; aBeing: TBeing ) : boolean;
    
    { Determines if the coord has a being that the player can sense by Intuition. }
    function BeingIntuited( coord: TCoord2D; aBeing: TBeing ) : boolean;
    
    {$IFDEF CORNERMAP}
    function  Corner( coord : TCoord2D ) : boolean;
    {$ENDIF}

    function CallHook( coord : TCoord2D;  Hook : TCellHook ) : Variant; overload;
    function CallHook( coord : TCoord2D; aCellID : Word; Hook : TCellHook ) : Variant; overload;
    function CallHook( coord : TCoord2D; What : TThing; Hook : TCellHook ) : Variant; overload;
    procedure CallHook( Hook : Byte; const Params : array of Const );
    function CallHookCheck( Hook : Byte; const Params : array of Const ) : Boolean;

    procedure DropCorpse( aCoord : TCoord2D; CellID : Byte );
    procedure DamageTile( coord : TCoord2D; dmg : Integer; DamageType : TDamageType );
    procedure Explosion( Sequence : Integer; coord : TCoord2D; Range, Delay : Integer; Damage : TDiceRoll; color : byte; ExplSound : Word; DamageType : TDamageType; aItem : TItem; aFlags : TExplosionFlags = []; aContent : Byte = 0; aDirectHit : Boolean = False );
    procedure Shotgun( source, target : TCoord2D; Damage : TDiceRoll; Shotgun : TShotgunData; aItem : TItem );
    procedure Respawn( Chance : byte );
    function isPassable( const coord : TCoord2D ) : Boolean; override;
    function isEmpty( const coord : TCoord2D; EmptyFlags : TFlags32 = []) : Boolean; override;
    function cellFlagSet( coord : TCoord2D; Flag : byte) : Boolean;
    procedure playSound( const SoundID : DWord; coord : TCoord2D ); overload;
    procedure playSound( const SoundID : string; coord : TCoord2D ); overload;
    procedure playSound( const BaseID,SoundID : string; coord : TCoord2D ); overload;
    function BeingsVisible : Word;

    function DropItem ( aItem  : TItem;  aCoord : TCoord2D ) : boolean;  // raises EPlacementException
    procedure DropBeing( aBeing : TBeing; aCoord : TCoord2D ); // raises EPlacementException

    procedure Remove( Node : TNode ); override;
    procedure Add( aThing : TThing; aWhere : TCoord2D ); reintroduce;
    function isAlive( aUID : TUID ) : boolean;

    procedure ScriptLevel(script : string);
    procedure SingleLevel(ModuleID : string);

    function RandomCoord( EmptyFlags : TFlags32 ) : TCoord2D; // raises EPlacementException

    destructor Destroy; override;

    procedure DestroyItem( coord : TCoord2D );
    procedure Blood( coord : TCoord2D );
    procedure Kill( aBeing : TBeing; Silent : Boolean = False );
    function ActiveBeing : TBeing;
    procedure CalculateVision( coord : TCoord2D );

    procedure Place( Thing : TThing; Coord : TCoord2D );
    procedure RevealBeings;
    function GetMiniMapColor( aCoord : TCoord2D ) : TColor;
    function getGylph( const aCoord : TCoord2D ) : TIOGylph;
    function EntityFromStream( aStream : TStream; aEntityID : Byte ) : TLuaEntityNode; override;
    class procedure RegisterLuaAPI();

    private
    function CellToID( const aCell : Byte ) : AnsiString; override;
    procedure RawCallHook( Hook : Byte; const aParams : array of const ); overload;
    function RawCallHookCheck( Hook : Byte; const aParams : array of const ) : boolean;
    function EnemiesLeft : DWord;
    function  getCell( const aWhere : TCoord2D ) : byte; override;
    procedure putCell( const aWhere : TCoord2D; const aWhat : byte ); override;
    function  getBeing( const coord : TCoord2D ) : TBeing; override;
    function  getItem( const coord : TCoord2D ) : TItem; override;
    private
    Map         : TMap;
    FStatus     : Word; // level result
    FStyle      : Byte;

    FActiveBeing : TBeing;
    FNextNode    : TNode;

    function getCellBottom( Index : TCoord2D ): Byte;
    function getCellTop( Index : TCoord2D ): Byte;
    function getRotation( Index : TCoord2D ): Byte;

    public
    property Hooks : TFlags read FHooks;
    property Item     [ Index : TCoord2D ] : TItem  read getItem;
    property Being    [ Index : TCoord2D ] : TBeing read getBeing;
    property CellBottom [ Index : TCoord2D ] : Byte read getCellBottom;
    property CellTop    [ Index : TCoord2D ] : Byte read getCellTop;
    property Rotation [ Index : TCoord2D ] : Byte   read getRotation;
    published
    property Status       : Word       read FStatus     write FStatus;
    property Name         : AnsiString read FName       write FName;
    property Name_Number  : Word       read LNum        write LNum;
    property Danger_Level : Word       read DangerLevel write DangerLevel;
    property Style        : Byte       read FStyle      write FStyle;
    property Special_Exit : AnsiString read SpecExit;
    property Feeling      : AnsiString read FFeeling    write FFeeling;
    property id : AnsiString           read FID;
  end;

implementation

uses typinfo, vluadungen, vluatools, vluasystem,
     vdebug, dfplayer, doomlua, doombase, doomio, doomspritemap;

procedure TLevel.ScriptLevel(script : string);
begin
  FullClear;
  LuaPlayerX := 2;
  LuaPlayerY := 2;

  with LuaSystem.GetTable( ['levels', script] ) do
  try
    FID := Script;

    if IsString('entry')   then Player.AddHistory( GetString('entry') );
    if IsString('welcome') then 
    begin
      Ui.Msg( GetString('welcome') );
      FFeeling := GetString('welcome');
    end;
    FStatus := 0;
    FName   := GetString( 'name' );
    LNum    := 0;
    Call('Create',[]);
    Place( Player, FMapArea.Drop( NewCoord2D(LuaPlayerX,LuaPlayerY), [ EF_NOBEINGS ] ) );
    Include( FFlags, LF_SCRIPT );
  finally
    Free;
  end;
  FHooks := LoadHooks( [ 'levels', script ] ) * LevelHooks;

  AfterGeneration( False );
end;

procedure TLevel.SingleLevel(ModuleID : string);
begin
  FullClear;
  LuaPlayerX := 2;
  LuaPlayerY := 2;

  LuaSystem.ProtectedCall([ModuleID,'run'],[]);
  Place( Player, FMapArea.Drop( NewCoord2D(LuaPlayerX,LuaPlayerY), [ EF_NOBEINGS ] ) );

  AfterGeneration( False );
end;

function TLevel.RandomCoord( EmptyFlags: TFlags32 ) : TCoord2D;
const LIMES = 10000;
var iCount : Word;
begin
  iCount := 0;
  repeat
    RandomCoord := FArea.RandomInnerCoord();
    Inc( iCount );
  until isEmpty( RandomCoord, EmptyFlags ) or ( iCount > LIMES );
  if ( iCount > LIMES ) then raise EPlacementException.Create('');
end;

function TLevel.isEmpty( const coord : TCoord2D; EmptyFlags : TFlags32 = []) : Boolean;
begin
  if EmptyFlags = [] then EmptyFlags := [EF_NOITEMS,EF_NOBEINGS,EF_NOBLOCK,EF_NOSTAIRS];
  if not inherited isEmpty( coord, EmptyFlags ) then Exit( False );
  isEmpty := True;
  if EF_NOVISION in EmptyFlags then if cellFlagSet(coord,CF_BLOCKLOS) then Exit(False);
  if EF_NOSTAIRS in EmptyFlags then if CellHook_OnExit in Cells[Cell[coord]].Hooks then Exit(False);
  if EF_NOTELE   in EmptyFlags then if (Item[coord] <> nil) and (Item[coord].IType = ITEMTYPE_TELE) then Exit(False);
  if EF_NOHARM   in EmptyFlags then if cellFlagSet(coord,CF_HAZARD) then Exit(False);
  if EF_NOSAFE   in EmptyFlags then if Distance(coord,Player.Position) < PlayerSafeZone then Exit(False);
  if EF_NOSPAWN  in EmptyFlags then if LightFlag[ coord, lfNoSpawn ] then Exit(False);
end;

function TLevel.cellFlagSet( coord : TCoord2D; Flag : byte) : Boolean;
begin
  Exit(Flag in Cells[ GetCell( coord ) ].Flags);
end;

procedure TLevel.playSound(const SoundID: DWord; coord : TCoord2D );
begin
  IO.PlaySound(SoundID, coord);
end;

procedure TLevel.playSound(const SoundID: string; coord : TCoord2D );
begin
  IO.PlaySound(IO.ResolveSoundID([SoundID]), coord );
end;

procedure TLevel.playSound(const BaseID, SoundID: string; coord : TCoord2D );
begin
  IO.PlaySound(IO.ResolveSoundID([BaseID+'.'+SoundID,SoundID]), coord );
end;

function TLevel.BeingsVisible : Word;
var iNode  : TNode;
begin
  BeingsVisible := 0;
  for iNode in Self do
    if iNode is TBeing then
      if TBeing(iNode).isVisible then
        Inc(BeingsVisible);
end;

function TLevel.isAlive ( aUID : TUID ) : boolean;
begin
  Exit( FindChild( aUID ) <> nil );
end;

procedure TLevel.Place(Thing: TThing; Coord: TCoord2D);
begin
  Thing.Position := Coord;
  Add( Thing, Coord );
end;

procedure TLevel.RevealBeings;
var iNode : TNode;
begin
  for iNode in Self do
    if iNode is TBeing then
      TBeing(iNode).AnimCount := 0;
end;

function TLevel.GetMiniMapColor ( aCoord : TCoord2D ) : TColor;
const DefColor : TColor = ( R : 0; G : 0; B : 0; A : 50 );
var iColor : Byte;
    iItem  : TItem;
    iBeing : TBeing;

begin
  if not isProperCoord( aCoord ) then Exit( DefColor );
  iColor := Black;
  iBeing := Being[ aCoord ];
  iItem  := Item[ aCoord ];

  if BeingVisible( aCoord, iBeing ) or BeingExplored( aCoord, iBeing ) or BeingIntuited( aCoord, iBeing ) then
  begin
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
        iColor := Yellow;
    end
    else
      with Cells[ getCell(aCoord) ] do
      if CF_PUSHABLE in Flags then
        iColor := Magenta
      else
      if CF_LIQUID in Flags then
        iColor := Blue
      else
      if CF_STAIRS in Flags then
        iColor := Yellow
      else
      if CF_BLOCKMOVE in Flags then
        iColor := LightGray
      else
        iColor := DarkGray;
  end;

  if iColor = Black then Exit( DefColor );
  Result := NewColor( iColor );
  Result.A := 50;
end;

function TLevel.getGylph(const aCoord: TCoord2D): TIOGylph;
  function GetColor( aAtr : Byte; aCoord : TCoord2D; aHighlight : boolean = false ) : TIOColor;
  var Mod2    : Boolean;
      //color : TTrueColorRec;
  begin
    if aAtr > 16 then
    begin
      Mod2 := ((aCoord.x+aCoord.y) mod 2) = 0;
      case aAtr of
        COLOR_WATER : if Mod2 then aAtr := BLUE   else aAtr := LIGHTBLUE;
        COLOR_ACID  : if Mod2 then aAtr := GREEN  else aAtr := LIGHTGREEN;
        COLOR_LAVA  : if Mod2 then aAtr := YELLOW else aAtr := RED;
        MULTIPORTAL : case (( Player.FStatistics.GameTime div 10 ) mod 3) of
                        0 : aAtr := LIGHTMAGENTA;
                        1 : aAtr := MAGENTA;
                        2 : aAtr := WHITE;
                      end;
      end;
    end;
    {$IFDEF CORNERMAP}
    if Corner( aCoord ) then aAtr := Yellow;
    {$ENDIF CORNERMAP}
    if StatusEffect <> StatusNormal then
      case StatusEffect of
        StatusRed     : if aHighlight then aAtr := LightRed     else aAtr := Red;
        StatusGreen   : if aHighlight then aAtr := LightGreen   else aAtr := Green;
        StatusBlue    : if aHighlight then aAtr := LightBlue    else aAtr := Blue;
        StatusCyan    : if aHighlight then aAtr := LightCyan    else aAtr := Cyan;
        StatusMagenta : if aHighlight then aAtr := LightMagenta else aAtr := Magenta;
        StatusYellow  : if aHighlight then aAtr := Yellow       else aAtr := Brown;
        StatusGray    : if aHighlight then aAtr := LightGray    else aAtr := DarkGray;
        StatusWhite   : if aHighlight then aAtr := White        else aAtr := DarkGray;
        StatusInvert  : if aHighlight then aAtr := 16*LightGray else aAtr := 16*LightGray+DarkGray;
      end;
    {    if GraphicsVersion then
    begin
      distmod := 1.0 - Distance(Coord,Player.Position) * 0.1;
      if distmod < 0.2 then distmod := 0.2;
      Color[0] := Round((GLFloatColors[atr mod 16].X * distmod ) * 255);
      Color[1] := Round((GLFloatColors[atr mod 16].Y * distmod ) * 255);
      Color[2] := Round((GLFloatColors[atr mod 16].Z * distmod ) * 255);
      Color[3] := 255;
      IO.Console.OutputChar( Coord.x+1,Coord.y+2,color,TTrueColor(chr));
    end}
    Exit( aAtr );
  end;
var iColor    : TIOColor;
    iChar     : Char;
    iCell     : DWord;
    iVisible  : Boolean;
    iExplored : Boolean;
    iBlood    : Boolean;
    iItem     : TItem;
    iBeing    : TBeing;
begin
  iBeing   := Being[ aCoord ];

  if BeingVisible( aCoord, iBeing ) or BeingExplored( aCoord, iBeing) then
    Exit( IOGylph( iBeing.Picture, GetColor( iBeing.Color, aCoord, True ) ) );

  if BeingIntuited( aCoord, iBeing ) then
    Exit( IOGylph( Option_IntuitionChar, GetColor( Option_IntuitionColor, aCoord, True ) ) );

  iItem    := Item[ aCoord ];

  if ItemVisible( aCoord, iItem ) then
    Exit( IOGylph( iItem.Picture, GetColor( iItem.Color, aCoord, True ) ) );

  if ItemExplored( aCoord, iItem ) then
    Exit( IOGylph( iItem.Picture, GetColor( DarkGray, aCoord, True ) ) );

  iVisible  := isVisible( aCoord );
  iExplored := CellExplored( aCoord );
  iCell     := GetCell( aCoord );

  iColor   := LightGray;
  iChar    := ' ';
  with Cells[ iCell ] do
  if PicChr <> ' ' then
  begin
    if iVisible or iExplored then
      if Option_HighASCII
        then iChar := PicChr
        else iChar := PicLow;
    if iVisible then
    begin
      iBlood := LightFlag[ aCoord, LFBLOOD ] and (BloodColor <> 0);
      if iBlood
         then iColor := BloodColor
         else iColor := LightColor;
    end
    else if iExplored then iColor := DarkColor;
  end;
  getGylph.ASCII := iChar;
  getGylph.Color := GetColor( iColor, aCoord, CF_HIGHLIGHT in Cells[ iCell ].Flags );
end;

function TLevel.EntityFromStream ( aStream : TStream; aEntityID : Byte ) : TLuaEntityNode;
begin
  case aEntityID of
    ENTITY_BEING : Exit( TBeing.CreateFromStream(aStream) );
    ENTITY_ITEM  : Exit( TItem.CreateFromStream(aStream) );
  end;
end;

function TLevel.EnemiesLeft: DWord;
var iEnemies : DWord;
    iNode : TNode;
begin
  iEnemies := 0;
  for iNode in Self do
    if iNode is TBeing then
      Inc( iEnemies );
  Exit( iEnemies - 1 );
end;

constructor TLevel.Create;
begin
  inherited Create('default',MaxX, MaxY, 15);
  RegisterDungen( FGenerator );

  Assert( dfdata.EF_NOBLOCK  = vluamapnode.EF_NOBLOCK );
  Assert( dfdata.EF_NOITEMS  = vluamapnode.EF_NOITEMS );
  Assert( dfdata.EF_NOBEINGS = vluamapnode.EF_NOBEINGS );
end;

procedure TLevel.Init(nStyle : byte; nLNum : Word; nName : string; nSpecExit : string; nDepth : Word; nDangerLevel : Word);
begin
  FActiveBeing := nil;
  FNextNode    := nil;

  LTime  := 0;
  FullClear;
  FStyle := nstyle;
  lnum := nlnum;
  FName := nname;
  DangerLevel := nDangerLevel;
  SpecExit := nSpecExit;
  FID := 'level'+IntToStr(nDepth);
  FFlags := [];
  Empty := False;
  FHooks := [];
  FFloorCell := LuaSystem.Defines[LuaSystem.Get(['generator','styles',FStyle,'floor'])];
  if LuaSystem.Get(['diff',Doom.Difficulty,'respawn']) then Include( FFlags, LF_RESPAWN );
  ToHitBonus := LuaSystem.Get(['diff',Doom.Difficulty,'tohitbonus']);
end;

procedure TLevel.AfterGeneration( aGenerated : Boolean );
var iCoord : TCoord2D;
    iCell  : Word;
    iFlags : TFlags;
    iWall  : Word;
begin
  FFloorCell := LuaSystem.Defines[ LuaSystem.Get(['generator','styles',FStyle,'floor'] ) ];
  iWall      := LuaSystem.Defines[ LuaSystem.Get(['generator','styles',FStyle,'wall'] ) ];
  for iCoord in FArea do
  begin
    iCell   := GetCell(iCoord);
    iFlags  := Cells[iCell].Flags;
    if CF_OVERLAY in iFlags then
    begin
      if (CF_STICKWALL in iFlags) and (not (CF_OPENABLE in iFlags )) then
        PutCell(iCoord,iWall)
      else
        PutCell(iCoord,FFloorCell);
      PutCell(iCoord,iCell);
    end;
  end;

  if not aGenerated then Exit;
  FHooks := LoadHooks( [ 'generator' ] ) * LevelHooks;
end;


procedure TLevel.PreEnter;
var c : TCoord2D;
begin
  if GraphicsVersion then
  begin
    for c in FArea do
    begin
      if CF_MULTISPRITE in Cells[CellBottom[c]].Flags then
        Map.r[c.x,c.y] := SpriteMap.GetCellShift(c);
    end;

    UI.GameUI.UpdateMinimap;
    RecalcFluids;
    SpriteMap.NewShift := SpriteMap.ShiftValue( Player.Position );
  end;

  CallHook(Hook_OnEnter,[Player.CurrentLevel,FID]);

  if GraphicsVersion then
  begin
    RecalcFluids;
    SpriteMap.NewShift := SpriteMap.ShiftValue( Player.Position );
  end;

  Player.LevelEnter;

  if LF_UNIQUEITEM in FFlags then
  begin
    UI.Msg('You feel there is something really valuable here!');
    FFeeling := FFeeling + ' You feel there is something really valuable here!';
  end;

  for c in FArea do
    HitPoints[c] := Cells[GetCell(c)].HP;

end;

procedure TLevel.RecalcFluids;
var cc : TCoord2D;
  function FluidFlag( c : TCoord2D; Value : Byte ) : Byte;
  begin
    if not isProperCoord( c ) then Exit(0);
    if not (F_GFLUID in Cells[CellBottom[ c ]].Flags)
      then Exit( Value )
      else Exit( 0 );
  end;
begin
  if LF_SHARPFLUID in FFlags then Exit;
 for cc in FArea do
   if F_GFLUID in Cells[CellBottom[ cc ]].Flags then
     Map.r[cc.x,cc.y] :=
       FluidFlag( cc.ifInc( 0,-1), 1 ) +
       FluidFlag( cc.ifInc( 0,+1), 2 ) +
       FluidFlag( cc.ifInc(-1, 0), 4 ) +
       FluidFlag( cc.ifInc(+1, 0), 8 );
end;

procedure TLevel.Leave;
var TimeDiff : LongInt;
begin
  CallHook(Hook_OnExit,[Player.CurrentLevel,FID, FStatus]);
  if LF_BONUS in FFlags then
    if Hook_OnCompletedCheck in FHooks then
    begin
      if RawCallHookCheck( Hook_OnCompletedCheck,[] ) then Player.IncStatistic('bonus_levels_completed');
    end
    else
      if EnemiesLeft() = 0 then Player.IncStatistic('bonus_levels_completed');


  if (not (LF_BONUS in FFlags)) and (Player.HP > 0) then
  begin
    TimeDiff :=  Player.FStatistics.GameTime - Player.FStatistics.Map['entry_time'];
    if TimeDiff < 100 then
      Player.AddHistory(Format('He left level %d as soon as possible.',[Player.CurrentLevel]));
  end;

  UI.MsgReset;
end;

procedure TLevel.Clear;
begin
  FHooks := [];
  if Player <> nil then Player.Detach;
  DestroyChildren;
  ClearEntities;
end;

procedure TLevel.FullClear;
var x,y : Byte;
begin
  ClearAll;
  ClearEntities;
  with Map do
  for x := 1 to MaxX do
    for y := 1 to MaxY do
    begin
      d[x,y] := 0;
      r[x,y] := 0;
      if (x = 1) or (y = 1) or ( x = MaxX ) or ( y = MaxY ) then LightFlag[ NewCoord2D(x,y), lfPermanent ] := True;
    end;
end;

function TLevel.CellExplored( coord: TCoord2D ): boolean;
begin
  if Player.Flags[ BF_DARKNESS ] and not isVisible( coord ) then Exit(False);
  if Player.Flags[ BF_STAIRSENSE ] and (CF_STAIRS in Cells[ GetCell(coord) ].Flags) then Exit(True);
  if Option_BlindMode and not GraphicsVersion then Exit(False);
  Exit(isExplored( coord ));
end;

function TLevel.ItemVisible( coord: TCoord2D; aItem: TItem ) : boolean;
begin
  if aItem = nil then Exit(False);
  if isVisible( coord ) then Exit(True);
  if aItem.isPower and Player.Flags[ BF_POWERSENSE ] then Exit(True);
  if Player.Flags[ BF_DARKNESS ] then Exit(False);
  if LF_ITEMSVISIBLE in FFlags then Exit(True);
  Exit(False);
end;

function TLevel.ItemExplored( coord: TCoord2D; aItem: TItem ) : boolean;
begin
  if aItem = nil then Exit(False);
  if Player.Flags[ BF_DARKNESS ] and not isVisible( coord ) then Exit(False);
  Exit(isExplored( coord ));
end;
	
function TLevel.BeingVisible( coord: TCoord2D; aBeing: TBeing ) : boolean;
begin
  if aBeing = nil then Exit(False);
  Exit(isVisible( coord ));
end;

function TLevel.BeingExplored( coord: TCoord2D; aBeing: TBeing ) : boolean;
begin
  if aBeing = nil then Exit(False);
  if Player.Flags[ BF_DARKNESS ] and not isVisible( coord ) then Exit(False);
  Exit(LF_BEINGSVISIBLE in FFlags);
end;

function TLevel.BeingIntuited( coord: TCoord2D; aBeing: TBeing ) : boolean;
begin
  if aBeing = nil then Exit(False);
  if not Player.Flags[ BF_BEINGSENSE ] then Exit(False);
  Exit(Distance( Player.Position, coord ) <= Player.Vision + 3);
end;

{$IFDEF CORNERMAP}
function TLevel.Corner ( coord : TCoord2D ) : boolean;
begin
  Exit( LightFlag[ coord, lfCorner ] );
end;
{$ENDIF CORNERMAP}

function TLevel.CallHook( coord : TCoord2D; Hook: TCellHook ) : Variant;
begin
  Exit( CallHook( Coord, GetCell(coord), Hook ) );
end;

function TLevel.CallHook( coord : TCoord2D; aCellID : Word; Hook: TCellHook ) : Variant;
begin
  if Hook in Cells[ aCellID ].Hooks
    then CallHook := LuaSystem.ProtectedCall( [ 'cells', aCellID, CellHooks[ Hook ] ], [LuaCoord(coord)] )
    else CallHook := False;
end;

function TLevel.CallHook(coord: TCoord2D; What: TThing; Hook: TCellHook) : Variant;
begin
  if Hook in Cells[ GetCell(coord) ].Hooks
    then CallHook := LuaSystem.ProtectedCall( [ 'cells', Cell[ coord ], CellHooks[ Hook ] ], [LuaCoord(coord),What] )
    else CallHook := False;
end;

procedure TLevel.RawCallHook(Hook: Byte; const aParams : array of const );
begin
  if not (Hook in FHooks) then Exit;
  if LF_SCRIPT in FFlags then
    LuaSystem.ProtectedCall( [ 'levels', FID, HookNames[Hook] ], aParams )
  else
    LuaSystem.ProtectedCall( [ 'generator', HookNames[Hook] ], aParams );
end;

function TLevel.RawCallHookCheck(Hook: Byte; const aParams : array of const ): boolean;
begin
  if not (Hook in FHooks) then Exit(False);
  if LF_SCRIPT in FFlags then
    RawCallHookCheck := LuaSystem.ProtectedCall( [ 'levels', FID, HookNames[Hook] ], aParams )
  else
    RawCallHookCheck := LuaSystem.ProtectedCall( [ 'generator', HookNames[Hook] ], aParams );
end;

procedure TLevel.CallHook( Hook : Byte; const Params : array of const ) ;
begin
  if Hook in FHooks           then RawCallHook( Hook, Params );
  Doom.CallHook( Hook, Params );
end;

function TLevel.CallHookCheck( Hook : Byte; const Params : array of const ) : Boolean;
begin
  if not Doom.CallHookCheck( Hook, Params ) then Exit( False );
  if Hook in FHooks then if not RawCallHookCheck( Hook, Params ) then Exit( False );
  Exit( True );
end;


procedure TLevel.DamageTile( coord : TCoord2D; Dmg : Integer; DamageType : TDamageType );
var cellID : byte;
    Heavy  : Boolean;
begin
  Heavy := DamageType in [Damage_Acid, Damage_Fire, Damage_Plasma, Damage_SPlasma];
  if not isProperCoord(coord) then Exit;
  cellID := Cell[Coord];
  
  if LightFlag[ coord, lfPermanent ] then Exit;
  if LightFlag[ coord, lfFresh ]     then Exit;

  if (not Heavy) and (not (CF_FRAGILE in Cells[cellID].Flags)) then Exit;
  if Cells[cellID].DR = 0 then Exit;

  dmg -= Cells[cellID].DR;

  if CF_CORPSE in Cells[cellID].Flags then
  case DamageType of
    Damage_Acid    : Dmg := Dmg * 2;
    Damage_SPlasma : Dmg := Dmg * 3;
    Damage_Plasma  : Dmg := Round( Dmg * 1.5 );
  end;

  if dmg <= 0 then Exit;

  HitPoints[coord] := Max(0,HitPoints[coord]-dmg);
  if HitPoints[coord] > 0 then Exit;
  
  if CF_CORPSE in Cells[cellID].Flags then
    playSound( 'gib', coord );

  if Cells[cellID].destroyto = ''
    then Cell[coord] := FFloorCell
    else Cell[coord] := LuaSystem.Defines[ Cells[cellID].destroyto ];

  CallHook( coord, CellID, CellHook_OnDestroy );
end;


destructor TLevel.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TLevel.DropItem( aItem : TItem; aCoord : TCoord2D ) : boolean;
begin
  DropItem := true;
  if aItem = nil then Exit;
  aCoord := FMapArea.Drop( aCoord, [ EF_NOITEMS,EF_NOBLOCK,EF_NOSTAIRS ] );
  Add( aItem, aCoord );

  if cellFlagSet(aCoord,CF_HAZARD) then
  begin
    DestroyItem( aCoord );
    DropItem := False;
  end;
end;

procedure TLevel.DropBeing( aBeing : TBeing; aCoord : TCoord2D );
begin
  if aBeing = nil then Exit;
  aCoord := FMapArea.Drop( aCoord, [ EF_NOTELE,EF_NOBEINGS,EF_NOBLOCK,EF_NOSTAIRS ] );
  Add( aBeing, aCoord );
  if not aBeing.IsPlayer then Player.FKills.MaxCount := Player.FKills.MaxCount + 1;
end;

procedure TLevel.Remove ( Node : TNode ) ;
begin
  if FActiveBeing = Node then FActiveBeing := nil;
  if FNextNode = Node    then FNextNode := Node.Next;
  inherited Remove( Node );
end;

procedure TLevel.Add ( aThing : TThing; aWhere : TCoord2D );
begin
  inherited Add( aThing );
  aThing.Position := aWhere;
  if aThing is TBeing then
    TBeing(aThing).LastPos := aWhere;
  Displace( aThing, aWhere );
end;

procedure TLevel.DropCorpse(aCoord: TCoord2D; CellID: Byte);
begin
  if Cell[ aCoord ] in CellFloors then
  begin
    Cell[ aCoord ] := CellID;
    LightFlag[ aCoord, lfFresh ] := True;
  end;
end;

procedure TLevel.Explosion( Sequence : Integer; coord : TCoord2D; Range, Delay : Integer; Damage : TDiceRoll; color : byte; ExplSound : Word; DamageType : TDamageType; aItem : TItem; aFlags : TExplosionFlags = []; aContent : Byte = 0 ; aDirectHit : Boolean = False );
var a     : TCoord2D;
    iDamage : Integer;
    dir   : TDirection;
    iKnockbackValue : Byte;
    iNode : TNode;
begin
  if not isProperCoord( coord ) then Exit;

  UI.Explosion( Sequence, coord, Range, Delay, Color, ExplSound, aFlags );

  for iNode in Self do
    if iNode is TBeing then
      TBeing(iNode).KnockBacked := False;

  ClearLightMapBits( [lfFresh] );

  if Damage.max > 0 then
  for a in NewArea( Coord, Range ).Clamped( FArea ) do
    if Distance( a, coord ) <= Range then
      begin
        if not isEyeContact( a, coord ) then Continue;
        iDamage := Damage.Roll;
        if not (efNoDistanceDrop in aFlags) then
          iDamage := iDamage div Max(1,(Distance(a,coord)+1) div 2);
        DamageTile( a, iDamage, DamageType );
        if Being[a] <> nil then
        with Being[a] do
        begin
          if KnockBacked then Continue;
          if (efSelfSafe in aFlags) and isActive then Continue;
          if efChain in aFlags then Explosion( Sequence + Distance( a, coord ) * Delay, a,Max( Range div 2 - 1, 1 ), Delay, NewDiceRoll(0,0,0), color, 0, DamageType, nil );
          iKnockbackValue := KnockBackValue;
          if (efHalfKnock in aFlags) then iKnockbackValue *= 2;
          if (efSelfKnockback in aFlags) and isActive then iKnockbackValue := 2;
          if (iDamage >= iKnockBackValue) and (not (efNoKnock in aFlags) ) then
          begin
            dir.CreateSmooth( coord, a );
            Knockback( dir, iDamage div iKnockbackValue );
          end;
          KnockBacked := True;
          if (Flags[BF_FIREANGEL]) and (not aDirectHit) then Continue;
          if (efSelfHalf in aFlags) and isActive then iDamage := iDamage div 2;
          ApplyDamage( iDamage, Target_Torso, DamageType, aItem );
        end;
        if Item[a] <> nil then
           if (iDamage > 10) then
           begin
             if efChain in aFlags then Explosion(Sequence + Distance( a, coord ) * Delay,a,Max( Range div 2 - 1, 1 ), Delay, NewDiceRoll(0,0,0), color, 0, DamageType, nil );
             DestroyItem( a );
           end;
        if (aContent <> 0) and isEmpty( a, [ EF_NOITEMS, EF_NOSTAIRS, EF_NOBLOCK, EF_NOHARM ] ) then
        begin
          if (iDamage > 20) or ((efRandomContent in aFlags) and (Random(2) = 1)) then
            Cell[a] := aContent;
        end;
      end;
  if aContent <> 0 then RecalcFluids;
end;

procedure TLevel.Shotgun( source, target : TCoord2D; Damage : TDiceRoll; Shotgun : TShotgunData; aItem : TItem );
var a,b,tc  : TCoord2D;
    d       : Single;
    dmg     : Integer;
    Range   : Byte;
    Spread  : Byte;
    Reduce  : Single;
    Dir     : TDirection;
    iNode   : TNode;
    procedure SendShotgunBeam( s : TCoord2D; tcc : TCoord2D );
    var shb : TVisionRay;
        cnt : byte;
    begin
      shb.Init(Self,s,tcc,0.4);
      cnt := 0;
      repeat
        Inc(cnt);
        shb.Next;
        if not isProperCoord( shb.GetC ) then Exit;
        LightFlag[ shb.GetC, lfDamage ] := True;
        if not isEmpty( shb.GetC, [ EF_NOBLOCK ] ) then Exit;
        if shb.Done then Exit;
      until cnt = Range;
    end;
begin
  Range  := Shotgun.MaxRange;
  Spread := Shotgun.Spread;
  Reduce := Shotgun.Reduce;

  d   := Distance( source, target );
  if d = 0 then Exit;
  a   := target - source;
  d   := Sqrt(a.x*a.x+a.y*a.y);
  b.x := Round((a.x*Range)/d);
  b.y := Round((a.y*Range)/d);
  b   += source;

  for iNode in Self do
    if iNode is TBeing then
      TBeing(iNode).KnockBacked := False;

  for tc in NewArea( b, Spread ) do
    SendShotGunBeam( source, tc );

  for tc in FArea do
    if LightFlag[ tc, lfDamage ] then
      begin
        dmg := Round(Damage.Roll * (1.0-Reduce*Max(1,Distance( source, tc ))));
        if (dmg < 1) then dmg := 1;
        
        if Being[ tc ] <> nil then
        with Being[ tc ] do
        begin
          if KnockBacked then Continue;
          if isVisible then
          begin
            if dmg > 10 then UI.Mark( tc, Red, '*', 200 )
              else if dmg > 4 then UI.Mark( tc, LightRed, '*', 100 )
                else UI.Mark( tc, LightGray, '*', 50 );
          end;
          if dmg >= KnockBackValue then
          begin
            dir.CreateSmooth(source, tc);
            Knockback( dir, dmg div KnockBackValue );
          end;
          KnockBacked := True;
          ApplyDamage( dmg, Target_Torso, Shotgun.DamageType, aItem );
        end;
        
        DamageTile( tc, dmg, Shotgun.DamageType );
        if cellFlagSet(tc,CF_BLOCKMOVE) then
          if isVisible(tc) then UI.Mark(tc,LightGray,'*',100);
      end;
  ClearLightMapBits([lfDamage]);
end;


procedure TLevel.Respawn( Chance : byte );
var coord  : TCoord2D;
    iBeing : TBeing;
begin
  if LF_NORESPAWN in FFlags then Exit;
  for coord in FArea do
    if Being[ coord ] = nil then
      if cellFlagSet( coord ,CF_RAISABLE ) then
        if Random(100) < Chance then
        try
          iBeing := TBeing.Create( Cells[ GetCell(coord) ].raiseto );
          DropBeing( iBeing, coord );
          iBeing.Flags[ BF_NOEXP ] := True;
          // XXX: No farming?
          iBeing.Flags[ BF_NODROP ] := False;
          Cell[ coord ] := LuaSystem.Defines[ Cells[ GetCell(coord) ].destroyto ];
        except
          on EPlacementException do FreeAndNil( iBeing );
        end;

end;

function TLevel.isPassable ( const coord : TCoord2D ) : Boolean;
begin
  Exit( not cellFlagSet(coord,CF_BLOCKMOVE) );
end;

procedure TLevel.DestroyItem( coord : TCoord2D );
var iItem : TItem;
begin
  iItem := Item[ coord ];
  if iItem = nil then Exit;
  if iItem.Flags[ IF_UNIQUE ] or iItem.Flags[ IF_NODESTROY ] then Exit;
  FreeAndNil( iItem );
  SetItem( coord, nil );
end;

procedure TLevel.Blood( coord : TCoord2D );
var iCell : DWord;
begin
  iCell := GetCell(coord);
  if (Cells[ iCell ].bloodto <> '') and (LightFlag[ coord, LFBLOOD ] or (Cells[ iCell ].BloodColor = 0))
    then Cell[ coord ] := LuaSystem.Defines[ Cells[ iCell ].bloodto ]
    else LightFlag[ coord, LFBLOOD ] := True;
end;

procedure TLevel.Kill ( aBeing : TBeing; Silent : Boolean ) ;
begin
  if aBeing = nil then Exit;
  if Being[ aBeing.Position ] = aBeing then
    SetBeing( aBeing.Position, nil );

  if (Doom.State = DSPlaying) and (not Silent) then
  begin
    CallHook(Hook_OnKill,[ aBeing ]);
  end;

  FreeAndNil(aBeing);

  if (Doom.State = DSPlaying) and (not Silent) then
  begin
    if EnemiesLeft() = 0 then
    begin
      CallHook(Hook_OnKillAll,[]);
      if (not (LF_RESPAWN in FFlags)) and ( EnemiesLeft() = 0 ) then
      begin
        if not (Hook_OnKillAll in FHooks) then
          UI.Msg('You feel relatively safe now.');
        Empty := True;
      end;
    end;
  end;
end;

function TLevel.ActiveBeing: TBeing;
begin
  Exit( FActiveBeing );
end;

procedure TLevel.CalculateVision(coord: TCoord2D);
{$IFDEF CORNERMAP}
var c : TCoord2D;
{$ENDIF CORNERMAP}
begin
  ClearLightMapBits( [ lfFresh ] );
  RunVision( Coord, Player.Vision );
  {$IFDEF CORNERMAP}
  begin
    ClearLightMapBits( [ lfCorner ] );
    for c in FArea do
      if isVisible(c) then
        if not isEyeContact(c,coord) then
          LightFlag[ c, lfCorner ] := True;
  end;
  {$ENDIF CORNERMAP}
end;

procedure TLevel.Tick;
var Scan  : TNode;
begin
  Inc(LTime);
  if Doom.State = DSPlaying then
  begin
    Scan := Child;
    if Scan <> nil then
    repeat
      FNextNode    := Scan.Next;
      FActiveBeing := nil;
      if Scan is TBeing then
      begin
        FActiveBeing := TBeing(Scan);
        FActiveBeing.Call;
      end;
      if Doom.State <> DSPlaying then Break;
      Scan := FNextNode;
    until (Scan = Child) or (Scan = nil);
  end;
  FActiveBeing := nil;
  CallHook( Hook_OnTick,[] );
  
  if LF_RESPAWN in FFlags  then
  begin
    if LTime mod 100 = 0 then
      if ((LTime div 100)+20) > DWord(Random(100)) then
        Respawn( Min( (LTime div 1000) + 10, 100 ) );
  end;

  NukeTick;
end;

procedure TLevel.NukeTick;
var Nuke : DWord;
    cn   : Word;
begin
  if Player.NukeActivated <> 0 then
  begin
    Dec(Player.NukeActivated);
    if (Player.NukeActivated <> 0) then
    begin
      Nuke := Player.NukeActivated;
      if (Nuke <= 100)   then begin if (Nuke mod 10  = 0) then UI.Msg('Warning! Explosion in %d seconds!',[Player.NukeActivated div 10]); end else
      if (Nuke <= 10*60) then begin if (Nuke mod 100 = 0) then UI.Msg('Warning! Explosion in %d seconds!',[Player.NukeActivated div 10]); end else
      if (Nuke mod (10*60) = 0) then UI.Msg('Warning! Explosion in %d minutes!',[Player.NukeActivated div 600]);
    end
    else
    begin
      Player.IncStatistic('levels_nuked');
      if Doom.State in [DSNextLevel,DSSaving] then
      begin
        UI.MsgEnter('Right in the nick of time!');
        Exit;
      end;
      for cn := 1 to 10 do
      begin
        Explosion( cn*200, RandomCoord( [ EF_NOBLOCK ] ),8,10,NewDiceRoll(0,0,0),LightRed,IO.ResolveSoundID(['nuke','barrel.explode','explode']){}{}{}{}{}{}{}{}{}, Damage_Fire, nil);
        UI.Blink(LightRed,40);
        UI.Blink(White,40);
      end;
      UI.Blink(White,2000);

      Include( FFlags, LF_NUKED );

      FArea.ForAllCells( @NukeCell );


      Player.NukeActivated := 0;
      Player.ApplyDamage( 6000, Target_Internal, Damage_Plasma, nil );
      CallHook(Hook_OnNuked,[Player.CurrentLevel,FID]);
    end;
  end;
end;

procedure TLevel.NukeCell(where: TCoord2D);
var CellBeing : TBeing;
    CellItem  : TItem;
    MapEdge   : Boolean;
begin
  if (where.x = MaxX) or (where.y = MaxY) or (where.x = 1) or (where.y = 1) then MapEdge := true else MapEdge := false;
  if cellFlagSet( where, CF_BLOCKMOVE ) and ( ( not MapEdge ) or ( ( MapEdge ) and ( not GetLightFlag( where, LFPERMANENT ) ) ) ) or
    cellFlagSet( where, CF_CORPSE ) or
    cellFlagSet( where, CF_NUKABLE ) then
       if Cells[ GetCell(where) ].destroyto = ''
         then Cell[ where ] := FFloorCell
         else Cell[ where ] := LuaSystem.Defines[ Cells[ GetCell(where) ].destroyto ];
  CellBeing := Being[ where ];
  CellItem  := Item [ where ];

  if ( CellBeing <> nil ) and ( not CellBeing.isPlayer ) then
    CellBeing.Kill(15,true,nil,nil);
  if ( CellItem <> nil ) and ( not ( CellItem.Flags[ IF_NUKERESIST ] ) ) then
    DestroyItem( where );
end;


function TLevel.blocksVision( const coord : TCoord2D ): boolean;
begin
  Exit(isProperCoord(coord) and (cellFlagSet(coord,CF_BLOCKLOS)));
end;

function TLevel.getCell( const aWhere : TCoord2D ) : byte; inline;
var iOverlay : Word;
begin
  iOverlay := Map.d[aWhere.x, aWhere.y];
  if iOverlay <> 0 then Exit( iOverlay );
  Result := inherited GetCell( aWhere );
end;

procedure TLevel.putCell( const aWhere : TCoord2D; const aWhat : byte ); inline;
begin
  if CF_OVERLAY in Cells[ aWhat ].Flags
  then
     Map.d[aWhere.x, aWhere.y] := aWhat
  else
  begin
    inherited PutCell( aWhere, aWhat );
    Map.d[aWhere.x, aWhere.y] := 0;
  end;
end;

function TLevel.getBeing( const coord : TCoord2D ) : TBeing;
begin
  Exit( inherited GetBeing(coord) as TBeing );
end;

function TLevel.getItem( const coord : TCoord2D ) : TItem;
begin
  Exit( inherited GetItem(coord) as TItem );
end;

function TLevel.getCellBottom( Index : TCoord2D ): Byte;
begin
  Exit( inherited GetCell( Index ) );
end;

function TLevel.getCellTop( Index : TCoord2D ): Byte;
begin
  Exit( Map.d[Index.x, Index.y] );
end;

function TLevel.getRotation( Index : TCoord2D ): Byte;
begin
  Exit( Map.r[Index.x, Index.y] );
end;

function lua_level_drop_being(L: Plua_State): Integer; cdecl;
var State  : TDoomLuaState;
    iBeing : TBeing;
    Level  : TLevel;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  if State.IsNil(3) then Exit(0);
  try
    if State.IsTable(2)
      then iBeing := State.ToObject(2) as TBeing
      else iBeing := TBeing.Create( State.ToId(2) );
    Level.DropBeing( iBeing, State.ToCoord(3) );
    State.Push( iBeing );
  except
    on EPlacementException do
    begin
      FreeAndNil( iBeing );
      State.PushNil();
    end;
  end;
  Result := 1;
end;

function lua_level_drop_item(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    iItem : TItem;
    Level : TLevel;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  if State.IsNil(3) then Exit(0);
  try
    if State.IsTable(2)
      then iItem := State.ToObject(2) as TItem
      else iItem := TItem.Create( State.ToId(2), State.ToBoolean(4, false) );
    Level.DropItem( iItem, State.ToPosition(3) );
    State.Push( iItem );
  except
    on EPlacementException do
    begin
      FreeAndNil( iItem );
      State.PushNil();
    end;
  end;
  Result := 1;
end;

function lua_level_player(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  if State.StackSize < 3 then Exit(0);
  LuaPlayerX := State.ToInteger(2);
  LuaPlayerY := State.ToInteger(3);
  Result := 0;
end;

function lua_level_play_sound(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    Level : TLevel;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  Level.playSound( State.ToSoundId(2), State.ToPosition(3) );
  Result := 0;
end;

function lua_level_nuke(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    Count : Byte;
    Level : TLevel;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  for Count := 1 to 10 do
  begin
    Level.Explosion(0,Level.RandomCoord( [ EF_NOBLOCK ] ),8,10,NewDiceRoll(0,0),LightRed,0{}{}{}{}{}{}{}{}{}, Damage_Fire, nil );
    UI.Blink(LightRed,40);
    UI.Blink(White,40);
  end;
  UI.Blink(White,1000);
  Level.FArea.ForAllCells( @Level.NukeCell );
  Result := 0;
end;


function lua_level_explosion(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    Content : Word;
    Sound   : Word;
    Level : TLevel;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  if State.IsNil(2) then Exit(0);
  Content := 0;
  Sound   := 0;
  if State.StackSize < 7 then Exit(0);
  if (State.StackSize >= 12) and (not State.IsNil(12)) then Content := State.ToId(12);
  if (State.StackSize >= 8 ) and (not State.IsNil(8))  then Sound := State.ToSoundId(8);

  Level.Explosion(0, State.ToPosition(2),
                  State.ToInteger(3),State.ToInteger(4),
                  NewDiceRoll(State.ToInteger(5),State.ToInteger(6)),
                  State.ToInteger(7),
                  Sound,
                  TDamageType(State.ToInteger(9,Byte(Damage_Fire))),
                  State.ToObjectOrNil(10) as TItem,
                  ExplosionFlagsFromFlags(State.ToFlags(11)),Content);
  Result := 0;
end;

function lua_level_clear_being(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    c  : TCoord2D;
    Level : TLevel;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  if State.IsNil(2) then Exit(0);
  c := State.ToCoord(2);
  if Level.Being[c] <> nil then
    Level.Kill(Level.Being[c],State.ToBoolean(3));
  Result := 0;
end;

function lua_level_recalc_fluids(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    Level : TLevel;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  if GraphicsVersion then
    Level.RecalcFluids;
  Exit( 0 );
end;

const lua_level_lib : array[0..8] of luaL_Reg = (
      ( name : 'drop_item';  func : @lua_level_drop_item),
      ( name : 'drop_being'; func : @lua_level_drop_being),
      ( name : 'player';     func : @lua_level_player),
      ( name : 'play_sound'; func : @lua_level_play_sound),
      ( name : 'nuke';       func : @lua_level_nuke),
      ( name : 'explosion';  func : @lua_level_explosion),
      ( name : 'clear_being';func : @lua_level_clear_being),
      ( name : 'recalc_fluids';func : @lua_level_recalc_fluids),
      ( name : nil;          func : nil; )
);


class procedure TLevel.RegisterLuaAPI();
begin
  TLuaMapNode.RegisterLuaAPI('level');
  LuaSystem.Register( 'level', lua_level_lib );
end;

function TLevel.CellToID ( const aCell : Byte ) : AnsiString;
begin
  Result:= LuaSystem.Get(['cells',aCell,'id']);
end;


end.

