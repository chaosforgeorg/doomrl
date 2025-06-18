-- CENTRAL PROCESSING  --------------------------------------------------------

register_level "toxin_refinery"
{
	name  = "Toxin Refinery",
	entry = "On level @1 he waded into the Toxin Refinery.",
	welcome = "The stench of toxins chokes you briefly.",
	level = 4,

	OnRegister = function ()
		register_item "lever_toxinrefinery1"
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
				level:transmute( "wall", "floor", level.data.trap1 )
				level.data.old_darkness = player.flags[ BF_DARKNESS ]
				level.data.darkness_end_time = core.game_time() + 150
				player.flags[ BF_DARKNESS ]   = true
				player.vision = player.vision - level.data.vision_reduction
				ui.msg("Eastern door unlocked.")
				return true
			end,
		}

		register_item "lever_toxinrefinery2"
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
				ui.msg("Smoking area unlocked.")
				return true
			end,
		}

		register_item "lever_toxinrefinery3"
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
				level:transmute( "wall", "floor", level.data.door3 )
				level:transmute( "acid", "bridge", level.data.bridge )
				ui.msg("Shortcut unlocked.")
				return true
			end,
		}
	end,
	
	Create = function ()
		level:set_generator_style( 1 )
		level:fill( "wall" )
		level.data.bridge               = area(36,11,36,14)
		level.data.door1                = area(39,10,39,10)
		level.data.trap1                = area(13,5,13,6)
		level.data.door2                = area(66,15,66,16)
		level.data.door3                = area(36,10,36,10)
		level.data.secret1              = area(13,14,13,14)
		level.data.half_wall            = area(14,14,14,14)
		level.data.half_wall_coord      = coord(14,14)
		level.data.half_wall_trigger    = area(26,16,26,16)
		level.data.half_wall_trigger2   = area(10,14,10,14)
		level.data.half_wall_down_time  = 0
		level.data.darkness_end_time    = 0
		level.data.vision_reduction     = 6

		local translation = {
			['.'] = "floor",
			['#'] = { "wall",  flags = { LFPERMANENT } },
			['='] = "acid",
			['>'] = "stairs",
			['+'] = "door",

			['~'] = { "floor", item = "barrel" },
			['%'] = { "wall", flags = { LFBLOOD } },
			['L'] = { "ldoor",  flags = { LFPERMANENT } },

			['a'] = { "floor", item = "garmor" },
			['A'] = { "floor", item = "barmor" },
			['B'] = { "floor", item = "bpack" },
			['M'] = { "floor", item = "lmed" },
			['m'] = { "floor", item = "smed" },
			['g'] = { "floor", item = "shglobe" },
			['-'] = { "floor", item = "shell" },

			['1'] = { "floor", item = "lever_toxinrefinery1" },
			['2'] = { "floor", item = "lever_toxinrefinery2" },
			['3'] = { "floor", item = "lever_toxinrefinery3" },

			['h'] = { "floor", being = "former" },
			['H'] = { "floor", being = core.bydiff{ "former","former","sergeant","captain" } },
			['i'] = { "floor", being = "imp" },
			['O'] = { "floor", being = core.bydiff{ "cacodemon","cacodemon","knight","baron" } },
		}

		local map = [=[
################################..h..+..####################################
##############....h....h.#######....h#.>####################################
##############.####.#.##########.O...#################......i=....##########
##########i#...#####.###########...i.############...h...=====#.H..##########
##########i#...###=.H.=##########%.%########.i.#.....#########....#.B.######
############...###=.=.=##########%.%######...=.+......h........#H.+..A######
######3.####g1.###=.=.=##########%.%#####..===.#.....#########....#.>.######
######..=#########=...=##########%.%#....i.===.##..h....=====#.H..##########
########=###########.################L###..===.#######......i=....##########
#========###########.h......#~.m#===#i.m##..==.#############################
#==.i..####################.#H.##===##.~###..=.+..##########################
#==.M#.######.H......######.+..#=====#..####...##.##........##...###########
#==........##..#####.######.#..##===##..#########.........h......###########
#==.i#.######..h..##.######.#.H.....~..h############.h......####L###########
#==....######..##2##........#.~......H..###########...i.....####..B.=....###
#=======#####..i.a##.#############+#############################..M.=....###
#############..#####.############m.-############################=====....###
#############i.......###########################################.........###
]=]

		generator.place_tile( translation, map, 2, 2 )

		generator.set_permanence( area.FULL )
		level.data.kill_all  = false
		level.data.old_darkness = player.flags [ BF_DARKNESS ]
		level.data.darkness_end_time = 0

		local id = core.get_unknown_assembly( 0 )
		if id then
			local item = level:drop_item("schematic_0",coord(41,2))
			local ma   = mod_arrays[id]
			item.ammo  = ma.nid
			item.name  = ma.name.." schematics"
		end

		level:player(36,18)
	end,

	OnKillAll = function ()
		level.data.kill_all  = true
		ui.msg("\"The acrid smell begins to dissipate\"")
		level.status = 4
	end,

	OnEnterLevel = function ()
		level.status = 0
	end,

	OnTick = function ()
		if (level.data.half_wall_down_time > 0) and (core.game_time() >= level.data.half_wall_down_time) and not level.data.half_wall:contains(player.position) then
			level:transmute( "floor", "wall", level.data.half_wall)
			local target = level:get_being(level.data.half_wall_coord)
			if target then
				if target:is_player() then return false end
				target:kill()
			end
			level.data.half_wall_down_time = 0
		elseif level.data.half_wall_down_time == 0 and (level.data.half_wall_trigger:contains(player.position) or level.data.half_wall_trigger2:contains(player.position)) then
			level:transmute( "wall", "floor", level.data.half_wall)
			level.data.half_wall_down_time = core.game_time() + 150
		end
		if level.data.darkness_end_time > 0 and level.data.darkness_end_time < core.game_time() then
			player.vision = player.vision + level.data.vision_reduction
			player.flags[ BF_DARKNESS ] = level.data.old_darkness
			level.data.darkness_end_time = 0
			end
		if level.data.half_wall:contains(player.position) then
			level:transmute( "wall", "floor", level.data.secret1)
		end
	end,

	OnExit = function ()
		if level.data.kill_all  then
			ui.msg("You were a green machine.")
			player:add_history("He was the antidote.")
		else
			ui.msg("That'll set them back a bit.")
			player:add_history("He couldn't quite finish the job.")
		end
		if level.data.darkness_end_time > 0 then
			player.vision = player.vision + level.data.vision_reduction
			player.flags[ BF_DARKNESS ] = level.data.old_darkness
			level.data.darkness_end_time = 0
		end
	end,

}