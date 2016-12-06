pascal_method_files   = { "../src/dfplayer.pas", "../src/dfbeing.pas", "../src/dfitem.pas", "../src/dfthing.pas" }
pascal_function_files = { "../src/doomlua.pas", "../src/dflevel.pas", "../src/dfdungen.pas"  }
lua_files             = { "lua/main.lua", "lua/core.lua" }
lua_config_files      = { "lua/constants.lua", "lua/enum.lua" }

parse_merges = {
	{ "item", "thing" },
	{ "being", "thing" },
	{ "player", "being" },
	{ "being", "player" },
	{ "self", "player" },
	{ "self", "item" },
}

parse_libraries = { "string", "table", "math" }

function parse_globals( global )
	local prop = global:match("PROP_([A-Z_]+)")
	if prop then
		return "fields", "thing", string.lower(prop)
	end
end



