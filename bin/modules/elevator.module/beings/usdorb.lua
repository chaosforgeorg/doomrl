--An upside down S&D Orb
require("elevator:beings/sdorb")

register_being "usdorb" {
	name         = "qjo hoj+sap 9 y>jeas",
	name_plural  = "sqjo hoj+sap 9 y>jeas",
	sound_id     = "sdorb",
	ascii        = "§",
	color        = LIGHTMAGENTA,
	sprite       = 0,
	hp           = 40,
	armor        = 2,
	speed        = 50,
	attackchance = 50,
	todam        = 4,
	tohit        = 2,
	min_lev      = 5,
	max_lev      = 20,
	corpse       = false,
	danger       = 6,
	weight       = 8,
	bulk         = 100,
	flags        = { BF_ENVIROSAFE },
	ai_type      = "ranged_ai",

	desc            = "sqjo hoj+sa|) 9 y>jeaS orbs like to search, then destroy.  Knock them out of the air fast or they'll turn you into a crispy critter.",
	kill_desc       = "found by a qjo hoj+sap 9 y>jeas",
	kill_desc_melee = "found by a qjo hoj+sap 9 y>jeas",

	OnCreate = function (self)
		self.eq.weapon = item.new("nat_sdorb")
		self.dodgebonus = self.dodgebonus + 2
	end
}

--Fixing up sounds
local FixSounds = function()
	beings["usdorb"].sound_hit   = core.resolve_sound_id("sdorb.hit")
	beings["usdorb"].sound_die   = core.resolve_sound_id("sdorb.die")
	beings["usdorb"].sound_act   = core.resolve_sound_id("sdorb.act")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)