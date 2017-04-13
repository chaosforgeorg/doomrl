--Standard chaingun.

register_missile "duke_mchaingun" {
	sound_id   = "duke_chaingun",
	color      = WHITE,
	sprite     = SPRITE_SHOT,
	delay      = 10,
	miss_base  = 10,
	miss_dist  = 5,
}
register_item "duke_chaingun" {
	name     = "chaingun",
	color    = RED,
	sprite   = SPRITE_CHAINGUN,
	psprite  = SPRITE_PLAYER_CHAINGUN,
	level    = 5,
	weight   = 0,
	--weight   = 200,
	group    = "weapon-chain",
	desc     = "The chaingun cannon is also known as the ripper. That's because its high rate of fire can rip apart enemies.",

	type          = ITEMTYPE_RANGED,
	ammo_id       = "ammo",
	ammomax       = 40,
	damage        = "1d6",
	damagetype    = DAMAGE_BULLET,
	acc           = 2,
	fire          = 10,
	reload        = 25,
	shots         = 4,
	altfire       = ALT_CHAIN,
	missile       = "duke_mchaingun",
}

--Fixing up sounds
local FixSounds = function()
	items["duke_chaingun"].sound_fire   = core.resolve_sound_id("duke_chaingun.fire")
	items["duke_chaingun"].sound_pickup = core.resolve_sound_id("pistol.pickup")
	items["duke_chaingun"].sound_reload = core.resolve_sound_id("pistol.reload")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)