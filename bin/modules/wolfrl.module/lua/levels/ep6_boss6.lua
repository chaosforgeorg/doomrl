--[[ The general is a mob boss.  Enemies are everywhere in this cave level and you'll
     need to take most of them out.
--]]

register_level "boss6" {
	name  = "Fettgesicht's Cave",
	entry = "Then at last he reached General Fettgesicht...",
	welcome = "Finish the job, BJ!",

	Create = function ()
		generator.fill( "void", area.FULL )
		generator.fill( "floor", area.new( 8, 2, 71, 19 ) )

		local translation = {
			['.'] = "floor",
			["`"] = "void",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },
			['&'] = "wolf_whwall",
			['$'] = "wolf_whwall", --flair
			['%'] = { "wolf_cywall", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },

			['!'] = { "floor", item = "wolf_smed" },
			['*'] = { "floor", item = "wolf_food2" },
			['|'] = { "floor", item = "wolf_9mm" },
			[':'] = { "floor", item = "wolf_8mm" },
			[';'] = { "floor", item = "wolf_kurz" },
			['/'] = { "floor", item = "wolf_rocket" },

			["h"] = { "floor", being = "wolf_guard1" },
			["i"] = { "floor", being = "wolf_ss1" },
			["j"] = { "floor", being = "wolf_officer1" },

			["1"] = { "floor", being = core.bydiff{"wolf_ss1", "wolf_officer1"} },
			["2"] = { "floor", being = core.bydiff{"wolf_guard1", "wolf_ss1", "wolf_officer1"} },
			["3"] = { "floor", being = core.bydiff{nil, "wolf_guard1", "wolf_ss1", "wolf_officer1"} },
			["4"] = { "floor", being = core.bydiff{nil, nil, "wolf_guard1", "wolf_ss1"} },
			["5"] = { "floor", being = core.bydiff{nil, nil, nil, "wolf_guard1"} },
			["6"] = { "floor", being = core.bydiff{nil, "wolf_guard1"} },
			["7"] = { "floor", being = core.bydiff{nil, "wolf_ss1"} },
			["8"] = { "floor", being = core.bydiff{nil, "wolf_officer1"} },
			["9"] = { "floor", being = core.bydiff{nil, nil, "wolf_guard1"} },
			["A"] = { "floor", being = core.bydiff{nil, nil, "wolf_ss1"} },
			["B"] = { "floor", being = core.bydiff{nil, nil, "wolf_officer1"} },
		}

		local map = [[
````````########################################################
````````#...........&&&&&&&&&&&&&&&&&&&&&&&&&&i&&&&&&&&&&&&&&&&#
````````#.B%%%%%&&..&&&&&&&&&&&&&&&&&&&&&|..........&&&&&&&&&&&#
````````#.7%%%%%&&...&&&&&&&&&&&&&&&&&..h.../&&&&....1.&&&&&&&&#
````````#.h%%%%%&&...&&&&&&&&&&&&&&*.......&&&&&&.......2/&&&&&#
````````#..%%%%%&&A...&&&&&&&&&&&&&..j....&&&&&&....&&.....&&&&#
`````####.......&&.....&&&&&&&&&&&........&&&....9..&&.........#
``####.!&&&&&&&+&&.....&&&&&&&&&&&.....i....................&&&#
###|....+.......&&.......&&&&&&&&&........A.......|&&&&&&...&&&#
#;....h.+.......&&.......+...1&:....&&&&:.....8...&&&&&;....&&&#
##......&&&&&&&+&&.....&&&&&&.&&&&...&&&&&.......&&&&....3.*&&&#
`####:.!&.......&&.....&&&3..2&&&&.....&&&&......&&........&&&&#
````#####..%%%%%&&6...&&&&.&&&&&&&&.......B................&&&&#
````````#.h%%%%%&&...&&&&&.&&&&&&;............7.....5..4.&&&&&&#
````````#.7%%%%%&&...&&&&&.&&&&&&&&.&&&&&...............&&&&&&&#
````````#.B%%%%%&&..&&&&&&4........5&&&&&&&&..&&&...6&&&&&&&&&&#
````````#...........&&&&&&&&&&&&&&&&&&&&&&&&&*&&&&&&&&&&&&&&&&&#
````````########################################################
]]

		generator.place_tile( translation, map, 8, 2)
		level:player(10, 12)
	end,

	OnEnter = function ()
		level.status = 1
	end,

	OnTick = function ()
		if(level.status == 1 and player.position.x > 42) then
			level:drop_being("wolf_bossfett",coord.new(72,8))
			level.status = 2
		end
	end,

	OnKill = function (being)
		if being.id == "wolf_bossfett" then
			--Victory
			if statistics.damage_on_level == 0 then
				player:add_history("He obliterated General Fettgesicht, mastermind of the poison war.")
			else
				player:add_history("He defeated General Fettgesicht, mastermind of the poison war.")
			end

			player:win()
		end
	end,
}
