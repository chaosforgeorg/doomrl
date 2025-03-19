{$INCLUDE doomrl.inc}
{
----------------------------------------------------
DFBEING.PAS -- Creature control and data in DownFall
Copyright (c) 2002 by Kornel "Anubis" Kisielewicz
----------------------------------------------------
}
unit dfbeing;
interface
uses Classes, SysUtils,
     vluatable, vnode, vpath, vmath, vutil, vrltools,
     dfdata, dfthing, dfitem, dfaffect,
     doominventory, doomcommand;

type TMoveResult = ( MoveOk, MoveBlock, MoveDoor, MoveBeing );

type TBonuses = record
  ToHit           : Integer;
  ToDam           : Integer;
  ToDamAll        : Integer;
  ToHitMelee      : Integer;
  Pistol          : Integer;
  Rapid           : Integer;
  Body            : Integer;
  Tech            : Integer;
  Dodge           : Integer;
  Move            : Integer;
  Defence         : Integer;
  MulDamage       : Integer;
  MulDamageMelee  : Integer;
  MulDamageRanged : Integer;
end;

type TBeingTimes = record
  Reload : Byte;
  Fire   : Byte;
  Move   : Byte;
end;

type

{ TBeing }

TBeing = class(TThing,IPathQuery)
    constructor Create( nid : byte ); overload;
    constructor Create( const nid : AnsiString ); overload;
    constructor CreateFromStream( Stream: TStream ); override;
    procedure WriteToStream( Stream: TStream ); override;
    procedure Initialize;
    function GetName( known : boolean ) : string;
    procedure Tick;
    procedure Action; virtual;
    procedure HandlePostMove; virtual;
    procedure HandlePostDisplace;
    function HandleCommand( aCommand : TCommand ) : Boolean;
    function  TryMove( aWhere : TCoord2D ) : TMoveResult;
    function  MoveTowards( aWhere : TCoord2D; aVisualMultiplier : Single = 1.0 ) : TMoveResult;
    procedure Reload( AmmoItem : TItem; Single : Boolean );
    procedure Ressurect( RRange : Byte );
    procedure Kill( aBloodAmount : DWord; aOverkill : Boolean; aKiller : TBeing; aWeapon : TItem ); virtual;
    procedure Blood( aFrom : TDirection; aAmount : LongInt );
    procedure Attack( aWhere : TCoord2D ); overload;
    procedure Attack( aTarget : TBeing; Second : Boolean = False ); overload;
    function meleeWeaponSlot : TEqSlot;
    function getTotalResistance( const aResistance : AnsiString; aTarget : TBodyTarget ) : Integer;
    procedure ApplyDamage( aDamage : LongInt; aTarget : TBodyTarget; aDamageType : TDamageType; aSource : TItem ); virtual;
    function SendMissile( aTarget : TCoord2D; aItem : TItem; aSequence : DWord; aDamageMod, aToHitMod, aShotCount, aDamageMult : Integer ) : Boolean;
    function  isActive : boolean;
    function  WoundStatus : string;
    function  IsPlayer : Boolean;

    procedure BloodFloor;
    procedure Knockback( dir : TDirection; Strength : Integer );
    destructor Destroy; override;
    function rollMeleeDamage( aSlot : TEqSlot = efWeapon ) : Integer;
    function getMoveCost : LongInt;
    function getFireCost( aAltFire : TAltFire = ALT_NONE ) : LongInt;
    function getReloadCost : LongInt;
    function getDodgeMod : LongInt;
    function getKnockMod : LongInt;
    function getToHitMelee( Item : TItem ) : Integer;
    function getToHitRanged( Item : TItem ) : Integer;
    function canDualGun : boolean;
    function canDualBlade : boolean;
    function canDualReload : Boolean;
    function canPackReload : Boolean;
    function getStrayChance( aDefender : TBeing; aMissile : Byte ) : Byte;
    function Preposition( Creature : AnsiString ) : string;
    function Dead : Boolean;
    procedure Remove( Node : TNode ); override;
    function ASCIIMoreCode : AnsiString; virtual;

    // Actions
    // All actions return True/False depending on success.
    // On success they do eat up action cost!
    function ActionSwapWeapon : boolean;
    function ActionQuickKey( aIndex : Byte ) : Boolean;
    function ActionQuickWeapon( const aWeaponID : Ansistring ) : Boolean;
    function ActionDrop( Item : TItem ) : boolean;
    function ActionWear( aItem : TItem ) : boolean;
    function ActionSwap( aItem : TItem; aSlot : TEqSlot ) : boolean;
    function ActionTakeOff( aSlot : TEqSlot ) : boolean;
    function ActionReload : Boolean;
    function ActionDualReload : Boolean;
    function ActionAltReload : Boolean;
    function ActionFire( aTarget : TCoord2D; aWeapon : TItem; aAltFire : Boolean = False ) : Boolean;
    function ActionPickup : Boolean;
    function ActionUse( aItem : TItem ) : Boolean;
    function ActionUnLoad( aItem : TItem; aDisassembleID : AnsiString = '' ) : Boolean;
    function ActionMove( aTarget : TCoord2D; aVisualMultiplier : Single = 1.0 ) : Boolean;
    function ActionSwapPosition( aTarget : TCoord2D ) : Boolean;
    function ActionActive : boolean;
    function ActionAction( aTarget : TCoord2D ) : Boolean;

    // Always returns False.
    //
    // aText (VFormatted with aParams is emoted if Being is player.
    function Fail( const aText : AnsiString; const aParams : array of Const ) : Boolean;

    // Always returns True.
    //
    // aText (VFormatted with aParams is emoted if Being is player.
    function Success( const aText : AnsiString; const aParams : array of Const; aCost : DWord = 0 ) : Boolean;

    // Always returns True.
    //
    // aPlayerText (VFormatted with aParams is emoted if Being is player, aBeingText (same format) otherwise.
    function Success( const aPlayerText, aBeingText : AnsiString; const aParams : array of Const; aCost : DWord = 0 ) : Boolean;

    procedure Emote( const aPlayerText, aBeingText : AnsiString; const aParams : array of Const );

    function MoveCost( const Start, Stop : TCoord2D ) : Single;
    function CostEstimate( const Start, Stop : TCoord2D ) : Single;
    function passableCoord( const aCoord : TCoord2D ) : boolean;
    function VisualTime( aActionCost : Word = 1000; aBaseTime : Word = 100 ) : Word;

    class procedure RegisterLuaAPI();

  protected
    procedure LuaLoad( Table : TLuaTable ); override;
    // private
    function FireRanged( aTarget : TCoord2D; aGun : TItem; aAlt : TAltFire = ALT_NONE ) : Boolean;
    function getAmmoItem( Weapon : TItem ) : TItem;
    function HandleShotgunFire( aTarget : TCoord2D; aShotGun : TItem; aShots : DWord ) : Boolean;
    function HandleSpreadShots( aTarget : TCoord2D; aGun : TItem ) : Boolean;
    function HandleShots( aTarget : TCoord2D; aGun : TItem; aShots : DWord; toHit, toDam : Integer; iChaining : Boolean ) : Boolean;

  protected
    FHPNom         : Word;
    FHPMax         : Word;
    FHPDecayMax    : Word;

    FBonus         : TBonuses;
    FTimes         : TBeingTimes;
    FLastCommand   : TCommand;

    FVisionRadius  : Byte;
    FSpeedCount    : LongInt;
    FSpeed         : Byte;
    FExpValue      : Word;

    FMeleeAttack   : Boolean;
    FSilentAction  : Boolean;
    FTargetPos     : TCoord2D;
    FInv           : TInventory;
    FMovePos       : TCoord2D;
    FLastPos       : TCoord2D;
    FBloodBoots    : Byte;
    FChainFire     : Byte;
    FPath          : TPathFinder;
    FPathHazards   : TFlags;
    FPathClear     : TFlags;
    FKnockBacked   : Boolean;
    FAnimSeq       : Integer;
    FAffects       : TAffects;
  public
    property Affects   : TAffects    read FAffects;
    property Inv       : TInventory  read FInv       write FInv;
    property TargetPos : TCoord2D    read FTargetPos write FTargetPos;
    property LastPos   : TCoord2D    read FLastPos   write FLastPos;
    property LastMove  : TCoord2D    read FMovePos   write FMovePos;

    property KnockBacked  : Boolean read FKnockBacked  write FKnockBacked;
    property SilentAction : Boolean read FSilentAction write FSilentAction;
    property MeleeAttack  : Boolean read FMeleeAttack;
    property ChainFire    : Byte    read FChainFire    write FChainFire;
  published

    property can_dual_reload : Boolean read canDualReload;
    property HPMax        : Word       read FHPMax        write FHPMax;
    property HPNom        : Word       read FHPNom        write FHPNom;

    property Vision       : Byte       read FVisionRadius write FVisionRadius;
    property SCount       : LongInt    read FSpeedCount   write FSpeedCount;
    property AnimSeq      : Integer    read FAnimSeq      write FAnimSeq;

    property ToHit        : Integer    read FBonus.ToHit        write FBonus.ToHit;
    property ToDam        : Integer    read FBonus.ToDam        write FBonus.ToDam;
    property ToDamAll     : Integer    read FBonus.ToDamAll     write FBonus.ToDamAll;
    property ToHitMelee   : Integer    read FBonus.ToHitMelee   write FBonus.ToHitMelee;

    property Speed        : Byte       read FSpeed         write FSpeed;
    property ExpValue     : Word       read FExpValue      write FExpValue;

    property TechBonus       : Integer read FBonus.Tech            write FBonus.Tech;
    property PistolBonus     : Integer read FBonus.Pistol          write FBonus.Pistol;
    property RapidBonus      : Integer read FBonus.Rapid           write FBonus.Rapid;
    property BodyBonus       : Integer read FBonus.Body            write FBonus.Body;
    property DodgeBonus      : Integer read FBonus.Dodge           write FBonus.Dodge;
    property MoveBonus       : Integer read FBonus.Move            write FBonus.Move;
    property DefenceBonus    : Integer read FBonus.Defence         write FBonus.Defence;
    property MulDamage       : Integer read FBonus.MulDamage       write FBonus.MulDamage;
    property MulDamageMelee  : Integer read FBonus.MulDamageMelee  write FBonus.MulDamageMelee;
    property MulDamageRanged : Integer read FBonus.MulDamageRanged write FBonus.MulDamageRanged;

    property HPDecayMax   : Word       read FHPDecayMax    write FHPDecayMax;

    property ReloadTime   : Byte       read FTimes.Reload  write FTimes.Reload;
    property FireTime     : Byte       read FTimes.Fire    write FTimes.Fire;
    property MoveTime     : Byte       read FTimes.Move    write FTimes.Move;
  end;


implementation

uses math, vlualibrary, vluaentitynode, vuid, vdebug, vvision, vluasystem, vluatools,
     dfplayer, dflevel, dfmap, doomhooks,
     doomlua, doombase, doomio;

function TBeing.getStrayChance( aDefender : TBeing; aMissile : Byte ) : Byte;
var iMiss : Integer;
begin
  if IsPlayer        then Exit(0);
  if aDefender = nil then Exit(0);

  iMiss := Missiles[ aMissile ].MissBase +
          Missiles[ aMissile ].MissDist *
          Distance( FPosition, aDefender.FPosition );

  if aDefender.IsPlayer then
  begin
    if (Player.Flags[ BF_MASTERDODGE ]) and (not Player.MasterDodge) then
    begin
      Player.MasterDodge := true;
      Exit(100);
    end;
  end;

  iMiss += aDefender.getDodgeMod;
  Exit( Clamp( iMiss, 0, 95 ) );
end;

constructor TBeing.Create(nid : byte);
var Table : TLuaTable;
begin
  inherited Create( LuaSystem.Get( ['beings', nid, 'id'] ) );
  FEntityID := ENTITY_BEING;
  Table := LuaSystem.GetTable( ['beings', nid] );
  LuaLoad( Table );
  FreeAndNil( Table );
end;

constructor TBeing.Create( const nid: AnsiString );
var Table : TLuaTable;
begin
  inherited Create( nid );
  FEntityID := ENTITY_BEING;
  Table := LuaSystem.GetTable(['beings', nid]);
  LuaLoad( Table );
  FreeAndNil( Table );
end;

constructor TBeing.CreateFromStream ( Stream : TStream ) ;
var Slot   : TEqSlot;
    Amount : Byte;
    c      : Byte;
begin
  inherited CreateFromStream ( Stream ) ;

  Initialize;

  FHPMax      := Stream.ReadWord();
  FHPNom      := Stream.ReadWord();
  FHPDecayMax := Stream.ReadWord();

  Stream.Read( FBonus,       SizeOf( FBonus ) );
  Stream.Read( FTimes,       SizeOf( FTimes ) );
  Stream.Read( FLastCommand, SizeOf( FLastCommand ) );

  FVisionRadius := Stream.ReadByte();
  FSpeedCount   := Stream.ReadWord();
  FSpeed        := Stream.ReadByte();
  FExpValue     := Stream.ReadWord();

  FAffects := TAffects.CreateFromStream( Stream, Self );

  Amount := Stream.ReadByte;
  for c := 1 to Amount do
    FInv.Add( TItem.CreateFromStream( Stream ) );
  for slot in TEqSlot do
    if Stream.ReadByte <> 0 then
      FInv.RawSetSlot(slot,TItem.CreateFromStream( Stream ));
end;

procedure TBeing.WriteToStream ( Stream : TStream ) ;
var Item : TItem;
    Slot : TEqSlot;
begin
  inherited WriteToStream ( Stream ) ;

  Stream.WriteWord( FHPMax );
  Stream.WriteWord( FHPNom );
  Stream.WriteWord( FHPDecayMax );

  Stream.Write( FBonus,       SizeOf( FBonus ) );
  Stream.Write( FTimes,       SizeOf( FTimes ) );
  Stream.Write( FLastCommand, SizeOf( FLastCommand ) );

  Stream.WriteByte( FVisionRadius );
  Stream.WriteWord( FSpeedCount );
  Stream.WriteByte( FSpeed );
  Stream.WriteWord( FExpValue );

  FAffects.WriteToStream( Stream );

  Stream.WriteByte( FInv.Size );
  for Item in FInv do
    if not FInv.Equipped( Item ) then
      Item.WriteToStream( Stream );
  for slot in TEqSlot do
    if FInv.Slot[ slot ] = nil
      then Stream.WriteByte(0)
      else
      begin
        Stream.WriteByte(1);
        FInv.Slot[ slot ].WriteToStream(Stream);
      end;
end;

