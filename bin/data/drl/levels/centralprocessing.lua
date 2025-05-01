-- CENTRAL PROCESSING  --------------------------------------------------------

register_level "central_processing"
{
	name  = "Central Processing",
	entry = "On level @1 he trekked through Central Processing.",
	welcome = "You enter Central Processing. You shudder, thinking about the evil mastermind who planned this.",
	level = 4,

	OnRegister = function ()
		register_item "lever_centralprocessing1"
		{
			name   = "lever",
			color  = MAGENTA,
			sprite = SPRITE_LEVER,
			weight = 0,
			type   = ITEMTYPE_LEVER,
			flags  = { IF_NODESTROY },

			good = "neutral",
			desc = "unlocks door",

			color_id = false,
			sound_id = "lever",

			OnUse = function(self,being)
				level:transmute( "ldoor", "floor", level.data.door1 )
				level:transmute( "wall", "floor", level.data.trap11 )
				level:transmute( "wall", "floor", level.data.trap12 )
				level:transmute( "wall", "floor", level.data.trap13 )
				level:transmute( "wall", "floor", level.data.trap14 )
				level:play_sound( "door.open", level.data.door1 )
				level:play_sound( "door.open", level.data.trap11 )
				level:play_sound( "door.open", level.data.trap12 )
				level:play_sound( "door.open", level.data.trap13 )
				level:play_sound( "door.open", level.data.trap14 )

				ui.msg("Red access granted, north door unlocked.")
				return true
			end,
		}

		register_item "lever_centralprocessing2"
		{
			name   = "lever",
			color  = MAGENTA,
			sprite = SPRITE_LEVER,
			weight = 0,
			type   = ITEMTYPE_LEVER,
			flags  = { IF_NODESTROY },

			good = "neutral",
			desc = "unlocks door",

			color_id = false,
			sound_id = "lever",

			OnUse = function(self,being)
				level:transmute( "ldoor", "floor", level.data.door2 )
				level:transmute( "wall", "floor", level.data.trap31 )
				level:transmute( "wall", "floor", level.data.trap32 )
				ui.msg("Yellow access granted, central door unlocked.")
				return true
			end,
		}

		register_item "lever_centralprocessing3"
		{
			name   = "lever",
			color  = MAGENTA,
			sprite = SPRITE_LEVER,
			weight = 0,
			type   = ITEMTYPE_LEVER,
			flags  = { IF_NODESTROY },

			good = "neutral",
			desc = "unlocks door",

			color_id = false,
			sound_id = "lever",

			OnUse = function(self,being)
				level:transmute( "ldoor", "floor", level.data.door3 )
				ui.msg("East door unlocked.")
				return true
			end,
		}
	
		register_item "lever_centralprocessing4"
		{
			name   = "lever",
			color  = MAGENTA,
			sprite = SPRITE_LEVER,
			weight = 0,
			type   = ITEMTYPE_LEVER,
			flags  = { IF_NODESTROY },

			good = "neutral",
			desc = "unlocks door",

			color_id = false,
			sound_id = "lever",

			OnUse = function(self,being)
				level:transmute( "ldoor", "floor", level.data.door4 )
				ui.msg("Exit unlocked.")
				return true
			end,
		}
	
	end,

	Create = function ()
		level:set_generator_style( 1 )
		level:fill( "wall" )

		level.data.trap11   = area(4,14,4,15)
		level.data.trap12   = area(10,13,11,13)
		level.data.trap13   = area(6,17,7,17)
		level.data.trap14   = area(7,12,7,13)
		level.data.door1    = area(7,7,8,7)
		level.data.trap2    = area(8,2,8,3)
		level.data.trap21   = area(5,2,5,3)
		level.data.trapSA   = area(12,2,12,2)
		level.data.trapSA1  = area(13,2,13,2)
		level.data.trapSB   = area(3,2,3,2)
		level.data.trapSB1  = area(3,11,3,11)
		level.data.trapSB2  = area(2,2,2,2)
		level.data.trap31   = area(31,12,31,12)
		level.data.trap32   = area(33,10,33,10)
		level.data.door21   = area(28,9,28,9)
		level.data.wall22   = area(31,18,31,18)
		level.data.door3    = area(52,4,52,4)
		level.data.door4    = area(71,8,71,8)
		level.data.platform = area(56,16,56,16)
		level.data.trapSC   = area(56,15,56,15)
		level.data.trapSC1  = area(56,14,56,14)
		level.data.platform_up = false
		level.entry_time = core.game_time()

		local translation = {
			['.'] = "floor",
			['#'] = { "wall",  flags = { LFPERMANENT } },
			['='] = "acid",
			['>'] = "stairs",
			['~'] = "barrel of fuel",
			['L'] = { "ldoor",  flags = { LFPERMANENT } },
			['P'] = { "floor", item = "pmap" },
			['S'] = { "floor", item = "scglobe" },
			['E'] = { "floor", item = "enviro" },

			['1'] = { "floor", item = "lever_centralprocessing1" },
			['2'] = { "floor", item = "lever_centralprocessing2" },
			['3'] = { "floor", item = "lever_centralprocessing3" },
			['4'] = { "floor", item = "lever_centralprocessing4" },
		}
		


		local map = [=[
################################################################..#####..###
=#..#...2===#.#################....................#############..#####..###
=#..#....===#.#################.#####...#####..==..#..........~...........##
=####.###===#.#################.......#............L.#####.####...........##
=####.##E===####.......########.#####...#####..==..#.......#k...............
=####..#########.#####.########....................#.#####.####.............
=#####LL#~..####.#...#.########.##################.#..........~...........##
=#####......####.#...#.#...#....####=.=######.####.###############.###L#..##
=#####..#####............#.L.#####.......#=.=#...#.###############.###.#..##
=.#..#.......###.#...#.#...###P.#..#=.=#.......#.#...............#####.#####
=.#.....########.#...#.#######.##.###.##.#=.=###.#...............#####.#####
###..#..#..#####.#####.#########=.=#..##.##.##..3#..............4#####...###
######.#########.......########......##=.=#.##...#...............#####...###
##.#....~..#..####.############.=.=#........##.#######################.>.###
##.#.......#.1####.############.#.##.##=.=#.##.########S####################
####~...#~....####.............##....######....#......###.....##############
##################==========####################..............##############
#####..####..#####============#...............................##############
]=]



		generator.place_tile( translation, map, 2, 2 )

		generator.set_permanence( area.FULL )
		level.data.drop_time = 0
		level.data.kill_all  = false
		level:player(4,11)
	end,

	OnKillAll = function ()
		level.data.kill_all  = true
		ui.msg("\"The machinery falls silent\"")
		level.status = 4
	end,

	OnEnter = function ()
		level.status = 0
	end,

	OnTick = function ()
		local time = core.game_time() - level.entry_time
		local platform_up = not level.data.platform_up
		--math.mininteger(math.mininteger(time / 5) / 2) == 1
		if not level.data.platform_up and platform_up then
			level:transmute( "wall", "floor", level.data.platform)
			level:play_sound( "door.open", level.data.platform )
		elseif level.data.platform_up and not platform_up then
			level:transmute( "floor", "wall", level.data.platform)
			level:play_sound( "door.close", level.data.platform )
		end
		level.data.platform_up = platform_up

		if level.data.trap2:contains(player.position) then 
			level.data.trap21:transmute( "wall", "floor")
		end
		if level.data.trapSA:contains(player.position) then
			level.data.trapSA1:transmute( "wall", "floor")
		end
		if level.data.trapSB:contains(player.position) then
			level.data.trapSB1:transmute( "wall", "floor")
			level.data.trapSB2:transmute( "wall", "floor")
		end
		if level.data.trapSC:contains(player.position) then
			level.data.trapSC1:transmute( "wall", "floor")
		end
	end,

	OnExit = function ()
		if level.data.kill_all  then
			ui.msg("No meat left to process.")
			player:add_history("Nothing stood in his way.")
		else
			ui.msg("Just too many to count.")
			player:add_history("He couldn't quite finish the job.")
		end
	end,


}