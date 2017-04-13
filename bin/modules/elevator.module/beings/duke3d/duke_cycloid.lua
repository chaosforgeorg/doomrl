--The Cycloid Emoeror.  Yep, big and a little ugly to boot, this guy fires spreads of mini rockets.  He also has a mind blast attack similar to the octabrain that I have made his close range weapon.
require("elevator:ai/duke_cycloid_ai")

register_item "nat_duke_cycloid1" {
	name       = "nat_duke_cycloid1",
	sprite     = 0,
	weight     = 0,

	type       = ITEMTYPE_NRANGED,
	damage     = "3d3",
	damagetype = DAMAGE_FIRE,
	fire       = 10,
	shots      = 5,
	radius     = 1,
	flags      = { IF_NODROP, IF_NOAMMO, IF_SCATTER },
	missile    = {
		sound_id   = "duke_cycloid1",
		ascii      = '-',
		color      = LIGHTRED,
		sprite     = SPRITE_ROCKETSHOT,
		delay      = 30,
		miss_base  = 35,
		miss_dist  = 6,
		expl_delay = 40,
		expl_color = RED,
	},
}
register_item "nat_duke_cycloid2" {
	name       = "nat_duke_cycloid2",
	sprite     = 0,
	weight     = 0,

	type       = ITEMTYPE_NRANGED,
	damage     = "1d9 + 3",
	damagetype = DAMAGE_PLASMA,
	acc        = 1,
	shots      = 1,
	flags      = { IF_SPREAD, IF_NODROP, IF_NOAMMO, IF_DESTRUCTIVE },
	missile    = {
		sound_id   = "duke_cycloid2",
		ascii      = 'o',
		color      = LIGHTMAGENTA,
		sprite     = 0,
		delay      = 20,
		miss_base  = 20,
		miss_dist  = 2,
	},
}

register_being "duke_cycloid" {
	name         = "cycloid emperor",
	ascii        = "C",
	color        = WHITE,
	sprite       = 0,
	hp           = 250,
	armor        = 2,
	attackchance = 50,
	todam        = 15,
	tohit        = 4,
	speed        = 130,
	min_lev      = 200,
	max_lev      = 200,
	corpse       = true,
	danger       = 50,
	weight       = 0,
	bulk         = 100,
	flags        = { F_LARGE, BF_KNOCKIMMUNE },
	ai_type      = "duke_cycloid_ai",

	desc            = "The alien leader. It's monolithic, has monovision, and is a firm believer in peace through volume of fire.",
	kill_desc       = "devastated by the Cycloid Emperor",
	kill_desc_melee = "crushed by the Emperor's heel",

	OnCreate = function (self)
		self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 10
		self.hp = self.hpmax

		self.eq.weapon = item.new("nat_duke_cycloid1")
		self.inv:add( item.new("nat_duke_cycloid2") )
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["duke_cycloid"].sound_hit   = core.resolve_sound_id("duke_cycloid.hit")
	beings["duke_cycloid"].sound_die   = core.resolve_sound_id("duke_cycloid.die")
	beings["duke_cycloid"].sound_act   = core.resolve_sound_id("duke_cycloid.act")
	beings["duke_cycloid"].sound_melee = core.resolve_sound_id("duke_cycloid.hoof")
	beings["duke_cycloid"].sound_hoof  = core.resolve_sound_id("duke_cycloid.hoof")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)