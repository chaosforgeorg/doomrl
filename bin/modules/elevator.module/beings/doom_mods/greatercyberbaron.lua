--The greater baron is part of the baron pack.  It is actually a boss enemy.  Visually it's a lot bigger than most enemies; gameplay-wise the difference is it fires spread acid and has boss level HP.
register_being "greatercyberbaron" {
	name         = "greater cyberbaron",
	ascii        = "B",
	color        = LIGHTBLUE,
	sprite       = 0,
	hp           = 160,
	armor        = 3,
	speed        = 100,
	attackchance = 50,
	todam        = 8,
	tohit        = 6,
	min_lev      = 15,
	corpse       = true,
	danger       = 18,
	weight       = 6,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "baron_ai",

	resist = { acid = 50 },

	desc            = "Greater cyberbarons are what you get when a regular baron has pituitary gland issues AND really likes cyberpunk.  Not much can stand in the way of one of these.",
	kill_desc       = "slain by a greater cyberbaron",
	kill_desc_melee = "slain by a greater cyberbaron",

	weapon = {
		damage     = "6d6",
		damagetype = DAMAGE_FIRE,
		radius     = 3,
		flags      = { IF_SPREAD },
		missile = {
			sound_id   = "bazooka",
			color      = BROWN,
			sprite     = 228,
			delay      = 30,
			miss_base  = 30,
			miss_dist  = 5,
			expl_delay = 40,
			expl_color = RED,
		},
	},
}

--Fixing up sounds
local FixSounds = function()
	beings["greatercyberbaron"].sound_hit = core.resolve_sound_id("belphegor.hit")
	beings["greatercyberbaron"].sound_die = core.resolve_sound_id("baron.die")
	beings["greatercyberbaron"].sound_act = core.resolve_sound_id("baron.act")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
