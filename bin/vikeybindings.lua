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
INPUT_ACTION            = 43;
INPUT_ALTPICKUP         = 44;
INPUT_RELOAD            = 45;
INPUT_ALTRELOAD         = 46;

INPUT_HELP              = 47; -- will be removed
INPUT_LEVEL_FEEL        = 48; -- will be removed
INPUT_MESSAGES          = 49; -- will be removed
INPUT_ASSEMBLIES        = 50; -- will be removed

INPUT_SOUNDTOGGLE       = 86;
INPUT_MUSICTOGGLE       = 87;

Keybindings = {
	["H"]            = INPUT_WALKWEST,
	["L"]            = INPUT_WALKEAST,
	["K"]            = INPUT_WALKNORTH,
	["J"]            = INPUT_WALKSOUTH,
	["U"]            = INPUT_WALKNE,
	["N"]            = INPUT_WALKSE,
	["Y"]            = INPUT_WALKNW,
	["B"]            = INPUT_WALKSW,
	["ESCAPE"]       = INPUT_ESCAPE,
	["CENTER"]       = INPUT_WAIT,
	["PERIOD"]       = INPUT_WAIT,
	["ENTER"]        = INPUT_OK,
	["M"]            = INPUT_MORE,
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
	["QUOTE"]        = INPUT_LOOK,
	["F"]            = INPUT_FIRE,
	["SHIFT+F"]      = INPUT_ALTFIRE,
	["R"]            = INPUT_RELOAD,
	["SHIFT+R"]      = INPUT_ALTRELOAD,
	["A"]            = INPUT_USE,
	["SHIFT+Q"]      = INPUT_QUIT,
	["SHIFT+SLASH"]  = INPUT_HELP,
	["SHIFT+2"]      = INPUT_PLAYERINFO,
	["SHIFT+S"]      = INPUT_SAVE,
	TAB              = INPUT_TACTIC,
	["COMMA"]        = INPUT_RUNMODE,
	["Z"]            = INPUT_SWAPWEAPON,
--	F10       = function() command.screenshot() end,   (Is hardcoded)
--	F9        = function() command.screenshot( true ) end,  (Is hardcoded)
	["SHIFT+T"]      = INPUT_TRAITS,
	["SHIFT+9"]      = INPUT_SOUNDTOGGLE,
	["SHIFT+0"]      = INPUT_MUSICTOGGLE,
	["SHIFT+P"]      = INPUT_MESSAGES,
	["SHIFT+A"]      = INPUT_ASSEMBLIES,
	-- Commands for blind mode:
	["X"]            = INPUT_EXAMINENPC,
	["SHIFT+X"]      = INPUT_EXAMINEITEM,
	-- QuickKeys
	["0"]     = INPUT_QUICKKEY_0,
	["1"]     = INPUT_QUICKKEY_1,
	["2"]     = INPUT_QUICKKEY_2,
	["3"]     = INPUT_QUICKKEY_3,
	["4"]     = INPUT_QUICKKEY_4,
	["5"]     = INPUT_QUICKKEY_5,
	["6"]     = INPUT_QUICKKEY_6,
	["7"]     = INPUT_QUICKKEY_7,
	["8"]     = INPUT_QUICKKEY_8,
	["9"]     = INPUT_QUICKKEY_9,
}
