--Hell if I know exactly what it's supposed to be in game; it acts like a rocket launcher at any rate
--require("elevator:items/blood/blood_gas")

register_missile "blood_mnapalm" {
	sound_id   = "blood_napalm",
	color      = LIGHTRED,
	sprite     = SPRITE_ROCKETSHOT,
	delay      = 30,
	miss_base  = 30,
	miss_dist  = 5,
	expl_delay = 40,
	expl_color = RED,
}
register_missile "blood_mnapalmjump" {
	sound_id   = "blood_napalm",
	color      = LIGHTRED,
	sprite     = SPRITE_ROCKETSHOT,
	delay      = 30,
	miss_base  = 30,
	miss_dist  = 5,
	flags      = { MF_EXACT },
	range      = 1,
	expl_delay = 40,
	expl_color = RED,
	expl_flags = { EFSELFKNOCKBACK, EFSELFHALF },
}

register_item "blood_napalm" {
	name     = "napalm launcher",
	color    = LIGHTRED,
	sprite   = SPRITE_BAZOOKA,
	psprite  = SPRITE_PLAYER_BAZOOKA,
	level    = 7,
	weight   = 200,
	group    = "weapon-rocket",
	desc     = "A gasoline napalm launcher.",

	type          = ITEMTYPE_RANGED,
	ammo_id       = "rocket",
	--ammo_id       = "blood_gas",
	ammomax       = 1,
	damage        = "6d5",
	damagetype    = DAMAGE_FIRE,
	acc           = 4,
	fire          = 10,
	radius        = 4,
	reload        = 15,
	altfire       = ALT_SCRIPT,
	altfirename   = "rocketjump",
	missile       = "blood_mnapalm",

	OnAltFire = function( self, being )
		self.missile = missiles[ "blood_mnapalmjump" ].nid
		return true
	end,

	OnFire = function( self, being )
		self.missile = missiles[ "blood_mnapalm" ].nid
		return true
	end,
}

local FixSounds = function()
	items["blood_napalm"].sound_fire    = core.resolve_sound_id("blood_napalm.fire")
	items["blood_napalm"].sound_pickup  = core.resolve_sound_id("blood.pickup")
	items["blood_napalm"].sound_reload  = core.resolve_sound_id("blood.pickup")
	items["blood_napalm"].sound_explode = core.resolve_sound_id("blood_dynamite.explode")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
