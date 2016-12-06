--[[ The crypt is just a simple filler level.  Could go anywhere really.
     And since ep1 doesn't really have a theme as far as special levels go
     that makes it a perfect candidate to ease the player in.

     A unique but otherwise weak 'boss' enemy like a mummy might be nice
     if I can find appropriate 'wolf-like' sounds.
--]]

register_level "spec1" {
	name  = "The Catacombs",
	entry = "On level @1 he wandered into the Catacombs.",
	welcome = "Don't touch, never ever steal",
	level = {2,3},

	canGenerate = function ()
		return CHALLENGE == "challenge_ep1"
	end,

	OnCompletedCheck = function ()
		return level.status >= 3
	end,

	OnRegister = function ()
		--Generic level, generic medals.  This can clue the player in to the
		--fact that each episode has two medals since these ones are easy.
		register_medal "tomb1" {
			name  = "Sandstone",
			desc  = "Awarded for investigating the catacombs.",
			hidden  = true,
		}
		register_medal "tomb2" {
			name  = "Candelabra",
			desc  = "Awarded for clearing the catacombs perfectly.",
			hidden  = true,
		}
	end,

	Create = function ()
		level.name = "Crypts of Eternity"
		--level.name = "Thieves"
		level.status = 0
		generator.fill( "void", area.FULL )

		--Generate the map...
		local basetranslation = {
			['.'] = "floor",
			[','] = "floor",

			["`"] = "void",
			[">"] = "stairs",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },
			['&'] = { "wolf_rewall", flags = { LFPERMANENT } },
			['%'] = { "wolf_blwall", flags = { LFPERMANENT } },
			['$'] = { "wolf_grwall", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },

			["@"] = "floor",
		}
		local gametranslation = {
			['.'] = "floor",
			[','] = "floor",

			["`"] = "void",
			[">"] = "stairs",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },
			['&'] = { "wolf_rewall", flags = { LFPERMANENT } },
			['%'] = { "wolf_blwall", flags = { LFPERMANENT } },
			['$'] = { "wolf_grwall", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },

			["@"] = {"floor", being = "wolf_mutant1"}, --temp enemy
		}

		local map = [[
```````````````###############################################```
```````````````#.+............................+..............#```
```````````````#.##############################..............#```
````````````####+####`````````````#########```#...####.......#```
########````#.......#`````````````#.......#```#...#``#.......#```
#......######......`###############.......#```#...####...#####```
#.>....+............+.............+.......#```#..........#```````
#......+............+.............+.......#```#..........#```````
#......######.......###############.......#```#+##########```````
########````#.......#`````````````#.......#```#.#````````````````
````````````####+####`````````````#########```#.#````````````````
```````````````#.#```#####`#####`#####`#####`##+##```````````````
```````````````#.#```#...#`#...#`#...#`#...#`#...#```````````````
`````````````###+#####...###...###...###...###...###````````#####
`````````````#.....#...............................##########...#
`````````````#.....+...............................+........+.@.#
`````````````#.....#...............................##########...#
`````````````#########...###...###...###...###...###````````#####
`````````````````````#...#`#...#`#...#`#...#`#...#```````````````
`````````````````````#####`#####`#####`#####`#####```````````````
]]
		generator.place_tile( basetranslation, map, 7, 1 )
		generator.place_tile( gametranslation, map, 7, 1 )

		level:player(10, 8)
	end,

	OnEnter = function ()

	end,

	OnTick = function ()

	end,

	OnKill = function ()
		if level.status < 1 then
			level.status = level.status + 1
		end
	end,

	OnKillAll = function ()
		level.status = level.status + 1
	end,

	OnExit = function (being)
		level.status = level.status + 1

		if level.status == 3 and statistics.damage_on_level == 0 then
			player:add_history("He came in looking for the kill.")
		elseif level.status == 3 then
			player:add_history("He cleaned the place out.")
		elseif level.status == 2 then
			player:add_history("He poked around for a bit and then left.")
		else
			player:add_history("He marched right back out.")
		end

		if (level.status == 3) then player:add_medal("tomb1") end
		if (level.status == 3 and statistics.damage_on_level == 0) then player:add_medal("tomb2") end
	end,
}
