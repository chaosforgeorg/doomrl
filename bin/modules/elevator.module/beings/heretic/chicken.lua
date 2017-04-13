--Chickens are heretic monsters that have been turned into, well, chickens.  They aren't aggressice.
require("elevator:ai/neutral_melee_ai")
register_being "chicken" {
	name         = "chicken",
	ascii        = "c",
	color        = WHITE,
	sprite       = 0,
	hp           = 5,
	armor        = 0,
	speed        = 130,
	todam        = 0,
	tohit        = 1,
	min_lev      = 1,
	max_lev      = 10,
	corpse       = true,
	danger       = 0,
	weight       = 1,
	xp           = 0,
	bulk         = 100,
	flags        = { },
	ai_type      = "neutral_melee_ai",

	desc            = "Just some of the local, harmless wildlife.",
	kill_desc_melee = "pecked to death",
}

--Fixing up sounds
local FixSounds = function()
	beings["chicken"].sound_die   = core.resolve_sound_id("chicken.die")
	beings["chicken"].sound_act   = core.resolve_sound_id("chicken.act")
	beings["chicken"].sound_hit   = core.resolve_sound_id("chicken.hit")
	beings["chicken"].sound_melee = core.resolve_sound_id("chicken.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)