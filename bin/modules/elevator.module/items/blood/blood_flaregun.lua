--require("elevator:items/blood/blood_coltammo")

register_missile "blood_mflaregun" {
	sound_id   = "blood_flaregun",
	color      = YELLOW,
	sprite     = SPRITE_SHOT,
	delay      = 15,
	miss_base  = 10,
	miss_dist  = 3,
}
register_item "blood_flaregun" {
	name     = "flaregun",
	color    = YELLOW,
	sprite   = SPRITE_PISTOL,
	psprite  = SPRITE_PLAYER_PISTOL,
	level    = 1,
	weight   = 40,
	group    = "weapon-pistol",
	desc     = "A single shot flaregun.",
	flags    = { IF_PISTOL },

	type          = ITEMTYPE_RANGED,
	ammo_id       = "blood_flare",
	ammomax       = 1,
	damage        = "1d3",
	damagetype    = DAMAGE_FIRE,
	acc           = 4,
	fire          = 10,
	reload        = 14,
	altfire       = ALT_AIMED,
	altreload     = RELOAD_DUAL,
	missile       = "blood_mflaregun",

	OnHitBeing = function(self,being,target)
		target:play_sound("soldier.phase")
		being:msg("Suddenly "..target:get_name(true,false).." blinks away!")
		Level.explosion( target.position, 2, 50, 0, 0, LIGHTBLUE )
		target:phase()
		return false
	end,
}

local FixSounds = function()
	items["blood_flaregun"].sound_fire   = core.resolve_sound_id("blood_flaregun.fire")
	items["blood_flaregun"].sound_pickup = core.resolve_sound_id("blood.pickup")
	items["blood_flaregun"].sound_reload = core.resolve_sound_id("blood.pickup")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)