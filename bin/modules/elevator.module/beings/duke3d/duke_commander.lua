--Duke enemies.  Trooper/Captain == former/imp, pig == sergeant, enforcer == captain, commander == something higher up

register_being "duke_commander" {
	name         = "commander",
	ascii        = "O",
	color        = BROWN,
	sprite       = 0,
	hp           = 60,
	armor        = 1,
	attackchance = 40,
	todam        = 6,
	tohit        = 6,
	speed        = 100,
	min_lev      = 10,
	max_lev      = 30,
	corpse       = true,
	danger       = 6,
	weight       = 7,
	bulk         = 100,
	flags        = { BF_OPENDOORS, BF_ENVIROSAFE },
	ai_type      = "melee_ranged_ai",

	desc            = "This guy is so fat he needs his own floating spike platform to move around. Keep your distance and he'll rocket you. Get too close and he'll spin like a top and slice you to ribbons.",
	kill_desc       = "blown away by a commander",
	kill_desc_melee = "diced by a commander",

	weapon = {
		damage     = "4d5",
		damagetype = DAMAGE_FIRE,
		radius     = 2,
		missile = {
			sound_id   = "duke_commander",
			ascii      = "-",
			color      = BROWN,
			sprite     = SPRITE_ROCKETSHOT,
			delay      = 30,
			miss_base  = 30,
			miss_dist  = 6,
			expl_delay = 40,
			expl_color = RED,
		},
	},
}

--Fixing up sounds
local FixSounds = function()
	beings["duke_commander"].sound_hit   = core.resolve_sound_id("duke_commander.hit")
	beings["duke_commander"].sound_die   = core.resolve_sound_id("duke_commander.die")
	beings["duke_commander"].sound_act   = core.resolve_sound_id("duke_commander.act")
	beings["duke_commander"].sound_attack= core.resolve_sound_id("duke_commander.fire")
	beings["duke_commander"].sound_melee = core.resolve_sound_id("duke_commander.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)