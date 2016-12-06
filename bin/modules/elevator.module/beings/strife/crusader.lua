--The crusader is the mid-ranged tank in Strife..  It has a long and a short range weapon and explodes when killed.

--weapons 1 & 2
register_item "nat_strife_crusader1" {
	name       = "nat_strife_crusader1",
	sprite     = 0,
	weight     = 0,

	type       = ITEMTYPE_NRANGED,
	damage     = "6d6",
	damagetype = DAMAGE_FIRE,
	fire       = 10,
	shots      = 1,
	radius     = 1,
	flags      = { IF_HALFKNOCK, IF_NODROP, IF_NOAMMO },
	missile    = {
		sound_id   = "strife_crusader1",
		color      = LIGHTRED,
		sprite     = SPRITE_ROCKETSHOT,
		delay      = 30,
		miss_base  = 30,
		miss_dist  = 6,
		expl_delay = 40,
		expl_color = RED,
	},
}
register_item "nat_strife_crusader2" {
	name       = "nat_strife_crusader2",
	sprite     = 0,
	weight     = 0,

	type       = ITEMTYPE_NRANGED,
	damage     = "2d3",
	damagetype = DAMAGE_FIRE,
	fire       = 4,
	shots      = 8,
	radius     = 0,
	flags      = { IF_NODROP, IF_NOAMMO, IF_SCATTER }, --IF_SCATTER does not respect the range.  Neither does dodging from within the range.  Bug filed.
	missile    = {
		sound_id    = "strife_crusader2",
		ascii       = '*',
		color       = YELLOW,
		sprite      = 0,
		delay       = 20,
		miss_base   = 60,
		miss_dist   = 4,
		range       = 4,
		expl_delay  = 40,
		expl_color  = RED,
	},
}

register_being "strife_crusader" {
	name         = "crusader",
	ascii        = "C",
	color        = LIGHTGRAY,
	sprite       = 0,
	hp           = 40,
	armor        = 2,
	todam        = 6,
	tohit        = 3,
	speed        = 80,
	min_lev      = 10,
	max_lev      = 19,
	corpse       = false,
	danger       = 7,
	weight       = 6,
	bulk         = 100,
	ai_type      = "ranged_ai",

	desc            = "Crusaders are support robots developed by the Order. They are resilient and loaded with firepower, but they're a bit slow.",
	kill_desc       = "swept away by a Crusader",
	kill_desc_melee = "crushed by a Crusader",


	OnCreate = function (self)
		self.eq.weapon = item.new("nat_strife_crusader1")
		self.bodybonus = self.bodybonus + 1
	end,

	OnAction = function(self)
		if(self:in_sight(player) == true and (self:distance_to(player) < 4 or (self:distance_to(player) < 5 and math.random(2) == 1))) then
			if(self.eq.weapon.id ~= "nat_strife_crusader2") then
				self.eq.weapon = item.new("nat_strife_crusader2")
			end
		else
			if(self.eq.weapon.id ~= "nat_strife_crusader1") then
				self.eq.weapon = item.new("nat_strife_crusader1")
			end
		end
	end,

	OnDie = function(self)
		EventQueue.AddEvent(level.explosion, 0, { level, self.position, 1, 40, 4, 4, COLOR_LAVA, "", DAMAGE_SHARPNEL } )
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["strife_crusader"].sound_hit    = core.resolve_sound_id("strife_crusader.hit")
	beings["strife_crusader"].sound_die    = core.resolve_sound_id("strife_crusader.die")
	beings["strife_crusader"].sound_act    = core.resolve_sound_id("strife_crusader.act")
	beings["strife_crusader"].sound_melee  = core.resolve_sound_id("strife_reaver.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)