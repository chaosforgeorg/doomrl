--Part of the baron combo pack.  Identical to the regular baron except shoots rockets instead of acid.  More dangerous than a baron, less than a belphie.
register_being "cyberbaron" {
	name         = "cyber baron of hell",
	name_plural  = "cyber barons of hell",
	ascii        = "B",
	color        = LIGHTMAGENTA,
	sprite       = 75,
	hp           = 60,
	armor        = 2,
	attackchance = 40,
	todam        = 8,
	tohit        = 5,
	speed        = 100,
	min_lev      = 14,
	corpse       = true,
	danger       = 12,
	weight       = 6,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "baron_ai",

	resist = { acid = 50 },

	desc            = "Huge, almost humanoid, rocket hurling monsters from your worst nightmares. They are the nobility of hell.",
	kill_desc       = "was bruised by a cyber baron",
	kill_desc_melee = "was ripped to shreds by a cyber baron",

	weapon = {
		damage     = "5d5",
		damagetype = DAMAGE_FIRE,
		radius     = 3,
		missile = {
			sound_id   = "bazooka",
			color      = BROWN,
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
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["cyberbaron"].sound_hit = core.resolve_sound_id("baron.hit")
	beings["cyberbaron"].sound_die = core.resolve_sound_id("baron.die")
	beings["cyberbaron"].sound_act = core.resolve_sound_id("baron.act")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
