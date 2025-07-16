{$INCLUDE doomrl.inc}
unit doomconfiguration;
interface
uses vconfiguration;

type TDoomConfiguration = class( TConfigurationManager )
  constructor Create;
end;

var Configuration : TDoomConfiguration;

implementation

uses vioevent, doomkeybindings;

constructor TDoomConfiguration.Create;
var iGroup : TConfigurationGroup;
    iInput : TInputKey;
    iID    : Ansistring;
const CInputGroups : array[1..7] of Ansistring = (
  'keybindings_movement',
  'keybindings_actions',
  'keybindings_ui',
  'keybindings_running',
  'keybindings_target',
  'keybindings_helper',
  'keybindings_legacy'
);
begin
  inherited Create;

  iGroup := AddGroup( 'meta' );
  iGroup.AddInteger( 'config_version', 0 );

  iGroup := AddGroup( 'general' );
  iGroup.AddToggle( 'first_run', True );
  iGroup.AddToggle( 'skip_intro', False )
    .SetName('Skip intro')
    .SetDescription('Setting to {!Enabled} will skip the plot intro text before playing.')
    ;

  iGroup := AddGroup( 'display' );
  iGroup.AddInteger( 'display_mode', 0 );
  iGroup.AddInteger( 'screen_width', 0 );
  iGroup.AddInteger( 'screen_height', 0 );

  iGroup.AddToggle( 'fullscreen', True )
    .SetName('Fullscreen')
    .SetDescription('Set to {!Disabled} to make the game launch in windowed mode.')
    ;

  iGroup.AddInteger( 'font_multiplier', 0 )
    .SetRange(0,3)
    .SetName('Font size multiplier')
    .SetDescription('Control font size multiplier. Set to {!0} to pick one based on resolution.')
    ;

  iGroup.AddInteger( 'tile_multiplier', 0 )
    .SetRange(0,3)
    .SetName('Tile size multiplier')
    .SetDescription('Control tile size multiplier. Set to {!0} to pick one based on resolution.')
    ;

  iGroup.AddInteger( 'minimap_multiplier', 0 )
    .SetRange(0,9)
    .SetName('Minimap size multiplier')
    .SetDescription('Control minimap size multiplier. Set to {!0} to pick one based on resolution.')
    ;
  iGroup.AddInteger( 'minimap_opacity', 2 )
    .SetRange(0,5)
    .SetName('Minimap opacity')
    .SetDescription('Control minimap opacity. Set to {!0} to disable minimap.')
    ;
  iGroup.AddToggle( 'screen_shake', True )
    .SetName('Screen shake effect')
    .SetDescription('Setting to {!Disabled} will disable screen shake FX.')
    ;
  iGroup.AddToggle( 'flashing_fx', True )
    .SetName('Screen flashing')
    .SetDescription('Setting to {!Disabled} will disable screen flash FX.')
    ;
  iGroup.AddToggle( 'glow_fx', True )
    .SetName('Emissive glow')
    .SetDescription('Setting to {!Disabled} will disable glow FX and improve performance.')
    ;

  iGroup := AddGroup( 'audio' );
  iGroup.AddInteger( 'sound_volume', 25 )
    .SetRange(0,25)
    .SetName('Sound volume')
    .SetDescription('Control sound volume. Set to {!0} to turn off sounds.')
    ;
  iGroup.AddInteger( 'music_volume', 10 )
    .SetRange(0,25)
    .SetName('Music volume')
    .SetDescription('Control music volume. Set to {!0} to turn off music.')
    ;
  iGroup.AddToggle( 'menu_sound', True )
    .SetName('Menu sounds')
    .SetDescription('Set to {!Disabled} to disable the chunky menu sounds.')
    ;

  iGroup := AddGroup( 'gameplay' );
  iGroup.AddToggle( 'always_random_name', False )
    .SetName('Always random name')
    .SetDescription( 'Setting to {!Enabled} will skip name entry and always supply a random name.')
    ;
  iGroup.AddToggle( 'hide_hints', False )
    .SetName('Hide hints')
    .SetDescription('Setting to {!Enabled} will hide the hints in the top right corner.')
    ;
  iGroup.AddToggle( 'run_over_items', False )
    .SetName('Run over items')
    .SetDescription('Setting to {!Enabled} will make the run command not stop on items.')
    ;
  iGroup.AddToggle( 'unlock_all', False )
    .SetName('Unlock all unlocks')
    .SetDescription('For returning players so they don''t have to unlock everything again. Otherwise a cheat!')
    ;

  iGroup := AddGroup( 'input' );
  iGroup.AddToggle( 'empty_confirm', False )
    .SetName('Confirm firing empty weapon')
    .SetDescription('Setting to {!Enabled} will make the game wait for confirmation if trying to fire an empty weapon')
    ;
  iGroup.AddToggle( 'enable_mouse', True )
    .SetName('Mouse control')
    .SetDescription('Setting to {!Disabled} will turn off interaction and visuals of the mouse.')
    ;
  iGroup.AddToggle( 'mouse_edge_pan', False )
    .SetName('Screen edge mouse scroll')
    .SetDescription('Setting to {!Enabled} will make the screen scroll if the mouse is at the edge.')
    ;
  iGroup.AddToggle( 'enable_gamepad', True )
    .SetName('Gamepad control')
    .SetDescription('Setting to {!Disabled} will turn off interaction and visuals of the gamepad.')
    ;
  iGroup.AddToggle( 'enable_rumble', True )
    .SetName('Gamepad rumble')
    .SetDescription('Setting to {!Disabled} will turn off gamepad rumble effects.')
    ;

  iGroup := AddGroup( 'keybindings_hidden' );
  iGroup.AddInteger( 'input_escape', VKEY_ESCAPE );
  iGroup.AddInteger( 'input_ok', VKEY_ENTER );

  for iID in CInputGroups do
  begin
    iGroup := AddGroup( iID );
    for iInput in TInputKey do
      if KeyInfo[ iInput ].Group = iID then
        iGroup.AddInteger( KeyInfo[ iInput ].ID, KeyInfo[ iInput ].Default )
          .SetName(KeyInfo[ iInput ].Name)
          .SetDescription(KeyInfo[ iInput ].Description)
          ;
  end;
end;

end.

