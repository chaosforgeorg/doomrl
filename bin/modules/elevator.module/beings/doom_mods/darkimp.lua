--The dark imp is partially based on standard skulltag reskinning but largely comes from KDIZD.
register_being "darkimp" {
	name         = "dark imp",
	ascii        = "i",
	color        = LIGHTBLUE, --blue replacement
	sprite       = SPRITE_IMP,
	overlay      = { 0.5, 0.8, 1.0, 1.0 },
	glow         = { 0.2,0.2,0.3,1.0 },
	hp           = 35,
	todam        = 4,
	tohit        = 4,
	speed        = 115,
	min_lev      = 8,
	corpse       = true,
	danger       = 6,
	weight       = 9,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "melee_ranged_ai",

  resist = { fire = 50 },

	desc            = "Dark imps hurl blue fireballs instead of red ones.  Other than that they're not much tougher than their brown counterparts.",
	kill_desc       = "burned by a dark imp",
	kill_desc_melee = "slashed by a dark imp",

	weapon = {
		damage     = "2d5",
		damagetype = DAMAGE_FIRE,
		radius     = 1,
		missile = {
			sound_id   = "darkimp",
			ascii      = "*",
			color      = LIGHTBLUE,
			sprite     = SPRITE_FIREBALL,
			delay      = 30,
			miss_base  = 50,
			miss_dist  = 4,
			expl_delay = 40,
			expl_color = LIGHTBLUE,
		},
	},
}

--Fixing up sounds
local FixSounds = function()
	beings["darkimp"].sound_die    = core.resolve_sound_id("darkimp.die")
	beings["darkimp"].sound_act    = core.resolve_sound_id("darkimp.act")
	beings["darkimp"].sound_attack = core.resolve_sound_id("darkimp.fire")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