procedure TBeing.Initialize;
begin
  FInv := TInventory.Create( Self );
  FPath := nil;

  FTargetPos.Create(1,1);
  FLastPos.Create(1,1);
  FMovePos.Create(1,1);
  FLastCommand.Command := 0;

  FBloodBoots   := 0;
  FChainFire    := 0;
  FAnimSeq      := 0;

  FSilentAction := False;
  FKnockBacked  := False;
  FMeleeAttack  := False;
end;

procedure TBeing.LuaLoad( Table : TLuaTable );
begin
  inherited LuaLoad( Table );
  Initialize;
  FAffects := TAffects.Create( Self );

  FHooks := FHooks * BeingHooks;

  FBonus.ToHit      := Table.getInteger('tohit');
  FBonus.ToHitMelee := Table.getInteger('tohitmelee');
  FBonus.ToDam      := Table.getInteger('todam');
  FTimes.Move       := Table.getInteger('movetime',100);
  FTimes.Fire       := Table.getInteger('firetime',100);
  FTimes.Reload     := Table.getInteger('reloadtime',100);
  FExpValue         := Table.getInteger('xp');

  FSpeed      := Table.getInteger('speed');

  FVisionRadius := VisionBaseValue + Table.getInteger('vision');

  Flags[ BF_WALKSOUND ] := ( IO.Audio.ResolveSoundID( [ FID+'.hoof', FSoundID+'.hoof' ] ) <> 0 );

  FHPMax := FHP;
  FHPNom := FHP;
  FSpeedCount := 900+Random(90);

  FBonus.Pistol := 0;
  FBonus.Rapid  := 0;
  FBonus.Tech   := 0;
  FBonus.Body   := 0;
  FBonus.Dodge  := 0;
  FBonus.Move   := 0;
  FBonus.Defence:= 0;
  FBonus.MulDamage       := 0;
  FBonus.MulDamageMelee  := 0;
  FBonus.MulDamageRanged := 0;

  FHPDecayMax   := 100;

  if not isPlayer then
    CallHook(Hook_OnCreate,[]);
end;

function TBeing.getAmmoItem ( Weapon : TItem ) : TItem;
begin
  if Weapon = nil then Exit( nil );
  if ( Weapon = FInv.Slot[ efWeapon ] ) and canPackReload then Exit( FInv.Slot[ efWeapon2 ] );
  Exit( FInv.SeekAmmo( Weapon.AmmoID ) );
end;

function TBeing.HandleShotgunFire( aTarget : TCoord2D; aShotGun : TItem; aShots : DWord ) : Boolean;
var iThisUID  : DWord;
    iDual     : Boolean;
    iCount    : DWord;
    iShotgun  : TShotgunData;
    iDamage   : TDiceRoll;
begin
  Assert( aShotGun <> nil );
  Assert( aShotGun.Flags[ IF_SHOTGUN ] );
  iThisUID := FUID;
  aShots    := Max( aShots, 1 );

  iDual := aShotGun.Flags[ IF_DUALSHOTGUN ];
  if iDual then aShotgun.PlaySound( 'fire', FPosition );

  iDamage.Init( aShotGun.Damage_Dice, aShotGun.Damage_Sides, aShotGun.Damage_Add + FBonus.ToDamAll );
  if BF_MAXDAMAGE in FFlags then iDamage.Init( 0, 0, iDamage.Max );

  for iCount := 1 to aShots do
  begin
    if not iDual then aShotGun.PlaySound( 'fire', FPosition );
    iShotgun := Shotguns[ aShotGun.Missile ];
    iShotgun.DamageType := aShotGun.DamageType;
    if (BF_ARMYDEAD in FFlags) and (iShotgun.DamageType = DAMAGE_SHARPNEL) then iShotgun.DamageType := Damage_IgnoreArmor;
    TLevel(Parent).ShotGun( FPosition, aTarget, iDamage, iShotgun, aShotgun );
    if UIDs[ iThisUID ] = nil then Exit( false );
    if (not iDual) and (aShotGun.Shots > 1) then IO.Delay(30);
  end;
  Exit( true );
end;

function TBeing.HandleSpreadShots( aTarget : TCoord2D; aGun : TItem ) : Boolean;
var iLevel : TLevel;
begin
  iLevel := TLevel(Parent);
  Assert( aGun <> nil );
  if TLevel(Parent).Being[ aTarget ] <> nil then aTarget := TLevel(Parent).Being[ aTarget ].FLastPos;
  if not SendMissile( iLevel.Area.Clamped(NewCoord2D(aTarget.x+Sgn(aTarget.y-FPosition.y),aTarget.y-Sgn(aTarget.x-FPosition.x))),aGun,10,FBonus.ToDamAll,0,0,FBonus.MulDamage + FBonus.MulDamageRanged ) then Exit( False );
  if not SendMissile( iLevel.Area.Clamped(NewCoord2D(aTarget.x-Sgn(aTarget.y-FPosition.y),aTarget.y+Sgn(aTarget.x-FPosition.x))),aGun,10,FBonus.ToDamAll,0,0,FBonus.MulDamage + FBonus.MulDamageRanged ) then Exit( False );
  if not SendMissile( aTarget, aGun,10,FBonus.ToDamAll,0,0,FBonus.MulDamage + FBonus.MulDamageRanged ) then Exit( False );
  Exit( True );
end;

function TBeing.HandleShots ( aTarget : TCoord2D; aGun : TItem; aShots : DWord; toHit, toDam : Integer; iChaining : Boolean ) : Boolean;
var iScatter     : DWord;
    iCount       : DWord;
    iSeqBase     : DWord;
    iChainTarget : TCoord2D;
    iMissileRange: SmallInt;
    iRay         : TVisionRay;
    iSteps       : SmallInt;
begin
  Assert( aGun <> nil );
  iSeqBase := 0;
  if not isPlayer then iSeqBase := 100;
  iSeqBase += FAnimSeq;
  iMissileRange := Missiles[aGun.Missile].MaxRange;

  if aGun.Flags[ IF_SCATTER ] then
  begin
    iSteps := 0;
    iRay.Init(TLevel(Parent), FPosition, aTarget);
    repeat
      iRay.Next;
      if not TLevel(Parent).isProperCoord(iRay.GetC) then begin aTarget:=iRay.prev; break;end; {**** Stop at edge of map.}
      Inc(iSteps);
      if iSteps >= iMissileRange then begin aTarget := iRay.GetC; break; end; {**** Stop if further than maxrange.}
      if (MF_EXACT in (Missiles[aGun.Missile].Flags)) and (iRay.GetC = aTarget) then break; {**** Stop at target square for exact missiles.}
      if iRay.Done then
         iRay.Init(TLevel(Parent), iRay.GetC, iRay.GetC + (aTarget - FPosition)); {**** Extend target out in same direction for non-exact missiles.}
    until false;
    iScatter := Max(1,(iSteps div 4)); {**** SCATTER TIME!}
  end;
  if iChaining then
  begin
    iChainTarget := aTarget;
    aTarget      := FTargetPos;
  end;
  for iCount := 1 to aShots do
  begin
    if iChaining then aTarget := RotateTowards( FPosition, aTarget, iChainTarget, PI/6 );
    if aGun.Flags[ IF_SCATTER ] then
       begin
            if not SendMissile( TLevel(Parent).Area.Clamped(aTarget.RandomShifted( iScatter )), aGun, iSeqBase+(iCount-1)*Missiles[aGun.Missile].Delay*3, toDam, toHit, iCount-1, FBonus.MulDamage + FBonus.MulDamageRanged ) then Exit( False );
       end
    else
       begin
            if not SendMissile( aTarget, aGun, iSeqBase+(iCount-1)*Missiles[aGun.Missile].Delay*3, toDam, toHit, iCount-1, FBonus.MulDamage + FBonus.MulDamageRanged ) then Exit( False );
       end;
  end;
  Exit( True );
end;

function TBeing.VisualTime( aActionCost : Word = 1000; aBaseTime : Word = 100 ) : Word;
begin
  Result := Ceil( ( 100.0 / FSpeed ) * ( aActionCost / 1000.0 ) * Single( aBaseTime ) );
end;

function TBeing.IsPlayer : Boolean;
begin
  Exit( inheritsFrom( TPlayer ) );
end;

function TBeing.isActive: boolean;
begin
  Exit( TLevel(Parent).ActiveBeing = Self );
end;

function TBeing.Preposition( Creature : AnsiString ) : string;
begin
  Case Creature[1] of
    'a','e','i','o','u' : Exit('an ');
  end;
  Exit('a ');
end;

function TBeing.Dead: Boolean;
begin
  Exit( FHP <= 0 );
end;

procedure TBeing.Remove( Node : TNode );
begin
  if FInv <> nil then
    if Node is TItem then
      FInv.ClearSlot( Node as TItem );
  inherited Remove( Node );
end;

function TBeing.ASCIIMoreCode : AnsiString;
begin
  Exit( ID );
end;

function TBeing.ActionQuickKey( aIndex : Byte ) : Boolean;
var iUID  : TUID;
    iID   : string[32];
    iItem : TItem;
begin
  if ( aIndex < 1 ) or ( aIndex > 9 ) then Exit( False );
  with Player.FQuickSlots[ aIndex ] do
  begin
    iUID := UID;
    iID  := ID;
  end;
  if iUID <> 0 then
  begin
    iItem := UIDs[ iUID ] as TItem;
    if iItem <> nil then
    begin
      if FInv.Equipped( iItem )     then
      begin
         if iItem.isWeapon and ( FInv.Slot[ efWeapon2 ] = iItem )
           then Exit( ActionSwapWeapon )
           else Exit( Fail( 'You''re already using it!', [] ) );
      end;
      if not FInv.Contains( iItem ) then Exit( Fail( 'You no longer have it!', [] ) );
      Exit( ActionWear( iItem ) );
    end;
  end
  else
  if iID <> '' then
  begin
    for iItem in Inv do
      if iItem.isPack then
        if iItem.id = iID then
          Exit( ActionUse( iItem ) );
    Exit( Fail( 'You no longer have any item like that!', [] ) );
  end;
  Exit( Fail( 'Quickslot %d is unassigned!', [aIndex] ) );
end;

function TBeing.ActionQuickWeapon( const aWeaponID : Ansistring ) : Boolean;
var iWeapon  : TItem;
    iItem    : TItem;
    iAmmo    : Byte;
begin
  if (not LuaSystem.Defines.Exists(aWeaponID)) or (LuaSystem.Defines[aWeaponID] = 0)then Exit( False );

  if Inv.Slot[ efWeapon ] <> nil then
  begin
    if Inv.Slot[ efWeapon ].ID = aWeaponID then Exit( Fail( 'You already have %s in your hands.', [ Inv.Slot[ efWeapon ].GetName(true) ] ) );
    if Inv.Slot[ efWeapon ].Flags[ IF_CURSED ] then Exit( Fail( 'You can''t!', [] ) );
  end;

  if Inv.Slot[ efWeapon2 ] <> nil then
    if Inv.Slot[ efWeapon2 ].ID = aWeaponID then
      Exit( ActionSwapWeapon );

  iAmmo   := 0;
  iWeapon := nil;
  for iItem in Inv do
    if iItem.isWeapon then
      if iItem.ID = aWeaponID then
      if iItem.Ammo >= iAmmo then
      begin
        iWeapon := iItem;
        iAmmo   := iItem.Ammo;
      end;

  if iWeapon = nil then Exit( Fail( 'You don''t have a %s!', [ Ansistring(LuaSystem.Get([ 'items', aWeaponID, 'name' ])) ] ) );

  Inv.Wear( iWeapon );

  if Option_SoundEquipPickup
    then iWeapon.PlaySound( 'pickup', FPosition )
    else iWeapon.PlaySound( 'reload', FPosition );

  if not ( BF_QUICKSWAP in FFlags )
     then Exit( Success( 'You prepare the %s!',[ iWeapon.Name ], 1000 ) )
     else Exit( Success( 'You prepare the %s instantly!',[ iWeapon.Name ] ) );
end;

function TBeing.ActionSwapWeapon : boolean;
begin
  if ( Inv.Slot[ efWeapon ] <> nil ) and Inv.Slot[ efWeapon ].Flags[ IF_CURSED ] then Exit( False );
  if ( Inv.Slot[ efWeapon2 ] <> nil ) and ( Inv.Slot[ efWeapon2 ].isAmmoPack )   then Exit( False );

  Inv.EqSwap( efWeapon, efWeapon2 );

  if Inv.Slot[ efWeapon ] <> nil then
    if Option_SoundEquipPickup
      then Inv.Slot[ efWeapon ].PlaySound( 'pickup', FPosition )
      else Inv.Slot[ efWeapon ].PlaySound( 'reload', FPosition );

  if ( BF_QUICKSWAP in FFlags ) or ( canDualReload )
    then Exit( Success( 'You swap your weapons instantly!',[] ) )
    else Exit( Success( 'You swap your weapons.',[], Round(ActionCostWear*0.8) ) );
end;

function TBeing.ActionDrop ( Item : TItem ) : boolean;
var iUnique : Boolean;
begin
  if Item = nil then Exit( false );
  if not FInv.Contains( Item ) then Exit( False );
  iUnique := Item.Flags[ IF_UNIQUE ] or Item.Flags[ IF_NODESTROY ];
try
  if TLevel(Parent).DropItem( Item, FPosition ) then
  begin
    FInv.ClearSlot( Item );
    Exit( Success( 'You dropped %s.',[Item.GetName(false)],ActionCostDrop ) )
  end
  else
    begin
      FInv.ClearSlot( Item );
      if iUnique then
        Exit( Success( 'You dropped %s.',[Item.GetName(false)],ActionCostDrop ) )
	  else
        Exit( Success( 'The dropped item melts!',[],ActionCostDrop ) );
    end;
except
  on e : EPlacementException do
  begin
    Fail( 'No room on the floor.', [] );
  end;
end;
  Exit( False );
end;

function TBeing.ActionWear( aItem : TItem ) : boolean;
var iWeapon : Boolean;
begin
  if aItem = nil then Exit( false );
  if not FInv.Contains( aItem ) then Exit( False );
  iWeapon := aItem.isWeapon;

  if Option_SoundEquipPickup
    then aItem.PlaySound( 'pickup', FPosition )
    else aItem.PlaySound( 'reload', FPosition );

  if FInv.DoWear( aItem ) then
  begin
    if ( not iWeapon ) or ( not Flags[BF_QUICKSWAP] ) then
    begin
      Dec( FSpeedCount, ActionCostWear );
      Exit( True );
    end;
  end;
  Exit( False );
end;

