--Another natural upgrade from Skulltag that's just a recolored version of the original.
--No rockets either.  Acid throwers don't have anything useful to drop.

register_being "hectebus" {
	name         = "hectebus",
	name_plural  = "hectebi",
	ascii        = "M",
	color        = LIGHTBLUE, --Substituting for black
	sprite       = SPRITE_MANCUBUS,
	overlay      = { 0.5,0.7,1.0,1.0 },
	glow         = { 0.3,0.3,0.3,1.0 },
	hp           = 70,
	armor        = 3,
	attackchance = 40,
	todam        = 9,
	tohit        = 3,
	speed        = 80,
	min_lev      = 19,
	corpse       = true,
	danger       = 13,
	weight       = 5,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "sequential_ai",

	desc            = "What's big, ugly, and fires acid? This thing. Better steer clear if you want to live to talk about it.",
	kill_desc       = "cremated by a hectebus",
	kill_desc_melee = "squashed by a hectebus",

	weapon = {
		damage     = "4d5",
		damagetype = DAMAGE_ACID,
		radius     = 2,
		fire       = 10,
		flags      = { IF_SPREAD },
		missile = {
			sound_id   = "hectebus",
			ascii      = "*",
			color      = LIGHTGREEN,
			sprite     = SPRITE_ROCKETSHOT,
			delay      = 30,
			miss_base  = 1,
			miss_dist  = 3,
			expl_delay = 50,
			expl_color = GREEN,
		},
	},

	OnCreate = function (self)
		self.inv:add( "rocket" )
	end
}

--Fixing up sounds
local FixSounds = function()
	beings["hectebus"].sound_hit = core.resolve_sound_id("mancubus.hit")
	beings["hectebus"].sound_die = core.resolve_sound_id("mancubus.die")
	beings["hectebus"].sound_act = core.resolve_sound_id("mancubus.act")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)