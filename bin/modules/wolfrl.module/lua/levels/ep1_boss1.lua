--[[ The boss level for Wolfenstein is embarrasingly straightforward.
     Here's Hans Grosse.  Go kill him.  Of course it's just as simple
     in the real game.
--]]

register_level "boss1" {
	name  = "Great Hall",
	entry = "Then at last he reached the exit...",
	welcome = "The way out is through.",

	Create = function ()
		generator.fill( "grass1", area.FULL )

		local translation = {
			['.'] = "floor",
			["`"] = "grass1",
			['#'] = { "wolf_rewall", flags = { LFPERMANENT } },
			['$'] = "wolf_rewall",
			['&'] = { "wolf_whwall", flags = { LFPERMANENT } },
			['%'] = "wolf_whwall",

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },

			['*'] = { "floor", item = "wolf_smed" },
			['|'] = { "floor", item = "wolf_9mm" },
		}

		local map = [[
````````````###########################################````````````
````````````#.........................................#````````````
````````#####...%%......%%......%%......%%......%%....#````````````
````````#|.....%%%%....%%%%....%%%%....%%%%....%%%%...#````````````
#####```#.......%%......%%......%%......%%......%%....#`###`#######
#*.|#####.............................................###.###.....#
#.......+...................................................+.....=
#*.|#####.............................................###.###.....#
#####```#.......%%......%%......%%......%%......%%....#`###`#######
````````#|.....%%%%....%%%%....%%%%....%%%%....%%%%...#````````````
````````#####...%%......%%......%%......%%......%%....#````````````
````````````#.........................................#````````````
````````````###########################################````````````
]]
		generator.place_tile( translation, map, 5, 5 )
		generator.scatter( area.FULL,"grass1","grass2", 500)

		level.flags[ LF_NOHOMING ] = true
		level:player(6, 11)
	end,

	OnEnter = function ()
		level.status = 1
	end,

	OnTick = function ()
		if(level.status <= 500) then
			if (player.position.x > 58 or level.status == 500) then
				level.status = 501
				level:drop_being("wolf_bosshans",coord.new(68,11))
			else
				level.status = level.status + 1
			end
		end

		--This exists in order to get that neato running out 'Yeah!' effect that players love.
		if(player.position.x > 73) then

			--OnExit hooks don't fire when the level ends the game.
			if statistics.damage_on_level == 0 then
				player:add_history("He walked out of Castle Wolfenstein like he owned it.")
			else
				player:add_history("He escaped from Castle Wolfenstein.")
			end

			player:play_sound("soldier.yeah")
			player:win()
		end
	end,

	OnKill = function (being)
		if being.id == "wolf_bosshans" then
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