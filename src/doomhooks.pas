{$INCLUDE doomrl.inc}
unit doomhooks;
interface
uses vutil, dfdata;

const
  Hook_OnCreate        = 0;   // Being and Item -> Level, Module, Challenge, Core (Chained)
  Hook_OnAction        = 1;   // Being
  Hook_OnAttacked      = 2;   // Trait, Being
  Hook_OnUseActive     = 3;   // Trait, Being
  Hook_OnDie           = 4;   // Trait, Being, Level, Module, Challenge, Core (Chained)
  Hook_OnDieCheck      = 5;   // Trait, Being, Level, Module, Challenge, Core (Chained)
  Hook_OnPickupItem    = 6;   // Trait, Being, Level, Module, Challenge, Core (Chained)
  Hook_OnPickup        = 7;   // Item, Level, Module, Challenge, Core (Chained)
  Hook_OnPickupCheck   = 8;   // Item, Level, Module, Challenge, Core (Chained)
  Hook_OnFirstPickup   = 9;   // Item
  Hook_OnUse           = 10;  // Item, Level, Module, Challenge, Core (Chained)
  Hook_OnUseCheck      = 11;  // Item, Level, Module, Challenge, Core (Chained)
  Hook_OnAltFire       = 12;  // Item
  Hook_OnAltReload     = 13;  // Item
  Hook_OnEquip         = 14;  // Item
  Hook_OnRemove        = 15;  // Item
  Hook_OnKill          = 16;  // Item (separate), Trait, Being (separate), Level, Module, Challenge, Core (Chained)
  Hook_OnKillAll       = 17;  // Level, Module, Challenge, Core (Chained)
  Hook_OnHitBeing      = 18;  // Item
  Hook_OnReload        = 19;  // Item
  Hook_OnEquipTick     = 20;  // Item
  Hook_OnEquipCheck    = 21;  // Item
  Hook_OnAct           = 22;  // Item
  Hook_OnDestroy       = 23;  // Item
  Hook_OnEnter         = 24;  // Item (separate)
  Hook_OnEnterLevel    = 25;  // Level, Module, Challenge, Core (chained)
  Hook_OnFire          = 26;  // Item, Level, Module, Challenge, Core (Chained)
  Hook_OnFired         = 27;  // Trait (separate), Item, Level, Module, Challenge, Core (Chained)
  Hook_OnExit          = 28;  // Level, Module, Challenge, Core (Chained)
  Hook_OnTick          = 29;  // Being (Separate), Level, Module, Challenge, Core (Chained)
  Hook_OnCompletedCheck= 30;  // Level, Module, Challenge, Core (Chained)
  Hook_OnNuked         = 31;  // Level, Module, Challenge, Core (Chained)
  Hook_OnLoad          = 32;  // Module, Challenge, Core (Chained)
  Hook_OnLoaded        = 33;  // Module, Challenge, Core (Chained)
  Hook_OnUnLoad        = 34;  // Module, Challenge, Core (Chained)
  Hook_OnCreatePlayer  = 35;  // Module, Challenge, Core (Chained)
  Hook_OnLevelUp       = 36;  // Module, Challenge, Core (Chained)
  Hook_OnPreLevelUp    = 37;  // Module, Challenge, Core (Chained)
  Hook_OnWinGame       = 38;  // Module, Challenge, Core (Chained)
  Hook_OnMortem        = 39;  // Module, Challenge, Core (Chained)
  Hook_OnMortemPrint   = 40;  // Module, Challenge, Core (Chained)
  Hook_OnCreateEpisode = 41;  // Module, Challenge, Core (Chained)
  Hook_OnIntro         = 42;  // Module, Challenge, Core (Chained)
  Hook_OnGenerate      = 43;  // Module, Challenge, Core (Chained)

  // TODO: merge with above
  Hook_OnPostMove      = 44;   // Trait, Being
  Hook_OnPreReload     = 45;   // Trait, Being
  Hook_OnDamage        = 46;   // Trait, Being, Item
  Hook_OnReceiveDamage = 47;   // Trait, Being
  Hook_OnPreAction     = 48;   // Trait, Being
  Hook_OnPostAction    = 49;   // Trait, Being
  Hook_OnCanDualWield  = 50;   // Trait

  Hook_OnDescribe      = 51; // Item

  Hook_getDamageBonus  = 52; // Trait, Being, Affects
  Hook_getToHitBonus   = 53; // Trait, Being, Affects
  Hook_getShotsBonus   = 54; // Trait, Being, Affects
  Hook_getFireCostBonus= 55; // Trait, Being, Affects
  Hook_getDefenceBonus = 56; // Trait, Being, Affects
  Hook_getDodgeBonus   = 57; // Trait, Being, Affects
  Hook_getMoveBonus    = 58; // Trait, Being, Affects
  Hook_getBodyBonus    = 59; // Trait, Being, Affects
  Hook_getResistBonus  = 60; // Trait, Being, Affects
  Hook_getDamageMul    = 61; // Trait, Being, Affects
  Hook_getFireCostMul  = 62; // Trait, Being, Affects
  Hook_getAmmoCostMul  = 63; // Trait, Being, Affects
  Hook_getReloadCostMul= 64; // Trait, Being, Affects

  HookAmount           = 65;

