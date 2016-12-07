local phase1, phase2, phase3

local completed

Levels("basement_hanged", {
  name = "The Hanged Man",
  entry = "On level @1 he raided The Hanged Man!",
  hint = "You suppress an urge to surrender.",
  welcome = "You enter The Hanged Man. Is defeat a certainty?",
  mortem_location = "at The Hanged Man",
  type = "basement",

  range = {20, 24},
  
  canGenerate = function()
    return true
  end,

  Create = function()
    Level.fill("wall")
    local translation = {
      ["#"] = {"wall", flags = {LFPERMANENT}},
      [">"] = {"unbstairs", flags = {LFNOSPAWN}},
      ["="] = "lava",
      ["."] = "floor",
      ["M"] = {"floor", being = "mancubus"},
      ["C"] = {"lava", being = "cacodemon"},
      ["c"] = {"floor", being = "demon"},
      ["V"] = {"floor", being = "arch"},
    }
    local map = [[
#######################
#####cccc######VV######
#######################
#C#==....#===#....==#C#
###==.........M...==###
#C#==..........M..==#C#
###==.>........M..==###
#C#==..........M..==#C#
###==.........M...==###
#C#==....#===#....==#C#
#######################
#####cccc######VV######
#######################
    ]]
    Level.place_tile(translation, map, 27, 4)
    Level.player(34, 10)
    Level.result(0)
    phase1 = {
      area.new(32, 6, 35, 6),
      area.new(32, 14, 35, 14),
    }
    phase2 = {
      area.new(28, 7, 29, 13),
      area.new(47, 7, 48, 13),
    }
    phase3 = {
      area.new(42, 6, 43, 6),
      area.new(42, 14, 43, 14),
    }
  end,
  OnEnter = function()
    for b in Level.beings() do
      if b ~= player then
        b.flags[BF_HUNTING] = true
      end
    end
  end,
  OnTick = function()
    local result = Level.result()
    if result == 0 and player.turns_on_level >= 120 then
      for _, a in ipairs(phase1) do
        for c in a:coords() do
          Level[c] = "floor"
        end
      end
      player:play_sound("door.open")
      Level.result(1)
    elseif result == 1 and player.turns_on_level >= 235 then
      for _, a in ipairs(phase2) do
        for c in a:coords() do
          Level[c] = "lava"
        end
      end
      player:play_sound("door.open")
      Level.result(2)
    elseif result == 2 and player.turns_on_level >= 345 then
      for _, a in ipairs(phase3) do
        for c in a:coords() do
          Level[c] = "floor"
        end
      end
      player:play_sound("door.open")
      Level.result(3)
    end
  end,
  OnKillAll = function()
    if not completed then
      for _ = 1, 4 do Level.drop(Level.roll_item_type({ITEMTYPE_PACK}, 25, 2)) end
      for _ = 1, 8 do Level.drop(Level.roll_item_type({ITEMTYPE_ARMOR, ITEMTYPE_BOOTS}, 25, 4)) end
      for _ = 1, 8 do Level.drop(Level.roll_item_type({ITEMTYPE_RANGED}, 25, 4)) end
      Level.drop("pammo", 2)
      Level.drop("pshell", 2)
      Level.drop("pcell", 2)
      Level.drop("procket", 2)
      Level.drop("mod_power")
      Level.drop("mod_bulk")
      Level.drop("mod_tech")
      Level.drop("mod_agility")
      Level.drop(inferno.roll_rare(ITEMTYPE_RANGED, 25))
      Level.drop(inferno.roll_rare(ITEMTYPE_ARMOR, 25))
      completed = true
    end
  end,
  IsCompleted = function()
    return completed
  end,
})