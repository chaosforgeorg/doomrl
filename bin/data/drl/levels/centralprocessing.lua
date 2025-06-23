-- CENTRAL PROCESSING  --------------------------------------------------------

register_level "central_processing"
{
	name  = "Central Processing",
	entry = "On @1 he trekked through Central Processing.",
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
				level:play_sound( "door.open", level.data.door1_coord )

				ui.msg("North door unlocked.")
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
				level:play_sound( "door.open", level.data.door2_coord )
				ui.msg("Central area unlocked.")
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
				level:transmute( "wall", "floor", level.data.trap31 )
				level:transmute( "wall", "floor", level.data.trap32 )
				level:transmute( "wall", "floor", level.data.wall22 )
				level:play_sound( "door.open", level.data.door3_coord )
				ui.msg("Processing area unlocked.")
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
				level:play_sound( "door.open", level.data.door4_coord )
				ui.msg("East door unlocked.")
				return true
			end,
		}
	
		register_item "lever_centralprocessing5"
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
				level:transmute( "ldoor", "floor", level.data.door5 )
				level:play_sound( "door.open", level.data.door5_coord )
				ui.msg("Exit unlocked.")
				return true
			end,
		}
	end,

	Create = function ()
		level:set_generator_style( 1 )
		level:fill( "wall" )

		level.data.trap11         = area(5,15,5,16)
		level.data.trap12         = area(11,14,12,14)
		level.data.trap13         = area(7,18,8,18)
		level.data.trap14         = area(13,18,14,18)
		level.data.door1          = area(8,8,9,8)
		level.data.door1_coord    = coord(8,8)
		level.data.trap2          = area(9,3,9,4)
		level.data.trap21         = area(6,3,6,4)
		level.data.trapSA         = area(13,3,13,3)
		level.data.trapSA1        = area(14,3,14,3)
		level.data.trapSB         = area(4,3,4,3)
		level.data.trapSB1        = area(4,12,4,12)
		level.data.trapSB2        = area(3,3,3,3)
		level.data.door2          = area(15,10,15,10)
		level.data.door2_coord    = coord(15,10)
		level.data.trap31         = area(32,13,32,13)
		level.data.trap32         = area(34,11,34,11)
		level.data.door3          = area(29,10,29,10)
		level.data.door3_coord    = coord(29,10)
		level.data.wall22         = area(36,19,36,19)
		level.data.door4          = area(53,5,53,5)
		level.data.door4_coord    = coord(53,5)
		level.data.door5          = area(72,9,72,9)
		level.data.door5_coord    = coord(72,9)
		level.data.platform       = area(57,17,57,17)
		level.data.platform_coord = coord(57,17)
		level.data.trapSC         = area(57,16,57,16)
		level.data.trapSC1        = area(57,15,57,15)
		level.data.platform_up    = false

		local translation = {
			['.'] = "floor",
			['#'] = { "wall",  flags = { LFPERMANENT } },
			['='] = "acid",
			['>'] = "stairs",
			['+'] = { "floor", item = "lmed" },
			['~'] = { "floor", item = "barrel" },
			['L'] = { "ldoor",  flags = { LFPERMANENT } },
			['S'] = { "floor", item = "scglobe" },
			['E'] = { "floor", item = "epack" },
			['B'] = { "floor", item = "sboots" },
			['M'] = { "floor", item = "mod_agility"},
			['A'] = { "floor", item = "garmor"},

			['1'] = { "floor", item = "lever_centralprocessing1" },
			['2'] = { "floor", item = "lever_centralprocessing2" },
			['3'] = { "floor", item = "lever_centralprocessing3" },
			['4'] = { "floor", item = "lever_centralprocessing4" },
			['5'] = { "floor", item = "lever_centralprocessing5" },
			['6'] = { "floor", item = "level_centralprocessing6" },

			['h'] = { "floor", being = "former" },
			['H'] = { "floor", being = core.bydiff{ "former","former","sergeant","captain" } },
			['i'] = { "floor", being = "imp" },
			['O'] = { "floor", being = core.bydiff{ "cacodemon","cacodemon","knight","baron" } },
		}
		


		local map = [=[
################################################################.i#####..###
=#h.#...2===#.#################...........i........#############..#####h.###
=#i.#....===#.#################.#####...#####..==..#..........~...........##
=####.###===#+#################.......#............L.#####.####...........##
=####.##E===####.......########.#####...#####..==..#.......#5....i..........
=####..#########.#####.########............i.......#.#####.####............H
=#####LL#~+i####.#.i.#.########.##################.#..........~...........##
=#####......####.#...#.#...#....####=.=######.####.###############.###L#..##
=#####..#####L...........#.L.#####.....h.#=.=#...#.###############h###.#..##
=+#..#.......###.#...#.#...###+h#..#=.=#......h#.#.......h.......#####.#####
=A#.....########.#.i.#.#######.##.###.##.#=.=###.#...H......H....#####.#####
###..#..#H.#####.#####.#########=.=#..##.##.##..3#..............4#####.M.###
######.#########.......########......##=.=#.##...#...............#####+.B###
##i#....~..#h.####.############.=.=#.....h..##.#######################.>.###
##H#.......#.1####.############.#.##.##=.=#.##.########S####################
####~...#~....####.............##....######....#...i..###h....##############
##################==========####################.....h......O.##############
#####h.####h.#####================#...........................##############
]=]



		generator.place_tile( translation, map, 2, 2 )

		generator.set_permanence( area.FULL )
		level.data.kill_all  = false

		local id = core.get_unknown_assembly( 0 )
		if id then
			local item = level:drop_item("schematic_0",coord(63,18))
			local ma   = mod_arrays[id]
			item.ammo  = ma.nid
			item.name  = ma.name.." schematics"
		end

		level:player(5,12)
	end,

	OnKillAll = function ()
		level.data.kill_all  = true
		ui.msg("\"The machinery falls silent\"")
		level.status = 4
	end,

	OnEnterLevel = function ()
		level.status = 0
	end,

	OnTick = function ()
		local platform_up = (core.game_time() % 500 > 249)
		if not level.data.platform:contains(player.position) then
			if not level.data.platform_up and platform_up then
				level:transmute( "wall", "floor", level.data.platform)
				level:play_sound( "door.open", level.data.platform_coord )
			elseif level.data.platform_up and not platform_up then
				level:transmute( "floor", "wall", level.data.platform)
				level:play_sound( "door.close", level.data.platform_coord )
				--Actually, this 'wall' is a platform, so there is no need to kill the monster. However it will look unusual sitting atop a wall.
				--If killing it is the preferred option, refer to toxinrefinery's code.
			end
			level.data.platform_up = platform_up
		end

		if level.data.trap2:contains(player.position) then 
			level:transmute( "wall", "floor", level.data.trap21)
		end
		if level.data.trapSA:contains(player.position) then
			level:transmute( "wall", "floor", level.data.trapSA1)
		end
		if level.data.trapSB:contains(player.position) then
			level:transmute( "wall", "floor", level.data.trapSB1)
			level:transmute( "wall", "floor", level.data.trapSB2)
		end
		if level.data.trapSC:contains(player.position) then
			level:transmute( "wall", "floor", level.data.trapSC1)
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