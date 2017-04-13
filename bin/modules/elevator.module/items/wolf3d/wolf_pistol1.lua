--require("elevator:items/wolf3d/wolf_9mm")

register_missile "wolf_mpistol1" {
	sound_id   = "wolf_pistol1",
	color      = LIGHTGRAY,
	sprite     = SPRITE_SHOT,
	delay      = 14,
	miss_base  = 10,
	miss_dist  = 3,
}
register_item "wolf_pistol1" {
	name     = "luger",
	color    = LIGHTGRAY,
	sprite   = SPRITE_PISTOL,
	psprite  = SPRITE_PLAYER_PISTOL,
	level    = 1,
	weight   = 60,
	group    = "weapon-pistol",
	desc     = "A guard's pistol.  Quirky, but they get the job done.",
	flags    = { IF_PISTOL },

	type          = ITEMTYPE_RANGED,
	--ammo_id       = "wolf_9mm",
	ammo_id       = "ammo",
	ammomax       = 8,
	damage        = "2d4",
	damagetype    = DAMAGE_BULLET,
	acc           = 3,
	fire          = 10,
	reload        = 12,
	altfire       = ALT_AIMED,
	altreload     = RELOAD_DUAL,
	missile       = "wolf_mpistol1",
}

local FixSounds = function()
	items["wolf_pistol1"].sound_fire   = core.resolve_sound_id("wolf_pistol1.fire")
	items["wolf_pistol1"].sound_pickup = core.resolve_sound_id("pistol.pickup")
	items["wolf_pistol1"].sound_reload = core.resolve_sound_id("pistol.reload")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)