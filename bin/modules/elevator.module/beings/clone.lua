require("elevator:ai/marine_ai")

register_being "clone"
{
	name         = "soldier",
	sound_id     = "soldier",
	ascii        = "@" ,
	color        = LIGHTGRAY,
	sprite       = SPRITE_PLAYER,
	hp           = 100,
	min_lev      = 200,
	corpse       = false,
	danger       = 0,
	weight       = 0,
	xp           = 0,
	flags        = { BF_OPENDOORS },
	desc         = "You're a soldier. One of the best that the world could set against the demonic invasion.",
	ai_type      = "marine_ai",
}
