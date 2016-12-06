{$INCLUDE doomrl.inc}
{
----------------------------------------------------
DFDATA.PAS -- Data for Downfall
Copyright (c) 2002 by Kornel "Anubis" Kisielewicz
----------------------------------------------------
}
unit dfdata;
interface
uses Classes, SysUtils, idea, DOM, vgenerics, vcolor, vutil, vrltools,
     doomconfig, vuitypes;

const ConfigurationPath : AnsiString = '';
      DataPath          : AnsiString = '';
      SaveFilePath      : AnsiString = '';

{$INCLUDE version.inc}

var   MemorialWritten : Boolean;

const PlayerSafeZone = 6;

type
  TIntHashMap  = specialize TGHashMap<Integer>;

type
  // Error reporting.
  EZlibError          = class(EStreamError);
  EDunGenException    = class(EException);
  EItemException      = class(EException);

type
  TUIHOFCallback = function ( aFilter : char; out aFilterName : AnsiString ) : TUIStringArray of object;
  TUIHOFReport   = record
    Title    : TUIString;
    Footer   : TUIString;
    Filters  : TUIString;
    Callback : TUIHOFCallback;
  end;

  TUIPageArray   = specialize TGObjectArray< TUIStringArray >;
  TUIPagedReport = record
    Pages   : TUIPageArray;
    Titles  : TUIStringArray;
    Headers : TUIStringArray;
    Title   : TUIString;
  end;

  THOFRank = record
    ExpRank   : DWord;
    SkillRank : DWord;
  end;

const
  DEBUG           : Boolean = False;
  WADMAKE         : Boolean = False;
  CRASHMODE       : Boolean = False;
  EXCEPTEMMITED   : Boolean = False;
  GraphicsVersion : Boolean = True;
  SoundVersion    : Boolean = True;
  ForceNoNet      : Boolean = False;
  ForceNoAudio    : Boolean = False;
  ForceConsole    : Boolean = False;
  ForceGraphics   : Boolean = False;
  ForceFullscreen : Boolean = False;
  VisionBaseValue : Byte = 8;

  ThisSeed       : Cardinal = 0;

  NoPlayerRecord : Boolean = False;
  NoScoreRecord  : Boolean = False;

  ConfigFile   : string  = 'config.lua';

  GodMode      : Boolean = False;

  GameRealTime    : Comp = 0;
  ProgramRealTime : Comp = 0;

  Config       : TDoomConfig = nil;


type
    TDoomGameType   = ( GameStandard, GameSingle, GameEpisode, GameTotal );
    TItemType       = ( ItemType_None, ItemType_Ranged, ItemType_NRanged, ItemType_Armor, ItemType_Melee, ItemType_Ammo, ItemType_Pack, ItemType_Power, ItemType_Boots, ItemType_Tele, ItemType_Lever, ItemType_AmmoPack );
    TBodyTarget     = ( Target_Internal, Target_Torso, Target_Feet );
    TEqSlot         = ( efTorso, efWeapon, efBoots, efWeapon2 );
    TStatusEffect   = ( StatusNormal, StatusInvert, StatusRed, StatusGreen, StatusBlue, StatusCyan, StatusMagenta, StatusYellow, StatusGray, StatusWhite );
    TDamageType     = ( Damage_Bullet, Damage_Melee, Damage_Sharpnel, Damage_Acid, Damage_Fire, Damage_Plasma, Damage_SPlasma, Damage_IgnoreArmor );
    TAltFire        = ( ALT_NONE, ALT_CHAIN, ALT_THROW, ALT_SCRIPT, ALT_AIMED, ALT_SINGLE );
    TAltReload      = ( RELOAD_NONE, RELOAD_SCRIPT, RELOAD_FULL, RELOAD_DUAL, RELOAD_SINGLE );
    TExplosionFlag  = ( efSelfHalf, efSelfKnockback, efSelfSafe, efAfterBlink, efChain, efHalfKnock, efNoKnock, efRandomContent, efNoDistanceDrop );
    TResistance     = ( Resist_Bullet, Resist_Melee, Resist_Shrapnel, Resist_Acid, Resist_Fire, Resist_Plasma );


const
{$include ../bin/core/constants.lua}
{$include ../bin/dkey.inc}

