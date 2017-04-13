--[[ This level sucks but the below is all I have right now.
--]]

register_level "spear2" {
	name  = "Dungeon Boss",
	entry = "Guarding the dungeon was Barnacle Wilhelm!",
	welcome = "Almost out of these dungeons...",

	Create = function ()
		generator.fill( "void", area.FULL )
		generator.fill( "floor", area.new( 8, 3, 76, 18 ) )

		local translation = {
			['.'] = "floor",
			["`"] = "void",
			[">"] = "stairs",
			['#'] = { "wolf_blwall", flags = { LFPERMANENT } },
			['&'] = "wolf_blwall",
			['$'] = { "wolf_rewall", flags = { LFPERMANENT } },
			['%'] = "wolf_rewall",

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },

			['*'] = { "floor", item = "wolf_smed" },
			['|'] = { "floor", item = "wolf_8mm" },
			[':'] = { "floor", item = "wolf_rocket" },
			['('] = { "floor", item = "wolf_key2" },

			["a"] = {"floor", being = "wolf_guard1"},
			["b"] = {"floor", being = "wolf_dog1"},
			["c"] = {"floor", being = "wolf_ss1"},
			["d"] = {"floor", being = "wolf_officer1"},
			["@"] = {"floor", being = "wolf_bossbarney"},

			["1"] = {"floor", being = core.bydiff{nil, "wolf_guard1"}},
			["2"] = {"floor", being = core.bydiff{nil, nil, "wolf_guard1"}},
			["3"] = {"floor", being = core.bydiff{nil, nil, nil, "wolf_guard2"}},
			["4"] = {"floor", being = core.bydiff{nil, "wolf_guard1", "wolf_ss1"}},
			["5"] = {"floor", being = core.bydiff{nil, nil, "wolf_ss1"}},
			["6"] = {"floor", being = core.bydiff{nil, nil, nil, "wolf_ss2"}},
			["7"] = {"floor", being = core.bydiff{nil, "wolf_guard1", "wolf_ss1", "wolf_officer1"}},
			["8"] = {"floor", being = core.bydiff{nil, nil, "wolf_ss1", "wolf_officer1"}},
			["9"] = {"floor", being = core.bydiff{nil, nil, nil, "wolf_officer2"}},

			["x"] = "bones1",
			["y"] = "bones2",
			["z"] = { "bones1", flags = { LFBLOOD } },
		}

		local map = [[
################################$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#&&&&&&&&a.........&&#*.......*#%%%%%%.+.4%%%....8%%%|..%%%%%%%bc%%$
#&&&&&....&&........&#2.&...&.a#.......%%.....%%%.%%%.%.%%%%%....(%$
#&&&...7&&&&.2&&&&..&#&&&...&&&#.......%%%%%%%%%%.....%.%%%%..3...%$
#&&&...&&&&..&&&&&..&#&&.....&&#.......%%%%...%%%%%%%%%.%%%%.....%%$
#&&&...&&&..6&&&&....#.........#.......+.%%5%.....7..%%+%%%%...%%%%$
#@-...c&&&|..........-.........+.......%.1..%%%%%%%%.%%...2.......%$
#&&&...&&&...........#.........#+%%%+%%%%%%%%%%%%%%%+%.....%......*$
#&&&...&&&&.&&&&&...############.%%%.%%%%%%%%%%%%%%%.......%.......$
#&&&:..&&&&.&&&&&&..#.>.+..:&##$.%%%.......c%%c....+...%%%%%%%%%.1.$
#&&&&..&&&&..3&&&&.&###&&...&&#$.%%%%%%%%%%....%%%%%.......%.......$
#&&&&..9&&.....&&&.&&###&...&&#$.%%%....:%%%%%%%%%%%.......%......*$
#&&&&.......&&.......&#.....&&#$.%%%.%%%.%%%%%..2%.+....5.........%$
#&&&d......5&&........=.....&&#$.%%%.%%%.%%%%%7%.%.%%...........%%%$
#&&&&&&..............&##&&&&&##$.....%%%..2....%...%%%%%%%%%%%%%%%%$
###############################$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
]]
		generator.place_tile( translation, map, 8, 3 )

		level.flags[ LF_NOHOMING ] = true
		level:player(34, 5)
	end,

	--OnPickup = function (item, being)
	--	if item and item.id == "wolf_key2" then
	--		level:drop_being("wolf_bossbarney",coord.new(9,9))
	--	end
	--end,

	OnKill = function (being)
		if being.id == "wolf_bossbarney" then
			--Drop key, which is a powerup and thus must actually be spawned here.
			local key = level:drop_item( "wolf_key1", being.position )
			if (key == nil) then
				--Emergency backup, unlock the doors manually
				items[ "wolf_key1" ].OnPickup(nil, player)
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

	OnExit = function ()
		if statistics.damage_on_level == 0 then
			player:add_history("He eliminated Barnacle Wilhelm without difficulty.")
		else
			player:add_history("He eliminated Barnacle Wilhelm.")
		end
	end,
}