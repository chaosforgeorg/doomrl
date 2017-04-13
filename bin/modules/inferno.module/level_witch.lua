local d = 0
local origin = nil

Items({
  name = "Ruby Heart",
  ascii = "*",
  id = "uheart",
  color = LIGHTRED,
  sprite = SPRITE_ARMOR,
  coscolor = { 1.0, 0.2, 0.1, 1.0 },
  level = 200,
  weight = 0,
  type = ITEMTYPE_ARMOR,
  armor = 0,
  desc = "This thing pulses with infernal energy.",
  flags = {IF_UNIQUE},
  res_fire = 50,
  OnCreate = function(self)
    self:add_property("saved_weapon", false)
    self:add_property("equipped", false)
  end,
  OnEquipCheck = function(self, b)
    if b ~= player then
      return false
    end
    return true
  end,
  OnEquip = function(self, b)
    if player.eq.weapon then
      self.saved_weapon = player.eq.weapon:serialize()
    else
      self.saved_weapon = false
    end
    self.equipped = true
    ui.msg("Infernal magic flows through you.")
    player.eq.weapon = item.new("ulavablast")
  end,
  OnEquipTick = function(self, b)
    if self.durability == 0 then
      self.__proto.OnRemove(self, b)
      player.eq.armor = nil
    end
  end,
  OnRemove = function(self, b)
    if self.equipped then
      if self.saved_weapon then
        player.eq.weapon = item.load(self.saved_weapon)
        self.saved_weapon = false
      else
        player.eq.weapon = nil
      end
      self.equipped = false
    end
  end,
})

Items({
  name = "Lava Blast",
  id = "ulavablast",
  color = LIGHTRED,
  sprite = 0,
  psprite = 0,
  level = 200,
  weight = 0,
  type = ITEMTYPE_RANGED,
  ammo_id = "ammo",
  ammomax = 5,
  desc = "",
  acc = 1,
  damage = "7d2",
  damagetype = DAMAGE_FIRE,
  radius = 2,
  missile = {
    sound_id = "lwitch",
    color = RED,
    sprite = 0,
    delay = 30,
    miss_base = 25,
    miss_dist = 5,
    flags = {MF_IMMIDATE},
    expl_flags = {EFSELFSAFE, EFHALFKNOCK},
  },
  reload = 10,
  fire = 10,
  group = "weapon-other",
  flags = {IF_CURSED, IF_NOUNLOAD, IF_AUTOHIT},
  OnFired = function(self, being)
    self.ammo = self.ammomax
    player.eq.armor.durability = math.max(0, player.eq.armor.durability - 5)
  end,
})

Cells({ 
  name = "floor",
  id = "lava_floor",
  ascii = "=",
  set = CELLSET_FLOORS,
  bloodto = "blood",
  sprite = SPRITE_CAVEFLOOR,
})

Cells({ 
  name = "floor",
  id = "plava_floor",
  ascii = "=",
  set = CELLSET_FLOORS,
  flags = {CF_BLOCKMOVE},
  bloodto = "pblood",
  sprite = SPRITE_CAVEFLOOR,
})

Beings({
  name = "lava witch",
  name_plural = "lava witches",
  id = "lwitch",
  ascii = "W",
  color = LIGHTRED,
  todam = 9,
  tohit = 3,
  hp = 200,
  corpse = "corpse",
  speed = 100,
  min_lev = 200,
  weight = 0,
  armor = 2,
  corpse = true,
  danger = 10,
  bulk = 100,
  res_fire = 50,
  desc = "This demon has a mystic power of lava and hellfire.",
  sprite = SPRITE_ARCHVILE,
  flags = {F_GLOW},
  glow = {1.0, 0.0, 0.0, 0.8},
  attackchance = 75,
  kill_desc_melee = "flayed by a lava witch",
  kill_desc = "cremated by a lava witch",
  ai_type = "ranged_ai",
  weapon = {
    damage = "7d2",
    damagetype = DAMAGE_FIRE,
    radius = 2,
    missile = {
      sprite = 0,
      sound_id = "lwitch",
      firedesc = "@1 points at you!",
      hitdesc = "Lava bursts from the ground around you!",
      color = RED,
      delay = 30,
      miss_base = 25,
      miss_dist = 5,
      flags = {MF_IMMIDATE},
      expl_flags = {EFSELFSAFE, EFHALFKNOCK},
    },
  },
  OnCreate = function(self)
    self.inv:add("uheart")
    self.eq.armor = item.new("garmor")
    self.eq.armor.armor = 0
    self.eq.armor.durability = 0
  end,
  OnAction = function(self)
    if math.random(20 - DIFFICULTY) == 1 then
      for try = 1, 10 do
        local c = area.around(player:get_position(), 7):random_coord()
        if Level[c] == "lava" and Level.light[c][LFVISIBLE] then
          local b = Level.drop_being("cinder", c)
          if b then
            b.flags[BF_NOEXP] = true
            b.flags[BF_HUNTING] = true
            b:msg(nil, "A cinder rises from the lava.")
          end
          break
        end
      end
    end
    if Level.result() == 0 and self.hp <= 120 then
      self:msg(nil, "The lava witch teleports away.")
      Level.explosion(self, 2, 40, 0, 0, RED, self.id .. ".phase")
      thing.displace(self, coord.new(69, 11))
      Level.result(1)
    end
  end,
  OnDie = function(self)
    origin = self:get_position()
    if Level.result() == 0 then
      player:add_medal("inferno_witch2")
    end
    Level.result(2)
    player:add_medal("inferno_witch1")
  end,
})

