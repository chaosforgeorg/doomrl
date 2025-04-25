{$INCLUDE doomrl.inc}
{
----------------------------------------------------
DFLEVEL.PAS -- Level data and handling for Downfall
Copyright (c) 2002 by Kornel "Anubis" Kisielewicz
----------------------------------------------------
}
unit dflevel;
interface
uses SysUtils, Classes,
     vluaentitynode, vutil, vvision, vmath, viotypes, vrltools, vnode,
     vluamapnode, vtextmap,
     dfdata, dfmap, dfthing, dfbeing, dfitem,
     doomhooks;

const CellWalls   : TCellSet = [];
      CellFloors  : TCellSet = [];

type

{ TLevel }

TLevel = class(TLuaMapNode, ITextMap)
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
     
    function blocksVision( const aCoord : TCoord2D ) : boolean; override;
	
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

    function CallHook( aHook : TCellHook; aCellID : Word; aWhat : TThing ) : Variant; overload;
    function CallHook( coord : TCoord2D;  Hook : TCellHook ) : Variant; overload;
    function CallHook( coord : TCoord2D; aCellID : Word; Hook : TCellHook ) : Variant; overload;
    function CallHook( coord : TCoord2D; What : TThing; Hook : TCellHook ) : Variant; overload;
    procedure CallHook( Hook : Byte; const Params : array of Const );
    function CallHookCheck( Hook : Byte; const Params : array of Const ) : Boolean;

    procedure DropCorpse( aCoord : TCoord2D; CellID : Byte );
    procedure DamageTile( aCoord : TCoord2D; aDamage : Integer; aDamageType : TDamageType );
    procedure Explosion( Sequence : Integer; coord : TCoord2D; Range, Delay : Integer; Damage : TDiceRoll; color : byte; ExplSound : Word; DamageType : TDamageType; aItem : TItem; aFlags : TExplosionFlags = []; aContent : Byte = 0; aDirectHit : Boolean = False; aDamageMult : Single = 1.0 );
    procedure Shotgun( source, target : TCoord2D; Damage : TDiceRoll; aDamageMul : Single; Shotgun : TShotgunData; aItem : TItem );
    procedure Respawn( aChance : byte );
    function isPassable( const aCoord : TCoord2D ) : Boolean; override;
    function isEmpty( const coord : TCoord2D; EmptyFlags : TFlags32 = []) : Boolean; override;
    function cellFlagSet( coord : TCoord2D; Flag : byte) : Boolean;
    procedure playSound( const aSoundID : DWord; aCoord : TCoord2D; aDelay : DWord = 0 ); overload;
    procedure playSound( const SoundID : string; coord : TCoord2D ); overload;
    procedure playSound( const BaseID,SoundID : string; coord : TCoord2D ); overload;
    function EnemiesVisible : Word;

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
    function getGylph( const aCoord : TCoord2D ) : TIOGylph;
    function EntityFromStream( aStream : TStream; aEntityID : Byte ) : TLuaEntityNode; override;
    constructor CreateFromStream( Stream: TStream ); override;
    procedure WriteToStream( Stream: TStream ); override;

    function EnemiesLeft( aUnique : Boolean = False ) : DWord;
    function GetLookDescription( aWhere : TCoord2D; aBeingOnly : Boolean = False ) : Ansistring;
    procedure UpdateAutoTarget( aAutoTarget : TAutoTarget; aBeing : TBeing; aRange : Integer );
    function PushItem( aWho : TBeing; aWhat : TItem; aFrom, aTo : TCoord2D ) : Boolean;
    function SwapBeings( aA, aB : TCoord2D ) : Boolean;

    class procedure RegisterLuaAPI();

  private
    function CellToID( const aCell : Byte ) : AnsiString; override;
    procedure RawCallHook( Hook : Byte; const aParams : array of const ); overload;
    function RawCallHookCheck( Hook : Byte; const aParams : array of const ) : boolean;
    function  getCell( const aWhere : TCoord2D ) : byte; override;
    procedure putCell( const aWhere : TCoord2D; const aWhat : byte ); override;
    function  getBeing( const coord : TCoord2D ) : TBeing; override;
    function  getItem( const coord : TCoord2D ) : TItem; override;
  private
    FMap           : TMap;
    FStatus        : Word; // level result
    FStyle         : Byte;

    FLNum          : Word;
    FLTime         : DWord;
    FEmpty         : Boolean;

    FDangerLevel   : Word;
    FAccuracyBonus : Integer;

    FActiveBeing   : TBeing;
    FNextNode      : TNode;

    FFloorCell     : Word;
    FFloorStyle    : Byte;
    FFeeling       : AnsiString;
    FSpecExit      : AnsiString;
  private
    function getCellBottom( Index : TCoord2D ): Byte;
    function getCellTop( Index : TCoord2D ): Byte;
    function getRotation( Index : TCoord2D ): Byte;
    function getStyle( Index : TCoord2D ): Byte;
    function getDeco( Index : TCoord2D ): Byte;
    function getSpriteTop( Index : TCoord2D ): TSprite;
    function getSpriteBottom( Index : TCoord2D ): TSprite;
  public
    property AccuracyBonus : Integer                read FAccuracyBonus;
    property Hooks : TFlags                         read FHooks;
    property FloorCell : Word                       read FFloorCell;
    property FloorStyle : Byte                      read FFloorStyle;
    property Item     [ Index : TCoord2D ] : TItem  read getItem;
    property Being    [ Index : TCoord2D ] : TBeing read getBeing;
    property CellBottom [ Index : TCoord2D ] : Byte read getCellBottom;
    property CellTop    [ Index : TCoord2D ] : Byte read getCellTop;
    property CStyle   [ Index : TCoord2D ] : Byte   read getStyle;
    property Deco     [ Index : TCoord2D ] : Byte   read getDeco;
    property Rotation [ Index : TCoord2D ] : Byte   read getRotation;

    property SpriteTop    [ Index : TCoord2D ] : TSprite read getSpriteTop;
    property SpriteBottom [ Index : TCoord2D ] : TSprite read getSpriteBottom;
  published
    property Empty        : Boolean    read FEmpty;
    property Status       : Word       read FStatus      write FStatus;
    property Name         : AnsiString read FName        write FName;
    property Name_Number  : Word       read FLNum        write FLNum;
    property Danger_Level : Word       read FDangerLevel write FDangerLevel;
    property Style        : Byte       read FStyle;
    property Special_Exit : AnsiString read FSpecExit;
    property Feeling      : AnsiString read FFeeling     write FFeeling;
    property id           : AnsiString read FID;
  end;