const
  COMMAND_MMOVE    = 240;
  COMMAND_MRIGHT   = 241;
  COMMAND_MMIDDLE  = 242;
  COMMAND_MLEFT    = 243;
  COMMAND_MSCRUP   = 244;
  COMMAND_MSCRDOWN = 245;
  COMMAND_YIELD    = 254;

  KnockbackValue = 7;


const
  Option_HighASCII        : Boolean = {$IFDEF WINDOWS}True{$ELSE}False{$ENDIF};
  Option_AlwaysRandomName : Boolean = False;
  Option_NoIntro          : Boolean = False;
  Option_NoFlash          : Boolean = False;
  Option_NoBloodSlide     : Boolean = False;
  Option_RunOverItems     : Boolean = False;
  Option_Music            : Boolean = False;
  Option_Sound            : Boolean = False;
  Option_MenuSound        : Boolean = False;
  Option_BlindMode        : Boolean = False;
  Option_ClearMessages    : Boolean = False;
  Option_MorePrompt       : Boolean = True;
  Option_MessageColoring  : Boolean = False;
  Option_InvFullDrop      : Boolean = False;
  Option_MortemArchive    : Boolean = False;
  Option_MenuReturn       : Boolean = False;
  Option_ColorBlindMode   : Boolean = False;
  Option_EmptyConfirm     : Boolean = False;
  Option_SoundEquipPickup : Boolean = False;
  Option_ColoredInventory : Boolean = True;
  Option_LockBreak        : Boolean = True;
  Option_LockClose        : Boolean = True;
  Option_Hints            : Boolean = True;
  Option_RunDelay         : Byte = 0;
  Option_MessageBuffer    : DWord = 100;
  Option_MaxRun           : DWord = 100;
  Option_MaxWait          : DWord = 20;
  Option_Graphics         : string = 'TILES';
  Option_Blending         : Boolean = False;
  Option_SaveOnCrash      : Boolean = True;
  Option_SoundEngine      : string = 'DEFAULT';
  Option_AlwaysName       : string = '';
  Option_TimeStamp        : string = 'yyyy/mm/dd hh:nn:ss';
  Option_MusicVol         : Byte = 25;
  Option_SoundVol         : Byte = 25;
  Option_SDLMixerFreq     : Integer = 22050;
  Option_SDLMixerFormat   : Word = $8010;
  Option_SDLMixerChunkSize: Integer = 1024;
  Option_PlayerBackups    : DWord = 7;
  Option_ScoreBackups     : DWord = 7;
  Option_IntuitionColor   : Byte = LIGHTGRAY;
  Option_IntuitionChar    : Char = '.';
  Option_NetworkConnection: Boolean = True;
  Option_VersionCheck     : Boolean = True;
  Option_AlertCheck       : Boolean = True;
  Option_BetaCheck        : Boolean = False;
  Option_InvMenuStyle     : AnsiString = 'HYBRID';
  Option_EqMenuStyle      : AnsiString = 'HYBRID';
  Option_HelpMenuStyle    : AnsiString = 'HYBRID';
  Option_CustomModServer  : AnsiString = '';


var
  SoundOff  : boolean = False;
  MusicOff  : boolean = False;

  // 0-25 range

const
{$include ../bin/core/commands.lua}
  COMMANDS_MOVE        = [COMMAND_WALKNORTH,COMMAND_WALKSOUTH,
                          COMMAND_WALKEAST,COMMAND_WALKWEST,
                          COMMAND_WALKNE,COMMAND_WALKSE,
                          COMMAND_WALKNW,COMMAND_WALKSW];

type TCellSet = set of Byte;
     TExplosionFlags = set of TExplosionFlag;
     TSprite = record
       Large    : Boolean;
       Overlay  : Boolean;
       CosColor : Boolean;
       Glow     : Boolean;
       Color    : TColor;
       GlowColor: TColor;
       SpriteID : Word;
     end;

function NewSprite( ID : Word ) : TSprite;
function NewSprite( ID : Word; Color : TColor ) : TSprite;

const
  ActionCostPickUp = 1000;
  ActionCostDrop   = 500;
  ActionCostAct    = 500;
  ActionCostReload = 1000;
  ActionCostWear   = 1000;
  ActionCostMove   = 1000;
  ActionCostFire   = 1000;

  ActSoundChance    = 30;

