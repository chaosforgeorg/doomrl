register_item "wolf_armor3" {
	name     = "heavy armor",
	color    = DARKGRAY,
	sprite   = SPRITE_ARMOR,
	coscolor = { 0.3,0.3,0.3,1.0 },
	level    = 9,
	weight   = 150,
	desc     = "This armor is slow, heavy, and able to deflect artillery.  The perfect thing for a walking tank like you.",

	resist = { bullet = 10, shrapnel = 10, fire = 10 },

	type       = ITEMTYPE_ARMOR,
	armor      = 4,
	movemod    = -20,
}
