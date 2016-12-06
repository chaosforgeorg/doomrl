--Gargoyles and fire gargoyles come from heretic.  They are like imps in Doom, except the basic gargoyle doesn't even get a projectile.

register_being "firegargoyle" {
	name         = "fire gargoyle",
	ascii        = "g",
	color        = LIGHTRED,
	sprite       = 0,
	hp           = 15,
	attackchance = 50,
	armor        = 0,
	speed        = 180,
	todam        = 2,
	tohit        = 2,
	tohitmelee   = 2,
	min_lev      = 2,
	max_lev      = 17,
	corpse       = true,
	danger       = 2,
	weight       = 6,
	bulk         = 100,
	flags        = { BF_CHARGE, BF_ENVIROSAFE },
	ai_type      = "melee_ranged_ai",

	resist = { fire = 40 },

	desc            = "As if flying demons weren't enough, Fire Gargoyles toss balls of fire down on their unsuspecting enemy.",
	kill_desc       = "scarred by a gargoyle.",
	kill_desc_melee = "hacked by a gargoyle.",

	weapon = {
		damage     = "2d5",
		damagetype = DAMAGE_FIRE,
		fire       = 18,
		radius     = 0,
		flags      = { },
		missile = {
			sound_id   = "firegargoyle",
			ascii      = "*",
			color      = LIGHTRED,
			sprite     = 233,
			delay      = 35,
			miss_base  = 50,
			miss_dist  = 5,
			expl_delay = 40,
			expl_color = RED,
		},
	},
}

--Fixing up sounds
local FixSounds = function()
	beings["firegargoyle"].sound_die   = core.resolve_sound_id("firegargoyle.die")
	beings["firegargoyle"].sound_act   = core.resolve_sound_id("firegargoyle.act")
	beings["firegargoyle"].sound_hit   = core.resolve_sound_id("firegargoyle.hit")
	beings["firegargoyle"].sound_attack= core.resolve_sound_id("firegargoyle.fire")
	beings["firegargoyle"].sound_melee = core.resolve_sound_id("firegargoyle.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