function TBeing.ActionSwap( aItem : TItem; aSlot : TEqSlot ) : boolean;
var iWeapon : Boolean;
begin
  if aItem = nil then Exit( false );
  if not FInv.Contains( aItem ) then Exit( False );
  iWeapon := aItem.isWeapon;

  if Option_SoundEquipPickup
    then aItem.PlaySound( 'pickup', FPosition )
    else aItem.PlaySound( 'reload', FPosition );

  if FInv.DoWear( aItem, aSlot ) then
  begin
    if ( not iWeapon ) or ( not Flags[BF_QUICKSWAP] ) then
    begin
      Dec( FSpeedCount, ActionCostWear );
      Exit( True );
    end;
  end;
  Exit( False );
end;

function TBeing.ActionTakeOff( aSlot : TEqSlot ) : boolean;
var iWeapon : Boolean;
begin
  if (FInv.Slot[aSlot] = nil) or FInv.Slot[aSlot].Flags[ IF_CURSED ] then
    Exit( False );
  iWeapon := FInv.Slot[aSlot].isWeapon;
  FInv.setSlot( aSlot, nil );
  if ( not iWeapon ) or ( not Flags[BF_QUICKSWAP] ) then
  begin
    Dec( FSpeedCount, ActionCostWear );
    Exit( True );
  end;
  Exit( False );
end;

function TBeing.ActionReload : Boolean;
var Weapon   : TItem;
    AItem    : TItem;
    iAmmoUID : TUID;
    iPack    : Boolean;
    AmmoName : AnsiString;
begin
  Weapon := Inv.Slot[ efWeapon ];
  if ( Weapon = nil ) or ( not Weapon.isRanged ) then Exit( Fail( 'You have no weapon to reload.',[] ) );
  if (Weapon.Flags[ IF_RECHARGE ]) and ((not Weapon.Flags[ IF_CHAMBEREMPTY ]) or (Weapon.Ammo = 0)) then Exit( Fail( 'The weapon cannot be manually reloaded!', [] ) );
  if (Weapon.Flags[ IF_NOAMMO ]) and (not Weapon.Flags[ IF_CHAMBEREMPTY ])then Exit( Fail( 'The weapon doesn''t need to be reloaded!', [] ) );
  if ( Weapon.Ammo = Weapon.AmmoMax ) then Exit( Fail( 'Your %s is already loaded.', [ Weapon.Name ] ) );

  if not Weapon.CallHookCheck( Hook_OnReload, [ Self ] ) then Exit( False );

  if Weapon.Flags[ IF_CHAMBEREMPTY ] and ((Weapon.Ammo <> 0) or Weapon.Flags[ IF_NOAMMO ]) then
  begin
    Weapon.Flags[ IF_CHAMBEREMPTY ] := False;
    TLevel(Parent).playSound( Weapon.ID, 'pump', FPosition );
    Exit( Success( 'You pump a shell into the %s chamber.',[Weapon.Name],200 ) );
  end;

  AItem := getAmmoItem( Weapon );

  if AItem = nil then Exit( Fail( 'You have no more ammo for the %s!',[Weapon.Name] ) );

  iAmmoUID := AItem.UID;
  AmmoName := AItem.Name;
  
  iPack := AItem.isAmmoPack;

  if Weapon.Flags[ IF_PUMPACTION ] then
  begin
    Weapon.Flags[ IF_CHAMBEREMPTY ] := False;
    Reload( AItem, Weapon.Flags[ IF_SINGLERELOAD ] );
    Emote( 'You '+IIf(iPack,'quickly ')+'load a shell into the %s.', 'loads a shell into his %s.', [Weapon.Name] );
  end
  else
  begin
    Reload( AItem, Weapon.Flags[ IF_SINGLERELOAD ] );
    Emote( 'You '+IIf(iPack,'quickly ')+'reload the %s.', 'reloads his %s.', [Weapon.Name] );
  end;
  
  if iPack and ( UIDs[ iAmmoUID ] = nil ) and IsPlayer then
    IO.Msg( 'Your %s is depleted.', [AmmoName] );
  
  Exit( True );
end;

function TBeing.ActionDualReload : Boolean;
var SAStore : Boolean;
    iReload : Boolean;
begin
  if not canDualReload then
    Exit( Fail( 'Dualreload not possible.', [] ) );
  SAStore := FSilentAction;
  FSilentAction := True;
  iReload := ActionReload;
  FInv.EqSwap( efWeapon, efWeapon2 );
  if ActionReload then iReload := True;
  FInv.EqSwap( efWeapon, efWeapon2 );
  FSilentAction := SAStore;
  if iReload then
    Exit( Success( 'You dualreload your guns!', 'dualreloads his guns.', [] ) )
  else
    if (FInv.Slot[ efWeapon ].Ammo = FInv.Slot[ efWeapon ].AmmoMax)
    and (FInv.Slot[ efWeapon2 ].Ammo = FInv.Slot[ efWeapon2 ].AmmoMax) then
      Exit( Fail( 'Guns already loaded.', [] ) )
    else
      Exit( Fail( 'No more ammo!', [] ) )
end;

function TBeing.ActionAltReload : Boolean;
var SAStore : Boolean;
    AmmoItem : TItem;
    Pack     : Boolean;
    Weapon   : TItem;
begin
  Weapon := Inv.Slot[ efWeapon ];
  if ( Weapon = nil ) or ( not Weapon.isRanged ) then Exit( Fail( 'You have no weapon to reload.',[] ) );
  SAStore := FSilentAction;
  case Weapon.AltReload of
    RELOAD_SCRIPT : Exit( Weapon.CallHookCheck( Hook_OnAltReload, [Self] ) );
    RELOAD_DUAL   : Exit( ActionDualReload );
    RELOAD_FULL   :
      begin
        if Weapon.Ammo = Weapon.AmmoMax then Exit( Fail( 'Your %s is already fully loaded.', [ Weapon.Name ] ) );
        Weapon.Flags[ IF_CHAMBEREMPTY ] := False;
        AmmoItem := getAmmoItem( Weapon );
        if AmmoItem = nil then Exit( Fail('You have no ammo for the %s!',[ Weapon.Name ] ) );
        Pack := AmmoItem.isAmmoPack;
        while (Weapon.Ammo <> Weapon.AmmoMax) do
        begin
          if AmmoItem = nil then AmmoItem := getAmmoItem( Weapon );
          if AmmoItem = nil then Exit( Success('You have no more ammo for the %s!',[ Weapon.Name ], 200 ) );
          FSilentAction := True;
          Reload( AmmoItem, True );
          FSilentAction := SAStore;
          AmmoItem := nil;
        end;
        Exit( Success('You%s fully load the %s.', [ IIf( Pack, ' quickly'), Weapon.Name ], 200 ) );
      end;
    RELOAD_SINGLE :
      begin
        if Weapon.Ammo = Weapon.AmmoMax then Exit( Fail( 'Your %s is already fully loaded.', [ Weapon.Name ] ) );
        AmmoItem := getAmmoItem( Weapon );
        if AmmoItem = nil then Exit( Fail('You have no ammo for the %s!',[ Weapon.Name ] ) );
        FSilentAction := True;
        Reload( AmmoItem, True );
        FSilentAction := SAStore;
        Exit( Success('You%s single-load the %s.', [ IIf( Pack, ' quickly'), Weapon.Name ] ) );
      end;
    else
      Exit( Fail('This weapon has no special reload mode.', [] ) );
  end;
end;

function TBeing.ActionFire ( aTarget : TCoord2D; aWeapon : TItem; aAltFire : Boolean ) : Boolean;
var iChainFire : Byte;
    iEnemy     : TBeing;
    iEnemyUID  : TUID;
    iGunKata   : Boolean;
    iFireCost  : LongInt;
    iLimitRange: Boolean;
    iRange     : Byte;
    iDist      : Byte;
    iAltFire   : TAltFire;
begin
  iChainFire  := FChainFire;
  iAltFire    := ALT_NONE;
  FChainFire  := 0;

  if (aWeapon = nil) then Exit( False );
  if aAltFire then iAltFire := aWeapon.AltFire;

  if iAltFire <> ALT_NONE then 
  begin
    if (not aWeapon.isWeapon) then Exit( False );
    if aWeapon.isMelee then FMeleeAttack := True;
    if aWeapon.AltFire in [ ALT_SCRIPT, ALT_TARGETSCRIPT ] then
      if not aWeapon.CallHookCheck( Hook_OnAltFire, [Self] ) 
        then Exit( False );

    if aWeapon.isMelee then
    begin
      case aWeapon.AltFire of
        ALT_THROW  :
        begin
          SendMissile( aTarget, aWeapon, 0, FBonus.ToDam + FBonus.ToDamAll, FBonus.ToHit + FBonus.ToHitMelee, 0,
            FBonus.MulDamage + FBonus.MulDamageRanged + FBonus.MulDamageMelee );
          Dec( FSpeedCount, 1000 );
          Exit( True );
        end;
      end;
      Exit( True );
    end;
  end;  
  
  if (not aWeapon.isRanged) then Exit( False );

  if not aWeapon.Flags[ IF_NOAMMO ] then
  begin
    if aWeapon.Ammo = 0 then Exit( False );
    if aWeapon.Ammo < aWeapon.ShotCost then Exit( False );
  end;
  
  if aWeapon.Flags[ IF_CHAMBEREMPTY ] then Exit( False );

  if aWeapon.Flags[ IF_SHOTGUN ] then
      iRange := Shotguns[ aWeapon.Missile ].Range
  else
      iRange := Missiles[ aWeapon.Missile ].Range;
  if iRange = 0 then iRange := self.Vision;
  iLimitRange := (not aWeapon.Flags[ IF_SHOTGUN ]) and (MF_EXACT in Missiles[ aWeapon.Missile ].Flags);

  if iLimitRange then
  begin
    iDist := Distance( FPosition, aTarget );
    if iDist > iRange then
    begin
      if iRange = 1 then // Rocket jump hack!
        aTarget := FPosition + NewDirectionSmooth( FPosition, aTarget )
      else
        Exit( False );
    end;
  end;

  if (iAltFire = ALT_CHAIN) then
  begin
    if ( iChainFire > 0 )
      then FTargetPos := Doom.Targeting.PrevPos
      else FTargetPos := aTarget;
  end;
  FChainFire := iChainFire;

  iEnemy    := TLevel(Parent).Being[ aTarget ];
  iEnemyUID := 0;
  if iEnemy <> nil then iEnemyUID := iEnemy.uid;
  iGunKata  := aWeapon.Flags[ IF_PISTOL ] and (BF_GUNKATA in FFlags);

  iFireCost := getFireCost( iAltFire );
  // Gun Kata -- fire effect
  if iGunKata and isPlayer and (iAltFire = ALT_NONE) then
  begin
    if Player.LastTurnDodge then
    begin
      iFireCost := iFireCost div 10;
      Player.LastTurnDodge := False;
    end
    else if ( FLastCommand.Command = COMMAND_MOVE ) then
      iFireCost := iFireCost div 2;
  end;
  Dec(FSpeedCount,iFireCost);

  if ( not FireRanged( aTarget, aWeapon, iAltFire )) or Player.Dead then Exit;
  if canDualGun then
    if ( not FireRanged( aTarget, Inv.Slot[ efWeapon2 ], iAltFire )) or Player.Dead then Exit;

  // Gun Kata -- reload effect
  if iGunKata and (iEnemyUID <> 0) and ( not TLevel(Parent).isAlive( iEnemyUID ) ) then
  begin
    iFireCost := FSpeedCount;
    if canDualReload
      then ActionDualReload
      else ActionReload;
    FSpeedCount := iFireCost;
  end;
  Exit( True );
end;

function TBeing.ActionPickup : Boolean;
var iAmount  : byte;
    iItem   : TItem;
    iName   : AnsiString;
    iCount  : Byte;
begin
  iItem := TLevel(Parent).Item[ FPosition ];

  if iItem = nil            then Exit( Fail( 'But there is nothing here!', [] ) );
  if not iItem.isPickupable then Exit( Fail( 'But there is nothing here to pick up!', [] ) );

  if iItem.isPower then
  begin
    if iItem.CallHookCheck(Hook_OnPickupCheck,[Self]) then
    begin
      iItem.PlaySound( 'powerup', FPosition );
      CallHook( Hook_OnPickUpItem, [iItem] );
      iItem.CallHook(Hook_OnPickUp, [Self]);
    end;
    TLevel(Parent).DestroyItem( FPosition );
    Dec(FSpeedCount,ActionCostPickUp);
    Exit( True );
  end;

  if iItem.isAmmo then
  begin
    iAmount := Inv.AddAmmo(iItem.NID,iItem.Ammo);
    if iAmount <> iItem.Ammo then
    begin
      iItem.playSound( 'pickup', FPosition );
      CallHook( Hook_OnPickUpItem, [iItem] );
      iName := iItem.Name;
      iCount := iItem.Ammo-iAmount;
      if iAmount = 0 then
        TLevel(Parent).DestroyItem( FPosition )
      else iItem.Ammo := iAmount;
      Exit( Success( 'You found %d of %s.',[iCount,iName],ActionCostPickup) );
    end else Exit( Fail('You don''t have enough room in your backpack.',[]) );
  end;

  if BF_IMPATIENT in FFlags then
    if iItem.isPack then
      begin
        if isPlayer then IO.Msg('No time to waste.');
        CallHook( Hook_OnPickUpItem, [iItem] );
        Exit( ActionUse( iItem ) );
      end;

  if Inv.isFull then Exit( Fail( 'You don''t have enough room in your backpack.', [] ) );

  if not iItem.CallHookCheck(Hook_OnPickupCheck,[Self]) then  Exit( False );
  iItem.PlaySound('pickup', FPosition );
  if isPlayer then IO.Msg('You picked up %s.',[iItem.GetName(false)]);
  Inv.Add(iItem);
  CallHook( Hook_OnPickUpItem, [iItem] );
  Dec(FSpeedCount,ActionCostPickUp);
  iItem.CallHook(Hook_OnPickup, [Self]);
  Exit( True );
end;

function TBeing.ActionUse ( aItem : TItem ) : Boolean;
var isOnGround : Boolean;
    isLever    : Boolean;
    isPack     : Boolean;
    isEquip    : Boolean;
    isPrepared : Boolean;
    isUsed     : Boolean;
    isFailed   : Boolean;
    iSlot      : TEqSlot;
    iUID       : TUID;
	
