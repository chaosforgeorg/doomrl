--The inquisitor is the heavy hitter in Strife.  It is able to fly (not that that means much in DoomRL), has a grenade launcher, and has a mauler.  It explodes when killed.

--weapons 1 & 2
register_item "nat_strife_inquisitor1" {
	name       = "nat_strife_inquisitor1",
	sprite     = 0,
	weight     = 0,

	type          = ITEMTYPE_NRANGED,
	damage        = "1d3",
	damagetype    = DAMAGE_PLASMA,
	acc           = 3,
	fire          = 12,
	shots         = 20,
	flags         = { IF_NODROP, IF_NOAMMO, IF_SCATTER },
	missile       = {
		sound_id   = "strife_mauler",
		ascii      = '*',
		color      = LIGHTGREEN,
		sprite     = SPRITE_SHOT,
		delay      = 3,
		miss_base  = 10,
		miss_dist  = 3,
	},

	OnFired = function( self, being )
		being:play_sound("strife_mauler.fire1")
	end,
}
register_item "nat_strife_inquisitor2" {
	name       = "nat_strife_inquisitor2",
	sprite     = 0,
	weight     = 0,

	type       = ITEMTYPE_NRANGED,
	damage     = "4d4",
	damagetype = DAMAGE_FIRE,
	acc        = 2,
	fire       = 16,
	radius     = 1,
	flags      = { IF_NODROP, IF_NOAMMO, IF_SPREAD },
	missile    = {
		sound_id   = "strife_glauncher",
		ascii      = '*',
		color      = YELLOW,
		sprite     = SPRITE_ROCKETSHOT,
		delay      = 30,
		miss_base  = 0,
		miss_dist  = 6,
		range      = 6,
		flags      = { MF_EXACT },
		expl_delay = 40,
		expl_color = RED,
	},
}

register_being "strife_inquisitor" {
	name         = "inquisitor",
	ascii        = "H",
	color        = LIGHTGRAY,
	sprite       = 0,
	hp           = 100,
	armor        = 2,
	todam        = 8,
	tohit        = 4,
	speed        = 110,
	min_lev      = 25,
	corpse       = false,
	danger       = 13,
	weight       = 6,
	bulk         = 100,
	ai_type      = "ranged_ai",

	desc            = "The inquisitor is a giant bipedal robot loaded with rocket boosters, grenade launchers, and maulers. If you see one, break out the big guns immediately.",
	kill_desc       = "swept away by a Crusader",
	kill_desc_melee = "crushed by a Crusader",

	OnCreate = function (self)
		self.eq.weapon = item.new("nat_strife_inquisitor1")
		self.bodybonus = self.bodybonus + 2
	end,

	OnAction = function(self)
		--The grenade launcher is preferred at long ranges but cannot be used past 7.
		if(self:in_sight(player) == true and ((self:distance_to(player) > 4 and self:distance_to(player) < 7) or (self:distance_to(player) >= 4 and self:distance_to(player) <= 7 and math.random(2) == 1))) then
			if(self.eq.weapon.id ~= "nat_strife_inquisitor2") then
				self.eq.weapon = item.new("nat_strife_inquisitor2")
			end
		else
			if(self.eq.weapon.id ~= "nat_strife_inquisitor1") then
				self.eq.weapon = item.new("nat_strife_inquisitor1")
			end
		end
	end,

	OnDie = function(self)
		EventQueue.AddEvent(level.explosion, 0, { level, self.position, 2, 40, 4, 5, COLOR_LAVA, "", DAMAGE_SHARPNEL } )
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["strife_inquisitor"].sound_hit    = core.resolve_sound_id("strife_inquisitor.hit")
	beings["strife_inquisitor"].sound_die    = core.resolve_sound_id("strife_inquisitor.die")
	beings["strife_inquisitor"].sound_act    = core.resolve_sound_id("strife_inquisitor.act")
	beings["strife_inquisitor"].sound_melee  = core.resolve_sound_id("strife_reaver.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)