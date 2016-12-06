COMMAND_WALKNORTH         = 2;
COMMAND_WALKSOUTH         = 3;
COMMAND_WALKEAST          = 4;
COMMAND_WALKWEST          = 5;
COMMAND_WALKNE            = 6;
COMMAND_WALKSE            = 7;
COMMAND_WALKNW            = 8;
COMMAND_WALKSW            = 9;
COMMAND_WAIT              = 10;
COMMAND_ESCAPE            = 11;
COMMAND_OK                = 12;
COMMAND_ENTER             = 13;
COMMAND_UNLOAD            = 14;
COMMAND_PICKUP            = 15;
COMMAND_DROP              = 16;
COMMAND_INVENTORY         = 17;
COMMAND_EQUIPMENT         = 18;
COMMAND_OPEN              = 19;
COMMAND_CLOSE             = 20;
COMMAND_LOOK              = 21;
COMMAND_ALTFIRE           = 23;
COMMAND_FIRE              = 24;
COMMAND_USE               = 25;
COMMAND_PLAYERINFO        = 26;
COMMAND_SAVE              = 27;
COMMAND_TACTIC            = 28;
COMMAND_RUNMODE           = 29;
COMMAND_MORE              = 31;
COMMAND_EXAMINENPC        = 32;
COMMAND_EXAMINEITEM       = 33;
COMMAND_SWAPWEAPON        = 34;
COMMAND_TRAITS            = 39;
COMMAND_GRIDTOGGLE        = 40;

COMMAND_SOUNDTOGGLE       = 86;
COMMAND_MUSICTOGGLE       = 87;

Keybindings = {
	["LEFT"]         = COMMAND_WALKWEST,
	["RIGHT"]        = COMMAND_WALKEAST,
	["UP"]           = COMMAND_WALKNORTH,
	["DOWN"]         = COMMAND_WALKSOUTH,
	["PGUP"]         = COMMAND_WALKNE,
	["PGDOWN"]       = COMMAND_WALKSE,
	["HOME"]         = COMMAND_WALKNW,
	["END"]          = COMMAND_WALKSW,
	["ESCAPE"]       = COMMAND_ESCAPE,
	["CENTER"]       = COMMAND_WAIT,
	["PERIOD"]       = COMMAND_WAIT,
	["ENTER"]        = COMMAND_OK,
	["M"]            = COMMAND_MORE,
	["SHIFT+COMMA"]  = COMMAND_ENTER,
	["SHIFT+PERIOD"] = COMMAND_ENTER,
	["SHIFT+U"]      = COMMAND_UNLOAD,
	["G"]            = COMMAND_PICKUP,
	["D"]            = COMMAND_DROP,
	["I"]            = COMMAND_INVENTORY,
	["E"]            = COMMAND_EQUIPMENT,
	["O"]            = COMMAND_OPEN,
	["C"]            = COMMAND_CLOSE,
	["L"]            = COMMAND_LOOK,
	["SHIFT+L"]      = function() ui.repeat_feel() end,
	["SPACE"]        = COMMAND_GRIDTOGGLE,
	["F"]            = COMMAND_FIRE,    -- function() command.fire() end,
	["SHIFT+F"]      = COMMAND_ALTFIRE, -- function() command.fire( true ) end,
	["R"]            = function() command.reload() end,
	["SHIFT+R"]      = function() command.reload( true ) end,
	["U"]            = COMMAND_USE,
	["SHIFT+Q"]      = function() command.quit() end,
	["SHIFT+SLASH"]  = function() command.help() end,
	["SHIFT+2"]      = COMMAND_PLAYERINFO,
	["SHIFT+S"]      = COMMAND_SAVE,
	TAB              = COMMAND_TACTIC,
	["COMMA"]        = COMMAND_RUNMODE,
	["Z"]            = COMMAND_SWAPWEAPON,
--	F10       = function() command.screenshot() end, -- currently hardcoded
--	F9        = function() command.screenshot( true ) end,-- currently hardcoded
	["T"]            = COMMAND_TRAITS,
	["SHIFT+9"]      = COMMAND_SOUNDTOGGLE,
	["SHIFT+0"]      = COMMAND_MUSICTOGGLE,
	["SHIFT+P"]      = function() command.messages() end,
	["SHIFT+A"]      = function() command.assemblies() end,
	-- Commands for blind mode:
	["X"]            = COMMAND_EXAMINENPC,
	["SHIFT+X"]      = COMMAND_EXAMINEITEM,
	-- QuickKeys
	["0"]     = function() command.quick_weapon('chainsaw') end,
	["1"]     = function() command.quick_weapon('knife') end,
	["2"]     = function() command.quick_weapon('pistol') end,
	["3"]     = function() command.quick_weapon('shotgun') end,
	["4"]     = function() command.quick_weapon('ashotgun') end,
	["5"]     = function() command.quick_weapon('dshotgun') end,
	["6"]     = function() command.quick_weapon('chaingun') end,
	["7"]     = function() command.quick_weapon('bazooka') end,
	["8"]     = function() command.quick_weapon('plasma') end,
	["9"]     = function() command.quick_weapon('bfg9000') end,

	-- Example of complex quickkey's
	["SHIFT+N"]    = function()
					if not command.use_item("smed") then
						ui.msg("No small medpacks left!")
					end
				end,
	["SHIFT+M"]    = function()
					if not command.use_item("lmed") then
						ui.msg("No large medpacks left!")
					end
				end,
}
