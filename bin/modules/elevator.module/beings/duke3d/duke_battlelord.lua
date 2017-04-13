--The Battlelord.  Big and ugly, this guy can fire his minigun or his mortars.  Since they are both on the same weapon there is no weapon switch time.  His minigun behaviour is similar to the spider mastermind.  His mortars however tend to scatter.
require("elevator:ai/duke_battlelord_ai")

register_item "nat_duke_battlelord1" {
	name       = "nat_duke_battlelord1",
	sprite     = 0,
	weight     = 0,

	type       = ITEMTYPE_NRANGED,
	damage     = "2d6",
	damagetype = DAMAGE_PLASMA,
	shots      = 4,
	flags      = { IF_NODROP, IF_NOAMMO, IF_DESTRUCTIVE },
	missile    = {
		sound_id   = "duke_battlelord1",
		ascii      = '-',
		color      = YELLOW,
		sprite     = 0,
		delay      = 20,
		miss_base  = 20,
		miss_dist  = 4,
	},
}
register_item "nat_duke_battlelord2" {
	name       = "nat_duke_battlelord2",
	sprite     = 0,
	weight     = 0,

	type       = ITEMTYPE_NRANGED,
	damage     = "6d6",
	damagetype = DAMAGE_FIRE,
	acc        = 2,
	fire       = 16,
	shots      = 1,
	radius     = 1,
	flags      = { IF_NODROP, IF_NOAMMO },
	missile    = {
		sound_id   = "duke_battlelord2",
		ascii      = '*',
		color      = LIGHTRED,
		sprite     = SPRITE_ROCKETSHOT,
		delay      = 30,
		miss_base  = 0,
		miss_dist  = 6,
		range      = 10,
		flags      = { MF_EXACT },
		expl_delay = 40,
		expl_color = RED,
	},
}

register_being "duke_battlelord" {
	name         = "battlelord",
	ascii        = "B",
	color        = WHITE,
	sprite       = 0,
	hp           = 250,
	armor        = 2,
	attackchance = 60,
	todam        = 15,
	tohit        = 4,
	speed        = 150,
	min_lev      = 200,
	max_lev      = 200,
	corpse       = true,
	danger       = 50,
	weight       = 0,
	bulk         = 100,
	flags        = { F_LARGE, BF_KNOCKIMMUNE },
	ai_type      = "duke_battlelord_ai",

	desc            = "The hulking battlelord commands the front lines in any alien invasion. With its deafening roar and thundering chaingun it tears resistance asunder. It has no weaknesses. Only relentless firepower can overcome it.",
	kill_desc       = "could not go up against the Battlelord's weapons",
	kill_desc_melee = "foolishly approached the Battlelord",

	OnCreate = function (self)
		self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 10
		self.hp = self.hpmax

		self.eq.weapon = item.new("nat_duke_battlelord1")
		self.inv:add( item.new("nat_duke_battlelord2") )
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["duke_battlelord"].sound_hit   = core.resolve_sound_id("duke_battlelord.hit")
	beings["duke_battlelord"].sound_die   = core.resolve_sound_id("duke_battlelord.die")
	beings["duke_battlelord"].sound_act   = core.resolve_sound_id("duke_battlelord.act")
	beings["duke_battlelord"].sound_melee = core.resolve_sound_id("duke_battlelord.hoof")
	beings["duke_battlelord"].sound_hoof  = core.resolve_sound_id("duke_battlelord.hoof")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)