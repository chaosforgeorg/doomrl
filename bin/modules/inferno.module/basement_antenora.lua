local phase1, phase2, phase3

local cleared

Levels("basement_antenora", {
  name = "Antenora",
  entry = "On level @1 he raided Antenora!",
  hint = "You shed a tear for your fellow soldiers lost in hell's invasion.",
  welcome = "You enter Antenora. You hear the unnatural shuffling sound of former soldiers.",
  mortem_location = "in Antenora",
  type = "basement",

  range = {8, 12},
  
  canGenerate = function(dlevel)
    return true
  end,

  Create = function()
    Level.fill("dwall")
    local translation = {
      ["#"] = {"dwall", flags = {LFPERMANENT}},
      ["+"] = {"ldoor", flags = {LFPERMANENT}},
      ["X"] = {"gwall", flags = {LFPERMANENT}},
      [">"] = "unbstairs",
      ["."] = "floor",
      ["h"] = {"floor", being = "former"},
      ["g"] = {"floor", being = "sergeant"},
      ["n"] = {"floor", being = "captain"},
      ["o"] = {"floor", being = "commando"},
    }
    local map = [[
#####################
####hhnhh###hhnhh####
##o+ggngg+o+ggngg+o##
##+#+#+#+#+#+#+#+#+##
#ng+.............+gn#
#ng#......>......#gn#
#ng+.............+gn#
##+#+#+#+#+#+#+#+#+##
##o+ggngg+o+ggngg+o##
####hhnhh###hhnhh####
#####################
    ]]
    Level.place_tile(translation, map, 28, 5)
    Level.player(38, 10)
    Level.result(0)
    cleared = false
    phase1 = {
      coord.new(32, 8),
      coord.new(34, 8),
      coord.new(36, 8),
      coord.new(40, 8),
      coord.new(42, 8),
      coord.new(44, 8),
      coord.new(32, 12),
      coord.new(34, 12),
      coord.new(36, 12),
      coord.new(40, 12),
      coord.new(42, 12),
      coord.new(44, 12),
    }
    phase2 = {
      coord.new(31, 9),
      coord.new(31, 11),
      coord.new(45, 9),
      coord.new(45, 11),
    }
    phase3 = {
      coord.new(38, 8),
      coord.new(38, 12),
      coord.new(30, 8),
      coord.new(46, 8),
      coord.new(30, 12),
      coord.new(46, 12),
      coord.new(31, 7),
      coord.new(45, 7),
      coord.new(31, 13),
      coord.new(45, 13),
      coord.new(37, 7),
      coord.new(39, 7),
      coord.new(37, 13),
      coord.new(39, 13),
    }
  end,
  OnEnter = function()
    for b in Level.beings() do
      if b ~= player then
        b.flags[BF_HUNTING] = true
      end
    end
  end,
  OnKillAll = function()
    if not cleared then
      local c1 = coord.new(38, 6)
      local c2 = coord.new(38, 14)
      Level[c1] = "blood"
      Level[c2] = "blood"
      Level.drop_item(inferno.roll_rare(ITEMTYPE_RANGED, 15), c1)
      Level.drop_item(Level.roll_item_type({ITEMTYPE_PACK}, 15), c2)
      cleared = true
    end
  end,
  OnTick = function()
    local result = Level.result()
    if result == 0 and player.turns_on_level >= 55 then
      for _, c in ipairs(phase1) do
        Level[c] = "odoor"
      end
      player:play_sound("door.open")
      Level.result(1)
    elseif result == 1 and player.turns_on_level >= 265 then
      for _, c in ipairs(phase2) do
        Level[c] = "odoor"
      end
      player:play_sound("door.open")
      Level.result(2)
    elseif result == 2 and player.turns_on_level >= 370 then
      for _, c in ipairs(phase3) do
        Level[c] = "odoor"
      end
      player:play_sound("door.open")
      Level.result(3)
    end
  end,
  IsCompleted = function()
    return cleared
  end,
})