implementation

uses math, typinfo, vluatools, vluasystem,
     vdebug, vuid, dfplayer, doomlua, doombase, doomio, doomgfxio,
     doomspritemap, doomhudviews;

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
      IO.Msg( GetString('welcome') );
      FFeeling := GetString('welcome');
    end;
    FStatus := 0;
    FName   := GetString( 'name' );
    FLNum   := 0;
    Call('Create',[]);
    Place( Player, DropCoord( NewCoord2D(LuaPlayerX,LuaPlayerY), [ EF_NOBEINGS ] ) );
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
  Place( Player, DropCoord( NewCoord2D(LuaPlayerX,LuaPlayerY), [ EF_NOBEINGS ] ) );

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
  if EF_NOVISION in EmptyFlags then if blocksVision(coord) then Exit(False);
  if EF_NOSTAIRS in EmptyFlags then if CellHook_OnExit in Cells[Cell[coord]].Hooks then Exit(False);
  if EF_NOTELE   in EmptyFlags then if (Item[coord] <> nil) and (Item[coord].IType = ITEMTYPE_TELE) then Exit(False);
  if EF_NOHARM   in EmptyFlags then if cellFlagSet(coord,CF_HAZARD) then Exit(False);
  if EF_NOLIQUID in EmptyFlags then if cellFlagSet(coord,CF_LIQUID) then Exit(False);
  if EF_NOSAFE   in EmptyFlags then if Distance(coord,Player.Position) < PlayerSafeZone then Exit(False);
  if EF_NOSPAWN  in EmptyFlags then if LightFlag[ coord, lfNoSpawn ] then Exit(False);
end;

function TLevel.cellFlagSet( coord : TCoord2D; Flag : byte) : Boolean;
begin
  Exit(Flag in Cells[ GetCell( coord ) ].Flags);
end;

procedure TLevel.playSound( const aSoundID: DWord; aCoord : TCoord2D; aDelay : DWord = 0 );
begin
  IO.Audio.PlaySound(aSoundID, aCoord, aDelay);
end;

procedure TLevel.playSound(const SoundID: string; coord : TCoord2D );
begin
  IO.Audio.PlaySound(IO.Audio.ResolveSoundID([SoundID]), coord );
end;

procedure TLevel.playSound(const BaseID, SoundID: string; coord : TCoord2D );
begin
  IO.Audio.PlaySound(IO.Audio.ResolveSoundID([BaseID+'.'+SoundID,SoundID]), coord );
end;

function TLevel.EnemiesVisible : Word;
var iNode  : TNode;
begin
  EnemiesVisible := 0;
  for iNode in Self do
    if iNode is TBeing then
      if TBeing(iNode).isVisible then
        if not TBeing(iNode).isPlayer then
          if not TBeing(iNode).Flags[ BF_FRIENDLY ] then
            Inc(EnemiesVisible);
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

function TLevel.getGylph(const aCoord: TCoord2D): TIOGylph;
  function GetColor( aAtr : Byte; aCoord : TCoord2D; aHighlight : boolean = false ) : TIOColor;
  var Mod2    : Boolean;
      //color : TTrueColorRec;
  begin
    if aAtr > 16 then
    begin
      Mod2 := ((aCoord.x+aCoord.y) mod 2) = 0;
      case aAtr of
        COLOR_WATER : if Mod2 then aAtr := BLUE     else aAtr := LIGHTBLUE;
        COLOR_ACID  : if Mod2 then aAtr := GREEN    else aAtr := LIGHTGREEN;
        COLOR_LAVA  : if Mod2 then aAtr := YELLOW   else aAtr := RED;
        COLOR_BLOOD : if Mod2 then aAtr := LIGHTRED else aAtr := RED;
        COLOR_MUD   : if Mod2 then aAtr := YELLOW   else aAtr := BROWN;
        MULTIPORTAL : case (( Player.Statistics.GameTime div 10 ) mod 3) of
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
    iStyle    : Integer;
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
         else
         begin
           iStyle := getStyle( aCoord );
           iColor := LightColor[ iStyle ];
           if iColor = 0 then
             iColor := LightColor[ 0 ];
         end;
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

