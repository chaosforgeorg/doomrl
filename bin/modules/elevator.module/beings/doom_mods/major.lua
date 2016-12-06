--The major is part of the logical progression involving former humans.  Skulltag features one I believe.
register_being "major" {
	name         = "former major",
	ascii        = "h",
	color        = GREEN,
	sprite       = SPRITE_SERGEANT,
	overlay      = { 0.6,1.0,0.6,1.0 },
	glow         = { 0.0,0.2,0.0,1.0 },
	hp           = 25,
	armor        = 0,
	speed        = 100,
	todam        = 1,
	tohit        = 0,
	min_lev      = 8,
	max_lev      = 20,
	corpse       = true,
	danger       = 6,
	weight       = 7,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "former_ai",

	desc            = "You used to swap war stories with these guys.  Now you're swapping lead.  Keep your distance; their shotguns are only scary at close range",
	kill_desc       = "jacked by a former major",
	kill_desc_melee = "maimed by a former major",

	OnCreate = function(self)
		self.eq.weapon = item.new("dshotgun")
		self.inv:add( item.new("shell"), { ammo = 30 } )
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["major"].sound_hit   = core.resolve_sound_id("former.pain")
	beings["major"].sound_die   = core.resolve_sound_id("sergeant.die")
	beings["major"].sound_act   = core.resolve_sound_id("former.act")
	beings["major"].sound_melee = core.resolve_sound_id("soldier.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)