begin
  isFailed   := False;
  isOnGround := TLevel(Parent).Item[ FPosition ] = aItem;
  if aItem = nil then Exit( false );
  if (not aItem.isLever) and (not aItem.isPack) and (not aItem.isAmmoPack) and (not aItem.isWearable) then Exit( False );
  if ((not aItem.isWearable) and (not aItem.CallHookCheck( Hook_OnUseCheck,[Self] ))) or (aItem.isWearable and ( (not aItem.CallHookCheck( Hook_OnEquipCheck,[Self] )) or (not aItem.CallHookCheck( Hook_OnPickupCheck,[Self] )) )) then Exit( False );

  isLever := aItem.isLever;
  isPack  := aItem.isPack;
  isEquip := aItem.isWearable;
  iUID    := aItem.uid;
  if isOnGround then
    begin
      if isLever then
        begin
          Emote( 'You pull the lever...', 'pulls the lever...',[] );
          if isPlayer then Player.Statistics.Increase( 'levers_pulled' );
        end
	  else if isPack then
	    begin
		  Emote( 'You use %s from the ground.', 'uses %s.', [ aItem.GetName(false) ] );
		end
	  else if isEquip then
	    begin
		  isPrepared := (aItem.isWeapon and (Inv.Slot[ efWeapon2 ] = nil));
		  if (Inv.Slot[ aItem.eqSlot ] = nil) or isPrepared then
		    begin
			  if (Inv.Slot[ aItem.eqSlot ] = nil) then iSlot := aItem.eqSlot
			  else if isPrepared then iSlot := efWeapon2;
			  Emote( 'You equip %s from the ground.', 'equips %s.', [ aItem.GetName(false) ] );
			end
		  else
			begin
  			  isEquip := False;
			  isFailed := True;
			  Emote( 'You must unequip first!', '', [ aItem.GetName(false) ] );
			end;
		end;
	end
  else
     Emote( 'You use %s.', 'uses %s.', [ aItem.GetName(false) ] );

  if not isFailed then
    if isEquip
      then aItem.PlaySound( 'pickup', FPosition )
      else aItem.PlaySound( 'use', FPosition );
  if isEquip or isPack then
    begin
      CallHook( Hook_OnPickUpItem, [aItem] );
	  aItem.CallHook( Hook_OnPickup,[Self] )
    end;
  if isEquip then
    Inv.setSlot( iSlot, aItem )
  else
    isUsed := aItem.CallHookCheck( Hook_OnUse,[Self] );
	 
  if ((UIDs.Get( iUID ) <> nil) and isUsed and (isLever or isPack)) then FreeAndNil( aItem );
  
  if not isFailed then
    if (BF_INSTAUSE in FFlags) and (not isEquip) then
      Dec(FSpeedCount,100)
    else
      Dec(FSpeedCount,1000);
  Exit( not isFailed );
end;

function TBeing.ActionUnLoad ( aItem : TItem; aDisassembleID : AnsiString = '' ) : Boolean;
var iAmount : Integer;
    iName   : AnsiString;
begin
  if aItem = nil then Exit( False );
  if ( aDisassembleID <> '' ) then
  begin
    iName   := aItem.Name;
    FreeAndNil( aItem );
    aItem := TItem.Create( aDisassembleID );
    aItem.PlaySound('reload', FPosition );
    if not Inv.isFull
       then Inv.Add( aItem )
       else TLevel(Parent).DropItem( aItem, FPosition );
    Exit( Success( 'You disassemble the %s.',[iName], ActionCostReload ) );
  end;

  if not (aItem.isRanged or aItem.isAmmoPack) then Exit( Fail( 'This item cannot be unloaded!', [] ) );
  if aItem.Flags[ IF_NOUNLOAD ] then Exit( Fail( 'This weapon cannot be unloaded!', []) );
  if aItem.Flags[ IF_RECHARGE ] then Exit( Fail( 'This weapon is self powered!', []) );
  if aItem.Flags[ IF_NOAMMO ] then Exit( Fail( 'This weapon doesn''t use ammo!', []) );
  if aItem.Ammo = 0 then Exit( Fail( 'The weapon isn''t loaded!', [] ) );

  aItem.PlaySound( 'reload', FPosition );
  iName   := aItem.Name;
  iAmount := FInv.AddAmmo(aItem.AmmoID,aItem.Ammo);
  if iAmount = 0 then
  begin
    aItem.Ammo := 0;
    if aItem.isAmmoPack then FreeAndNil( aItem );
    Exit( Success( 'You fully unload the %s.', [iName], ActionCostReload ) );
  end;
  if aItem.Ammo = iAmount then Exit( Fail( 'You don''t have enough room in your backpack to unload the %s.', [ iName ] ) );
  aItem.Ammo := iAmount;
  Exit( Success( 'You partially unload the %s.', [ iName ], ActionCostReload ) );
end;

function TBeing.ActionMove( aTarget : TCoord2D; aVisualMultiplier : Single = 1.0 ) : Boolean;
var iVisualTime : Integer;
    iMoveCost   : Integer;
begin
  iMoveCost := getMoveCost;
  if GraphicsVersion then
  begin
    iVisualTime := Ceil( VisualTime( iMoveCost, 100 ) * aVisualMultiplier );
    if isPlayer then
      IO.addScreenMoveAnimation( iVisualTime, aTarget );
    IO.addMoveAnimation( iVisualTime, 0, FUID, Position, aTarget, Sprite, True );
  end;
  Displace( aTarget );
  Dec( FSpeedCount, iMoveCost );
  HandlePostDisplace;
  HandlePostMove;
  Exit( True );
end;

function TBeing.ActionSwapPosition( aTarget : TCoord2D ) : Boolean;
var iLevel  : TLevel;
begin
  iLevel  := TLevel(Parent);
  if not iLevel.SwapBeings( Position, aTarget ) then Exit( False );
  Dec( FSpeedCount, getMoveCost );
  Exit( True );
end;

function TBeing.ActionActive : Boolean;
begin
  if ( not isPlayer ) then Exit( False );
  Exit( CallHookCheck( Hook_OnUseActive, [] ) );
end;

function TBeing.ActionAction( aTarget : TCoord2D ) : Boolean;
var iLevel : TLevel;
    iItem  : TItem;
begin
  iLevel := TLevel(Parent);
  iItem := iLevel.Item[ aTarget ];
  if Assigned( iItem ) and iItem.HasHook( Hook_OnAct )
    then iItem.CallHook( Hook_OnAct, [ LuaCoord( aTarget ), Self ] )
    else iLevel.CallHook( aTarget, Self, CellHook_OnAct );
  Exit( True );
end;

function TBeing.Fail ( const aText: AnsiString; const aParams: array of const ): Boolean;
begin
  if FSilentAction then Exit( False );
  if IsPlayer then IO.Msg( aText, aParams );
  Exit( False );
end;

function TBeing.Success ( const aText : AnsiString; const aParams : array of const; aCost : DWord ) : Boolean;
begin
  if aCost <> 0 then Dec( FSpeedCount, aCost );
  if FSilentAction then Exit( True );
  if IsPlayer then IO.Msg( aText, aParams );
  Exit( True );
end;

function TBeing.Success ( const aPlayerText, aBeingText : AnsiString; const aParams : array of const; aCost : DWord ) : Boolean;
begin
  if aCost <> 0 then Dec( FSpeedCount, aCost );
  Emote( aPlayerText, aBeingText, aParams );
  Exit( True );
end;

procedure TBeing.Emote ( const aPlayerText, aBeingText : AnsiString; const aParams : array of const ) ;
begin
  if FSilentAction then Exit;
  if IsPlayer
    then IO.Msg( aPlayerText, aParams )
    else if isVisible then IO.Msg( Capitalized(GetName(true))+' '+aBeingText, aParams );
end;

function TBeing.GetName(known : boolean) : string;
begin
  if BF_UNIQUENAME in FFlags then Exit( Name );
  if known then Exit( 'the ' + Name )
           else Exit( Preposition(Name) + Name );
end;

function  TBeing.WoundStatus : string;
var percent : LongInt;
begin
  percent := Min(Max(Round((FHP / FHPMax) * 100),0),1000);
  case percent of
 -1000..-1  : Exit('dead');
    0 ..10  : Exit('almost dead');
    11..20  : Exit('mortally wounded');
    21..35  : Exit('severely wounded');
    36..50  : Exit('heavily wounded');
    51..70  : Exit('wounded');
    71..80  : Exit('lightly wounded');
    81..90  : Exit('scratched');
    91..99  : Exit('almost unhurt');
    100     : Exit('unhurt');
    101..999: Exit('boosted');
    1000    : Exit('cheated');
  end;
end;


function TBeing.TryMove( aWhere : TCoord2D ) : TMoveResult;
var iLevel : TLevel;
begin
  iLevel := TLevel(Parent);
  if not iLevel.isProperCoord( aWhere )          then Exit( MoveBlock );
  if iLevel.cellFlagSet( aWhere, CF_OPENABLE )   then Exit( MoveDoor  );
  if not iLevel.isEmpty( aWhere, [EF_NOBLOCK] )  then Exit( MoveBlock );
  if ( not Self.isPlayer ) and iLevel.cellFlagSet( aWhere, CF_HAZARD ) and (not (BF_CHARGE in FFlags)) then
  begin
    if not (BF_ENVIROSAFE in FFlags) then Exit( MoveBlock );
  end;
  if iLevel.Being[ aWhere ] <> nil               then Exit( MoveBeing );
  Exit( MoveOk );
end;

function TBeing.MoveTowards( aWhere : TCoord2D; aVisualMultiplier : Single = 1.0 ): TMoveResult;
var iDir        : TDirection;
    iMoveResult : TMoveResult;
    iMoveCost   : Integer;
    iVisualMult : Single;
    iLevel      : TLevel;
begin
  iLevel := TLevel(Parent);
  iDir.CreateSmooth( FPosition, aWhere );
  FMovePos := FPosition + iDir;
  iMoveResult := TryMove( FMovePos );
  if iMoveResult = MoveBlock then
  begin
    iDir.Create( FPosition, aWhere );
    FMovePos := FPosition + iDir;
    iMoveResult := TryMove( FMovePos );
  end;
  if ( iMoveResult = MoveBlock ) and ( iDir.x <> 0 ) then
  begin
    FMovePos.x := FPosition.x + iDir.x;
    FMovePos.y := FPosition.y;
    iMoveResult := TryMove( FMovePos );
  end;
  if ( iMoveResult = MoveBlock ) and ( iDir.y <> 0 ) then
  begin
    FMovePos.x := FPosition.x;
    FMovePos.y := FPosition.y + iDir.y;
    iMoveResult := TryMove( FMovePos );
  end;
  if iMoveResult <> MoveOk then Exit( iMoveResult );

  iMoveCost   := getMoveCost;
  FSpeedCount := FSpeedCount - iMoveCost;
  if GraphicsVersion then
    if iLevel.BeingExplored( FPosition, Self ) or iLevel.BeingExplored( LastMove, Self ) or iLevel.BeingVisible( FPosition, Self ) or iLevel.BeingVisible( LastMove, Self ) then
    begin
      iVisualMult := ( 100.0 / FSpeed ) * ( iMoveCost / 1000.0 ) * aVisualMultiplier;
      IO.addMoveAnimation( Ceil( iVisualMult * 100 ), 0, FUID,Position,LastMove,Sprite, True);
    end;
  Displace( FMovePos );
  if BF_WALKSOUND in FFlags then
    PlaySound( 'hoof' );
  HandlePostDisplace;
  Exit( iMoveResult );
end;

procedure TBeing.Reload( AmmoItem : TItem; Single : Boolean );
var iAmmo  : Byte;
    iPack  : Boolean;
begin
  Inv.Slot[efWeapon].PlaySound( 'reload', FPosition );

  repeat
    if Single then iAmmo := Min(AmmoItem.Ammo,1)
              else iAmmo := Min(AmmoItem.Ammo,Inv.Slot[efWeapon].AmmoMax-Inv.Slot[efWeapon].Ammo);

    AmmoItem.Ammo := AmmoItem.Ammo - iAmmo;
    Inv.Slot[efWeapon].Ammo := Inv.Slot[efWeapon].Ammo + iAmmo;
    iPack := AmmoItem.isAmmoPack;
    if AmmoItem.Ammo = 0 then
    begin
      FreeAndNil( AmmoItem );
      if not iPack then
      begin
        if ( not Single ) and ( Inv.Slot[efWeapon].AmmoMax <> Inv.Slot[efWeapon].Ammo ) then
        begin
          AmmoItem := FInv.SeekAmmo(Inv.Slot[efWeapon].AmmoID);
          if AmmoItem <> nil then Continue;
        end;
      end;
    end;

    if iPack then
      Dec(FSpeedCount,getReloadCost div 5)
    else
      Dec(FSpeedCount,getReloadCost);
    Break;
  until AmmoItem = nil;
end;

function TBeing.FireRanged( aTarget : TCoord2D; aGun : TItem; aAlt : TAltFire ) : Boolean;
var iShots       : Integer;
    iDamageBonus : Integer;
    iToHitBonus  : Integer;
    iShotCost    : Byte;
    iChaining    : Boolean;
    iBulletDance : Boolean;
    iAmmochaining: Boolean;
    iFreeShot    : Boolean;
    iResult      : Boolean;

