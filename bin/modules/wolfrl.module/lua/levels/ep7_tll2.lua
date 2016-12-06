--[[ Professor Quarkblitz's lab ought to affect the artillery range
     but I can't think of a logical reason yet, nor can I think of
     an actual theme for this level.  Possibly a barracks + alarm?
     Or possibly a zombie lab if I have enough sprites to add bruiser
     mutants.
--]]

register_level "tll2" {
	name  = "Professor's Lab",
	entry = "On level @1 he detoured to meet Quarkblitz.",
	welcome = "He puts the mad in mad scientist.",
	level = {9,11},

	canGenerate = function ()
		return DIFFICULTY >= DIFF_MEDIUM and not DoomRL.isepisode()
	end,

	OnCompletedCheck = function ()
		return level.status == 3
	end,

	OnRegister = function ()

	end,

	Create = function ()
		level.name = "War Pigs"
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

			["@"] = {"floor", being = "wolf_bossquark"},
		}

		local map = [[
.................................................................
.................................................................
.................................................................
.................................................................
.................................................................
.................................................................
.................................................................
...............................@.................................
.................................................................
.................................................................
.................................................................
.......>.........................................................
.................................................................
.................................................................
.................................................................
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
