--[[ A zombie rush level, which is sort've ep2's theme overall.
--]]

register_level "spec2" {
	name  = "The Divide",
	level = {5,7},

	canGenerate = function ()
		return CHALLENGE == "challenge_ep2"
	end,

	OnCompletedCheck = function ()
		return level.status == 5 or level.status == 6
	end,

	OnRegister = function ()
		register_medal "shot1" {
			name  = "Shotgun Shell",
			desc  = "Awarded for standing your ground at night.",
			hidden  = true,
		}
		register_medal "shot2" {
			name  = "Flechette Shell",
			desc  = "Awarded for spending the night w/o damage.",
			hidden  = true,
		}
	end,

	Create = function ()
		level.name = "Souls Of Black"
		generator.fill( "void", area.FULL )

		--Generate the map...
		local area_graveyard1 = area.new( 25, 11, 40, 19 )
		local area_graveyard2 = area.new( 45, 2, 60, 14 )
		local basetranslation = {
			['.'] = "floor",
			[','] = "grass1",

			["`"] = "void",
			[">"] = "stairs",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },
			['&'] = { "wolf_rfwall", flags = { LFPERMANENT } },
			['%'] = { "wolf_cvwall", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },
			["|"] = "tombstone",

			["1"] = "grass1",
			["2"] = "grass1",
			["3"] = "grass1",
			["4"] = "grass1",
			["5"] = "grass1",
			["6"] = "grass1",
			["7"] = "grass1",
			["8"] = "grass1",
			["9"] = "grass1",
		}
		local gametranslation = {
			['.'] = "floor",
			[','] = "grass1",

			["`"] = "void",
			[">"] = "stairs",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },
			['&'] = { "wolf_rfwall", flags = { LFPERMANENT } },
			['%'] = { "wolf_rfwall", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },
			["|"] = "tombstone",

			["1"] = {"grass1", being = "wolf_mutant1"},
			["2"] = {"grass1", being = core.bydiff{nil, "wolf_mutant1"}},
			["3"] = {"grass1", being = core.bydiff{nil, nil, "wolf_mutant1"}},
			["4"] = {"grass1", being = core.bydiff{nil, nil, nil, "wolf_mutant1"}},
			["5"] = {"grass1", being = "wolf_mutant2"},
			["6"] = {"grass1", being = core.bydiff{nil, "wolf_mutant2"}},
			["7"] = {"grass1", being = core.bydiff{nil, nil, "wolf_mutant2"}},
			["8"] = {"grass1", being = core.bydiff{nil, nil, nil, "wolf_mutant2"}},
			["9"] = {"grass1", being = core.bydiff{nil, "wolf_rat"}}, --Just because it's funny
		}

		local map = [[
9,&``````````&&&&&&,,,,,,&&&&&&&&&,,,,,,,,,%473374&&&&&&&&&&&&&&&&```&&&&&&&
,,&&&``````&&&,,,,,,,,,,,,,,,,,,,,,,,,,,,&&&&%%%%%%,,,,,,,,,,,,,,&&`&&,,,|,&
&34,&&&&`&&&,,,,&&&&&,,,,,,,,,,,,,,,,,,&&&``&,,,,,,,,,,,,,,,,,,,,,&&`&&&,>,&
&&&8622&&&,,,,&&&&&&,,,,,,,,,,,,,,,,,,&&````&,,,,,,,,,,,,,,,,,,,&&&````&&,&&
``&&%%%&,,,,&&&&,,,,,,,,&&&&&&&&&&&&,,&&&&`&&,,,,,,,,,,,,,,,,,,&&`````&&1,&`
```&&,,,,&&&&&,,,,,,,&&&&````````&&,,,,,,&&&,,,,,,,,,,,,,,,,,&&&`````&&12&&`
`&&&,,&&&&`&&,,,,&&&&&```######``&,,,,,,,,,,,,,,,,,,,,,,,,,,,%&&&```&&128&``
&&,,&&&`&&&&,,&&&&```````#....&&&&,,,,,,,,,,,,,,,,,,,,,,,,,,,%,,&&`&&536&&``
,,,,&``&&,,,,&&````#########+##,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,%,,,&&&54,,&```
,,,,&&&&,,,,,&`````#..........#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,&%,,,,&,,,,&&```
,,,,,,,,,,,,&&`````#..........+,,,,,,,,,,##+#,,,,,,,,,,,,,,,&,,,,,,,,,,&````
,,,,,,,,,,,&&&&&```############,,,,,,,,###..#&,,,,,,,,,,,,,,&&,,,,,,,,&&````
,,,,,,,,,,,,,,,&&&&&,,,,,,,,,,,,,,,,,,,#....#&&,,,,,,,,,,,,,&&&,,,,,,,&`````
###+###,,,,,,,,,,,,,,,,,,,,,,,,,,,#######...#`&,,,,,,,,,,,,,&`&,,,,,,&&`````
#.....#,,,,,,,,,,,,,&&&&&&,,,,,,,,#.....+...#`&,,,,,,,,,,,,&&`&&,,,,,&``````
#.....#,,,,,,,,,,,,&&````&&&,,,,,,+.....#####&&,,,,,,,,,,,&&```&,,,,&&``````
###+#########,,,,,,&```````&&&,,,,#######``&&&,,,,,,,,,,&&&````&,,,,&```````
#...........+,,,,,,&&&&``````&&,,,,,,,,,&&&&,,,,,,,,,,&&&``````&&,,&&```````
#...........#,,,,,,,,,&&&&&&&&,,,,,,,,,,,,,,,,,,,,&&&&&`````````&,,&````````
#############,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,&&&&&&`````````````&&,&````````
]]
		generator.place_tile( basetranslation, map, 1, 1 )
		--Cheater way of getting all the cells we'll want to destroy later
		level.data.items = { barriers = {} }
		for c in generator.each("wolf_cvwall") do
			table.insert(level.data.items.barriers, coord.clone( c ))
		end
		generator.place_tile( gametranslation, map, 1, 1 )

		generator.scatter( area_graveyard1,"grass1","tombstone", 10)
		generator.scatter( area_graveyard2,"grass1","tombstone", 10)

		level:player(3, 18)
	end,

	OnEnter = function ()
		local curdate = statistics.get_date()

		if (curdate.hour == 0) then
			ui.msg("Run away! Run away!")
			player:add_history("On level @1 he entered the divide even though he really shouldn't have.")
			level.status = 2

			--Beef up all the monsters
			for b in level:beings() do
				if (b.id == "wolf_mutant1" or b.id == "wolf_mutant2") then
					b.todamall = b.todamall + 2
					b.speed = math.floor(b.speed * 1.33)
				end
			end
		else
			ui.msg("You have an uncanny feeling...")
			player:add_history("On level @1 he got lost and wandered outside.")
			level.status = 1
		end
		

		--Zombie tradition: swarm the player!
		for b in level:beings() do
			if (b.id == "wolf_mutant1" or b.id == "wolf_mutant2") then
				b.flags[ BF_HUNTING ] = true
			end
		end
	end,

	OnTick = function ()
		if ((level.status == 1 or level.status == 2) and player.position.x >= 45) then
			ui.msg("**Crash!**")
			for _,c in ipairs(level.data.items.barriers) do
				level.map[ c ] = "grass1"
			end

			level.status = level.status + 2
		end
	end,

	OnKill = function (being)
		--Under normal circumstances this would be a plain ol' KillAll but
		--I want to keep the rat in the corner a secret to infuriate 100%ers.
		local foundEnemy = false
		for b in level:beings() do
			if (b.id ~= "wolf_rat" and b ~= being) then
				foundEnemy = true
				break
			end
		end

		if foundEnemy == false and (level.status == 3 or level.status == 4) then
			level.status = level.status + 2
		end
	end,

	OnExit = function (being)
		ui.msg("Whew. What a mess.")

		if statistics.damage_on_level == 0 then
			player:add_history("He slipped through effortlessly.")
		elseif level.status >= 5 then
			player:add_history("He braved the grave intact.")
		else
			player:add_history("He fled! He fled this accursed place!")
		end

		if (level.status == 6) then player:add_medal("shot1") end
		if (level.status == 6 and statistics.damage_on_level == 0) then player:add_medal("shot2") end
	end,
}
