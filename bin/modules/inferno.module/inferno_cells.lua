Cells({
  id = "pblood",
  name = "blood",
  ascii = ".",
  color = RED,
  color_id = "blood",
  set = CELLSET_FLOORS,
  flags = {CF_BLOCKMOVE, CF_OVERLAY},
  sprite = SPRITE_BLOOD,
})

Cells({
  id = "treeb",
  name = "tree",
  ascii = "T",
  color = BROWN,
  armor = 5,
  hp = 5,
  flags = {CF_OVERLAY, CF_FRAGILE, CF_BLOCKMOVE},
  sprite = SPRITE_TREE,
})

Cells({
  id = "cwall",
  name = "stone wall",
  ascii = "#",
  color = LIGHTGRAY,
  armor = 10,
  hp = 10,
  set = CELLSET_WALLS,
  flags = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
  coscolor = {0.7, 0.35, 0.1, 1.0},
  bloodto = "bwall",
  sprite = SPRITE_CAVEWALL,
})

Cells({
  id = "lavawall",
  name = "pillar",
  ascii = "#",
  color = RED,
  hp = 12,
  armor = 10,
  set = CELLSET_WALLS,
  flags = {CF_BLOCKMOVE, CF_BLOCKLOS, CF_MULTISPRITE, CF_STICKWALL},
  sprite = SPRITE_BOSSWALL,
  destroyto = "lava",
})

Cells({
  id = "display",
  name = "display case",
  ascii = " ",
  color = RED,
  set = CELLSET_WALLS,
  flags = {CF_BLOCKMOVE},
  sprite = SPRITE_HELLFLOOR,
})

Cells({
  id = "invis_wall",
  name = "floor",
  ascii      = "ù",
  asciilow   = '.',
  color = LIGHTGRAY,
  color_id = "floor",
  set = CELLSET_WALLS,
  flags = {CF_BLOCKMOVE},
  sprite = SPRITE_FLOOR,
})

Cells({
  id = "invis_wallb",
  name = "floor",
  ascii      = "ù",
  asciilow   = '.',
  color = LIGHTGRAY,
  color_id = "floor",
  set = CELLSET_WALLS,
  flags = {CF_BLOCKMOVE},
  sprite = SPRITE_HELLFLOOR,
})

--[[
Cells({
  id = "creepy_floor",
  name = "floor",
  ascii = "\249",
  asciilow = ".",
  color = LIGHTGRAY,
  bloodto = "blood",
  sprite = 97,
  set = CELLSET_FLOORS,
  OnEnter = function(c, being)
    if being:is_player() then
      Level[c] = "blood"
    end
  end,
})
]]
--[[
Cells({
  id = "bone_floor",
  name = "floor",
  color = WHITE,
  ascii = "\249",
  asciilow = ".",
  bloodto = "blood",
  sprite = 97,
  set = CELLSET_FLOORS,
})
]]

Cells({
  name = "crusher",
  ascii = "#",
  color = LIGHTGRAY,
  set = CELLSET_WALLS,
  flags = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
  bloodto = "bcrusher",
  sprite = SPRITE_WALL,
})

Cells({
  name = "crusher",
  id = "bcrusher",
  ascii = "#",
  color = RED,
  set = CELLSET_WALLS,
  flags = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_OVERLAY, CF_STICKWALL},
  bloodto = "bcrusher",
  sprite = SPRITE_WALLBLOOD,
})

--[[
Cells({
  id = "bone_wall",
  name = "bone wall",
  ascii = "#",
  color = WHITE,
  armor = 5,
  hp = 6,
  set = CELLSET_WALLS,
  flags = {
    CF_BLOCKLOS,
    CF_BLOCKMOVE,
    CF_MULTISPRITE,
    CF_STICKWALL},
  bloodto = "bwall",
  sprite = 98
})
]]