begin
  if aTarget = FPosition then Exit( False );
  if aGun = nil then Exit( False );

  iDamageBonus := FBonus.ToDamAll;
  iToHitBonus  := 0;
  if aGun.Flags[ IF_PISTOL ] then iDamageBonus += 3 * FBonus.Pistol;

  iShots       := Max( aGun.Shots, 1 );
  iChaining    := ( aAlt = ALT_CHAIN ) and ( iShots > 1 );
  iBulletDance := ( BF_BULLETDANCE in FFlags ) and aGun.Flags[ IF_PISTOL ] and ( aAlt = ALT_NONE );

  // thelaptop: The problem is there's no flag for "rapid fire" weapons.  There are 3 proposals here.
  //            Here, I explicitly verify that if the weapon fires more than one "shot" per firing action, it is a rapid fire if it's not a shotgun or pistol.
  // Actually, another alternative would be to compare with aGun.AltFire = ALT_CHAIN
  // 1. Original: Anything with 3 or more shots per firing action counts as "rapid shot", if 2, then it has to be not shotgun and not pistol.
  //if (iShots > 2) or (iBulletDance) or ( ( iShots > 1 ) and ( not aGun.Flags[ IF_SHOTGUN ]  and not aGun.Flags[ IF_PISTOL ] ) ) then
  // 2. Alt #1: 2 or more shots that are not shotguns nor pistols are considered "rapid shots".
  //if (iBulletDance) or ( ( iShots > 1 ) and ( not aGun.Flags[ IF_SHOTGUN ] and not aGun.Flags[ IF_PISTOL ] ) ) then
  // 3. Alt #2: Only chain-fire capable weapons are "rapid shots".
  //if (iBulletDance) or ( aGun.AltFire = ALT_CHAIN ) then
  if (iShots > 2) or (iBulletDance) or ( ( iShots > 1 ) and ( not aGun.Flags[ IF_SHOTGUN ]  and not aGun.Flags[ IF_PISTOL ] ) ) then
    iShots += FBonus.Rapid;

  if ( aAlt = ALT_AIMED ) then iToHitBonus += 3;

  iAmmoChaining := ( aGun.AltFire = ALT_CHAIN ) and (
    ( BF_AMMOCHAIN in FFlags ) or
    ( ( BF_ENTRENCHMENT in FFlags ) and ( iChaining ) and ( FChainFire > 0 ) )
  );

  if iChaining then
  begin
    case FChainFire of
      0 : iShots -= aGun.Shots div 3;
      2 : iShots += aGun.Shots div 2;
    end;
    if FChainFire < 2 then Inc( FChainFire );
  end;

  if aAlt = ALT_SINGLE then iShots := 1;

  iFreeShot := False;
  if aGun.Flags[ IF_NOAMMO ] then iFreeShot := true;

  if not iFreeShot then
  begin
    iShotCost       := Max( aGun.ShotCost, 1 );
    if not (iAmmoChaining) then
      iShots          := Min( aGun.Ammo div iShotCost , iShots );

    if (iShots < 1) or (aGun.ShotCost > aGun.Ammo) then Exit( False );

    aGun.RechargeReset;
    
    if iAmmoChaining then
      aGun.Ammo := aGun.Ammo - iShotCost
    else
      aGun.Ammo := aGun.Ammo - iShots * iShotCost;
  end;

  if FTargetPos = Player.Position then Player.MultiMove.Stop;

  if aGun.Flags[ IF_SHOTGUN ] then
    iResult := HandleShotgunFire( aTarget, aGun, iShots )
  else if aGun.Flags[ IF_SPREAD ] then
    iResult := HandleSpreadShots( aTarget, aGun )
  else
    iResult := HandleShots( aTarget, aGun, iShots, iToHitBonus, iDamageBonus, iChaining );

  if not iResult then Exit( False );

  FTargetPos := aTarget;

  if aGun.Flags[ IF_PUMPACTION ] then
    aGun.Flags[ IF_CHAMBEREMPTY ] := True;

  aGun.CallHook( Hook_OnFired, [ Self ] );

  if aGun.Flags[ IF_DESTROY ] then
    FreeAndNil( aGun );

  Exit( True );
end;

procedure TBeing.Action;
var iThisUID : DWord;
begin
  FMeleeAttack := False;
  iThisUID := UID;
  TLevel(Parent).CallHook( FPosition, Self, CellHook_OnEnter );
  if UIDs[ iThisUID ] = nil then Exit;
  LastPos := FPosition;
  FAffects.OnUpdate;
  if UIDs[ iThisUID ] = nil then Exit;
  CallHook(Hook_OnAction,[]);
  if UIDs[ iThisUID ] = nil then Exit;
  while FSpeedCount >= 5000 do Dec( FSpeedCount, 1000 );
end;

procedure TBeing.HandlePostMove;
begin
end;

procedure TBeing.HandlePostDisplace;
var iLevel      : TLevel;
begin
  BloodFloor;
  iLevel := TLevel( Parent );
  if iLevel.Item[ FPosition ] <> nil then
    if iLevel.Item[ FPosition ].Hooks[ Hook_OnEnter ] then
      iLevel.Item[ FPosition ].CallHook( Hook_OnEnter, [ Self ] );
end;


function TBeing.HandleCommand( aCommand : TCommand ) : Boolean; 
begin
  Result := True;
  case aCommand.Command of
    COMMAND_MOVE         : Result := ActionMove( aCommand.Target );
    COMMAND_USE          : Result := ActionUse( aCommand.Item );
    COMMAND_DROP         : Result := ActionDrop( aCommand.Item );
    COMMAND_WEAR         : Result := ActionWear( aCommand.Item );
    COMMAND_TAKEOFF      : Result := ActionTakeOff( aCommand.Slot );
    COMMAND_SWAP         : Result := ActionSwap( aCommand.Item, aCommand.Slot );
    COMMAND_WAIT         : Dec( FSpeedCount, 1000 );
    COMMAND_ACTION       : Result := ActionAction( aCommand.Target );
    COMMAND_ENTER        : TLevel( Parent ).CallHook( Position, CellHook_OnExit );
    COMMAND_MELEE        : Attack( aCommand.Target );
    COMMAND_RELOAD       : Result := ActionReload;
    COMMAND_ALTRELOAD    : Result := ActionAltReload;
    COMMAND_FIRE         : Result := ActionFire( aCommand.Target, aCommand.Item );
    COMMAND_ALTFIRE      : Result := ActionFire( aCommand.Target, aCommand.Item, True );
    COMMAND_PICKUP       : Result := ActionPickup;
    COMMAND_UNLOAD       : Result := ActionUnLoad( aCommand.Item, aCommand.ID );
    COMMAND_SWAPWEAPON   : Result := ActionSwapWeapon;
    COMMAND_QUICKKEY     : Result := ActionQuickKey( Ord( aCommand.ID[1] ) - Ord( '0' ) );
    COMMAND_ACTIVE       : Result := ActionActive;
    COMMAND_SWAPPOSITION : Result := ActionSwapPosition( aCommand.Target );
  else Exit( False );
  end;
  if Result then FLastCommand := aCommand;
end;

procedure TBeing.Tick;
begin
  if ( FHP * 100 ) > Integer( FHPMax * FHPDecayMax ) then
    if FHP > 1 then
      if ( Player.Statistics.GameTime mod 50 = 0 ) then
        Dec( FHP );
  if BF_REGENERATE in FFlags then
    if FHP < 20 then
      if ( Player.Statistics.GameTime mod 10 = 0 ) then
        Inc( FHP );
  FSpeedCount := Min( FSpeedCount + FSpeed, 10000 );
end;

procedure TBeing.Ressurect( RRange : Byte );
var range   : byte;
    sc      : TCoord2D;
    iBeing  : TBeing;
    iLevel  : TLevel;
    iCellID : Byte;
begin
  iLevel := TLevel(Parent);
  for Range := 1 to RRange do
    for sc in NewArea( FPosition, Range ).Clamped( iLevel.Area.Shrinked ) do
      if iLevel.cellFlagSet( sc, CF_RAISABLE ) then
        if iLevel.isEmpty(sc,[EF_NOBEINGS,EF_NOBLOCK]) then
        if iLevel.isEyeContact( FPosition, sc ) then
        begin
          try
            iCellID := iLevel.GetCell(sc);
            iBeing := TBeing.Create( Cells[ iCellID ].raiseto );
            Include( iBeing.FFlags, BF_RESPAWN );
            iLevel.DropBeing( iBeing, sc );
            iLevel.Cell[sc] := LuaSystem.Defines[ Cells[ iCellID ].destroyto ];
            Include( iBeing.FFlags, BF_NOEXP );
            Include( iBeing.FFlags, BF_NODROP );
            if isVisible then IO.Msg(Capitalized(GetName(true))+' raises his arms!');
            if iBeing.isVisible then IO.Msg(Capitalized( iBeing.GetName(true))+' suddenly rises from the dead!');
          except
            on e : EPlacementException do FreeAndNil( iBeing );
          end;
          Exit;
        end;
end;


procedure TBeing.Blood( aFrom : TDirection; aAmount : LongInt );
var iCount : byte;
    iCoord : TCoord2D;
    iLevel : TLevel;
begin
  if BF_NOBLEED in FFlags then Exit;
  iLevel := TLevel(Parent);
  for iCount := 1 to Min( aAmount, 20 ) do
  begin
    repeat
      case Random(5) of
        0..1 : iCoord := FPosition;
        2..3 : iCoord := FPosition + aFrom;
        4    : iCoord := FPosition + NewCoord2D( Random(3)-1, Random(3)-1);
      end;
    until iLevel.isProperCoord( iCoord );
    iLevel.Blood( iCoord );
  end;
end;

procedure TBeing.Kill( aBloodAmount : DWord; aOverkill : Boolean; aKiller : TBeing; aWeapon : TItem );
var iItem      : TItem;
    iCorpse    : Word;
    iBlood     : Byte;
    iDir       : TDirection;
    iLevel     : TLevel;
begin
  iLevel := TLevel(Parent);
  if not CallHookCheck( Hook_OnDieCheck, [ aOverkill ] ) then
  begin
    HP := Max(1,HP);
    Exit;
  end;

  // TODO: Change to Player.RegisterKill(kill)
  if not ( BF_FRIENDLY in FFlags ) then
    Player.RegisterKill( FID, aKiller, aWeapon, not Flags[ BF_RESPAWN ] );

  if (aKiller <> nil) and (aWeapon <> nil) then
    aWeapon.CallHook(Hook_OnKill, [ aKiller, Self ]);

  if not aOverkill then
  try
    for iItem in FInv do
      if (not (BF_NODROP in FFlags)) and (not iItem.Flags[IF_NODROP]) then
        iLevel.DropItem( iItem, FPosition );
  except
    on e : EPlacementException do ;
  end;

  iDir.code := 5;

  if aKiller <> nil then
    iDir.CreateSmooth( aKiller.FPosition, FPosition );

  iBlood := aBloodAmount;
  if aOverkill then iBlood *= 3;
  Blood(iDir,iBlood);

  CallHook( Hook_OnDie, [ aOverkill ] );

  if not aOverkill then
  begin
    iCorpse := GetLuaProtoValue('corpse');
    if iCorpse <> 0 then iLevel.DropCorpse( FPosition, iCorpse );
  end;

  if aOverkill then
    iLevel.playSound( 'gib',FPosition )
  else
    playSound( 'die' );
  
  if not (BF_NOEXP in FFlags) then Player.AddExp(FExpValue);

  if BF_BOSS in FFlags then
  begin
    iLevel.Kill( Self );
    Doom.GameWon := True;
    Doom.SetState( DSFinished );
    Exit;
  end;
  iLevel.Kill( Self );
end;

function TBeing.rollMeleeDamage( aSlot : TEqSlot = efWeapon ) : Integer;
var iDamage : Integer;
begin
  iDamage := FBonus.ToDam;
  if ( Inv.Slot[ aSlot ] <> nil ) and ( Inv.Slot[ aSlot ].isMelee ) then
  begin
    if BF_MAXDAMAGE in FFlags then
      iDamage += Inv.Slot[ aSlot ].maxDamage
    else
      iDamage += Inv.Slot[ aSlot ].rollDamage;

    if ( BF_BLADEBONUS in FFlags ) and Inv.Slot[ aSlot ].Flags[ IF_BLADE ] then
      iDamage *= 2;
  end
  else
  begin
    if BF_MAXDAMAGE in FFlags then
      iDamage += 3
    else
      iDamage += Byte(Dice(1,3));
  end;

  iDamage += FBonus.ToDamAll;
  iDamage := ApplyMul( iDamage, FBonus.MulDamage + FBonus.MulDamageMelee );

  if iDamage < 0 then iDamage := 0;
  rollMeleeDamage := iDamage;
end;

procedure TBeing.Attack( aWhere : TCoord2D );
var iSlot       : TEqSlot;
    iWeapon     : TItem;
    iAttackCost : DWord;
begin
  FMeleeAttack := True;
  iSlot := efTorso;
  iWeapon := nil;

  if TLevel(Parent).Being[ aWhere ] <> nil then
    Attack( TLevel(Parent).Being[ aWhere ] )
  else
  begin
    iSlot := meleeWeaponSlot;
    if iSlot in [ efWeapon, efWeapon2 ] then
	  iWeapon := Inv.Slot[ iSlot ];
	if iWeapon <> nil
      then iWeapon.PlaySound( 'fire', FPosition )
      else PlaySound( 'melee' );

    // Attack cost
    if iWeapon <> nil
      then iAttackCost := iWeapon.UseTime * FTimes.Fire
      else iAttackCost := 10*FTimes.Fire;

    IO.addMeleeAnimation( VisualTime( iAttackCost, 100 ), 0, FUID, Position, aWhere, Sprite );

    TLevel(Parent).DamageTile( aWhere, rollMeleeDamage( iSlot ), Damage_Melee );
    if iWeapon <> nil then
      Dec( FSpeedCount, Integer( iWeapon.UseTime ) * Integer( FTimes.Fire ) )
    else
      Dec( FSpeedCount, 10*Integer( FTimes.Fire ) )
  end;
end;

procedure TBeing.Attack( aTarget : TBeing; Second : Boolean = False );
var iName          : string;
    iDefenderName  : string;
    iResult        : string;
    iDamage        : Integer;
    iWeaponSlot    : TEqSlot;
    iWeapon        : TItem;
    iDamageType    : TDamageType;
    iToHit         : Integer;
    iBerserk       : Integer;
    iDualAttack    : Boolean;
    iAttackCost    : DWord;
    iIncrease      : DWord;
    iTargetUID     : TUID;
    iMissed        : Boolean;
