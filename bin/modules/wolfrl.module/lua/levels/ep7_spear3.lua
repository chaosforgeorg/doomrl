--[[ This level helps break up the monotony.  There's a
     hulking mutant locked away that eventually breaks loose
     and needs killing, but he has a pretty poor IIF sense
     so a good way to get through this level with minimum
     damage is to wait for him to escape and start killing
     guards for you (or use the guards as meat shields).

     Note: berserker mutant AI not yet implemented, todo.
--]]

register_level "spear3" {
	name  = "Castle Boss",
	entry = "Inside the castle he ran into a supermutant!",
	welcome = "*sniff sniff* something's not right here...",

	Create = function ()
		generator.fill( "void", area.FULL )
		generator.fill( "floor", area.new( 15, 2, 59, 19 ) )

		local translation = {
			['.'] = "floor",
			[','] = { "floor", flags = { LFBLOOD } },
			[':'] = "bloodpool",
			[">"] = "stairs",
			["`"] = "void",
			['O'] = "pillar",      --These WERE permanent but I decided against that.
			['#'] = "wolf_whwall", --These WERE permanent but I decided against that.
			['&'] = "wolf_whwall",
			['Y'] = { "wolf_cywall", flags = { LFPERMANENT } },
			['%'] = "wolf_rewall",
			['$'] = { "wolf_rewall", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },

			['*'] = { "floor", item = "wolf_smed" },
			['|'] = { "floor", item = "wolf_8mm" },

			["a"] = {"floor", being = "wolf_guard1"},
			["b"] = {"floor", being = "wolf_dog1"},
			["c"] = {"floor", being = "wolf_ss1"},
			["d"] = {"floor", being = "wolf_officer1"},

			["1"] = {"floor", being = core.bydiff{nil, "wolf_guard1"}},
			["2"] = {"floor", being = core.bydiff{nil, nil, "wolf_guard2"}},
			["3"] = {"floor", being = core.bydiff{nil, nil, nil, "wolf_guard1"}},
			["4"] = {"floor", being = core.bydiff{nil, "wolf_guard1", "wolf_ss1"}},
			["5"] = {"floor", being = core.bydiff{nil, nil, "wolf_ss2"}},
			["6"] = {"floor", being = core.bydiff{nil, nil, nil, "wolf_ss1"}},
			["7"] = {"floor", being = core.bydiff{nil, "wolf_guard1", "wolf_ss1", "wolf_officer1"}},
			["8"] = {"floor", being = core.bydiff{nil, nil, "wolf_ss1", "wolf_officer2"}},
			["9"] = {"floor", being = core.bydiff{nil, nil, nil, "wolf_officer1"}},

			["x"] = "bones1",
			["y"] = "bones2",
			["z"] = { "bones1", flags = { LFBLOOD } },
		}

		local map = [[
$$$$$$$$$$$$$$$$$$$$$$$$$$```````````````````
$%%%%.....6.....8.......4$$$$$$$$$$$$$$$$$$$$
$%%%%..###O##O##O##O###..$%%%..............%$
$%%%%..#b............a#..$%%...%%......%%...$
$%%%%..O..7.....5....9O..$%%..%%%%%%%%%%%%..$
$%%%%..#..YYYYYYYYYY..#..$%%..%%$$$$$$$$%%..$
$%%%%..#..Y.,:.,.,,Yd.#..=.....%$$c..c$$%...$
$|.*%..#&&Y....,..,-..O..$.....%$.>..>.$%...$
$...+..+..Y...,x...Y..#..$.....%$......$%...$
$|.*%..#&+Y...,:.,.Y..#..$.....%$$+$$+$$%...$
$%%%%..O..Y,.....z.=..O..$.....%%1....2%%...$
$%%%%..#..Y,:,x.,,.Yd.#..=.....%%......%%...$
$%%%%..#..YYYYYYYYYY..#..$%%..%%%%.OO.%%%%..$
$%%%%..O..4.....8....6O..$%%..%%%%....%%%%..$
$%%%%..#b............a#..$%%...%%......%%...$
$%%%%..###O##O##O##O###..$%%%..............%$
$%%%%.....9.....5.......7$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$$$$$$$$$$$$```````````````````
]]
		generator.place_tile( translation, map, 15, 2 )

		level.flags[ LF_NOHOMING ] = true
		level:player(16, 10)
	end,

	OnEnter = function ()
		level.status = 1
	end,

	OnTick = function ()
		if(level.status < 800) then
			level.status = level.status + 1
			if(level.status == 800) then
				ui.msg("Something has smashed its way free!")
				level:drop_being("wolf_bossuber",coord.new(33,9))
				generator.transmute("lmdoor2", "floor")
			end
		end
	end,

	OnKill = function (being)
		if being.id == "wolf_bossuber" then
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

	OnExit = function ()
		if statistics.damage_on_level == 0 then
			player:add_history("He purified the ubermutant with extreme prejudice.")
		else
			player:add_history("He purified the ubermutant.")
		end
	end,
}
