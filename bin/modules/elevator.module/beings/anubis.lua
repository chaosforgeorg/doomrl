--Anubis appears to be a custom being to serve as round 1's Elevator boss.  Who knows where the graphic was lifted from.  The sounds could be better though.
--In EoD the projectile bounces.  A lot.  Can't do that here though.
register_being "anubis" {
	name         = "anubis minister",
	ascii        = "L",
	color        = LIGHTGRAY,
	sprite       = 0,
	hp           = 80,
	armor        = 2,
	speed        = 110,
	todam        = 6,
	tohit        = 3,
	min_lev      = 14,
	corpse       = false,
	danger       = 13,
	weight       = 3,
	bulk         = 100,
	flags        = { },
	ai_type      = "ranged_ai",

	resist = { bullet = 10, shrapnel = 10, fire = 10 },

	desc            = "You have desecrated the tombs of the Pharaohs. The ministers of Anubis seek revenge.",
	kill_desc       = "blasted by an Anubis minister",
	kill_desc_melee = "whacked by an Anubis minister",

	weapon = {
		damage     = "3d6",
		damagetype = DAMAGE_PLASMA,
		radius     = 2,
		flags      = { IF_AUTOHIT },
		missile = {
			sound_id   = "anubis",
			ascii      = "*",
			color      = GREEN,
			sprite     = 0,
			delay      = 25,
			miss_base  = 20,
			miss_dist  = 5,
			range      = 5,
			expl_delay = 30,
			expl_color = LIGHTGREEN,
		},
	},
}

--Fixing up sounds
local FixSounds = function()
	beings["anubis"].sound_die   = core.resolve_sound_id("anubis.die")
	beings["anubis"].sound_act   = core.resolve_sound_id("anubis.act")
	beings["anubis"].sound_hit   = core.resolve_sound_id("anubis.hit")
	beings["anubis"].sound_fire  = core.resolve_sound_id("anubis.fire")
	beings["anubis"].sound_melee = core.resolve_sound_id("anubis.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
