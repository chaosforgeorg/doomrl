--The rocketeer is part of the logical progression involving former humans
register_being "rocketeer" {
	name         = "former specialist",
	id           = "rocketeer",
	ascii        = "h",
	color        = BROWN,
	sprite       = SPRITE_PLAYER_BAZOOKA,
	coscolor     = { 0.8,0.6,0.5,1.0 },
	hp           = 20,
	armor        = 1,
	speed        = 100,
	todam        = 2,
	tohit        = 1,
	min_lev      = 11,
	max_lev      = 25,
	corpse       = true,
	danger       = 7,
	weight       = 7,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "former_ai",

	resist = { fire = 20 },

	desc            = "Demolitions experts are as dangerous to themselves as they are to you.",
	kill_desc       = "splattered by a specialist's rocket",
	kill_desc_melee = "maimed by a former specialist",

	OnCreate = function(self)
		self.eq.weapon = item.new("bazooka")
		self.inv:add( item.new("rocket"), { ammo = 3 } )
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["rocketeer"].sound_hit   = core.resolve_sound_id("former.pain")
	beings["rocketeer"].sound_die   = core.resolve_sound_id("commando.die")
	beings["rocketeer"].sound_act   = core.resolve_sound_id("former.act")
	beings["rocketeer"].sound_melee = core.resolve_sound_id("soldier.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
