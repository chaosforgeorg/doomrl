--Skeleton archers have been represented in a lot of different games, and I can't find the source used by EoD's graphics.  I consider this to be a slightly hardier former human, but one that doesn't drop anything useful and is harder to kill since most players will be runnig on bullet and shrapnel damage early on.
register_being "skeletonarcher" {
	name         = "skeleton archer",
	ascii        = "Z",
	color        = LIGHTGRAY,
	sprite       = 0,
	hp           = 15,
	armor        = 0,
	speed        = 100,
	todam        = 2,
	tohit        = 2,
	min_lev      = 2,
	max_lev      = 18,
	corpse       = true,
	danger       = 4,
	weight       = 6,
	bulk         = 100,
	flags        = { },
	ai_type      = "ranged_ai",

	resist = { bullet = 75, shrapnel = 50 },

	desc            = "Not much is holding skeleton archers together but their lack of internal organs does mean a good solid punch can sometimes be more effective than a bullet.",
	kill_desc       = "sniped by a skeleton archer",
	kill_desc_melee = "beaten by a skeleton archer",

	weapon = {
		damage     = "2d5",
		damagetype = DAMAGE_BULLET,
		fire       = 10,
		flags      = { },
		missile = {
			sound_id   = "skeletonarcher",
			ascii      = "-",
			color      = LIGHTGRAY,
			sprite     = 0,
			delay      = 15,
			miss_base  = 10,
			miss_dist  = 10,
		},
	},
}

--Fixing up sounds
local FixSounds = function()
	beings["skeletonarcher"].sound_die   = core.resolve_sound_id("skeletonarcher.die")
	beings["skeletonarcher"].sound_act   = core.resolve_sound_id("skeletonarcher.act")
	beings["skeletonarcher"].sound_attack= core.resolve_sound_id("skeletonarcher.fire")
	beings["skeletonarcher"].sound_melee = core.resolve_sound_id("revenant.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
