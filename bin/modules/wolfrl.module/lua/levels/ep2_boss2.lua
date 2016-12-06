--[[ The boss level for Schabbs is similarly straightforward.
     Schabbs is meant to be pretty easy; there are some
     token mutants to cause you some hassle but overall
     the level's more about ambience.
--]]

register_level "boss2" {
	name  = "Schabbs' Laboratory",
	entry = "Then at last he reached the laboratory...",
	welcome = "Schabbs is near. Eliminate him!",

	Create = function ()
		generator.fill( "void", area.FULL )

		local basetranslation = {
			['.'] = "floor",
			["`"] = "void",
			['#'] = { "wolf_cywall", flags = { LFPERMANENT } },
			['$'] = { "wolf_cywall", flags = { LFPERMANENT } },
			['%'] = { "wolf_cywall", flags = { LFPERMANENT } },
			['&'] = "wolf_cywall",
			['O'] = "floor",

			["+"] = "floor",
			["="] = "floor",
			["-"] = "floor",

			['*'] = "floor",
			['|'] = "floor",
			[':'] = "floor",

			["M"] = "floor",
			["Z"] = "floor",

			["1"] = "floor",
			["2"] = "floor",
			["3"] = "floor",
			["4"] = "floor",
			["5"] = "floor",
			["6"] = "floor",
		}
		local gametranslation = {
			['.'] = "floor",
			["`"] = "void",
			['#'] = { "wolf_cywall", flags = { LFPERMANENT } },
			['$'] = { "wolf_cywall", flags = { LFPERMANENT } },
			['%'] = { "wolf_cywall", flags = { LFPERMANENT } },
			['&'] = "wolf_cywall",
			['O'] = { "pillar", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "mdoor1", flags = { LFPERMANENT } },
			["-"] = { "mdoor2", flags = { LFPERMANENT } },

			['*'] = { "floor", item = "wolf_smed" },
			['|'] = { "floor", item = "wolf_9mm" },
			[':'] = { "floor", item = "wolf_8mm" },

			["M"] = {"floor", being = "wolf_mutant1"},
			["Z"] = {"floor", being = "wolf_mutant2"},

			["1"] = {"floor", being = core.bydiff{nil, "wolf_mutant1"}},
			["2"] = {"floor", being = core.bydiff{nil, nil, "wolf_mutant1"}},
			["3"] = {"floor", being = core.bydiff{nil, nil, nil, "wolf_mutant1"}},
			["4"] = {"floor", being = core.bydiff{nil, "wolf_mutant2"}},
			["5"] = {"floor", being = core.bydiff{nil, nil, "wolf_mutant2"}},
			["6"] = {"floor", being = core.bydiff{nil, nil, nil, "wolf_mutant2"}},
		}

		--Handle random adjustments and G-mode changes
		if (string.find(VERSION_STRING, "G")) then
			gametranslation['%'] = { "wolf_flrsign2", flags = { LFPERMANENT } }
		else
			gametranslation['$'] = { "wolf_flrsign1", flags = { LFPERMANENT } }
		end
		if math.random(2) == 1 then
			gametranslation["1"], gametranslation["4"] = gametranslation["4"], gametranslation["1"]
		end
		if math.random(2) == 1 then
			gametranslation["2"], gametranslation["5"] = gametranslation["5"], gametranslation["2"]
		end
		if math.random(2) == 1 then
			gametranslation["3"], gametranslation["6"] = gametranslation["6"], gametranslation["3"]
		end


		local map = [[
````````````#################``...................````
````````````#..............4#``.##O##O##O##O##O##.````
````````````#...&&&&&&&&....#``.#...............#.````
`#######````#......&&.......#``.#.M...........&2O.....
##*....######.....&&&&......###%#...............##O##.
#|......&..........&&:.........3$.............&.....#.
#.......+.........&&&&..........=...................#.
#|......&..........&&:.........6$.............&.....#.
##*....######.....&&&&......###%#...............##O##.
`#######````#......&&.......#``.#.Z...........&5O.....
````````````#...&&&&&&&&....#``.#...............#.````
````````````#..............1#``.##O##O##O##O##O##.````
````````````#################``...................````
]]
		generator.place_tile( basetranslation, map, 12, 5)
		generator.place_tile( gametranslation, map, 12, 5)

		level.flags[ LF_NOHOMING ] = true
		level:player(15, 11)
	end,

	OnEnter = function ()
		level.status = 1
	end,

	OnTick = function ()
		if (level.status == 1 and player.position.x > 42) then
			level.status = 2
			level:drop_being("wolf_bossschabbs",coord.new(63,11))
		end
	end,

	OnKill = function (being)
		if being.id == "wolf_bossschabbs" then
			--Victory
			if statistics.damage_on_level == 0 then
				player:add_history("He exorcised the zombie menace for good.")
			else
				player:add_history("He defeated Dr. Schabbs and halted the zombie menace.")
			end

			player:win()
		end
	end,
}
