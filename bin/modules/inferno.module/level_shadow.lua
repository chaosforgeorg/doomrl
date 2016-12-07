Items({
  name = "shadow orb",
  id = "shadoworb",
  color = BLACK,
  sprite = 0,
  level = 200,
  weight = 0,
  sprite = SPRITE_MEGASPHERE,
  type = ITEMTYPE_POWER,
  flags = {F_GLOW, IF_NODESTROY},
  glow = {0.1, 0.1, 0.1, 0.8},
  OnPickup = function(self, being)
    being:msg("The shadow orb dissolves before you can pick it up.")
    being:msg("You feel a sinister presence.")
    Level.result(2)
    local c = coord.new(70, 10)
    local demon
    if not Level.get_being(c) then
      demon = Level.drop_being("shadowdemon", c)
    else
      demon = Level.drop_being("shadowdemon", Level.empty_coord())
    end
    if demon then
      demon.inv:add(item.new("usouls"))
    end
    Level.clear_item(self:get_position())
  end,
})

Items({
  name = "Staff of Souls",
  id = "usouls",
  color = YELLOW,
  sprite = SPRITE_STAFF,
  level = 200,
  weight = 0,
  type = ITEMTYPE_PACK,
  desc = "Through this staff, you can feel the spirits of all creatures.",
  flags = {IF_UNIQUE},
  ascii = "?",
  OnCreate = function(self)
    self:add_property("cost", 3)
  end,
  OnUse = function(self, being)
    if not being:is_player() then
      return false
    end
    if being.tired then
      ui.msg("You're too tired to use it now.")
      return false
    end
    if being.hpmax <= 10 then
      ui.msg("You need more vitality to use it.")
      return false
    end
    being.tired = true
    being:play_sound("powerup")
    ui.msg("Part of your soul is ripped out! But you can now sense nearby creatures.")
    ui.blink(DARKGRAY, 50)
    being.hpmax = being.hpmax - self.cost
    self.cost = 5 - self.cost
    being.hp = math.min(being.hp, being.hpmax * 2)
    Level.flags[LF_BEINGSVISIBLE] = true
    being.scount = being.scount - 1000
    return false
  end
})

Medal({
  id = "inferno_shadow1",
  name = "Shadow Medal",
  desc = "Defeated the shadow demon",
  hidden = true,
})

-- Results:
-- 1: initial
-- 2: used shadow orb
-- 3: killed shadow demon

Levels("SHADOW",{

  name = "Erebus",
  
  entry = "On level @1 he descended into Erebus...",
  
  welcome = "You enter Erebus.",
  
  find_phrase = "There he discovered the @1.",
  
  mortem_location = "among the shadows of Erebus",
  
  type = "special",
  
  Create = function()
    Level.fill("wall")
    local translation = {
      ["."] = "floor",
      [","] = "blood",
      ["o"] = "bloodpool",
      ["X"] = {"wall", flags = {LFPERMANENT}},
      ["#"] = "wall",
      [">"] = "stairs",
      ["B"] = "bwall",
      ["P"] = {"bwall", flags = {LFPERMANENT}},
      ["^"] = {"bloodpool", item = "shadoworb"},
      ["|"] = {"floor", item = "cell"},
      ["/"] = {"floor", item = "rocket"},
      ["c"] = {"floor", being = "spectre"},
      ["d"] = {"floor"},
      ["e"] = {"floor"},
      ["K"] = {"floor", being = "imp"},
      [";"] = {"floor", item = "pboots"},
      ["["] = {"floor", item = "barmor"},
    }
    if DIFFICULTY >= 3 then
      translation["d"].being = "spectre"
      translation["K"].being = "knight"
    end
    if DIFFICULTY >= 4 then
      translation["e"].being = "spectre"
      translation["K"].being = "baron"
    end
    local map = [[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXPPXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXX.....XXXXP,,....,........XXXXX.....XXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXX.........X....##.,o....##....X.........XXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXX.....###........#..,.d....#........###.....XXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXX.....###XX##..........c.c..........##XX###.....XXXXXXXXXXXXXXX
XXXXXXXXXXXX.......##XX###...##...#..e..#,..##...###XX##.......XXXXXXXXXXXXX
XXXXXXXXXX....###....###..c..#...##..K..#B...#..c..###....###....XXXXXXXXXXX
XXXXX|.......##X##...e.d....,o.e.....,.....e.......d.e...##X##........|XXXXX
XXXX/..>.....#XXX#....[...K.,o,.c...,^,...c....K....;....#XXX#........./XXXX
XXXXX|.......##X##...e.d.....,.e.....,.....e..,....d.e...##X##........|XXXXX
XXXXXXXXXX....###....###,,c..#...##..K..##..,Bo.c..###....###....XXXXXXXXXXX
XXXXXXXXXXXX.......###XX#B...##...#..e..#...#B,..###XX##.......XXXXXXXXXXXXX
XXXXXXXXXXXXXX.....##XX###,.........c.c..........##XX###.....XXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXX.....###........#....d...,B,.......###.....XXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXX.........X....##.......BB,,..X.........XXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXX.....XXXXX............,,oPXXXX.....XXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXPPPXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    ]]
    Level.place_tile(translation, map, 2, 2)
    Level.player(70, 10)
  end,
  
  OnEnter = function()
    Level.result(1)
    player.vision = player.vision - 2
    ui.msg("The darkness here is palpable.")
    if inferno.test then
      player.eq.weapon = item.new("ashotgun")
      player.inv:add(item.new("shell"))
      player.inv:add(item.new("shell"))
      player.inv:add(item.new("shell"))
      player.inv:add(item.new("shell"))
      player.inv:add(item.new("shell"))
      player.eq.prepared = item.new("plasma")
      player.inv:add(item.new("cell"))
      player.inv:add(item.new("cell"))
      player.inv:add(item.new("cell"))
      player.inv:add(item.new("cell"))
      player.inv:add(item.new("cell"))
    end
  end,
  
  OnKill = function(b)
    if Level.result() == 2 and b.id == "shadowdemon" then
      player:add_medal("inferno_shadow1")
      Level.result(3)
    end
  end,
  
  OnExit = function()
    player.vision = player.vision + 2
    if Level.result() == 3 then
      player:add_history("He banished the shadow demon!")
      ui.msg("You aren't afraid of shadows.")
      player.completed_levels["SHADOW"] = true
    elseif Level.result() == 2 then
      player:add_history("He fled that place, the shadows at his heels!")
      ui.msg("Shadows aren't supposed to kill you!")
    else
      player:add_history("He was not tempted by shadows.")
      ui.msg("You hear the faint sound of mocking laughter behind you.")
    end
  end,

  OnKillAll = function()
    local result = Level.result()
    if result == 1 then
      ui.msg("You feel like you are being watched.")
    else
      ui.msg("Stillness returns to this dark place.")
    end
  end,
  
  IsCompleted = function()
    return Level.result() == 3
  end,
  
})