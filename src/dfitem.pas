{$INCLUDE doomrl.inc}
{
----------------------------------------------------
DFITEM.PAS -- Items data and handling for Downfall
Copyright (c) 2002 by Kornel "Anubis" Kisielewicz
----------------------------------------------------
}
unit dfitem;
interface
uses Classes, SysUtils, dfthing, dfdata, vrltools, vluatable, math;

type TItemSounds = record
  Pickup     : Word;
  Reload     : Word;
  Fire       : Word;
end;

type TItemRecharge = record
  Delay   : Byte;
  Amount  : Byte;
  Counter : Byte;
  Limit   : Byte;
end;

type

{ TItem }

TItem  = class( TThing )

    constructor Create( const anid : AnsiString; onFloor : boolean = False ); overload;
    constructor Create(anid : byte; onFloor : boolean = False); overload;
    constructor CreateFromStream( Stream: TStream ); override;
    procedure WriteToStream( Stream: TStream ); override;

    function    rollDamage : Integer;
    function    maxDamage : Integer;
    function    GetName(known : boolean) : string;
    function    GetProtection : Byte;
    function    GetResistance( const aResistance : AnsiString ) : Integer;
    function    Description : Ansistring;
    function    DescriptionBox( aNewFormat : Boolean = False ) : Ansistring;
    function    ResistDescriptionShort : AnsiString;
    destructor  Destroy; override;
    function    CanMod(aModChar : char) : Boolean;
    function    AddMod(aModChar : char) : Boolean;
    function    eqSlot : TEqSlot;
    function    isAmmo : boolean;
    function    isMelee : boolean;
    function    isRanged : boolean;
    function    isWeapon : boolean;
    function    isTele : boolean;
    function    isLever : boolean;
    function    isPower : boolean;
    function    isPack : boolean;
    function    isAmmoPack : boolean;
    function    isWearable : boolean;
    function    canFire : boolean;
    function MenuColor : byte;
    procedure RechargeReset;
    procedure Tick( Owner : TThing );
    function Preposition( const Item : AnsiString ) : string;
    class function Compare( a, b : TItem ) : Boolean; reintroduce;
    class procedure RegisterLuaAPI();
    private
    FRecharge : TItemRecharge;
    FSounds   : TItemSounds;
    FArmor    : Byte;
    FNID      : Byte;
    FProps    : TItemProperties;
    FMods     : array[Ord('A')..Ord('Z')] of Byte;
    procedure LuaLoad( Table : TLuaTable; onFloor: boolean ); reintroduce;
    public
    property NID           : Byte        read FNID;
    property Sounds        : TItemSounds read FSounds;
    published
    property Armor          : Byte        read FArmor                write FArmor;
    property RechargeDelay  : Byte        read FRecharge.Delay       write FRecharge.Delay;
    property RechargeAmount : Byte        read FRecharge.Amount      write FRecharge.Amount;
    property RechargeLimit  : Byte        read FRecharge.Limit       write FRecharge.Limit;
    property IType          : TItemType   read FProps.IType          write FProps.IType;
    property Durability     : Word        read FProps.Durability     write FProps.Durability;
    property MaxDurability  : Word        read FProps.MaxDurability  write FProps.MaxDurability;
    property MoveMod        : Integer     read FProps.MoveMod        write FProps.MoveMod;
    property DodgeMod       : Integer     read FProps.DodgeMod       write FProps.DodgeMod;
    property KnockMod       : Integer     read FProps.KnockMod       write FProps.KnockMod;
    property AmmoID         : Byte        read FProps.AmmoID         write FProps.AmmoID;
    property Ammo           : Word        read FProps.Ammo           write FProps.Ammo;
    property AmmoMax        : Word        read FProps.AmmoMax        write FProps.AmmoMax;
    property Acc            : ShortInt    read FProps.Acc            write FProps.Acc;
    property Damage_Dice    : Word        read FProps.Damage.Amount  write FProps.Damage.Amount;
    property Damage_Sides   : Word        read FProps.Damage.Sides   write FProps.Damage.Sides;
    property Damage_Add     : Integer     read FProps.Damage.Bonus   write FProps.Damage.Bonus;
    property Missile        : Byte        read FProps.Missile        write FProps.Missile;
    property BlastRadius    : Byte        read FProps.BlastRadius    write FProps.BlastRadius;
    property Shots          : Byte        read FProps.Shots          write FProps.Shots;
    property ShotCost       : Byte        read FProps.ShotCost       write FProps.ShotCost;
    property ReloadTime     : Byte        read FProps.ReloadTime     write FProps.ReloadTime;
    property UseTime        : Byte        read FProps.UseTime        write FProps.UseTime;
    property DamageType     : TDamageType read FProps.DamageType     write FProps.DamageType;
    property AltFire        : TAltFire    read FProps.AltFire        write FProps.AltFire;
    property AltReload      : TAltReload  read FProps.AltReload      write FProps.AltReload;
    property Desc           : AnsiString  read Description;
  end;