const AllHooks      : TFlags = [ 0..HookAmount-1 ];

var   BeingHooks    : TFlags;
      ItemHooks     : TFlags;
      ChainedHooks  : TFlags;
      LevelHooks    : TFlags;
      GlobalHooks   : TFlags;

const HookNames : array[ 0..HookAmount-1 ] of AnsiString = (
      'OnCreate', 'OnAction', 'OnAttacked', 'OnUseActive', 'OnDie', 'OnDieCheck',
      'OnPickupItem', 'OnPickup','OnPickupCheck','OnFirstPickup','OnUse','OnUseCheck',
      'OnAltFire', 'OnAltReload', 'OnEquip', 'OnRemove', 'OnKill', 'OnKillAll',
      'OnHitBeing', 'OnReload', 'OnEquipTick', 'OnEquipCheck', 'OnAct', 'OnDestroy', 'OnEnter', 'OnEnterLevel',
      'OnFire', 'OnFired', 'OnExit', 'OnTick', 'OnCompletedCheck', 'OnNuked',
      'OnLoad','OnLoaded','OnUnLoad', 'OnCreatePlayer', 'OnLevelUp','OnPreLevelUp',
      'OnWinGame', 'OnMortem', 'OnMortemPrint', 'OnCreateEpisode', 'OnIntro' , 'OnGenerate',

      'OnPostMove', 'OnPreReload', 'OnDamage', 'OnReceiveDamage', 'OnPreAction', 'OnPostAction', 'OnCanDualWield',
      'OnDescribe',
      'getDamageBonus', 'getToHitBonus', 'getShotsBonus', 'getFireCostBonus',
      'getDefenceBonus', 'getDodgeBonus', 'getMoveBonus', 'getBodyBonus', 'getResistBonus',
      'getDamageMul', 'getFireCostMul', 'getAmmoCostMul', 'getReloadCostMul'
      );

function LoadHooks( const Table : array of Const ) : TFlags;

implementation

uses vluasystem;

function LoadHooks ( const Table : array of Const ) : TFlags;
var Hook  : Byte;
begin
  with LuaSystem.GetTable( Table ) do
  try
    LoadHooks := [];
    for Hook in AllHooks do
      if isFunction(HookNames[Hook]) then
        Include(LoadHooks,Hook);
  finally
    Free;
  end;
end;

initialization

AllHooks     := [ 0..HookAmount-1 ];
BeingHooks   := [ Hook_OnCreate, Hook_OnAction, Hook_OnAttacked, Hook_OnUseActive,
  Hook_OnDie, Hook_OnDieCheck, Hook_OnPickUpItem, Hook_OnPostMove, Hook_OnKill,
  Hook_OnDamage, Hook_OnReceiveDamage, Hook_OnPreAction, Hook_OnEnterLevel,
  Hook_getDamageBonus, Hook_getToHitBonus, Hook_getShotsBonus, Hook_getFireCostBonus,
  Hook_getDefenceBonus, Hook_getDodgeBonus, Hook_getMoveBonus, Hook_getBodyBonus,
  Hook_getResistBonus, Hook_getDamageMul, Hook_getFireCostMul, Hook_getAmmoCostMul];
ItemHooks    := [ Hook_OnCreate, Hook_OnPickup, Hook_OnPickupCheck, Hook_OnFirstPickup,
  Hook_OnUse, Hook_OnUseCheck, Hook_OnAltFire, Hook_OnAltReload, Hook_OnEquip,
  Hook_OnRemove, Hook_OnKill, Hook_OnKillAll, Hook_OnHitBeing, Hook_OnReload,
  Hook_OnEquipTick, Hook_OnEquipCheck, Hook_OnEnter, Hook_OnFire, Hook_OnFired,
  Hook_OnAct, Hook_OnDestroy, Hook_OnPostMove, Hook_OnPreReload, Hook_OnDamage, Hook_OnDescribe ];
ChainedHooks := [ Hook_OnCreate, Hook_OnDie, Hook_OnDieCheck, Hook_OnPickup,
  Hook_OnPickUpItem, Hook_OnKillAll, Hook_OnPickupCheck, Hook_OnUse, Hook_OnUseCheck,
  Hook_OnFire, Hook_OnFired ];
LevelHooks   := ChainedHooks + [ Hook_OnEnterLevel, Hook_OnKill, Hook_OnExit, Hook_OnTick,
  Hook_OnCompletedCheck, Hook_OnNuked ];
GlobalHooks  := LevelHooks + [ Hook_OnEnterLevel, Hook_OnKill, Hook_OnExit, Hook_OnTick,
  Hook_OnLoad, Hook_OnLoaded, Hook_OnUnLoad, Hook_OnCreatePlayer, Hook_OnLevelUp,
  Hook_OnPreLevelUp, Hook_OnWinGame, Hook_OnMortem, Hook_OnMortemPrint, Hook_OnCreateEpisode,
  Hook_OnIntro, Hook_OnGenerate ];

end.

