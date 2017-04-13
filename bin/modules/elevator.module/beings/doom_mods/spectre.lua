-- The spectre comes from vanilla DooM
require("elevator:ai/demon_ai_fixed")
register_being "spectre" {
	name         = "spectre",
	ascii        = " ",
	color        = BLACK,
	sprite       = 127, --No transparency overlay effects yet
	hp           = 20,
	armor        = 1,
	todam        = 5,
	tohit        = 3,
	speed        = 100,
	vision       = -2,
	min_lev      = 9,
	corpse       = true,
	danger       = 4,
	weight       = 7,
	bulk         = 100,
	flags        = { BF_CHARGE },
	ai_type      = "demon_ai_fixed",

	desc            = "Spectres have traded in a little power for partial invisibility. Watch out for these guys; having one sneak up on you is about the worst way a firefight can go wrong.",
	kill_desc_melee = "eaten by a spectre",
}

--Fixing up sounds
local FixSounds = function()
	beings["spectre"].sound_hit   = core.resolve_sound_id("demon.hit")
	beings["spectre"].sound_die   = core.resolve_sound_id("demon.die")
	beings["spectre"].sound_act   = core.resolve_sound_id("demon.act")
	beings["spectre"].sound_melee = core.resolve_sound_id("demon.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)