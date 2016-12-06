--Undead warriors come from heretic.  They aren't that strong and the only unusual thing they do is throw special red axes on occasion.  I consider them roughly equivalent to hell knights (but the red axe means their HP is less).
register_missile "mnat_undeadwarrior1" {
	sound_id   = "undeadwarrior",
	ascii      = "'",
	color      = LIGHTGREEN,
	sprite     = 0,
	delay      = 20,
	miss_base  = 40,
	miss_dist  = 3,
	range      = 8,
}
register_missile "mnat_undeadwarrior2" {
	sound_id   = "undeadwarrior",
	ascii      = "'",
	color      = LIGHTRED,
	sprite     = 0,
	delay      = 20,
	miss_base  = 55,
	miss_dist  = 3,
	range      = 10,
}

register_being "undeadwarrior" {
	name         = "undead warrior",
	ascii        = "K",
	color        = RED,
	sprite       = 0,
	hp           = 40,
	armor        = 1,
	speed        = 100,
	todam        = 5,
	tohit        = 4,
	min_lev      = 8,
	max_lev      = 14,
	corpse       = true,
	danger       = 6,
	weight       = 6,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "baron_ai",

	desc            = "As part of the Order's insidious plot to control your world, they've recruited the dead, gave them armour and armed them with deadly magic axes. Now they guard the evil cities and toss their infinite supply of axes at any elf who passes by.",
	kill_desc       = "slain by an undead warrior",
	kill_desc_melee = "axed by an undead warrior",

	weapon = {
		damage     = "3d4",
		damagetype = DAMAGE_BULLET,
		fire       = 10,
		flags      = { },
		missile    = "mnat_undeadwarrior1",
		OnFire = function( self, being )
			if(math.random(8) > 1) then
				self.damage_dice  = 3
				self.damage_sides = 4
				self.missile = missiles[ "mnat_undeadwarrior1" ].nid
			else
				self.damage_dice  = 3
				self.damage_sides = 8
				self.missile = missiles[ "mnat_undeadwarrior2" ].nid
			end
			return true
		end,
	},
}

--Fixing up sounds
local FixSounds = function()
	beings["undeadwarrior"].sound_die   = core.resolve_sound_id("undeadwarrior.die")
	beings["undeadwarrior"].sound_act   = core.resolve_sound_id("undeadwarrior.act")
	beings["undeadwarrior"].sound_hit   = core.resolve_sound_id("undeadwarrior.hit")
	beings["undeadwarrior"].sound_attack= core.resolve_sound_id("undeadwarrior.fire")
	beings["undeadwarrior"].sound_melee = core.resolve_sound_id("undeadwarrior.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)