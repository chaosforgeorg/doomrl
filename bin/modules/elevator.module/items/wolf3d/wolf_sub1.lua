--require("elevator:items/wolf3d/wolf_9mm")

register_missile "wolf_msub1" {
	sound_id   = "wolf_sub1",
	color      = WHITE,
	sprite     = SPRITE_SHOT,
	delay      = 30,
	miss_base  = 10,
	miss_dist  = 3,
}
register_item "wolf_sub1" {
	name     = "machine pistol",
	color    = WHITE,
	sprite   = SPRITE_CHAINGUN,
	psprite  = SPRITE_PLAYER_CHAINGUN,
	level    = 5,
	weight   = 40,
	group    = "weapon-sub",
	desc     = "A pistol with an internal box magazine and stock.",
	flags    = { IF_PISTOL },

	type          = ITEMTYPE_RANGED,
	--ammo_id       = "wolf_9mm",
	ammo_id       = "ammo",
	ammomax       = 32,
	damage        = "1d6",
	damagetype    = DAMAGE_BULLET,
	acc           = 3,
	fire          = 10,
	reload        = 15,
	shots         = 3,
	missile       = "wolf_msub1",
}

local FixSounds = function()
	items["wolf_pistol1"].sound_fire   = core.resolve_sound_id("wolf_sub1.fire")
	items["wolf_pistol1"].sound_pickup = core.resolve_sound_id("wolf_sub1.pickup")
	items["wolf_pistol1"].sound_reload = core.resolve_sound_id("pistol.reload")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)