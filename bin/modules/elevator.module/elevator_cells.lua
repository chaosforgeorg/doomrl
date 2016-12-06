
--Void
register_cell "void" {
  name       = "void",
  ascii      = " ",
  color      = BLACK,
  color_dark = BLACK,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE},
  sprite     = 0, --totally black
}
register_cell "voidfloor" {
  name       = "void",
  ascii      = " ",
  color      = BLACK,
  color_dark = BLACK,
  flags      = {CF_HAZARD, CF_NOCHANGE, CF_NORUN},
  sprite     = 0, --totally black

  OnEnter = function(c,being)

    if being.flags[ BF_ENVIROSAFE ] then return end
    being:play_sound("gib")
    being:kill()
  end
}

--Elevator
register_cell "ewall" {
  name       = "wall",
  color      = DARKGRAY,
  coscolor   = { 0.5,0.5,0.5,1.0 },
  sprite     = SPRITE_BRICKWALL,
  --blname     = "blooded wall",
  --blcolor    = RED,
  --blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "#",
  armor      = 10,
  hp         = 10,
  set        = CELLSET_WALLS,
  flags      = { CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL },
}
register_cell "ehwindow" {
  name       = "window",
  color      = LIGHTGRAY,
  coscolor   = { 0.5,0.5,0.5,1.0 },
  sprite     = SPRITE_BRICKWALL,
  --blname     = "blooded wall",
  --blcolor    = RED,
  --blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "Ä",
  asciilow   = "-",
  armor      = 10,
  hp         = 10,
  set        = CELLSET_WALLS,
  flags      = { CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL },
}
register_cell "evwindow" {
  name       = "window",
  color      = LIGHTGRAY,
  coscolor   = { 0.5,0.5,0.5,1.0 },
  sprite     = SPRITE_BRICKWALL,
  --blname     = "blooded wall",
  --blcolor    = RED,
  --blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "³",
  asciilow   = "|",
  armor      = 10,
  hp         = 10,
  set        = CELLSET_WALLS,
  flags      = { CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL },
}

register_cell "oedoor" {
  name       = "elevator door",
  color      = LIGHTGRAY,
  coscolor   = { 0.5,0.5,0.5,1.0 },
  sprite     = SPRITE_OPENDOOR,
  --blname     = "blooded wall",
  --blcolor    = RED,
  --blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "/",
  flags      = { CF_NOCHANGE, CF_NORUN, CF_OVERLAY, CF_STICKWALL, CF_HIGHLIGHT },
}
register_cell "edoor" {
  name       = "elevator door",
  color      = LIGHTGRAY,
  coscolor   = { 0.5,0.5,0.5,1.0 },
  sprite     = SPRITE_DOOR,
  --blname     = "blooded wall",
  --blcolor    = RED,
  --blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "=",
  armor      = 10,
  hp         = 10,
  flags      = { CF_BLOCKLOS, CF_BLOCKMOVE, CF_NORUN, CF_OVERLAY, CF_STICKWALL, CF_HIGHLIGHT },
}

register_cell "plant1" {
  name       = "plant",
  color      = GREEN,
  coscolor   = { 0.0,1.0,0.0,1.0 },
  sprite     = SPRITE_TREE,
  --blname     = "blooded wall",
  --blcolor    = RED,
  --blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "%",
  armor      = 3,
  hp         = 2,
  flags      = { CF_BLOCKMOVE, CF_FRAGILE, CF_OVERLAY, CF_HIGHLIGHT },
}
register_cell "plant2" {
  name       = "potted plant",
  color      = GREEN,
  coscolor   = { 0.0,1.0,0.0,1.0 },
  sprite     = SPRITE_TREE,
  --blname     = "blooded wall",
  --blcolor    = RED,
  --blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "%",
  armor      = 3,
  hp         = 2,
  flags      = { CF_BLOCKMOVE, CF_FRAGILE, CF_OVERLAY, CF_HIGHLIGHT },
}
register_cell "tv" {
  name       = "Family Guy",
  color      = DARKGRAY,
  sprite     = SPRITE_YBOX,
  --blname     = "blooded wall",
  --blcolor    = RED,
  --blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "<",
  armor      = 5,
  hp         = 2,
  set        = CELLSET_WALLS,
  flags      = { CF_BLOCKMOVE, CF_OVERLAY, CF_HIGHLIGHT },
}
register_cell "brokentv" {
  name       = "broken TV",
  color      = DARKGRAY,
  sprite     = SPRITE_YBOX,
  --blname     = "blooded wall",
  --blcolor    = RED,
  --blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "\\",
  armor      = 5,
  hp         = 2,
  set        = CELLSET_WALLS,
  flags      = { CF_BLOCKMOVE, CF_OVERLAY, CF_HIGHLIGHT },
}