Cells({
  id = "trap_lava_bridge",
  name = "bridge",
  ascii = "=",
  color = BROWN,
  color_id = "bridge",
  sprite = SPRITE_BRIDGE,
  OnEnter = function(c, being)
    if being:is_player() then
      ui.msg("Suddenly, the bridge beneath your feet lowers into the lava!")
      Level[c] = "lava"
    end
  end,
})

Cells({
  id = "secret_wall",
  name = "stone wall",
  ascii = "#",
  color = LIGHTGRAY,
  color_id = "wall",
  set = CELLSET_WALLS,
  flags = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_PUSHABLE, CF_MULTISPRITE, CF_STICKWALL},
  sprite = SPRITE_WALL,
  OnAct = function(c, being)
    if being:is_player() then
      ui.msg("You have found a secret door!")
      being:play_sound("door.open")
      Level[c] = "floor"
      inferno.Secret.trigger_secret(Level.id)
      player.secrets_found = player.secrets_found + 1
      being.scount = being.scount - 500
    end
  end,
})

Cells({
  id = "secret_rwall",
  name = "bloodstone",
  ascii = "#",
  color = RED,
  color_id = "rwall",
  set = CELLSET_WALLS,
  flags = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_PUSHABLE, CF_MULTISPRITE, CF_STICKWALL},
  sprite = cells.rwall.sprite,
  coscolor = cells.rwall.coscolor,
  OnAct = function(c, being)
    if being:is_player() then
      ui.msg("You have found a secret door!")
      being:play_sound("door.open")
      Level[c] = "floorb"
      inferno.Secret.trigger_secret(Level.id)
      player.secrets_found = player.secrets_found + 1
      being.scount = being.scount - 500
    end
  end,
})

Cells({
  name = "blood",
  id = "blood_river",
  ascii = "=",
  color = RED,
  flags = {F_GTSHIFT, F_GFLUID, CF_LIQUID, CF_NOCHANGE},
  sprite = SPRITE_WATER,
})

Cells({
  name = "blood",
  id = "pblood_river",
  ascii = "=",
  color = RED,
  color_id = "blood_river",
  set = CELLSET_WALLS,
  flags = {CF_BLOCKLOS, CF_BLOCKMOVE},
  sprite = 174,
})

Cells({
  name = "bloody corpse",
  id = "pcorpse",
  ascii = "%",
  color = RED,
  color_id = "corpse",
  set = CELLSET_WALLS,
  flags = {CF_BLOCKLOS, CF_BLOCKMOVE},
  sprite = 165,
})

Cells({
  name = "web",
  color = WHITE,
  ascii = "*",
  sprite = 97,
  set = CELLSET_FLOORS,
  armor = 1,
  OnEnter = function(c, enterer)
    if enterer ~= player then return end
    if player.__props.web then return end
    player.__props.web = true
    player.speed = player.speed - 25
    player:msg("The web is making your movements difficulty.")
  end
})

cells.web.OnTick = function()
  if not player.__props.web then return end
  if Level[player:get_position()] ~= "web" then
    player.web = false
    player.speed = player.speed + 25
  end
end