constructor TLevel.CreateFromStream( Stream: TStream );
begin
  inherited CreateFromStream( Stream );

  Stream.Read( FMap, SizeOf( FMap ) );
  FStatus := Stream.ReadWord();
  FStyle  := Stream.ReadByte();
  FLNum   := Stream.ReadWord();
  FLTime  := Stream.ReadDWord();
  Stream.Read( FEmpty, SizeOf( FEmpty ) );
  FDangerLevel := Stream.ReadWord();
  Stream.Read( FAccuracyBonus, SizeOf( FAccuracyBonus ) );
  FFloorCell   := Stream.ReadWord();
  FFloorStyle  := Stream.ReadByte();
  FID          := Stream.ReadAnsiString();
  FFeeling     := Stream.ReadAnsiString();
  FSpecExit    := Stream.ReadAnsiString();

  FActiveBeing := nil;
  FNextNode    := nil;
end;

procedure TLevel.WriteToStream( Stream: TStream );
var aID : Ansistring;
begin
  aID := FID;
  FID := 'default';
  inherited WriteToStream( Stream );

  Stream.Write( FMap, SizeOf( FMap ) );
  Stream.WriteWord( FStatus );
  Stream.WriteByte( FStyle );
  Stream.WriteWord( FLNum );
  Stream.WriteDWord( FLTime );
  Stream.Write( FEmpty, SizeOf( FEmpty ) );
  Stream.WriteWord( FDangerLevel );
  Stream.Write( FAccuracyBonus, SizeOf( FAccuracyBonus ) );
  Stream.WriteWord( FFloorCell );
  Stream.WriteByte( FFloorStyle );
  Stream.WriteAnsiString( aID );
  Stream.WriteAnsiString( FFeeling );
  Stream.WriteAnsiString( FSpecExit );

//    FActiveBeing : TBeing;
//    FNextNode    : TNode;
end;

function TLevel.EnemiesLeft( aUnique : Boolean = False ) : DWord;
var iEnemies : DWord;
    iNode    : TNode;
begin
  iEnemies := 0;
  for iNode in Self do
    if iNode is TBeing then
      if ( not TBeing(iNode).isPlayer ) and ( not iNode.Flags[ BF_FRIENDLY ] ) then
        if ( not aUnique ) or ( not iNode.Flags[ BF_RESPAWN ] ) then
          Inc( iEnemies );
  Exit( iEnemies );
end;

constructor TLevel.Create;
begin
  inherited Create('default',MaxX, MaxY, 15);

  Assert( dfdata.EF_NOBLOCK  = vluamapnode.EF_NOBLOCK );
  Assert( dfdata.EF_NOITEMS  = vluamapnode.EF_NOITEMS );
  Assert( dfdata.EF_NOBEINGS = vluamapnode.EF_NOBEINGS );
end;

procedure TLevel.Init(nStyle : byte; nLNum : Word; nName : string; nSpecExit : string; nDepth : Word; nDangerLevel : Word);
begin
  FActiveBeing := nil;
  FNextNode    := nil;

  FLTime  := 0;
  FStyle := nstyle;
  FullClear;
  FLNum := nlnum;
  FName := nname;
  FDangerLevel := nDangerLevel;
  FSpecExit := nSpecExit;
  FID := 'level'+IntToStr(nDepth);
  FFlags := [];
  FEmpty := False;
  FHooks := [];
  FFeeling := '';

  FFloorCell     := LuaSystem.Defines[LuaSystem.Get(['generator','styles',FStyle,'floor'])];
  FFloorStyle    := LuaSystem.Get(['generator','styles',FStyle,'style'],0);
  if LuaSystem.Get(['diff',Doom.Difficulty,'respawn']) then Include( FFlags, LF_RESPAWN );
  FAccuracyBonus := LuaSystem.Get(['diff',Doom.Difficulty,'accuracybonus']);
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
      if SF_MULTI in Cells[CellBottom[c]].Sprite[0].Flags then
        FMap.Rotation[c.x,c.y] := SpriteMap.GetCellRotationMask(c);

    (IO as TDoomGFXIO).UpdateMinimap;
    RecalcFluids;
    SpriteMap.NewShift := SpriteMap.ShiftValue( Player.Position );
  end;

  CallHook( Hook_OnEnterLevel,[Player.CurrentLevel,FID] );
  Player.CallHook( Hook_OnEnterLevel,[Player.CurrentLevel,FID] );

  if GraphicsVersion then
  begin
    RecalcFluids;
    SpriteMap.NewShift := SpriteMap.ShiftValue( Player.Position );
  end;

  Player.LevelEnter;

  if LF_UNIQUEITEM in FFlags then
  begin
    IO.Msg('You feel there is something really valuable here!');
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
    if not (SF_FLUID in Cells[CellBottom[ c ]].Sprite[0].Flags)
      then Exit( Value )
      else Exit( 0 );
  end;
begin
  if LF_SHARPFLUID in FFlags then Exit;
 for cc in FArea do
   if SF_FLUID in Cells[CellBottom[ cc ]].Sprite[0].Flags then
     FMap.Rotation[cc.x,cc.y] :=
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
      if RawCallHookCheck( Hook_OnCompletedCheck,[] ) then Player.Statistics.Increase('bonus_levels_completed');
    end
    else
      if EnemiesLeft() = 0 then Player.Statistics.Increase('bonus_levels_completed');


  if (not (LF_BONUS in FFlags)) and (Player.HP > 0) then
  begin
    TimeDiff :=  Player.Statistics.GameTime - Player.Statistics['entry_time'];
    if TimeDiff < 100 then
      Player.AddHistory(Format('He left level %d as soon as possible.',[Player.CurrentLevel]));
  end;

  IO.MsgReset;
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
  with FMap do
  for x := 1 to MaxX do
    for y := 1 to MaxY do
    begin
      Style[x,y]    := FFloorStyle;
      Deco[x,y]     := 0;
      Overlay[x,y]  := 0;
      Rotation[x,y] := 0;
      if (x = 1) or (y = 1) or ( x = MaxX ) or ( y = MaxY ) then LightFlag[ NewCoord2D(x,y), lfPermanent ] := True;
    end;
