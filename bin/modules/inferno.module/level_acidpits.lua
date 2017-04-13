Items({
  id = "acidpits_lever",
  name = "lever",
  color = WHITE,
  color_id = "lever",
  sprite = SPRITE_LEVER,
  weight = 0,
  type = ITEMTYPE_LEVER,
  good = "beneficial",
  desc = "raises a bridge",
  OnUse = function(self, being)
    for c in area.new(35, 10, 38, 11)() do
      local tile = cells[Level[c]]
      if tile.id == "acid" then
        Level[c] = "bridge"
      end
    end
    Level.clear_item(self:get_position())
    being:msg("You hear something moving.")
    being:play_sound("dsstnmov5")
    return true
  end,
})

Items({
  name = "Aegis",
  id = "uaegis",
  ascii = "?",
  color = YELLOW,
  sprite = SPRITE_STAFF,
  level = 200,
  weight = 0,
  type = ITEMTYPE_PACK,
  desc = "You sense a protective aura.",
  flags = {IF_UNIQUE},
  OnUse = function(self, being)
    if not being:is_player() then
      return false
    end
    if being.tired then
      ui.msg("You're too tired to use it now.")
      return false
    end
    being.tired = true
    being:set_affect("enviro", 30)
    being.scount = being.scount - 1000
    return false
  end
})

Medal({
  id = "inferno_hydra1",
  name = "Hydra's Head",
  desc = "Completed the Acid Pits without damage",
  hidden = true,
})

Medal({
  id = "inferno_hydra2",
  name = "Hydra's Heart",
  desc = "Defeated the Hydra Queen using pistols",
  hidden = true,
})

Levels("ACIDPITS",{

  name = "The Spawning Pits",
  
  entry = "On level @1 he entered The Spawning Pits...",
  
  welcome = "You enter The Spawning Pits. The acrid scent of acid hangs in the air.",
  
  find_phrase = "There he discovered the @1.",
  
  mortem_location = "in The Spawning Pits",
  
  type = "special",
  
  style = inferno.styles.cave_style,
  
  Create = function()
    Level.fill("cwall")
    local translation = {
      ["."] = "floorc",
      [","] = "floor",
      ["o"] = "bloodpool",
      ["X"] = {"cwall", flags = {LFPERMANENT}},
      ["#"] = "wall",
      ["P"] = {"wall", flags = {LFPERMANENT}},
      ["="] = "acid",
      [">"] = "stairs",
      ["+"] = "door",
      ["&"] = {"floor", item = "acidpits_lever"},
      ["{"] = {"floor", item = "ashotgun"},
      ["|"] = {"floor", item = "shell"},
      ["r"] = {"blood", item = "rocket"},
      ["Q"] = {"acid", being = "hydraq"},
      ["1"] = {"acid", being = "hydra"},
      ["q"] = {"floorc", being = "hydra"},
      ["c"] = {"acid"},
      ["C"] = {"acid"},
      ["2"] = {"acid"},
      ["e"] = {"floorc"},
      ["f"] = {"floor", being = "former"},
      ["g"] = {"floor", being = "sergeant"},
    }
    if DIFFICULTY >= 3 then
      translation["c"].being = "cacodemon"
      translation["2"].being = "hydra"
      translation["f"].being = "sergeant"
      translation["g"].being = "captain"
    end
    if DIFFICULTY >= 4 then
      translation["C"].being = "cacodemon"
      translation["e"].being = "hydra"
      translation["g"].being = "commando"
    end
    local map = [[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX====XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXr.====XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.====XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.====XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXX=XXXXXXXXXXXXXXXXXXXXXXXXPPP##====XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XX==XXXXXXXXXXXXX==XXXXXXX=XPo,&#====XXXXXXX==XXXXXXXXXXXXXXXXXX=1=XXXXXXXXXXX
XX.......XXXXXXX==1=XXXXX==XP|g|#X=c==XXXXX=C=XXXXXXXXXXX=X.e.........XXXXXXXX
X=.##+##....XXX.....eXXX=2=XPf,f#===2..q.XX==XXXXXXXXXXXX.....======X.....####
X..#|,|#........X..........XP#+##====....e......1=...XX.......=2========..#,,#
X..+,{,+...XXXXXXX==XXXX..........====...............2..XX.e...X===Q====..+,>#
X..#|,|#.......XX=2XX.....XX......====...q.XX.....................=====...#,,#
X..##+##.XXX..........XX.....XXXX==2=...e..........e=XX.......e..====XX...####
XX...........XXX...XXXXXe..XXXXXX====.q..XXXXX=1=XXXXXXXX==1=XXX........XXXXXX
XXX...X==X=1=XXXX=1XXXXXXXXXXXXXX=c==..XXXXXX=C=XXXXXXXXXX=C=XXXXXX===XXXXXXXX
XXXX==XXXXXX=XXXXXXXXXXXXXXXXXXX====XXXXXXXXXXXXXXXXXXXXX===XXXXXXXXXXXXXXXXXX
XXXXX=XXXXXXXXXXXXXXXXXXXXXXXr.====XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.====XrXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX====.rXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX====XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX====XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    ]]
    IGen.place_tile(translation, map, 1, 1)
    Level.player(6, 10)
  end,
  
  OnEnter = function()
    local replace = table.toset({"door", "stairs", "bloodpool"})
    for c in area.FULL:coords() do
      if replace[Level[c]] then
        local initial = Level[c]
        Level[c] = "floor"
        Level[c] = initial
      end
    end
    Level.result(1)
  end,
  
  OnTick = function()
    if Level.result() == 2 then
      return
    end
    for being in Level.beings() do
      if being.id == "hydraq" then
        return
      end
    end
    if inferno.Statistics.hydra_queen_pistol_check() then
      player:add_medal("inferno_hydra2")
    end
    Level.result(2)
    ui.msg("A strange object rises from the acid.")
    Level.drop_item("uaegis", coord.new(66, 11))
  end,
  
  OnKillAll = function()
    ui.msg("You take a wary look at the last corpse before deciding it is safe to proceed.")
  end,
  
  OnExit = function()
    if Level.result() == 2 then
      ui.msg("You sure as hell had better have killed them all.")
      player:add_history("He slew the hydra queen!")
      if statistics.damage_taken == player.damage_on_start then
        player:add_medal("inferno_hydra1")
      end
    else
      ui.msg("Why don't they ever stop!")
      player:add_history("He fled before the hydras overwhelmed him.")
    end
  end,
  
  IsCompleted = function()
    return Level.result() == 2
  end,
  
})