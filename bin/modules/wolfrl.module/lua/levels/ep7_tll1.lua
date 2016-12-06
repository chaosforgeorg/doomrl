--[[ Submarine Willie.  A water level seems appropriate, though canonically
     (as far as canon can be said to exist in TLL) he's not a submariner
     by the time BJ meets him.  That and justifying a submarine bay inland
     is a bit tricky.  As is making a level based on one.

     Beating sub willie and finishing the level should have future impacts...
--]]

register_level "tll1" {
	name  = "The Submarine Bay",
	entry = "On level @1 he detoured to meet Submarine Willie.",
	welcome = "Everything seems a bit warped here.",
	level = 3,

	canGenerate = function ()
		return DIFFICULTY >= DIFF_MEDIUM and not DoomRL.isepisode()
	end,

	OnCompletedCheck = function ()
		return level.status == 3
	end,

	OnRegister = function ()

	end,

	Create = function ()
		level.name = "Children Of The Sea"
		generator.fill( "void", area.FULL )

		local translation = {
			['.'] = "floor",
			['~'] = "water",
			['"'] = "bridge",
			
			["`"] = "void",
			[">"] = "stairs",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },
			['$'] = { "wolf_whwall", flags = { LFPERMANENT } }, --Todo: flarify special levels
			['&'] = "wolf_whwall",
			['%'] = "wolf_whwall", --flair

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },

			["@"] = {"floor", being = "wolf_bosswillie"},
		}

		local map = [[
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~>~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~@~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
]]
		generator.place_tile( translation, map, 8, 3 )

		level:player(12, 10)
	end,

	OnEnter = function ()

	end,

	OnTick = function ()

	end,

	OnExit = function (being)
		if statistics.damage_on_level == 0 then
			player:add_history("He won without damage.")
		else
			player:add_history("He won.")
		end

		level.status = level.status + 2
	end,
}
