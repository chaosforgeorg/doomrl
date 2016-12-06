--[[ This as-of-yet-unknown special level is based on the Castle in NetHack.
     It will probably become part of another level; for now it lives here.
--]]

register_level "castle" {
	name  = "The Castle",
	entry = "On level @1 he wandered into the Castle.",
	welcome = "How meta...",
	level = 2,

	canGenerate = function ()
		return not DoomRL.isepisode()
	end,

	OnCompletedCheck = function ()
		return level.status == 3 or level.status == 4
	end,

	OnRegister = function ()

	end,

	Create = function ()

		local left = area.new( 1, 1, 9, 19 )
		local right = area.new( 70, 1, 78, 19 )
		local playerCoord = coord.new( 3, 3 )
		generator.fill( "void", area.FULL )

		--Generate the map...
		local translation = {
			['.'] = "floor",
			['~'] = "water",
			['"'] = "bridge",

			["`"] = "void",
			[">"] = "stairs",
			[">"] = "stairs",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },
		}

		local map = [[
##############################################################################
#.......#~~~~~~~~~..........................................~~~~~~~~~#.......#
#.#.....#~#######~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#######~#.....>.#
#.......#~#.....##############################################.....#~#.......#
#.......#~#.....+............................................+.....#~#.......#
#.......#~#############################+############################~#.......#
#.......#~~~~~~#.......#..........+.........#.......+.+.......#~~~~~~#.......#
#.......#.....~#.......#..........#.........#.......#.#.......#~.............#
#.......#.....~#.......############.........#########.#########~.....#.......#
#.......#....."+.......+..........+...........................+".....#.......#
#.......#.....~#.......############.........#########.#########~.....#.......#
#.............~#.......#..........#.........#.......#.#.......#~.....#.......#
#.......#~~~~~~#.......#..........+.........#.......+.+.......#~~~~~~#.......#
#.......#~#############################+############################~#.......#
#.......#~#.....+............................................+.....#~#.......#
#.......#~#.....##############################################.....#~#.......#
#.......#~#######~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#######~#.....>.#
#.......#~~~~~~~~~..........................................~~~~~~~~~#.......#
##############################################################################
]]
		generator.place_tile( translation, map, 1, 1 )

		--Generate the mazes.  Yes they are diggable.
		generator.maze_dungeon( "floor", "wolf_whwall", 2, 300, 2, 10, left )
		generator.maze_dungeon( "floor", "wolf_whwall", 2, 300, 2, 10, right )

		--Finish up
		level.flags[ LF_SHARPFLUID ] = true

		generator.set_cell( playerCoord, "floor" )
		level:player(playerCoord.x, playerCoord.y)
	end,

	OnEnter = function ()

	end,

	OnTick = function ()

	end,

	OnExit = function (being)
		if statistics.damage_on_level == 0 then
			player:add_history("He sacked it with ease.")
		else
			player:add_history("He marched through intact.")
		end

		level.status = level.status + 2
	end,
}
