--[[ Hitler is a REAL boss, and he comes in stages.  First
     you must kill all those puny underlings to reach him,
     then there's him and his power armor.
--]]

register_level "boss3" {
	name  = "Hitler's Lair",
	entry = "Then at last he found Hitler...",
	welcome = "Finish the job, BJ!",

	Create = function ()
		generator.fill( "void", area.FULL )
		generator.fill( "floor", area.new( 8, 2, 65, 19 ) )

		local officers = table.shuffle{ core.bydiff{nil, "wolf_officer1"}, core.bydiff{nil, nil, "wolf_officer1"}, core.bydiff{nil, nil, nil, "wolf_officer1"}}
		local translation = {
			['.'] = "floor",
			["`"] = "void",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },
			['X'] = "wolf_whwall",
			['x'] = "wolf_whwall", --flair
			['&'] = { "wolf_brwall", flags = { LFPERMANENT } },
			['Y'] = "wolf_brwall",
			['y'] = "wolf_brwall", --flair
			['%'] = { "wolf_cywall", flags = { LFPERMANENT } },
			['Z'] = "wolf_cywall",
			['z'] = "wolf_cywall", --flair

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },

			['*'] = { "floor", item = "wolf_smed" },
			['|'] = { "floor", item = "wolf_9mm" },
			[':'] = { "floor", item = "wolf_8mm" },
			['/'] = { "floor", item = "wolf_kurz" },
			[';'] = { "floor", item = "wolf_armor2" },

			["a"] = { "floor", being = "wolf_guard1" },
			["b"] = { "floor", being = "wolf_dog1" },
			["c"] = { "floor", being = "wolf_ss1" },
			["d"] = { "floor", being = "wolf_officer1" },
			["e"] = { "floor", being = "wolf_fakehitler" },

			["1"] = { "floor", being = core.bydiff{"wolf_guard1", "wolf_ss1", "wolf_officer1", "wolf_fakehitler"} },
			["2"] = { "floor", being = core.bydiff{nil, "wolf_guard1", "wolf_ss1", "wolf_officer1"} },
			["3"] = { "floor", being = core.bydiff{nil, nil, "wolf_guard1", "wolf_ss1"} },
			["4"] = { "floor", being = core.bydiff{nil, nil, nil, "wolf_guard1"} },
			["5"] = { "floor", being = core.bydiff{nil, "wolf_officer1"} },
			["6"] = { "floor", being = core.bydiff{nil, nil, "wolf_officer1"} },
			["7"] = { "floor", being = core.bydiff{nil, nil, nil, "wolf_officer1"} },
			["8"] = { "floor", being = officers[1] },
			["9"] = { "floor", being = officers[2] },
			["0"] = { "floor", being = officers[3] },
		}


		local map = [[
`````````````````&&&&&&&&&&&&&&&&&####################````
`````````````````&YY56.....YY234y&#................./#````
`````````````````&YY:7.....YY.e.+.=..................#````
````````##########YYYYYYY...Y...y&#...##..%%%%....####````
````````#........#YYYYYYY...Y...Y&#...##..%%%%....#```````
````````#.XX..XX.#YYYYYYY...Y...Y&#/..##..%%%%....########
````````#.XX..XX.X......8...Y...Y&######................*#
``#######........+..YYYYY...+...Y&`````#......%%%%.......#
`##*....X........X..YYYYY...Y...Y&`````#......%%%%.......#
##|.....X........x......9...Y...Y&`````#......%%%%.......#
#;......+......e.X..YYYYY...Y...Y&`````#.................#
##|.....X........+..YYYYY...+...Y&`````#.........%%%%....#
`##*....X........X......0...Y...Y&`````#*........%%%%....#
``#######........#YYYYYYYY..Y12.Y&`````#####.....%%%%....#
````````#.XX..XX.#&&&&&&&Y..Y/34Y&`````````#.............#
````````#.XX..XX.#``````&Y..YYYYY&`````````#.............#
````````#........#``````&Y...ab:Y&`````````###############
````````##########``````&&&&&&&&&&````````````````````````
]]
		--[[old--discarded
		--"................................................############### #####........"
		--"................................................#.............# #...#........"
		--"................................................#...%%%.......###...#........"
		--"................................................#...%%%..%%%........#........"
		--"................................................#...%%%..%%%........#........"
		--".......................#######..................#........%%%..%%%...#........"
		--".......................#.....#..................####..........%%%...#........"
		--".......................#.....&&&&&&&&&&&&&&&&&&&&&&#..........%%%...#........"
		--".......................#.....&.....................+................#........"
		--".......................#.....&&&&&&&+&&&&+&&&&&&&&&##############...#........"
		--".......................#..................................#.........#........"
		--".....................###############+####+##########......#.........#........"
		--"....................##.....#.......................#......###########........"
		--"...................##......#...#...............#...#......#.................."
		--"...................#.......+.......................#......#.................."
		--"...................##......#...#...............#...########.................."
		--"....................##.....#.......................#........................."
		--".....................###############################........................."]]--

		generator.place_tile( translation, map, 8, 2)
		level:player(10, 12)
	end,

	OnEnter = function ()
		level.status = 0
	end,

	OnKillAll = function ()
		if level.status == 0 then
			level.status = 1

			generator.transmute("lmdoor1", "mdoor1")

			local enemy
			enemy = level:drop_being("wolf_officer1",coord.new(62, 17))
			enemy.flags[ BF_HUNTING ] = true
			enemy = level:drop_being("wolf_officer1",coord.new(62, 16))
			enemy.flags[ BF_HUNTING ] = true
			enemy = level:drop_being("wolf_officer1",coord.new(63, 15))
			enemy.flags[ BF_HUNTING ] = true
			enemy = level:drop_being("wolf_officer1",coord.new(64, 15))
			enemy.flags[ BF_HUNTING ] = true

			level:drop_being("wolf_bosshitler1",coord.new(64, 17))

			ui.msg("A door is unlocked from the inside!")
			player:play_sound("wolf_bosshitler1.act")
		end
	end,

	OnKill = function (being)
		if being.id == "wolf_bosshitler1" then
			--spawn non-mecha Hitler.
			--Mecha-hitler hasn't actually died yet casuing a bit of a problem here.
			--If we drop regular hitler on the same coord it will cloak him until he moves.
			--I've found no workaround for this; the only option is to do the spawn in the
			--actual being's OnDie hook which apparently doesn't have this problem.  I
			--hate to resort to that but it's the only way right now.

			--local target = generator.drop_coord( being.position, {EF_NOBLOCK, EF_NOBEINGS} )
			--local boss = level:drop_being("wolf_bosshitler2",target)
			--boss.scount = being.scount
			--being:spawn("wolf_bosshitler2")
		elseif being.id == "wolf_bosshitler2" then
			--Victory
			if statistics.damage_on_level == 0 then
				player:add_history("He assassinated Hitler flawlessly.")
			else
				player:add_history("He toppled the Third Reich's last stand.")
			end

			player:win()
		end
	end,
}
