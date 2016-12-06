--[[ This level is similar to the Hans special level, just with a few more enemies.
     Rather than create another run + escape ending condition I decided that killing
     all of the officers should be the victory condition.  I mean, if the opportunity
     presented itself why wouldn't you?
--]]

register_level "boss5" {
	name  = "War Conference",
	entry = "Then at last he found the meeting room...",
	welcome = "Beware the giantess guardian!",

	Create = function ()
		generator.fill( "void", area.FULL )
		generator.fill( "floor", area.new( 10, 2, 70, 19 ) )

		local tab1 = table.shuffle{ core.bydiff{nil, "wolf_guard1"}, core.bydiff{nil, nil, "wolf_guard1"}, core.bydiff{nil, nil, nil, "wolf_guard1"}}
		local tab2 = table.shuffle{ core.bydiff{nil, "wolf_ss1"},    core.bydiff{nil, nil, "wolf_ss1"},    core.bydiff{nil, nil, nil, "wolf_ss1"}}

		local translation = {
			['.'] = "floor",
			["`"] = "void",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },
			['X'] = "wolf_whwall",
			['&'] = "wolf_brwall",

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },

			['!'] = { "floor", item = "wolf_smed" },
			['|'] = { "floor", item = "wolf_9mm" },
			[':'] = { "floor", item = "wolf_8mm" },

			["h"] = { "floor", being = "wolf_guard1" },
			["j"] = { "floor", being = "wolf_officer1" },

			["1"] = {"floor", being = tab1[1] },
			["2"] = {"floor", being = tab2[1] },
			["3"] = {"floor", being = tab1[2] },
			["4"] = {"floor", being = tab2[2] },
			["5"] = {"floor", being = tab1[3] },
			["6"] = {"floor", being = tab2[3] },
		}

		local map = [[
```````````````````###########################```````````````
```````````````````#...j........j........j...#```````````````
```````````````````#..j......j.....j......j..#```````````````
```````````````````#.j.....................j.#```````````````
```````````````````#.........................#```````````````
``##############################=############################
`##|........+......................................X..|.....#
`#...21XXXXXX......................................+....XX:.#
`#..XXXXXh.......&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&....XX..XXXX.#
##+XXX.:X...........................................X..:XX..#
#...X...X.................&&&......&&&......&&&.....XX.....!#
#!..+4.3+.................&&&......&&&......&&&......XXXXXXX#
#...X...X.................&&&......&&&......&&&.....XX.....!#
##+XXX.:X...........................................X..:XX..#
`#..XXXXXh.......&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&....XX..XXXX.#
`#...56XXXXXX......................................+....XX:.#
`##|........+......................................X..|.....#
``###########################################################
]]
		generator.place_tile( translation, map, 10, 2)

		level.flags[ LF_NOHOMING ] = true
		level:player(11, 13)
	end,

	OnEnter = function ()
		level.status = 1

		--The officers in the meeting are unarmed, heh
		for b in level:beings() do
			if (b.id == "wolf_officer1") then
				b.inv:clear()
				b.eq:clear()
			end
		end
	end,

	OnTick = function ()
		if(level.status <= 500) then
			if (player.position.x > 54 or level.status == 500) then
				level.status = 501
				level:drop_being("wolf_bossgretel",coord.new(62,13))
			else
				level.status = level.status + 1
			end
		end
	end,

	OnKill = function (being)
		if being.id == "wolf_officer1" then
			local foundOfficer = false
			for b in level:beings() do
				if (b.id == "wolf_officer1" and b ~= being) then
					foundOfficer = true
					break
				end
			end

			if foundOfficer == false then
				--OnExit hooks don't fire when the level ends the game.
				if statistics.damage_on_level == 0 then
					player:add_history("He infiltrated the meeting like a ghost")
				else
					player:add_history("He assainated everyone at the meeting")
				end

				player:play_sound("soldier.yeah")
				player:win()
			end
		end
		if being.id == "wolf_bossgretel" then
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
}
