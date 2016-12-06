--[[ Pac-Man! The ghosts actually follow proper pac-man ghost AI
     (or as reasonable an approximation as I can make).

     Todo: make all of the pac cells.
--]]

register_level "spec3" {
	name  = "Pac-Man",
	entry = "On level @1 he had a pac-attack.",
	welcome = "  * = 10  O = 50  ",
	level = {3,6},

	canGenerate = function ()
		return CHALLENGE == "challenge_ep3"
	end,

	OnCompletedCheck = function ()
		return level.status == 3
	end,

	OnRegister = function ()
		register_medal "pac1" {
			name  = "Pellet",
			desc  = "Awarded for munching a pac-ghost.",
			hidden  = true,
		}
		register_medal "pac2" {
			name  = "Power Pellet",
			desc  = "Awarded for munching every pac-ghost.",
			hidden  = true,
		}
	end,

	Create = function ()
		generator.fill( "void", area.FULL )

		local mods = { "wolf_mod_agility","wolf_mod_bulk","wolf_mod_tech","wolf_mod_power" }
		table.remove(mods, math.random(4))
		local translation = {
			["."] = "floor",
			["`"] = "void",
			["+"] = "door",
			[">"] = "stairs",

			["|"] = { "pac_wall1", flags = { LFPERMANENT } },
			["-"] = { "pac_wall2", flags = { LFPERMANENT } },
			["C"] = { "pac_wall3", flags = { LFPERMANENT } },
			["Z"] = { "pac_wall4", flags = { LFPERMANENT } },
			["E"] = { "pac_wall5", flags = { LFPERMANENT } },
			["Q"] = { "pac_wall6", flags = { LFPERMANENT } },
			["W"] = { "pac_wall7", flags = { LFPERMANENT } },
			["X"] = { "pac_wall8", flags = { LFPERMANENT } },
			["D"] = { "pac_wall9", flags = { LFPERMANENT } },
			["A"] = { "pac_wall10", flags = { LFPERMANENT } },
			[","] = { "pac_wall12", flags = { LFPERMANENT } },

			[":"] = { "pac_bwall1", flags = { LFPERMANENT } },
			["="] = { "pac_bwall2", flags = { LFPERMANENT } },
			["n"] = { "pac_bwall3", flags = { LFPERMANENT } },
			["v"] = { "pac_bwall4", flags = { LFPERMANENT } },
			["y"] = { "pac_bwall5", flags = { LFPERMANENT } },
			["r"] = { "pac_bwall6", flags = { LFPERMANENT } },
			["t"] = { "pac_bwall7", flags = { LFPERMANENT } },
			["b"] = { "pac_bwall8", flags = { LFPERMANENT } },


			['*'] = { "floor", item = "wolf_chalice" },
			['!'] = { "floor", item = "wolf_oneup" },

			["1"] = { "floor", being = "pac_blinky" },
			["2"] = { "floor", being = "pac_pinky" },
			["3"] = { "floor", being = "pac_inky" },
			["4"] = { "floor", being = "pac_clyde" },
			["5"] = { "floor", item = { "teleport", target = coord.new(43, 2) } },
			["6"] = { "floor", item = { "teleport", target = coord.new(43,18) } },
			["7"] = { "floor", item = mods[1] },
			["8"] = { "floor", item = mods[2] },
			["9"] = { "floor", item = mods[3] },
		}

		local map = [[
Q---------W-----W---------E,,,,,,,,,,,,|6|,,,,,,,,,,,,Q-----------------E
|*...*...*Z-----C..!...*..|,,,,,,,,,,,,|.|,,,,,,,,,,,,|*...*...*...!...*|
|.Q-----E4..*...*.Q-----E.|,,,,,,,,,,,,|.|,,,,,,,,,,,,|.Q-----E.Q-----E.|
|.|,,,,,|.--------X-----C*Z------------C.Z------------C.Z-----C.Z-----C.|
|.|,,,,,|.*...*...*...*.....*...*...*...*...*...*...*...*...*..2..*...*.|
|*|,,,,,D--------.Q-----E.--------------.-------W-----W--------*Q-----E.|
|.|,,,,,|.*...*...|,,,,,|.......................|,,,,,|.*...*...|,,,,,|.|
|.Z-----C.Q-----E*Z-----C*Q-----E.Qt=========tE.Z-----C.Q-----E.Z-----C*|
|...*...*.|,,,,,|.....*...|,,,,,|.|:...9.....vn.........|,,,,,|.*...*...|
|*--------A,,,,,|.--------A,,,,,|.|:.>..8.....+.--------A,,,,,|.--------A
|...*...*.|,,,,,|.....*...|,,,,,|.|:...7.....ry.........|,,,,,|.*...*...|
|.Q-----E.Z-----C*Q-----E*Z-----C.Zb=========bC.Q-----E.Z-----C.Q-----E*|
|.|,,,,,|.*...*...|,,,,,|.......................|,,,,,|.*...*...|,,,,,|.|
|*|,,,,,D--------.Z-----C.--------------.-------X-----X--------*Z-----C.|
|.|,,,,,|.*...*...*...*.....*...*...*...*...*...*...*...*...*..1..*...*.|
|.|,,,,,|.--------W-----E*Q------------E.Q------------E.Q-----E.Q-----E.|
|.Z-----C3..*...*.Z-----C.|,,,,,,,,,,,,|.|,,,,,,,,,,,,|.Z-----C.Z-----C.|
|*...*...*Q-----E..!...*..|,,,,,,,,,,,,|.|,,,,,,,,,,,,|*...*...*...!...*|
Z---------X-----X---------C,,,,,,,,,,,,|5|,,,,,,,,,,,,Z-----------------C
]]
		generator.place_tile( translation, map, 3, 1)

		level:player(20, 10)
	end,

	OnEnter = function ()
		level.status = 0
		player.vision = player.vision + 7 --You are 8 by default, 15 is the highest you can go, numbers over 15 are permitted, they just have no effect.
	end,

	OnExit = function (being)
		ui.msg("wakka wakka")
		player.vision = player.vision - 7

		local pac_small = 0
		local pac_large = 0
		for item in level:items() do
			if ( item.id == "wolf_chalice" ) then
				pac_small = pac_small + 1
			elseif ( item.id == "wolf_oneup" ) then
				pac_large = pac_large + 1
			end
		end

		if (pac_small == 0 and pac_large == 0) then
			if statistics.damage_on_level == 0 then
				player:add_history("He scavenged the maze flawlessly.")
			else
				player:add_history("He scavenged the maze completely.")
			end
			level.status = 3
		elseif (pac_large == 0) then
			player:add_history("He took the best treasure and left.")
			level.status = 2
		elseif (pac_small <= 50 or pac_large <= 2) then
			player:add_history("He stuck around for a little while before being run off.")
			level.status = 1
		else
			player:add_history("The ghosts quickly scared him off.")
		end

		if (kills.get("pac_blinky") > 0 or  kills.get("pac_pinky") > 0 or  kills.get("pac_inky") > 0 or  kills.get("pac_clyde") > 0) then player:add_medal("pac1") end
		if (kills.get("pac_blinky") > 0 and kills.get("pac_pinky") > 0 and kills.get("pac_inky") > 0 and kills.get("pac_clyde") > 0) then player:add_medal("pac2") end
	end,
}
