-- ABYSSAL PLAINS --------------------------------------------------------

register_level "abyssal_plains"
{
	name  = "Abyssal Plains",
	entry = "On level @1 he romped upon the Abyssal Plains.",
	welcome = "You enter the Abyssal Plains. Well isn't this... just... dandy.",
	level = 12,


	Create = function ()
		level:set_generator_style( 1 )
		generator.fill( "wall", area.FULL )

		local roll_mod = function ()
			return table.random_pick{"mod_power","mod_agility","mod_bulk","mod_tech"}
		end

		local translation = {
			['.'] = "floor",
			[','] = { "floor", flags = { LFBLOOD } },
			['#'] = { "wall",  flags = { LFPERMANENT } },
			['$'] = { "rwall", flags = { LFPERMANENT } },
			['Z'] = { "gwall", flags = { LFPERMANENT } },
			['+'] = { "door",  flags = { LFPERMANENT } },
			['X'] = { "stairs",being = "pain" },
			['K'] = { "floor", being = core.ifdiff( 4, "baron") or core.ifdiff( 2, "knight", "demon" ) },
			['i'] = { "floor", being = core.ifdiff( 5, "nimp")  or core.ifdiff( 3, "knight", "imp" ) },
			['I'] = { "floor", being = core.ifdiff( 2, "knight", "imp" ) },
			['s'] = { "floor", being = core.ifdiff( 5, "pain", "lostsoul" ) },
			['K'] = { "floor", being = core.ifdiff( 3, "pain", "lostsoul" ) },
			['b'] = { "floor", being = core.ifdiff( 3, "lostsoul" ) },
			['S'] = { "floor", being = core.ifdiff( 4, "pain") or core.ifdiff( 2, "lostsoul" ) },
			['c'] = { "floor", being = "demon" },
			['o'] = { "floor", being = core.ifdiff( 2, "cacodemon", "imp" ) },
			['O'] = { "floor", being = core.ifdiff( 3, "arachno", "cacodemon" ) },
			['%'] = { "corpse"},

			['^'] = { "floor", item = "shglobe" },
			['!'] = { "floor", item = "scglobe" },
			['-'] = { "floor", item = "shell" },
			['1'] = { "floor", item = "pshell" },
			['5'] = { "floor", item = "shotgun" },
			['|'] = { "floor", item = "ammo" },
			['2'] = { "floor", item = "pammo" },
			['6'] = { "floor", item = "chaingun" },
			['3'] = { "floor", item = "procket" },
			['7'] = { "floor", item = "umbazooka" },
			['/'] = { "floor", item = "lmed" },

		}

		local map = [=[
###^......##....i........................--...........O.......#####....3%###
######............####...I......####....5%-..####..............O......######
......i...........###............####..o.1....#.......##....................
.......####.........###..............................###.........####...b..#
#i........###........###........I$$$$$$$$$$......O...##^.......###.......###
##.........##..$$.....I....$$$$$$$........$$$$$$$..........$$..##...S...####
##............i$$$.....$$$$$.......ZZZZZZ.......$$$$$.....$$$..........###..
###........b.....$$$$$$$.......ZZZZZs..sZZZZZ.......$$$$$$$...........##....
....................b.+.......ZZs....KK....sZZ.......+.......b............#!
......................+.......ZZs....KX....sZZ.......+....................#7
###...........b..$$$$$$$.......ZZZZZs..sZZZZZ.......$$$$$$$.......S...##....
##........b....$$$...I.$$$$$.......ZZZZZZ.......$$$$$.....$$$..........###..
##.........##i.$$..........$$$$$$$........$$$$$$$......#...$$..##.......####
#i........###.......##...........$$$$$$$$$$..........####O.....###.....b.###
.......####..........##...........I..........###......###........####......#
........i............##....I####..........o.###...............##...O........
######......................^#####...........#.......|||.....##.......######
###%/......###......i......######......##.........o..2%6..........#.....^###
]=]
		generator.place_tile( translation, map, 2, 2 )

		generator.set_permanence( area.FULL )
		level.data.drop_time = 0
		level.data.kill_all  = false
		level:player(2,11)
	end,

	OnKillAll = function ()
		if level.status > 0 then
			if not level.data.kill_add then
				level.data.kill_all  = true
				ui.msg("\"Ugly motherfuckers.\"")
			end
		end
		--on the off-chance the player nuke/invulns through the level
		generator.transmute( "gwall", "floor" )
	end,

	OnEnter = function ()
		level.status = 0
	end,

	OnTick = function ()
		local time = core.game_time()
		local res = level.status
		if res > 1 then return end
		if res == 0 and player.x > 29 and player.x < 49 and player.y > 7 and player.y < 14 then
			ui.msg("Suddenly you're trapped in!")
			level:play_sound( "door.close", player.position )
			generator.transmute( "gwall", "floor" )
			for c in area.new( 28, 9, 28, 12 )() do generator.wallin_cell( c, "rwall" ) end
			for c in area.new( 50, 9, 50, 12 )() do generator.wallin_cell( c, "rwall" ) end
			generator.set_permanence( area.FULL )

			ui.msg("You hear a howl of agony!")
			local agony = level:drop_being("agony",coord.new(42,11))
			for i = 1,3 do
				agony.inv:add( item.new(table.random_pick{"ufskull","ubskull","uhskull"}) )
			end

			level.data.drop_time = time
			level.status = 1
		end
		if res == 1 and (time - 400 > level.data.drop_time or level.data.kill_all) then
			ui.msg("Finally, the walls retract into the ground.")
			generator.transmute( "rwall", "floor", area.new( 28, 9, 50, 12 ) )
			generator.set_permanence( area.FULL )
			level.status = 2
		end
	end,

	OnExit = function ()
		if level.data.kill_all  then
			ui.msg("Sure can make a guy miss the REAL plains...")
			player:add_history("He slaughtered the beasts living there.")
 	 		player:add_badge("skull1")
			if core.is_challenge("challenge_aora") then player:add_badge("skull2") end
		else
			ui.msg("Damn, that was way too close for comfort!.")
			player:add_history("He barely escaped the trap set for him.")
		end
	end,


}