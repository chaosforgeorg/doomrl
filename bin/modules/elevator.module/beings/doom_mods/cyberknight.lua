--Part of the baron combo pack.  Identical to the regular knight except shoots rockets instead of acid.  More dangerous than a knight, less than a baron.
register_being "cyberknight" {
	name         = "cyber hell knight",
	ascii        = "B",
	color        = BROWN,
	sprite       = 74,
	hp           = 50,
	armor        = 1,
	attackchance = 40,
	todam        = 6,
	tohit        = 6,
	speed        = 110,
	min_lev      = 11,
	corpse       = true,
	danger       = 8,
	weight       = 6,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "baron_ai",

	resist = { acid = 50 },

	desc            = "These are hell's warlords. They command hellish armies to battle. Not as tough as Barons but still a pain in the ass...",
	kill_desc       = "was splayed by a cyber hell knight",
	kill_desc_melee = "was slashed by a cyber hell knight",

	weapon = {
		damage     = "3d5",
		damagetype = DAMAGE_FIRE,
		radius     = 2,
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
	end
}

--Fixing up sounds
local FixSounds = function()
	beings["cyberknight"].sound_hit = core.resolve_sound_id("knight.hit")
	beings["cyberknight"].sound_die = core.resolve_sound_id("knight.die")
	beings["cyberknight"].sound_act = core.resolve_sound_id("knight.act")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
