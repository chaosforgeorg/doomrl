-- HELL'S ARMORY --------------------------------------------------------

register_level "hells_armory"
{
	name  = "Hell's Armory",
	entry = "On level @1 he entered Hell's Armory.",
	level = 9,
	welcome = "You enter Hell's Armory.",

	canGenerate = function ()
		return DIFFICULTY > 1
	end,

	OnCompletedCheck = function ()
		return level.status > 1
	end,


	OnRegister = function ()

		register_item "lever_spec3"
		{
			name   = "lever",
			color  = MAGENTA,
			sprite = SPRITE_LEVER,
			weight = 0,
			type   = ITEMTYPE_LEVER,
			flags  = { IF_NODESTROY },

			good = "dangerous",
			desc = "opens the lab",

			color_id = false,

			OnUse = function(self,being)
				if level.status > 0 then return true end
				for x = 6,7 do
					for y = 9,11 do
						level.map[ coord.new(x,y) ] = "floor"
						level.light[ coord.new(x,y) ][ LFBLOOD ] = true
					end
				end
				local b = level:drop_being("shambler",coord.new(6,10))
				level.status = 1
				if b then
					b:play_sound("act")
				end
				ui.msg("You hear a loud wail!")
				return true
			end,
		}
	end,


	Create = function ()
		level:set_generator_style( 1 )
		level:fill( "plava" )

		local special = drl.get_special_item( player.name )
		if not special then 
			special = level:roll_item{ level = 15, type = ITEMTYPE_RANGED, reqs = { is_special = true } }
		end

		local mod1,mod2 = generator.roll_pair{"mod_power","mod_agility","mod_bulk","mod_tech"}
		local translation = {
			['.'] = "floor",
			[','] = { "floor", flags = { LFBLOOD } },
			['#'] = "wall",
			['X'] = "rwall",
			['+'] = "door",
			['>'] = "stairs",
			['='] = "lava",
			['h'] = { "floor", being = core.bydiff{"former", "former", "sergeant", "captain"} },
			['H'] = { "floor", being = core.bydiff{"former", "sergeant", "sergeant", "commando"} },
			['G'] = { "floor", being = "captain" },
			['i'] = { "floor", being = "imp" },
			['c'] = { "floor", being = core.bydiff{"demon", "demon", "cacodemon", "baron"} },
			['A'] = { "floor", being = core.ifdiff( 4, "revenant", "arachno" ) },

			['&'] = { "floor", item = "lever_spec3" },
			['!'] = { "floor", item = "scglobe" },
			['1'] = { "floor", item = "ammo" },
			['2'] = { "floor", item = "shell" },
			['3'] = { "floor", item = "rocket" },
			['4'] = { "floor", item = "cell" },
			['5'] = { "floor", item = "pammo" },
			['6'] = { "floor", item = "pshell" },
			[']'] = { "floor", item = "garmor" },
			['['] = { "floor", item = "barmor" },
			['U'] = { "floor", item = level:roll_item{ level = 15, type = ITEMTYPE_RANGED } },
			['I'] = { "floor", item = special },
			['O'] = { "floor", item = level:roll_item{ level = 15, type = ITEMTYPE_RANGED, unique_mod = 6 } },
			['P'] = { "floor", item = level:roll_item{ level = 15, type = ITEMTYPE_RANGED } },
			['{'] = { "floor", item = mod1 },
			['}'] = { "floor", item = mod2 },
		}

		local map = [=[
============================================================================
============================================================================
============================================================================
==================..........=========================....XXXXXX=============
===============....#######..#########.=====..XXXXXXXXX..iX5..6XXXXXXX=======
==========.........#..h..#.h#..h....#H.===...X2.1.2.1X...X..c.X4.4.4X...====
=#####==...........#.....#..#....G..#..==....X.2.A.2.X...X....X.4.4.Xi....==
=#####.............###+###..###+#####..==....XXXX+XXXX...XXX+XXXXX+XX...,,,=
!#####..................................................................,&,=
=#####......#########+####..######+##..==....XXXX+XXXX...XXXXXXX+XXXX...,,,=
=#####=..>..#11H..#......#..#..G....#.G==..i.X3c.A..3X..iX..........X..i.===
=======.....#.....+......#..#....H..#..==....X3{3.3}3X...X[[.c...c]]X.....==
======......#11..h#.h....#..#########.====...XXXXXXXXX...X[[.UIOP.]]X....===
======......##############...........======..............XXXXXXXXXXXX..=====
===========.................=========================................=======
============================================================================
============================================================================
============================================================================
]=]
		generator.place_tile( translation, map, 2, 2 )
		generator.set_permanence( area.new( 3,8,7,12 ) )

		if DIFFICULTY > 3 then
			level:summon{ "cacodemon", 6 + DIFFICULTY, cell = "lava" }
		else
			level:summon{ "lostsoul", 8 + DIFFICULTY, cell = "lava" }
		end

		level:player(11,10)
	end,

	OnKillAll = function ()
		if level.status == 1 then
			level.status = 2

			player:add_medal("armory1")
			if statistics.damage_on_level == 0 then
				player:add_medal("armory2")
				if player_data.count('player/medals/medal[@id="armory1"]') > 0 then
					player:remove_medal("armory1")
				end
			end

			ui.msg("The lab cache opens.")
			for x = 4,5 do
				for y = 9,11 do
					level.map[ coord.new(x,y) ] = "floor"
				end
			end
			player:play_sound("lever.use")

			local unknown = { {}, {}, {} }

			local lvl = math.max( DIFFICULTY - 3, 0 )
			if math.random(10) == 1 then lvl = lvl + 1 end
			if math.random(10) == 1 then lvl = lvl + 1 end

			local reward1 = table.random_pick{ "umod_sniper","umod_firestorm","umod_nano","umod_onyx" }
			local reward2 = table.random_pick{ "mod_power","mod_agility","mod_bulk","mod_tech","ucarmor"}

			if player:has_medal("armory2") then
				if reward1 == "umod_nano" then
					reward2 = "umod_onyx"
				else
					reward2 = "umod_nano"
				end
			end

			level:drop_item(reward1,coord.new(4,9))
			level:drop_item(reward2,coord.new(4,11))

			local rewards = weight_table.new{}
			for k,ma in ipairs(mod_arrays) do
				if ma.level <= lvl then
					if player_data.count('player/assemblies/assembly[@id="'..ma.id..'"]') == 0 and not player:has_assembly(ma.id) then
						rewards:add( items["schematic_"..ma.level] )
						table.insert( unknown[ma.level+1], ma.nid )
					end
				end
			end

			if rewards:size() > 0 then
				local special = rewards:roll()
				local item    = level:drop_item(special.id,coord.new(4,10))
				item.ammo = table.random_pick(unknown[special.slevel+1])
				item.name = mod_arrays[ item.ammo ].name.." schematics"
			end
		end
	end,

	OnEnter = function ()
		level.status = 0
		ui.msg_feel("You hear the sounds of heavy machinery.")
	end,

	OnExit = function ()
		local result = level.status
			if player.nuketime > 1 then
			ui.msg("Cleansed with fire.")
			player:add_history( "He decided to nuke Hell's production center." )
		elseif result == 0 then
			ui.msg("Let it lie, that which is eternally dead...")
			player:add_history("He left the Armory without drawing too much attention.")
		elseif result == 1 then
			ui.msg("This is madness!")
			player:add_history("He fled being chased by a nightmare!")
		else
			ui.msg("Gotta love the craft...")
			player:add_history("He destroyed the evil within and reaped the rewards!")
		end
	end,

}