procedure SwapItem(var a, b: TItem);

implementation

uses doomlua, doomio, vluasystem, vluaentitynode, vutil, vdebug, dfbeing, dfplayer, doombase, vmath, doomhooks;

procedure SwapItem(var a, b: TItem);
var c : TItem;
begin
  c := a;
  a := b;
  b := c;
end;

class function TItem.Compare(a, b: TItem): Boolean;
begin
  if a = nil then Exit(True);
  if b = nil then Exit(False);
  if a.FProps.IType > b.FProps.IType then Exit(True);
  if a.FProps.IType < b.FProps.IType then Exit(False);
  Exit(a.NID > b.NID);
end;

function TItem.eqSlot : TEqSlot;
begin
  case FProps.IType of
    ITEMTYPE_ARMOR    : Exit(efTorso);
    ITEMTYPE_MELEE    : Exit(efWeapon);
    ITEMTYPE_RANGED   : Exit(efWeapon);
    ITEMTYPE_NRANGED  : Exit(efWeapon);
    ITEMTYPE_BOOTS    : Exit(efBoots);
    ITEMTYPE_AMMOPACK : Exit(efWeapon2);
  end;
  raise EItemException.CreateFmt('eqSlot -- unsupported IType: %d',[ Byte( FProps.Itype ) ]);
end;

constructor TItem.Create(anid : byte; onFloor : boolean);
var Table : TLuaTable;
begin
  inherited Create( LuaSystem.Get( ['items',anid,'id'] ) );
  FEntityID := ENTITY_ITEM;
  if aNID = 0 then raise EItemException.Create('Bad item (ID#0) passed to Create!');

  Table := LuaSystem.GetTable( ['items',anid ] );
  LuaLoad( Table, onFloor );
  FreeAndNil( Table );
end;

constructor TItem.Create( const anid : AnsiString; onFloor: boolean);
var Table : TLuaTable;
begin
  inherited Create( anid );
  FEntityID := ENTITY_ITEM;
  if anid = '' then raise EItemException.Create('Bad item id!');

  Table := LuaSystem.GetTable( ['items',anid] );
  LuaLoad( Table, onFloor );
  FreeAndNil( Table );
end;

constructor TItem.CreateFromStream ( Stream : TStream ) ;
begin
  inherited CreateFromStream ( Stream ) ;

  Stream.Read( FRecharge, SizeOf( FRecharge ) );
  Stream.Read( FSounds,   SizeOf( FSounds ) );
  Stream.Read( FMods,     SizeOf( FMods ) );
  Stream.Read( FProps,    SizeOf( FProps ) );

  FArmor := Stream.ReadByte();
  FNID   := Stream.ReadByte();
end;

procedure TItem.WriteToStream ( Stream : TStream ) ;
begin
  inherited WriteToStream ( Stream ) ;

  Stream.Write( FRecharge, SizeOf( FRecharge ) );
  Stream.Write( FSounds,   SizeOf( FSounds ) );
  Stream.Write( FMods,     SizeOf( FMods ) );
  Stream.Write( FProps,    SizeOf( FProps ) );

  Stream.WriteByte( FArmor );
  Stream.WriteByte( FNID );
end;

procedure TItem.LuaLoad( Table : TLuaTable; onFloor: boolean );
var cnt : byte;
    soundID : string[20];
