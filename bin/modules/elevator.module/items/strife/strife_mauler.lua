register_missile "strife_mmauler" {
	sound_id   = "strife_mauler",
	ascii      = '*',
	color      = LIGHTGREEN,
	sprite     = SPRITE_SHOT,
	delay      = 3,
	miss_base  = 10,
	miss_dist  = 3,
}

register_item "strife_mauler" {
	name     = "mauler",
	color    = LIGHTMAGENTA,
	sprite   = SPRITE_BFG9000,
	psprite  = SPRITE_PLAYER_BFG9000,
	level    = 20,
	weight   = 10,
	group    = "weapon-plasma",
	desc     = "The mauler is a rather unwieldly prototype for an energy weapon being developed by the order.",
	flags    = { IF_SCATTER },

	type          = ITEMTYPE_RANGED,
	ammo_id       = "cell",
	--ammo_id       = "strife_cell",
	ammomax       = 100,
	damage        = "1d3",
	damagetype    = DAMAGE_PLASMA,
	acc           = 3,
	fire          = 12,
	reload        = 20,
	shots         = 20,
	altreload     = RELOAD_SCRIPT,
	altreloadname = "overcharge",
	missile       = "strife_mmauler",

	OnFired = function( self, being )
		being:play_sound("strife_mauler.fire1")
	end,

	OnAltReload = function(self)
		if not self:can_overcharge("This will destroy the weapon after the next shot...") then return false end
		self.shots         = self.shots * 2
		self.ammomax       = self.shots
		self.ammo          = self.shots
		self.damage_sides  = self.damage_sides + 1
		return true
	end,
}

local FixSounds = function()
	items["strife_mauler"].sound_fire   = core.resolve_sound_id("strife_mauler.fire")
	items["strife_mauler"].sound_pickup = core.resolve_sound_id("plasma.pickup")
	items["strife_mauler"].sound_reload = core.resolve_sound_id("plasma.reload")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)