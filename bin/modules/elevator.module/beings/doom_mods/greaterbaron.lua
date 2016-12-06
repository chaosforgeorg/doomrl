--The greater baron is part of the baron pack.  It is actually a boss enemy.  Visually it's a lot bigger than most enemies; gameplay-wise the difference is it fires spread acid and has boss level HP.
register_being "greaterbaron" {
	name         = "greater baron",
	ascii        = "B",
	color        = LIGHTBLUE,
	sprite       = 0,
	hp           = 160,
	armor        = 3,
	speed        = 100,
	attackchance = 60,
	todam        = 8,
	tohit        = 6,
	min_lev      = 15,
	corpse       = true,
	danger       = 16,
	weight       = 6,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "baron_ai",

	resist = { acid = 50 },

	desc            = "Greater barons are what you get when a regular baron has pituitary gland issues. They are big, and that's the main thing they have going.",
	kill_desc       = "slain by a greater baron",
	kill_desc_melee = "slain by a greater baron",

	weapon = {
		damage     = "4d5",
		damagetype = DAMAGE_ACID,
		radius     = 2,
		flags      = { IF_SPREAD },
		missile = {
			sound_id   = "greaterbaron",
			ascii      = "*",
			color      = COLOR_ACID,
			sprite     = 0,
			delay      = 35,
			miss_base  = 35,
			miss_dist  = 4,
			expl_delay = 40,
			expl_color = GREEN,
		},
	},
}

--Fixing up sounds
local FixSounds = function()
	beings["greaterbaron"].sound_hit = core.resolve_sound_id("belphegor.hit")
	beings["greaterbaron"].sound_die = core.resolve_sound_id("baron.die")
	beings["greaterbaron"].sound_act = core.resolve_sound_id("baron.act")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
