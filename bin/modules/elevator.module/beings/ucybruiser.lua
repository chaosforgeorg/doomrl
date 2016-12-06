--An upside down cybruiser
require("elevator:beings/doom_mods/cybruiser")

register_being "ucybruiser" {
	name         = "jas!njqh>",
	name_plural  = "sjas!njqh>",
	sound_id     = "cybruiser",
	ascii        = "3",
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
	flags        = { },
	ai_type      = "baron_ai",

	resist = { fire = 25 },

	desc            = "Cybernetic foot soldiers that throw out rockets like candy.",
	kill_desc       = "was bruised by a jas!njqh>",
	kill_desc_melee = "was ripped to shreds by a jas!njqh>",

	OnCreate = function (self)
		self.eq.weapon = item.new("nat_cybruiser")
		self.inv:add( "rocket" )
		self.dodgebonus = self.dodgebonus + 2
	end
}

--Fixing up sounds
local FixSounds = function()
	beings["ucybruiser"].sound_hit  = core.resolve_sound_id("baron.hit")
	beings["ucybruiser"].sound_die  = core.resolve_sound_id("cybruiser.die")
	beings["ucybruiser"].sound_act  = core.resolve_sound_id("cybruiser.act")
	beings["ucybruiser"].sound_hoof = core.resolve_sound_id("cybruiser.hoof")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
