--An upside down rev.  Identical to the regular one in most ways.

register_being "urevenant" {
	name         = "+ueua^aj",
	name_plural  = "s+ueua^aj",
	sound_id     = "revenant",
	ascii        = "4",
	color        = WHITE,
	sprite       = SPRITE_REVENANT,
	hp           = 30,
	armor        = 2,
	attackchance = 50,
	todam        = 6,
	tohit        = 4,
	speed        = 120,
	min_lev      = 13,
	corpse       = true,
	danger       = 12,
	weight       = 5,
	bulk         = 100,
	flags        = { },
	ai_type      = "ranged_ai",

	resist = { fire = 25, bullet = 50 },

	desc            = "Apparently when a demon dies, they pick him up, dust him off, wire him some combat gear, and send him back into battle. No rest for the wicked, eh? You wish your missiles did what his can do.",
	kill_desc       = "couldn't evade a s,+ueua^aj fireball",
	kill_desc_melee = "was punched by a +ueua^aj",

	OnCreate = function (self)
		self.eq.weapon = item.new("nat_revenant")
		self.inv:add( "rocket" )
		self.dodgebonus = self.dodgebonus + 2
	end,
}
