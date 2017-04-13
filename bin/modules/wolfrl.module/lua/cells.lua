--[[ WolfRL is a world filled with walls, and on those walls there stand
     men with guns.  And signs.  And paintings.  Flair is an overlay (kinda
     like blood once was) that is only assigned in G-mode if the cell's wall
     faces the player, and is always assigned in console mode.
     That's the generator's problem though; we just define them.

     At some point in the future I want flair to be destroyable in such a way
     that the underlying cell is left undamaged (unless of course you fired
     something explosive at it, in which case I want the spillover damage to
     hit the cell of course). Right now we can fake it... somewhat... but
     the effect only really sells in Console mode, and even then there are
     issues.  In G-mode destructible flair is too hacky to implement well
     so we will hold off on it until a later date.
  ]]--
core.declare( "CELLSET_DOORS" , 4);
function DoomRL.loadcells()

	-- Floor tiles (not sure what to do with these yet)
	register_cell "floor" {
		name       = "floor",
		color      = LIGHTGRAY,
		sprite     = SPRITE_FLOOR,
		blname     = "blood",
		blcolor    = RED,
		blsprite   = SPRITE_BLOOD,
		ascii      = "ù",
		asciilow   = '.',
		set        = CELLSET_FLOORS,
		bloodto    = "bloodpool",
	}
	register_cell "floorc" {
		name       = "floor",
		color      = LIGHTGRAY,
		sprite     = SPRITE_CAVEFLOOR,
		blname     = "blood",
		blcolor    = RED,
		blsprite   = SPRITE_BLOOD,
		ascii      = "ù",
		asciilow   = '.',
		set        = CELLSET_FLOORS,
		bloodto    = "bloodpool",
	}
	register_cell "floorb" {
		name       = "floor",
		color      = LIGHTGRAY,
		sprite     = SPRITE_HELLFLOOR,
		blname     = "blood",
		blcolor    = RED,
		blsprite   = SPRITE_BLOOD,
		ascii      = "ù",
		asciilow   = '.',
		set        = CELLSET_FLOORS,
		bloodto    = "bloodpool",
	}

	register_cell "rock" {
		name       = "rock",
		color      = RED,
		sprite     = SPRITE_FLOOR,
		blname     = "blood",
		blcolor    = LIGHTRED,
		blsprite   = SPRITE_BLOOD,
		ascii      = ".",
		set        = CELLSET_FLOORS,
		bloodto    = "bloodpool",
	}
	register_cell "dirt" {
		name       = "dirt",
		color      = BROWN,
		sprite     = SPRITE_FLOOR,
		blname     = "blood",
		blcolor    = RED,
		blsprite   = SPRITE_BLOOD,
		ascii      = "ù",
		asciilow   = '.',
		set        = CELLSET_FLOORS,
		bloodto    = "bloodpool",
	}
	register_cell "grass1" {
		name       = "grass",
		color      = GREEN,
		sprite     = SPRITE_FLOOR,
		blname     = "blood",
		blcolor    = RED,
		blsprite   = SPRITE_BLOOD,
		ascii      = "ù",
		asciilow   = '.',
		set        = CELLSET_FLOORS,
		bloodto    = "bloodpool",
	}
	register_cell "grass2" {
		name     = "grass",
		color    = LIGHTGREEN,
		sprite     = SPRITE_FLOOR,
		blname     = "blood",
		blcolor    = RED,
		blsprite   = SPRITE_BLOOD,
		ascii    = "ù",
		asciilow = '.',
		set      = CELLSET_FLOORS,
		bloodto    = "bloodpool",
	}
	register_cell "rubble" {
		name       = "rubble",
		color      = LIGHTGRAY,
		sprite     = SPRITE_FLOOR,
		blname     = "blood",
		blcolor    = RED,
		blsprite   = SPRITE_BLOOD,
		ascii      = "ù",
		asciilow   = '.',
		set        = CELLSET_FLOORS,
		bloodto    = "bloodpool",
	}

	register_cell "bones1" {
		name       = "pile of bones",
		color      = LIGHTGRAY,
		sprite     = SPRITE_FLOOR,
		blname     = "blooded bones",
		blcolor    = RED,
		blsprite   = SPRITE_BLOOD,
		ascii      = "%",
		set        = CELLSET_FLOORS,
		flags      = {CF_OVERLAY},
	}
	register_cell "bones2" {
		name       = "skeleton",
		color      = LIGHTGRAY,
		sprite     = SPRITE_FLOOR,
		blname     = "blooded skeleton",
		blcolor    = RED,
		blsprite   = SPRITE_BLOOD,
		ascii      = "%",
		set        = CELLSET_FLOORS,
		flags      = {CF_OVERLAY},
	}

	-- Walls
	register_cell "wolf_whwall" {
		name       = "stone wall",
		color      = LIGHTGRAY,
		coscolor   = { 1.0,1.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 10,
		hp         = 10,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "wolf_rewall" {
		name       = "brick wall",
		color      = RED,
		coscolor   = { 1.0,0.0,0.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded brick wall",
		blcolor    = LIGHTRED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 8,
		hp         = 10,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "wolf_blwall" {
		name       = "blue wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,0.8,1.0 },
		sprite     = SPRITE_STONEWALL,
		blname     = "blooded blue wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 12,
		hp         = 10,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "wolf_grwall" {
		name       = "mossy stone wall",
		color      = GREEN,
		coscolor   = { 0.5,0.8,0.4,1.0 },
		sprite     = SPRITE_STONEWALL,
		blname     = "blooded mossy stone wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 9,
		hp         = 9,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "wolf_brwall" {
		name       = "wooden wall",
		color      = BROWN,
		coscolor   = { 0.75,0.5,0.25,1.0 },
		sprite     = SPRITE_WOODWALL,
		blname     = "blooded wooden wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 8,
		hp         = 6,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "wolf_puwall" {
		name       = "purple wall",
		color      = MAGENTA,
		coscolor   = { 1.0,0.0,1.0,1.0 },
		sprite     = SPRITE_CAVEWALL,
		blname     = "blooded purple wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 15,
		hp         = 10,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "wolf_cywall" {
		name       = "metal wall",
		color      = CYAN,
		coscolor   = { 0.125,1.0,1.0,1.0 },
		sprite     = SPRITE_METALWALL,
		blname     = "blooded metal wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 15,
		hp         = 15,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "wolf_dkwall" {
		name       = "dark stone wall",
		color      = DARKGRAY,
		coscolor   = { 0.5,0.5,0.5,1.0 },
		sprite     = SPRITE_CAVEWALL,
		blname     = "blooded dark stone wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 11,
		hp         = 10,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "wolf_bdwall" {
		name       = "bloodstone",
		color      = RED,
		coscolor   = { 1.0,0.0,0.0,1.0 },
		sprite     = SPRITE_BLOODSTONE,
		blname     = "blooded bloodstone",
		blcolor    = LIGHTRED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 10,
		hp         = 15,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "wolf_otwall" {
		name       = "temp blake wall",
		color      = RED,
		coscolor   = { 0.5,0.0,0.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded temp blake wall",
		blcolor    = LIGHTRED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 10,
		hp         = 15,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "wolf_cvwall" {
		name       = "cave wall",
		color      = BROWN,
		coscolor   = { 1.0,0.6,0.2,1.0 },
		sprite     = SPRITE_CAVEWALL,
		blname     = "blooded cave wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 15,
		hp         = 30,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "wolf_rfwall" {
		name       = "rockface",
		color      = LIGHTGRAY,
		coscolor   = { 1.0,1.0,1.0,1.0 },
		sprite     = SPRITE_CAVEWALL,
		blname     = "blooded rockface",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 15,
		hp         = 30,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}

	-- Flair
	register_cell "wolf_flrflag1" {
		name       = "flag",
		color      = RED,
		sprite     = SPRITE_FLAG1,
		blname     = "blooded flag",
		blcolor    = LIGHTRED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL},
	}
	register_cell "wolf_flrflag2" {
		name       = "flag",
		color      = RED,
		sprite     = SPRITE_FLAG2,
		blname     = "blooded flag",
		blcolor    = LIGHTRED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL},
	}
	register_cell "wolf_flrpicture1" {
		name       = "painting",
		color      = WHITE,
		sprite     = SPRITE_PICTURE1,
		blname     = "blooded painting",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL},
	}
	register_cell "wolf_flrpicture2" {
		name       = "eagle painting",
		color      = YELLOW,
		sprite     = SPRITE_PICTURE2,
		blname     = "blooded eagle painting",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL},
	}
	register_cell "wolf_flrsign1" {
		name       = "warning sign",
		color      = LIGHTGRAY,
		sprite     = SPRITE_SIGN1,
		blname     = "blooded warning sign",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL},
	}
	register_cell "wolf_flrsign2" {
		name       = "sign",
		color      = LIGHTGRAY,
		sprite     = SPRITE_SIGN2,
		blname     = "blooded sign",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL},
	}
	register_cell "wolf_flrcell1" {
		name       = "cell bars",
		color      = DARKGRAY,
		sprite     = SPRITE_CELL1,
		blname     = "blooded cell bars",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL},
	}
	register_cell "wolf_flrcell2" {
		name       = "cell bars",
		color      = LIGHTGRAY,
		sprite     = SPRITE_CELL2,
		blname     = "blooded cell bars",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL},
	}
	register_cell "wolf_flrwreath" {
		name       = "wreath",
		color      = GREEN,
		sprite     = SPRITE_WREATH,
		blname     = "blooded wreath",
		blcolor    = LIGHTRED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL},
	}
	register_cell "wolf_flrtapestry" {
		name       = "eagle flag",
		color      = MAGENTA,
		sprite     = SPRITE_TAPESTRY,
		blname     = "blooded eagle flag",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL},
	}
	register_cell "wolf_flrcross" {
		name       = "cross decal",
		color      = BLUE,
		sprite     = SPRITE_CROSS,
		blname     = "blooded cross decal",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL},
	}
	register_cell "wolf_flrglass" {
		name       = "stained glass window",
		color      = LIGHTMAGENTA,
		sprite     = SPRITE_GLASS,
		blname     = "blooded stained glass window",
		blcolor    = LIGHTRED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL},
	}
	register_cell "wolf_flrmap" {
		name       = "map",
		color      = LIGHTGREEN,
		sprite     = SPRITE_WALLMAP,
		blname     = "blooded map",
		blcolor    = LIGHTRED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL},
	}
	register_cell "wolf_flrphoto" {
		name       = "portrait",
		color      = LIGHTRED,
		sprite     = SPRITE_PHOTO,
		blname     = "blooded portrait",
		blcolor    = LIGHTRED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL},
	}
	register_cell "wolf_flrivy" {
		name       = "ivy",
		color      = GREEN,
		sprite     = SPRITE_PHOTO,
		blname     = "blooded ivy",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL},
	}

	-- Crates
	register_cell "crate" {
		name       = "crate",
		blname     = "blooded crate",
		ascii      = "#",
		color      = BLUE,
		blcolor    = RED,
		armor      = 5,
		hp         = 5,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_STICKWALL},
		sprite     = SPRITE_YBOX,
		blsprite   = SPRITE_WALLBLOOD,
	}
	register_cell "ycrate" {
		name       = "crate",
		blname     = "blooded crate",
		ascii      = "#",
		color      = BROWN,
		blcolor    = RED,
		armor      = 5,
		hp         = 5,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_STICKWALL},
		sprite     = SPRITE_WBOX,
		blsprite   = SPRITE_WALLBLOOD,
	}

	register_cell "crate_ammo" {
		name       = "crate",
		color      = LIGHTRED,
		sprite     = SPRITE_WBOXC,
		blname     = "blooded crate",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 5,
		hp         = 5,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_STICKWALL, CF_FRAGILE},
		coscolor   = {1.0,0.0,0.0,1.0},

		OnDestroy = function(c)
			if math.random(4) == 1 and level.danger_level >= items["wolf_9mm"].level then
				local item_spawn = "wolf_9mm"
				if math.random(6) <= 2 and level.danger_level >= items["wolf_8mm"].level then
					item_spawn = "wolf_8mm"
					if math.random(6) <= 2 and level.danger_level >= items["wolf_kurz"].level then
						item_spawn = "wolf_kurz"
					end
				end
				level:drop_item( item_spawn, c, true )
			end
		end,
	}
	register_cell "crate_armor" {
		name       = "crate",
		color      = YELLOW,
		sprite     = SPRITE_YBOXC,
		blname     = "blooded crate",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 5,
		hp         = 5,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_STICKWALL, CF_FRAGILE},
		coscolor   = {1.0,1.0,0.0,1.0},

		OnDestroy = function(c)
			if math.random(5) == 1 then
				local item_spawn = {"wolf_armor1","wolf_boots1","wolf_smed"}
				if math.random(6) == 1 then
					item_spawn = {"wolf_armor2","wolf_boots2","wolf_lmed"}
				end
				level:drop_item( table.random_pick( item_spawn ), c )
			end
		end,
	}

	-- Doors
	register_cell "door" {
		name       = "closed door",
		ascii      = "+",
		color      = BROWN,
		armor      = 4,
		hp         = 6,
		set        = CELLSET_DOORS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_FRAGILE, CF_OVERLAY, CF_STICKWALL, CF_OPENABLE, CF_RUNSTOP, CF_HIGHLIGHT},
		sprite     = SPRITE_DOOR,

		OnAct = function(c,being)
			being:msg("You open the door.")
			being:play_sound("door.open")
			level.map[ c ] = "odoor"
			being.scount = being.scount - 500
			return true
		end,
	}
	register_cell "odoor" {
		name       = "open door",
		ascii      = "/",
		color      = BROWN,
		set        = CELLSET_DOORS,
		flags      = {CF_NOCHANGE, CF_NORUN, CF_OVERLAY, CF_STICKWALL, CF_CLOSABLE, CF_RUNSTOP, CF_NUKABLE, CF_HIGHLIGHT },
		sprite     = SPRITE_OPENDOOR,

		OnAct = function(c,being)
			if level:get_being(c) == nil and level:get_item(c) == nil then
				being:msg("You close the door.")
				being:play_sound("door.close")
				level.map[ c ] = "door"
				being.scount = being.scount - 500
				return true
			else
				being:msg("There's something blocking the door.")
				return false
			end
		end,
	}
	register_cell "ldoor" {
		name       = "locked door",
		ascii      = "+",
		color      = BROWN,
		armor      = 6,
		hp         = 6,
		set        = CELLSET_DOORS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_FRAGILE, CF_OVERLAY, CF_STICKWALL, CF_RUNSTOP},
		sprite     = SPRITE_DOOR,

		OnAct = function(c,being)
			being:msg("The door is locked.")
			return false
		end,
	}

	register_cell "mdoor1" {
		name       = "closed metal door",
		ascii      = "+",
		color      = LIGHTGRAY,
		armor      = 4,
		hp         = 6,
		set        = CELLSET_DOORS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL, CF_OPENABLE, CF_RUNSTOP, CF_HIGHLIGHT},
		sprite     = SPRITE_DOOR,

		OnAct = function(c,being)
			being:msg("You open the door.")
			being:play_sound("door.open")
			level.map[ c ] = "omdoor1"
			being.scount = being.scount - 500
			return true
		end,
	}
	register_cell "omdoor1" {
		name       = "open metal door",
		ascii      = "/",
		color      = LIGHTGRAY,
		set        = CELLSET_DOORS,
		flags      = {CF_NOCHANGE, CF_NORUN, CF_OVERLAY, CF_STICKWALL, CF_CLOSABLE, CF_RUNSTOP, CF_NUKABLE, CF_HIGHLIGHT },
		sprite     = SPRITE_OPENDOOR,

		OnAct = function(c,being)
			if level:get_being(c) == nil and level:get_item(c) == nil then
				being:msg("You close the door.")
				being:play_sound("door.close")
				level.map[ c ] = "mdoor1"
				being.scount = being.scount - 500
				return true
			else
				being:msg("There's something blocking the door.")
				return false
			end
		end,
	}
	register_cell "lmdoor1" {
		name       = "locked metal door",
		ascii      = "+",
		color      = LIGHTGRAY,
		armor      = 6,
		hp         = 6,
		set        = CELLSET_DOORS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL, CF_RUNSTOP},
		sprite     = SPRITE_DOOR,

		OnAct = function(c,being)
			being:msg("The door is locked.")
			return false
		end,
	}

	register_cell "mdoor2" {
		name       = "closed metal door",
		ascii      = "+",
		color      = DARKGRAY,
		armor      = 4,
		hp         = 6,
		set        = CELLSET_DOORS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL, CF_OPENABLE, CF_RUNSTOP, CF_HIGHLIGHT},
		sprite     = SPRITE_DOOR,

		OnAct = function(c,being)
			being:msg("You open the door.")
			being:play_sound("door.open")
			level.map[ c ] = "omdoor2"
			being.scount = being.scount - 500
			return true
		end,
	}
	register_cell "omdoor2" {
		name       = "open metal door",
		ascii      = "/",
		color      = DARKGRAY,
		set        = CELLSET_DOORS,
		flags      = {CF_NOCHANGE, CF_NORUN, CF_OVERLAY, CF_STICKWALL, CF_CLOSABLE, CF_RUNSTOP, CF_NUKABLE, CF_HIGHLIGHT },
		sprite     = SPRITE_OPENDOOR,

		OnAct = function(c,being)
			if level:get_being(c) == nil and level:get_item(c) == nil then
				being:msg("You close the door.")
				being:play_sound("door.close")
				level.map[ c ] = "mdoor2"
				being.scount = being.scount - 500
				return true
			else
				being:msg("There's something blocking the door.")
				return false
			end
		end,
	}
	register_cell "lmdoor2" {
		name       = "locked metal door",
		ascii      = "+",
		color      = DARKGRAY,
		armor      = 6,
		hp         = 6,
		set        = CELLSET_DOORS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL, CF_RUNSTOP},
		sprite     = SPRITE_DOOR,

		OnAct = function(c,being)
			being:msg("The door is locked.")
			return false
		end,
	}

	-- Stairs --
	register_cell "stairs" {
		name       = "down stairs",
		ascii      = ">",
		color      = LIGHTGRAY,
		color_dark = LIGHTGRAY,
		flags      = {CF_NOCHANGE, CF_NORUN, CF_OVERLAY, CF_CRITICAL, CF_HIGHLIGHT, CF_STAIRS},
		sprite     = SPRITE_GRAYSTAIRS,

		OnEnter = function(c,being)
			being:msg("There are stairs leading downward here.")
		end,

		OnExit = function(c)
			player:exit()
		end,
	}
	register_cell "rstairs" {
		name       = "down stairs",
		ascii      = ">",
		color      = LIGHTRED,
		color_dark = RED,
		flags      = {CF_NOCHANGE, CF_NORUN, CF_OVERLAY, CF_CRITICAL, CF_HIGHLIGHT, CF_STAIRS},
		sprite     = SPRITE_REDSTAIRS,

		OnEnter = function(c,being)
			being:msg("There are stairs leading to "..levels[level.special_exit].name.." here.")
		end,

		OnExit = function(c)
			player:exit( level.special_exit )
		end,

		OnDescribe = function(c)
			return "stairs leading to "..levels[level.special_exit].name
		end,
	}
	register_cell "ystairs" {
		name       = "up stairs",
		ascii      = "<",
		color      = LIGHTGRAY,
		color_dark = LIGHTGRAY,
		flags      = {CF_NOCHANGE, CF_NORUN, CF_OVERLAY, CF_CRITICAL, CF_HIGHLIGHT, CF_STAIRS},
		sprite     = SPRITE_GRAYSTAIRS,

		OnEnter = function(c,being)
			being:msg("There are stairs leading upward here.")
		end,

		OnExit = function(c)
			player:exit(level.data.exit)
		end,
	}

	-- Barrels --
	register_cell "barrel" {
		name       = "barrel of fuel",
		ascii      = "0",
		color      = BROWN,
		armor      = 3,
		hp         = 2,
		flags      = { CF_BLOCKMOVE, CF_PUSHABLE, CF_FRAGILE, CF_OVERLAY, CF_HIGHLIGHT},
		sprite     = SPRITE_BARREL,

		OnAct = function(c,being)
			local source = being.position
			if level:push_cell(c, c + (c - source)) then
				being.scount = being.scount - 1000
			end
		end,

		OnDestroy = function(c)
			if level:is_visible(c) then ui.msg('The barrel explodes!') end
			level.map[ c ] = generator.styles[ level.style ].floor
			level:explosion(c,4,40,5,5,RED, "barrel.explode" )
		end
	}
	register_cell "barrela" {
		name       = "barrel of acid",
		ascii      = "0",
		color      = GREEN,
		armor      = 4,
		hp         = 2,
		flags      = { CF_BLOCKMOVE, CF_PUSHABLE, CF_FRAGILE, CF_OVERLAY, CF_HIGHLIGHT},
		sprite     = SPRITE_ACIDBARREL,

		OnAct = function(c,being)
			local source = being.position
			if level:push_cell(c, c + (c - source)) then
				being.scount = being.scount - 1000
			end
		end,

		OnDestroy = function(c)
			if level:is_visible(c) then ui.msg('The barrel explodes!') end
			level.map[ c ] = "acid"
			level:explosion(c,3,40,6,6,GREEN, "barrel.explode", DAMAGE_ACID, nil, {}, "acid")
		end
	}
	register_cell "barreln" {
		name       = "barrel of napalm",
		ascii      = "0",
		color      = LIGHTRED,
		armor      = 5,
		hp         = 2,
		flags      = { CF_BLOCKMOVE, CF_PUSHABLE, CF_FRAGILE, CF_OVERLAY, CF_HIGHLIGHT},
		sprite     = SPRITE_LAVABARREL,

		OnAct = function(c,being)
			local source = being.position
			if level:push_cell(c, c + (c - source)) then
				being.scount = being.scount - 1000
			end
		end,

		OnDestroy = function(c)
			if level:is_visible(c) then ui.msg('The barrel explodes!') end
			level.map[ c ] = "lava"
			level:explosion(c,2,40,7,7,RED, "barrel.explode", DAMAGE_FIRE, nil, {}, "lava")
		end
	}

	-- Fluids --
	register_cell "water" {
		name       = "water",
		ascii      = "=",
		color      = COLOR_WATER,
		flags      = {F_GTSHIFT, F_GFLUID, CF_LIQUID, CF_NOCHANGE},
		sprite     = SPRITE_WATER,
	}
	register_cell "acid" {
		name       = "acid",
		ascii      = "=",
		color      = COLOR_ACID,
		flags      = {F_GTSHIFT, F_GFLUID, CF_LIQUID, CF_NOCHANGE, CF_NORUN, CF_HAZARD, CF_HIGHLIGHT},
		sprite     = SPRITE_ACID,

		OnEnter = function(c,being)
			local damage   = 6
			if DIFFICULTY == DIFF_EASY then damage = damage / 2 end
			if being.flags[ BF_ENVIROSAFE ] then return end
			if being:get_total_resistance( DAMAGE_ACID, TARGET_FEET ) == 100 then return end
			if being:is_player() then
				if being.running then damage = damage / 2 end
				if being:is_affect("enviro") then return end
				ui.msg("Argh!!! Acid!")
				if core.game_time() % 3 == 0 then
					being:play_sound(being.soundhit)
				end
			end
			being:apply_damage(damage,TARGET_FEET,DAMAGE_ACID)
		end
	}
	register_cell "lava" {
		name       = "lava",
		ascii      = "=",
		color      = COLOR_LAVA,
		flags      = {F_GTSHIFT, F_GFLUID, CF_LIQUID, CF_NOCHANGE, CF_NORUN, CF_HAZARD, CF_HIGHLIGHT},
		sprite     = SPRITE_LAVA,

		OnEnter = function(c,being)
			local damage = 12
			if DIFFICULTY == DIFF_EASY then damage = damage / 2 end
			if being.flags[ BF_ENVIROSAFE ] then return end
			if being:get_total_resistance( DAMAGE_FIRE, TARGET_FEET ) == 100 then return end
			if being:is_player() then
				if being.running then damage = damage / 2 end
				if being:is_affect("enviro") then return end
				ui.msg("Argh!!! Lava!")
				if core.game_time() % 3 == 0 then
					being:play_sound(being.soundhit)
				end
			end
			being:apply_damage(damage,TARGET_FEET,DAMAGE_FIRE)
		end
	}

	register_cell "pwater" {
  		name       = "water",
		ascii      = "=",
		color      = COLOR_WATER,
		color_id   = "water",
		set        = CELLSET_WALLS,
		flags      = {F_GTSHIFT, F_GFLUID, CF_BLOCKLOS, CF_BLOCKMOVE},
		sprite     = SPRITE_WATER,
	}
	register_cell "pacid" {
		name       = "acid",
		ascii      = "=",
		color      = COLOR_ACID,
		color_id   = "acid",
		set        = CELLSET_WALLS,
		flags      = {F_GTSHIFT, F_GFLUID, CF_BLOCKLOS, CF_BLOCKMOVE, CF_HIGHLIGHT},
		sprite     = SPRITE_ACID,
	}
	register_cell "plava" {
		name       = "lava",
		ascii      = "=",
		color      = COLOR_LAVA,
		color_id   = "lava",
		set        = CELLSET_WALLS,
		flags      = {F_GTSHIFT, F_GFLUID, CF_BLOCKLOS, CF_BLOCKMOVE, CF_HIGHLIGHT},
		sprite     = SPRITE_LAVA,
	}

	-- Pac --
	-- Must be viewed in Terminal
	-- ÉË»ÉÍ»ÚÂ¿ÚÄ¿ÕÑ¸ÖÒ·
	-- ÌÎ¹º ºÃÅ´³ ³ÆØµÇ×¶
	-- ÈÊ¼ÈÍ¼ÀÁÙÀÄÙÔÏ¾ÓÐ½
	register_cell "pac_wall1" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "º", --this should look like two vertical bars
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "pac_wall2" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "Í", --this should look like two horizontal bars
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "pac_wall3" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "¼", --lower right corner
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "pac_wall4" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "È", --lower left corner
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "pac_wall5" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "»", --upper right corner
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "pac_wall6" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "É", --upper left corner
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "pac_wall7" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "Ë", --T
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "pac_wall8" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "Ê", --upide down T
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "pac_wall9" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "Ì", -- |-
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "pac_wall10" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "¹", -- -|
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "pac_wall11" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "Î", --this should look like two vertical bars
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "pac_wall12" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = " ",
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}

	register_cell "pac_bwall1" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "º", --this should look like two vertical bars
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "pac_bwall2" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "Í", --this should look like two horizontal bars
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "pac_bwall3" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "¼", --lower right corner
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "pac_bwall4" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "È", --lower left corner
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "pac_bwall5" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "»", --upper right corner
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "pac_bwall6" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "É", --upper left corner
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "pac_bwall7" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "Ë", --T
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "pac_bwall8" {
		name       = "wall",
		color      = BLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "Ê", --upide down T
		asciilow   = "#",
		armor      = 15,
		hp         = 20,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}

	-- Blake --
	register_cell "blake_blwall" {
		name       = "futuristic wall",
		color      = BLUE,
		coscolor   = { 0.8,0.9,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded futuristic wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 10,
		hp         = 10,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "blake_cywall" {
		name       = "futuristic wall",
		color      = CYAN,
		coscolor   = { 0.3,1.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded futuristic wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 10,
		hp         = 10,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "blake_brwall" {
		name       = "futuristic wall",
		color      = BROWN,
		coscolor   = { 0.8,0.6,0.4,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded futuristic wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 10,
		hp         = 10,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "blake_whwall" {
		name       = "stone wall",
		color      = LIGHTGRAY,
		coscolor   = { 0.8,0.8,0.8,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded stone wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 10,
		hp         = 10,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "blake_elevatorwall" {
		name       = "elevator wall",
		color      = DARKGRAY,
		coscolor   = { 0.2,0.2,0.2,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded elevator wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 10,
		hp         = 10,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
	}
	register_cell "blake_pushwall" {
		name       = "futuristic wall",
		color      = CYAN,
		coscolor   = { 0.3,1.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded futuristic wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 10,
		hp         = 10,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_PUSHABLE, CF_MULTISPRITE, CF_STICKWALL}, --CF_OPENABLE and CF_PUSHABLE both do the same thing, but CF_OPENABLE cells are usable by enemies as well as the player.

		OnAct = function(c,being)
			--Hook into existing pushwall logic
			cells["wolf_pushwall"].OnAct(c,being)
		end,
	}
	register_cell "blake_barrier" {
		name       = "barrier",
		color      = LIGHTBLUE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		ascii      = "O",
		armor      = 10,
		hp         = 10,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE},
	}
	register_cell "blake_ebarrier" {
		name       = "electric barrier",
		color      = WHITE,
		coscolor   = { 0.0,0.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		ascii      = "~",
		armor      = 10,
		hp         = 10,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_PUSHABLE, CF_MULTISPRITE}, --CF_OPENABLE and CF_PUSHABLE both do the same thing, but CF_OPENABLE cells are usable by enemies as well as the player.

		OnAct = function(c,being)
			--Hurt the being.  There's no protection here.
			local damage = 10
			if DIFFICULTY == DIFF_EASY then damage = damage / 2 end
			being:play_sound(level.map[c] .. ".act")
			being:msg("Argh!!! Electricity!")
			being:apply_damage(damage,TARGET_INTERNAL,DAMAGE_PLASMA)
		end,
	}

	-- Misc --
	register_cell "bridge" {
		name       = "bridge",
		ascii      = "=",
		color      = BROWN,
		set        = CELLSET_FLOORS,
		sprite     = SPRITE_BRIDGE,
		blname     = "blood",
		blcolor    = RED;
		blsprite   = SPRITE_BLOOD;
		flags      = {F_GFLUID},
	}
	register_cell "pillar" {
		name       = "pillar",
		color      = LIGHTGRAY,
		coscolor   = { 1.0,1.0,1.0,1.0 },
		sprite     = SPRITE_PILLAR,
		blname     = "blooded pillar",
		blcolor    = RED;
		blsprite   = SPRITE_WALLBLOOD;
		ascii      = "O",
		armor      = 10,
		hp         = 10,
		flags      = {CF_BLOCKMOVE, CF_OVERLAY},
	}
	register_cell "tombstone" {
		name       = "tombstone",
		color      = LIGHTGRAY,
		coscolor   = { 1.0,1.0,1.0,1.0 },
		sprite     = SPRITE_TOMBSTONE,
		blname     = "blooded tombstone",
		blcolor    = RED;
		blsprite   = SPRITE_WALLBLOOD;
		destroyto  = "rubble",
		ascii      = "|",
		armor      = 2,
		hp         = 5,
		flags      = {CF_BLOCKMOVE, CF_OVERLAY, CF_FRAGILE},

		OnDescribe = function(c)
			local choices =
			{   "Go away!"
			  , "Be careful or this could happen to you!"
			  , "Beware of Electric Third Rail"
			  , "Caution! This grave contains toxic waste"
			  , "Look out below!"
			  , "Made in Taiwan"
			  , "Rest in peace"
			  , "Rest in pieces"
			  , "Sum quod eris"
			  , "Now she's at rest and so am I"
			  , "I made an ash of myself"
			  , "I'm With Stupid"
			  , "Don't Panic"
			  , "This space for rent"
			  , "Pepperoni and Cheese"
			  , "I told you I was sick"
			  , player.name
			}

			--If I had a UID for each cell I could generate a 'random' but consistent string identifier
			--for the epitath.  NetHack does something similar using the pointers for T-shirts.
			--I haven't found anything that quite fits the bill for DoomRL though so instead I cheat
			--on a cheat and use the closest thing to a random number that will remain consistent for
			--the duration of a normal level: statistics.max_kills.
			--A better option would be welcome.
			local pseudorandom_choice = statistics.max_kills
			pseudorandom_choice = pseudorandom_choice * 31 + c.x
			pseudorandom_choice = pseudorandom_choice * 31 + c.y
			pseudorandom_choice = (pseudorandom_choice % #choices) + 1

			return 'tombstone reading "'.. choices[pseudorandom_choice] .. '"'
		end,
	}
	register_cell "void" {
		name       = "void",
		ascii      = " ",
		color      = BLACK,
		color_dark = BLACK,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE},
		sprite     = 0, --totally black
	}
	register_cell "nukecell" {
		name       = "a bomb!",
		ascii      = "0",
		color      = RED,
		color_dark = RED,
		flags      = { CF_NOCHANGE, CF_NORUN, CF_OVERLAY, CF_NUKABLE, CF_CRITICAL, CF_HIGHLIGHT},
		sprite     = SPRITE_NUKE,
	}
	register_cell "wolf_pushwall" {
		name       = "stone wall",
		color      = LIGHTGRAY,
		coscolor   = { 1.0,1.0,1.0,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blname     = "blooded wall",
		blcolor    = RED,
		blsprite   = SPRITE_WALLBLOOD,
		ascii      = "#",
		armor      = 10,
		hp         = 10,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_PUSHABLE, CF_MULTISPRITE, CF_STICKWALL}, --CF_OPENABLE and CF_PUSHABLE both do the same thing, but CF_OPENABLE cells are usable by enemies as well as the player.

		OnAct = function(c,being)
			--Player must be adjacent and not at an angle.
			local direction = nil
			for cc in c:cross_coords() do
				if (being.position == cc) then
					direction = c - being.position
					break
				end
			end
			if (direction ~= nil) then
				--Calc the direction and move the wall
				local iterations = 3
				local direction = c - being.position
				local destination = c

				while true do
					local new_coord = destination + direction
					local cell_id = level.map[new_coord]
					local cell = cells[cell_id]

					--In bounds, a floor tile, not a hazard, not blocking, not past our max iterations
					if ((iterations <= 0)
					 or (not area.FULL:contains(new_coord))
					 or (cell.flags[CF_HAZARD])
					 or (cell.set ~= CELLSET_FLOORS)
					 or (not generator.is_empty( destination, { EF_NOITEMS, EF_NOBEINGS } ))) then break end

					destination = new_coord
					iterations = iterations - 1
				end

				if (destination ~= c) then
					level:play_sound( core.resolve_sound_id( level.map[c] .. ".move" ), c )
					being:msg("The wall slides forward.")
					being.scount = being.scount - 500

					local hp_c = level.hp[c]
					local hp_destination = level.hp[destination]
					level.map[ c ], level.map[ destination ] = level.map[ destination ], level.map[ c ]
					level.hp[destination], level.hp[c] = hp_destination, hp_c
					return true
				end
			end

			--Must have failed.
			level:play_sound( core.resolve_sound_id( level.map[c] .. ".movefail" ), c )
			being:msg("The wall doesn't move.")
			return false
		end,
	}

end
