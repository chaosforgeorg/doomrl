Levels("basement_volcano", {
  name = "Masaya's Demesne",
  entry = "On level @1 he raided Masaya's Demesne!",
  hint = "The ground here is rumbling.",
  welcome = "You enter Masaya's Demesne. You have a bad feeling about that lever.",
  mortem_location = "in Masaya's Demesne",
  type = "basement",

  range = {20, 24},
  
  canGenerate = function()
    return true
  end,

  Create = function()
    Level.fill("rwall")
    local translation = {
      ["#"] = {"rwall", flags = {LFPERMANENT}},
      [">"] = "unbstairs",
      ["X"] = "rwall",
      ["."] = "floor",
      [","] = "blood",
      ["&"] = {"blood", item = {"lever_flood_lava", target_area = area.FULL}},
    }
    local map = [[
#####################
##.................##
#...X...X.,.X...X...#
#........,,,........#
#>,.,.,.,,&,,.......#
#........,,,........#
#...X...X.,.X...X...#
##.................##
#####################
    ]]
    Level.place_tile(translation, map, 28, 6)
    Level.player(29, 10)
    Level.result(0)
  end,
  OnUse = function(item, being)
    if item.id == "lever_flood_lava" then
      Level.summon("lava_elemental", 3)
      Level.result(1)
    end
  end,
  OnKillAll = function()
    if Level.result() == 1 then
      Level.result(2)
      Level.drop_item("lava_element", coord.new(38, 10))
    end
  end,
  IsCompleted = function()
    return Level.result() == 2
  end,
})