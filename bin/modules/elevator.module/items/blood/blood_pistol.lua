--require("elevator:items/blood/blood_coltammo")

register_missile "blood_mpistol" {
	sound_id   = "blood_pistol",
	color      = LIGHTGRAY,
	sprite     = SPRITE_SHOT,
	delay      = 15,
	miss_base  = 10,
	miss_dist  = 3,
}
register_item "blood_pistol" {
	name     = "revolver",
	color    = LIGHTGRAY,
	sprite   = SPRITE_PISTOL,
	psprite  = SPRITE_PLAYER_PISTOL,
	level    = 1,
	weight   = 70,
	group    = "weapon-pistol",
	desc     = "An old fashioned peacemaker.",
	flags    = { IF_PISTOL },

	type          = ITEMTYPE_RANGED,
	--ammo_id       = "blood_coltammo",
	ammo_id       = "ammo",
	ammomax       = 6,
	damage        = "2d4",
	damagetype    = DAMAGE_BULLET,
	acc           = 4,
	fire          = 10,
	reload        = 14,
	altfire       = ALT_AIMED,
	altreload     = RELOAD_DUAL,
	missile       = "blood_mpistol",
}

local FixSounds = function()
	items["blood_pistol"].sound_fire   = core.resolve_sound_id("blood_pistol.fire")
	items["blood_pistol"].sound_pickup = core.resolve_sound_id("blood.pickup")
	items["blood_pistol"].sound_reload = core.resolve_sound_id("blood.pickup")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)