begin
  inherited LuaLoad( Table );
  FHooks := FHooks * ItemHooks;

  FProps.itype:= TItemType( Table.getInteger('type') );
  FSounds.Pickup := 0;
  FSounds.Reload := 0;
  FSounds.Fire   := 0;
  
  for cnt := Ord('A') to Ord('Z') do FMods[cnt] := 0;

  FArmor           := Table.getInteger('armor',0);
  FNID             := Table.getInteger('nid');
  FRecharge.Delay  := Table.getInteger('rechargedelay',0);
  FRecharge.Amount := Table.getInteger('rechargeamount',0);
  FRecharge.Limit  := Table.getInteger('rechargelimit',0);
  FRecharge.Counter:= 0;

   case FProps.IType of
     ITEMTYPE_TELE,
     ITEMTYPE_LEVER :
       begin
         soundid := Table.getString('sound_id','');
         if soundid = '' then soundid := ID;
         FSounds.Fire := IO.Audio.ResolveSoundID([ID+'.use',soundid+'.use','use']);
       end;
     ITEMTYPE_ARMOR,
     ITEMTYPE_BOOTS :
       begin
         FProps.Durability := Table.getInteger('durability');
         if FProps.Durability = 0 then FProps.Durability := 100;
         FProps.MaxDurability := FProps.Durability;
         FProps.MoveMod  := Table.getInteger('movemod');
         FProps.DodgeMod  := Table.getInteger('dodgemod');
         FProps.KnockMod := Table.getInteger('knockmod');
         FSounds.Pickup := IO.Audio.ResolveSoundID([ID+'.pickup','pickup']);
       end;
     ITEMTYPE_PACK,
     ITEMTYPE_POWER :
       begin
         if FProps.IType = ITEMTYPE_POWER
           then FSounds.Fire   := IO.Audio.ResolveSoundID([ID+'.activate','activate'])
           else FSounds.Fire   := IO.Audio.ResolveSoundID([ID+'.use','use']);
         FSounds.Pickup := IO.Audio.ResolveSoundID([ID+'.pickup','pickup']);
       end;
     ITEMTYPE_AMMO, ITEMTYPE_AMMOPACK :
       begin
         FProps.Ammo        := Table.getInteger('ammo');
         FProps.AmmoMax     := Table.getInteger('ammomax');
         FProps.AmmoID      := Table.getInteger('ammo_id',0);
         FSounds.Pickup := IO.Audio.ResolveSoundID([ID+'.pickup','pickup']);
       end;
     ITEMTYPE_MELEE :
       begin
         FProps.Damage      := NewDiceRoll( Table.getInteger('damage_dice'), Table.getInteger('damage_sides'), Table.getInteger('damage_bonus') );
         FSounds.Fire   := IO.Audio.ResolveSoundID([ID+'.attack','attack']);
         FSounds.Pickup := IO.Audio.ResolveSoundID([ID+'.pickup','pickup']);
         FProps.DamageType  := TDamageType( Table.getInteger('damagetype') );
         FProps.Acc         := Table.getInteger('acc');
         FProps.UseTime     := Table.getInteger('fire');
         FProps.AltFire     := TAltFire( Table.getInteger('altfire') );
         FProps.missile     := Table.getInteger('missile');
       end;
     ITEMTYPE_RANGED, ITEMTYPE_NRANGED:
       begin
         FProps.Damage      := NewDiceRoll( Table.getInteger('damage_dice'), Table.getInteger('damage_sides'), Table.getInteger('damage_bonus') );
         FProps.AmmoID      := Table.getInteger('ammo_id',0);
         FProps.AmmoMax     := Table.getInteger('ammomax',0);
         FProps.Ammo        := FProps.AmmoMax;
         FProps.Acc         := Table.getInteger('acc');
         FProps.missile     := Table.getInteger('missile');
         FProps.BlastRadius := Table.getInteger('radius');
         FProps.Shots       := Table.getInteger('shots');
         FProps.ShotCost    := Table.getInteger('shotcost',0);
         FProps.ReloadTime  := Table.getInteger('reload',0);
         FProps.UseTime     := Table.getInteger('fire',0);
         FProps.AltFire     := TAltFire( Table.getInteger('altfire',0) );
         FProps.AltReload   := TAltReload( Table.getInteger('altreload',0) );
         FProps.DamageType  := TDamageType( Table.getInteger('damagetype',0) );
         soundid := Table.getString('sound_id','');
         if soundid = '' then soundid := ID;
         FSounds.Fire   := IO.Audio.ResolveSoundID([ID+'.fire', SoundID+'.fire', 'fire']);
         FSounds.Pickup := IO.Audio.ResolveSoundID([ID+'.pickup', SoundID+'.pickup', 'pickup']);
         FSounds.Reload := IO.Audio.ResolveSoundID([ID+'.reload', SoundID+'.reload', 'reload']);
       end;
  end;

  if onFloor and isAmmo then
    FProps.Ammo := Round( FProps.Ammo * Double(LuaSystem.Get([ 'diff', Doom.Difficulty, 'ammofactor' ])) );

  CallHook( Hook_OnCreate, [] );
