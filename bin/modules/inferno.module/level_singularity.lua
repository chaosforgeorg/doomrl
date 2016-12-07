local finished = {false, false, false, false}
local pos = {nil, nil, nil, nil}
local spawned = 0

Items({
  id = "portal_lever",
  name = "lever",
  color = WHITE,
  color_id = "lever",
  sprite = SPRITE_LEVER,
  weight = 0,
  type = ITEMTYPE_LEVER,
  flags = {IF_NODESTROY, IF_NUKERESIST},
  good = "beneficial",
  desc = "closes a portal",
  OnCreate = function(self)
    self:add_property("trigger", false)
  end,
  OnUse = function(self, being)
    if not being:is_player() then
      return
    end
    being:msg("The portal closes!")
    if self.trigger then
      self.trigger()
    end
    Level.clear_item(self:get_position())
    return true
  end,
})

Items({
  name = "portal",
  id = "sing_portal",
  color = MULTIPORTAL,
  sprite = SPRITE_PORTAL,
  ascii = "0",
  weight = 0,
  type = ITEMTYPE_TELE,
  flags = {IF_NODESTROY, IF_NUKERESIST},
  OnEnter = function(self, being)
    if not being:is_player() then
      return
    end
    ui.msg("You need to close the portal quickly!")
  end
})

Items({
  name = "closed portal",
  id = "sing_portal_closed",
  color = DARKGRAY,
  sprite = SPRITE_PORTAL,
  ascii = "0",
  weight = 0,
  type = ITEMTYPE_TELE,
  flags = {IF_NODESTROY, IF_NUKERESIST},
  OnEnter = function() end,
})

Items({
  name = "Duplication Pack",
  id = "upack_duplicate",
  color = YELLOW,
  level = 1,
  weight = 0,
  sprite = SPRITE_PHASE,
  type = ITEMTYPE_PACK,
  flags = {IF_UNIQUE},
  ascii = "+",
  desc = "This advanced technology will duplicate any item that is sitting on the floor.",
  OnUse = function(self, being)
    if not being:is_player() then
      return false
    end
    local it = Level.get_item(being:get_position())
    if not it or it.itype == ITEMTYPE_TELE or it.itype == ITEMTYPE_LEVER or it.itype == ITEMTYPE_POWER then
      being:msg("There is nothing here to duplicate.")
      return false
    else
      self:destroy()
      being.inv:add(item.clone(it))
      return false
    end
  end
})

Medal({
  id = "inferno_sing1",
  name = "Lightning Cross",
  desc = "Allowed no more than two barons to enter the Singularity",
  hidden = true,
})

