--A skeleton dragon.  Yawn.  How quaint.
register_being "skeletondragon" {
	name         = "skeletal dragon",
	ascii        = "D",
	color        = LIGHTGRAY,
	sprite       = 0,
	hp           = 70,
	armor        = 0,
	speed        = 120,
	todam        = 6,
	tohit        = 3,
	min_lev      = 14,
	corpse       = true,
	danger       = 10,
	weight       = 4,
	bulk         = 100,
	flags        = { BF_ENVIROSAFE },
	ai_type      = "melee_ranged_ai",

	resist = { bullet = 75, shrapnel = 50 },

	desc            = "Skeletal dragons are like their flesh and blood counterparts except they don't have flesh or blood. Bullets go straight through.",
	kill_desc       = "burninated by a skeletal dragon",
	kill_desc_melee = "eaten by a skeletal dragon",

	weapon = {
		damage     = "2d5",
		damagetype = DAMAGE_FIRE,
		fire       = 10,
		shots      = 3,
		radius     = 1,
		flags      = { IF_NODROP, IF_NOAMMO, IF_SCATTER },
		missile = {
			sound_id   = "skeletondragon",
			ascii      = "*",
			color      = LIGHTRED,
			sprite     = SPRITE_ACIDSHOT,
			delay      = 20,
			miss_base  = 50,
			miss_dist  = 4,
			range      = 7,
			expl_delay = 40,
			expl_color = RED,
		},
	},
}

--Fixing up sounds
local FixSounds = function()
	beings["skeletondragon"].sound_die  = core.resolve_sound_id("skeletondragon.die")
	beings["skeletondragon"].sound_act  = core.resolve_sound_id("skeletondragon.act")
	beings["skeletondragon"].sound_fire = core.resolve_sound_id("skeletondragon.fire")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