begin
  if BF_NOMELEE in FFlags then Exit;
  if aTarget = nil then Exit;
  FMeleeAttack := True;
  iDualAttack  := canDualBlade;
  iTargetUID   := aTarget.UID;
  iMissed      := False;

  // Choose weaponSlot
  iWeaponSlot := meleeWeaponSlot;
  if Second then iWeaponSlot := efWeapon2;

  iDamageType := Damage_Melee;
  if iWeaponSlot in [ efWeapon, efWeapon2 ] then
    iWeapon := Inv.Slot[ iWeaponSlot ]
  else
    iWeapon := nil;

  if ( iWeapon <> nil ) and ( not iWeapon.isMelee ) then iWeapon := nil;
  
  // Play Sound
  if (iWeapon <> nil) then
  begin
    iWeapon.PlaySound( 'fire', FPosition );
    iDamageType := iWeapon.DamageType;
  end
  else
    PlaySound( 'melee' );

  // Attack cost
  if iWeapon <> nil
    then iAttackCost := iWeapon.UseTime * FTimes.Fire
    else iAttackCost := 10*FTimes.Fire;

  if not Second then
    IO.addMeleeAnimation( VisualTime( iAttackCost, 100 ), 0, FUID, Position, aTarget.Position, Sprite );

  if iDualAttack then iAttackCost := iAttackCost div 2;
  Dec( FSpeedCount, iAttackCost );

  // Get names
  iName         := GetName( true );
  iDefenderName := aTarget.GetName( true );
  if IsPlayer         then iName         := 'you';
  if aTarget.IsPlayer then iDefenderName := 'you';

  // Last kill
  iToHit := getToHitMelee( iWeapon ) - aTarget.DefenceBonus;

  if Roll( 12 + iToHit ) < 0 then
  begin
    if IsPlayer then iResult := ' miss ' else iResult := ' misses ';
    if isVisible then IO.Msg( Capitalized(iName) + iResult + iDefenderName + '.' );
    iMissed := True;
  end;

  if not iMissed then
  begin
    // Damage roll
    iDamage := rollMeleeDamage( iWeaponSlot );

    // Hit message
    if IsPlayer then iResult := ' hit ' else iResult := ' hits ';
    if isVisible then IO.Msg( Capitalized(iName) + iResult + iDefenderName + '.' );

    // Apply damage
    aTarget.ApplyDamage( iDamage, Target_Torso, iDamageType, iWeapon );
  
    // Cleave
    if ( ( iWeapon <> nil ) and ( iWeapon.Flags[IF_CLEAVE] ) or ( BF_CLEAVE in FFlags ) ) and
      ( not TLevel(Parent).isAlive( iTargetUID ) ) then
      begin
        IO.Msg('Next!');
        FSpeedCount := 5001;
      end;

    // Vampyre
    if ( BF_VAMPYRE in FFlags ) and
      ( FHP < FHPMax ) and
      ( not TLevel(Parent).isAlive( iTargetUID ) ) then
       FHP := Min( FHP + Ceil(aTarget.FHPMax / 10), FHPMax );


    // Berserker roll
    if (Player.EnemiesInVision > 0) then
      if (BF_BERSERKER in FFlags) and ( iDamage >= 10 ) then
      begin
        Player.BerserkerLimit := Player.BerserkerLimit + 1;
        if Player.BerserkerLimit > 4 - Min((Player.EnemiesInVision + 1) div 2, 3) then
          begin
            TLevel(Parent).playSound('bpack','powerup',FPosition);
            IO.Blink(Red,30);
            if Player.FAffects.IsActive(LuaSystem.Defines['berserk']) then
            begin
              iBerserk  := Player.FAffects.GetTime(LuaSystem.Defines['berserk']);
              if iBerserk > 0 then
              begin
                iIncrease := 10 - Min( iBerserk div 10, 9 );
                Player.FAffects.Add(LuaSystem.Defines['berserk'],iIncrease);
              end;
            end
            else
              Player.FAffects.Add(LuaSystem.Defines['berserk'],20);
            IO.Msg('You''re going berserk!');
            Player.BerserkerLimit := 0;
          end;
      end;
  end;
  // Dualblade attack
  if iDualAttack and (not Second) and TLevel(Parent).isAlive( iTargetUID ) then
    Attack( aTarget, True );
end;

function TBeing.meleeWeaponSlot: TEqSlot;
begin
  meleeWeaponSlot := efWeapon;
  if (BF_QUICKSWAP in FFlags) and
     ((Inv.Slot[efWeapon] = nil) or (not Inv.Slot[efWeapon].isMelee)) and
     (Inv.Slot[efWeapon2] <> nil) and (Inv.Slot[efWeapon2].isMelee) then
      meleeWeaponSlot := efWeapon2;
  if isPlayer then
  begin
    if (Inv.Slot[meleeWeaponSlot] <> nil) and Inv.Slot[meleeWeaponSlot].isMelee then
    begin
      if not Doom.CallHookCheck(Hook_OnFire,[Inv.Slot[meleeWeaponSlot], Self]) then Exit(efTorso);
    end
    else
      if not Doom.CallHookCheck(Hook_OnFire,[nil, Self]) then Exit(efTorso);
  end;
end;

function TBeing.getTotalResistance(const aResistance: AnsiString; aTarget: TBodyTarget): Integer;
var iResist : LongInt;
begin
  iResist := GetLuaProperty( ['resist',aResistance], 0 );
  if isPlayer and ( aTarget <> Target_Feet ) then iResist := Min( 95, iResist );
  if iResist >= 100 then Exit( 100 );
  getTotalResistance := iResist;
  if aTarget = Target_Internal then Exit;

  iResist := 0;
  if Inv.Slot[ efWeapon ] <> nil then
  begin
    iResist := Inv.Slot[ efWeapon ].GetResistance( aResistance );
    if iResist >= 100 then Exit( 100 );
  end;
  getTotalResistance += iResist;

  iResist := 0;
  case aTarget of
    Target_Torso    : if Inv.Slot[ efTorso ] <> nil then iResist := Inv.Slot[ efTorso ].GetResistance( aResistance );
    Target_Feet     : if Inv.Slot[ efBoots ] <> nil then iResist := Inv.Slot[ efBoots ].GetResistance( aResistance );
  end;
  if iResist >= 100 then Exit( 100 );

  if BF_BLADEDEFEND in FFlags then
    if (Inv.Slot[ efWeapon2 ] <> nil) and (Inv.Slot[ efWeapon2 ].Flags[ IF_BLADE ]) then
    begin
      if (aResistance = 'bullet') or (aResistance = 'shrapnel') or (aResistance = 'fire') then iResist += 50;
      if (aResistance = 'melee') then iResist +=75;
    end;

  if (BF_ENTRENCHMENT in FFlags) and (FChainFire > 0) then
    iResist += 50;

  getTotalResistance += iResist;
  getTotalResistance := Min( 95, getTotalResistance );
end;

procedure TBeing.ApplyDamage( aDamage : LongInt; aTarget : TBodyTarget; aDamageType : TDamageType; aSource : TItem );
var iDirection     : TDirection;
    iArmor         : TItem;
    iSlot          : TEqSlot;
    iArmorDamage   : LongInt;
    iProtection    : LongInt;
    iArmorValue    : Byte;
    iOverKillValue : LongInt;
    iResist        : LongInt;
begin
  if aDamage < 0 then Exit;
  
  if BF_INV in FFlags then Exit;
  
  if BF_SELFIMMUNE in FFlags then
    if ( ( aSource <> nil ) and Self.Inv.Equipped( aSource ) ) then Exit;

  if aDamageType <> Damage_IgnoreArmor then
  begin
    case aDamageType of
      Damage_Acid        : iResist := getTotalResistance( 'acid', aTarget );
      Damage_Fire        : iResist := getTotalResistance( 'fire', aTarget );
      Damage_Sharpnel    : iResist := getTotalResistance( 'shrapnel', aTarget );
      Damage_Plasma,
      Damage_SPlasma     : iResist := getTotalResistance( 'plasma', aTarget );
      Damage_Bullet      : iResist := getTotalResistance( 'bullet', aTarget );
      Damage_Melee       : iResist := getTotalResistance( 'melee', aTarget );
    else iResist := 0;
    end;
    if iResist >= 100 then Exit;
    if iResist <> 0 then
      aDamage := Max( Round( aDamage * ( (100-iResist) / 100 ) ), 1 );
  end;

  if not isPlayer then
    PlaySound( 'hit' );

  iArmor := nil;
  iSlot := efWeapon;
  case aTarget of
    Target_Torso    : iSlot := efTorso;
    Target_Feet     : iSlot := efBoots;
  end;
  if iSlot <> efWeapon then iArmor := Inv.Slot[ iSlot ];

  iArmorValue := FArmor;
  if Inv.Slot[ efWeapon ] <> nil then
     iArmorValue += Inv.Slot[ efWeapon ].Armor;

  
  if iArmor <> nil then
  begin
    iProtection := iArmor.GetProtection;
    iArmorValue += iProtection;

    iArmorDamage := Max( aDamage - iProtection , 1 );
    if aDamageType = Damage_Acid then iArmorDamage *= 2;
    if iArmor.Flags[ IF_NODURABILITY ] then iArmorDamage := 0;
    iArmor.Durability := Max( 0, iArmor.Durability - iArmorDamage );

    if iArmorDamage > 0 then iArmor.RechargeReset;

    if (iArmor.Durability = 0) and (not iArmor.Flags[ IF_NODESTROY ]) then
    begin
      if IsPlayer then
        if aTarget = Target_Torso then IO.Msg('Your '+iArmor.Name+' is completely destroyed!')
                                  else IO.Msg('Your '+iArmor.Name+' are completely destroyed!');
      FreeAndNil( iArmor );
    end
    else if IsPlayer and ( iProtection <> iArmor.GetProtection ) then
      if aTarget = Target_Torso then IO.Msg('Your '+iArmor.Name+' is damaged!')
                                else IO.Msg('Your '+iArmor.Name+' are damaged!');

  end;

  if aDamageType = DAMAGE_SHARPNEL then iArmorValue := iArmorValue * 2;
  if aDamageType = DAMAGE_PLASMA   then iArmorValue := iArmorValue div 2;
  if aDamageType = DAMAGE_SPLASMA  then iArmorValue := iArmorValue div 3;

  if aDamageType <> Damage_IgnoreArmor then
  begin
    if (BF_HARDY in FFlags) and (aDamage <= iArmorValue) and (Random(2) = 1) then Exit;
    aDamage := Max( 1, aDamage - iArmorValue );
  end;

  if aDamage > 8 then
  begin
    if TLevel(Parent).ActiveBeing <> nil then
      iDirection.Create( TLevel(Parent).ActiveBeing.FPosition, FPosition )
    else iDirection.code := 5;
    Blood( iDirection, aDamage div 6 );
  end;

  case aDamageType of
    Damage_Fire    : iOverKillValue := FHPMax + FHPMax div 2;
    Damage_Acid    : iOverKillValue := FHPMax * 2;
    Damage_Plasma  : iOverKillValue := FHPMax * 2;
    Damage_SPlasma : iOverKillValue := FHPMax;
  else
    iOverKillValue := FHPMax * 4;
  end;

  if IsPlayer then Player.Statistics.OnDamage( aDamage );

  FHP := Max( FHP - aDamage, 0 );
  if Dead and (not IsPlayer) then
    if isVisible then IO.Msg(Capitalized(GetName(true))+' dies.')
                 else IO.Msg('You hear the scream of a freed soul!');
  if Dead
    then Kill( Min( aDamage div 2, 15), aDamage >= iOverKillValue, TLevel(Parent).ActiveBeing, aSource )
    else CallHook( Hook_OnAttacked, [ TLevel(Parent).ActiveBeing, aSource ] );
end;

function TBeing.SendMissile( aTarget : TCoord2D; aItem : TItem; aSequence : DWord; aDamageMod, aToHitMod, aShotCount, aDamageMult : Integer ) : Boolean;
var iDirection  : TDirection;
    iMisslePath : TVisionRay;
    iOldCoord   : TCoord2D;
    iTarget     : TCoord2D;
    iSource     : TCoord2D;
    iCoord      : TCoord2D;
    iColor      : Byte;
    iToHit      : Integer;
    iDamage     : Integer;
    iBeing      : TBeing;
    iAimedBeing : TBeing;
    iRange      : Byte;
    iMaxRange   : Byte;
    iRoll       : TDiceRoll;
    iRadius     : Byte;
    iIsHit      : Boolean;
    iRunDamage  : Boolean;
    iDodged     : Boolean;
    iFireDesc   : Ansistring;
    iSprite     : TSprite;
    iDuration   : DWord;
    iSteps      : DWord;
    iDelay      : DWord;
    iSound      : DWord;
    iMissile    : DWord;
    iDirectHit  : Boolean;
    iThisUID    : TUID;
    iItemUID    : TUID;
    iHit        : Boolean;
    iLevel      : TLevel;
    iStart      : TCoord2D;
    iMaxDamage  : Boolean;
