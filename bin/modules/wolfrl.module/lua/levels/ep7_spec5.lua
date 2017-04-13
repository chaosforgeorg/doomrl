--[[ The teleporter lab, home of a phase device or two and absolutely loaded
     with invisible teleporters.  Generating this is tricky since we must make
     sure there is (1) a path to the exit and (2) dropping teleporters on cells
     can cause problems if an item is already there.  In regular DoomRL an item
     can't get dropped on a teleporter cell; it will be shifted like any other
     item.  But we can't actually DROP a teleporter until the user lands on that
     tile.  So we displace the item when dropping.  Annoying but the best way.

     Since all the magic happens in OnTick a player with a move speed below 0.1s
     can actually run over a teleporter (mire crystal).  There's nothing I can do
     about this without some egregious hacks.
--]]

register_level "tele" {
	name  = "Teleporter Labs",
	entry = "On level @1 he found the teleporter research labs.",
	welcome = "This area looks pretty simple.",
	level = {20,21},

	canGenerate = function ()
		return not DoomRL.isepisode()
	end,

	OnCompletedCheck = function ()
		return level.status == 3 or level.status == 4
	end,

	OnRegister = function ()

	end,

	Create = function ()
		local basetranslation = {
			['.'] = "floor",
			[','] = "rock",

			["`"] = "void",
			[">"] = "stairs",
			['#'] = "wolf_dkwall",
			['$'] = { "wolf_dkwall", flags = { LFPERMANENT } },
			['&'] = { "wolf_cvwall", flags = { LFPERMANENT } },
			['S'] = "rock",

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },
		}
		local gametranslation = {
			['.'] = "floor",
			[','] = "rock",

			["`"] = "void",
			[">"] = "stairs",
			['#'] = "wolf_dkwall",
			['$'] = { "wolf_dkwall", flags = { LFPERMANENT } },
			['&'] = { "wolf_cvwall", flags = { LFPERMANENT } },
			['S'] = { "rock", item = { "teleport", target = coord.new(4,11) } },

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },
		}

		--generator goes in top right
		local map = [[
,&&,,,,,,,,&&&&&..........&&&....$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
,,,,,,,,&&&&.....................###...............######...........####.....$
,,,,,,&&&........................+...................##...............##.....$
,,,,S&&......................#####........###........+.................#.....$
,,,,&&..........#####........#...+...................#.................##+#+#$
,,,&&...........#...###......##+####...............###........#........+.....$
&,&&............#.....###........##########+##########.................#.....$
,&&&......#######.......###......#........#.#........+.................#.....$
,&&...#####.....#.........+......#........#.#........##...............###+#+#$
&&....#.........+.......###......#####.####.####.########...........###......$
&&....+.........#.......###......+...................+..######.######........$
&.....#####################......+...................+.......................$
&&...............................#####.####.####.#####.......................$
&&&...........................&..#........#.#........#......&&&&&............$
`&&.....&.....................&&.#........#.#........#....&&&,,,&&.##+#####+#$
`&.....&&&.......................##########+##########..&&&,,,,,,&.#..........
&&....&&`&&....###+###############...................#.&&,,,,,,&&&.#..........
&.....&```&&...+.................+...................+..&&&&&&&&...+......>...
.....&&````&&&.#.................+.........&&&&.&&...+.............+........&&
&....&```````&&&$$$$$$$$$$$$$$$$$$$$$$$$$$&&&&&.&&&$$$$$$$$$$$$$$$$$&....&&&&`]]

		generator.place_tile( basetranslation, map, 1, 1 )
		generator.place_tile( gametranslation, map, 1, 1 )

		--Generate teleporters
		level.data.teleporters = {}
		level.data.mishaps = 0
		level.data.walls = 0
		level:player(2, 2)

		--Count all of the breakable walls.  For fun.
		for c in area.coords( area.FULL ) do
			if (level.light[c][LFPERMANENT] == false and cells[ generator.get_cell(c) ].set == CELLSET_WALLS) then
				level.data.walls = level.data.walls + 1
			end
		end


		local tele_targets = {}
		local count = 1000
		repeat
			count = count - 1

			--Get free cells for the teleportation
			local tries = 5
			local pos1 = nil
			local pos2 = nil
			while true do
				tries = tries - 1
				if tries == 0 then break end

				if (pos1 == nil) then
					pos1 = generator.random_empty_coord{ EF_NOITEMS, EF_NOSTAIRS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }
					if (level.data.teleporters[pos1.x*25+pos1.y] ~= nil or tele_targets[pos1.x*25+pos1.y]) then pos1 = nil end
				end
				if (pos2 == nil) then
					pos2 = generator.random_empty_coord{ EF_NOITEMS, EF_NOSTAIRS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }
					if (level.data.teleporters[pos2.x*25+pos2.y] ~= nil) then pos2 = nil end
				end

				if (pos1 ~= nil and pos2 ~= nil) then break end
			end

			if (tries > 0) then
				level.data.teleporters[pos1.x*25+pos1.y] = pos2
				tele_targets[pos2.x*25+pos2.y] = true
			end
		until count <= 0

		--trace through the teleporters and make a path to the exit if none exists (TODO)

		tele_targets = nil
	end,

	OnEnter = function ()
		level.status = 1
	end,

	OnTick = function ()
		--iterate through every being and see if they are standing on a hidden teleporter.
		if (level.status == 1) then
			--for b in level:beings() do
				local b = player
				local tele_coord = level.data.teleporters[b.position.x*25+b.position.y]
				if (tele_coord ~= nil) then
					--Drop the teleporter, then displace any items that may already exist there.
					local tele = level:drop_item_ext( {"teleport", target = tele_coord }, b.position )
					if (tele ~= nil and tele.position ~= b.position) then
						local otherItem = level:get_item(b.position)
						if (otherItem ~= nil) then
							otherItem:displace(tele.position)
						end
						tele:displace(b.position)
					end

					if (b == player) then
						level.data.mishaps = level.data.mishaps + 1
						if (level.data.mishaps == 1) then
							ui.msg( table.random_pick( {"Huh?", "What the hell just happened?", "What the-", "This isn't where I wanted to go.", } ) )
						end
					end
					level.data.teleporters[b.position.x*25+b.position.y] = nil
				end
			--end
		end
	end,

	OnExit = function (being)
		local walls = 0
		for c in area.coords( area.FULL ) do
			if (level.light[c][LFPERMANENT] == false and cells[ generator.get_cell(c) ].set == CELLSET_WALLS) then
				walls = walls + 1
			end
		end

		local destroyedGenerator = (level.status == 2)
		local bruteForce = (level.data.walls * 2 / 3 > walls)
		local demolitionMan = (level.data.walls * 1 / 3 > walls)
		local mishaps = level.data.mishaps

		if (not destroyedGenerator) then
			player:add_history("He "
			 .. ((mishaps == 0) and ("glided through the area with ease" .. ((bruteForce) and " (and " .. ((demolitionMan) and "lots of " or "") .. "explosives)" or "") .. ".")
			 or ((mishaps < 19) and ("walked through the area with " .. ((bruteForce) and "" .. ((demolitionMan) and "" or "a little ") .. "help from high explosives" or "little trouble") .. ".")
			 or ((mishaps < 37) and ("ran through the area with some annoyance" .. ((bruteForce) and " (harmlessly taken out on the " .. ((demolitionMan) and "many " or "") .. "walls)" or "") .. ".")
			 or ((mishaps < 55) and ("" .. ((bruteForce) and "blasted " or "bashed ") .. "through the area with great difficulty.")
			 or ("blundered around with extreme frustration."))))))
		else
			player:add_history("He "
			 .. ((not bruteForce) and "disabled" or ((not demolitionMan) and "destroyed" or "recklessly blasted"))
			 .. " the generator "
			 .. ((mishaps == 0) and "immediately on entry" or ((mishaps < 55) and "and left" or "after blundering around in frustration"))
			 .. ".")
		end

		level.status = level.status + 2
	end,
}
