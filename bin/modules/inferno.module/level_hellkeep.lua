items.shotgun.OnFirstPickup = function(self, being)
  if not being:is_player() then
    return
  end
  if Level.id == "HELLKEEP" then
    local old_juggler = being.flags[BF_QUICKSWAP]
    being.flags[BF_QUICKSWAP] = true
    ui.msg(items.shotgun.firstmsg)
    being:quick_weapon("shotgun")
    being.flags[BF_QUICKSWAP] = old_juggler
  end
end

Medal({
  id = "inferno_hellkeep1",
  name = "Siege Token",
  desc = "Cleared the Hell Keep on UV",
  hidden = true,
})

local transmute1, transmute2, the_lever, hint

Levels("HELLKEEP",{

  name = "Hell Keep",
  
  entry = "He began his journey by storming Hell Keep...",
  
  welcome = "You feel a sense of foreboding.",
  
  mortem_location = "in the Hell Keep",
  
  type = "special",
  
  Create = function()
    Level.fill("floorb")
    Generator.restore_walls("rwall")
    local translation = {
      ["."] = "floorb",
      [","] = "floorb",
      ["o"] = "bloodpool",
      ["X"] = {"rwall", flags = {LFPERMANENT}},
      ["="] = "lava",
      ["b"] = "trap_lava_bridge",
      [">"] = "stairs",
      ["+"] = "doorb",
      ["/"] = {"floorb", item = "ammo"},
      ["|"] = {"floorb", item = "shell"},
      ["a"] = {"floorb", item = "garmor"},
      ["e"] = {"floorb", item = "epack"},
      ["^"] = {"floorb", item = "lhglobe"},
      ["{"] = {"floorb", item = "shotgun"},
      ["0"] = {"floorb", being = "imp"},
      ["1"] = {"floorb", being = diffchoice(
        nil, nil, "imp", "imp", "imp")},
      ["2"] = {"floorb", being = diffchoice(
        nil, nil, nil, "imp", "imp")},
      ["3"] = {"floorb", being = "cacodemon"},
      ["4"] = {"floorb", being = diffchoice(
        nil, nil, nil, "cacodemon", "cacodemon")},
      ["5"] = {"floorb", being = "demon"},
      ["6"] = {"floorb", being = diffchoice(
        nil, nil, "demon", "demon", "demon")},
      ["7"] = {"floorb", being = diffchoice(
        nil, nil, nil, "demon", "demon")},
    }
    if DIFFICULTY ~= 3 then
      translation["3"].being = nil
    end
    --diffchoice(a,b,c,d,e)
    local map = [[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX,,,,,,,,,,XXXXXXXXXXXXX
XX.......XX...212020...X...........XXXXXXXXXXXXXXXXXX,,,,,,,,,,,,,,,,,XXXXXX
X....>....+..2.........+....XaX....XXXX=====XXXXXXXXX/,,,,,,,,XX,,,,,,,,,XXX
XX.......XXo..102120...X...........XX=========XXXXXXX/,,,,,,,,,,,,,1,,,,,,XX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX+X===========XXXXXX,,,,,,,,,,,,,,,,,,,,,,X
XXXXXXXXXXXXXX...6.5..6...7..7.....X===========XXXXXX|,,,XX,,,,,,,,,,,,,,,,,
XXXXXXXXXXXXXX+XXXXXXXXXXXXXXXXXXXXX===========XXXXXX|,,,,,,,,,,,,,XXXXX,,,,
XXXXXXXXXXX........................X.==========.....X,,,,,,,,,,,,,,X,,,X,,,,
XXXXXX,,,,,...................1....X{bbbbbbbbbb...4.+,,,,,,,,,,0,,,X,,,X,,,,
XXX......0.........................X.==========.....X,,,,,,,,,,,,,,X,,,X,,,,
XX....1....X....0..................X===========XXXXXX|,,,,,,,,,,,,,XXXXX,,,,
XX.2.....XXXXX.......XXX...0..XX.2.X===========XXXXXX|,,,,,XX,,,,,,,,,,,,,,,
XXX....1...XX.......XXXXX.....X....X===========XXXXXX,,,,,,,,,,,,,,,,,,,,,,,
XXXXX..........0.......X..0...1...XXX=========XXXXXXX/,,,,,,,,,,XXX,2,,,,,,,
XXXXXX...2.........1.............XXXXXX=====XXXXXXXXX/,,,,,,,,,,,,,,,,,,,,,X
XXXXXXX......2..XXX....2...4...XXXXXXXXXXXXXXXXXXXXXX,,,,X,,,,,,,,,,,,,,,XXX
XXXXXXXX.3...XXXXXXXXXXX.....XXXXXXXXXXXXXXXXXXXXXXXX,,,,,,,,,,,,,,,,XXXXXXX
XXXXXXXXXX.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX,,,,,,,,,,,,XXXXXXXXXXX
    ]]
    Level.place_tile(translation, map, 2, 2)
    Level.player(71, 10)
    the_lever = item.new("lever_walls")
    the_lever.color = RED
    the_lever.target_area = area.new(69, 8, 73, 12)
    Level.drop_item(the_lever, coord.new(70, 10))
    hint = false
  end,
  
  OnTick = function()
    if not hint and player.turns_on_level >= 110 and the_lever.__ptr then
      ui.msg("You have a sudden urge to @<u@>se the lever.")
      hint = true
    end
    if transmute1 and transmute2 then
      return
    end
    if not transmute1 and player.x == 38 and player.y <= 11 and player.y >= 9 then
      Level[coord.new(37, 10)] = "floorb"
      transmute1 = true
    end
    --[[
    if not transmute2 and player.x == 51 and player.y >= 13 then
      Level[coord.new(51, 12)] = "floor"
      transmute2 = true
    end
    ]]
  end,
  
  OnEnter = function()
    -- TODO: TEMP
    inferno.FirstLevelLoadPlayer()
    Level.result(1)
    if inferno.cheat then
      Level.drop_item("lever_phase", player:get_position())
    end
  end,
  
  OnKillAll = function()
    Level.result(2)
  end,
  
  OnExit = function()
    if Level.result() == 2 then
      player:add_history("He left no survivors!")
      if DIFFICULTY >= 4 then
        player:add_medal("inferno_hellkeep1")
      end
    end
  end,
})