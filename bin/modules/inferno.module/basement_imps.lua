Levels("basement_imps", {
  name = "Hellfire Furnace",
  entry = "On level @1 he raided the Hellfire Furnace!",
  hint = "This place is unnaturally warm.",
  welcome = "You enter the Hellfire Furnace. The heat here seems to pierce your defenses!",
  mortem_location = "in the Hellfire Furnace",
  type = "basement",

  range = {6, 10},
  
  canGenerate = function()
    return true
  end,

  Create = function()
    Level.fill("wall")
    local translation = {
      ["#"] = {"wall", flags = {LFPERMANENT}},
      [">"] = {"unbstairs", flags = {LFNOSPAWN}},
      ["."] = "floor",
      ["i"] = {"blood", being = "imp"},
      ["-"] = "windowh",
      ["="] = "lava",
      ["0"] = "barrel",
    }
    local map = [[
#####=====#####
#####=====0####
#####=====0####
#####=====0####
#####=====#####
######---######
#.i.i.i.i.i.i.#
#i#.#.#.#.#.#i#
#.............#
#i#....>....#i#
#.............#
#i#.#.#.#.#.#i#
#.i.i.i.i.i.i.#
######---######
#####=====#####
#####=====#####
####0=====0####
####0=====0####
#####=====#####
#####=====#####
    ]]
    Level.place_tile(translation, map, 32, 1)
    Level.player(39, 10)
    Level.result(0)
  end,
  OnEnter = function()
    player.res_fire = player.res_fire - 40 - (5 * DIFFICULTY)
  end,
  OnExit = function()
    player.res_fire = player.res_fire + 40 + (5 * DIFFICULTY)
  end,
  OnKillAll = function()
    if Level.result() == 0 then
      for _ = 1, 3 do Level.drop(Level.roll_item_type({ITEMTYPE_RANGED}, 15)) end
      for _ = 1, 3 do Level.drop(Level.roll_item_type({ITEMTYPE_ARMOR}, 15)) end
      Level.drop(Level.roll_item_type({ITEMTYPE_BOOTS}, 15))
      Level.drop("knife")
      Level.result(1)
    end
  end,
  IsCompleted = function()
    return Level.result() == 1
  end,
})