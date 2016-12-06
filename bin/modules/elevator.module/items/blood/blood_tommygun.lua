--require("elevator:items/blood/blood_ammo")

register_missile "blood_mtommygun" {
	sound_id   = "blood_tommygun",
	color      = WHITE,
	sprite     = SPRITE_SHOT,
	delay      = 20,
	miss_base  = 10,
	miss_dist  = 3,
}
register_item "blood_tommygun" {
	name     = "thompson",
	color    = WHITE,
	level    = 5,
	weight   = 200,
	psprite  = SPRITE_PLAYER_CHAINGUN,
	sprite   = SPRITE_CHAINGUN,
	group    = "weapon-chain",
	desc     = "A drum fueled tommygun.",

	type          = ITEMTYPE_RANGED,
	--ammo_id       = "blood_ammo",
	ammo_id       = "ammo",
	ammomax       = 50,
	damage        = "1d5",
	damagetype    = DAMAGE_BULLET,
	acc           = 2,
	fire          = 10,
	reload        = 30,
	shots         = 5,
	altfire       = ALT_CHAIN,
	missile       = "blood_mtommygun",
}

local FixSounds = function()
	items["blood_tommygun"].sound_fire   = core.resolve_sound_id("blood_tommygun.fire")
	items["blood_tommygun"].sound_pickup = core.resolve_sound_id("blood.pickup")
	items["blood_tommygun"].sound_reload = core.resolve_sound_id("blood.pickup")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
