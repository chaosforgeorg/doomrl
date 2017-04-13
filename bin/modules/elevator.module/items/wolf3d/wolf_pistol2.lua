--require("elevator:items/wolf3d/wolf_9mm")

register_missile "wolf_mpistol2" {
	sound_id   = "wolf_pistol2",
	color      = LIGHTGRAY,
	sprite     = SPRITE_SHOT,
	delay      = 15,
	miss_base  = 10,
	miss_dist  = 3,
}
register_item "wolf_pistol2" {
	name     = "mauser",
	color    = RED,
	sprite   = SPRITE_PISTOL,
	psprite  = SPRITE_PLAYER_PISTOL,
	level    = 2,
	weight   = 4,
	group    = "weapon-pistol",
	desc     = "A pistol with an internal box magazine and stock.",
	flags    = { IF_PISTOL },

	type          = ITEMTYPE_RANGED,
	--ammo_id       = "wolf_9mm",
	ammo_id       = "ammo",
	ammomax       = 10,
	damage        = "2d5",
	damagetype    = DAMAGE_BULLET,
	acc           = 5,
	fire          = 11,
	reload        = 14,
	altfire       = ALT_AIMED,
	altreload     = RELOAD_DUAL,
	missile       = "wolf_mpistol2",
}

local FixSounds = function()
	items["wolf_pistol2"].sound_fire   = core.resolve_sound_id("wolf_pistol2.fire")
	items["wolf_pistol2"].sound_pickup = core.resolve_sound_id("pistol.pickup")
	items["wolf_pistol2"].sound_reload = core.resolve_sound_id("pistol.reload")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)