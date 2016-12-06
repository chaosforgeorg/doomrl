--Standard shotgun.

register_shotgun "duke_snormal" {
	maxrange   = 14,
	spread     = 3,
	reduce     = 0.075,
}
register_item "duke_shotgun" {
	name     = "shotgun",
	color    = DARKGRAY,
	sprite   = SPRITE_SHOTGUN,
	psprite  = SPRITE_PLAYER_SHOTGUN,
	level    = 2,
	weight   = 0,
	--weight   = 150,
	group    = "weapon-shotgun",
	desc     = "When there's killing to be done the shotgun will deliver.",
	flags    = { IF_SHOTGUN },

	type          = ITEMTYPE_RANGED,
	ammo_id       = "shell",
	ammomax       = 1,
	damage        = "8d3",
	damagetype    = DAMAGE_SHARPNEL,
	fire          = 10,
	reload        = 10,
	altfire       = ALT_AIMED,
	missile       = "duke_snormal",
}

--Fixing up sounds
local FixSounds = function()
	items["duke_shotgun"].sound_fire   = core.resolve_sound_id("duke_shotgun.fire")
	items["duke_shotgun"].sound_pickup = core.resolve_sound_id("pistol.pickup")
	items["duke_shotgun"].sound_reload = core.resolve_sound_id("duke_shotgun.reload")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
