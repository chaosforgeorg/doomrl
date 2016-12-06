{$INCLUDE doomrl.inc}
unit doomhooks;
interface
uses vutil, dfdata;

const
  Hook_OnCreate        = 0;   // Being and Item -> Level, Module, Challenge, Core (Chained)
  Hook_OnAction        = 1;   // Being
  Hook_OnAttacked      = 2;   // Being
  Hook_OnDie           = 3;   // Being, Level, Module, Challenge, Core (Chained)
  Hook_OnDieCheck      = 4;   // Being, Level, Module, Challenge, Core (Chained)
  Hook_OnPickupItem    = 5;   // Being, Level, Module, Challenge, Core (Chained)
  Hook_OnPickup        = 6;   // Item, Level, Module, Challenge, Core (Chained)
  Hook_OnPickupCheck   = 7;   // Item, Level, Module, Challenge, Core (Chained)
  Hook_OnFirstPickup   = 8;   // Item
  Hook_OnUse           = 9;   // Item, Level, Module, Challenge, Core (Chained)
  Hook_OnUseCheck      = 10;  // Item, Level, Module, Challenge, Core (Chained)
  Hook_OnAltFire       = 11;  // Item
  Hook_OnAltReload     = 12;  // Item
  Hook_OnEquip         = 13;  // Item
  Hook_OnRemove        = 14;  // Item
  Hook_OnKill          = 15;  // Item (separate), Level, Module, Challenge, Core (Chained)
  Hook_OnKillAll       = 16;  // Level, Module, Challenge, Core (Chained)
  Hook_OnHitBeing      = 17;  // Item
  Hook_OnReload        = 18;  // Item
  Hook_OnEquipTick     = 19;  // Item
  Hook_OnEquipCheck    = 20;  // Item
  Hook_OnEnter         = 21;  // Item (separate),  Level, Module, Challenge, Core (chained)
  Hook_OnFire          = 22;  // Item, Level, Module, Challenge, Core (Chained)
  Hook_OnFired         = 23;  // Item, Level, Module, Challenge, Core (Chained)
  Hook_OnExit          = 24;  // Level, Module, Challenge, Core (Chained)
  Hook_OnTick          = 25;  // Level, Module, Challenge, Core (Chained)
  Hook_OnCompletedCheck= 26;  // Level, Module, Challenge, Core (Chained)
  Hook_OnNuked         = 27;  // Level, Module, Challenge, Core (Chained)
  Hook_OnLoad          = 28;  // Module, Challenge, Core (Chained)
  Hook_OnLoaded        = 29;  // Module, Challenge, Core (Chained)
  Hook_OnUnLoad        = 30;  // Module, Challenge, Core (Chained)
  Hook_OnCreatePlayer  = 31;  // Module, Challenge, Core (Chained)
  Hook_OnLevelUp       = 32;  // Module, Challenge, Core (Chained)
  Hook_OnPreLevelUp    = 33;  // Module, Challenge, Core (Chained)
  Hook_OnWinGame       = 34;  // Module, Challenge, Core (Chained)
  Hook_OnMortem        = 35;  // Module, Challenge, Core (Chained)
  Hook_OnMortemPrint   = 36;  // Module, Challenge, Core (Chained)
  Hook_OnCreateEpisode = 37;  // Module, Challenge, Core (Chained)
  Hook_OnLoadBase      = 38;  // Module, Challenge, Core (Chained)
  Hook_OnIntro         = 39;  // Module, Challenge, Core (Chained)
  Hook_OnGenerate      = 40;  // Module, Challenge, Core (Chained)
  HookAmount           = 41;

const AllHooks      : TFlags = [ 0..HookAmount-1 ];

var   BeingHooks    : TFlags;
      ItemHooks     : TFlags;
      ChainedHooks  : TFlags;
      LevelHooks    : TFlags;
      GlobalHooks   : TFlags;
var   GameTypeHooks : array[ TDoomGameType ] of TFlags;


const HookNames : array[ 0..HookAmount-1 ] of AnsiString = (
      'OnCreate', 'OnAction', 'OnAttacked', 'OnDie', 'OnDieCheck',
      'OnPickupItem', 'OnPickup','OnPickupCheck','OnFirstPickup','OnUse','OnUseCheck',
      'OnAltFire', 'OnAltReload', 'OnEquip', 'OnRemove', 'OnKill', 'OnKillAll',
      'OnHitBeing', 'OnReload', 'OnEquipTick', 'OnEquipCheck', 'OnEnter',
      'OnFire', 'OnFired', 'OnExit', 'OnTick', 'OnCompletedCheck', 'OnNuked',
      'OnLoad','OnLoaded','OnUnLoad', 'OnCreatePlayer', 'OnLevelUp','OnPreLevelUp',
      'OnWinGame', 'OnMortem', 'OnMortemPrint', 'OnCreateEpisode', 'OnLoadBase', 'OnIntro', 'OnGenerate'
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
BeingHooks   := [ Hook_OnCreate, Hook_OnAction, Hook_OnAttacked, Hook_OnDie, Hook_OnDieCheck, Hook_OnPickUpItem ];
ItemHooks    := [ Hook_OnCreate, Hook_OnPickup, Hook_OnPickupCheck, Hook_OnFirstPickup,
  Hook_OnUse, Hook_OnUseCheck, Hook_OnAltFire, Hook_OnAltReload, Hook_OnEquip,
  Hook_OnRemove, Hook_OnKill, Hook_OnKillAll, Hook_OnHitBeing, Hook_OnReload,
  Hook_OnEquipTick, Hook_OnEquipCheck, Hook_OnEnter, Hook_OnFire, Hook_OnFired ];
ChainedHooks := [ Hook_OnCreate, Hook_OnDie, Hook_OnDieCheck, Hook_OnPickup, Hook_OnPickUpItem, Hook_OnKillAll,
  Hook_OnPickupCheck, Hook_OnUse, Hook_OnUseCheck,
  Hook_OnFire, Hook_OnFired ];
LevelHooks   := ChainedHooks + [ Hook_OnEnter, Hook_OnKill, Hook_OnExit, Hook_OnTick, Hook_OnCompletedCheck, Hook_OnNuked ];
GlobalHooks  := LevelHooks + [ Hook_OnEnter, Hook_OnKill, Hook_OnExit, Hook_OnTick, Hook_OnLoad, Hook_OnLoaded, Hook_OnUnLoad, Hook_OnCreatePlayer, Hook_OnLevelUp,
  Hook_OnPreLevelUp, Hook_OnWinGame, Hook_OnMortem, Hook_OnMortemPrint, Hook_OnCreateEpisode, Hook_OnLoadBase,
  Hook_OnIntro, Hook_OnGenerate ];

GameTypeHooks[ GameStandard ] := GlobalHooks;
GameTypeHooks[ GameTotal ]    := GlobalHooks;
GameTypeHooks[ GameEpisode ]  := GlobalHooks - [Hook_OnLoadBase];
GameTypeHooks[ GameSingle ]   := GlobalHooks - [Hook_OnCreateEpisode,Hook_OnLoadBase];

end.