Cells({
  id = "windowv",
  name = "window",
  ascii = "\179",
  asciilow = "|",
  color = LIGHTGRAY,
  set = CELLSET_WALLS,
  flags = {CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
  sprite = SPRITE_BRICKWALL,
  coscolor = {0.9, 0.9, 0.9, 1.0},
})

Cells({
  id = "windowv_fragile",
  name = "window",
  ascii = "\179",
  asciilow = "|",
  armor = 1,
  hp = 1,
  color = LIGHTGRAY,
  set = CELLSET_WALLS,
  flags = {CF_BLOCKMOVE, CF_FRAGILE, CF_MULTISPRITE, CF_STICKWALL},
  sprite = SPRITE_BRICKWALL,
  coscolor = {0.9, 0.9, 0.9, 1.0},
})

Cells({
  id = "windowh",
  name = "window",
  ascii = "\196",
  asciilow = "-",
  color = LIGHTGRAY,
  set = CELLSET_WALLS,
  flags = {CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
  sprite = SPRITE_BRICKWALL,
  coscolor = {0.9, 0.9, 0.9, 1.0},
})

Cells({
  id = "windowh_fragile",
  name = "window",
  ascii = "\196",
  asciilow = "-",
  armor = 1,
  hp = 1,
  color = LIGHTGRAY,
  set = CELLSET_WALLS,
  flags = {CF_BLOCKMOVE, CF_FRAGILE, CF_MULTISPRITE, CF_STICKWALL},
  sprite = SPRITE_BRICKWALL,
  coscolor = {0.9, 0.9, 0.9, 1.0},
})

Cells({
  id = "windowul",
  name = "window",
  ascii = "\218",
  asciilow = "+",
  color = LIGHTGRAY,
  set = CELLSET_WALLS,
  flags = {CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
  sprite = SPRITE_BRICKWALL,
  coscolor = {0.9, 0.9, 0.9, 1.0},
})

Cells({
  id = "windowur",
  name = "window",
  ascii = "\191",
  asciilow = "+",
  color = LIGHTGRAY,
  set = CELLSET_WALLS,
  flags = {CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
  sprite = SPRITE_BRICKWALL,
  coscolor = {0.9, 0.9, 0.9, 1.0},
})

Cells({
  id = "windowdl",
  name = "window",
  ascii = "\192",
  asciilow = "+",
  color = LIGHTGRAY,
  set = CELLSET_WALLS,
  flags = {CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
  sprite = SPRITE_BRICKWALL,
  coscolor = {0.9, 0.9, 0.9, 1.0},
})

Cells({
  id = "windowdr",
  name = "window",
  ascii = "\217",
  asciilow = "+",
  color = LIGHTGRAY,
  set = CELLSET_WALLS,
  flags = {CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
  sprite = SPRITE_BRICKWALL,
  coscolor = {0.9, 0.9, 0.9, 1.0},
})

function inferno.void_tick(force)
  if force or core.game_time() % 10 == 0 then
    for c in area.FULL:coords() do
      local cell_id = Level[c]
      if cell_id == "void1" then
        Level[c] = table.random_pick{"void2", "void3", "void4"}
      elseif cell_id == "void2" then
        Level[c] = table.random_pick{"void1", "void3", "void4"}
      elseif cell_id == "void3" then
        Level[c] = table.random_pick{"void1", "void2", "void4"}
      elseif cell_id == "void4" then
        Level[c] = table.random_pick{"void1", "void2", "void3"}
      end
    end
  end
end

Cells({
  id = "void1",
  name = "void",
  ascii = "\247",
  asciilow = "=",
  color = RED,
  color_dark = BLACK,
  set = CELLSET_WALLS,
  flags = {F_GTSHIFT, F_GFLUID, CF_BLOCKMOVE},
  sprite = SPRITE_WATER,
})

Cells({
  id = "void2",
  name = "void",
  ascii = "\247",
  asciilow = "=",
  color = LIGHTRED,
  color_dark = BLACK,
  set = CELLSET_WALLS,
  flags = {F_GTSHIFT, F_GFLUID, CF_BLOCKMOVE},
  sprite = SPRITE_WATER,
})

Cells({
  id = "void3",
  name = "void",
  ascii = "\247",
  asciilow = "=",
  color = MAGENTA,
  color_dark = BLACK,
  set = CELLSET_WALLS,
  flags = {F_GTSHIFT, F_GFLUID, CF_BLOCKMOVE},
  sprite = SPRITE_WATER,
})

Cells({
  id = "void4",
  name = "void",
  ascii = "\247",
  asciilow = "=",
  color = LIGHTMAGENTA,
  color_dark = BLACK,
  set = CELLSET_WALLS,
  flags = {F_GTSHIFT, F_GFLUID, CF_BLOCKMOVE},
  sprite = SPRITE_WATER,
})