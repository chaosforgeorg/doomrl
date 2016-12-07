Levels("basement_unholy", {
  name = "Unholy Altar",
  entry = "On level @1 he raided the Unholy Altar!",
  hint = "There is a faint hint of something sinister here.",
  welcome = "You enter the Unholy Altar. Could it be...?",
  mortem_location = "at the Unholy Altar",
  type = "basement",

  range = {10, 18},
  
  canGenerate = function()
    return player.completed_levels["BLOOD"]
  end,

  Create = function()
    Level.fill("rwall")
    local translation = {
      ["#"] = {"rwall", flags = {LFPERMANENT}},
      ["X"] = "rwall",
      [">"] = "unbstairs",
      [","] = "blood",
      ["."] = "floor",
      ["A"] = {"floor", being = "angel"},
      ["c"] = {"floor", being = "ndemon"},
      ["-"] = "bridge",
      ["="] = "lava",
      ["+"] = "door",
    }
    local map = [[
################################
################################
################################
######################=#########
######################=#########
#####################==#########
#####################==XXXXXXX##
####################==XXc...cXX#
###################.==X..cXc..X#
##################,,--+,,,,,A.X#
##################>,--+,,,,,..X#
###################.==X..cXc..X#
####################==XXc...cXX#
#####################==XXXXXXX##
#####################==#########
######################=#########
######################=#########
################################
################################
################################
    ]]
    Level.place_tile(translation, map, 14, 1)
    Level.player(32, 10)  
    Level.result(0)
  end,
  
  OnTick = function()
    local c1 = coord.new(36, 10)
    local c2 = coord.new(36, 11)
    if Level[c1] == "odoor" or Level[c2] == "odoor" then
      Level[c1] = "blood"
      Level[c2] = "blood"
    end
  end,
  
  OnKillAll = function()
    if Level.result() == 0 then
      ui.msg("The angel of death has fallen yet again.")
      Level.drop("spear")
      Level.result(1)
    end
  end,
  
  OnExit = function()
    local result = Level.result()
    if result == 0 then
      ui.msg("One should not tempt fate a second time.")
    else
      ui.msg("The holy relic has been retrieved again!")
    end
  end,
  
  OnFire = levels.BLOOD.OnFire,

  IsCompleted = function()
    return Level.result() == 1
  end,
  
})