--I first encountered the cacolich in the skulltag mod Elevator of Dimensions but it dates back to some resource wad.  Cacoliches are brown (minor problem if you're also using pain elementals), they shoot acidic blasts, and they're fairly fragile.
register_being "cacolich" {
	name         = "cacolich",
	ascii        = "O",
	color        = BROWN,
	sprite       = 0,
	hp           = 50,
	armor        = 0,
	speed        = 120,
	attackchance = 60,
	todam        = 4,
	tohit        = 3,
	min_lev      = 8,
	max_lev      = 37,
	corpse       = true,
	danger       = 5,
	weight       = 8,
	bulk         = 100,
	flags        = { BF_ENVIROSAFE },
	ai_type      = "ranged_ai",

	resist = { acid = 15 },

	desc            = "Cacoliches are ugly and undead. They're also more fragile than their living counterparts.",
	kill_desc       = "blasted by a cacolich",
	kill_desc_melee = "got too close to a cacolich",

	weapon = {
		damage     = "2d6",
		damagetype = DAMAGE_ACID,
		radius     = 1,
		fire       = 11,
		missile = {
			sound_id   = "cacolich",
			ascii      = "*",
			color      = LIGHTGREEN,
			sprite     = 0,
			delay      = 20,
			miss_base  = 40,
			miss_dist  = 3,
			expl_delay = 40,
			expl_color = GREEN,
		},
	},
}

--Fixing up sounds
local FixSounds = function()
	beings["cacolich"].sound_hit   = core.resolve_sound_id("cacolich.hit")
	beings["cacolich"].sound_die   = core.resolve_sound_id("cacolich.die")
	beings["cacolich"].sound_act   = core.resolve_sound_id("cacolich.act")
	beings["cacolich"].sound_attack= core.resolve_sound_id("cacolich.fire")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
