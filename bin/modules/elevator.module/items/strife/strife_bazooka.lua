register_missile "strife_mbazooka" {
	sound_id   = "strife_bazooka",
	color      = LIGHTRED,
	sprite     = SPRITE_ROCKETSHOT,
	delay      = 30,
	miss_base  = 30,
	miss_dist  = 6,
	expl_delay = 40,
	expl_color = RED,
}
register_missile "strife_mbazookajump" {
	sound_id   = "strife_bazooka",
	color      = LIGHTRED,
	sprite     = SPRITE_ROCKETSHOT,
	delay      = 30,
	miss_base  = 30,
	miss_dist  = 6,
	flags      = { MF_EXACT },
	range      = 1,
	expl_delay = 40,
	expl_color = RED,
	expl_flags = { EFSELFKNOCKBACK, EFSELFHALF },
}

register_item "strife_bazooka" {
	name     = "mini missile launcher",
	color    = LIGHTRED,
	sprite   = SPRITE_BAZOOKA,
	psprite  = SPRITE_PLAYER_BAZOOKA,
	level    = 6,
	weight   = 200,
	group    = "weapon-rocket",
	desc     = "A miniature missile launcer.  Less punch than the normal kind, but lighter and faster.",

	type          = ITEMTYPE_RANGED,
	ammo_id       = "rocket",
	--ammo_id       = "strife_rocket",
	ammomax       = 1,
	damage        = "4d5",
	damagetype    = DAMAGE_FIRE,
	acc           = 4,
	fire          = 8,
	radius        = 2,
	reload        = 10,
	altfire       = ALT_SCRIPT,
	altfirename   = "rocketjump",
	missile       = "strife_mbazooka",

	OnAltFire = function( self, being )
		self.missile = missiles[ "strife_mbazookajump" ].nid
		return true
	end,

	OnFire = function( self, being )
		self.missile = missiles[ "strife_mbazooka" ].nid
		return true
	end,
}

local FixSounds = function()
	items["strife_bazooka"].sound_fire   = core.resolve_sound_id("strife_bazooka.fire")
	items["strife_bazooka"].sound_pickup = core.resolve_sound_id("bazooka.pickup")
	items["strife_bazooka"].sound_reload = core.resolve_sound_id("bazooka.reload")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)