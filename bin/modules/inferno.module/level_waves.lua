local time_on_release
local bfg_pickup

Medal({
  id = "medal_waves2",
  name = "Betrayal Token",
  desc = "Cleared Ptolomea",
  hidden = true,
})

Medal({
  id = "medal_waves3",
  name = "Betrayal Token",
  desc = "Cleared Ptolomea on HMP",
  hidden = true,
})

Medal({
  id = "medal_waves4",
  name = "Betrayal Cross",
  desc = "Cleared Ptolomea on UV",
  hidden = true,
})

Medal({
  id = "medal_waves1",
  name = "Vindictive Cross",
  desc = "Cleared Ptolomea without wielding the BFG 9000",
  hidden = true,
})

Levels("WAVES",{

  name = "Ptolomea",
  
  entry = "On level @1 he anwsered the call of Ptolomea...",
  
  welcome = "You enter Ptolomea. Somehow you feel unwelcome.",
  
  mortem_location = "in Ptolomea",
  
  type = "special",
  
  style = inferno.styles.hell_style,
  
  Create = function()
    Level.fill("rwall")
    local translation = {
      ["."] = "floorb",
      [","] = "blood",
      ["o"] = "bloodpool",
      ["#"] = {"rwall", flags = {LFPERMANENT}},
      ["X"] = {"rwall", flags = {LFPERMANENT}},
      ["P"] = {"brwall", flags = {LFPERMANENT}},
      ["S"] = "secret_rwall",
      [">"] = "stairs",
      ["|"] = {"floorb", item = "cell"},
      ["{"] = {"floorb", item = "bfg9000"},
      ["["] = {"floorb", item = "rarmor"},
      [";"] = {"floorb", item = "psboots"},
      ["*"] = {"floorb", item = "scglobe"},
      ["+"] = {"floorb", item = "lmed"},
      ["A"] = {"blood", being = "arachno"},
      ["a"] = {"blood", being = "arachno"},
      ["B"] = {"blood", being = "baron"},
      ["R"] = {"blood", being = "revenant"},
      ["V"] = {"blood", being = "arch"},
      ["M"] = {"blood", being = "mancubus"},
      ["m"] = {"blood", being = "mancubus"},
      ["U"] = {"blood", being = "asura"},
    }
    if DIFFICULTY <= 3 then
      translation["U"].being = nil
      translation["V"].being = nil
      translation["m"].being = nil
    end
    if DIFFICULTY <= 2 then
      translation["R"].being = "knight"
      translation["a"].being = nil
    end
    local map = [[
XXXXXXXXXXXXXPPPXXXXXXXXPPPXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXPo,a...a...P,,,.......M.............#....V.XXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXP,...A...A.Po.....A.B.......B....V.M#...M..XXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXX,.a...a...P.............a.....A....#.B....XXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXX,...A...A.X*....R......R.....R.....#...m..XXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXPPPXXXXXXXXXXXXXXX##XXX###XXX##X.A..#.B....XXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXX..>..XXXXXXX.|||.|||.|||.X....#U....M.||XXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXX.....XXXXXXX.....+.+....[#...B#.......||XXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXX.............|||..{..|||*#.a..#...m...||XXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXX.....XXXXXXX.....+.+....;#...B#.......||XXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXX..>..XXXXXXX.|||.|||.|||.X....#U....M.||XXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX##XXX###XXX##X.A..#.B....XXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXX,...A,,,A.X*....R...B..R.....R.....#...M..XXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXPo,a...a...X.............a.,...A....#.B....XXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXX....A...A.P,.....A......,,o.B...V.M#...m..XXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXX..ao,,a...Po,........M.,,,,,o,,....#....V.XXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXPPXXXXXPPPXXXXXXXXXXXXPPPPPXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    ]]
    Level.place_tile(translation, map, 2, 2)
    Level.player(23, 10)
    -- Stop the player from phasing into monsters
    Level.light[LFNOSPAWN] = true
    for c in area.new(33, 8, 45, 12)() do
      Level.light[c][LFNOSPAWN] = false
    end
    Level.flags[LF_NOHOMING] = true
  end,
  
  OnTick = function()
    local res = Level.result()
    if player.eq.weapon and player.eq.weapon.id == "bfg9000" and res < 5 then
      bfg_pickup = true
    end
    if res == 1 and player.x >= 34 then
      Level[coord.new(32, 10)] = "invis_wallb"
      Level.result(2)
      return
    end
    if res == 2 and player.x <= 33 then
      --[[
      if player.x <= 32 then
        thing.displace(player, coord.new(33, 10))
      end
      ]]
      player:play_sound("dsdoropn")
      Level.light[LFNOSPAWN] = false
      Level.result(3)
      Level[coord.new(32, 10)] = "rwall"
      for x = 33, 34 do
        Level[coord.new(x, 13)] = "floorb"
        Level[coord.new(x, 7)] = "floorb"
      end
      for x = 38, 40 do
        Level[coord.new(x, 13)] = "floorb"
        Level[coord.new(x, 7)] = "floorb"
      end
      for x = 44, 45 do
        Level[coord.new(x, 13)] = "floorb"
        Level[coord.new(x, 7)] = "floorb"
      end
      Level[coord.new(46, 11)] = "floorb"
      Level[coord.new(46, 10)] = "floorb"
      Level[coord.new(46, 9)] = "floorb"
      Generator.set_permanence(area.FULL, false, "floorb")
      Generator.set_permanence(area.FULL, true, "rwall")
      time_on_release = core.game_time()
      return
    end
    if res == 3 and (core.game_time() - time_on_release) >= 300 then
      Level.result(4)
      Level.play_sound("dsdoropn", coord.new(26, 10))
      Level.play_sound("dsdoropn", coord.new(51, 10))
      for y = 3, 6 do
        Level[coord.new(26, y)] = "floorb"
      end
      for y = 14, 17 do
        Level[coord.new(26, y)] = "floorb"
      end
      for y = 3, 17 do
        Level[coord.new(51, y)] = "floorb"
      end
      Level.drop("cell", 36)
      Generator.set_permanence(area.FULL, false, "floorb")
    end
  end,
  
  OnExit = function()
    if Level.result() == 5 then
      player:add_history("He blasted the demons who were lying in wait!")
      ui.msg("Hospitality be damned!")
      player:add_medal("medal_waves2")
      if DIFFICULTY >= 3 then
        player:add_medal("medal_waves3")
      end
      if DIFFICULTY >= 4 then
        player:add_medal("medal_waves4")
      end
      if bfg_pickup == false then
        player:add_medal("medal_waves1")
      end
    else
      player:add_history("He chose not to trespass.")
      ui.msg("Perhaps it is better this way.")
    end
  end,
  
  OnKillAll = function()
    Level.result(5)
    Level[coord.new(32, 10)] = "floorb"
    Level.light[coord.new(32, 10)][LFPERMANENT] = false
    local a = area.new(21, 8, 25, 12)
    Level.area_drop(a, "cell", 12)
    ui.msg("Where are the rest of them? Surely that can't be all!")
  end,
  
  OnEnter = function()
    core.play_music("karma pending")
    Level.result(1)
    time_on_release = 0
    bfg_pickup = false
    if inferno.test then
      player.hpmax = 80
      player.hp = 80
      player.armor = 3
      player.bodybonus = 1
      player.inv:add(item.new("hphase"))
      player.inv:add(item.new("hphase"))
    end
  end,
  
  IsCompleted = function()
    return Level.result() == 5
  end,
})