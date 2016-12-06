-- Recolored demons are a common mod ploy
require("elevator:ai/demon_ai_fixed")
register_being "sanddemon" {
	name         = "sand demon",
	ascii        = "c",
	color        = BROWN,
	sprite       = 0,
	hp           = 35,
	armor        = 2,
	todam        = 5,
	tohit        = 3,
	speed        = 110,
	vision       = -1,
	min_lev      = 5,
	min_lev      = 22,
	corpse       = true,
	danger       = 4,
	weight       = 6,
	bulk         = 100,
	flags        = { BF_CHARGE },
	ai_type      = "demon_ai_fixed",

	desc            = "Sand demons are slightly slower and slightly hardier than regular demons. They may blend in better, but they're no tougher than their pink counterparts.",
	kill_desc_melee = "bitten by a sand demon",
}

--Fixing up sounds
local FixSounds = function()
	beings["sanddemon"].sound_hit   = core.resolve_sound_id("demon.hit")
	beings["sanddemon"].sound_die   = core.resolve_sound_id("demon.die")
	beings["sanddemon"].sound_act   = core.resolve_sound_id("demon.act")
	beings["sanddemon"].sound_melee = core.resolve_sound_id("demon.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)