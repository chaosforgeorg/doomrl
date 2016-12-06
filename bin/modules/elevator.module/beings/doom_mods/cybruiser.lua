--Part of the baron combo pack.  Cybruisers are the only really customized cyberbarontype.  They sit somewhere between knights and barons but are faster.
register_being "cybruiser" {
	name         = "cybruiser",
	ascii        = "B",
	color        = WHITE,
	sprite       = 0,
	hp           = 50,
	armor        = 2,
	attackchance = 40,
	todam        = 8,
	tohit        = 5,
	speed        = 120,
	min_lev      = 13,
	corpse       = true,
	danger       = 10,
	weight       = 6,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "baron_ai",

	resist = { fire = 25 },

	desc            = "Cybernetic foot soldiers that throw out rockets like candy.",
	kill_desc       = "was bruised by a cybruiser",
	kill_desc_melee = "was ripped to shreds by a cybruiser",

	weapon = {
		damage     = "4d5",
		damagetype = DAMAGE_FIRE,
		radius     = 2,
		missile = {
			sound_id   = "bazooka",
			color      = RED,
			sprite     = 228,
			delay      = 30,
			miss_base  = 30,
			miss_dist  = 5,
			expl_delay = 40,
			expl_color = RED,
		},
	},

	OnCreate = function (self)
		self.inv:add( "rocket" )
	end
}

--Fixing up sounds
local FixSounds = function()
	beings["cybruiser"].sound_hit  = core.resolve_sound_id("baron.hit")
	beings["cybruiser"].sound_die  = core.resolve_sound_id("cybruiser.die")
	beings["cybruiser"].sound_act  = core.resolve_sound_id("cybruiser.act")
	beings["cybruiser"].sound_hoof = core.resolve_sound_id("cybruiser.hoof")
	items["nat_cybruiser"].sound_fire  = core.resolve_sound_id("cybruiser.fire")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
