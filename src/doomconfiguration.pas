{$INCLUDE doomrl.inc}
unit doomconfiguration;
interface
uses vconfiguration, vlua;

type TDoomConfiguration = class( TConfigurationManager )
  constructor Create( aState : PLua_State = nil );
end;

implementation

uses vioevent;

constructor TDoomConfiguration.Create( aState : PLua_State = nil );
var iGroup : TConfigurationGroup;
begin
  inherited Create;

  iGroup := AddGroup( 'meta' );
  iGroup.AddInteger( 'config_version', 0 );

  iGroup := AddGroup( 'general' );
  iGroup.AddToggle( 'first_run', True );
  iGroup.AddToggle( 'always_random_name', False )
    .SetName('Always random name')
    .SetDescription( 'Setting to Enabled will skip name entry and always supply a random name.')
    ;
  iGroup.AddToggle( 'skip_intro', False )
    .SetName('Skip intro')
    .SetDescription('Setting to Enabled will skip the plot intro text before playing.')
    ;
  iGroup.AddToggle( 'hide_hints', False )
    .SetName('Hide hints')
    .SetDescription('Setting to Enabled will hide the hints in the top right corner.')
    ;
  iGroup.AddToggle( 'no_flashing', False )
    .SetName('Disable screen flashing')
    .SetDescription('Setting to Enabled will disable screen flash FX.')
    ;
  iGroup.AddToggle( 'empty_confirm', False )
    .SetName('Setting to Enabled will make the game wait for confirmation if trying to fire an empty weapon')
    ;
  iGroup.AddToggle( 'run_over_items', False )
    .SetName('Run over items')
    .SetDescription('Setting to Enabled will make the run command not stop on items.')
    ;
  iGroup.AddInteger( 'run_delay', 20 )
    .SetRange( 0, 200, 5 )
    .SetName('Run delay')
    .SetDescription('Setting to Enabled will make the run command not stop on items.')
    ;
  iGroup.AddToggle( 'unlock_all', False )
    .SetName('Unlock all unlocks')
    .SetDescription('For returning players so they don''t have to unlock everything again. Otherwise a cheat!')
    ;

  iGroup := AddGroup( 'display' );
  iGroup.AddInteger( 'display_mode', -1 );
  iGroup.AddInteger( 'screen_width', 0 );
  iGroup.AddInteger( 'screen_height', 0 );

  iGroup.AddToggle( 'fullscreen', True )
    .SetName('Fullscreen')
    .SetDescription('Set to Disabled to make the game launch in windowed mode.')
    ;

  iGroup.AddInteger( 'font_multiplier', 0 )
    .SetRange(0,3)
    .SetName('Font size multiplier')
    .SetDescription('Control font size multiplier. Set to 0 to pick one based on resolution.')
    ;

  iGroup.AddInteger( 'tile_multiplier', 0 )
    .SetRange(0,3)
    .SetName('Tile size multiplier')
    .SetDescription('Control tile size multiplier. Set to 0 to pick one based on resolution.')
    ;

  iGroup.AddInteger( 'minimap_multiplier', 0 )
    .SetRange(0,3)
    .SetName('Minimap size multiplier')
    .SetDescription('Control minimap size multiplier. Set to 0 to pick one based on resolution.')
    ;

  iGroup := AddGroup( 'audio' );
  iGroup.AddInteger( 'sound_volume', 100 )
    .SetRange(0,100,5)
    .SetName('Sound volume')
    .SetDescription('Control sound volume. Set to 0 to turn off sounds.')
    ;
  iGroup.AddInteger( 'music_volume', 100 )
    .SetRange(0,100,5)
    .SetName('Music volume')
    .SetDescription('Control music volume. Set to 0 to turn off music.')
    ;
  iGroup.AddToggle( 'menu_sound', True )
    .SetName('Menu sounds')
    .SetDescription('Set to Disabled to disable the chunky menu sounds.')
    ;

  iGroup := AddGroup( 'keybindings_hidden' );
  iGroup.AddInteger( 'input_escape', VKEY_ESCAPE );
  iGroup.AddInteger( 'input_ok', VKEY_ENTER );

  iGroup := AddGroup( 'keybindings_movement' );
  iGroup.AddInteger( 'input_walkleft', VKEY_LEFT )
    .SetName('Walk left')
    .SetDescription('Keybind to walk left.')
    ;
  iGroup.AddInteger( 'input_walkright', VKEY_RIGHT )
    .SetName('Walk right')
    .SetDescription('Keybind to walk roght.')
    ;
  iGroup.AddInteger( 'input_walkup', VKEY_UP )
    .SetName('Walk up')
    .SetDescription('Keybind to walk up.')
    ;
  iGroup.AddInteger( 'input_walkdown', VKEY_DOWN )
    .SetName('Walk up')
    .SetDescription('Keybind to walk down.')
    ;
  iGroup.AddInteger( 'input_walkupleft', VKEY_HOME )
    .SetName('Walk up-left')
    .SetDescription('Keybind to walk up and left.')
    ;
  iGroup.AddInteger( 'input_walkupright', VKEY_PGUP )
    .SetName('Walk up-right')
    .SetDescription('Keybind to walk up and right.')
    ;
  iGroup.AddInteger( 'input_walkdownleft', VKEY_END )
    .SetName('Walk down-left')
    .SetDescription('Keybind to walk down and left.')
    ;
  iGroup.AddInteger( 'input_walkdownright', VKEY_PGDOWN )
    .SetName('Walk down-right')
    .SetDescription('Keybind to walk down and right.')
    ;
  iGroup.AddInteger( 'input_wait', VKEY_PERIOD )
    .SetName('Wait a turn')
    .SetDescription('Keybind to wait in place.')
    ;
  iGroup.AddInteger( 'input_run', VKEY_COMMA )
    .SetName('Repeat move mode')
    .SetDescription('Enter repeat move mode (move until enemy appears or stopped).')
    ;

  iGroup := AddGroup( 'keybindings_actions' );
  iGroup.AddInteger( 'input_action', VKEY_SPACE )
    .SetName('Action')
    .SetDescription('Perform action (open/close door, descend stairs, press button).')
    ;
  iGroup.AddInteger( 'input_fire', VKEY_F )
    .SetName('Fire')
    .SetDescription('Fire your currently wielded weapon.')
    ;
  iGroup.AddInteger( 'input_reload', VKEY_R )
    .SetName('Reload')
    .SetDescription('Reload currently held weapon.')
    ;
  iGroup.AddInteger( 'input_pickup', VKEY_G )
    .SetName('Pickup')
    .SetDescription('Pickup item from ground.')
    ;
  iGroup.AddInteger( 'input_lookmode', VKEY_L )
    .SetName('Look mode')
    .SetDescription('Look around.')
    ;
  iGroup.AddInteger( 'input_swapweapon', VKEY_Z )
    .SetName('Swap weapon')
    .SetDescription('Swap your current and prepared weapon.')
    ;
  iGroup.AddInteger( 'input_tab', VKEY_TAB )
    .SetName('Change tactic')
    .SetDescription('Change tactic to running (if not tired).')
    ;
  iGroup.AddInteger( 'input_unload', VKEY_U )
    .SetName('Unload weapon')
    .SetDescription('Unload weapon from ground (if present) or inventory.')
    ;
  // TODO: SHIFT ENCODING!
  iGroup.AddInteger( 'input_altpickup', VKEY_G + 1000 )
    .SetName('Alternative pickup')
    .SetDescription('Use item from ground if possible.')
    ;
  iGroup.AddInteger( 'input_altfire', VKEY_F + 1000 )
    .SetName('Alternative fire')
    .SetDescription('Use weapons alternative fire mode (if present).')
    ;
  iGroup.AddInteger( 'input_altreload', VKEY_R + 1000 )
    .SetName('Alternative reload')
    .SetDescription('Use weapons alternative reload (if present).')
    ;

  iGroup := AddGroup( 'keybindings_ui' );
  iGroup.AddInteger( 'input_help', VKEY_H )
    .SetName('Show help screen')
    .SetDescription('Open up help screen.')
    ;
  iGroup.AddInteger( 'input_inventory', VKEY_I )
    .SetName('Show inventory screen')
    .SetDescription('Open up inventory screen.')
    ;
  iGroup.AddInteger( 'input_equipment', VKEY_E )
    .SetName('Show equipment screen')
    .SetDescription('Open up equipment screen.')
    ;
  iGroup.AddInteger( 'input_traits', VKEY_T )
    .SetName('Show traits screen')
    .SetDescription('Open up traits screen.')
    ;
  iGroup.AddInteger( 'input_playerinfo', VKEY_P )
    .SetName('Show player screen')
    .SetDescription('Open up player info screen.')
    ;
  iGroup.AddInteger( 'input_messages', VKEY_S )
    .SetName('Show messages screen')
    .SetDescription('Show log of previous messages.')
    ;
  iGroup.AddInteger( 'input_assemblies', VKEY_A )
    .SetName('Show assemblies screen')
    .SetDescription('Open up known assemblies screen.')
    ;
  iGroup.AddInteger( 'input_more', VKEY_M )
    .SetName('More info on target')
    .SetDescription('Open up target information screen.')
    ;
  iGroup.AddInteger( 'input_drop', VKEY_BACK )
    .SetName('Drop item')
    .SetDescription('Drop item while in inventory.')
    ;
  iGroup := AddGroup( 'keybindings_helper' );
  iGroup.AddInteger( 'input_quickkey_1', VKEY_1 )
    .SetName('Quickkey 1')
    .SetDescription('Mark and use quickslot 1.')
    ;
  iGroup.AddInteger( 'input_quickkey_2', VKEY_2 )
    .SetName('Quickkey 2')
    .SetDescription('Mark and use quickslot 2.')
    ;
  iGroup.AddInteger( 'input_quickkey_3', VKEY_3 )
    .SetName('Quickkey 3')
    .SetDescription('Mark and use quickslot 3.')
    ;
  iGroup.AddInteger( 'input_quickkey_4', VKEY_4 )
    .SetName('Quickkey 4')
    .SetDescription('Mark and use quickslot 4.')
    ;
  iGroup.AddInteger( 'input_quickkey_5', VKEY_5 )
    .SetName('Quickkey 5')
    .SetDescription('Mark and use quickslot 5.')
    ;
  iGroup.AddInteger( 'input_quickkey_6', VKEY_6 )
    .SetName('Quickkey 6')
    .SetDescription('Mark and use quickslot 6.')
    ;
  iGroup.AddInteger( 'input_quickkey_7', VKEY_7 )
    .SetName('Quickkey 7')
    .SetDescription('Mark and use quickslot 7.')
    ;
  iGroup.AddInteger( 'input_quickkey_8', VKEY_8 )
    .SetName('Quickkey 8')
    .SetDescription('Mark and use quickslot 8.')
    ;
  iGroup.AddInteger( 'input_quickkey_9', VKEY_9 )
    .SetName('Quickkey 9')
    .SetDescription('Mark and use quickslot 9.')
    ;
  iGroup.AddInteger( 'input_soundtoggle', 0 )
    .SetName('Sound toggle')
    .SetDescription('Quickly toggle sound on and off.')
    ;
  iGroup.AddInteger( 'input_musictoggle', 0 )
    .SetName('Music toggle')
    .SetDescription('Quickly toggle music on and off.')
    ;
  iGroup.AddInteger( 'input_togglegrid', 0 )
    .SetName('Toggle grid visibility')
    .SetDescription('Toggle visibility of helper grid overlay.')
    ;
  iGroup.AddInteger( 'input_examinenpc', 0 )
    .SetName('Examine NPCs')
    .SetDescription('(blind mode) List in message box all visible NPCs.')
    ;
  iGroup.AddInteger( 'input_examineitem', 0 )
    .SetName('Examine Items')
    .SetDescription('(blind mode) List in message box all visible Items.')
    ;


end;

end.