end;

function TLevel.CellExplored( coord: TCoord2D ): boolean;
begin
  if Player.Flags[ BF_DARKNESS ] and not isVisible( coord ) then Exit(False);
  if Player.Flags[ BF_STAIRSENSE ] and (CF_STAIRSENSE in Cells[ GetCell(coord) ].Flags) then Exit(True);
  if Option_BlindMode and not GraphicsVersion then Exit(False);
  Exit(isExplored( coord ));
end;

function TLevel.ItemVisible( coord: TCoord2D; aItem: TItem ) : boolean;
begin
  if aItem = nil then Exit(False);
  if isVisible( coord ) then Exit(True);
  if aItem.isPower and Player.Flags[ BF_POWERSENSE ] then Exit(True);
  if Player.Flags[ BF_DARKNESS ] then Exit(False);
  if ( LF_ITEMSVISIBLE in FFlags ) and ( ( not aItem.isFeature ) or ( aItem.Flags[IF_HIGHLIGHT] ) ) then Exit(True);
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
  Exit(Distance( Player.Position, coord ) <= Player.Vision + 2);
end;

{$IFDEF CORNERMAP}
function TLevel.Corner ( coord : TCoord2D ) : boolean;
begin
  Exit( LightFlag[ coord, lfCorner ] );
end;
{$ENDIF CORNERMAP}

function TLevel.CallHook( aHook: TCellHook; aCellID : Word; aWhat: TThing ) : Variant;
begin
  if aHook in Cells[ aCellID ].Hooks
    then CallHook := LuaSystem.ProtectedCall( [ 'cells', aCellID, CellHooks[ aHook ] ], [aWhat] )
    else CallHook := False;
end;

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


procedure TLevel.DamageTile( aCoord : TCoord2D; aDamage : Integer; aDamageType : TDamageType );
var iCellID  : Byte;
    iHeavy   : Boolean;
    iFeature : TItem;
    iNode    : TNode;
    iDamage  : Integer;
begin
  if not isProperCoord( aCoord )      then Exit;
  if LightFlag[ aCoord, lfPermanent ] then Exit;
  if LightFlag[ aCoord, lfFresh ]     then Exit;

  iHeavy   := aDamageType in [Damage_Acid, Damage_Fire, Damage_Plasma, Damage_SPlasma];
  iCellID  := Cell[ aCoord ];
  iFeature := Item[ aCoord ];
  if Assigned( iFeature ) and ( not iFeature.isFeature ) then
    iFeature := nil;

  if ( Cells[ iCellID ].DR > 0 ) and ( Cells[ iCellID ].DR < aDamage ) and ( iHeavy or ( CF_FRAGILE in Cells[ iCellID ].Flags ) ) then
  begin
    iDamage := aDamage - Cells[ iCellID ].DR;
    if CF_CORPSE in Cells[ iCellID ].Flags then
    case aDamageType of
      Damage_Acid    : iDamage := iDamage * 2;
      Damage_SPlasma : iDamage := iDamage * 3;
      Damage_Plasma  : iDamage := Round( iDamage * 1.5 );
    end;

    HitPoints[ aCoord ] := Max( 0, HitPoints[ aCoord ] - iDamage );
    if HitPoints[ aCoord ] = 0 then
    begin

      if CF_CORPSE in Cells[ iCellID ].Flags then
        playSound( 'gib', aCoord );

      if Cells[ iCellID ].destroyto = ''
        then Cell[ aCoord ] := FFloorCell
        else Cell[ aCoord ] := LuaSystem.Defines[ Cells[ iCellID ].destroyto ];

      CallHook( aCoord, iCellID, CellHook_OnDestroy );
    end;
  end;

  if Assigned( iFeature ) and ( iFeature.HP > 0 ) and ( iFeature.Armor < aDamage ) then
  begin
    iFeature.HP := iFeature.HP - ( aDamage - iFeature.Armor );
    if iFeature.HP <= 0 then
    begin
      SetItem( aCoord, nil );
      iFeature.Detach;
      iFeature.CallHook( Hook_OnDestroy, [ LuaCoord( aCoord ) ] );
      for iNode in iFeature do
        DropItem( iNode as TItem, aCoord );
      FreeAndNil( iFeature );
    end;
  end;
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
  aCoord := DropCoord( aCoord, [ EF_NOITEMS,EF_NOBLOCK,EF_NOSTAIRS ] );
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
  aCoord := DropCoord( aCoord, [ EF_NOTELE,EF_NOBEINGS,EF_NOBLOCK,EF_NOSTAIRS ] );
  Add( aBeing, aCoord );
  if ( not aBeing.IsPlayer ) and ( not aBeing.Flags[ BF_FRIENDLY ] ) then
  begin
    Player.FKills.MaxCount := Player.FKills.MaxCount + 1;
    if not aBeing.Flags[ BF_RESPAWN ] then Player.FKillMax := Player.FKillMax + 1;
  end;
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
    LightFlag[ aCoord, lfFresh ]     := True;
    LightFlag[ aCoord, lfPermanent ] := False;
  end;
