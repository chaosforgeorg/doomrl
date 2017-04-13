Medal({
  id = "inferno_blood1",
  name = "Bloody Medal",
  desc = "Cleared the Blood Temple on UV",
  hidden = true,
})

Medal({
  id = "inferno_blood2",
  name = "Brutal Cross",
  desc = "Cleared the Blood Temple with fists",
  hidden = true,
})

local first_kills
local first_fist_kills

Levels("BLOOD", {

  name = "The Blood Temple",
  
  entry = "On level @1 he encountered the Blood Temple...",
  
  welcome = "You enter the Blood Temple.",
  
  mortem_location = "in the Blood Temple",
  
  type = "special",
  
  style = inferno.styles.hell_style,
  
  Create = function()
    Level.fill("wall")
    local translation = {
      ["."] = "floorb",
      ["*"] = "floorb",
      [","] = "blood",
      ["o"] = "bloodpool",
      ["X"] = {"rwall", flags = {LFPERMANENT}},
      [">"] = "stairs",
      ["+"] = "doorb",
      ["%"] = "corpse",
      ["/"] = {"bloodpool", item = "chainsaw"},
    }
    --diffchoice(a,b,c,d,e)
    local map = [[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX...........XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX......,,,......XXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX......,,...,,.....XXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXX...XXXXX......,,.,,.,,.,,......XXXXX...XXXXXXXXXXXXXXXX
XX.X.X.X.XXXXX....XX.....XXX......,..,.,,,.,..,......XXX.....XX....XXXX,,,XX
X,,,,,,,,,X,,,,,,,,,,,,,,,,X.....,...,,...,,...,.....X,,,,,,,,,,,,,,,X,,o,,X
X>,,,,,,,,+,,,,,,,,,,,,,,,,+.....,..,,..%..,,..,.....+,,,,,,,,,,,,,,,+,o/o,X
X,,,,,,,,,X,,,,,,,,,,,,,,,,X.....,.,..,...,..,.,.....X,,,,,,,,,,,,,,,X,,o,,X
XX.X.X.X.XXXXX....XX.....XXX......,,,,,,,,,,,,,......XXX.....XX....XXXX,,,XX
XXXXXXXXXXXXXXXXXXXXX...XXXXXX.....,...,.,...,.....XXXXXX...XXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX....,,..,..,,....XXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX....,,,,,....XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.........XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    ]]
    Level.place_tile(translation, map, 2, 2)
    Level.player(5, 10)
  end,
  
  OnEnter = function()
    Level.result(1)
    first_kills = player.kills
    first_fist_kills = kills.get_type(0)
    if player.eq.weapon and player.eq.weapon.itype == ITEMTYPE_RANGED then
      ui.msg("You sense you are unwanted here. Your " .. player.eq.weapon.name .. " feels strange.")
    else
      ui.msg("Your hands tingle in anticipation.")
    end
  end,
  
  OnPickup = function(it, b)
    if Level.result() >= 2 then
      return
    end
    if b == player and it.id == "chainsaw" then
      local center = coord.new(42, 10)
      local a = area.around(center, 5)
      if DIFFICULTY >= 4 then
        Level.drop_being("arch", center)
        Level.area_summon(a, "baron", 3)
      end
      Level.area_summon(a, "demon", 12)
      if DIFFICULTY >= 3 then
        Level.area_summon(a, "baron", 3)
        Level.area_summon(a, "demon", 12)
      end
      Level.result(2)
    end
  end,
  
  OnExit = function()
    if Level.result() == 3 then
      player:add_history("He slaughtered the worshippers!")
      ui.msg("Their blood stains your hands.")
      player.completed_levels["BLOOD"] = true
      if DIFFICULTY >= 4 then
        player:add_medal("inferno_blood1")
      end
      if player.kills - first_kills == kills.get_type(0) - first_fist_kills then
        player:add_medal("inferno_blood2")
      end
    else
      player:add_history("He left the place undisturbed.")
      ui.msg("You feel wise to leave this place.")
    end
  end,
  
  OnFire = function(item,being)
    if being:is_player() and item.itype == ITEMTYPE_RANGED then
      ui.msg("You pull the trigger... nothing happens!")
      return false
    end
    return true
  end,
  
  OnKillAll = function()
    Level.result(3)
    ui.msg("So much blood...")
  end,
  
  IsCompleted = function()
    return Level.result() == 3
  end,
  
})