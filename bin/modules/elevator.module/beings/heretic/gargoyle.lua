--Gargoyles and fire gargoyles come from heretic.  They are like imps in Doom, except the basic gargoyle doesn't even get a projectile.

register_being "gargoyle" {
	name         = "gargoyle",
	ascii        = "g",
	color        = RED,
	sprite       = 0,
	hp           = 10,
	attackchance = 50,
	armor        = 0,
	speed        = 180,
	todam        = 2,
	tohit        = 4,
	min_lev      = 0,
	max_lev      = 15,
	corpse       = true,
	danger       = 1,
	weight       = 8,
	bulk         = 100,
	flags        = { BF_CHARGE, BF_ENVIROSAFE },
	ai_type      = "melee_seek_ai",

	resist = { fire = 15 },

	desc            = "Half-demon and half-bat, these wicked red beasts are the Order's guard dogs of the sky.",
	kill_desc       = "scarred by a gargoyle.",
	kill_desc_melee = "hacked by a gargoyle.",
}

--Fixing up sounds
local FixSounds = function()
	beings["gargoyle"].sound_die   = core.resolve_sound_id("gargoyle.die")
	beings["gargoyle"].sound_act   = core.resolve_sound_id("gargoyle.act")
	beings["gargoyle"].sound_hit   = core.resolve_sound_id("gargoyle.hit")
	beings["gargoyle"].sound_melee = core.resolve_sound_id("gargoyle.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