Levels("SINGULARITY",{

  name = "Singularity",
  
  entry = "On level @1 he approached the Singularity...",
  
  welcome = "You enter the Singularity.",
  
  find_phrase = "There he found the @1.",
  
  mortem_location = "in the Singularity",
  
  type = "special",
  
  style = inferno.styles.base_style,
  
  Create = function()
    Level.fill("rwall")
    local translation = {
      ["."] = "floor",
      ["#"] = "wall",
      ["X"] = {"wall", flags = {LFPERMANENT}},
      [">"] = "stairs",
      ["+"] = "door",
      ["="] = "void1",
      ["w"] = "windowv",
      ["W"] = "windowh",
      [":"] = {"floor", item = "ammo"},
      [";"] = {"floor", item = "shell"},
      ["/"] = {"floor", item = "rocket"},
      ["|"] = {"floor", item = "cell"},
      ["|"] = {"floor", item = "cell"},
      ["L"] = {"floor", item = "bazooka"},
      ["P"] = {"floor", item = "plasma"},
      ["1"] = "floor",
      ["2"] = "floor",
      ["3"] = "floor",
      ["4"] = "floor",
      ["A"] = {"floor", item = "sing_portal"},
      ["B"] = {"floor", item = "sing_portal"},
      ["C"] = {"floor", item = "sing_portal"},
      ["D"] = {"floor", item = "sing_portal"},
      ["h"] = {"floor", being = "former"},
      ["g"] = {"floor", being = "sergeant"},
      ["d"] = {"floor"},
    }
    if DIFFICULTY >= 3 then
      translation["g"].being = "captain"
      translation["h"].being = "sergeant"
    end
    if DIFFICULTY >= 4 then
      translation["d"].being = "commando"
    end
    local map = [[
==============================================================================
===============XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=================
===============X1...........;#.......::.......#;...........4X=================
===============X...A..#.....;#....g..##..g....#;........D...X=================
===============X.g......d#.........#....#.........#d......g.X=================
=========XXXXXXX#.#.#.#..#.....h............h.....#.##.##.##XX================
=========w:.....................#..........#.................XXXX=============
=========w:........................##..##.............#.##.##X>XXXX===========
=======XXX#+####.##..##..#.........#....#.............#.h..#...h||w===========
======XX.......+..h..h........#.......>......#.............+..g..Pw===========
======X>....g..#.##..##..#.........#....#.............#.h..#...h||w===========
======XX..h..h.#...................##..##.............#.##.###+#XXX===========
=======X//.L.//#................#..........#....................X=============
=======XXXWWWXXX#.#.#.#..#.....h............h.....#.##.##.##XXXXX=============
===============X.g......d#.........#....#.........#d......g.X=================
===============X...B..#.....;#....g..##..g....#;........C...X=================
===============X2...........;#.......::.......#;...........3X=================
===============XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=================
==============================================================================
==============================================================================
    ]]
    Level.place_tile(translation, map, 1, 1)
    Level.player(38, 10)
    finished = {false, false, false, false}
    local lever_pos = {
      coord.new(17, 3),
      coord.new(17, 17),
      coord.new(60, 17),
      coord.new(60, 3),
    }
    pos = {
      coord.new(20, 4),
      coord.new(20, 16),
      coord.new(57, 16),
      coord.new(57, 4),
    }
    for i = 1, 4 do -- make sure it's lua 5.1 ;)
      local lever = item.new("portal_lever")
      lever.trigger = function()
        finished[i] = true
        Level.clear_item(pos[i])
        Level.drop_item("sing_portal_closed", pos[i])
        Level.result(Level.result() + 1)
        player:add_exp(500)
      end
      Level.drop_item(lever, lever_pos[i])
    end
    spawned = 0
  end,
  
  OnTick = function()
    local res = Level.result()
    inferno.void_tick()
    if res == 6 then
      return
    end
    if res == 5 then
      Level.result(6)
      local pos = player:get_position()
      Level.drop_item("hphase", pos)
      Level.drop_item("upack_duplicate", pos)
      Level.drop_item("msglobe", pos)
      ui.msg("Whew! That's all of them.")
    end
    local t = diffchoice(560, 500, 450, 395, 345)
    local b = diffchoice("baron", "baron", "baron", "baron", "baron")
    if (player.turns_on_level + 101) % t == 0 then
      for i = 1, 4 do
        if not finished[i] and not Level.get_being(pos[i]) then
          local being = Level.drop_being(b, pos[i])
          if being then
            spawned = spawned + 1
            being.flags[BF_HUNTING] = true
            being.flags[BF_NOEXP] = true
            LurkAI.unlurk(being)
            being:play_sound("soldier.phase")
            Level.explosion(being:get_position(), 2, 50, 0, 0, LIGHTBLUE)
            local spawn_amt = math.max(3, math.random(DIFFICULTY))
            if DIFFICULTY <= 3 then
              spawn_amt = 0
            end
            for _ = 1, spawn_amt do
              local imp = being:spawn("imp")
              if imp then
                imp.flags[BF_HUNTING] = true
              end
            end
          end
        end
      end
    end
  end,
  
  OnExit = function()
    local result = Level.result()
    if result == 6 then
      player:add_history("He closed all the portals!")
      ui.msg("You fear no army of hellspawn.")
      player.completed_levels["SINGULARITY"] = true
      if spawned <= 2 then
        player:add_medal("inferno_sing1")
      end
    else
      player:add_history("He escaped before hell's forces grew too numerous.")
      ui.msg("You can't handle the pressure.")
    end
  end,
  
  OnKillAll = function()
    local result = Level.result()
    if result >= 5 then
      ui.msg("That's the last of them!")
    else
      ui.msg("Some of the portals are still active!")
    end
  end,
  
  OnEnter = function()
    ui.msg("You can hear portals powering up nearby. You'd better shut them off quickly!")
    for _, c in ipairs(pos) do
      Level.light[c][LFEXPLORED] = true
    end
    Level.result(1)
    if inferno.test then
      player.eq.weapon = item.new("chaingun")
      player.inv:add(item.new("ammo"))
      player.inv:add(item.new("ammo"))
      player.inv:add(item.new("ammo"))
      player.inv:add(item.new("ammo"))
      player.inv:add(item.new("smed"))
      player.inv:add(item.new("smed"))
      player.toHit = 2
      player.toDamAll = 3
    end
  end,
  
  IsCompleted = function()
    return Level.result() == 6
  end,
})