end;

procedure TLevel.Explosion( Sequence : Integer; coord : TCoord2D; Range, Delay : Integer; Damage : TDiceRoll; color : byte; ExplSound : Word; DamageType : TDamageType; aItem : TItem; aFlags : TExplosionFlags = []; aContent : Byte = 0 ; aDirectHit : Boolean = False; aDamageMult : Single = 1.0 );
var a     : TCoord2D;
    iDamage : Integer;
    dir   : TDirection;
    iKnockbackValue : Byte;
    iItemUID : TUID;
    iNode : TNode;
begin
  if not isProperCoord( coord ) then Exit;
  if aItem <> nil then iItemUID := aItem.uid;

  IO.Explosion( Sequence, coord, Range, Delay, Color, ExplSound, aFlags );

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
        iDamage := Floor( iDamage * aDamageMult );
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
          if (Flags[BF_SPLASHIMMUNE]) and (not aDirectHit) then Continue;
          if (efSelfHalf in aFlags) and isActive then iDamage := iDamage div 2;
          if ( aItem <> nil ) and ( UIDs[ iItemUID ] = nil ) then aItem := nil;
          ApplyDamage( iDamage, Target_Torso, DamageType, aItem );
          if ( aItem <> nil ) and ( UIDs[ iItemUID ] = nil ) then aItem := nil;
        end;
        if ( iDamage > 10 ) and ( Item[a] <> nil ) and (not Item[a].isFeature) then
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

procedure TLevel.Shotgun( source, target : TCoord2D; Damage : TDiceRoll; aDamageMul : Single; Shotgun : TShotgunData; aItem : TItem );
var a,b,tc  : TCoord2D;
    d       : Single;
    dmg     : Integer;
    Range   : Byte;
    Spread  : Byte;
    Reduce  : Single;
    Dir     : TDirection;
    iNode   : TNode;
    iItemUID: TUID;
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

  iItemUID := 0;
  if aItem <> nil then iItemUID := aItem.uid;

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
        dmg := Floor( dmg * aDamageMul );

        if (dmg < 1) then dmg := 1;
        
        if Being[ tc ] <> nil then
        with Being[ tc ] do
        begin
          if KnockBacked then Continue;
          if isVisible then
          begin
            if dmg > 10 then IO.addMarkAnimation( 199, 0, tc, Shotgun.HitSprite, Red, '*' )
              else if dmg > 4 then IO.addMarkAnimation( 199, 0, tc, Shotgun.HitSprite, LightRed, '*' )
                else IO.addMarkAnimation( 199, 0, tc, Shotgun.HitSprite, LightGray, '*' );
          end;
          if dmg >= KnockBackValue then
          begin
            dir.CreateSmooth(source, tc);
            Knockback( dir, dmg div KnockBackValue );
          end;
          KnockBacked := True;
          if ( aItem <> nil ) and ( UIDs[ iItemUID ] = nil ) then aItem := nil;
          ApplyDamage( dmg, Target_Torso, Shotgun.DamageType, aItem );
          if ( aItem <> nil ) and ( UIDs[ iItemUID ] = nil ) then aItem := nil;
        end;
        
        DamageTile( tc, dmg, Shotgun.DamageType );
        if isVisible( tc ) and ( not isPassable( tc ) ) then
          IO.addMarkAnimation( 199, 0, tc, Shotgun.HitSprite, LightGray,'*' );
      end;
  ClearLightMapBits([lfDamage]);
end;


procedure TLevel.Respawn( aChance : byte );
var iCoord : TCoord2D;
    iBeing : TBeing;
begin
  if LF_NORESPAWN in FFlags then Exit;
  for iCoord in FArea do
    if Being[ iCoord ] = nil then
      if cellFlagSet( iCoord, CF_RAISABLE ) then
        if not isVisible( iCoord ) then
          if isPassable( iCoord ) then
            if Random(100) < aChance then
            try
              iBeing := TBeing.Create( Cells[ GetCell(iCoord) ].raiseto );
              iBeing.Flags[ BF_RESPAWN ] := True;
              DropBeing( iBeing, iCoord );
              iBeing.Flags[ BF_NOEXP   ] := True;
              iBeing.Flags[ BF_NODROP ]  := True;
              Cell[ iCoord ] := LuaSystem.Defines[ Cells[ GetCell(iCoord) ].destroyto ];
            except
              on EPlacementException do FreeAndNil( iBeing );
            end;

end;

