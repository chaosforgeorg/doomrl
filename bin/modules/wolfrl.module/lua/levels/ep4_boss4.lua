--[[ Otto's special offers a choice: go straight for him or detour and fight some
     guards for keys.  The keys unlock two stashes, but are they worth it?
--]]

register_level "boss4" {
	name  = "Otto's Barracks",
	entry = "Then at last he reached Otto Giftmacher...",
	welcome = "Otto is here...",

	Create = function ()
		generator.fill( "void", area.FULL )
		generator.fill( "floor", area.new( 10, 2, 54, 19 ) )

		local translation = {
			['.'] = "floor",
			["`"] = "void",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },
			['%'] = "wolf_whwall",
			['F'] = "wolf_whwall", --flair
			['R'] = { "wolf_rewall", flags = { LFPERMANENT } },
			['B'] = { "wolf_blwall", flags = { LFPERMANENT } },
			['&'] = "wolf_brwall",

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },

			['!'] = { "floor", item = "wolf_smed" },
			['*'] = { "floor", item = "wolf_food2" },
			['|'] = { "floor", item = "wolf_9mm" },
			[':'] = { "floor", item = "wolf_8mm" },
			[';'] = { "floor", item = "wolf_kurz" },
			['/'] = { "floor", item = "wolf_rocket" },
			['1'] = { "floor", item = "wolf_key1" },
			['2'] = { "floor", item = "wolf_key2" },
			['7'] = { "floor", item = "wolf_assault2" },
			['8'] = { "floor", item = "wolf_bazooka" },

			["h"] = { "floor", being = "wolf_guard1" },
			["i"] = { "floor", being = "wolf_ss1" },
			["j"] = { "floor", being = "wolf_officer1" },

			["4"] = { "floor", being = core.bydiff{"wolf_guard1", "wolf_ss1", "wolf_officer1", "wolf_fakehitler"} },
			["5"] = { "floor", being = core.bydiff{nil, "wolf_guard1", "wolf_ss1", "wolf_officer1"} },
			["6"] = { "floor", being = core.bydiff{nil, nil, "wolf_guard1", "wolf_ss1"} },
		}

		local map = [[
``````###################BBBBBBBB`````````````````````
``````#%%%%%%%%%%%%%%%%%%B.*|//|B```##################
``````#%%%%%%%%%%%%%%%%%%#=##!8:B``##4.=.......%%%%.h#
```RRRR%%...................#BBBB###45.#.1...........#
```R7;R%%..&&&&.......&&&&..%%%%%%%F56.-.......%%%%..#
``RR;|R%%..&&&&.......&&&&..%%%%%%%#45.#.2.....%%%%..#
``R.:*R%%...................%%%%%%%##4.=.............#
``R.:!R%%..&&&&.......&&&&..%%%%%%%%####%%%%%%+%%%%%%#
###-###%%..&&&&.......&&&&..+...%%%%%%%%%%%%%...%%%###
#%..........................%...%%%%%%%%%%%%%...%%%#``
#%..&&&&............%%%%%%%%%F+F%%%%%%%%%%%%%%+%%%%#``
#%..&&&&............%%%%%%%.......................%#``
#%............&&&&..%%%%%%%.......................%#``
#%............&&&&..%%%%%%%%%F+F%%%%%%%%%%%%%%+%%%%#``
#%..................%%%%%%%.......................%#``
#%%%%%%%%%%%%%%%%%%%%%%%%%%.......................%#``
##########################%.......................%#``
`````````````````````````###########################``
]]
		generator.place_tile( translation, map, 10, 2 )

		level.flags[ LF_NOHOMING ] = true
		level:player(48, 18)
	end,

	OnEnter = function ()
		level.status = 1
	end,

	OnTick = function ()
		if(level.status == 1) then
			local area1 = area.new(coord.new(1,1), coord.new(38,12))
			local area2 = area.new(coord.new(1,1), coord.new(30,18))
			if (area1:contains(player.position) or area2:contains(player.position)) then
				level.status = 2
				level:drop_being("wolf_bossgift",coord.new(11,17))
			end
		end
	end,

	OnKill = function (being)
		if being.id == "wolf_bossgift" then
			--Victory
			if statistics.damage_on_level == 0 then
				player:add_history("He vanquished Otto Giftmacher, bringer of poison war.")
			else
				player:add_history("He defeated Otto Giftmacher, bringer of poison war.")
			end

			player:win()
		end
	end,
}