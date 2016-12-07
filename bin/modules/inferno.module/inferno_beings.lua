being_prototype.danger_override = { false }
being_prototype.glow = { false }

local function add_flag(p, f)
  p.flag_set[f] = true
  table.insert(p.flags, f)
end

local function overlay_to_glow(p)
  add_flag(p, F_GLOW)
  p.glow_alpha = p.overlay_alpha
  p.glow_red = p.overlay_red
  p.glow_green = p.overlay_green
  p.glow_blue = p.overlay_blue
end

-- nightmare glow
overlay_to_glow(beings.ndemon)
overlay_to_glow(beings.nimp)
overlay_to_glow(beings.ncacodemon)
overlay_to_glow(beings.narachno)
overlay_to_glow(beings.narch)

local function invisible(self)
  if not self.__ptr then
    return
  end
  local effective_vision_bonus = 0
  if player.flags[BF_BEINGSENSE] then
    effective_vision_bonus = effective_vision_bonus + 3
  end
  if self:distance_to(player) > player.vision + effective_vision_bonus - 4 and not Level.flags[LF_BEINGSVISIBLE] then
    if Level.get_being(self:get_position()) == self then
      local c = player:get_position()
      thing.displace(player, self:get_position())
      thing.displace(player, c)
    end
  else
    if not Level.get_being(self:get_position()) then
      thing.displace(self, self:get_position())
    end
  end
end

local loaded = false

