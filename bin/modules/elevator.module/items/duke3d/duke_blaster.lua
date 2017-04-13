--Enemy weapon that dosen't need reloading.  Weaker than standard pistol due to damagetype being bad against armor.

register_missile "duke_mblaster" {
	sound_id   = "duke_blaster",
	color      = MULTIYELLOW,
	sprite     = SPRITE_SHOT,
	delay      = 10,
	miss_base  = 30,
	miss_dist  = 5,
}
register_item "duke_blaster" {
	name     = "blaster",
	color    = YELLOW,
	sprite   = SPRITE_PISTOL,
	psprite  = SPRITE_PLAYER_PISTOL,
	level    = 1,
	weight   = 0,
	--weight   = 70,
	group    = "weapon-pistol",
	desc     = "An alien blaster. Just barely adequate.",
	flags    = { IF_PISTOL, IF_RECHARGE },

	type          = ITEMTYPE_RANGED,
	ammo_id       = "cell",
	ammomax       = 10,
	rechargeamount= 1,
	rechargedelay = 3,
	damage        = "2d4",
	damagetype    = DAMAGE_SHARPNEL,
	acc           = 4,
	fire          = 10,
	reload        = 10,
	altfire       = ALT_AIMED,
	missile       = "duke_mblaster",
}

--Fixing up sounds
local FixSounds = function()
	items["duke_blaster"].sound_fire   = core.resolve_sound_id("duke_blaster.fire")
	items["duke_blaster"].sound_pickup = core.resolve_sound_id("pistol.pickup")
	items["duke_blaster"].sound_reload = core.resolve_sound_id("pistol.reload")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)