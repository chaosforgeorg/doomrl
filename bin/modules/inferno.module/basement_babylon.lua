Levels("basement_babylon", {
  name = "Echoes of Babylon",
  entry = "On level @1 he raided the Echoes of Babylon!",
  hint = "Ashes of a scattered memory hang in the air.",
  welcome = "You enter the Echoes of Babylon. You hear familiar footsteps...",
  mortem_location = "at the Echoes of Babylon",
  type = "basement",
  
  range = {10, 15},
  
  canGenerate = function()
    return true
  end,

  Create = function()
    Level.fill("dwall")
    local translation = {
      ["#"] = {"dwall", flags = {LFPERMANENT}},
      ["X"] = "gwall",
      [">"] = "unbstairs",
      [","] = "blood",
      ["."] = "floor",
      ["C"] = {"floor", being = "cyberdemon"},
    }
    local map = [[
########################
##....................##
##.XX..XX..XX..XX..XX.##
#..XX..XX..XX..XX..XX..#
#......................#
#>.....................#
#......................#
#..XX..XX..XX..XX..XX..#
##.XX..XX..XX..XX..XX.##
##....................##
########################
    ]]
    Level.place_tile(translation, map, 26, 5)
    Level.player(27, 10)
    Level.result(0)
    local cybie = Level.drop_being("cyberdemon", coord.new(48, 10))
    cybie.inv:add(inferno.roll_rare(ITEMTYPE_ARMOR, 25))
    cybie.inv:add(inferno.roll_rare(ITEMTYPE_RANGED, 25))
    cybie.flags[BF_HUNTING] = true
  end,
  
})