function inferno.load_beings()
  if loaded then return end
  loaded = true
  Beings({
    name = "spectre",
    sound_id = "demon",
    ascii = "c",
    color = WHITE,
    todam = 5,
    tohit = 3,
    hp = 25,
    speed = 100,
    min_lev = 1,
    max_lev = 20,
    armor = 2,
    corpse = true,
    danger = 4,
    weight = 0,
    bulk = 100,
    flags = {BF_CHARGE, F_GLOW},
    desc = "Damn! These things come out of nowhere. You can't even hit them until they're too close!",
    sprite = SPRITE_DEMON,
    glow = { 0.0, 0.0, 0.2, 0.8 },
    kill_desc_melee = "spooked by a spectre",
    ai_type = "demon_ai"
  })

  -- This breaks with arch-vile rezzing
  --beings.spectre.OnCreate = create_seq_function(beings.spectre.OnCreate, invisible)

  LurkAI.enable_lurk_ai("spectre", 6)
  
  beings.spectre.OnAction = create_seq_function(beings.spectre.OnAction, invisible)

  Beings({
    name = "nightmare spectre",
    id = "nspectre",
    ascii = "c",
    color = DARKGRAY,
    todam = 10,
    tohit = 5,
    hp = 80,
    speed = 140,
    min_lev = 40,
    armor = 3,
    corpse = true,
    danger = 11,
    weight = 0,
    bulk = 100,
    flags = { BF_CHARGE },
    desc = "These ghostly demons are shrouded in a palpable darkness.",
    sprite = 54,
    kill_desc_melee = "surprised by a nightmare spectre",
    ai_type = "demon_ai",
    OnAction = function(self)
      player.__props.spec_penalty = player.__props.spec_penalty or 0
      if self:distance_to(player) <= 6 and player.spec_penalty == 0 then
        player.__props.spec_penalty = 2
        player.vision = player.vision - 2
        ui.msg("The world suddenly becomes dim.")
      end
    end,
  })

  beings.nspectre.OnTick = function()
    if core.game_time() % 100 == 0 then
      if player.__props.spec_penalty and player.__props.spec_penalty ~= 0 then
        for b in Level.beings() do
          if b.id == "nspectre" then
            if b:distance_to(player) <= 6 then
              return
            end
          end
        end
        player.vision = player.vision + player.spec_penalty
        player.spec_penalty = 0
        ui.msg("You can see clearly again.")
      end
    end
  end

  beings.nspectre.OnAction = create_seq_function(beings.nspectre.OnAction, invisible)

  LurkAI.enable_lurk_ai("nspectre", 6)

  Beings({
    name = "shadow demon",
    id = "shadowdemon",
    ascii = "D",
    color = DARKGRAY,
    todam = 8,
    tohit = 4,
    hp = 80,
    speed = 125,
    min_lev = 200,
    armor = 3,
    corpse = true,
    danger = 15,
    weight = 0,
    bulk = 100,
    attackchance = 30,
    flags = {BF_OPENDOORS, BF_HUNTING, F_GLOW},
    desc = "Does this thing really exist? Or is your mind just playing tricks?",
    sprite = SPRITE_BARON,
    glow = { 0.0, 0.0, 0.2, 0.8 },
    kill_desc = "vaporized by a shadow demon",
    kill_desc_melee = "sundered by a shadow demon",
    ai_type = "ranged_hunting_ai",
    weapon = {
      damage = "4d5",
      damagetype = DAMAGE_BULLET,
      missile = {
        sprite = SPRITE_PLASMABALL,
        color = DARKGRAY,
        delay = 60,
        miss_base = 15,
        miss_dist = 5,
        flags = {MF_RAY}
      },
    },
    OnAction = function(self)
      if math.random(12) == 1 then
        if self:distance_to(player) <= player.vision - 4 then
          Level.explosion(self:get_position(), 1, 50, 0, 0, LIGHTBLUE)
        end
        self:phase()
        if self:distance_to(player) <= player.vision - 4 then
          Level.explosion(self:get_position(), 1, 50, 0, 0, LIGHTBLUE)
        end
      end
    end,
    OnCreate = function(self)
      self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 4
      self.hp = self.hpmax
      self:add_property("invisible", true)
    end,
  })

  beings.shadowdemon.OnAction = create_seq_function(beings.shadowdemon.OnAction, invisible)

  Beings({
    name = "imp lord",
    id = "imp_lord",
    sound_id = "imp",
    ascii = "i",
    color = LIGHTRED,
    sprite = SPRITE_IMP,
    hp = 90,
    armor = 2,
    attackchance = 60,
    todam = 3,
    tohit = 4,
    speed = 205,
    min_lev = 0,
    weight = 0,
    corpse = "corpse",
    danger = 15,
    bulk = 100,
    flags = {F_GLOW},
    glow = {0.8, 0.2, 0.2, 0.8},
    ai_type = "melee_ranged_ai",
    
    res_fire = 70,
    res_acid = 15,
    res_melee = 15,
    res_bullet = 15,
    res_shrapnel = 15,
    res_plasma = 15,
    
    weapon = {
      damage = "2d6+2",
      damagetype = DAMAGE_FIRE,
      radius = 1,
      missile = {
        sound_id = "imp",
        ascii = "*",
        color = LIGHTRED,
        sprite = SPRITE_FIREBALL,
        delay = 30,
        miss_base = 25,
        miss_dist = 5,
        expl_delay = 40,
        expl_color = RED,
      },
    },
    
    desc = "Lightning fast and tough to boot, this is the paragon of all imps.",
    kill_desc = "scorched by an imp lord",
    kill_desc_melee = "slashed by an imp lord",
    
    OnAction = function(self)
      if self.hp < self.hpmax then
        self.hp = self.hp + 1
      end
      if math.random(30) == 1 then
        local count = 0
        for b in Level.beings() do
          if b.id == "imp" then
            count = count + 1
          end
        end
        if count < 18 then
          local bid = "imp"
          if math.random(4) == 1 then
            bid = "nimp"
          end
          local c = Generator.standard_empty_coord()
          if c and not Level.light[c][LFVISIBLE] then
            local b = Level.drop_being(bid, c)
            b.flags[BF_HUNTING] = true
            b.flags[BF_NOEXP] = true
            b.scount = 3500 + math.random(99)
          end
        end
      end
    end,
  })
  
  LurkAI.enable_lurk_ai(beings["imp_lord"], 8)
  
  Beings({
    name = "soul keeper",
    id = "soul_keeper",
    sound_id = "lostsoul",
    ascii = "K",
    color = WHITE,
    sprite = SPRITE_LOSTSOUL,
    hp = 100,
    armor = 3,
    attackchance = 0,
    todam = 6,
    tohit = 4,
    speed = 150,
    min_lev = 0,
    weight = 0,
    corpse = "bloodpool",
    danger = 17,
    bulk = 100,
    flags = {F_GLOW},
    glow = {0.8, 0.8, 0.15, 0.8},
    ai_type = "spawnonly_ai",
    
    res_fire = 15,
    res_acid = 15,
    res_melee = 45,
    res_bullet = 45,
    res_shrapnel = 35,
    res_plasma = 15,
        
    desc = "A soul keeper is a powerful lich that commands power over the souls of demons.",
    kill_desc = "depleted by a soul keeper",
    
    OnCreate = function(self)
      self:add_property("spawnchance", 4)
      self:add_property("spawnlist", {{name = "imp", amt = 2}})
      self:add_property("pending_souls", {})
    end,
    
    OnAction = function(self)
      for _, soul in ipairs(self.pending_souls) do
        local b = Level.drop_being("lostsoul", coord.new(soul.x, soul.y))
        if b then
          b.scount = 4000
          b:msg(nil, "A lost soul rises from the corpse.")
        end
      end
      self.pending_souls = {}
      if self.hp < 10 then
        self.spawnchance = 3
      end
      if self.hp < 40 then
        self.spawnlist = {{name = "baron", amt = 1}}
      elseif self.hp < 75 then
        self.spawnlist = {{name = "knight", amt = 1}}
      end
    end,
    
    OnDie = function(self)
      for _=1, 9 do
        self:spawn("lostsoul")
      end
    end,
  })
  
  LurkAI.enable_lurk_ai(beings["soul_keeper"], 8)
  
  Beings({
    name = "hydra",
    ascii = "y",
    color = GREEN,
    todam = 2,
    tohit = 4,
    hp = 16,
    speed = 115,
    min_lev = 0,
    max_lev = 200,
    danger = 5,
    danger_override = 4.5,
    weight = 0,
    bulk = 100,
    flags = {BF_ENVIROSAFE, F_GLOW},
    res_acid = 50,
    attackchance = 40,
    desc = "Kill these bastards fast before they have a chance to multiply!",
    sprite = SPRITE_IMP,
    glow = {0.2, 0.75, 0.2, 0.8},
    kill_desc = "dissolved by a hydra",
    kill_desc_melee = "eaten by a hydra",
    ai_type = "hydra_ai",
    weapon = {
      damage = "2d4",
      damagetype = DAMAGE_ACID,
      radius = 0,
      missile = {
        sprite = SPRITE_ACIDSHOT,
        sound_id = "hydra",
        color = LIGHTGREEN,
        flags = {F_COSCOLOR},
        delay = 20,
        miss_base = 50,
        miss_dist = 5,
        expl_delay = 40,
        expl_color = GREEN,
      },
    },
    OnCreate = function(self)
      --self:add_property("is_dying", false)
    end,
    --[[OnDie = function(self) -- This was cute, but didn't play well IMO
      if not self.is_dying then
        self.is_dying = true
        if self.parent and self.parent.__ptr and not self.parent.is_dying then
          self.parent:kill(TARGET_INTERNAL, false)
        end
        if self.children then
          for _, child in ipairs(self.children) do
            if child and child.__ptr and not child.is_dying then
              child:kill(TARGET_INTERNAL, false)
            end
          end
        end
      end
    end,]]
  })

  LurkAI.enable_lurk_ai("hydra", 6)
  
  Beings({
    name = "hydra queen",
    id = "hydraq",
    sound_id = "hydra",
    ascii = "y",
    color = YELLOW,
    todam = 5,
    tohit = 5,
    hp = 40,
    speed = 120,
    min_lev = 200,
    max_lev = 200,
    danger = 12,
    xp = 15, -- Exp is awarded separately for each kill
    weight = 0,
    bulk = 100,
    flags = {BF_ENVIROSAFE, F_GLOW},
    res_acid = 50,
    attackchance = 30,
    desc = "So this is where they all come from. But rumor has it that the queens aren't so easy to kill...",
    sprite = SPRITE_IMP,
    glow = {0.8, 0.8, 0.15, 0.8},
    kill_desc = "swarmed by the hydra queen",
    kill_desc_melee = "swarmed by the hydra queen",
    ai_type = "melee_ranged_ai",
    weapon = {
      damage = "2d4",
      damagetype = DAMAGE_ACID,
      radius = 1,
      missile = {
        sprite = SPRITE_ACIDSHOT,
        flags = {F_COSCOLOR},
        sound_id = "imp",
        ascii = "*",
        color = LIGHTGREEN,
        delay = 30,
        miss_base = 50,
        miss_dist = 5,
        expl_delay = 40,
        expl_color = GREEN,
      },
    },
    OnCreate = function(self)
      if DIFFICULTY >= 3 then
        self.hpmax = self.hpmax + 10
      end
      if DIFFICULTY >= 4 then
        self.hpmax = self.hpmax + 10
      end
      self.hp = self.hpmax
    end,
    OnDie = function(self)
      if self.hpmax > 10 then
        local num = 0
        for i = 1, 2 do
          local b = Level.drop_being(self.id, self:get_position())
          if b then
            b.hpmax = self.hpmax - 10
            b.hp = b.hpmax
            b.scount = 3500
            LurkAI.unlurk(b)
            num = num + 1
          end
        end
        if num == 2 then
          self:msg(nil, "Two smaller queens crawl from its corpse.")
        elseif num == 1 then
          self:msg(nil, "A smaller queen crawls from its corpse.")
        end
      end
    end,
  })

  LurkAI.enable_lurk_ai(beings["hydraq"], 8)

  Beings({
    name = "nightmare hydra",
    id = "nhydra",
    ascii = "y",
    color = MAGENTA,
    todam = 4,
    tohit = 5,
    hp = 35,
    speed = 125,
    min_lev = 0,
    max_lev = 200,
    danger = 8,
    xp = 30,
    weight = 0,
    bulk = 100,
    flags = {BF_ENVIROSAFE, F_GLOW},
    res_acid = 50,
    res_plasma = 50,
    attackchance = 55,
    desc = "Infused with plasma and even harder to kill: meet the ultimate hydra.",
    sprite = SPRITE_IMP,
    glow = {0.75, 0.0, 1.0, 0.8},
    kill_desc = "dissolved by a hydramare",
    kill_desc_melee = "devoured by a hydramare",
    ai_type = "hydra_ai",
    weapon = {
      damage = "2d6",
      damagetype = DAMAGE_PLASMA,
      radius = 0,
      missile = {
        sprite = SPRITE_ACIDSHOT,
        flags = {F_COSCOLOR},
        sound_id = "hydra",
        color = LIGHTMAGENTA,
        delay = 20,
        miss_base = 40,
        miss_dist = 4,
        expl_delay = 40,
        expl_color = MAGENTA,
      },
    },
    OnDie = function(self)
      if self.hpmax == 35 then
        local num = 0
        for i = 1, 2 do
          local b = Level.drop_being(self.id, self:get_position())
          if b then
            b.hpmax = self.hpmax - 10
            b.hp = b.hpmax
            b.scount = 3500
            LurkAI.unlurk(b)
            num = num + 1
          end
        end
        if num == 2 then
          self:msg(nil, "Two smaller hydramares from its corpse.")
        elseif num == 1 then
          self:msg(nil, "A smaller hydramare crawls from its corpse.")
        end
      end
    end,
  })

  LurkAI.enable_lurk_ai("nhydra", 7)
  
  Beings({
    name = "achlys",
    name_plural = "achlyses",
    id = "mist",
    ascii = "a",
    color = CYAN,
    todam = 3,
    tohit = 3,
    hp = 30,
    speed = 120,
    min_lev = 5,
    max_lev = 25,
    weight = 0,
    armor = 1,
    corpse = true,
    danger = 5,
    bulk = 100,
    flags = {F_GLOW},
    glow = {0.1, 0.6, 0.8, 0.8},
    desc = "This ethereal demon is always ready to appear out of nowhere and disintegrate you.",
    sprite = SPRITE_KNIGHT,
    attackchance = 60,
    kill_desc_melee = "gutted by an achlys",
    kill_desc = "disintegrated by an achlys",
    ai_type = "mist_ai",
    weapon = {
      damage = "2d4",
      damagetype = DAMAGE_IGNOREARMOR,
      missile = {
        sprite = SPRITE_PLASMABALL,
        sound_id = "mist",
        color = LIGHTCYAN,
        delay = 16,
        miss_base = 40,
        miss_dist = 6,
      },
    },
  })

  LurkAI.enable_lurk_ai("mist", 5)
  
  Beings({
    name = "anaplecte",
    id = "nmist",
    ascii = "a",
    color = LIGHTBLUE,
    todam = 5,
    tohit = 4,
    hp = 55,
    speed = 130,
    min_lev = 11,
    max_lev = 25,
    weight = 0,
    armor = 1,
    corpse = true,
    danger = 10,
    bulk = 100,
    res_melee = 50,
    res_bullet = 50,
    res_shrapnel = 50,
    desc = "These elite achlyses are hardly visible. Physical weapons may have little effect.",
    sprite = 53,
    attackchance = 60,
    kill_desc_melee = "flayed by an anaplecte",
    kill_desc = "disintegrated by an anaplecte",
    ai_type = "mist_ai",
    weapon = {
      damage = "4d3",
      damagetype = DAMAGE_BULLET,
      missile = {
        sprite = 0,
        sound_id = "mist",
        color = LIGHTCYAN,
        delay = 30,
        miss_base = 40,
        miss_dist = 6,
      },
    },
  })

  beings.nmist.OnAction = create_seq_function(beings.nmist.OnAction, invisible)

  Beings({
    name = "cinder",
    ascii = "e",
    color = YELLOW,
    todam = 0,
    tohit = 0,
    hp = 38,
    speed = 145,
    min_lev = 1,
    max_lev = 20,
    armor = 1,
    corpse = "lava",
    danger = 7,
    danger_override = 6.5,
    weight = 0,
    bulk = 100,
    flags = {BF_CHARGE, BF_FIREANGEL, BF_ENVIROSAFE, F_GLOW},
    res_fire = 50,
    desc = "Flaming corpse animated by hellish magic. Don't get too close or the flames will engulf you.",
    sprite = SPRITE_LOSTSOUL,
    glow = {1.0, 0.0, 0.0, 0.8},
    kill_desc_melee = "burned by a cinder",
    ai_type = "cinder_ai",
    OnDie = function(self)
      self:play_sound(self.id .. ".explode")
    end
  })

  LurkAI.enable_lurk_ai("cinder", 6)
  
  Beings({
    name = "ember",
    ascii = "E",
    color = LIGHTRED,
    sprite = 0,
    todam = 6,
    tohit = 4,
    hp = 80,
    min_lev = 70,
    armor = 4,
    danger = 12,
    weight = 0,
    corpse = "lava",
    attackchance = 40,
    bulk = 100,
    flags = {BF_ENVIROSAFE},
    res_fire = 50,
    desc = "This mass of lava has been animated by infernal sorcery.",
    kill_desc = "ignited by an ember",
    kill_desc_melee = "scorched by an ember",
    ai_type = "flee_ranged_ai",
    weapon = {
      damage = "5d4",
      damagetype = DAMAGE_FIRE,
      radius = 2, 
      missile = {
        sprite = 0,
        sound_id = "ember",
        ascii = "*",
        color = LIGHTRED,
        delay = 50,
        expl_color = RED,
        miss_base = 35,
        miss_dist = 4,
        expl_delay = 40,
        flags = {MF_EXACT},
        expl_flags = {EFRANDOMCONTENT},
        content = "lava",
      },
    },
  })

  LurkAI.enable_lurk_ai(beings["ember"], 6)

  Beings({
    name = "prometheus",
    ascii = "P",
    sprite = 0,
    color = YELLOW,
    todam = 9,
    tohit = 4,
    hp = 120,
    min_lev = 70,
    armor = 5,
    danger = 17,
    weight = 0,
    corpse = "lava",
    attackchance = 35,
    bulk = 100,
    flags = {BF_ENVIROSAFE},
    res_fire = 50,
    desc = "This demon is like a walking volcano.",
    kill_desc = "charred by a prometheus",
    kill_desc_melee = "charred by a prometheus",
    ai_type = "ranged_ai",
    weapon = {
      damage = "5d5",
      damagetype = DAMAGE_FIRE,
      radius = 1,
      missile = {
        sprite = 0,
        sound_id = "prometheus",
        ascii = "*",
        color = LIGHTRED,
        delay = 50,
        expl_color = RED,
        miss_base = 35,
        miss_dist = 3,
        expl_delay = 40,
        flags = {MF_EXACT},
      },
    },
    OnAction = function(self)
      if not self.lurking then
        self.flags[BF_HUNTING] = true
      end
      for c in area.around(self, 1)() do
        if math.random(4) == 1 then
          local cell = cells[Level[c]]
          if not cell.flag_set[CF_CRITICAL] then
            if area.FULL_SHRINKED:contains(c) then
              Level[c] = "lava"
            else
              Level[c] = "plava"
            end
          end
        end
      end
    end,
  })

  LurkAI.enable_lurk_ai(beings["prometheus"], 6)

  Beings({
    name = "asura",
    ascii = "U",
    color = RED,
    todam = 8,
    tohit = 2,
    hp = 65,
    speed = 90,
    min_lev = 200,
    max_lev = 200,
    armor = 2,
    corpse = true,
    danger = 11,
    weight = 0,
    attackchance = 60,
    bulk = 100,
    desc = "What's worse than a demon with shotguns for arms? The fact that it has three arms. Keep the hell away from these guys.",
    sprite = SPRITE_MANCUBUS,
    flags = {F_GLOW},
    glow = {0.6, 0.0, 0.0, 0.8},
    kill_desc = "was splattered by an asura",
    kill_desc_melee = "was torn apart by an asura",
    ai_type = "ranged_ai",
    OnCreate = function(self)
      self.eq.weapon = item.new("sg_asura")
      local it = item.new("shell")
      it.ammo = 30
      self.inv:add(it)
    end,
    OnAction = function(self)
      if self.__ptr then
        self.eq.weapon.ammo = 3 -- IF_NOAMMO doesn't seem to be working
      end
    end,
  })

  Items({
    name = "sg_asura",
    sound_id = "shotgun",
    sprite = 0,
    psprite = 0,
    level = 200,
    weight = 0,
    type = ITEMTYPE_RANGED,
    ammo_id = "shell",
    ammomax = 3,
    damage = "5d3",
    shots = 3,
    damagetype = DAMAGE_SHARPNEL,
    missile = "snormal",
    reload = 10,
    fire = 10,
    flags = {IF_SHOTGUN, IF_NODROP, IF_NOAMMO},
    group = "weapon-shotgun",
    desc = "",
  })

  LurkAI.enable_lurk_ai(beings["asura"], 6)

  Beings({
    name = "nightmare skull",
    id = "nskull",
    ascii = "s",
    color = LIGHTBLUE,
    todam = 4,
    tohit = 4,
    hp = 13,
    armor = 1,
    speed = 140,
    min_lev = 6,
    max_lev = 16,
    danger = 4,
    danger_override = 6,
    weight = 0,
    bulk = 100,
    flags = {BF_ENVIROSAFE},
    desc = "These skulls are possessed by powerful evil spirits. With their ability to appear behind you at any moment, they can quickly swarm you.",
    sprite = 55,
    kill_desc_melee = "devoured by a nightmare skull",
    vision = 9,
    ai_type = "skull_ai",
  })
  
  LurkAI.enable_lurk_ai(beings["nskull"], 6)

  Beings({ 
    name = "nightmare elemental",
    id = "npain",
    ascii = "O",
    color = MAGENTA,
    todam = 8,
    tohit = 2,
    hp = 78,
    speed = 120,
    min_lev = 12,
    max_lev = 20,
    armor = 3,
    danger = 13,
    weight = 0,
    bulk = 100,
    flags = {BF_ENVIROSAFE},
    desc = "A flying mass of putrid flesh that spews nightmare skulls.",
    sprite = 57,
    ai_type = "spawnonly_ai",
    OnCreate = function(self)
      self:add_property("spawnlist", {{name = "nskull", amt = 3}})
      self:add_property("spawnchance", 4)
    end,
    OnDie = function (self,overkill)
      if not overkill then
        for c = 1, 2 + math.random(2) do
          local b = Level.drop_being("nskull", self:get_position())
          if b then
            b.flags[BF_NOEXP] = true
            b.scount = 3000 + math.random(100)
            LurkAI.unlurk(b)
          end
        end
      end
    end,
  })

  LurkAI.enable_lurk_ai(beings["npain"], 6)

  local random_ammo
  do
    local ammo_types = {"ammo", "shell", "rocket", "cell"}
    local q = {48, 24, 5, 35}
    random_ammo = function(b, rate)
      for index, at in ipairs(ammo_types) do
        if math.random(100) <= rate then
          local it = item.new(at)
          it.ammo = q[index]
          b.inv:add(it)
        end
      end
    end
  end

  Beings({
    name = "hell duke",
    id = "duke",
    ascii = "B",
    color = MAGENTA,
    todam = 8,
    tohit = 5,
    hp = 80,
    min_lev = 12,
    armor = 2,
    corpse = true,
    danger = 15,
    weight = 0,
    attackchance = 40,
    bulk = 100,
    flags = {BF_OPENDOORS},
    res_acid = 50,
    desc = "These gigantic acid-hurling beasts have armies of hell knights at their command.",
    sprite = 59,
    kill_desc = "obliterated by a hell duke",
    kill_desc_melee = "flattened by a hell duke",
    ai_type = "baron_ai",
    weapon = {
      damage = "4d5",
      damagetype = DAMAGE_ACID,
      radius = 2, 
      missile = {
        sprite = 0,
        sound_id = "duke",
        ascii = "*",
        color = LIGHTGREEN,
        delay = 35,
        miss_base = 45,
        miss_dist = 3,
        expl_delay = 40,
        expl_color = GREEN,
      },
    },
    OnCreate = function(self)
      self:add_property("children", {})
      random_ammo(self, 40)
    end,
    OnAction = function(self)
      if #self.children > 0 then
        for index = #self.children, 1, -1 do
          local child = self.children[index]
          if not child.__ptr then
            table.remove(self.children, index)
          end
        end
      end
      if #self.children < 3 and math.random(4) == 1 then
        local summoned = 0
        for i = 1, 3 - #self.children do
          local b = Level.drop_being("knight", self:get_position())
          if b then
            summoned = summoned + 1
            b.flags[ BF_NOExp ] = true
            b.scount = 3000 + math.random(100)
            table.insert(self.children, b)
            if not self.lurking then
              LurkAI.unlurk(b)
            end
          end
        end
        if summoned == 1 then
          self:msg(nil, "The hell duke summons hell knights.")
        elseif summoned >= 2 then
          self:msg(nil, "The hell duke summons a hell knight.")
        end
      end
    end,
  })

  LurkAI.enable_lurk_ai(beings["duke"], 6)

  Beings({
    name = "archduke of hell",
    name_plural = "archdukes of hell",
    id = "archduke",
    ascii = "B",
    color = LIGHTBLUE,
    todam = 9,
    tohit = 5,
    hp = 94,
    min_lev = 12,
    armor = 3,
    corpse = true,
    danger = 20,
    weight = 0,
    attackchance = 45,
    bulk = 100,
    flags = {BF_OPENDOORS},
    res_acid = 50,
    desc = "These hulking nightmares command even hell's fearsome barons to do their bidding.",
    sprite = 59,
    kill_desc = "massacred by an archduke of hell",
    kill_desc_melee = "disemboweled by a archduke of hell",
    ai_type = "baron_ai",
    weapon = {
      damage = "4d5",
      damagetype = DAMAGE_ACID,
      radius = 2, 
      missile = {
        sprite = 0,
        sound_id = "archduke",
        ascii = "*",
        color = LIGHTGREEN,
        delay = 35,
        miss_base = 40,
        miss_dist = 2,
        expl_delay = 40,
        expl_color = GREEN,
      },
    },
    OnCreate = function(self)
      self:add_property("children", {})
      random_ammo(self, 50)
    end,
    OnAction = function(self)
      if #self.children > 0 then
        for index = #self.children, 1, -1 do
          local child = self.children[index]
          if not child.__ptr then
            table.remove(self.children, index)
          end
        end
      end
      if #self.children < 3 and math.random(4) == 1 then
        local summoned = 0
        for i = 1, 3 - #self.children do
          local b = Level.drop_being("baron", self:get_position())
          if b then
            summoned = summoned + 1
            b.flags[ BF_NOExp ] = true
            b.scount = 3000 + math.random(100)
            table.insert(self.children, b)
            if not self.lurking then
              LurkAI.unlurk(b)
            end
          end
        end
        if summoned == 1 then
          self:msg(nil, "The archduke of hell summons barons.")
        elseif summoned >= 2 then
          self:msg(nil, "The archduke of hell summons a baron.")
        end
      end
    end,
  })

  LurkAI.enable_lurk_ai(beings["archduke"], 7)

  Beings({
    name = "knightmare",
    id = "nknight",
    ascii = "B",
    color = YELLOW,
    todam = 10,
    tohit = 5,
    hp = 118,
    min_lev = 12,
    armor = 3,
    corpse = true,
    danger = 16,
    weight = 0,
    attackchance = 45,
    bulk = 100,
    flags = {BF_OPENDOORS},
    res_acid = 50,
    desc = "Almost no attack can stop the advance of these gargantuan tanks.",
    sprite = 59,
    kill_desc = "reduced to dust by a nightmare knight",
    kill_desc_melee = "pulverized by a nightmare knight",
    ai_type = "baron_ai",
    weapon = {
      damage = "5d5",
      damagetype = DAMAGE_PLASMA,
      radius = 2, 
      missile = {
        sprite = 0,
        sound_id = "nknight",
        ascii = "*",
        color = LIGHTMAGENTA,
        delay = 35,
        miss_base = 40,
        miss_dist = 3,
        expl_delay = 40,
        expl_color = MAGENTA,
      },
    },
    OnCreate = function(self)
      random_ammo(self, 30)
      self.bodybonus = 1
    end,
  })

  LurkAI.enable_lurk_ai(beings["nknight"], 6)

  --[[
  Beings({
    name = "nightmare baron",
    id = "nbaron",
    ascii = "B",
    color = BLUE,
    todam = 12,
    tohit = 6,
    hp = 140,
    min_lev = 12,
    speed = 110,
    armor = 4,
    corpse = true,
    danger = 20,
    weight = 0,
    attackchance = 48,
    bulk = 100,
    flags = {BF_OPENDOORS},
    res_acid = 50,
    desc = "These unstoppable forces charge at the front of hell's armies.",
    sprite = 59,
    kill_desc = "reduced to a puddle by a nightmare baron",
    kill_desc_melee = "run over by a nightmare baron",
    ai_type = "baron_ai",
    weapon = {
      damage = "6d5",
      damagetype = DAMAGE_ACID,
      radius = 2, 
      missile = {
        sprite = 0,
        sound_id = "nbaron",
        ascii = "*",
        color = LIGHTGREEN,
        delay = 35,
        miss_base = 38,
        miss_dist = 3,
        expl_delay = 40,
        expl_color = GREEN,
      },
    },
    OnCreate = function(self)
      random_ammo(self, 40)
    self.bodybonus = 2
    end,
  })

  LurkAI.enable_lurk_ai(beings["nbaron"], 6)

  Beings({
    name = "nightmare duke",
    id = "nduke",
    ascii = "B",
    color = GREEN,
    todam = 9,
    tohit = 6,
    hp = 133,
    min_lev = 12,
    armor = 3,
    corpse = true,
    danger = 15,
    weight = 100,
    attackchance = 48,
    bulk = 100,
    flags = {BF_OPENDOORS},
    res_acid = 50,
    desc = "These formidable commanders are flanked at all times by nightmare knights.",
    sprite = 59,
    kill_desc = "defeated by a nightmare duke",
    kill_desc_melee = "defeated by a nightmare duke",
    ai_type = "baron_ai",
    weapon = {
      damage = "5d5",
      damagetype = DAMAGE_ACID,
      radius = 2, 
      missile = {
        sprite = 0,
        sound_id = "duke",
        ascii = "*",
        color = LIGHTGREEN,
        delay = 35,
        miss_base = 40,
        miss_dist = 3,
        expl_delay = 40,
        expl_color = GREEN,
      },
    },
    OnCreate = function(self)
      self:add_property("children", {})
      random_ammo(self, 40)
    end,
    OnAction = function(self)
      if #self.children > 0 then
        for index = #self.children, 1, -1 do
          local child = self.children[index]
          if not child.__ptr then
            table.remove(self.children, index)
          end
        end
      end
      if #self.children < 2 and math.random(4) == 1 then
        local summoned = 0
        for i = 1, 2 - #self.children do
          local b = Level.drop_being("nknight", self:get_position())
          if b then
            summoned = summoned + 1
            b.flags[ BF_NOExp ] = true
        b.inv:clear()
            b.scount = 3000 + math.random(100)
            table.insert(self.children, b)
            if not self.lurking then
              LurkAI.unlurk(b)
            end
          end
        end
        if summoned == 1 then
          self:msg(nil, "The hell duke summons nightmare knights.")
        elseif summoned >= 2 then
          self:msg(nil, "The hell duke summons a nightmare knight.")
        end
      end
    end,
  })

  LurkAI.enable_lurk_ai(beings["nduke"], 6)
]]
  Beings({
    name = "nightmare revenant",
    id = "nrevenant",
    ascii = "R",
    color = LIGHTBLUE,
    todam = 9,
    tohit = 5,
    hp = 75,
    speed = 140,
    min_lev = 13,
    armor = 5,
    corpse = true,
    danger = 19,
    weight = 5,
    attackchance = 60,
    bulk = 100,
    flags = {BF_OPENDOORS},
    desc = "This skeletal being will keep on fighting even after it has died many times!",
    sprite = 62,
    kill_desc = "was found by a nightmare revenant's rocket",
    kill_desc_melee = "uppercutted by a nightmare revenant",
    ai_type = "ranged_ai",
    weapon = {
      damage = "5d6",
      radius = 2,
      damagetype = DAMAGE_FIRE,
      missile = {
        sprite = 0,
        sound_id = "bazooka",
        color = YELLOW,
        delay = 30,
        miss_base = 25,
        miss_dist = 5,
        expl_delay = 40,
        expl_color = RED,
        flags = {MF_EXACT},
      },
    },
    OnCreate = function(self)
      local it = item.new("rocket")
      it.ammo = 5
      self.inv:add(it)
    end,
  })

  do
    local locs = {}
    beings.nrevenant.OnDie = function(self)
      table.insert(locs, {t = core.game_time(), c = self:get_position()})
    end
    beings.nrevenant.OnTick = function(self)
      if core.game_time() % 10 == 0 then
        for i = #locs, 1, -1 do
          local t, c = locs[i].t, locs[i].c
          if Level[c] == "nrevenantcorpse" then
            if core.game_time() - t >= 100 then
              if not Level.get_being(c) then
                local r = Level.drop_being("nrevenant", c)
                if r then
                  Level[c] = "bloodpool"
                  r.flags[BF_NOEXP] = true
                  table.remove(locs, i)
                  r:msg(nil, "The nightmare revenant reassembles itself and gets back up.")
                  r.inv:clear()
                end
              end
            end
          else
            table.remove(locs, i)
          end
        end
      end
    end
  end

  local function strong_resurrect(b, area, rez_message)
    area = area:clamped(area.FULL_SHRINKED)
    local corpses = {}
    for c in area() do
      local cell = cells[Level[c]]
      if cell.flag_set[CF_CORPSE] and cell.effect > 100 then
        if not Level.get_being(c) then
          table.insert(corpses, c:clone())
        end
      end
    end
    if #corpses == 0 then
      return nil
    end
    local c = table.random_pick(corpses)
    local cell = cells[Level[c]]
    Level[c] = "bloodpool"
    b:msg(nil, rez_message)
    local r = Level.drop_being(cell.effect - 100, c)
    if r then
      r:msg(nil, r:get_name(true) .. " suddenly rises from the dead!")
      r.flags[BF_NOEXP] = true
      return r
    else
      return nil
    end
  end

  Beings({
    name = "hell witch",
    name_plural = "hell witches",
    id = "hwitch",
    ascii = "W",
    color = MAGENTA,
    todam = 9,
    tohit = 4,
    hp = 115,
    speed = 130,
    corpse = "corpse",
    danger = 23,
    weight = 0,
    min_lev = 100,
    attackchance = 30,
    flags = {BF_OPENDOORS},
    desc = "This powerful demon is a mother of arch-viles.",
    sprite = 61,
    kill_desc = "was drained by a hell witch",
    ai_type = "hwitch_ai",
    OnAction = function(self)
      if self:is_visible() then
        if math.random(4) == 1 then
          strong_resurrect(self, area.around(player:get_position(), 5), "The hell witch raises her arms!")
        end
      else
        if math.random(10) == 1 then
          strong_resurrect(self, area.FULL_SHRINKED, "The hell witch raises her arms!")
        end
      end
    end
  })

  LurkAI.enable_lurk_ai(beings["cyberdemon"], 7)

  Beings({
    name = "alastor",
    ascii = "T",
    color = BROWN,
    todam = 5,
    tohit = 1,
    hp = 87,
    min_lev = 200,
    armor = 3,
    corpse = true,
    danger = 19,
    weight = 0,
    attackchance = 55,
    bulk = 100,
    desc = "This cybernetic demon has a microrocket minigun. He's eager to blow you away.",
    sprite = 63,
    kill_desc = "bombarded by an alastor",
    kill_desc_melee = "slashed by an alastor",
    ai_type = "flee_ranged_ai",
    weapon = {
      damage = "3d5",
      damagetype = DAMAGE_FIRE,
      radius = 1,
      shots = 4,
      missile = {
        sprite = 0,
        sound_id = "alastor",
        color = BROWN,
        delay = 20,
        miss_base = 35,
        miss_dist = 5,
        expl_delay = 40,
        expl_color = RED,
        expl_flags = {EFHALFKNOCK},
      },
    },
  })

  LurkAI.enable_lurk_ai(beings["alastor"], 4)

  Beings({
    name = "rakshasa",
    ascii = "K",
    color = BROWN,
    todam = 5,
    tohit = 2,
    hp = 70,
    armor = 2,
    corpse = true,
    danger = 19,
    min_lev = 30,
    weight = 0,
    speed = 200,
    bulk = 100,
    desc = "",
    sprite = 63,
    flags = {BF_CHARGE},
    ai_type = "rakshasa_ai",
    kill_desc = "assassinated by a rakshasa",
    kill_desc_melee = "assassinated by a rakshasa",
    OnCreate = function(self)
      self.eq.weapon = item.new("dshotgun")
      self.inv:add("shell")
      self.inv[1].ammo = 30
    end,
  })

  Beings({
    name = "arachne",
    ascii = "C",
    color = GREEN,
    todam = 5,
    tohit = 4,
    hp = 95,
    armor = 2,
    speed = 160,
    min_lev = 100,
    corpse = true,
    danger = 14,
    weight = 0,
    attackchance = 63,
    bulk = 100,
    desc = "These are hell's true spider demons. Their sticky attack can entangle careless marines.",
    sprite = 60,
    kill_desc = "was ensnared by an arachne",
    ai_type = "ranged_ai",
    weapon = {
      damage = "4d4",
      damagetype = DAMAGE_ACID,
      radius = 1,
      missile = {
        sprite = 0,
        sound_id = "arachne",
        ascii = "*",
        color = WHITE,
        delay = 40,
        miss_base = 30,
        miss_dist = 5,
        expl_flags = {EFRANDOMCONTENT},
        content = "web",
      },
    },
    OnAction = function(self)
      local pos = self:get_position()
      if cells[Level[pos]].set == CELLSET_FLOORS then
        Level[pos] = "web"
      end
    end
  })

  Beings({
    name = "Simulacrum",
    id = "simulacrum",
    ascii = "@",
    color = DARKGRAY,
    todam = 0,
    tohit = 2,
    hp = 250,
    speed = 100,
    min_lev = 200,
    max_lev = 200,
    armor = 2,
    corpse = "corpse",
    danger = 32,
    xp = 0,
    weight = 0,
    attackchance = 75,
    bulk = 100,
    desc = "",
    sprite = SPRITE_JC,
    kill_desc = "was perforated by the Simulacrum",
    kill_desc_melee = "was shredded by the Simulacrum",
    flags = {
      BF_NODROP,
    },
    ai_type = "simulacrum_ai",
    OnCreate = function(self)
      self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 12
      self.hp = self.hpmax
      self.eq.prepared = "chainsaw"
    end,
    OnDie = function(self)
      inferno.ending()
    end,
  })
end