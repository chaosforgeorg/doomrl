local completed

Levels("basement_throne", {
  name = "Throne of Anubis",
  entry = "On level @1 he raided the Throne of Anubis!",
  hint = "Your heart is heavy.",
  welcome = "You enter the Throne of Anubis. This place is still.",
  mortem_location = "at the Throne of Anubis",
  type = "basement",
  
  range = {23, 24},
  
  canGenerate = function()
    return true
  end,

  Create = function()
    Level.fill("rwall")
    local translation = {
      ["#"] = {"rwall", flags = {LFPERMANENT}},
      ["W"] = "brwall",
      [">"] = "unbstairs",
      [","] = "blood",
      ["."] = "floor",
      ["o"] = "bloodpool",
      ["%"] = "corpse",
      ["A"] = {"blood", being = "arachno"},
      ["V"] = {"blood", being = "arch"},
      ["&"] = "floor",
    }
    local map = [[
#######################
######AAAVAAAVAAA######
#####AA#########AA#####
#####V##%.....%##V#####
#####A#....W....#A#####
#####A#.,Wo&oW,.#A#####
#####A#....,....#A#####
#####V##%..,..%##V#####
#####AA####,####AA#####
######AAA#.,.#AAA######
##########.,.##########
##########.>.##########
#######################
#######################
#######################
    ]]
    Level.place_tile(translation, map, 27, 5)
    Level.player(38, 16)
    local throne = item.new("stubitem")
    throne.picture = string.byte("&")
    throne.color = LIGHTRED
    throne.name = "throne"
    Level.drop_item(throne, coord.new(38, 10))
    Level.result(0)
    completed = false
  end,
  
  OnTick = function()
    local result = Level.result()
    if result == 0 and player.x == 38 and player.y == 10 then
      Level[coord.new(43, 10)] = "bloodpool"
      Level[coord.new(33, 10)] = "bloodpool"
      Level[coord.new(38, 7)] = "bloodpool"
      Level[coord.new(40, 14)] = "bloodpool"
      Level[coord.new(36, 14)] = "bloodpool"
      ui.blink(LIGHTBLUE,100)
      player.hp = math.max(5 * player.hpmax, player.hp)
      if player.eq.armor then
        player.eq.armor:fix(500)
      end
      player.tired = false
      ui.msg("\"Prepare to be judged!\"")
      Level.result(1)
    end
  end,
  
  OnKillAll = function()
    if not completed then
      ui.msg("\"Interesting. We may meet again.\"")
      Level[coord.new(38, 17)] = "floor"
      Level[coord.new(37, 18)] = "floor"
      Level.drop_item("lmed", coord.new(37, 18))
      Level[coord.new(38, 18)] = "floor"
      Level.drop_item("scglobe", coord.new(38, 18))
      Level[coord.new(39, 18)] = "floor"
      Level.drop_item("lmed", coord.new(39, 18))
      Level[coord.new(40, 18)] = "floor"
      Level.drop_item(inferno.roll_unique(ITEMTYPE_RANGED, 25), coord.new(40, 18))
      Level[coord.new(36, 18)] = "floor"
      Level.drop_item(inferno.roll_unique(ITEMTYPE_ARMOR, 25), coord.new(36, 18))
      player.hpmax = player.hpmax + 5
      player.hp = player.hp + 5
      completed = true
    end
  end,
  
  OnEnter = function()
    player.flags[BF_DARKNESS] = true
  end,
  
  OnExit = function()
    player.flags[BF_DARKNESS] = false
  end,
  
  IsCompleted = function()
    return completed
  end,
  
})