function TLevel.isPassable ( const aCoord : TCoord2D ) : Boolean;
var iItem : TItem;
begin
  if cellFlagSet( aCoord, CF_BLOCKMOVE ) then Exit( False );
  iItem := GetItem( aCoord );
  if Assigned( iItem ) and iItem.Flags[ IF_BLOCKMOVE ] then Exit( False );
  Exit( True );
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
var iEnemiesLeft : Integer;
begin
  if aBeing = nil then Exit;
  if Being[ aBeing.Position ] = aBeing then
    SetBeing( aBeing.Position, nil );

  if (Doom.State = DSPlaying) and (not Silent) then
  begin
    CallHook(Hook_OnKill,[ aBeing ]);
  end;

  FreeAndNil(aBeing);
  if Doom.State <> DSPlaying then Exit;

  iEnemiesLeft := EnemiesLeft();
  if ( iEnemiesLeft < 4 ) and ( not ( LF_BONUS in FFlags ) ) and ( not ( LF_BOSS in FFlags ) ) then
    Include( FFlags, LF_BEINGSVISIBLE );

  if not Silent then
  begin
    if iEnemiesLeft = 0 then
    begin
      CallHook(Hook_OnKillAll,[]);
      if (not (LF_RESPAWN in FFlags)) and ( EnemiesLeft() = 0 ) then
      begin
        if not (Hook_OnKillAll in FHooks) then
          IO.Msg('You feel relatively safe now.');
        FEmpty := True;
        if ( not ( LF_BONUS in FFlags ) ) and ( not ( LF_BOSS in FFlags ) ) then
          Include( FFlags, LF_ITEMSVISIBLE );
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
var iNode : TNode;
begin
  FActiveBeing := nil;
  repeat

    Inc(FLTime);
    Player.Statistics.OnTick;

    CallHook( Hook_OnTick,[ FLTime ] );

    if LF_RESPAWN in FFlags  then
    begin
      if FLTime mod 100 = 0 then
        if ((FLTime div 100)+20) > DWord(Random(100)) then
          Respawn( Min( (FLTime div 1000) + 10, 100 ) );
    end;

    NukeTick;

    if Doom.State = DSPlaying then
    begin
      for iNode in Self do
        if iNode is TBeing then
            TBeing(iNode).Tick;
    end;

    if Doom.State = DSPlaying then
    begin
      iNode := Child;
      if iNode <> nil then
      repeat
        FNextNode    := iNode.Next;
        FActiveBeing := nil;
        if iNode is TBeing then
          if TBeing(iNode).SCount >= 5000 then
            if not TBeing(iNode).isPlayer then
              begin
                FActiveBeing := TBeing(iNode);
                FActiveBeing.Action;
              end;
        if Doom.State <> DSPlaying then Break;
        iNode := FNextNode;
      until (iNode = Child) or (iNode = nil);
    end;
    FActiveBeing := nil;

  until ( Doom.State <> DSPlaying ) or ( Player.SCount > 5000 );
  if Doom.State = DSPlaying then
  begin
    CRASHMODE    := False;
    FActiveBeing := Player;
  end;
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
      if (Nuke <= 100)   then begin if (Nuke mod 10  = 0) then IO.Msg('Warning! Explosion in %d seconds!',[Player.NukeActivated div 10]); end else
      if (Nuke <= 10*60) then begin if (Nuke mod 100 = 0) then IO.Msg('Warning! Explosion in %d seconds!',[Player.NukeActivated div 10]); end else
      if (Nuke mod (10*60) = 0) then IO.Msg('Warning! Explosion in %d minutes!',[Player.NukeActivated div 600]);
    end
    else
    begin
      Player.Statistics.Increase('levels_nuked');
      if Doom.State in [DSNextLevel,DSSaving] then
      begin
        IO.Msg('Right in the nick of time!');
        IO.PushLayer( TMoreLayer.Create( False ) );
        IO.WaitForLayer( False );
        Exit;
      end;
      for cn := 1 to 10 do
      begin
        Explosion( cn*200, RandomCoord( [ EF_NOBLOCK ] ),8,10,NewDiceRoll(0,0,0),LightRed,IO.Audio.ResolveSoundID(['nuke','barrel.explode','explode']){}{}{}{}{}{}{}{}{}, Damage_Fire, nil);
        IO.Blink(LightRed,40);
        IO.Blink(White,40);
      end;
      IO.Blink(White,2000);

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

function TLevel.blocksVision( const aCoord : TCoord2D ) : Boolean;
var iItem : TItem;
begin
  if not isProperCoord( aCoord )        then Exit( True );
  if cellFlagSet( aCoord, CF_BLOCKLOS ) then Exit( True );
  iItem := GetItem( aCoord );
  if Assigned( iItem ) and iItem.Flags[ IF_BLOCKLOS ] then Exit( True );
  Exit( False );
end;

function TLevel.getCell( const aWhere : TCoord2D ) : byte;
var iOverlay : Word;
begin
  iOverlay := FMap.Overlay[aWhere.x, aWhere.y];
  if iOverlay <> 0 then Exit( iOverlay );
  Result := inherited GetCell( aWhere );
end;

procedure TLevel.putCell( const aWhere : TCoord2D; const aWhat : byte );
begin
  if CF_OVERLAY in Cells[ aWhat ].Flags
  then
     FMap.Overlay[aWhere.x, aWhere.y] := aWhat
  else
  begin
    inherited PutCell( aWhere, aWhat );
    FMap.Overlay[aWhere.x, aWhere.y] := 0;
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
  Exit( FMap.Overlay[Index.x, Index.y] );
end;

function TLevel.getRotation( Index : TCoord2D ): Byte;
begin
  Exit( FMap.Rotation[Index.x, Index.y] );
end;

function TLevel.getStyle( Index : TCoord2D ): Byte;
begin
  Exit( FMap.Style[Index.x, Index.y] );
end;

function TLevel.getDeco( Index : TCoord2D ): Byte;
begin
  Exit( FMap.Deco[Index.x, Index.y] );
end;

function TLevel.getSpriteTop( Index : TCoord2D ): TSprite;
var iCell  : TCell;
    iStyle : Byte;
begin
  iCell   := Cells[ getCellTop( Index ) ];
  iStyle  := getStyle( Index );
  if iCell.Sprite[ iStyle ].SpriteID[0] <> 0 then;
    Exit( iCell.Sprite[ iStyle ] );
  Exit( iCell.Sprite[ iStyle ] );