end;

function TItem.MenuColor: byte;
begin
  if not Option_ColoredInventory then Exit(LightGray);
  if Color = white then Exit(LightGray) else Exit(Color);
end;

procedure TItem.RechargeReset;
begin
  FRecharge.Counter := FRecharge.Delay;
end;

function    TItem.rollDamage : Integer;
begin
  if isWeapon then Exit(FProps.Damage.Roll);
  raise EItemException.CreateFmt('TItem.Damage called for Itype %d!',[ Byte( FProps.Itype ) ] );
end;

function TItem.maxDamage: Integer;
begin
  if isWeapon then Exit(FProps.Damage.Max);
  raise EItemException.CreateFmt('TItem.MaxDamage called for Itype %d!',[ Byte( FProps.Itype ) ] );
end;

function    TItem.GetProtection : Byte;
begin
  if FArmor = 0 then Exit(0);
  if Flags[ IF_NODEGRADE ] then Exit(FArmor);
  if (FProps.IType in [ITEMTYPE_ARMOR,ITEMTYPE_BOOTS]) then
    case FProps.Durability of
      0         : GetProtection := 0;
      1  .. 25  : GetProtection := Max( FArmor div 4, 1 );
      26 .. 49  : GetProtection := Max( FArmor div 2, 1 );
      50 ..1000 : GetProtection := FArmor;
    end
  else Exit(FArmor);
end;

function    TItem.GetResistance ( const aResistance : AnsiString ): Integer;
var iResist : LongInt;
begin
  iResist := GetLuaProperty( ['resist',aResistance], 0 );
  if iResist <= 0 then Exit(iResist);
  if Flags[ IF_NODEGRADE ] then Exit(iResist);
  if (FProps.IType in [ITEMTYPE_ARMOR,ITEMTYPE_BOOTS]) then
    case FProps.Durability of
      0         : GetResistance := 0;
      1  .. 25  : GetResistance := Ceil( Max( iResist div 4, 1 ) );
      26 .. 49  : GetResistance := Ceil( Max( iResist div 2, 1 ) );
      50 ..1000 : GetResistance := iResist;
    end
  else Exit(iResist);
end;

function    TItem.Description : Ansistring;
var FlagStr : string[10];
    Count   : Byte;
begin
  Description := Name;
  case FProps.IType of
    ITEMTYPE_LEVER    : Exit(Description);
    ITEMTYPE_AMMO     : if FProps.Ammo > 1 then Description += ' (x'+IntToStr(FProps.Ammo)+')';
    ITEMTYPE_AMMOPACK : Description += ' (x'+IntToStr(FProps.Ammo)+')';
    ITEMTYPE_MELEE :
    begin
      Description += ' ('+FProps.Damage.toString+')';
      FlagStr := '';
      if IF_MODIFIED in FFlags then
      for Count := Ord('A') to Ord('Z') do
        if FMods[Count] > 0 then FlagStr += Chr(Count);
      if FArmor <> 0 then Description += ' ['+IntToStr(FArmor)+']';
      if FlagStr <> '' then Description += ' ('+FlagStr+')';
      Description += ResistDescriptionShort;
    end;
    ITEMTYPE_ARMOR, ITEMTYPE_BOOTS :
      begin
        if IF_NODURABILITY in FFlags then
          Description += ' ['+IntToStr(GetProtection)+']'
        else
          Description += ' ['+IntToStr(GetProtection)+'/'+IntToStr(FArmor)+'] ('+IntToStr(FProps.Durability)+'%)';
        FlagStr := '';
        if IF_MODIFIED in FFlags then
        for Count := Ord('A') to Ord('Z') do
          if FMods[Count] > 0 then FlagStr += Chr(Count);
        if FlagStr <> '' then Description += ' ('+FlagStr+')';
        //Description += ResistDescriptionShort;
      end;
    ITEMTYPE_RANGED: begin
            Description += ' ('+FProps.Damage.toString+')';
            if FProps.Shots <> 0 then Description += 'x' +IntToStr(FProps.Shots);
            if not ( IF_NOAMMO in FFlags ) then Description += ' ['+IntToStr(FProps.Ammo)+'/'+IntToStr(FProps.AmmoMax)+']';
            if FArmor <> 0 then Description += ' ['+IntToStr(FArmor)+']';
            if IF_MODIFIED in FFlags then
            begin
              FlagStr := '';
              for Count := Ord('A') to Ord('Z') do
              if FMods[Count] > 0 then
                FlagStr += Chr(Count) + IntToStr(FMods[Count]);
              if FlagStr <> '' then Description += ' ('+FlagStr+')';
            end;
            Description += ResistDescriptionShort;
          end;
  end;
