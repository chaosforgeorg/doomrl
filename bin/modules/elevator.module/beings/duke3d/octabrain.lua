--The octabrain comes from Duke and they're pretty weak fodder.
Beings{
	name         = "octabrain",
	id           = "octabrain",
	ascii        = "Q",
	color        = BROWN,
	sprite       = 0,
	hp           = 17,
	armor        = 1,
	speed        = 100,
	todam        = 3,
	tohit        = 1,
	min_lev      = 4,
	max_lev      = 14,
	corpse       = true,
	danger       = 3,
	weight       = 4,
	bulk         = 100,
	flags        = { BF_ENVIROSAFE },
	ai_type      = "melee_ranged_ai",

	desc            = "An octabrain is a large floating brain with tentacles. It often lurks in the shadows and uses psychic powers to attack.",
	kill_desc       = "killed by an Octabrain",
	kill_desc_melee = "eaten alive by an Octabrain",

	weapon = {
		damage     = "1d9",
		damagetype = DAMAGE_PLASMA,
		missile = {
			sound_id   = "octabrain",
			ascii      = "o",
			color      = DARKGRAY,
			sprite     = 0,
			delay      = 20,
			miss_base  = 40,
			miss_dist  = 2,
		},
	},
}

--Fixing up sounds (remove this in 0996)
local FixSounds = function()
	beings["octabrain"].sound_hit    = core.resolve_sound_id("octabrain.hit")
	beings["octabrain"].sound_die    = core.resolve_sound_id("octabrain.die")
	beings["octabrain"].sound_act    = core.resolve_sound_id("octabrain.act")
	beings["octabrain"].sound_attack = core.resolve_sound_id("octabrain.fire")
	beings["octabrain"].sound_melee  = core.resolve_sound_id("octabrain.melee")
end
FixAllSounds = create_seq_function(FixSounds, FixAllSounds)