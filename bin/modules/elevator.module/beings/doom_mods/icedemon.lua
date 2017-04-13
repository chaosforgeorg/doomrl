-- Recolored demons are a common mod ploy.  Being able to add in some sort of freeze attack or something would be nice to distinguish this being from other reskins, but I have no ideas.
require("elevator:ai/demon_ai_fixed")
register_being "icedemon" {
	name         = "ice demon",
	ascii        = "c",
	color        = BLUE,
	sprite       = 0,
	hp           = 25,
	armor        = 1,
	todam        = 6,
	tohit        = 3,
	speed        = 130,
	vision       = -1,
	min_lev      = 5,
	min_lev      = 20,
	corpse       = true,
	danger       = 4,
	weight       = 6,
	bulk         = 100,
	flags        = { BF_CHARGE },
	ai_type      = "demon_ai_fixed",

	desc            = "Ice demons are more fragile than the regular kind but their eyes are sharp and so are their claws.",
	kill_desc_melee = "bitten by an ice demon",
}

--Fixing up sounds
local FixSounds = function()
	beings["icedemon"].sound_hit   = core.resolve_sound_id("demon.hit")
	beings["icedemon"].sound_die   = core.resolve_sound_id("demon.die")
	beings["icedemon"].sound_act   = core.resolve_sound_id("demon.act")
	beings["icedemon"].sound_melee = core.resolve_sound_id("demon.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)