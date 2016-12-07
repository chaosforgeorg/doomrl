local hellfire_picked_up
local kills_on_start

Items({
  name = "Hellfire Pack",
  id = "umod_hell",
  color = RED,
  level = 200,
  sprite = SPRITE_MOD,
  coscolor = {0.5, 0.0, 0.0, 1.0},
  weight = 0,
  type = ITEMTYPE_PACK,
  ascii = "\"",
  desc = "Imbues any equipment with great power.",
  OnPickup = function(self, being)
    hellfire_picked_up = true
  end,
  OnUse = function(self, being)
    if not being:is_player() then
      return
    end
    local item, result = being:pick_mod_item("H", being.techbonus)
    if not item then
      return result
    end
    if item.itype == ITEMTYPE_MELEE then
      item.damage_sides = item.damage_sides + 2
      item.damage_dice = item.damage_dice + 1
    elseif item.itype == ITEMTYPE_RANGED then
      if item.damage_dice + item.damage_sides > 0 then
        if item.damage_dice == 1 then
          item.damage_sides = item.damage_sides + 1
        else
          item.damage_dice = item.damage_dice + 1
        end
        item.damage_sides = item.damage_sides + 1
      end
      item.usetime = item.usetime * 0.85
    elseif item.itype == ITEMTYPE_BOOTS then
      item.armor = item.armor * 3
      item.movemod = item.movemod + 15
      item.knockmod = item.knockmod - 25
    elseif item.itype == ITEMTYPE_ARMOR then
      item.movemod = item.movemod + 10
      item.armor = item.armor + 3
      item.knockmod = item.knockmod - 10
    end
    item:add_mod("H")
    return true
  end,
})

Medal({
  id = "inferno_tech1",
  name = "Technomancer's Heart",
  desc = "Cleared the Technomanse without taking damage",
  hidden = true,
})

Medal({
  id = "inferno_tech2",
  name = "Technomancer's Wings",
  desc = "Escaped with the Hellfire Pack without kills",
  hidden = true,
})

Levels("TECH", {

  name = "The Technomanse",
  
  entry = "On level @1 he visited The Technomanse.",
  
  welcome = "You enter The Technomanse. What is the purpose of this place?",
  
  find_phrase = "There he stole @1.",
  
  mortem_location = "in The Technomanse",
  
  type = "special",
  
  Create = function()
  
    local translation = {
      ["X"] = {"rwall", flags = {LFPERMANENT}},
      [">"] = "stairs",
      ["="] = "lava",
      ["."] = "floor",
      ["+"] = "door",
      ["|"] = {"floor", item = "cell"},
      ["/"] = {"floor", item = "rocket"},
      ["u"] = {"floor"},
      ["U"] = {"floor", being = "asura"},
      ["m"] = {"floor"},
      ["n"] = {"floor"},
      ["M"] = {"floor", being = "mancubus"},
      ["1"] = {"floor", being = "arachno"},
      ["2"] = {"floor"},
      ["3"] = {"floor"},
      ["\""] = {"floor", item = "umod_hell"},
    }
    if DIFFICULTY >= 3 then
      translation["2"].being = "arachno"
      translation["m"].being = "mancubus"
    end
    if DIFFICULTY >= 4 then
      translation["3"].being = "arachno"
      translation["n"].being = "mancubus"
      translation["u"].being = "asura"
      translation["U"].being = nil
    end
    local map = [[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXX|///|XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXX+XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
X...............XXXXXXXXXXXXXXXXXXXXXXXX..........3.......3.......XXXXXXXXXXXX
X...............XX...XXX...XX...XXX...XX...1...2...1...2...1...2..XXX.>.XXXXXX
X...............X..m.....M....M.....m..X..XX..XX..XX..XX..XX..XX..XXX...XXXXXX
X+XXXXXuUuXXXXX+X======================X..XX..XX..XX..XX..XX..XX..n.X...XXXXXX
X.....X...X.....X======================X............................XX+XXXXXXX
X.....X...X.....X......................X.................................XXXXX
X....>X...X.....+......................+.............................."..XXXXX
X.....X...X.....X......................X.................................XXXXX
X.....X...X.....X======================X............................XX+XXXXXXX
X+XXXXXuUuXXXXX+X======================X..XX..XX..XX..XX..XX..XX..n.X...XXXXXX
X...............X..m.....M....M.....m..X..XX..XX..XX..XX..XX..XX..XXX...XXXXXX
X...............XX...XXX...XX...XXX...XX...1...2...1...2...1...2..XXX.>.XXXXXX
X...............XXXXXXXXXXXXXXXXXXXXXXXX..........3.......3.......XXXXXXXXXXXX
XXXXXXXX+XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXX|///|XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    ]]
    Level.place_tile(translation, map, 1, 1)
    Level.player(4, 10)
  end,
  
  OnEnter = function()
    hellfire_picked_up = false
    kills_on_start = player.kills
    if inferno.test then
      local it
      it = item.new("ashotgun")
      it.usetime = 7
      it.damage_dice = 8
      player.eq.weapon = it
      player.eq.armor = item.new("barmor")
      it = item.new("sboots")
      it.movemod = 20
      player.eq.boots = it
      for i = 1, 3 do
        it = item.new("shell")
        it.ammo = 50
        player.inv:add(it)
      end
      player.eq.prepared = item.new("bazooka")
      for i = 1, 2 do
        it = item.new("rocket")
        it.ammo = 10
        player.inv:add(it)
      end
      player.inv:add("lmed")
      player.inv:add("lmed")
      player.armor = 1
      player.hp = 60
      player.hpmax = 60
    end
    Level.result(0)
  end,
  
  OnKillAll = function()
    Level.result(1)
    ui.msg("The aura of this place has been cleansed.")
  end,
  
  OnExit = function()
    if Level.result() == 1 then
      player:add_history("He destroyed the evil within!")
      if statistics.damage_taken == player.damage_on_start then
        player:add_medal("inferno_tech1")
      end
      if hellfire_picked_up then
        ui.msg("So this is the technology of hell...")
      else
        ui.msg("A waste to leave it behind...")
      end
    elseif hellfire_picked_up then
      ui.msg("So this is the technology of hell...")
      player:add_history("He stole the demons' power source.")
    else
      ui.msg("This abominations here are better left undisturbed.")
      player:add_history("He left the treasure undisturbed.")
    end
    if hellfire_picked_up and player.kills == kills_on_start then
      player:add_medal("inferno_tech2")
    end
  end,
  
  IsCompleted = function()
    return Level.result() == 1
  end,
})