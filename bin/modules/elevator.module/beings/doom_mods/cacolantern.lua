--The cacolantern is in Skulltag, possibly other mods since it's just a recolored caco.
register_being "cacolantern" {
	name         = "cacolantern",
	ascii        = "O",
	color        = YELLOW,
	sprite       = SPRITE_CACODEMON,
	overlay      = { 0.7, 1.0, 0.3, 1.0 },
	glow         = { 0.7,0.5,0.0,1.0 },
	hp           = 60,
	armor        = 1,
	speed        = 120,
	attackchance = 50,
	todam        = 6,
	tohit        = 6,
	min_lev      = 13,
	corpse       = true,
	danger       = 9,
	weight       = 7,
	bulk         = 100,
	flags        = { BF_ENVIROSAFE },
	ai_type      = "melee_ranged_ai",

	desc            = "Cacolanters are said to be colored by the flames of Hell itself.  They're a bit tougher cacodemons and their fireballs are nearly twice as fast.",
	kill_desc       = "smitten by an cacolantern",
	kill_desc_melee = "got too close to a cacolantern",

	weapon = {
		damage     = "2d8",
		damagetype = DAMAGE_PLASMA,
		radius     = 1,
		missile = {
			sound_id   = "cacolantern",
			ascii      = "*",
			color      = LIGHTBLUE,
			sprite     = SPRITE_PLASMABALL,
			delay      = 20,
			miss_base  = 50,
			miss_dist  = 4,
			expl_delay = 40,
			expl_color = BLUE,
		},
	},
}

--Fixing up sounds
local FixSounds = function()
	beings["cacolantern"].sound_hit = core.resolve_sound_id("cacodemon.hit")
	beings["cacolantern"].sound_die = core.resolve_sound_id("cacodemon.die")
	beings["cacolantern"].sound_act = core.resolve_sound_id("cacodemon.act")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)