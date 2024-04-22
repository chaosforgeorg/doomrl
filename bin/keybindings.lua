INPUT_WALKNORTH         = 2;
INPUT_WALKSOUTH         = 3;
INPUT_WALKEAST          = 4;
INPUT_WALKWEST          = 5;
INPUT_WALKNE            = 6;
INPUT_WALKSE            = 7;
INPUT_WALKNW            = 8;
INPUT_WALKSW            = 9;
INPUT_WAIT              = 10;
INPUT_ESCAPE            = 11;
INPUT_OK                = 12;
INPUT_ENTER             = 13;
INPUT_UNLOAD            = 14;
INPUT_PICKUP            = 15;
INPUT_DROP              = 16;
INPUT_INVENTORY         = 17;
INPUT_EQUIPMENT         = 18;
INPUT_OPEN              = 19;
INPUT_CLOSE             = 20;
INPUT_LOOK              = 21;
INPUT_ALTFIRE           = 23;
INPUT_FIRE              = 24;
INPUT_USE               = 25;
INPUT_PLAYERINFO        = 26;
INPUT_SAVE              = 27;
INPUT_TACTIC            = 28;
INPUT_RUNMODE           = 29;
INPUT_MORE              = 31;
INPUT_EXAMINENPC        = 32;
INPUT_EXAMINEITEM       = 33;
INPUT_SWAPWEAPON        = 34;
INPUT_TRAITS            = 39;
INPUT_GRIDTOGGLE        = 40;
INPUT_QUIT              = 41;
INPUT_HARDQUIT          = 42;
INPUT_ACTION            = 43;
INPUT_ALTPICKUP         = 44;
INPUT_RELOAD            = 45;
INPUT_ALTRELOAD         = 46;

INPUT_SOUNDTOGGLE       = 86;
INPUT_MUSICTOGGLE       = 87;     

Keybindings = {
	["LEFT"]         = INPUT_WALKWEST,
	["RIGHT"]        = INPUT_WALKEAST,
	["UP"]           = INPUT_WALKNORTH,
	["DOWN"]         = INPUT_WALKSOUTH,
	["PGUP"]         = INPUT_WALKNE,
	["PGDOWN"]       = INPUT_WALKSE,
	["HOME"]         = INPUT_WALKNW,
	["END"]          = INPUT_WALKSW,
	["ESCAPE"]       = INPUT_ESCAPE,
	["CENTER"]       = INPUT_WAIT,
	["PERIOD"]       = INPUT_WAIT,
	["ENTER"]        = INPUT_OK,
	["M"]            = INPUT_MORE,
	["SHIFT+COMMA"]  = INPUT_ENTER,
	["SHIFT+PERIOD"] = INPUT_ENTER,
	["SPACE"]        = INPUT_ACTION,
	["SHIFT+U"]      = INPUT_UNLOAD,
	["G"]            = INPUT_PICKUP,
	["SHIFT+G"]      = INPUT_ALTPICKUP,
	["D"]            = INPUT_DROP,
	["I"]            = INPUT_INVENTORY,
	["E"]            = INPUT_EQUIPMENT,
	["O"]            = INPUT_OPEN,
	["C"]            = INPUT_CLOSE,
	["L"]            = INPUT_LOOK,
	["SHIFT+L"]      = function() ui.repeat_feel() end,
	["SHIFT+K"]      = INPUT_GRIDTOGGLE,
	["F"]            = INPUT_FIRE,
	["SHIFT+F"]      = INPUT_ALTFIRE, 
	["R"]            = INPUT_RELOAD,
	["SHIFT+R"]      = INPUT_ALTRELOAD,
	["U"]            = INPUT_USE,
	["SHIFT+Q"]      = function() command.quit() end,
	["SHIFT+SLASH"]  = function() command.help() end,
	["SHIFT+2"]      = INPUT_PLAYERINFO,
	["SHIFT+S"]      = INPUT_SAVE,
	TAB              = INPUT_TACTIC,
	["COMMA"]        = INPUT_RUNMODE,
	["Z"]            = INPUT_SWAPWEAPON,
--	F10       = function() command.screenshot() end, -- currently hardcoded
--	F9        = function() command.screenshot( true ) end,-- currently hardcoded
	["T"]            = INPUT_TRAITS,
	["SHIFT+9"]      = INPUT_SOUNDTOGGLE,
	["SHIFT+0"]      = INPUT_MUSICTOGGLE,
	["SHIFT+P"]      = function() command.messages() end,
	["SHIFT+A"]      = function() command.assemblies() end,
	-- Commands for blind mode:
	["X"]            = INPUT_EXAMINENPC,
	["SHIFT+X"]      = INPUT_EXAMINEITEM,
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