end;

function TItem.DescriptionBox( aNewFormat : Boolean = False ): Ansistring;
  function Iff(expr : Boolean; str : Ansistring) : Ansistring;
  begin
    if expr then exit(str) else exit('');
  end;
  function AltFireName( aValue : TAltFire ) : AnsiString;
  begin
    AltFireName := LuaSystem.Get([ 'items', ID, 'altfirename' ], '');
    if AltFireName <> '' then Exit;
    case aValue of
      ALT_CHAIN     : Exit('chain fire');
      ALT_THROW     : Exit('throw');
      ALT_AIMED     : Exit('aimed');
      ALT_SINGLE    : Exit('single');
    end;
  end;
  function AltReloadName( aValue : TAltReload ) : AnsiString;
  begin
    AltReloadName := LuaSystem.Get([ 'items', ID, 'altreloadname' ], '');
    if AltReloadName <> '' then Exit;
    case aValue of
      RELOAD_FULL        : Exit('full');
      RELOAD_DUAL        : Exit('dual');
      RELOAD_SINGLE      : Exit('single');
    end;
  end;
begin
  if aNewFormat then
  begin
    DescriptionBox := '';
    case FProps.IType of
      ITEMTYPE_ARMOR, ITEMTYPE_BOOTS : DescriptionBox :=
        'Durability  : {!'+IntToStr(FProps.MaxDurability)+'}'#10+
        'Move speed  : {!'+Percent(FProps.MoveMod)+'}'#10+
        'Knockback   : {!'+Percent(FProps.KnockMod)+'}'#10+
        Iff(FProps.DodgeMod <> 0,'Dodge rate  : {!'+Percent(FProps.DodgeMod)+'}'#10);
      ITEMTYPE_RANGED : DescriptionBox :=
        'Fire time   : {!'+Seconds(FProps.UseTime)+'}'#10+
        'Reload time : {!'+Seconds(FProps.ReloadTime)+'}'#10+
        'Accuracy    : {!'+BonusStr(FProps.Acc)+'}'#10+
        Iff(FProps.Shots       <> 0,'Shots       : {!'+IntToStr(FProps.Shots)+'}'#10)+
        Iff(FProps.ShotCost    <> 0,'Shot cost   : {!'+IntToStr(FProps.ShotCost)+'}'#10)+
        Iff(FProps.BlastRadius <> 0,'Expl.radius : {!'+IntToStr(FProps.BlastRadius)+'}'#10)+
        Iff(FProps.AltFire   <> ALT_NONE   ,'Alt. fire   : {!'+AltFireName( FProps.AltFire )+'}'#10)+
        Iff(FProps.AltReload <> RELOAD_NONE,'Alt. reload : {!'+AltReloadName( FProps.AltReload )+'}'#10);
      ITEMTYPE_MELEE : DescriptionBox :=
        'Attack time : {!'+Seconds(FProps.UseTime)+'}'#10+
        Iff(FProps.Acc     <> 0,'Accuracy    : {!' + BonusStr(FProps.Acc)+'}'#10)+
        Iff(FProps.AltFire <> ALT_NONE,'Alt. fire   : {!'+AltFireName( FProps.AltFire )+'}'#10);
    end;
    DescriptionBox +=
        Iff(GetResistance('bullet')   <> 0,'Bullet res. : {!' + BonusStr(GetResistance('bullet'))+'}'#10)+
        Iff(GetResistance('melee')    <> 0,'Melee res.  : {!' + BonusStr(GetResistance('melee'))+'}'#10)+
        Iff(GetResistance('shrapnel') <> 0,'Shrapnel res: {!' + BonusStr(GetResistance('shrapnel'))+'}'#10)+
        Iff(GetResistance('acid')     <> 0,'Acid res.   : {!' + BonusStr(GetResistance('acid'))+'}'#10)+
        Iff(GetResistance('fire')     <> 0,'Fire res.   : {!' + BonusStr(GetResistance('fire'))+'}'#10)+
        Iff(GetResistance('plasma')   <> 0,'Plasma res. : {!' + BonusStr(GetResistance('plasma'))+'}'#10);
  end
  else
  begin
    DescriptionBox := '';
    case FProps.IType of
      ITEMTYPE_ARMOR, ITEMTYPE_BOOTS : DescriptionBox :=
        'Durability  : @<'+IntToStr(FProps.MaxDurability)+'@>'#10+
        'Move speed  : @<'+Percent(FProps.MoveMod)+'@>'#10+
        'Knockback   : @<'+Percent(FProps.KnockMod)+'@>'#10+
        Iff(FProps.DodgeMod <> 0,'Dodge rate  : @<'+Percent(FProps.DodgeMod)+'@>'#10);
      ITEMTYPE_RANGED : DescriptionBox :=
        'Fire time   : @<'+Seconds(FProps.UseTime)+'@>'#10+
        'Reload time : @<'+Seconds(FProps.ReloadTime)+'@>'#10+
        'Accuracy    : @<'+BonusStr(FProps.Acc)+'@>'#10+
        Iff(FProps.Shots       <> 0,'Shots       : @<'+IntToStr(FProps.Shots)+'@>'#10)+
        Iff(FProps.ShotCost    <> 0,'Shot cost   : @<'+IntToStr(FProps.ShotCost)+'@>'#10)+
        Iff(FProps.BlastRadius <> 0,'Expl.radius : @<'+IntToStr(FProps.BlastRadius)+'@>'#10)+
        Iff(FProps.AltFire   <> ALT_NONE   ,'Alt. fire   : @<'+AltFireName( FProps.AltFire )+'@>'#10)+
        Iff(FProps.AltReload <> RELOAD_NONE,'Alt. reload : @<'+AltReloadName( FProps.AltReload )+'@>'#10);
      ITEMTYPE_MELEE : DescriptionBox :=
        'Attack time : @<'+Seconds(FProps.UseTime)+'@>'#10+
        Iff(FProps.Acc     <> 0,'Accuracy    : @<' + BonusStr(FProps.Acc)+'@>'#10)+
        Iff(FProps.AltFire <> ALT_NONE,'Alt. fire   : @<'+AltFireName( FProps.AltFire )+'@>'#10);
    end;
    DescriptionBox +=
        Iff(GetResistance('bullet')   <> 0,'Bullet res. : @<' + BonusStr(GetResistance('bullet'))+'@>'#10)+
        Iff(GetResistance('melee')    <> 0,'Melee res.  : @<' + BonusStr(GetResistance('melee'))+'@>'#10)+
        Iff(GetResistance('shrapnel') <> 0,'Shrapnel res: @<' + BonusStr(GetResistance('shrapnel'))+'@>'#10)+
        Iff(GetResistance('acid')     <> 0,'Acid res.   : @<' + BonusStr(GetResistance('acid'))+'@>'#10)+
        Iff(GetResistance('fire')     <> 0,'Fire res.   : @<' + BonusStr(GetResistance('fire'))+'@>'#10)+
        Iff(GetResistance('plasma')   <> 0,'Plasma res. : @<' + BonusStr(GetResistance('plasma'))+'@>'#10);
  end;
 end;

function TItem.ResistDescriptionShort: AnsiString;
const ResLetter : array[Low(TResistance)..High(TResistance)] of Char = ( 'b','m','s','a','f','p' );
const ResID   : array[Low(TResistance)..High(TResistance)] of AnsiString =
   ( 'bullet', 'melee', 'shrapnel', 'acid', 'fire', 'plasma' );
var Resistance : TResistance;
    iValue : LongInt;
begin
  ResistDescriptionShort := '';
  for Resistance := Low( TResistance ) to High( TResistance ) do
  begin
    iValue := GetResistance( ResID[ Resistance ] );
    if iValue > 0 then
      ResistDescriptionShort += ResLetter[ Resistance ]
    else if iValue < 0 then
      ResistDescriptionShort += '-'+ResLetter[ Resistance ];
  end;
  if ResistDescriptionShort = '' then Exit('') else Exit(' {'+ResistDescriptionShort+'}')
end;

function TItem.CanMod(aModChar: char): Boolean;
var iSum   : Word;
    iCount : Byte;
    iMax   : Byte;
begin
  if not (aModChar in ['A'..'Z']) then Exit(false);
  if (IF_UNIQUE in FFlags) and (not (IF_MODABLE in FFlags)) then Exit(False);
  if IF_NONMODABLE in FFlags then Exit(False);
  if (not Player.Flags[BF_MODEXPERT]) and ( IF_UNIQUE in FFlags ) then Exit( False );

  iSum := 0;
  for iCount := Ord('A') to Ord('Z') do iSum += FMods[iCount];

  if (IF_ASSEMBLED in FFlags) then
    if Player.TechBonus < (iSum + 2) then
      Exit( False );

  if (IF_SINGLEMOD in FFlags) and (iSum > 0) then Exit(False);

  if FProps.IType = ITEMTYPE_RANGED
    then iMax := 1 + 2* Player.TechBonus
    else iMax := 1 + Player.TechBonus;

  if iSum >= iMax then Exit(false);

  case FProps.IType of
    ITEMTYPE_RANGED :
        if FMods[Ord(aModChar)] > 2 then Exit(False);
    ITEMTYPE_MELEE, ITEMTYPE_ARMOR, ITEMTYPE_BOOTS :
        if FMods[Ord(aModChar)] > 0 then Exit(False);
    else Exit(False);
  end;
  Exit(True);
end;

function TItem.AddMod(aModChar: char): Boolean;
begin
  if not (CanMod(aModChar)) then Exit( false );
  Include(FFlags,IF_MODIFIED);
  Inc(FMods[Ord(aModChar)]);
  Exit(True);
end;

function TItem.Preposition( const Item : AnsiString ) : string;
begin
  if IF_PLURALNAME in FFlags then Exit('');
  Case Item[1] of
    'a','e','i','o','u' : Exit('an ');
  end;
  Exit('a ');
end;

function    TItem.GetName(known : boolean) : string;
begin
  case FProps.IType of
    ITEMTYPE_AMMO : if FProps.Ammo > 1 then Exit(Description);
  end;
  if known then Exit('the '+Description)
           else Exit(Preposition(Description)+Description);
end;

destructor  TItem.Destroy;
begin
  inherited Destroy;
end;

function TItem.isAmmo : boolean;
begin
  Exit(FProps.IType = ITEMTYPE_AMMO);
end;

function TItem.isMelee : boolean;
begin
  Exit(FProps.IType = ITEMTYPE_MELEE);
end;

function TItem.isRanged : boolean;
begin
  Exit(FProps.IType in [ITEMTYPE_RANGED,ITEMTYPE_NRANGED]);
end;

function TItem.isWeapon : boolean;
begin
  Exit(isRanged or isMelee);
end;

function TItem.isTele : boolean;
begin
  Exit(FProps.IType = ITEMTYPE_TELE);
end;

function TItem.isLever : boolean;
begin
  Exit(FProps.IType = ITEMTYPE_LEVER);
end;

function TItem.isPower : boolean;
begin
  Exit(FProps.IType = ITEMTYPE_POWER);
end;

function TItem.isPack : boolean;
begin
  Exit(FProps.IType = ITEMTYPE_PACK);
end;

function TItem.isAmmoPack : boolean;
begin
  Exit(FProps.IType = ITEMTYPE_AMMOPACK);
end;

function TItem.isWearable : boolean;
begin
  Exit(FProps.IType in [ITEMTYPE_RANGED,ITEMTYPE_NRANGED,ITEMTYPE_ARMOR,ITEMTYPE_MELEE,ITEMTYPE_BOOTS,ITEMTYPE_AMMOPACK]);
end;

function TItem.canFire: boolean;
begin
  if not isRanged then Exit( False );
  if not Flags[ IF_NOAMMO ] then
  begin
    if Ammo = 0        then Exit( False );
    if Ammo < ShotCost then Exit( False );
  end;
  if Flags[ IF_CHAMBEREMPTY ] then Exit( False );
  Exit( True );
end;

procedure TItem.Tick( Owner : TThing );
var Being : TBeing;
begin 
  if Hook_OnEquipTick in FHooks then
    CallHook( Hook_OnEquipTick, [ Owner ] );
    
  if Owner is TBeing then Being := Owner as TBeing else Being := nil;
  
  if ( IF_RECHARGE in FFlags ) or ( ( IF_NECROCHARGE in FFlags ) and ( Being <> nil ) and ( Being.HP > 1 ) ) then
  begin
    if FRecharge.Counter = 0 then
    case FProps.IType of
      ITEMTYPE_RANGED :
        if (FProps.Ammo < FProps.AmmoMax) and ( ( FRecharge.Limit = 0 ) or ( FProps.Ammo < FRecharge.Limit ) )  then
        begin
          FProps.Ammo := Min( FProps.Ammo + FRecharge.Amount, IIf( FRecharge.Limit <> 0, Min( FProps.AmmoMax, FRecharge.Limit ), FProps.AmmoMax ) );
          if IF_NECROCHARGE in FFlags then Being.HP := Being.HP - 1;
        end;
      ITEMTYPE_ARMOR,
      ITEMTYPE_BOOTS  :
        if (FProps.Durability < FProps.MaxDurability) and ( ( FRecharge.Limit = 0 ) or ( FProps.Durability < FRecharge.Limit ) ) then
        begin
          FProps.Durability := Min( FProps.Durability + FRecharge.Amount, IIf( FRecharge.Limit <> 0, Min( FProps.MaxDurability, FRecharge.Limit ), FProps.MaxDurability ) );
          if IF_NECROCHARGE in FFlags then Being.HP := Being.HP - 1;
        end;
    end
    else
      FRecharge.Counter := FRecharge.Counter - 1;
  end;
end;

function lua_item_new(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    Item  : TItem;
begin
  State.Init(L);
  Item := TItem.Create( State.ToId( 1 ), State.ToBoolean( 2 ) );
  State.Push(Item);
  Result := 1;
end;

function lua_item_add_mod(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    Item  : TItem;
begin
  State.Init(L);
  Item := State.ToObject(1) as TItem;
  State.Push( Item.AddMod( State.ToChar(2) ));
  Result := 1;
end;

function lua_item_can_mod(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    Item  : TItem;
begin
  State.Init(L);
  Item := State.ToObject(1) as TItem;
  State.Push( Item.CanMod( State.ToChar(2) ));
  Result := 1;
end;

function lua_item_get_mod(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    Item  : TItem;
begin
  State.Init(L);
  Item := State.ToObject(1) as TItem;
  State.Push( Item.FMods[ Ord(State.ToChar(2))]);
  Result := 1;
end;

function lua_item_clear_mods(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    Item  : TItem;
    Cnt   : Byte;
begin
  State.Init(L);
  Item := State.ToObject(1) as TItem;
  for Cnt := Ord('A') to Ord('Z') do
    Item.FMods[Cnt] := 0;
  Result := 0;
end;

const lua_item_lib : array[0..5] of luaL_Reg = (
      ( name : 'new';        func : @lua_item_new),
      ( name : 'add_mod';    func : @lua_item_add_mod),
      ( name : 'can_mod';    func : @lua_item_can_mod),
      ( name : 'get_mod';    func : @lua_item_get_mod),
      ( name : 'clear_mods'; func : @lua_item_clear_mods),
      ( name : nil;          func : nil; )
);

class procedure TItem.RegisterLuaAPI();
begin
  LuaSystem.Register( 'item', lua_item_lib );
end;

end.