Medal({
  id = "inferno_witch1",
  name = "Ruby Heart",
  desc = "Defeated the lava witch",
  hidden = true,
})

Medal({
  id = "inferno_witch2",
  name = "Deathblow Medal",
  desc = "Didn't allow the lava witch to escape",
  hidden = true,
})

Levels("WITCH", {

  name = "Infernal Sanctuary",
  
  entry = "On level @1 he discovered The Infernal Sanctuary.",
  
  welcome = "You enter the Infernal Sanctuary. ",
  
  find_phrase = "There he claimed @1.",
  
  mortem_location = "in The Infernal Sanctuary",
  
  type = "special",
  
  Create = function()
    Level.fill("floor")
    local translation = {
      ["."] = "floor",
      [">"] = "stairs",
      ["#"] = "wall",
      ["P"] = {"wall", flags = {LFPERMANENT}},
      ["="] = "lava",
      ["L"] = "plava",
      ["+"] = "door",
      ["W"] = {"floor", being = "lwitch"},
      ["O"] = {"lava", being = "cacodemon"},
      ["s"] = {"lava", being = "lostsoul"},
      ["1"] = {"lava"},
      ["2"] = {"lava"},
      ["|"] = {"floor", item = "shell"},
      ["/"] = {"floor", item = "cell"},
    }
    if DIFFICULTY == 3 then
      translation["1"].being = "pain"
    end
    if DIFFICULTY >= 4 then
      translation["1"].being = "lostsoul"
      translation["s"].being = "pain"
      translation["2"].being = "cacodemon"
    end
    local map = [[
LLLLLLLLLLLLLLLLLLLLLLLLLLLLLPPPLLLLLLLLLPPLLPPPPLPLLLLLLLLLLLLLPLLLLLLLLLLLLL
L=====###.===================PPP========//=====##=======================...==L
L===###..=========.###==.===PPP================#.======##=====...========.===L
L====##============||======.PPP======s==========s===============..===========L
L================O==.====..PPP==..=====.#====2=====O======##==####==##=======L
L=========...=s======2====.PPP===.==O=.##..=====1=====s===#==========#=======L
L=========.=============1=PPPPP=======1==2#.=....==2===##===PPPPPPPP===##====L
L====PPP=====.........===PP...PP=........===.......===##==PPP======PPP==##===L
L===#####===............=P.....P....................==O==PP==......==PP..====L
L==P#..|#......==2.......+....WP...===......==O==.....#==P=..........=P.=#===L
L==P#>..+....=======.....P.....P=======O......==s=.......+...........=P.=====L
L==P#..|#..======..======PP...PP=====#=====...........#==P=..........=P==#===L
L===#####===s.===#===O====PPPPP.=s=..##..=s==......==1===PP==......==PP======L
L====PPP===....====s====.==PPP..====##..====2======O==##==PPP======PPP==##===L
L====..=======O=====||=====PPP.========1========s==.===##===PPPPPPPP===##====L
L=========.=======.###.====.PPP==========#=======...=s====#=====..===#=======L
L=======.##..=====##========PPP=========..#.#O====.=====..##==####==##=======L
P##=.====...==========..=====PPP========.###//=========..===============..===L
P#####==============...#=====PPP==========.##========#===============.###====L
PPPPPPPPPLLPPPLLLLLLLLLLLLLLLLPPPLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLPPPPLLL
    ]]
    Level.place_tile(translation, map, 1, 1)
    Level.player(7, 11)
  end,
  OnEnter = function()
    Level.result(0)
  end,
  OnExit = function()
    local result = Level.result()
    if result >= 2 then
      ui.msg("Dust to dust...")
      player:add_history("He defeated the lava witch!")
    else
      ui.msg("Black magic is not to be trifled with.")
      player:add_history("He left the flames burning.")
    end
  end,
  OnTick = function()
    local result = Level.result()
    local c = coord.new(32, 10)
    if result >= 1 and (Level[c] == "wall" or Level[c] == "bwall") then
      Level[c] = "blood"
      Level.light[c][LFPERMANENT] = false
    end
    if result == 2 and core.game_time() % 10 == 0 then
      for c in area.FULL() do
        if c:distance(origin) == d then
          local cell_id = Level[c]
          if cell_id == "lava" then
            Level[c] = "lava_floor"
          elseif cell_id == "plava" then
            Level[c] = "plava_floor"
          end
        end
      end
      if d > MAXX + MAXY then
        Level.result(3)
      end
      d = d + 1
    end
  end,
  OnKillAll = function()
    ui.msg("Ashes to ashes...")
  end,
  IsCompleted = function()
    return Level.result() >= 2
  end,
})