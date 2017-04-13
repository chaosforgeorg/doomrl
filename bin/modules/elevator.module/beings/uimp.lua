--An upside down imp.  Identical to the regular one in most ways.

register_being "uimp" {
	name         = "dw!",
	name_plural  = "sdw!",
	sound_id     = "imp",
	ascii        = "!",
	color        = BROWN,
	sprite       = SPRITE_IMP,
	hp           = 12,
	attackchance = 40,
	todam        = 2,
	tohit        = 3,
	speed        = 105,
	min_lev      = 0,
	max_lev      = 17,
	corpse       = true,
	danger       = 2,
	weight       = 8,
	bulk         = 100,
	flags        = { },
	ai_type      = "melee_ranged_ai",

	resist = { fire = 25 },

	desc            = "Brown demonic servants from hell, sdw! can cast fireballs at you. They're tough, mean and strong, and think only about sending you into oblivion...",
	kill_desc       = "was burned by an dw!",
	kill_desc_melee = "was slashed by an dw!",

	OnCreate = function (self)
		self.eq.weapon = item.new("nat_imp")
		self.dodgebonus = self.dodgebonus + 2
	end,
}
