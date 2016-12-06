--[[ The sixth episode's special has four distinct sections with mazes,
     ghosts, Hans, and keys.  Though not meant to be a reproduction the
     general theme has been kept in this potentially short and bloody level.
--]]

register_level "spec6" {
	name  = "Underground",
	entry = "On level @1 he stumbled into the underground.",
	welcome = "Spooky...",
	level = {6,7},

	canGenerate = function ()
		return CHALLENGE == "challenge_ep6"
	end,

	OnCompletedCheck = function ()
		return level.status > 0
	end,

	OnRegister = function ()

	end,

	Create = function ()

		local left = area.new( 1, 1, 9, 19 )
		local right = area.new( 70, 1, 78, 19 )
		local playerCoord = coord.new( 3, 3 )
		generator.fill( "void", area.FULL )

		--Generate the map...
		local basetranslation = {
			['.'] = "floor",
			[','] = "rock",
			[';'] = "dirt",
			['~'] = "grass1",
			['_'] = "grass2",

			["`"] = "void",
			[">"] = "stairs",
			['3'] = "wolf_dkwall",
			['4'] = "wolf_whwall",
			['2'] = "wolf_grwall",
			['5'] = "wolf_rewall",
			['7'] = "wolf_blwall",
			['#'] = { "wolf_dkwall", flags = { LFPERMANENT } },
			['F'] = { "wolf_dkwall", flags = { LFPERMANENT } },
			['G'] = { "wolf_dkwall", flags = { LFPERMANENT } },
			['$'] = { "wolf_whwall", flags = { LFPERMANENT } },
			['@'] = { "wolf_grwall", flags = { LFPERMANENT } },
			['%'] = { "wolf_rewall", flags = { LFPERMANENT } },
			['&'] = { "wolf_blwall", flags = { LFPERMANENT } },

			['*'] = { "floor", item = "wolf_smed" },
			['|'] = { "floor", item = "wolf_8mm" },
			[':'] = { "floor", item = "wolf_rocket" },
			['('] = { "floor", item = "wolf_key2" },

			["a"] = "floor",
			["A"] = "dirt",
			["b"] = "floor",
			["B"] = "grass1",
			["c"] = "floor",
			["C"] = "grass2",
			["d"] = "floor",

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },
		}
		local gametranslation = {
			['.'] = "floor",
			[','] = "rock",
			[';'] = "dirt",
			['~'] = "grass1",
			['_'] = "grass2",

			["`"] = "void",
			[">"] = "stairs",
			['3'] = "wolf_dkwall",
			['4'] = "wolf_whwall",
			['2'] = "wolf_grwall",
			['5'] = "wolf_rewall",
			['7'] = "wolf_blwall",
			['#'] = { "wolf_dkwall", flags = { LFPERMANENT } },
			['F'] = { "wolf_dkwall", flags = { LFPERMANENT } },
			['G'] = { "wolf_dkwall", flags = { LFPERMANENT } },
			['$'] = { "wolf_whwall", flags = { LFPERMANENT } },
			['@'] = { "wolf_grwall", flags = { LFPERMANENT } },
			['%'] = { "wolf_rewall", flags = { LFPERMANENT } },
			['&'] = { "wolf_blwall", flags = { LFPERMANENT } },

			['*'] = { "floor", item = "wolf_smed" },
			['|'] = { "floor", item = "wolf_8mm" },
			[':'] = { "floor", item = "wolf_rocket" },
			['('] = { "floor", item = "wolf_key2" },

			["a"] = {"floor", being = "pac_blinky", item = "wolf_key1"},
			["A"] = "dirt",
			["b"] = {"floor", being = "wolf_minitrans"},
			["B"] = "grass1",
			["c"] = {"floor", being = "wolf_minigretel"},
			["C"] = "grass2",
			["d"] = {"floor", being = "wolf_minihans"},

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },
		}

		--Handle random adjustments and G-mode changes
		if (string.find(VERSION_STRING, "G")) then
			gametranslation['F'] = { "wolf_flrflag1", flags = { LFPERMANENT } }
		else
			gametranslation['G'] = { "wolf_flrflag2", flags = { LFPERMANENT } }
		end
		if math.random(2) == 1 then
			gametranslation["a"], gametranslation["A"] = gametranslation["A"], gametranslation["a"]
		end
		if math.random(2) == 1 then
			gametranslation["b"], gametranslation["B"] = gametranslation["B"], gametranslation["b"]
		end
		if math.random(2) == 1 then
			gametranslation["c"], gametranslation["C"] = gametranslation["C"], gametranslation["c"]
		end

		local map = [[
``````@@@@@@@@@@@@@@@@@@@@@@@@@@@``````
```@@@@;;;;;;;;;;;;;;;;;;;;;;;;;@@@@```
`%%%2a+;;;;;;;;;;;;;;;;;;;;;;;;;+A2&&&`
%%B~522;;;;;;;;;;;;;;;;;;;;;;;;;227_c&&
%~~~~5522;;;;;;;;;;;;;;;;;;;;;2277____&
%~~~~~~5522;;;;;;;;;;;;;;;;;2277______&
%~~~~~~~~5522;;;;;;;;;;;;;2277________&
%~~~~~~~~~~55223333+33332277__________&
%~~~~~~~~~~~~533.......337____________&
%~~~~~~~~~~~~33..#####..33____________&
%~~~~~~~~~~~~+...G.>.G...+____________&
%~~~~~~~~~~~~33..#F=F#..33____________&
%~~~~~~~~~~~~533.......337____________&
%~~~~~~~~~~55443333+33334477__________&
%~~~~~~~~55444,,,,,,,,,,,44477________&
%~~~~~~55444,,,444444444,,,44477______&
%~~~~55444,,,4444,,d,,4444,,,44477____&
%%b~544444,,,,44,,,,,,,44,,,,444447_C&&
`%%%%$$44444,,,,,,,,,,,,,,,44444$$&&&&`
``````$$$$$$$$$$$$$$$$$$$$$$$$$$$``````
]]
		generator.place_tile( basetranslation, map, 21, 1 )
		generator.place_tile( gametranslation, map, 21, 1 )

		--Generate the mazes.  Yes they are diggable.
		generator.maze_dungeon( "dirt",   "wolf_grwall", 2, 1000, 2,  3, area.FULL )
		generator.maze_dungeon( "grass1", "wolf_rewall", 2, 1000, 3,  5, area.FULL )
		generator.maze_dungeon( "grass2", "wolf_blwall", 2, 1000, 4,  7, area.FULL )

		--Drop beings in the now maze-ified areas
		local drops = {
		                { "dirt", core.bydiff{"wolf_mutant1"} },
		                { "dirt", core.bydiff{"wolf_mutant2"} },
		                { "dirt", core.bydiff{nil, "wolf_mutant1"} },
		                { "dirt", core.bydiff{nil, "wolf_mutant2"} },
		                { "dirt", core.bydiff{nil, nil, "wolf_mutant2"} },
		                { "dirt", core.bydiff{nil, nil, nil, "wolf_mutant2"} },
		                { "grass1", core.bydiff{"wolf_guard1", "wolf_ss1", "wolf_officer1"} },
		                { "grass1", core.bydiff{"wolf_guard1", "wolf_mutant1", "wolf_officer1"} },
		                { "grass1", core.bydiff{nil, "wolf_guard1", "wolf_ss1"} },
		                { "grass1", core.bydiff{nil, "wolf_guard1", "wolf_mutant2"} },
		                { "grass1", core.bydiff{nil, nil, "wolf_guard1", "wolf_ss1"} },
		                { "grass1", core.bydiff{nil, nil, nil, "wolf_guard1"} },
		                { "grass2", core.bydiff{"wolf_guard1", "wolf_ss1", "wolf_officer1"} },
		                { "grass2", core.bydiff{"wolf_guard1", "wolf_guard1", "wolf_ss1", "wolf_officer1"} },
		                { "grass2", core.bydiff{nil, "wolf_guard1", "wolf_ss1"} },
		                { "grass2", core.bydiff{nil, "wolf_guard1", "wolf_guard1", "wolf_ss1"} },
		                { "grass2", core.bydiff{nil, nil, "wolf_guard1"} },
		                { "grass2", core.bydiff{nil, nil, nil, "wolf_guard1"} },
		                { "rock", core.bydiff{"wolf_ss1", "wolf_officer1"} },
		                { "rock", core.bydiff{"wolf_ss1", "wolf_officer1"} },
		                { "rock", core.bydiff{nil, "wolf_ss1", "wolf_officer1"} },
		                { "rock", core.bydiff{nil, nil, "wolf_ss1", "wolf_officer1"} },
		                { "rock", core.bydiff{nil, nil, "wolf_ss1"} },
		                { "rock", core.bydiff{nil, nil, nil, "wolf_ss1"} },
		}
		for _,drop in ipairs(drops) do
			if (drop[2] ~= nil) then
				level:drop_being( drop[2], generator.random_empty_coord( {EF_NOBEINGS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN}, drop[1] ) )
			end
		end

		--Revert the ground tiles that I used to make my life easier.
		generator.transmute("rock",   "floor")
		generator.transmute("dirt",   "floor")
		generator.transmute("grass1", "floor")
		generator.transmute("grass2", "floor")

		--Pop some level data
		level.data.left = false
		level.data.right = false
		level.data.up = false
		level.data.down = false

		--Finish
		level:player(40, 13)
	end,

	OnEnter = function ()

	end,

	OnTick = function ()
		    if (level.data.left  == false and player.position.x < 35) then
			level.data.left = true
		elseif (level.data.right == false and player.position.x > 45) then
			level.data.right = true
		elseif (level.data.up    == false and player.position.y <  9) then
			level.data.up = true
		elseif (level.data.down  == false and player.position.y > 13) then
			level.data.down = true
		end
	end,

	OnPickup = function (item, being)
		--The spear teleports you to the last level.
		if item and item.id == "wolf_key1" and being == player then
			level.status = level.status + 1
		end
	end,

	OnKill = function (being)
		if being.id == "wolf_minihans" or being.id == "wolf_minitrans" or being.id == "wolf_minigretel" then
			--Drop key, which is a powerup and thus must actually be spawned here.
			local key = level:drop_item( "wolf_key1", being.position )
			if (key == nil) then
				--Emergency backup, unlock the doors manually
				items[ "wolf_key1" ].OnPickup(nil, player)
				level.status = level.status + 1
			elseif (key.position ~= being.position) then
				--This ensures the key doesn't get dropped behind a locked door
				local otherItem = level:get_item(being.position)
				if (otherItem ~= nil) then
					otherItem:displace(key.position)
				end
				key:displace(being.position)
			end
		end
	end,

	OnExit = function (being)
		--It is not fair to count the ghost as a missed kill
		for b in level:beings() do
			if (b.id == "pac_blinky") then
				statistics.max_kills = statistics.max_kills - 1
			end
		end

		if statistics.damage_on_level == 0 then
			player:add_history("He escaped without a scratch.")
		elseif level.status > 3 then
			player:add_history("He explored thoroughly and left.")
		elseif level.status > 1 then
			player:add_history("He explored for a bit and left.")
		else
			player:add_history("He left quickly.")
		end
	end,
}
