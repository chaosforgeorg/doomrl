-- MT. EREBUS -----------------------------------------------------------

register_level "mt_erebus"
{
	name  = "Mt. Erebus",
	entry = "On level @1 he arrived at Mt. Erebus.",
	welcome = "You arrive at Mt. Erebus. You shiver before the mountain of eternal fire!",
	level = 22,

	OnRegister = function ()
		register_item "lever_erebus"
		{
			name   = "lever",
			color  = MAGENTA,
			sprite = SPRITE_LEVER,
			weight = 0,
			type   = ITEMTYPE_LEVER,
			flags  = { IF_NODESTROY, IF_FEATURENAME },

			good = "dangerous",
			desc = "raises the mountain",

			color_id = false,

			OnUse = function(self,being)
				if level.status > 2 then return true end
				local raise = 0
				if level.status == 1 then 
					raise = 1
				elseif level.status == 2 then 
					raise = 2
				end
				player:play_sound("lever.use")
				generator.transmute_style( "cwall", "floor", raise, 0 )
				level.status = level.status + 1
				return true
			end,

			OnDescribe = item.get_lever_description,
		}
	end,

	Create = function ()
		level:set_generator_style( 1 )
		level:fill( "plava" )

		local lavapits_armor = {
			level      = 25,
			type       = {ITEMTYPE_ARMOR,ITEMTYPE_BOOTS},
			weights    = { is_unique = 5, ulavaarmor = 3 }, -- multiplicative!
		}

		local translation = {
			['.'] = "floor",
			['='] = "lava",
			['>'] = "stairs",
			[','] = "bridge",
			['X'] = { "cwall", flags = { LFPERMANENT }, style = 1, },
			['%'] = { "cwall", flags = { LFPERMANENT }, style = 2, },
			['#'] = { "cwall", flags = { LFPERMANENT }, style = 3, },
			['&'] = { "floor", item = "lever_erebus" },

			['/'] = { "floor", item = "shell" },
			['|'] = { "floor", item = "cell" },
			['-'] = { "floor", item = "rocket" },
			['!'] = { "floor", item = "epack" },
			['?'] = { "floor", item = core.ifdiff( 3, nil, "epack" ) },
			['*'] = { "floor", item = core.ifdiff( 4, nil, "epack" ) },

			['A'] = { "floor", being = core.bydiff{ "sergeant", "knight", "mancubus", "revenant" } },
			['B'] = { "floor", being = core.bydiff{ "knight", "mancubus", "revenant", "mancubus" } },

			['1'] = { "floor", item = level:roll_item( lavapits_armor ) },
			['2'] = { "floor", item = level:roll_item( lavapits_armor ) },
			['3'] = { "floor", item = level:roll_item( lavapits_armor ) },
			['4'] = { "floor", item = level:roll_item( lavapits_armor ) },
			['5'] = { "floor", item = level:roll_item( lavapits_armor ) },
			['6'] = { "floor", item = level:roll_item( lavapits_armor ) },
			['7'] = { "floor", item = level:roll_item( lavapits_armor ) },
			['8'] = { "floor", item = level:roll_item( lavapits_armor ) },
			['9'] = { "floor", item = level:roll_item( lavapits_armor ) },
			['0'] = { "floor", item = level:roll_item( lavapits_armor ) },
		}

		local map = [=[
============================================================================
====================================================XXXXXXX===========.|/.==
=================================================XXXX.....XXXX========.&?A==
================================================XXA.........AXX=======.-..==
================================================X..%%%%%%%%%..X========,,===
===============================================XX.%%B..|..B%%.XX=======,,===
==...==========================================X..%/.#####./%..X=======,,===
=.....============================...==========X..%.##154##.%..X=======,,===
=.....===========================..&..,,,,,,,,,X..%.#7-=-9#.%..X,,,,,,,,,===
=..>..===========================..A..,,,,,,,,,X..%.#8B=*0#.%..X,,,,,,,,,===
=.....============================...==========X..%.##362##.%..X=======,,===
==...==========================================X..%/.#####./%..X=======,,===
===============================================XX.%%B..|..B%%.XX=======,,===
================================================X..%%%%%%%%%..X========,,===
================================================XXA.........AXX=======.-..==
=================================================XXXX.....XXXX========.&!A==
====================================================XXXXXXX===========.|/.==
============================================================================
]=]
		generator.place_tile( translation, map, 2, 2 )

		local second = core.bydiff{ "lostsoul", "cacodemon", "cacodemon", "pain" }		
		level:summon{ "lostsoul", 10 + 2*DIFFICULTY, cell = "lava" }
		level:summon{ second,     4  +   DIFFICULTY, cell = "lava" }

		level:player(4,11)
		level.status = 0
	end,

	OnKillAll = function ()
		local result = level.status
		if result < 4 then
			ui.msg("That seems to be all of them... wait! Something is moving there, or is it just lava glow?")
			level:transmute( "cwall", "floor" )
			level.status = 4
			local element = level:summon("lava_elemental")
			element.inv:add( item.new("lava_element") )
		elseif result == 4 then
			ui.msg("Tough son of a bitch... now to get that shiny object he left behind...")
			level.status = 5
		end
	end,

	OnExit = function ()
		local result = level.status
		if result < 4 then
			ui.msg("Better leave, before this thing blows!")
			player:add_history("He decided it was too dangerous.")
		elseif result == 4 then
			ui.msg("There goes my beard... at least I'm still alive.")
			player:add_history("He fled there from the monstrous lava elemental.")
		elseif result == 5 then
			ui.msg("Lava elementals my ass. I don't care.")
			player:add_badge("lava1")
			if core.is_challenge("challenge_aoi") then player:add_badge("lava2") end
			player:add_history("He managed to raise Mt. Erebus completely!")
		end
	end,
}
