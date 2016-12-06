--Part of the baron combo pack.  Identical to the regular belphie except shoots rockets instead of acid.  More dangerous than a belphegor, less than the boss barons.
register_being "cyberbelphegor" {
	name         = "cyber belphegor",
	ascii        = "B",
	color        = RED,
	sprite       = 0,
	hp           = 80,
	armor        = 3,
	attackchance = 30,
	todam        = 8,
	tohit        = 6,
	speed        = 100,
	min_lev      = 17,
	corpse       = true,
	danger       = 16,
	weight       = 6,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "baron_ai",

	resist = { acid = 50 },

	desc            = "Belphegors are powerful demon nobles in Hell.",
	kill_desc       = "slain by a cyber belphegor",
	kill_desc_melee = "ripped to shreds by a cyber belphegor",

	weapon = {
		damage     = "6d6",
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
	beings["cyberbelphegor"].sound_hit = core.resolve_sound_id("belphegor.hit")
	beings["cyberbelphegor"].sound_die = core.resolve_sound_id("knight.die")
	beings["cyberbelphegor"].sound_act = core.resolve_sound_id("knight.act")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
