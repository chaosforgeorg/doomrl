--A Search and Destroy orb.  I have no idea where it's from.
register_being "sdorb" {
	name         = "search & destroy orb",
	ascii        = "o",
	color        = LIGHTMAGENTA,
	sprite       = 0,
	hp           = 40,
	armor        = 2,
	speed        = 50,
	attackchance = 50,
	todam        = 4,
	tohit        = 2,
	min_lev      = 5,
	max_lev      = 20,
	corpse       = false,
	danger       = 6,
	weight       = 8,
	bulk         = 100,
	flags        = { BF_ENVIROSAFE },
	ai_type      = "ranged_ai",

	desc            = "Search and Destroy orbs like to search, then destroy.  Knock them out of the air fast or they'll turn you into a crispy critter.",
	kill_desc       = "found by a search & destroy orb",
	kill_desc_melee = "found by a search & destroy orb",

	weapon = {
		damage     = "1d4",
		damagetype = DAMAGE_PLASMA,
		shots      = 6,
		missile = {
			sound_id   = "sdorb",
			ascii      = "*",
			color      = MULTIBLUE,
			sprite     = SPRITE_PLASMASHOT,
			delay      = 10,
			miss_base  = 30,
			miss_dist  = 4,
		},
	},
}

--Fixing up sounds
local FixSounds = function()
	beings["sdorb"].sound_hit   = core.resolve_sound_id("sdorb.hit")
	beings["sdorb"].sound_die   = core.resolve_sound_id("sdorb.die")
	beings["sdorb"].sound_act   = core.resolve_sound_id("sdorb.act")
	items["nat_sdorb"].sound_fire  = core.resolve_sound_id("sdorb.fire")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)