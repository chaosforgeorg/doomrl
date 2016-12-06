--The octabrain comes from Duke and they're pretty weak fodder.
register_being "duke_octabrain" {
	name         = "octabrain",
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

--Fixing up sounds
local FixSounds = function()
	beings["duke_octabrain"].sound_hit    = core.resolve_sound_id("duke_octabrain.hit")
	beings["duke_octabrain"].sound_die    = core.resolve_sound_id("duke_octabrain.die")
	beings["duke_octabrain"].sound_act    = core.resolve_sound_id("duke_octabrain.act")
	beings["duke_octabrain"].sound_attack = core.resolve_sound_id("duke_octabrain.fire")
	beings["duke_octabrain"].sound_melee  = core.resolve_sound_id("duke_octabrain.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)