--The arch-lich hallucination should visually match the arch-lich (at least at the time of conception) but is incapable of being damaged or causing damage.
require("elevator:ai/archlich_hallu_ai")

register_being "archlich_hallu" {
	name         = "arch-lich",
	sound_id     = "archlich",
	ascii        = "L",
	color        = LIGHTRED,
	sprite       = 0,
	hp           = 1000,
	armor        = 3,
	speed        = 160,
	attackchance = 10,
	todam        = -15, --We fake melee attacks in the AI
	tohit        = 8,
	min_lev      = 200,
	corpse       = false,
	danger       = 50,
	weight       = 0,
	bulk         = 100,
	xp           = 0,
	flags        = { BF_OPENDOORS, BF_UNIQUENAME, BF_SELFIMMUNE, BF_KNOCKIMMUNE, BF_ENVIROSAFE },
	ai_type      = "archlich_hallu_ai",

	desc            = "The arch-lich is one of the most powerful creatures across time and space. Go kill it.",
	kill_desc       = "feared the arch-lich",
	kill_desc_melee = "feared the arch-lich",

	weapon = {
		damage     = "0d0",
		damagetype = DAMAGE_FIRE,
		fire       = 11,
		radius     = 2,
		shots      = 1,
		missile = {
			sound_id    = "archlich3",
			ascii       = '*',
			color       = LIGHTRED,
			sprite      = 0,
			delay       = 25,
			miss_base   = 25,
			miss_dist   = 5,
			expl_delay  = 25,
			expl_color  = COLOR_LAVA,
		},
	},

	OnCreate = function (self)
		self.flags[ BF_INV ] = true
		self:add_property( "illusion_lifespan", 0 )
	end,

	OnAction = function(self)
		self.illusion_lifespan = self.illusion_lifespan - 1
		if self.illusion_lifespan <= 0 then
			self.flags[ BF_INV ] = false
			level:explosion( self.position, 2, 50, 0, 0, MAGENTA )
			self:kill()
		end
	end,
}
