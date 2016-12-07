local completed

Levels("basement_halls", {
  name = "Fool's Tomb",
  entry = "On level @1 he raided the Fool's Tomb!",
  hint = "This way seems right.",
  welcome = "You enter Fool's Tomb. Perhaps you should turn back.",
  mortem_location = "in the Fool's Tomb",
  type = "basement",
  
  range = {6, 9},
  
  canGenerate = function()
    return true
  end,

  Create = function()
    Level.fill("wall")
    local translation = {
      ["#"] = {"wall", flags = {LFPERMANENT}},
      ["!"] = {"wall", flags = {LFPERMANENT}},
      [">"] = "unbstairs",
      ["."] = "floor",
      ["h"] = {"floor", being = "sergeant"},
      ["U"] = {"floor", being = "asura"},
      ["+"] = {"door", flags = {LFPERMANENT}},
      ["%"] = "corpse",
      [","] = "blood",
      ["o"] = "bloodpool",
    }
    local map = [[
##################
#######h#h#hhh####
#######!#!#!!!####
#>...,o%,.....+.U#
#######!#!#!!!####
#######h#h#hhh####
##################
    ]]
    Level.place_tile(translation, map, 30, 7)
    Level.player(31, 10)  
    Level.result(0)
    completed = false
  end,
  
  OnTick = function()
    if Level.result() == 0 and player.x >= 37 then
      Level[coord.new(37, 11)] = "floor"
      Level[coord.new(37, 9)] = "floor"
      Level.result(1)
    end
    if Level.result() == 1 and player.x >= 39 then
      Level[coord.new(39, 11)] = "floor"
      Level[coord.new(39, 9)] = "floor"
      Level.result(2)
    end
    if Level[coord.new(44, 10)] ~= "door" then
      Level[coord.new(41, 11)] = "floor"
      Level[coord.new(42, 11)] = "floor"
      Level[coord.new(43, 11)] = "floor"
      Level[coord.new(41, 9)] = "floor"
      Level[coord.new(42, 9)] = "floor"
      Level[coord.new(43, 9)] = "floor"
      Level[coord.new(44, 10)] = "floor"
      Level.result(3)
    end
  end,
  
  OnKillAll = function()
    if not completed then
      Level[coord.new(31, 9)] = "door"
      Level[coord.new(31, 8)] = "floor"
      Level[coord.new(32, 8)] = "floor"
      Level[coord.new(33, 8)] = "floor"
      Level[coord.new(34, 8)] = "floor"
      Level[coord.new(35, 8)] = "floor"
      Level.drop_item(inferno.roll_rare(ITEMTYPE_ARMOR, 9), coord.new(34, 8))
      Level.drop_item(inferno.roll_rare(ITEMTYPE_RANGED, 9), coord.new(35, 8))
      completed = true
    end
  end,
  
  OnExit = function()
    
  end,
  
  IsCompleted = function()
    return completed
  end,
})