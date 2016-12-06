--The Overlord.  Even bigger and uglier.  The overlord doesn't have the great variety in weapons the battlelord does; he basically has shoulder mounted rocket launchers and that's it.  Since he's basically the cybie I just made him a little bit slower and tougher and called it a day.  Boring, but that's what is there.
require("elevator:ai/duke_overlord_ai")

register_item "nat_duke_overlord" {
	name       = "nat_duke_overlord",
	sprite     = 0,
	weight     = 0,

	type       = ITEMTYPE_NRANGED,
	damage     = "6d6",
	damagetype = DAMAGE_FIRE,
	fire       = 17,
	shots      = 2,
	radius     = 1,
	flags      = { IF_NODROP, IF_NOAMMO },
	missile    = {
		sound_id   = "duke_overlord",
		ascii      = '-',
		color      = RED,
		sprite     = SPRITE_ROCKETSHOT,
		delay      = 30,
		miss_base  = 10,
		miss_dist  = 5,
		range      = 14,
		flags      = { },
		expl_delay = 40,
		expl_color = RED,
	},
}

register_being "duke_overlord" {
	name         = "overlord",
	id           = "",
	ascii        = "O",
	color        = WHITE,
	sprite       = 0,
	hp           = 250,
	armor        = 4,
	attackchance = 40,
	todam        = 15,
	tohit        = 4,
	speed        = 140,
	min_lev      = 200,
	max_lev      = 200,
	corpse       = true,
	danger       = 50,
	weight       = 0,
	bulk         = 100,
	flags        = { F_LARGE, BF_KNOCKIMMUNE },
	ai_type      = "duke_overlord_ai",

	desc            = "The overlord almost looks like a frog. A brown, giant, ugly frog. With claws. And teeth. And rockets. It's agile for its size but with enough firepower he'll go down.",
	kill_desc       = "stood shell shocked in front of the Overlord",
	kill_desc_melee = "caught underneath the Overlord",

	OnCreate = function (self)
		self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 10
		self.hp = self.hpmax

		self.eq.weapon = item.new("nat_duke_overlord")
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["duke_overlord"].sound_hit   = core.resolve_sound_id("duke_overlord.hit")
	beings["duke_overlord"].sound_die   = core.resolve_sound_id("duke_overlord.die")
	beings["duke_overlord"].sound_act   = core.resolve_sound_id("duke_overlord.act")
	beings["duke_overlord"].sound_melee = core.resolve_sound_id("duke_overlord.hoof")
	beings["duke_overlord"].sound_hoof  = core.resolve_sound_id("duke_overlord.hoof")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)