register_cell "couch" {
  name       = "couch",
  color      = BROWN,
  sprite     = SPRITE_BRIDGE,
  ascii      = "]",
  set        = CELLSET_FLOORS,
  flags      = { CF_HIGHLIGHT },
}

--Tomb
register_cell "sand" {
  name       = "sand",
  color      = BROWN,
  sprite     = SPRITE_CAVEFLOOR,
  blname     = "blood",
  blcolor    = RED,
  blsprite   = SPRITE_BLOOD,
  bloodto    = "bloodpool",
  ascii      = "ù",
  asciilow   = '.',
  set        = CELLSET_FLOORS,
  flags      = {},
}
register_cell "sandhill" {
  name       = "hill",
  color      = YELLOW,
  sprite     = SPRITE_CAVEFLOOR,
  blname     = "blood",
  blcolor    = RED,
  blsprite   = SPRITE_BLOOD,
  bloodto    = "bloodpool",
  ascii      = "ù",
  asciilow   = '.',
  set        = CELLSET_FLOORS,
  flags      = {},
}
register_cell "tile" {
  name       = "tile",
  color      = LIGHTGRAY,
  sprite     = SPRITE_FLOOR,
  blname     = "blood",
  blcolor    = RED,
  blsprite   = SPRITE_BLOOD,
  bloodto    = "bloodpool",
  ascii      = "ù",
  asciilow   = '.',
  set        = CELLSET_FLOORS,
  flags      = {},
}

