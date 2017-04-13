--[[ This level is a basic introduction to our five level boss routine.
     Trans is not difficult and this level is not complicated.  It also
     serves as a de facto 'You get chaingun here' marker; the chaingun
     is actually a rather BAD weapon but if you're stuck with a pistol
     or mp40 and you run into a heavily armored rifler it's your best bet.
--]]

register_level "spear1" {
	name  = "Tunnel Boss",
	entry = "Leaving the tunnels he ran into Trans Grosse...",
	welcome = "You're almost in...",

	Create = function ()
		generator.fill( "void", area.FULL )
		generator.fill( "floor", area.new( 8, 3, 72, 17 ) )

		local translation = {
			['.'] = "floor",
			["`"] = "void",
			[">"] = "stairs",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },
			['$'] = { "wolf_whwall", flags = { LFPERMANENT } }, --Todo: flarify special levels
			['&'] = "wolf_whwall",
			['%'] = "wolf_whwall", --flair

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
			["@"] = {"floor", being = "wolf_bosstrans"},

			["1"] = {"floor", being = core.bydiff{nil, "wolf_guard1"}},
			["2"] = {"floor", being = core.bydiff{nil, nil, "wolf_guard1"}},
			["3"] = {"floor", being = core.bydiff{nil, nil, nil, "wolf_guard1"}},
			["4"] = {"floor", being = core.bydiff{nil, "wolf_guard1", "wolf_ss1"}},
			["5"] = {"floor", being = core.bydiff{nil, nil, "wolf_ss1"}},
			["6"] = {"floor", being = core.bydiff{nil, nil, nil, "wolf_ss1"}},
			["7"] = {"floor", being = core.bydiff{nil, "wolf_guard1", "wolf_ss1", "wolf_officer1"}},
			["8"] = {"floor", being = core.bydiff{nil, nil, "wolf_ss1", "wolf_officer1"}},
			["9"] = {"floor", being = core.bydiff{nil, nil, nil, "wolf_officer1"}},

			["x"] = "bones1",
			["y"] = "bones2",
			["z"] = { "bones1", flags = { LFBLOOD } },
		}

		local map = [[
````````````````````````````##########```````````````````````````
````````````````````````````#.2&.1&.a#```####$##$####````````````
````````````````````````````#..&..&..#`###..........###``````````
#############################..&..&..###c............a##`````````
#.2.b.a....................&.........1-...&&&....&&&...########``
#6&&&&&...&&&&&&&+&&&+&&&+&&..........&...&&.....3&&.........6$``
#.&*..&...&4.|&.......................%.......&&............#=###
#d&...+...%:c.+...................(...-...2..&&&&..5..&&&&.@=.+>#
#.&*..&...&4.|&.......................%.......&&............#=###
#6&&&&&...&&&&&&&+&&&+&&&+&&..........&...&&.....3&&.........6$``
#.2.b.a....................&.........1-...&&&....&&&...########``
#############################..&..&..###c............a##`````````
````````````````````````````#..&..&..#`###..........###``````````
````````````````````````````#.2&.1&.a#```####$##$####````````````
````````````````````````````##########```````````````````````````
]]
		generator.place_tile( translation, map, 8, 3 )

		level.flags[ LF_NOHOMING ] = true
		level:player(12, 10)
	end,

	--OnPickup = function (item, being)
	--	if item and item.id == "wolf_key2" then
	--		level:drop_being("wolf_bosstrans",coord.new(67, 10))
	--	end
	--end,

	OnKill = function (being)
		if being.id == "wolf_bosstrans" then
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
			player:add_history("He dispatched Trans Grosse with ease.")
		else
			player:add_history("He dispatched Trans Grosse.")
		end
	end,
}