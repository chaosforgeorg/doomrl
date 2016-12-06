--require("elevator:items/blood/blood_charge")

register_missile "blood_mtesla" {
	sound_id   = "blood_tesla",
	ascii      = "*",
	color      = MULTIBLUE,
	sprite     = SPRITE_PLASMASHOT,
	delay      = 16,
	miss_base  = 30,
	miss_dist  = 3,
}
register_item "blood_tesla" {
	name     = "tesla cannon",
	color    = CYAN,
	level    = 12,
	weight   = 70,
	psprite  = SPRITE_PLAYER_PLASMA,
	sprite   = SPRITE_PLASMA,
	group    = "weapon-plasma",
	desc     = "A high energy tesla cannon.",

	type          = ITEMTYPE_RANGED,
	ammo_id       = "cell",
	--ammo_id       = "blood_charge",
	ammomax       = 40,
	damage        = "1d6",
	damagetype    = DAMAGE_PLASMA,
	acc           = 2,
	fire          = 13,
	reload        = 20,
	shots         = 8,
	altfire       = ALT_CHAIN,
	altreload     = RELOAD_SCRIPT,
	altreloadname = "overcharge",
	missile       = "blood_mtesla",

	OnAltReload = function(self)
		if not self:can_overcharge("This will destroy the weapon after the next shot...") then return false end
		self.shots         = self.shots * 2
		self.ammomax       = self.shots
		self.ammo          = self.shots
		self.damage_sides  = self.damage_sides + 2
		return true
	end,
}

local FixSounds = function()
	items["blood_tesla"].sound_fire   = core.resolve_sound_id("blood_tesla.fire")
	items["blood_tesla"].sound_pickup = core.resolve_sound_id("blood.pickup")
	items["blood_tesla"].sound_reload = core.resolve_sound_id("blood.pickup")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
