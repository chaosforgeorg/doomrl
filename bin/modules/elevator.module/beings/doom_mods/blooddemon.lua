-- Recolored demons are a common mod ploy, but special mention goes out to KDIZD which included a different cyborg model and different sounds.
require("elevator:ai/demon_ai_fixed")
register_being "blooddemon" {
	name         = "blood demon",
	ascii        = "c",
	color        = RED,
	sprite       = SPRITE_DEMON,
	overlay      = { 0.7, 0.3, 0.3, 1.0 },
	hp           = 50,
	armor        = 1,
	todam        = 8,
	tohit        = 3,
	speed        = 120,
	vision       = -1,
	min_lev      = 7,
	corpse       = true,
	danger       = 5,
	weight       = 7,
	bulk         = 100,
	flags        = { BF_CHARGE },
	ai_type      = "demon_ai_fixed",

	desc            = "Blood demons are really just ordinary demons that have lived long enough to learn how to stay alive.",
	kill_desc_melee = "chomped by a blood demon",
}

--Fixing up sounds
local FixSounds = function()
	beings["blooddemon"].sound_hit   = core.resolve_sound_id("blooddemon.hit")
	beings["blooddemon"].sound_die   = core.resolve_sound_id("blooddemon.die")
	beings["blooddemon"].sound_act   = core.resolve_sound_id("blooddemon.act")
	beings["blooddemon"].sound_melee = core.resolve_sound_id("blooddemon.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)