begin
  if aItem = nil then Exit( False );
  if not aItem.isWeapon then Exit( False );
  if FHP <= 0 then Exit( False );

  iLevel     := TLevel(Parent);
  iDirectHit := False;
  iMissile   := aItem.Missile;
  iThisUID   := FUID;
  iItemUID   := aItem.uid;
  iDodged    := False;
  if iLevel.isProperCoord( aTarget ) then
  begin
    iBeing      := iLevel.Being[ aTarget ];
    iAimedBeing := iLevel.Being[ aTarget ];
  end;
  if iBeing <> nil then
    if Random(100) <= getStrayChance( iBeing, iMissile ) then
    begin
      if iBeing.FLastPos.X = 1 then iBeing.FLastPos := iBeing.FPosition;
      aTarget := iBeing.FLastPos;
      iDodged := True;
    end;
      
  with Missiles[iMissile] do
  begin
    case Color of
      MULTIYELLOW : case Random(3) of 0 : iColor := LightGreen; 1 : iColor := White;  2 : iColor := Yellow; end;
      MULTIBLUE   : case Random(3) of 0 : iColor := LightBlue;  1 : iColor := White;  2 : iColor := Blue;   end;
    else
      iColor := Color;
    end;
    iRange := Range;
    iMaxRange := MaxRange;
    iDelay := Delay;
  end;
  
  if iRange = 0 then iRange := 30;
  
  iToHit := getToHitRanged( aItem ) + aToHitMod;

  iTarget := aTarget;
  iSource := FPosition;
  
  if ( MF_IMMIDATE in Missiles[iMissile].Flags ) then
      iSource := iTarget;

  iMisslePath.Init( iLevel, iSource, aTarget );

  iMaxDamage := (BF_MAXDAMAGE in FFlags) or (( aItem.Flags[ IF_PISTOL ]) and ( BF_PISTOLMAX in FFlags ) );
  if iMaxDamage then
    iDamage := aItem.maxDamage
  else
    iDamage := aItem.rollDamage;

  iDamage += aDamageMod;
  iDamage := ApplyMul( iDamage, aDamageMult );

  iSteps := 0;
  iHit   := MF_EXACT in Missiles[iMissile].Flags;
  iIsHit := MF_EXACT in Missiles[iMissile].Flags;
  iStart := iMisslePath.GetSource;

  iRadius := aItem.BlastRadius;
  if ( BF_FIREANGEL in FFlags ) and ( not ( aItem.Hooks[ Hook_OnHitBeing ] ) ) then
    iRadius += 1;

  repeat
    iOldCoord := iMisslePath.GetC;
    if not ( MF_IMMIDATE in Missiles[iMissile].Flags ) then
      iMisslePath.Next;
    iCoord := iMisslePath.GetC;
    iSteps := Distance (iStart.x, iStart.y, iCoord.x, iCoord.y);

    if not iLevel.isProperCoord( iCoord ) then Break;

    if not iLevel.isEmpty( iCoord, [EF_NOBLOCK] ) then
    begin
      if (iAimedBeing = Player) and (iDodged) then IO.Msg('You dodge!');

      if aItem.Flags[ IF_DESTRUCTIVE ]
        then iLevel.DamageTile( iCoord, iDamage * 2, aItem.DamageType )
        else iLevel.DamageTile( iCoord, iDamage, aItem.DamageType );

      if iLevel.isVisible( iCoord ) then
        IO.Msg('Boom!');
      iCoord := iOldCoord;
      iHit   := True;
      Break;
    end;
    
    if iLevel.Being[ iCoord ] <> nil then
    begin
      iBeing := iLevel.Being[ iCoord ];
      if iBeing = iAimedBeing then
        iDodged := False;

      iToHit -= iBeing.DefenceBonus;

      if aItem.Flags[ IF_FARHIT ]
        then iIsHit := Roll( 10 + iToHit) >= 0
	else iIsHit := Roll( 10 - (distance(FPosition, iCoord ) div 3 ) + iToHit) >= 0;
      
      if iIsHit and ( not iLevel.isVisible( iCoord ) ) and ( not aItem.Flags[ IF_UNSEENHIT ] ) then
        iIsHit := (Random(10) > 4);
      
      if aItem.Flags[ IF_AUTOHIT ] then iIsHit := True;

      if iIsHit and ( iBeing <> iAimedBeing ) then
        if ( isPlayer and iBeing.Flags[ BF_FRIENDLY ] ) or
          ( Flags[ BF_FRIENDLY ] and iBeing.IsPlayer ) then
           if Random( 3 ) > 0 then
             iIsHit := False;

      if iIsHit then
      begin
        if iLevel.Being[ iCoord ] = Player
          then iDirectHit := True
          else if (iAimedBeing = Player) and (iDodged) then IO.Msg('You dodge!');
        if iLevel.isVisible( iCoord ) then
            if iBeing.IsPlayer then
            begin
              iFireDesc := LuaSystem.Get(['missiles',iMissile,'hitdesc'], '');
              if iFireDesc = '' then iFireDesc := 'You are hit!';
              IO.Msg( Capitalized( iFireDesc ) );
            end
            else IO.Msg('The missile hits '+iBeing.GetName(true)+'.');

        if not ( MF_HARD in Missiles[iMissile].Flags ) then
        begin
          iDirection.CreateSmooth( Self.FPosition, iCoord );
          iBeing.KnockBack( iDirection, iDamage div 12 );
        end;
        if iRadius = 0 then
        begin
          iRunDamage := True;
          if aItem.Hooks[ Hook_OnHitBeing ] then
          begin
            iRunDamage    := aItem.CallHookCheck(Hook_OnHitBeing,[Self,iBeing]);
          end;
          if iRunDamage then
            iBeing.ApplyDamage( iDamage, Target_Torso, aItem.DamageType, aItem );
        end;

        if not ( MF_HARD in Missiles[iMissile].Flags ) then
        begin
          aTarget := iCoord;
          iHit    := True;
          Break;
        end;
      end;
    end;
    
    if iMisslePath.Done then
      if MF_EXACT in Missiles[iMissile].Flags then
        Break;

    if ( iSteps >= iMaxRange ) or (MF_IMMIDATE in Missiles[iMissile].Flags) then
    begin
      if (iAimedBeing = Player) and (iDodged) then IO.Msg('You dodge!');
      break;
    end;

    if UIDs[ iItemUID ] = nil then
    begin
      aItem := nil;
      vdebug.Log( LOGWARN, 'Item destroyed duirng SendMissile!');
      Exit( False );
    end;
  until false;

  if UIDs[ iThisUID ] = nil then Exit( False );

  iSound  := IO.Audio.ResolveSoundID([aItem.ID+'.fire',Missiles[iMissile].soundID+'.fire','fire']);
  iSprite := Missiles[iMissile].Sprite;
  if iSound <> 0 then
    IO.addSoundAnimation( aSequence, iSource, iSound );

  iDuration := (iSource - iMisslePath.GetC).LargerLength * iDelay;
  if not ( MF_IMMIDATE in Missiles[iMissile].Flags ) then
  begin
    IO.addMissileAnimation( iDuration, aSequence,iSource,iMisslePath.GetC,iColor,Missiles[iMissile].Picture,iDelay,iSprite,MF_RAY in Missiles[iMissile].Flags);
    if iHit and iLevel.isVisible( iMisslePath.GetC ) then
      IO.addMarkAnimation(199, aSequence + iDuration, iMisslePath.GetC, Missiles[iMissile].HitSprite, Iif( iIsHit, LightRed, LightGray ), '*' );
  end;

  if aItem.Flags[ IF_THROWDROP ] then
  try
    iLevel.DropItem( aItem, iCoord )
  except
    FreeAndNil( aItem );
  end;

  if iRadius <> 0 then
  begin
    iRoll.Init(aItem.Damage_Dice, aItem.Damage_Sides, aItem.Damage_Add + aDamageMod );

    if iMaxDamage then
      iRoll.Init( 0,0, iRoll.Max );

    iSound := IO.Audio.ResolveSoundID([aItem.ID+'.explode',Missiles[iMissile].soundID+'.explode','explode']);
    with Missiles[iMissile] do
    iLevel.Explosion( iDelay*(iSteps+(aShotCount*2)), iCoord, iRadius, ExplDelay, iRoll, ExplColor,
                    iSound, aItem.DamageType, aItem, ExplFlags, Content, iDirectHit, aDamageMult );
  end;
  if (iAimedBeing = Player) and (iDodged) then Player.LastTurnDodge := True;
  Exit( UIDs[ iThisUID ] <> nil );
end;

procedure TBeing.BloodFloor;
var iLevel : TLevel;
begin
  if BF_FLY in FFlags then Exit;
  iLevel := TLevel(Parent);
       if iLevel.cellFlagSet( FPosition, CF_VBLOODY ) then Inc(FBloodBoots,1)
  else if iLevel.LightFlag[ FPosition, LFBLOOD ] then Inc(FBloodBoots,0)
    else if FBloodBoots > 0 then Dec(FBloodBoots);
  if FBloodBoots > 6 then FBloodBoots := 6;
  if FBloodBoots = 0 then Exit;
  if (iLevel.cellFlagSet(FPosition,CF_VBLOODY)) or
     (iLevel.LightFlag[ FPosition, LFBLOOD ]) then Exit;
  iLevel.Blood(FPosition);
end;

procedure TBeing.Knockback( dir : TDirection; Strength : Integer );
var knock : TCoord2D;
    FStrength : Real;
    iLevel : TLevel;
begin
  iLevel := TLevel(Parent);
  if Strength*Dir.code = 0 then Exit;
  if BF_KNOCKIMMUNE in FFlags then Exit;

  knock := FPosition + Dir;
  FStrength := Strength;

  FStrength *= getKnockMod / 100;
  Strength := Round(FStrength);
  Strength -= FBonus.Body;

  if Strength <= 0 then Exit;

  if not iLevel.isEmpty( knock, [EF_NOBEINGS,EF_NOBLOCK] ) then Exit;
  knock := FPosition;
  while Strength > 0 do
  begin
    if not iLevel.isEmpty(knock + Dir, [EF_NOBEINGS,EF_NOBLOCK] ) then Break;
    knock += Dir;
    Dec(Strength);
  end;

  if iLevel.isEmpty(knock,[EF_NOBEINGS,EF_NOBLOCK]) then
  begin
    if GraphicsVersion then
    begin
      if isPlayer then
        IO.addScreenMoveAnimation(100, knock );
      if isVisible then
        IO.addMoveAnimation(100,0,FUID,Position,knock,Sprite,True);
    end;
    Displace( knock );
    HandlePostDisplace;
  end;
end;

function TBeing.getMoveCost: LongInt;
var iModifier : Single;
begin
  iModifier := FTimes.Move/100.;
  if Inv.Slot[efTorso] <> nil then iModifier *= (100-Inv.Slot[efTorso].MoveMod)/100.;
  if Inv.Slot[efBoots] <> nil then iModifier *= (100-Inv.Slot[efBoots].MoveMod)/100.;
  if FBonus.Move <> 0         then iModifier *= (100-FBonus.Move)/100.;
  if not ( BF_FLY in FFlags ) then
    with Cells[ TLevel(Parent).getCell(FPosition) ] do
      iModifier *= MoveCost;
  getMoveCost := Round( ActionCostMove * iModifier );
end;

function TBeing.getFireCost( aAltFire : TAltFire ) : LongInt;
var iModifier : Single;
begin
  if (Inv.Slot[ efWeapon ] = nil) then Exit(10*FTimes.Fire);
  if (Inv.Slot[ efWeapon ].isMelee) then Exit(Inv.Slot[ efWeapon ].UseTime * FTimes.Fire);
  if canDualGun then
    iModifier := ( Inv.Slot[ efWeapon ].UseTime + Inv.Slot[ efWeapon2 ].UseTime ) / 2
  else
    iModifier := Inv.Slot[ efWeapon ].UseTime;
  iModifier *= FTimes.Fire/1000.;

  if (FBonus.Pistol > 0) and Inv.Slot[ efWeapon ].Flags[ IF_PISTOL ] then iModifier *= Max( (10.-FBonus.Pistol)/10, 0.1 );
  if (BF_BULLETDANCE in FFlags) and Inv.Slot[ efWeapon ].Flags[ IF_PISTOL ] and (aAltFire = ALT_NONE) then iModifier *= ( 1 + 0.5 * FBonus.Rapid );
  if (aAltFire = ALT_AIMED) then iModifier *= 2;
  if (BF_SHOTTYHEAD in FFlags) and Inv.Slot[efWeapon].Flags[ IF_SHOTGUN ] then iModifier *= 0.33;

  getFireCost := Max( Round( ActionCostFire*iModifier ), 100 );
end;

function TBeing.getReloadCost: LongInt;
var Modifier : Real;
begin
  if (Inv.Slot[efWeapon] = nil) or (Inv.Slot[efWeapon].isMelee) then Exit(1000);
  Modifier := Inv.Slot[efWeapon].ReloadTime/10.0;
  Modifier *= FTimes.Reload/100.;
  getReloadCost := Round(ActionCostReload*Modifier);
end;

function TBeing.getDodgeMod : LongInt;
begin
  Result := DodgeBonus;
  if Inv.Slot[efTorso] <> nil    then Result += Inv.Slot[efTorso].DodgeMod;
  if Inv.Slot[efBoots] <> nil    then Result += Inv.Slot[efBoots].DodgeMod;
end;

function TBeing.getKnockMod : LongInt;
var Modifier : Real;
begin
  Modifier := 100;
  if Inv.Slot[efWeapon] <> nil then
    if Inv.Slot[efWeapon].Flags[ IF_HALFKNOCK ] then
      Modifier := 50;
  if Inv.Slot[efBoots] <> nil then
    with Inv.Slot[efBoots] do
      if KnockMod <> 0 then
        Modifier *= (100 + KnockMod) / 100. ;
  if Inv.Slot[efTorso] <> nil then
    with Inv.Slot[efTorso] do
      if KnockMod <> 0 then
        Modifier *= (100 + KnockMod) / 100. ;
  getKnockMod := Round(Modifier) ;
end;

function TBeing.canDualGun: boolean;
begin
  Exit( ( BF_DUALGUN in FFlags )
    and ( Inv.Slot[efWeapon] <> nil )
    and ( Inv.Slot[efWeapon].Flags[ IF_PISTOL ] )
    and ( Inv.Slot[efWeapon2] <> nil )
    and ( Inv.Slot[efWeapon2].Flags[ IF_PISTOL ] )
    and ( Inv.Slot[efWeapon2].Ammo <> 0 ) );
end;

function TBeing.canDualBlade: boolean;
begin
  Exit( ( BF_DUALBLADE in FFlags )
    and ( Inv.Slot[efWeapon] <> nil )
    and ( Inv.Slot[efWeapon].Flags[ IF_BLADE ] )
    and ( Inv.Slot[efWeapon2] <> nil )
    and ( Inv.Slot[efWeapon2].Flags[ IF_BLADE ] ) );
end;

function TBeing.canDualReload : Boolean;
begin
  Exit( (BF_DUALGUN in FFlags) and
      ( Inv.Slot[ efWeapon  ] <> nil ) and Inv.Slot[ efWeapon ].Flags[ IF_PISTOL ] and
      ( Inv.Slot[ efWeapon2 ] <> nil ) and Inv.Slot[ efWeapon2 ].Flags[ IF_PISTOL ]
  );
end;

function TBeing.canPackReload : Boolean;
var Weapon, Pack : TItem;
begin
  Weapon := FInv.Slot[ efWeapon ];
  Pack   := FInv.Slot[ efWeapon2 ];
  Exit( ( Weapon <> nil ) and ( Weapon.isRanged )
    and ( Pack <> nil )   and ( Pack.isAmmoPack )
    and ( Pack.AmmoID = Weapon.AmmoID) );
end;

function TBeing.getToHitRanged(Item : TItem) : Integer;
begin
  getToHitRanged := FBonus.ToHit;
  if (Item <> nil) and (Item.isRanged) then getToHitRanged += Item.Acc;
  if not isPlayer then
    getToHitRanged += TLevel(Parent).ToHitBonus;
end;

function TBeing.getToHitMelee(Item : TItem) : Integer;
begin
  getToHitMelee := FBonus.ToHit + FBonus.ToHitMelee;
  if (Item <> nil) and (Item.isMelee) then getToHitMelee += Item.Acc;
  if not isPlayer then
    getToHitMelee += TLevel(Parent).ToHitBonus;
end;

destructor TBeing.Destroy;
begin
  FreeAndNil( FInv );
  FreeAndNil( FPath );
  FreeAndNil( FAffects );
  inherited Destroy;
end;

{ IBeingAI }

function TBeing.MoveCost(const Start, Stop: TCoord2D): Single;
var iDiff     : TCoord2D;
    iStopCell : TCell;
    iStopID   : Byte;
  function isHazard( aID : Byte ) : Boolean;
  begin
    if isPlayer and ( CellHook_OnHazardQuery in Cells[ aID ].Hooks ) then
    begin
      if aID in FPathHazards then Exit( True );
      if aID in FPathClear   then Exit( False );
      if TLevel(Parent).CallHook( CellHook_OnHazardQuery, aID, Self )
        then begin Include( FPathHazards, aID ); Exit( True ); end
        else begin Include( FPathClear, aID );   Exit( False ); end
    end
    else Exit( CF_HAZARD in Cells[ aID ].Flags );
  end;

begin
  iDiff := Start - Stop;
  if iDiff.x * iDiff.y = 0
     then MoveCost := 1.0
     else MoveCost := 1.3;

  if TLevel(Parent).Being[ Stop ] <> nil then MoveCost := MoveCost * 5;

  iStopID   := TLevel(Parent).getCell(Stop);
  iStopCell := Cells[ iStopID ];
  if not ( BF_FLY in FFlags ) then MoveCost := MoveCost * iStopCell.MoveCost;
  if BF_ENVIROSAFE in FFlags then Exit;
  if isHazard( iStopID ) then
  begin
    if FHp = FHpMax then Exit( 30 * MoveCost );
    if isHazard( TLevel(Parent).getCell(Start) ) then Exit( 3 * MoveCost );
    Exit( 5 * MoveCost );
  end;
end;

