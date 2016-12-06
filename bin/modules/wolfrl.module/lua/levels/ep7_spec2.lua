--[[ The vault will have treasure and other rocketable items.  Since the player
     won't have phases yet they will have to rocket the vaults until they crack.
     But how do we clue the player in to which (random) sections are vulneurable?
     A riddle?  Math?  Blood spatter?  At first I thought of using very subtle
     cell differences but that would be quickly defeated by a trip to the wiki.
     Now I'm leaning towards time based reasoning.
--]]

register_level "vault" {
	name  = "The Vaults",
	entry = "On level @1 he discovered the Vaults.",
	welcome = "How to get in?",
	level = {7,8},

	canGenerate = function ()
		return not DoomRL.isepisode()
	end,

	OnCompletedCheck = function ()
		return level.status >= 2 --Getting into the middle is fine by me
	end,

	OnRegister = function ()

	end,

	Create = function ()

		generator.fill( "void", area.FULL )

		--The different characters aren't actually used, I just like the handy markers.
		local basetranslation = {
			['.'] = "floor",
			['~'] = "floor",

			["+"] = "floor",
			["="] = "floor",
			["-"] = "floor",

			['*'] = "floor",
			['|'] = "floor",
			[':'] = "floor",

			["`"] = "void",
			[">"] = "stairs",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },
			['X'] = { "wolf_whwall", flags = { LFPERMANENT } },
		}
		local gametranslation = {
			['.'] = "floor",
			['~'] = "floor",

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },

			['*'] = { "floor", item = "wolf_smed" },
			['|'] = { "floor", item = "wolf_9mm" },
			[':'] = { "floor", item = "wolf_8mm" },

			["`"] = "void",
			[">"] = "stairs",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },
			['X'] = { "wolf_whwall", flags = { LFPERMANENT } },
		}

		local map = [[
````````#############````````##################````````#############````````
```````##.....~~....##``````##................##``````##....~~.....##```````
``````##...###XX###..##````##..XXXXXXXXXXXXXX..##````##..###XX###...##``````
`````##~..####XX####.~##``##..XXXXXXXXXXXXXXXX..##``##~.####XX####..~##`````
````##~..X##......##X.~####..XXX............XXX..####~.X##......##X..~##````
```##...XXX........XXX..##..XXX..............XXX..##..XXX........XXX...##```
``##...##X..........X##....XXX................XXX....##X..........X##...##``
`##...###............###..XXX.......####.......XXX..###............###...##`
`#.>~.XX......##......XX~.XX.......##``##.......XX.~XX......##......XX.~..#`
`#..~.XX......##......XX~.XX.......##``##.......XX.~XX......##......XX.~..#`
`##...###............###..XXX.......####.......XXX..###............###...##`
``##...##X..........X##....XXX................XXX....##X..........X##...##``
```##...XXX........XXX..##..XXX..............XXX..##..XXX........XXX...##```
````##~..X##......##X.~####..XXX............XXX..####~.X##......##X..~##````
`````##~..####XX####.~##``##..XXXXXXXXXXXXXXXX..##``##~.####XX####..~##`````
``````##...###XX###..##````##..XXXXXXXXXXXXXX..##````##..###XX###...##``````
```````##.....~~....##``````##................##``````##....~~.....##```````
````````#############````````##################````````#############````````
]]
		generator.place_tile( basetranslation, map, 2, 2 )
		generator.place_tile( gametranslation, map, 2, 2 )

		--Now work out the left/right vault entrances.
		local tempentry = nil
		local vault1 = math.random(8)
		local vault2 = math.random(8)

		level.data.ticks = 0
		level.data.hint = false
		level.data.access = false
		level.data.left =  { { area.new(16,  4, 17,  5), },
		                     { area.new(21,  7, 23,  7), area.new(22,  6, 22,  8), },
		                     { area.new(24, 10, 25, 11), },
		                     { area.new(21, 14, 23, 14), area.new(22, 13, 22, 15), },
		                     { area.new(16, 16, 17, 17), },
		                     { area.new(10, 14, 12, 14), area.new(11, 13, 11, 15), },
		                     { area.new( 8, 10,  9, 11), },
		                     { area.new(10,  7, 12,  7), area.new(11,  6, 11,  8), },
		                   }
		level.data.right = { { area.new(62,  4, 63,  5), },
		                     { area.new(67,  7, 69,  7), area.new(68,  6, 68,  8), },
		                     { area.new(70, 10, 71, 11), },
		                     { area.new(67, 14, 69, 14), area.new(68, 13, 68, 15), },
		                     { area.new(62, 16, 63, 17), },
		                     { area.new(56, 14, 58, 14), area.new(57, 13, 57, 15), },
		                     { area.new(54, 10, 55, 11), },
		                     { area.new(56,  7, 58,  7), area.new(57,  6, 57,  8), },
		                   }
		level.data.leftblood =  { { coord.new(16, 3), coord.new(17, 3), },
		                          { coord.new(23, 5), coord.new(24, 6), },
		                          { coord.new(26,10), coord.new(26,11), },
		                          { coord.new(24,15), coord.new(23,16), },
		                          { coord.new(16,18), coord.new(17,18), },
		                          { coord.new( 8,15), coord.new( 9,16), },
		                          { coord.new( 7,10), coord.new( 7,11), },
		                          { coord.new( 9, 5), coord.new( 8, 6), },
		                        }
		level.data.rightblood = { { coord.new(62, 3), coord.new(63, 3), },
		                          { coord.new(70, 5), coord.new(71, 6), },
		                          { coord.new(72,10), coord.new(72,11), },
		                          { coord.new(71,15), coord.new(70,16), },
		                          { coord.new(62,18), coord.new(63,18), },
		                          { coord.new(55,15), coord.new(56,16), },
		                          { coord.new(53,10), coord.new(53,11), },
		                          { coord.new(56, 5), coord.new(55, 6), },
		                        }
		level.data.center1 = area.new(29,  8, 50, 13)
		level.data.center2 = area.new(33,  4, 46, 17)
		level.data.centerwalls = area.new(27,  3, 52, 18)

		tempentry = level.data.left[vault1]
		for i=1,#tempentry do
			level.light[tempentry[i]][LFPERMANENT] = false
		end
		tempentry = level.data.right[vault2]
		for i=1,#tempentry do
			level.light[tempentry[i]][LFPERMANENT] = false
		end

		tempentry = level.data.leftblood[vault1]
		level.light[table.random_pick(tempentry)][LFBLOOD] = true
		tempentry = level.data.rightblood[vault2]
		level.light[table.random_pick(tempentry)][LFBLOOD] = true


		level:player(4,11)
		level.status = 0
	end,

	OnEnter = function ()

	end,

	OnTick = function ()
		level.data.ticks = level.data.ticks + 1

		--Do they need a hint?
		if (level.data.hint == false and level.data.access == false and level.data.ticks > 3000 and player.x > 25 and player.x < 54) then
			level.data.hint = true
			ui.msg("Maybe it's a time lock.")
		end

		--Are they in the main vault?
		if (level.data.access == false and (level.data.center1:contains(player.position) or level.data.center2:contains(player.position))) then
			level.data.access = true
			level.status = level.status + 2
		end

		--Rotate the vault door, plonker (not too often though, that's annoying)
		if (level.data.ticks % 30 == 0) then
			--Clear the old vulneurable cells
			generator.set_permanence( level.data.centerwalls, true, "wolf_whwall" )

			--Degrees start at 3:00 and rotate counter, must adjust
			local curdate = statistics.get_date()
			local radians = math.rad( 90 - ((curdate.minute * 60 + curdate.second) / 10) )
			--Do not use coords.  Those are int based and we need decimals.
			local tmp_center = { x = 39.5, y = 10.5 }
			local tmp_vector = { x = math.cos(radians), y = -math.sin(radians) }

			local tmp_adjust = 1.0 / math.max(math.abs(tmp_vector.x), math.abs(tmp_vector.y))
			tmp_vector.x = tmp_vector.x * tmp_adjust
			tmp_vector.y = tmp_vector.y * tmp_adjust

			local next_coord
			local tmp_scalar = 4
			while (true) do
				--Pascal rounds .5 to the nearest even (lunacy I might add).  Do a standard round in code.
				next_coord = coord.new(math.floor(0.5 + tmp_center.x + (tmp_vector.x * tmp_scalar)), math.floor(0.5 + tmp_center.y + (tmp_vector.y * tmp_scalar)))
				if (not level.data.centerwalls:contains(next_coord)) then
					next_coord = nil
					break
				elseif (level.map[ next_coord ] == "wolf_whwall") then
					break
				end

				tmp_scalar = tmp_scalar + 1
			end

			if (next_coord) then
				--Make the break in the wall
				if (generator.cross_around( next_coord, "wolf_whwall" ) == 4) then
					level.light[area.new(next_coord.x-1, next_coord.y, next_coord.x+1, next_coord.y)][LFPERMANENT] = false
					level.light[area.new(next_coord.x, next_coord.y-1, next_coord.x, next_coord.y+1)][LFPERMANENT] = false
				else
					local ar
					while true do --Loop exists solely so that I can use 'break' as a goto
						ar = area.new (next_coord.x-1, next_coord.y-1, next_coord.x, next_coord.y)
						if generator.scan(ar,"wolf_whwall") then break end
						ar = area.new (next_coord.x, next_coord.y-1, next_coord.x+1, next_coord.y)
						if generator.scan(ar,"wolf_whwall") then break end
						ar = area.new (next_coord.x-1, next_coord.y, next_coord.x, next_coord.y+1)
						if generator.scan(ar,"wolf_whwall") then break end
						ar = area.new (next_coord.x, next_coord.y, next_coord.x+1, next_coord.y+1)
						break --Doesn't matter if it's not a complete square, we should flag at least one cell
					end

					level.light[ar][LFPERMANENT] = false
				end
			end
		end
	end,

	OnKillAll = function ()
		level.status = level.status + 1
	end,

	OnExit = function (being)
		local result = level.status

		if result == 0 then
			player:add_history("He came, he saw, but he left.")
		elseif result == 1 then
			player:add_history("He managed to scavenge a part of the Vault's treasures.")
		elseif result == 2 then
			player:add_history("He cracked the main vault and cleared it out.")
		elseif result >= 3 then
			if statistics.damage_on_level == 0 then
				player:add_history("He ghosted the vaults flawlessly.")
			else
				player:add_history("He managed to clear the Vaults completely!")
			end
		end

		level.status = level.status + 2
	end,
}
