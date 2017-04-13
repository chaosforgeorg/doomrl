--[[ A pushwall maze similar to the infamous segment in episode 2.
     There is a random element to this but I'd like to make all
     puzzles solvable without trial and error.  The aardvark detail
     might be a nice touch for some dead ends but that's optional.
--]]

register_level "spec2" {
	name  = "The Maze",
	entry = "On level @1 he got lost in the maze.",
	welcome = "Something wicked this way comes.",
	level = {5,7},

	canGenerate = function ()
		return CHALLENGE == "challenge_ep2"
	end,

	OnCompletedCheck = function ()
		return level.status == 3
	end,

	OnRegister = function ()
		register_medal "maze1" {
			name  = "Loose Brick",
			desc  = "Awarded for navigating the maze.",
			hidden  = true,
		}
		register_medal "maze2" {
			name  = "Aardvark Decal",
			desc  = "Awarded for exposing every room in the maze.",
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

			["#"] = { "wolf_whwall", flags = { LFPERMANENT } },
			["~"] = { "wolf_pushwall", flags = { LFPERMANENT } },
		}

		local map = [[
.........................................................................
.........................................................................
.........................................................................
.........................................................................
.........................................................................
....................................################.....................
....................................#..~..#..~..#..#.....................
....................................#..#..~..#..~..#.....................
...........~.~......................#~~##~#######~##.....................
............>..........................~..#..~..#..#.....................
...........~.~......................#..#..~..#..~..~.....................
....................................##~########~####.....................
....................................#..~..#..~..#..#.....................
....................................#..#..~..#..~..#.....................
....................................################.....................
.........................................................................
.........................................................................
.........................................................................
.........................................................................
]]
		generator.place_tile( translation, map, 3, 1)

		level:player(20, 10)
	end,

	OnEnter = function ()
		level.status = 0
	end,

	OnExit = function (being)

	end,
}