type
  TShotgunData = record
    Range      : Byte;
    MaxRange   : Byte;
    Spread     : Byte;
    Reduce     : Real;
    DamageType : TDamageType
  end;

  TMissileData = record
    SoundID    : string[20];
    Sprite     : TSprite;
    Picture    : Char;
    Color      : Byte;
    Delay      : Byte;
    MissBase   : Byte;
    MissDist   : Byte;
    ExplDelay  : Byte;
    ExplColor  : Byte;
    ExplFlags  : TExplosionFlags;
    RayDelay   : Byte;
    Range      : Byte;
    MaxRange   : Byte;
    Flags      : TFlags;
    Content    : Byte;
  end;

  TAffectData = record
    Name       : Ansistring;
    Color      : Byte;
    Color_exp  : Byte;
    Hooks      : set of (AffectHookOnAdd,AffectHookOnTick,AffectHookOnRemove);
    StatusEff  : TStatusEffect;
    StatusStr  : DWord;
  end;

var
  Missiles  : array of TMissileData;
  Shotguns  : array of TShotgunData;
  Affects   : array of TAffectData;

const

  StatusEffect  : TStatusEffect = StatusNormal;

const PACK_RELOAD = 100;



type TItemSlot = 1..MAX_INV_SIZE;
type TItemTypeSet = set of TItemType;

const ItemEqFilters : array[TEqSlot] of TItemTypeSet = (
                       [ItemType_Armor],
                       [ItemType_Melee,ItemType_Ranged,ItemType_NRanged],
                       [ItemType_Boots],
                       [ItemType_Melee,ItemType_Ranged,ItemType_AmmoPack]
                      );
const ItemsAll      : TItemTypeSet = [Low(TItemType)..High(TItemType)];

type TItemProperties = record
       case IType : TItemType of
         ItemType_Armor,ItemType_Boots : (
           Durability : Word;
           MaxDurability : Word;
           MoveMod  : Integer;
		   DodgeMod : Integer;
           KnockMod : Integer;
         );
         ItemType_Ammo,
         ItemType_Melee,
         ItemType_NRanged,
         ItemType_Ranged,
         ItemType_AmmoPack : (
           AmmoID      : Byte;
           Ammo        : Word;
           AmmoMax     : Word;
           Acc         : ShortInt;
           Damage      : TDiceRoll;
           Missile     : Byte;
           BlastRadius : Byte;
           Shots       : Byte;
           ShotCost    : Byte;
           ReloadTime  : Byte;
           UseTime     : Byte;
           DamageType  : TDamageType;
           AltFire     : TAltFire;
           AltReload   : TAltReload;
         );
     end;

const MaxPlayerLevel = 26;

type  TTactic = (tacticNormal,tacticRunning,tacticTired);
const TacticName : array[TTactic] of string =
                   ('cautious','running','tired');
      TacticColor: array[TTactic] of byte =
                   (lightgray,yellow,darkgray);

const ExpTable : array[1..MaxPlayerLevel] of LongInt =
              (     0,    500,   1500,
                 4000,   7000,  11000,
                16000,  22000,  30000,
                40000,  50000,  60000,
                70000,  80000, 100000,
               120000, 140000, 160000,
               200000, 300000, 400000,
               500000, 600000, 700000,
               900000,10000000);
               
function Roll(stat : Integer) : Integer;
function CommandDirection(Command : byte) : TDirection;
function DirectionToCommand(Dir : TDirection) : Byte;
function TwoInt(x : integer) : string;
function ToProperFilename(s : string) : string;
function toHitPercent(EffSkill : ShortInt) : string;
function BonusStr(i : integer) : string;
function UnitsToPercent(Value : Integer) : string;
function Percent(Value : Integer) : string;
function Seconds(Value : Integer) : string;
function ItemTypeSetFromFlags( const aFlags : TFlags ) : TItemTypeSet;
function ExplosionFlagsFromFlags( const aFlags : TFlags ) : TExplosionFlags;
function RotateTowards( aSource, aTarget1, aTarget2 : TCoord2D; aAmount : Real ) : TCoord2D;
function MSecNow : Comp;
function DurationString( aSeconds : int64 ) : Ansistring;
function BlindCoord( const where : TCoord2D ) : string;
function SlotName(slot : TEqSlot) : string;

var ColorOverrides : TIntHashMap;

Function GetPropValueFixed(Instance: TObject; const PropName: Ansistring; PreferStrings: Boolean = True): Variant;


