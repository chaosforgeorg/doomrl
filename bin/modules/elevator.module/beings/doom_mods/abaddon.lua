--The abaddon is in Skulltag, possibly other mods since it's just a recolored caco.
register_being "abaddon" {
	name         = "abaddon",
	id           = "abaddon",
	ascii        = "O",
	color        = LIGHTBLUE, --A good 'black'
	sprite       = SPRITE_PAIN,
	overlay      = { 0.5,0.7,1.0,1.0 },
	glow         = { 0.0,0.0,0.0,1.0 },
	hp           = 80,
	armor        = 2,
	speed        = 110,
	attackchance = 60,
	todam        = 8,
	tohit        = 6,
	min_lev      = 16,
	corpse       = "corpse",
	--corpse       = "abaddoncorpse",
	--corpse       = true,
	danger       = 14,
	weight       = 5,
	bulk         = 100,
	flags        = { BF_ENVIROSAFE },
	ai_type      = "melee_ranged_ai",

	desc            = "Abaddons are the toughest cacodemons around.  Lurking in the deepest corners of Hell abaddon's are rarely seen by anyone who lives to tell the tale.",
	kill_desc       = "smitten by an abaddon",
	kill_desc_melee = "became food for an abaddon",

	weapon = {
		damage     = "3d8",
		damagetype = DAMAGE_PLASMA,
		radius     = 1,
		missile = {
			sound_id   = "abaddon",
			ascii      = "*",
			color      = COLOR_LAVA,
			sprite     = SPRITE_PLASMABALL,
			delay      = 20,
			miss_base  = 20,
			miss_dist  = 2,
			expl_delay = 40,
			expl_color = MAGENTA,
		},
	},
}

--Fixing up sounds
local FixSounds = function()
	beings["abaddon"].sound_hit = core.resolve_sound_id("cacodemon.hit")
	beings["abaddon"].sound_die = core.resolve_sound_id("cacodemon.die")
	beings["abaddon"].sound_act = core.resolve_sound_id("cacodemon.act")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)