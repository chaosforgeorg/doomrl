--[[ The Axe and the tower.  The axe is a cheesy boss in TLL
     but I have reinvented him.  The tower is cramped, semi-random,
     and features multiple levels.
--]]

register_level "tower1" {
	name  = "The Tower",
	entry = "On level @1 he scaled the tower.",
	welcome = "Do you wish to rise?",
	level = 18,

	canGenerate = function ()
		return DIFFICULTY >= DIFF_MEDIUM and not DoomRL.isepisode()
	end,

	OnCompletedCheck = function ()
		return false --This is a multi-level special.  Only the last floor really matters.
	end,

	OnRegister = function ()

	end,

	Create = function ()
		generator.fill( "void", area.FULL )

		--Generate the map...
		local basetranslation = {
			['.'] = "floor",
			[','] = "rock",

			["`"] = "void",
			["<"] = "ystairs",
			['$'] = "wolf_whwall",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },
			['&'] = { "wolf_whwall", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },
		}
		local gametranslation = {
			['.'] = "floor",
			[','] = "rock",

			["`"] = "void",
			["<"] = "ystairs",
			['$'] = "wolf_whwall",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },
			['&'] = { "wolf_whwall", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },
		}
		if (string.find(VERSION_STRING, "G")) then
			gametranslation['&'] = { "wolf_whwall", flags = { LFPERMANENT } }
		end

		local map = [[
`````#########````````
`````#,,,,,,,#````````
```###,#####+#####````
```#,,,#.........#````
```#,###.#.#.#.#.###``
```#,#.............#``
####,#.#.........#.###
#,,+,#<............+,#
#,,$,#.#.........#.#,#
#,,$,#.............#,#
#,,$,###.#.#.#.#.###,#
#,,$,,,#.........#,,,#
#,,$$$,###########,###
#,,,,$,,,,,,,,,,,,,#``
&,$$,$$$$$$$+#######``
=,,$,,,,,,,,,#````````
&,,,,,,,,,,,,#````````
#&=&##########````````
]]
		generator.place_tile( basetranslation, map, 26, 1 )
		generator.place_tile( gametranslation, map, 26, 1 )
		generator.maze_dungeon( "floor", "wolf_whwall", 2, 300, 1, 10, area.FULL )
		generator.transmute("rock", "floor")

		level.data.exit = "tower2"
		level:player(29, 16)
	end,

	OnEnter = function ()
		player:add_property( "tower_damage_on_level", 0 )
	end,

	OnExit = function (being)
		player.tower_damage_on_level = player.tower_damage_on_level + statistics.damage_on_level
	end,
}
register_level "tower2" {
	name  = "The Tower",

	canGenerate = function ()
		return false
	end,

	OnCompletedCheck = function ()
		return false --This is a multi-level special.  Only the last floor really matters.
	end,

	Create = function ()
		generator.fill( "void", area.FULL )

		--Generate the map...
		local basetranslation = {
			['.'] = "floor",

			["`"] = "void",
			["<"] = "ystairs",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },
		}
		local gametranslation = {
			['.'] = "floor",

			["`"] = "void",
			["<"] = "ystairs",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },
		}

		local map = [[
``###########``
``#.........#``
###.........###
#.............#
#.............#
#............<#
#.............#
#.............#
###.........###
``#.........#``
``###########``
]]
		generator.place_tile( basetranslation, map, 31, 3 )
		generator.place_tile( gametranslation, map, 31, 3 )
		generator.maze_dungeon( "floor", "wolf_whwall", 2, 300, 1, 10, area.FULL )

		level.data.exit = "tower3"
		level:player(32, 8)
	end,

	OnExit = function (being)
		player.tower_damage_on_level = player.tower_damage_on_level + statistics.damage_on_level
	end,
}
register_level "tower3" {
	name  = "Dark Tower",

	canGenerate = function ()
		return false
	end,

	OnCompletedCheck = function ()
		return false --This is a multi-level special.  Only the last floor really matters.
	end,

	Create = function ()
		generator.fill( "void", area.FULL )

		--Generate the map...
		local basetranslation = {
			['.'] = "floor",

			["`"] = "void",
			["<"] = "ystairs",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },
		}
		local gametranslation = {
			['.'] = "floor",

			["`"] = "void",
			["<"] = "ystairs",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },
		}

		local map = [[
``###########``
``#.........#``
###.#.#.#.#.###
#.............#
#.#.........#.#
#<............#
#.#.........#.#
#.............#
###.#.#.#.#.###
``#.........#``
``###########``
]]
		generator.place_tile( basetranslation, map, 31, 3 )
		generator.place_tile( gametranslation, map, 31, 3 )
		generator.maze_dungeon( "floor", "wolf_whwall", 2, 300, 1, 10, area.FULL )

		level.data.exit = "tower4"
		level:player(44, 8)
	end,

	OnExit = function (being)
		player.tower_damage_on_level = player.tower_damage_on_level + statistics.damage_on_level
	end,
}
register_level "tower4" {
	name  = "Dark Tower",

	canGenerate = function ()
		return false
	end,

	OnCompletedCheck = function ()
		return false --This is a multi-level special.  Only the last floor really matters.
	end,

	Create = function ()
		generator.fill( "void", area.FULL )

		--Generate the map...
		local basetranslation = {
			['.'] = "floor",

			["`"] = "void",
			["<"] = "ystairs",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },
		}
		local gametranslation = {
			['.'] = "floor",

			["`"] = "void",
			["<"] = "ystairs",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },
		}

		local map = [[
``###`###`###``
``#.#`#.#`#.#``
###.###.###.###
#.............#
###.........###
``#........<#``
###.........###
#.............#
###.###.###.###
``#.#`#.#`#.#``
``###`###`###``
]]
		generator.place_tile( basetranslation, map, 31, 3 )
		generator.place_tile( gametranslation, map, 31, 3 )
		generator.maze_dungeon( "floor", "wolf_whwall", 2, 300, 0, 10, area.FULL )

		level.data.exit = "tower5"
		level:player(34, 8)
	end,

	OnExit = function (being)
		player.tower_damage_on_level = player.tower_damage_on_level + statistics.damage_on_level
	end,
}
register_level "tower5" {
	name  = "Dark Tower",

	canGenerate = function ()
		return false
	end,

	OnCompletedCheck = function ()
		return level.status >= 1
	end,

	Create = function ()
		level.name = "Death Or Glory"
		generator.fill( "void", area.FULL )

		--Generate the map...
		local basetranslation = {
			['.'] = "floor",

			["`"] = "void",
			[">"] = "stairs",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },
		}
		local gametranslation = {
			['.'] = "floor",

			["`"] = "void",
			[">"] = "stairs",
			[">"] = {"stairs", being = "wolf_bossaxe"},
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },
		}

		local map = [[
``###`###`###``
``#.#`#.#`#.#``
###.###.###.###
#.............#
###.#.#.#.#.###
``#....>....#``
###.#.#.#.#.###
#.............#
###.###.###.###
``#.#`#.#`#.#``
``###`###`###``
]]
		generator.place_tile( basetranslation, map, 31, 3 )
		generator.place_tile( gametranslation, map, 31, 3 )

		level:player(42, 8)
	end,

	OnKillAll = function (being)
		level.status = 1
	end,

	OnExit = function (being)
		    if level.status > 0 and player.tower_damage_on_level + statistics.damage_on_level == 0 then
			player:add_history("He ascended with pure guile.")
		elseif level.status > 0 then
			player:add_history("He rose above all challenges.")
		else
			player:add_history("He fled the apex in fear.")
		end

		player:remove_property( "tower_damage_on_level" )
	end,
}