implementation
uses typinfo, strutils, XMLRead, math, vdebug;

// change also in mortem lua!
function SlotName(slot : TEqSlot) : string;
begin
  case Slot of
//  efHead    : Exit('[ Head       ]');
    efTorso   : Exit('[ Armor      ]');
    efWeapon  : Exit('[ Weapon     ]');
    efBoots   : Exit('[ Boots      ]');
    efWeapon2 : Exit('[ Prepared   ]');
  end;
end;


function BlindCoord( const where : TCoord2D ) : string;
begin
  BlindCoord := '[';
  if where.y > 0 then BlindCoord += IntToStr(where.y)+'s';
  if where.y < 0 then BlindCoord += IntToStr(-where.y)+'n';
  if where.x > 0 then BlindCoord += IntToStr(where.x)+'e';
  if where.x < 0 then BlindCoord += IntToStr(-where.x)+'w';
  if (where.x = 0) and (where.y = 0) then BlindCoord += 'here';
  BlindCoord += ']';
end;

function GetPropValueFixed(Instance: TObject; const PropName: Ansistring;
  PreferStrings: Boolean): Variant;
begin
  GetPropValueFixed := GetPropValue(Instance, PropName, PreferStrings );
  if GetPropInfo(Instance, PropName)^.PropType^.Kind = tkBool then
    VarCast( GetPropValueFixed, GetPropValueFixed, varBoolean );
end;

function UnitsToPercent(Value : Integer) : string;
begin
  UnitsToPercent := IIf( Value >= 0, '+' ) + FloatToStrF(Value,ffFixed,0,2)+'%';
end;

function Percent(Value : Integer) : string;
begin
  Percent := IIf( Value >= 0, '+' ) + IntToStr(Value)+'%';
end;

function Seconds(Value : Integer) : string;
begin
  Seconds := FloatToStrF(Value/10.,ffFixed,0,1)+'s';
end;

function ItemTypeSetFromFlags( const aFlags: TFlags ): TItemTypeSet;
var iCount : TItemType;
begin
  ItemTypeSetFromFlags := [];
  for iCount in TItemTypeSet do
    if Byte( iCount ) in aFlags then Include( ItemTypeSetFromFlags, iCount );
end;

function ExplosionFlagsFromFlags( const aFlags: TFlags ): TExplosionFlags;
var iCount : TExplosionFlag;
begin
  ExplosionFlagsFromFlags := [];
  for iCount in TExplosionFlags  do
    if Byte( iCount ) in aFlags then Include( ExplosionFlagsFromFlags, iCount );
end;

function RotateTowards( aSource, aTarget1, aTarget2: TCoord2D; aAmount : Real ): TCoord2D;
var iVector1, iVector2 : TCoord2D;
    iCos, iSin, iAngle : Float;
    iAT1, iAT2         : Float;
    iSign              : ShortInt;
begin
  if aTarget1 = aTarget2 then Exit( aTarget2 );
  iVector1  := aTarget1 - aSource;
  iVector2  := aTarget2 - aSource;
  iAT1      := arctan2( iVector1.y, iVector1.x );
  iAT2      := arctan2( iVector2.y, iVector2.x );
  if iAT1 < 0 then iAT1 += 2*PI;
  if iAT2 < 0 then iAT2 += 2*PI;
  iAngle    := iAT2 - iAT1;
  iSign     := Sign( iAngle );
  if Floor( Abs( iAngle ) / aAmount ) < 1 then Exit( aTarget2 );
  if Abs( iAngle ) > PI then iSign := -iSign;

  iCos := cos( aAmount * iSign );
  iSin := sin( aAmount * iSign );
  
  RotateTowards.x := aSource.x + Round((iVector1.x * iCos) - (iVector1.y * iSin));
  RotateTowards.y := aSource.y + Round((iVector1.y * iCos) + (iVector1.x * iSin));
end;

function MSecNow: Comp;
begin
  Exit( TimeStampToMSecs( DateTimeToTimeStamp( Now ) ) );
end;

function DurationString( aSeconds : int64 ): Ansistring;
var iSec, iMin, iHour, iDay : DWord;
    iPos                    : Integer;
  function ValueString( aValue : DWord; const aName : String ) : String;
  begin
    if aValue = 0 then Exit('');
    Exit(IntToStr(aValue) + ' ' + aName + IIf( aValue > 1, 's' ) + ', ');
  end;