end;

function TLevel.getSpriteBottom( Index : TCoord2D ): TSprite;
var iCell  : TCell;
    iStyle : Byte;
begin
  iCell   := Cells[ getCellBottom( Index ) ];
  iStyle  := getStyle( Index );
  if iCell.Sprite[ iStyle ].SpriteID[0] <> 0 then;
    Exit( iCell.Sprite[ iStyle ] );
  Exit( iCell.Sprite[ iStyle ] );
end;

procedure TLevel.UpdateAutoTarget( aAutoTarget : TAutoTarget; aBeing : TBeing; aRange : Integer );
var iCoord : TCoord2D;
    iBeing : TBeing;
begin
  aAutoTarget.Clear( aBeing.Position );
  for iCoord in NewArea( aBeing.Position, aRange ).Clamped( Area ) do
  begin
    iBeing := Being[ iCoord ];
    if ( iBeing <> nil ) and ( iBeing <> aBeing ) then
    begin
      if ( aBeing = Player ) then
      begin
        if not iBeing.isVisible then Continue;
        if iBeing.Flags[ BF_FRIENDLY ] then Continue;
      end;
      aAutoTarget.AddTarget( iCoord );
    end;
  end;
end;

function TLevel.PushItem( aWho : TBeing; aWhat : TItem; aFrom, aTo : TCoord2D ) : Boolean;
var iItemOld : TItem;
begin
  if ( aWho = nil ) or ( aWhat = nil ) or ( aWhat.Position <> aFrom ) then Exit( False );
  IO.addMoveAnimation( aWho.VisualTime( aWho.getMoveCost, AnimationSpeedPush ), 0, aWhat.UID, aFrom, aTo, aWhat.Sprite, False );
  iItemOld := Item[ aTo ];
  SetItem( aTo, aWhat );
  SetItem( aFrom, nil );
  aWhat.Position := aTo;
  if Assigned( iItemOld ) then
  begin
    SetItem( aFrom, iItemOld );
    iItemOld.Position := aFrom;
  end;
  aWho.ActionMove( aFrom, AnimationSpeedPush / AnimationSpeedMove );
end;

function TLevel.SwapBeings( aA, aB : TCoord2D ) : Boolean;
var iAB, iBB : TBeing;
    iAS, iBS : LongInt;
begin
  iAB := GetBeing( aA );
  iBB := GetBeing( aB );
  if ( not Assigned( iAB ) ) or ( not Assigned( iBB ) ) then Exit( False );
  iAS := iAB.SCount;
  iBS := iBB.SCount;
  SetBeing( aB, nil );
  iAB.ActionMove( aB );
  iBB.ActionMove( aA );
  iAB.SCount := iAS;
  iBB.SCount := iBS;
  Exit( True );
end;

function TLevel.GetLookDescription ( aWhere : TCoord2D; aBeingOnly : Boolean = False ) : AnsiString;
var iCellID : DWord;
  procedure AddInfo( const what : AnsiString );
  begin
    if Result = '' then Result := what
                   else Result += ' | ' + what;
  end;
begin
  if isVisible( aWhere ) then
  begin
    Result := '';
    if Being[ aWhere ] <> nil then
    with Being[ aWhere ] do
      AddInfo( GetName( false ) + ' (' + WoundStatus + ')' );
    if aBeingOnly then Exit;
    if Item[ aWhere ] <> nil then AddInfo( Item[ aWhere ].GetExtName( False ) );
    if CellHook_OnDescribe in Cells[ Cell[ aWhere ] ].Hooks then
       AddInfo( CallHook( aWhere, CellHook_OnDescribe ) )
    else
    begin
      iCellID := GetCell(aWhere);
      if LightFlag[ aWhere, LFBLOOD ] and (Cells[ iCellID ].bldesc <> '')
        then AddInfo( Cells[ GetCell(aWhere) ].bldesc )
        else AddInfo( Cells[ GetCell(aWhere) ].desc );
    end;
  end
  else Result := 'out of vision';
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
var iState : TDoomLuaState;
    iLevel : TLevel;
begin
  iState.Init(L);
  iLevel := iState.ToObject(1) as TLevel;
  if iState.IsString(3)
    then iLevel.playSound( iState.ToString(2), iState.ToString(3), iState.ToPosition(4) )
    else iLevel.playSound( IO.Audio.ResolveSoundID( [iState.ToString(2)] ), iState.ToPosition(3), iState.ToInteger(4,0) );
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
    IO.Blink(LightRed,40);
    IO.Blink(White,40);
  end;
  IO.Blink(White,1000);
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
  if (State.StackSize >= 8 ) and (not State.IsNil(8))  then Sound   := IO.Audio.ResolveSoundID( [State.ToString(8)] );

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

