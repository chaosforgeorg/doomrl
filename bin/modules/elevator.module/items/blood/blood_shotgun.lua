--require("elevator:items/blood/blood_shell")
register_shotgun "blood_swide" {
	maxrange   = 10,
	spread     = 3,
	reduce     = 0.09,
}
register_item "blood_shotgun" {
	name     = "shotgun",
	color    = DARKGRAY,
	sprite   = SPRITE_DSHOTGUN,
	psprite  = SPRITE_PLAYER_DSHOTGUN,
	level    = 2,
	weight   = 150,
	group    = "weapon-shotgun",
	desc     = "A sawn-off shotgun.",
	flags    = { IF_SHOTGUN, IF_DUALSHOTGUN },

	type          = ITEMTYPE_RANGED,
	--ammo_id       = "blood_shell",
	ammo_id       = "shell",
	ammomax       = 2,
	damage        = "7d3",
	damagetype    = DAMAGE_SHARPNEL,
	fire          = 10,
	reload        = 20,
	shots         = 2,
	altfire       = ALT_SINGLE,
	altreload     = RELOAD_SINGLE,
	missile       = "blood_swide",
}

local FixSounds = function()
	items["blood_shotgun"].sound_fire   = core.resolve_sound_id("blood_shotgun.fire")
	items["blood_shotgun"].sound_pickup = core.resolve_sound_id("blood.pickup")
	items["blood_shotgun"].sound_reload = core.resolve_sound_id("blood.pickup")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