Begin
  if aSeconds <= 0 then Exit('0 seconds');
  iSec     := aSeconds mod 60;
  iMin     := (aSeconds div 60) mod 60;
  iHour    := (aSeconds div (60*60)) mod 24;
  iDay     := (aSeconds div (60*60*24));

  DurationString := ValueString( iDay, 'day' )
                  + ValueString( iHour, 'hour' )
                  + ValueString( iMin,  'minute' )
                  + ValueString( iSec,  'second' );

  RemoveTrailingChars( DurationString, [' ',','] );
  iPos := RPos( ',', DurationString );
  if iPos > 0 then
  begin
    Delete( DurationString, iPos, 1 );
    Insert( ' and', DurationString, iPos );
  end;
end;

function TwoInt(x : integer) : string;
begin
  if (x < 10) and (x > -1) then Exit(' '+IntToStr(x))
  else Exit(IntToStr(x));
end;



function CommandDirection(Command : byte) : TDirection;
begin
  case Command of
    COMMAND_WALKWEST  : CommandDirection.Create(4);
    COMMAND_WALKEAST  : CommandDirection.Create(6);
    COMMAND_WALKNORTH : CommandDirection.Create(8);
    COMMAND_WALKSOUTH : CommandDirection.Create(2);
    COMMAND_WALKNW    : CommandDirection.Create(7);
    COMMAND_WALKNE    : CommandDirection.Create(9);
    COMMAND_WALKSW    : CommandDirection.Create(1);
    COMMAND_WALKSE    : CommandDirection.Create(3);
    COMMAND_WAIT      : CommandDirection.Create(5);
    else CommandDirection.Create(0);
  end;
end;

function DirectionToCommand(Dir : TDirection) : Byte;
begin
  case Dir.code of
    4 : Exit( COMMAND_WALKWEST );
    6 : Exit( COMMAND_WALKEAST );
    8 : Exit( COMMAND_WALKNORTH);
    2 : Exit( COMMAND_WALKSOUTH);
    7 : Exit( COMMAND_WALKNW );
    9 : Exit( COMMAND_WALKNE );
    1 : Exit( COMMAND_WALKSW );
    3 : Exit( COMMAND_WALKSE );
    5 : Exit( COMMAND_WAIT );
    else Exit( COMMAND_WAIT );
  end;
end;

function NewSprite ( ID : Word ) : TSprite;
begin
  NewSprite.CosColor := False;
  NewSprite.Overlay  := False;
  NewSprite.Glow     := False;
  NewSprite.Large    := False;
  NewSprite.SpriteID := ID;
end;

function NewSprite ( ID : Word; Color : TColor ) : TSprite;
begin
  NewSprite.Overlay  := False;
  NewSprite.Glow     := False;
  NewSprite.Large    := False;
  NewSprite.CosColor := True;
  NewSprite.Color    := Color;
  NewSprite.SpriteID := ID;
end;

function Roll(stat : Integer) : Integer;
var DieRoll : byte;
begin
  DieRoll := Dice(3,6);
  case DieRoll of
      3 : Exit(30);
      4 : Exit(20);
     17 : Exit(-20);
     18 : Exit(-30);
  end;
  Roll := stat - DieRoll;
end;

{ TStringList }


function ToProperFilename(s : string) : string;
const good : set of char = ['a'..'z','0','1'..'9','A'..'Z','[',']',' ','-'];
var ch : char;
begin
  ToProperFilename := '';
  for ch in s do
    ToProperFilename += IIf( ch in good, ch, '-' );
end;

function toHitPercent(EffSkill: ShortInt): string;
begin
  if EffSkill <= 3  then Exit('1%');
  if EffSkill >= 16 then Exit('98%');
  case EffSkill of
    4 : Exit('2%');
    5 : Exit('5%');
    6 : Exit('9%');
    7 : Exit('16%');
    8 : Exit('26%');
    9 : Exit('38%');
   10 : Exit('50%');
   11 : Exit('62%');
   12 : Exit('74%');
   13 : Exit('84%');
   14 : Exit('91%');
   15 : Exit('95%');
  end;
end;

function BonusStr(i: integer): string;
begin
  if i < 0 then BonusStr := IntToStr(i)
           else BonusStr := '+'+IntToStr(i);
end;

end.