function TBeing.CostEstimate(const Start, Stop: TCoord2D): Single;
begin
  Exit( RealDistance(Start,Stop) )
end;

function TBeing.passableCoord( const aCoord : TCoord2D ): boolean;
var iItem : TItem;
begin
  if not TLevel(Parent).isProperCoord( aCoord ) then Exit( False );
  with Cells[ TLevel(Parent).getCell( aCoord ) ] do
  begin
    if (not isPlayer) and (CF_HAZARD in Flags) and (not ((BF_ENVIROSAFE in FFlags) or (BF_CHARGE in FFlags))) then Exit( False );
    iItem := TLevel(Parent).Item[ aCoord ];
    if Assigned( iItem ) and ( iItem.Flags[ IF_BLOCKMOVE ] ) then Exit( False );
    if (not ( CF_BLOCKMOVE in Flags )) then Exit( True );
    if (BF_OPENDOORS in FFlags) and ( CF_OPENABLE in Flags ) then Exit( True );
  end;
  Exit( False );
end;

function lua_being_new(L: Plua_State): Integer; cdecl;
var State       : TDoomLuaState;
    Being       : TBeing;
begin
  State.Init( L );
  Being := TBeing.Create(State.ToId( 1 ));
  State.Push( Being );
  Result := 1;
end;

function lua_being_kill(L: Plua_State): Integer; cdecl;
var State       : TDoomLuaState;
    Being       : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  Being.Kill(15,State.ToBoolean(2),nil,nil);
  Result := 0;
end;

function lua_being_get_name(L: Plua_State): Integer; cdecl;
var State       : TDoomLuaState;
    Being       : TBeing;
    Res         : AnsiString;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  Res := Being.getName(State.ToBoolean( 2 ));
  if State.ToBoolean( 3 ) then Res := Capitalized(Res);
  State.Push( Res );
  Result := 1;
end;

function lua_being_ressurect(L: Plua_State): Integer; cdecl;
var State       : TDoomLuaState;
    Being       : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  Being.Ressurect( State.ToInteger(2) );
  Result := 0;
end;

function lua_being_apply_damage(L: Plua_State): Integer; cdecl;
var State       : TDoomLuaState;
    Being       : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  Being.ApplyDamage(State.ToInteger(2),TBodyTarget( State.ToInteger(3) ), TDamageType( State.ToInteger(4,Byte(Damage_Bullet)) ), State.ToObjectOrNil(2) as TItem );
  Result := 0;
end;

function lua_being_get_eq_item(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  State.Push( Being.Inv.Slot[TEqSlot(State.ToInteger( 2 ))] );
  Result := 1;
end;

function lua_being_set_eq_item(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
    slot    : TEqSlot;
    Item    : TItem;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  slot  := TEqSlot(State.ToInteger( 2 ));
  Item  := State.ToObjectOrNil(3) as TItem;

  if (Being.Inv.Slot[slot] <> nil) and (Being.Inv.Slot[slot] <> Item) then
    Being.Inv.Slot[slot].Free;

  if item <> nil then
    if not (Item.IType in ItemEqFilters[slot]) then
      State.Error('Being.seteqitem has wrong item for given slot!'+IntToStr(LongInt(Item.IType))+','+IntToStr(LongInt(Slot)));

  Being.Inv.setSlot(slot,Item);
  Result := 0;
end;

function lua_being_add_inv_item(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
    Item    : TItem;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  Item  := State.ToObject(2) as TItem;

  if Being.FInv.isFull then
    State.Push( False )
  else
  begin
    Being.FInv.Add(item);
    State.Push( True );
  end;
  Result := 1;
end;

function lua_being_get_total_resistance(L: Plua_State): Integer; cdecl;
var State  : TDoomLuaState;
    Being  : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  State.Push( Being.getTotalResistance( State.ToString(2), TBodyTarget( State.ToInteger(3, Byte(TARGET_TORSO) ) )) );
  Result := 1;
end;

function lua_being_play_sound(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    Being : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  Being.playSound( State.ToString(2), State.ToInteger(3,0) );
  Result := 0;
end;

function lua_being_quick_swap(L: Plua_State): Integer; cdecl;
var State  : TDoomLuaState;
    Being  : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  State.Push( Being.ActionSwapWeapon );
  Result := 1;
end;

function lua_being_drop(L: Plua_State): Integer; cdecl;
var State  : TDoomLuaState;
    Being  : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  State.Push( Being.ActionDrop( State.ToObjectOrNil( 2 ) as TItem ) );
  Result := 1;
end;

function lua_being_attack(L: Plua_State): Integer; cdecl;
var State  : TDoomLuaState;
    Being  : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if State.IsObject(2) then
    Being.Attack( State.ToObject(2) as TBeing )
  else
  begin
    if State.IsNil(2) then Exit(0);
    Being.Attack( State.ToCoord(2) );
  end;
  Result := 1;
end;

function lua_being_fire(L: Plua_State): Integer; cdecl;
var State  : TDoomLuaState;
    Being  : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  // TODO: add Hook_OnFire ?
  State.Push( Being.ActionFire( State.ToPosition(2), State.ToObject(3) as TItem ) );
  Result := 1;
end;

function lua_being_reload(L: Plua_State): Integer; cdecl;
var State  : TDoomLuaState;
    Being  : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  State.Push( Being.ActionReload );
  Result := 1;
end;

function lua_being_alt_reload(L: Plua_State): Integer; cdecl;
var State  : TDoomLuaState;
    Being  : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  State.Push( Being.ActionAltReload );
  Result := 1;
end;

function lua_being_direct_seek(L: Plua_State): Integer; cdecl;
var State  : TDoomLuaState;
    Being  : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if State.IsNil(2) then begin State.Push( Byte(MoveBlock) ); Exit(1); end;
  State.Push( Byte(Being.MoveTowards(State.ToPosition(2), State.ToFloat(3,1.0))) );
  State.PushCoord( Being.LastMove );
  Result := 2;
end;

function lua_being_use(L: Plua_State): Integer; cdecl;
var State  : TDoomLuaState;
    Being  : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  State.Push( Being.ActionUse( State.ToObjectOrNil(2) as TItem ) );
  Result := 1;
end;

function lua_being_wear(L: Plua_State): Integer; cdecl;
var State  : TDoomLuaState;
    Being  : TBeing;
    Item   : TItem;
    LRes   : Boolean;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  Item := State.ToObject(2) as TItem;
  if Item <> nil then
  begin
    with Being do
    if Item.isWearable then
    begin
      Inv.Wear( Item );
      SCount := SCount - ActionCostWear;
      LRes := True;
    end;
  end;
  State.Push( LRes );
  Result := 1;
end;

function lua_being_pickup(L: Plua_State): Integer; cdecl;
var State  : TDoomLuaState;
    Being  : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  State.Push( Being.ActionPickup );
  Result := 1;
end;

function lua_being_unload(L: Plua_State): Integer; cdecl;
var State  : TDoomLuaState;
    Being  : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  State.Push( Being.ActionUnload( State.ToObject(1) as TItem ) );
  Result := 1;
end;

function lua_being_path_find(L: Plua_State): Integer; cdecl;
var iState  : TDoomLuaState;
    iBeing  : TBeing;
begin
  iState.Init(L);
  iBeing := iState.ToObject(1) as TBeing;
  if iState.IsNil(2) then begin iState.Push( false ); Exit(1); end;

  with iBeing do
  begin
    if FPath = nil then FPath := TPathfinder.Create( iBeing );
    FPathHazards := [];
    FPathClear   := [];
    iState.Push( FPath.Run( iBeing.FPosition, iState.ToPosition(2), iState.ToInteger(3), iState.ToInteger(4) ) );
    if FPath.Found then FPath.Start := FPath.Start.Child;
  end;
  Result := 1;
end;

function lua_being_path_next(L: Plua_State): Integer; cdecl;
var iState  : TDoomLuaState;
    iBeing  : TBeing;
    iMoveR  : TMoveResult;
    iSuccess: Boolean;
begin
  iState.Init(L);
  iBeing := iState.ToObject(1) as TBeing;
  with iBeing do
  begin
    if (FPath = nil) or (not FPath.Found)
      or (FPath.Start = nil) or (Distance( FPath.Start.Coord, iBeing.Position ) <> 1) then
      begin
        iState.Push( False );
        Exit(1);
      end;

    iMoveR := iBeing.TryMove( FPath.Start.Coord );

    if iMoveR in [ MoveBlock, MoveBeing ] then
    begin
      iState.Push( Byte(iMoveR) );
      iState.PushCoord( iBeing.LastMove );
      Exit(2);
    end;

    if iMoveR = MoveDoor then
    begin
      if BF_OPENDOORS in iBeing.FFlags then
      begin
        iSuccess := Boolean( TLevel(iBeing.Parent).CallHook( FPath.Start.Coord, iBeing, CellHook_OnAct ) );
        if not iSuccess then iMoveR := MoveBlock;
      end;
      iState.Push( Byte(iMoveR) );
      iState.PushCoord( iBeing.LastMove );
      Exit(2);
    end;

    iBeing.MoveTowards(FPath.Start.Coord);
    FPath.Start := FPath.Start.Child;
    iState.Push( Byte(iMoveR) );
    iState.PushCoord( iBeing.LastMove );
  end;
  Result := 2;
end;

function lua_being_inv_items_closure(L: Plua_State): Integer; cdecl;
var State     : TDoomLuaState;
    Parent    : TBeing;
    Next      : TItem;
    Current   : TItem;
    Filter    : Byte;
begin
  State.Init( L );
  Parent    := TObject( lua_touserdata( L, lua_upvalueindex(1) ) ) as TBeing;
  Next      := TObject( lua_touserdata( L, lua_upvalueindex(2) ) ) as TItem;
  Filter    := lua_tointeger( L, lua_upvalueindex(3) );

  repeat
    Current := Next as TItem;
    if Next <> nil then Next := Next.Next as TItem;
    if Next = Parent.Child then Next := nil;
  until (Current = nil) or
        (((Filter = 0) or (Byte(Current.iType) = Filter)) and
         ( not Parent.Inv.Equipped(Current) ));

  lua_pushlightuserdata( L, Next );
  lua_replace( L, lua_upvalueindex(2) );

  State.Push( Current );
  Exit( 1 );
end;

// iterator
function lua_being_inv_items(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  lua_pushlightuserdata( L, Being );
  lua_pushlightuserdata( L, Being.Child );
  if lua_isnumber( L, 2 )
    then lua_pushvalue( L, 2 )
    else lua_pushnumber( L, 0 );
  lua_pushcclosure( L, @lua_being_inv_items_closure, 3 );
  Exit( 1 );
end;

function lua_being_inv_size(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  State.Push( Being.Inv.Size );
  Exit( 1 );
end;

function lua_being_relocate(L: Plua_State): Integer; cdecl;
var State  : TDoomLuaState;
    Thing  : TThing;
    Target : TCoord2D;
begin
  State.Init(L);
  Thing := State.ToObject(1) as TThing;
  if State.IsNil(2) then Exit(0);
  Target := State.ToCoord(2);
  if GraphicsVersion then
    if Thing is TBeing then
      if Thing is TPlayer then
        IO.addScreenMoveAnimation(Distance(Thing.Position,Target)*10,Target);
  Thing.Displace(Target);
  Result := 0;
end;


function lua_being_set_affect(L: Plua_State): Integer; cdecl;
var iState : TDoomLuaState;
    iBeing : TBeing;
begin
  iState.Init(L);
  iBeing := iState.ToObject(1) as TBeing;
  iBeing.Affects.Add( iState.ToId(2), iState.ToInteger(3,-1) );
  Result := 0;
end;

function lua_being_get_affect_time(L: Plua_State): Integer; cdecl;
var iState : TDoomLuaState;
    iBeing : TBeing;
begin
  iState.Init(L);
  iBeing := iState.ToObject(1) as TBeing;
  iState.Push( iBeing.Affects.getTime( iState.ToId(2) ) );
  Result := 1;
end;

function lua_being_remove_affect(L: Plua_State): Integer; cdecl;
var iState : TDoomLuaState;
    iBeing : TBeing;
begin
  iState.Init(L);
  iBeing := iState.ToObject(1) as TBeing;
  iBeing.Affects.Remove( iState.ToId(2), iState.ToBoolean( 3, False ) );
  Result := 0;
end;

function lua_being_is_affect(L: Plua_State): Integer; cdecl;
var iState : TDoomLuaState;
    iBeing : TBeing;
begin
  iState.Init(L);
  iBeing := iState.ToObject(1) as TBeing;
  iState.Push( iBeing.Affects.IsActive( iState.ToId( 2 ) ) );
  Result := 1;
end;

const lua_being_lib : array[0..29] of luaL_Reg = (
      ( name : 'new';           func : @lua_being_new),
      ( name : 'kill';          func : @lua_being_kill),
      ( name : 'ressurect';     func : @lua_being_ressurect),
      ( name : 'apply_damage';  func : @lua_being_apply_damage),
      ( name : 'get_name';      func : @lua_being_get_name),
      ( name : 'inv_items';     func : @lua_being_inv_items),
      ( name : 'get_eq_item';   func : @lua_being_get_eq_item),
      ( name : 'set_eq_item';   func : @lua_being_set_eq_item),
      ( name : 'add_inv_item';  func : @lua_being_add_inv_item),
      ( name : 'play_sound';    func : @lua_being_play_sound),
      ( name : 'get_total_resistance';func : @lua_being_get_total_resistance),

      ( name : 'quick_swap';    func : @lua_being_quick_swap),
      ( name : 'pickup';        func : @lua_being_pickup),
      ( name : 'unload';        func : @lua_being_unload),
      ( name : 'drop';          func : @lua_being_drop),
      ( name : 'use';           func : @lua_being_use),
      ( name : 'wear';          func : @lua_being_wear),
      ( name : 'attack';        func : @lua_being_attack),
      ( name : 'fire';          func : @lua_being_fire),
      ( name : 'reload';        func : @lua_being_reload),
      ( name : 'alt_reload';    func : @lua_being_alt_reload),
      ( name : 'direct_seek';   func : @lua_being_direct_seek),
      ( name : 'relocate';      func : @lua_being_relocate),

      ( name : 'path_find';     func : @lua_being_path_find),
      ( name : 'path_next';     func : @lua_being_path_next),

      ( name : 'set_affect';      func : @lua_being_set_affect),
      ( name : 'get_affect_time'; func : @lua_being_get_affect_time),
      ( name : 'remove_affect';   func : @lua_being_remove_affect),
      ( name : 'is_affect';       func : @lua_being_is_affect),

      ( name : nil;             func : nil; )
);

class procedure TBeing.RegisterLuaAPI();
begin
  LuaSystem.Register( 'being', lua_being_lib );
end;

end.
