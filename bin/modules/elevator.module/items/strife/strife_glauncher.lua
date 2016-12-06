--There's nothing I can do right now to mimic the annoying branching of this weapon.  So instead I slapped IF_SPREAD onto it and made it a triple shot.
register_missile "strife_mglauncher" {
	sound_id   = "strife_glauncher",
	ascii      = '*',
	color      = YELLOW,
	sprite     = SPRITE_ROCKETSHOT,
	delay      = 30,
	miss_base  = 0,
	miss_dist  = 6,
	range      = 6,
	flags      = { MF_EXACT },
	expl_delay = 40,
	expl_color = RED,
}

register_item "strife_glauncher" {
	name     = "grenade launcher",
	color    = LIGHTRED,
	sprite   = SPRITE_BAZOOKA,
	psprite  = SPRITE_PLAYER_BAZOOKA,
	level    = 6,
	weight   = 200,
	group    = "weapon-rocket",
	desc     = "A miniature missile launcer.  Less punch than the normal kind, but lighter and faster.",
	flags    = { IF_SPREAD },

	type          = ITEMTYPE_RANGED,
	ammo_id       = "rocket",
	--ammo_id       = "strife_grenade",
	ammomax       = 3,
	damage        = "5d5",
	damagetype    = DAMAGE_FIRE,
	acc           = 2,
	fire          = 12,
	radius        = 1,
	reload        = 11,
	shotcost      = 3,
	missile       = "strife_mglauncher",
}

local FixSounds = function()
	items["strife_glauncher"].sound_fire   = core.resolve_sound_id("strife_glauncher.fire")
	items["strife_glauncher"].sound_pickup = core.resolve_sound_id("bazooka.pickup")
	items["strife_glauncher"].sound_reload = core.resolve_sound_id("bazooka.reload")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)