function lua_level_animate_cell(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    iCoord  : TCoord2D;
    iLevel  : TLevel;
    iValue  : Integer;
    iSprite : TSprite;
begin
  State.Init(L);
  iLevel := State.ToObject(1) as TLevel;
  if State.IsNil(2) then Exit(0);
  iCoord := State.ToCoord(2);
  iValue := State.ToInteger(3);
  if iLevel.isVisible( iCoord ) then
  begin
    iSprite := iLevel.GetSpriteTop( iCoord );
    IO.addCellAnimation( iSprite.Frametime * Abs( iValue ), 0, iCoord, iSprite, iValue );
  end;
  Result := 0;
end;

function lua_level_animate_item(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    iItem   : TItem;
    iLevel  : TLevel;
    iValue  : Integer;
begin
  State.Init(L);
  iLevel := State.ToObject(1) as TLevel;
  if State.IsNil(2) then Exit(0);
  iItem  := State.ToObject(2) as TItem;
  iValue := State.ToInteger(3);
  if iLevel.isVisible( iItem.Position ) then
    IO.addItemAnimation( iItem.Sprite.Frametime * Abs( iValue ), 0, iItem, iValue );
  Result := 0;
end;

function lua_level_set_generator_style(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    iCoord  : TCoord2D;
    iLevel  : TLevel;
begin
  State.Init(L);
  iLevel := State.ToObject(1) as TLevel;
  if State.IsNil(2) then Exit(0);
  iLevel.FStyle := State.ToInteger(2);
  iLevel.FFloorCell := LuaSystem.Defines[LuaSystem.Get(['generator','styles',iLevel.FStyle,'floor'])];
  iLevel.FFloorStyle := LuaSystem.Get(['generator','styles',iLevel.FStyle,'style'], 0);
  for iCoord in iLevel.FArea do
  begin
    iLevel.FMap.Style[iCoord.X,iCoord.Y] := iLevel.FFloorStyle;
  end;
  Result := 0;
end;

function lua_level_set_raw_style(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    iCoord  : TCoord2D;
    iLevel  : TLevel;
    iValue  : Byte;
begin
  State.Init(L);
  iLevel := State.ToObject(1) as TLevel;
  if State.IsNil(2) then Exit(0);
  iCoord := State.ToCoord(2);
  iValue := State.ToInteger(3);
  iLevel.FMap.Style[iCoord.X,iCoord.Y] := iValue;
  Result := 0;
end;

function lua_level_get_raw_style(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    iCoord  : TCoord2D;
    iLevel  : TLevel;
begin
  State.Init(L);
  iLevel := State.ToObject(1) as TLevel;
  if State.IsNil(2) then Exit(0);
  iCoord := State.ToCoord(2);
  State.Push( iLevel.FMap.Style[iCoord.X,iCoord.Y] );
  Result := 1;
end;


function lua_level_set_raw_deco(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    iCoord  : TCoord2D;
    iLevel  : TLevel;
    iValue  : Byte;
begin
  State.Init(L);
  iLevel := State.ToObject(1) as TLevel;
  if State.IsNil(2) then Exit(0);
  iCoord := State.ToCoord(2);
  iValue := State.ToInteger(3);
  iLevel.FMap.Deco[iCoord.X,iCoord.Y] := iValue;
  Result := 0;
end;

function lua_level_get_raw_deco(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    iCoord  : TCoord2D;
    iLevel  : TLevel;
begin
  State.Init(L);
  iLevel := State.ToObject(1) as TLevel;
  if State.IsNil(2) then Exit(0);
  iCoord := State.ToCoord(2);
  State.Push( iLevel.FMap.Deco[iCoord.X,iCoord.Y] );
  Result := 1;
end;

function lua_level_damage_tile(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    Level : TLevel;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  Level.DamageTile( State.ToCoord(2), State.ToInteger(3), TDamageType( State.ToInteger(4,Byte(Damage_Bullet)) ) );
  Exit( 0 );
end;

function lua_level_push_item(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    Level : TLevel;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  Level.PushItem( State.ToObject(2) as TBeing, State.ToObject(3) as TItem, State.ToCoord(4), State.ToCoord(5) );
  Exit( 0 );
end;

function lua_level_reset(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    Level : TLevel;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  Level.Clear;
  Level.FullClear;
  Exit( 0 );
end;

function lua_level_post_generate(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    Level : TLevel;
begin
  State.Init(L);
  IO.MsgUpDate;
  Level := State.ToObject(1) as TLevel;
  Level.AfterGeneration( False );
  Level.PreEnter;
  Level.CalculateVision( Player.Position );
  Player.PreAction;
  Exit( 0 );
end;

const lua_level_lib : array[0..19] of luaL_Reg = (
      ( name : 'drop_item';  func : @lua_level_drop_item),
      ( name : 'drop_being'; func : @lua_level_drop_being),
      ( name : 'player';     func : @lua_level_player),
      ( name : 'play_sound'; func : @lua_level_play_sound),
      ( name : 'nuke';       func : @lua_level_nuke),
      ( name : 'explosion';  func : @lua_level_explosion),
      ( name : 'clear_being';func : @lua_level_clear_being),
      ( name : 'recalc_fluids';func : @lua_level_recalc_fluids),
      ( name : 'animate_cell'; func : @lua_level_animate_cell),
      ( name : 'animate_item'; func : @lua_level_animate_item),
      ( name : 'set_generator_style';func : @lua_level_set_generator_style),
      ( name : 'set_raw_style';      func : @lua_level_set_raw_style),
      ( name : 'get_raw_style';      func : @lua_level_get_raw_style),
      ( name : 'set_raw_deco';      func : @lua_level_set_raw_deco),
      ( name : 'get_raw_deco';      func : @lua_level_get_raw_deco),
      ( name : 'damage_tile';func : @lua_level_damage_tile),
      ( name : 'push_item';  func : @lua_level_push_item),
      ( name : 'reset';         func : @lua_level_reset),
      ( name : 'post_generate'; func : @lua_level_post_generate),
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