register_cell "tombwall" {
  name       = "wall",
  color      = BROWN,
  coscolor   = { 1.0,0.8,0.6,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded wall",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "sand",
  ascii      = "#",
  armor      = 10,
  hp         = 100,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
}
register_cell "tombarch" {
  name       = "archway",
  color      = BROWN,
  coscolor   = { 1.0,0.8,0.6,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded archway",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "sand",
  ascii      = "#",
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
}
register_cell "tombglyph" {
  name       = "painting",
  color      = LIGHTGRAY,
  coscolor   = { 1.0,1.0,1.0,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded painting",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "sand",
  ascii      = "#",
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
}

--Barons
register_cell "greenfloor" {
  name       = "floor",
  color      = GREEN,
  sprite     = SPRITE_FLOOR,
  blname     = "blood",
  blcolor    = RED,
  blsprite   = SPRITE_BLOOD,
  bloodto    = "bloodpool",
  ascii      = "ù",
  asciilow   = '.',
  set        = CELLSET_FLOORS,
  flags      = {},
}
register_cell "barrier" {
  name       = "barrier",
  color      = MULTIPORTAL,
  coscolor   = { 1.0,0.1,1.0,1.0 },
  sprite     = SPRITE_PORTAL-4, --Very evil.  Good work.
  --blname     = "blooded wall",
  --blcolor    = RED,
  --blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "greenfloor",
  ascii      = "|",
  armor      = 20,
  hp         = 100,
  set        = CELLSET_WALLS,
  flags      = { CF_BLOCKMOVE, CF_OVERLAY, CF_HIGHLIGHT },
}
register_cell "baronwall" {
  name       = "wall",
  color      = GREEN,
  coscolor   = { 0.1,0.6,0.1,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded wall",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "greenfloor",
  ascii      = "#",
  armor      = 15,
  hp         = 20,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
}
register_cell "barondropwall" {
  name       = "wall",
  color      = GREEN,
  coscolor   = { 0.1,0.6,0.1,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded wall",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "greenfloor",
  ascii      = "#",
  armor      = 15,
  hp         = 20,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
}
register_cell "barongate" {
  name       = "gate",
  color      = BROWN,
  coscolor   = { 1.0,0.8,0.6,1.0 },
  sprite     = SPRITE_HELLDOOR,
  blname     = "blooded gate",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "greenfloor",
  ascii      = "#",
  armor      = 10,
  hp         = 15,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
}
register_cell "baronface" {
  name       = "stone face",
  color      = LIGHTGRAY,
  sprite     = SPRITE_BOSSWALL,
  blname     = "blooded stone face",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "greenfloor",
  ascii      = "#",
  armor      = 15,
  hp         = 20,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
}
register_cell "stair1" {
  name       = "step",
  color      = LIGHTGRAY,
  sprite     = SPRITE_FLOOR,
  blname     = "blood",
  blcolor    = RED,
  blsprite   = SPRITE_BLOOD,
  bloodto    = "bloodpool",
  ascii      = "ù",
  asciilow   = '.',
  set        = CELLSET_FLOORS,
  flags      = {},
}
register_cell "stair2" {
  name       = "step",
  color      = DARKGRAY,
  sprite     = SPRITE_FLOOR,
  blname     = "blood",
  blcolor    = RED,
  blsprite   = SPRITE_BLOOD,
  bloodto    = "bloodpool",
  ascii      = "ù",
  asciilow   = '.',
  set        = CELLSET_FLOORS,
  flags      = {},
}
register_cell "baronfface" {
  name       = "stone face",
  color      = DARKGRAY,
  sprite     = SPRITE_TELEPORT,
  blname     = "blood",
  blcolor    = RED,
  blsprite   = SPRITE_BLOOD,
  bloodto    = "bloodpool",
  ascii      = "ù",
  asciilow   = '.',
  set        = CELLSET_FLOORS,
  flags      = {},
}
register_cell "telebase" {
  name       = "teleporter base",
  color      = RED,
  sprite     = SPRITE_PORTAL,
  --blname     = "blood",
  --blcolor    = RED,
  --blsprite   = SPRITE_BLOOD,
  --bloodto    = "bloodpool",
  ascii      = "ð",
  asciilow   = '_',
  set        = CELLSET_FLOORS,
  flags      = {},
}
register_cell "flesh" {
  name       = "flesh?",
  color      = BROWN,
  sprite     = SPRITE_CAVEFLOOR,
  blname     = "blood",
  blcolor    = RED,
  blsprite   = SPRITE_BLOOD,
  bloodto    = "bloodpool",
  ascii      = "ù",
  asciilow   = '.',
  set        = CELLSET_FLOORS,
  flags      = {},
}

--Wolf
--Wolf cells are QUITE varied.  One noteworthy quirk is that flair can be destructible while the underlying wall is not.
register_cell "wolf_whwall" {
  name       = "stone wall",
  color      = LIGHTGRAY,
  coscolor   = { 1.0,1.0,1.0,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded stone wall",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "#",
  armor      = 10,
  hp         = 10,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
}
register_cell "wolf_f1whwall_x" {
  name       = "flag",
  color      = RED,
  coscolor   = { 1.0,0.8,0.8,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded flag",
  blcolor    = LIGHTRED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "#",
  armor      = 1,
  hp         = 5,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL, CF_FRAGILE},

  OnDestroy = function(c)
      level.map[ c ] = "wolf_whwall"
      level.light[c][LFPERMANENT] = true
      level.light[c][LFBLOOD] = false
  end
}
register_cell "wolf_f1whwall" {
  name       = "flag",
  color      = RED,
  coscolor   = { 1.0,0.8,0.8,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded flag",
  blcolor    = LIGHTRED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "#",
  armor      = 1,
  hp         = 5,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL, CF_FRAGILE},

  OnDestroy = function(c)
      level.map[ c ] = "wolf_whwall"
      level.light[c][LFBLOOD] = false
  end
}
register_cell "wolf_f2whwall_x" {
  name       = "painting",
  color      = BROWN,
  coscolor   = { 0.9,0.7,0.5,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded painting",
  blcolor    = LIGHTRED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "#",
  armor      = 1,
  hp         = 5,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL, CF_FRAGILE},

  OnDestroy = function(c)
      level.map[ c ] = "wolf_whwall"
      level.light[c][LFPERMANENT] = true
      level.light[c][LFBLOOD] = false
  end
}
register_cell "wolf_f2whwall" {
  name       = "painting",
  color      = BROWN,
  coscolor   = { 0.9,0.7,0.5,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded painting",
  blcolor    = LIGHTRED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "#",
  armor      = 1,
  hp         = 5,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL, CF_FRAGILE},

  OnDestroy = function(c)
      level.map[ c ] = "wolf_whwall"
      level.light[c][LFBLOOD] = false
  end
}

register_cell "wolf_rewall" {
  name       = "brick wall",
  color      = RED,
  coscolor   = { 1.0,0.0,0.0,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded brick wall",
  blcolor    = LIGHTRED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "#",
  armor      = 8,
  hp         = 10,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
}
register_cell "wolf_f1rewall_x" {
  name       = "wreath",
  color      = GREEN,
  coscolor   = { 0.2,1.0,0.1,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded wreath",
  blcolor    = LIGHTRED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "#",
  armor      = 1,
  hp         = 5,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL, CF_FRAGILE},

  OnDestroy = function(c)
      level.map[ c ] = "wolf_rewall"
      level.light[c][LFPERMANENT] = true
      level.light[c][LFBLOOD] = false
  end
}
register_cell "wolf_f1rewall" {
  name       = "wreath",
  color      = GREEN,
  coscolor   = { 0.2,1.0,0.1,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded wreath",
  blcolor    = LIGHTRED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "#",
  armor      = 1,
  hp         = 5,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL, CF_FRAGILE},

  OnDestroy = function(c)
      level.map[ c ] = "wolf_rewall"
      level.light[c][LFBLOOD] = false
  end
}
register_cell "wolf_f2rewall_x" {
  name       = "eagle flag",
  color      = MAGENTA,
  coscolor   = { 0.9,0.1,0.9,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded eagle flag",
  blcolor    = LIGHTRED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "#",
  armor      = 1,
  hp         = 5,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL, CF_FRAGILE},

  OnDestroy = function(c)
      level.map[ c ] = "wolf_rewall"
      level.light[c][LFPERMANENT] = true
      level.light[c][LFBLOOD] = false
  end
}
register_cell "wolf_f2rewall" {
  name       = "eagle flag",
  color      = MAGENTA,
  coscolor   = { 0.9,0.1,0.9,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded eagle flag",
  blcolor    = LIGHTRED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "#",
  armor      = 1,
  hp         = 5,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL, CF_FRAGILE},

  OnDestroy = function(c)
      level.map[ c ] = "wolf_rewall"
      level.light[c][LFBLOOD] = false
  end
}

register_cell "wolf_brwall" {
  name       = "wooden wall",
  color      = BROWN,
  coscolor   = { 0.8,0.6,0.4,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded wooden wall",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "#",
  armor      = 8,
  hp         = 6,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
}
register_cell "wolf_f1brwall_x" {
  name       = "painting",
  color      = WHITE,
  coscolor   = { 1.0,1.0,1.0,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded painting",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "#",
  armor      = 1,
  hp         = 5,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL, CF_FRAGILE},

  OnDestroy = function(c)
      level.map[ c ] = "wolf_brwall"
      level.light[c][LFPERMANENT] = true
      level.light[c][LFBLOOD] = false
  end
}
register_cell "wolf_f1brwall" {
  name       = "painting",
  color      = WHITE,
  coscolor   = { 1.0,1.0,1.0,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded painting",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "#",
  armor      = 1,
  hp         = 5,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL, CF_FRAGILE},

  OnDestroy = function(c)
      level.map[ c ] = "wolf_brwall"
      level.light[c][LFBLOOD] = false
  end
}
register_cell "wolf_f2brwall_x" {
  name       = "eagle painting",
  color      = RED,
  coscolor   = { 1.0,0.2,0.2,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded eagle painting",
  blcolor    = LIGHTRED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "#",
  armor      = 1,
  hp         = 5,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL, CF_FRAGILE},

  OnDestroy = function(c)
      level.map[ c ] = "wolf_brwall"
      level.light[c][LFPERMANENT] = true
      level.light[c][LFBLOOD] = false
  end
}
register_cell "wolf_f2brwall" {
  name       = "eagle painting",
  color      = RED,
  coscolor   = { 1.0,0.2,0.2,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded eagle painting",
  blcolor    = LIGHTRED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "#",
  armor      = 1,
  hp         = 5,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL, CF_FRAGILE},

  OnDestroy = function(c)
      level.map[ c ] = "wolf_brwall"
      level.light[c][LFBLOOD] = false
  end
}

register_cell "wolf_blwall" {
  name       = "blue wall",
  color      = BLUE,
  coscolor   = { 0.1,0.1,1.0,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded blue wall",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "#",
  armor      = 10,
  hp         = 10,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
}

register_cell "wolf_door1" {
  name       = "closed metal door",
  color      = LIGHTGRAY,
  sprite     = SPRITE_DOOR,
  blname     = "blooded metal door",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "+",
  armor      = 10,
  hp         = 10,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL, CF_OPENABLE, CF_RUNSTOP, CF_HIGHLIGHT},

  OnAct = function(c,being)
    if not being:is_player() then
      being:msg("You open the door.")
      being:play_sound("wolf_door.open")
      level.map[ c ] = "wolf_odoor1"
      being.scount = being.scount - 500
      return true
    end
  end,
}
register_cell "wolf_odoor1" {
  name       = "open metal door",
  ascii      = "/",
  color      = LIGHTGRAY,
  sprite     = SPRITE_OPENDOOR,
  flags      = {CF_NOCHANGE, CF_NORUN, CF_OVERLAY, CF_STICKWALL, CF_CLOSABLE, CF_RUNSTOP, CF_NUKABLE, CF_HIGHLIGHT },

  OnAct = function(c,being)
      if not being:is_player() and level:get_being(c) == nil and level:get_item(c) == nil then
          being:msg("You close the door.")
          being:play_sound("wolf_door.close")
          level.map[ c ] = "wolf_door1"
          being.scount = being.scount - 500
          return true
      end
  end,
}
register_cell "wolf_ldoor1" {
  name       = "stone wall",
  color      = LIGHTGRAY,
  coscolor   = { 1.0,1.0,1.0,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded stone wall",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "floor",
  ascii      = "#",
  armor      = 10,
  hp         = 10,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
}

--Future
register_cell "ceiling" {
  name       = "ceiling",
  color      = LIGHTGRAY,
  sprite     = SPRITE_FLOOR,
  blname     = "blood",
  blcolor    = RED,
  blsprite   = SPRITE_BLOOD,
  bloodto    = "bloodpool",
  ascii      = "ù",
  asciilow   = '.',
  set        = CELLSET_FLOORS,
  flags      = {},
}
register_cell "futurewall" {
  name       = "futuristic wall",
  color      = WHITE,
  coscolor   = { 0.0,1.0,1.0,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded futuristic wall",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "ceiling",
  ascii      = "#",
  armor      = 15,
  hp         = 10,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
}
register_cell "futuredropwall" {
  name       = "futuristic wall",
  color      = WHITE,
  coscolor   = { 0.0,1.0,1.0,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded futuristic wall",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "ceiling",
  ascii      = "#",
  armor      = 15,
  hp         = 10,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
}
register_cell "futurepillar" {
  name       = "futuristic pillar",
  color      = LIGHTGRAY,
  coscolor   = { 0.0,1.0,1.0,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded futuristic pillar",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "ceiling",
  ascii      = "O",
  armor      = 15,
  hp         = 10,
  set        = CELLSET_WALLS,
  flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
}

--Void
register_cell "recess" {
  name       = "recess",
  color      = DARKGRAY,
  sprite     = SPRITE_CAVEFLOOR,
  blname     = "blood",
  blcolor    = RED,
  blsprite   = SPRITE_BLOOD,
  bloodto    = "bloodpool",
  ascii      = "ù",
  asciilow   = '.',
  set        = CELLSET_FLOORS,
  flags      = {},
}

--Boss
register_cell "ironfloor" {
  name       = "iron floor",
  color      = DARKGRAY,
  sprite     = SPRITE_FLOOR,
  blname     = "blood",
  blcolor    = RED,
  blsprite   = SPRITE_BLOOD,
  bloodto    = "bloodpool",
  ascii      = "ù",
  asciilow   = '.',
  set        = CELLSET_FLOORS,
  flags      = {},
}
register_cell "redflesh" {
  name       = "flesh",
  color      = RED,
  sprite     = SPRITE_CAVEFLOOR,
  --blname     = "blood",
  --blcolor    = RED,
  --blsprite   = SPRITE_BLOOD,
  --bloodto    = "bloodpool",
  ascii      = "ù",
  asciilow   = '.',
  set        = CELLSET_FLOORS,
  flags      = {},
}
register_cell "bloodriver" {
  name       = "flowing blood",
  color      = RED,
  sprite     = SPRITE_WATER,
  --blname     = "blood",
  --blcolor    = RED,
  --blsprite   = SPRITE_BLOOD,
  --bloodto    = "bloodpool",
  ascii      = "ù",
  asciilow   = '.',
  set        = CELLSET_FLOORS,
  flags      = {},
}
register_cell "corpse2"
{
  name = "bloody corpse";
  ascii = "%";
  color = RED;
  set = CELLSET_FLOORS;
  flags = {CF_OVERLAY, CF_NOCHANGE, CF_VBLOODY};
  destroyto = "bloodriver",
  sprite = SPRITE_CORPSE,
}
register_cell "bosswall1" {
  name       = "wall",
  color      = LIGHTGRAY,
  coscolor   = { 0.9,0.8,0.8,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded wall",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "ironfloor",
  ascii      = "#",
  armor      = 20,
  hp         = 15,
  set        = CELLSET_WALLS,
  flags      = { CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL },
}
register_cell "bosswall2" {
  name       = "wall",
  color      = DARKGRAY,
  coscolor   = { 0.5,0.4,0.4,1.0 },
  sprite     = SPRITE_BRICKWALL,
  blname     = "blooded wall",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "ironfloor",
  ascii      = "#",
  armor      = 20,
  hp         = 15,
  set        = CELLSET_WALLS,
  flags      = { CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL },
}
register_cell "irondoor" {
  name       = "iron door",
  color      = DARKGRAY,
  sprite     = SPRITE_HELLDOOR,
  blname     = "blooded iron door",
  blcolor    = RED,
  blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "ironfloor",
  ascii      = "#",
  armor      = 20,
  hp         = 15,
  set        = CELLSET_WALLS,
  flags      = { CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL },
}
register_cell "skullpillar" {
  name       = "pillar of skulls",
  color      = BROWN,
  coscolor   = { 0.8,0.6,0.4,1.0 },
  sprite     = SPRITE_BRICKWALL,
  --blname     = "blooded wall",
  --blcolor    = RED,
  --blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "ironfloor",
  ascii      = "#",
  armor      = 15,
  hp         = 15,
  set        = CELLSET_WALLS,
  flags      = { CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL },
}
register_cell "ironfence" {
  name       = "iron fence",
  color      = LIGHTRED,
  coscolor   = { 0.5,0.4,0.4,1.0 },
  sprite     = SPRITE_BRICKWALL,
  --blname     = "blooded wall",
  --blcolor    = RED,
  --blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "ironfloor",
  ascii      = "#",
  armor      = 8,
  hp         = 6,
  set        = CELLSET_WALLS,
  flags      = { CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL },
}
register_cell "bloodportal" {
  name       = "portal?",
  color      = LIGHTRED,
  coscolor   = { 1.0,0.0,0.0,1.0 },
  sprite     = SPRITE_PORTAL-4,
  --blname     = "blooded wall",
  --blcolor    = RED,
  --blsprite   = SPRITE_WALLBLOOD,
  destroyto  = "ironfloor",
  ascii      = "_",
  armor      = 20,
  hp         = 100,
  set        = CELLSET_WALLS,
  flags      = { CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL },
}
register_cell "bloodportal1" {
  name       = "portal",
  color      = RED,
  coscolor   = { 0.5,0.0,0.0,1.0 },
  sprite     = SPRITE_PORTAL-4,
  ascii      = "-",
  armor      = 20,
  hp         = 100,
  flags      = { CF_BLOCKLOS, CF_NOCHANGE, CF_NORUN, CF_OVERLAY, CF_STICKWALL, CF_HIGHLIGHT },
}
register_cell "bloodportal2" {
  name       = "portal",
  color      = LIGHTRED,
  coscolor   = { 1.0,0.0,0.0,1.0 },
  sprite     = SPRITE_PORTAL-4,
  ascii      = "-",
  armor      = 20,
  hp         = 100,
  flags      = { CF_BLOCKLOS, CF_NOCHANGE, CF_NORUN, CF_OVERLAY, CF_STICKWALL, CF_HIGHLIGHT },
}
