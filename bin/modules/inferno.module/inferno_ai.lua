LurkAI.enable_lurk_ai("former", 5, true)
LurkAI.enable_lurk_ai("sergeant", 6, true)
LurkAI.enable_lurk_ai("captain", 6, true)
LurkAI.enable_lurk_ai("commando", 5, true)
LurkAI.enable_lurk_ai("knight", 6, true)
LurkAI.enable_lurk_ai("baron", 6, true)
LurkAI.enable_lurk_ai("imp", 6)
LurkAI.enable_lurk_ai("cacodemon", 6)
LurkAI.enable_lurk_ai("arachno", 6)
LurkAI.enable_lurk_ai("mancubus", 6)
LurkAI.enable_lurk_ai("revenant", 7)
LurkAI.enable_lurk_ai("arch", 8)
LurkAI.enable_lurk_ai("nimp", 6)
LurkAI.enable_lurk_ai("ncacodemon", 6)
LurkAI.enable_lurk_ai("narachno", 6)
LurkAI.enable_lurk_ai("narch", 8)

LurkAI.enable_lurk_ai("demon", 6)
LurkAI.enable_lurk_ai("lostsoul", 6)
LurkAI.enable_lurk_ai("pain", 7)
LurkAI.enable_lurk_ai("ndemon", 7)

local function signum(x)
  if x > 0 then
    return 1
  elseif x < 0 then
    return -1
  else
    return 0
  end
end

local function get_direction(origin, c)
  -- We use psuedo-octants in the same sense as angband distance
  local dx = c.x - origin.x
  local dy = c.y - origin.y
  if math.abs(dx) >= 2 * math.abs(dy) then
    return coord.new(signum(dx), 0)
  elseif math.abs(dy) >= 2 * math.abs(dx) then
    return coord.new(0, signum(dy))
  else
    return coord.new(signum(dx), signum(dy))
  end
end

local function rotate(v, count)
  if count < 0 then
    count = count * -7
  end
  while count >= 8 do
    count = count - 8
  end
  v = coord.clone(v)
  while count > 0 do
    if v.x == 1 and v.y >= 0 then
      v.y = v.y - 1
    elseif v.y == -1 and v.x >= 0 then
      v.x = v.x - 1
    elseif v.x == -1 and v.y <= 0 then
      v.y = v.y + 1
    else
      v.x = v.x + 1
    end
    count = count - 1
  end
  return v
end

local function phase_to(self, c)
  self:play_sound({self.id .. ".phase", "soldier.phase"})
  Level.explosion(self:get_position(), 1, 50, 0, 0, LIGHTBLUE)
  thing.displace(self, c)
  Level.explosion(self:get_position(), 1, 50, 0, 0, LIGHTBLUE)
end

AI({
  name = "hydra_ai",
  OnCreate = function(self)
    self:add_property("ai_state", "passive")
    self:add_property("boredom", 0)
    self:add_property("spawn_delay", 0)
    self:add_property("pending_spawns", 2)
  end,
  OnAttacked = function(self)
    self.ai_state = "active"
    self.boredom = 0
  end,
  states = {
    passive = function(self)
      if self.flags[BF_HUNTING] then
        self.boredom = 0
        return "active"
      end
      if self:in_sight(player) then
        self.__proto.OnAttacked(self)
        return "active"
      end
      if self.spawn_delay > 0 then
        self.spawn_delay = self.spawn_delay - 1
      end
      if math.random(20) == 20 then
        self:play_sound(self.__proto.sound_act)
      end
      if math.random(100) <= 40 then
        self:direct_seek(self:get_position():random_shifted())
      end
      if self.__ptr and self.scount >= 5000 then
        self.scount = self.scount - 1000
      end
    end,
    active = function(self)
      if self.spawn_delay == 0 and self.hpmax == self.__proto.hp then
        if self:in_sight(player) then
          local spawns = 0
          local v = get_direction(self:get_position(), player:get_position())
          local pos = {
            self:get_position() + rotate(v, 2),
            self:get_position() + rotate(v, -2),
          }
          for i = 1, 2 do
            if spawns >= 1 then
              break
            end
            if not Level.get_being(pos[i]) and not cells[Level[pos[i]]].flag_set[CF_BLOCKMOVE] then
              local b = Level.drop_being(self.id, pos[i])
              if b then
                b.flags[BF_NOEXP] = true
                b.hp = self.hpmax
                b.hpmax = self.hpmax
                b.ai_state = "active"
                b.spawn_delay = 30
                spawns = spawns + 1
              end
            end
          end
          if spawns == 1 then
            self:msg(nil, self:get_name(true, true) .. " splits into two!")
          elseif spawns == 2 then
            self:msg(nil, self:get_name(true, true) .. " splits into three!")
          end
          self.pending_spawns = self.pending_spawns - spawns
          if self.pending_spawns <= 0 then
            self.spawn_delay = 30
            self.pending_spawns = 2
          end
        end
      else
        self.spawn_delay = self.spawn_delay - 1
      end
      if math.random(20) == 20 then
        self:play_sound(self.__proto.sound_act)
      end
      local dist = self:distance_to(player)
      if dist == 1 then
        self:attack(player)
      elseif self:in_sight(player) then
        local roll = math.random(100)
        if roll <= self.__proto.attackchance then
          self:fire(player:get_position(), self.eq.weapon)
          if not self.__ptr then
            return
          end
        else
          self:direct_seek(player:get_position())
        end
      else
        self.boredom = self.boredom + 1
        self:path_find(player, 10, 40)
        self:path_next()
      end
      if self.__ptr and self.scount >= 5000 then
        self.scount = self.scount - 500
        self.boredom = self.boredom + 2
      end
      if self.__ptr and self.boredom + math.random(5) > 12 then
        return "passive"
      end
    end
  }
})

rawset(being, "blink", function(self)
  local c = Generator.random_empty_coord({EF_NOBEINGS, EF_NOBLOCK, EF_NOTELE, EF_NOHARM}, area.around(self:get_position(), 4))
  if c then
    self:play_sound({self.id .. ".phase", "soldier.phase"})
    Level.explosion(self:get_position(), 1, 50, 0, 0, LIGHTBLUE)
    thing.displace(self, c)
    Level.explosion(self:get_position(), 1, 50, 0, 0, LIGHTBLUE)
  end
end)

AI({
  name = "mist_ai",
  OnCreate = function(self)
    self:add_property("ai_state", "passive")
    self:add_property("boredom", 0)
  end,
  OnAttacked = function(self)
    self.ai_state = "active"
    self.boredom = 0
  end,
  states = {
    passive = function(self)
      if self:in_sight(player) then
        self.__proto.OnAttacked(self)
        self.boredom = 0
        return "active"
      end
      if math.random(20) == 20 then
        self:play_sound(self.__proto.sound_act)
      end
      if math.random(100) <= 40 then
        self:direct_seek(self:get_position():random_shifted())
      elseif math.random(6) == 1 then
        self:blink()
      end
      if self.__ptr and self.scount >= 5000 then
        self.scount = self.scount - 1000
      end
    end,
    active = function(self)
      self.boredom = self.boredom + 1
      if math.random(20) == 20 then
        self:play_sound(self.__proto.sound_act)
      end
      local dist = self:distance_to(player)
      if dist == 1 then
        self:attack(player)
      elseif self:in_sight(player) then
        local roll = math.random(100)
        if roll <= self.__proto.attackchance then
          self:fire(player:get_position(), self.eq.weapon)
          if not self.__ptr then
            return
          end
        else
          local next = self:get_position():random_shifted()
          if player:distance_to(next) <= self.vision and Level.light[next][LFVISIBLE] then
            self:direct_seek(next)
          end
        end
      else
        self.boredom = self.boredom + 1
        self:direct_seek(player:get_position())
      end
      if self.__ptr and self.scount >= 5000 then
        self.scount = self.scount - 500
        self.boredom = self.boredom + 2
      end
      if self.__ptr and self.boredom + math.random(5) > 10 then
        self:blink()
        return "passive"
      end
    end,
  },
})

AI({
  name = "ranged_hunting_ai",
  OnCreate = function(self)
    self:add_property("ai_state", "active")
    self:add_property("lurking", false)
  end,
  states = {
    active = function(self)
      local dist = self:distance_to(player)
      if dist == 1 then
        self:attack(player)
      elseif self:in_sight(player) then
        local roll = math.random(100)
        if roll <= self.__proto.attackchance then
          self:fire(player:get_position(), self.eq.weapon)
          if not self.__ptr then
            return
          end
        else
          self:direct_seek(player:get_position())
        end
      else
        self:direct_seek(player:get_position())
      end
      if self.__ptr and self.scount >= 5000 then
        self.scount = self.scount - 500
      end
    end,
  }
})

AI({
  name = "cinder_ai",
  OnCreate = function(self)
    self:add_property("ai_state", "passive")
    self:add_property("boredom", 0)
  end,
  OnAttacked = function(self)
    self.ai_state = "active"
    self.boredom = 0
  end,
  states = {
    passive = function(self)
      self.boredom = 0
      if math.random(20) == 20 then
        self:play_sound(self.__proto.sound_act)
      end
      if self:in_sight(player) or self.flags[BF_HUNTING] then
        return "active"
      end
      self.scount = self.scount - 500
    end,
    active = function(self)
      if math.random(20) == 20 then
        self:play_sound(self.__proto.sound_act)
      end
      local dist = self:distance_to(player)
      if dist <= 2 and self:is_visible() then
        self.scount = self.scount - 1200
        self:msg(nil, "The flames surrounding " .. self:get_name(true, false) .. " explode towards you!")
        Level.explosion(self:get_position(), 2, 40, 3, 5, YELLOW, self.id .. ".explode", DAMAGE_FIRE, {EFSELFSAFE, EFHALFKNOCK})
      elseif self:distance_to(player) <= self.vision and self:is_visible() then
        self:direct_seek(player:get_position())
      else
        self.boredom = self.boredom + 1
        self:path_find(player, 10, 40)
        self:path_next()
      end
      if self.__ptr and self.scount >= 5000 then
        self.scount = self.scount - 500
        self.boredom = self.boredom + 2
      end
      if self.__ptr and self.boredom + math.random(5) > 15 then
        self.boredom = 0
        return "passive"
      end
    end
  }
})

AI({
  name = "skull_ai",
  OnCreate = function(self)
    self:add_property("ai_state", "active")
    self:add_property("sound_pending", false)
    self:add_property("boredom", 0)
  end,
  states = {
    passive = function(self)
      if math.random(20) == 20 then
        self:play_sound(self.__proto.sound_act)
      end
      if self:in_sight(player) then
        return "active"
      end
      self.scount = self.scount - 500
    end,
    active = function(self)
      if math.random(20) == 20 then
        self:play_sound(self.__proto.sound_act)
      end
      local dist = self:distance_to(player)
      local chase = false
      local has_vision = false
      if dist <= 1 then
        self:attack(player)
      elseif self:in_sight(player) then
        chase = true
        has_vision = true
      else
        self.boredom = self.boredom + 1
        chase = true
      end
      if self.__ptr and chase then
        local candidates = {}
        for c in area.around(player:get_position(), 1)() do
          if not cells[Level[c]].flag_set[CF_BLOCKMOVE] then
            if not Level.get_being(c) then
              table.insert(candidates, c:clone())
            end
          end
        end
        local teleport = false
        if #candidates > 0 and math.random(3) == 1 then
          teleport = true
        end
        if dist <= 2 and has_vision then
          teleport = false
        end
        if teleport then
          local target = table.random_pick(candidates)
          self:play_sound({self.id .. ".phase", "soldier.phase"})
          Level.explosion(self:get_position(), 1, 50, 0, 0, LIGHTBLUE)
          thing.displace(self, target)
          Level.explosion(self:get_position(), 1, 50, 0, 0, LIGHTBLUE)
          self.scount = self.scount - 1200
        else
          self:direct_seek(player:get_position())
        end
      end
      if self.__ptr and self.scount >= 5000 then
        self.scount = self.scount - 500
        self.boredom = self.boredom + 2
      end
      if self.__ptr and self.boredom + math.random(5) > 30 then
        self.boredom = 0
        return "passive"
      end
    end
  }
})

AI({
  name = "rakshasa_ai",
  OnCreate = function(self)
    self:add_property("ai_state", "lurk")
    self:add_property("lurking", true)
    self:add_property("lurk_radius", 4)
    self:add_property("sound_pending", false)
    self:add_property("boredom", 0)
  end,
  OnAttacked = function(self)
    if self.ai_state == "lurk" then
      LurkAI.unlurk(self)
    end
  end,
  states = {
    lurk = function(self)
      if self:in_sight(player) then
        self.__proto.OnAttacked(self)
        return "active"
      end
      self.scount = self.scount - 1000
    end,
    active = function(self)
      LurkAI.sound_sight_check(self)
      if math.random(20) == 20 then
        self:play_sound(self.__proto.sound_act)
      end
      if self.eq.weapon and self.eq.weapon.ammo == 0 then
        if being.reload(self) then
          return
        end
      end
      local dist = self:distance_to(player)
      local has_vision = self:in_sight(player)
      if dist <= 1 then
        if self.eq.weapon.ammo > 0 then
          self:fire(player, self.eq.weapon)
        else
          self:attack(player)
        end
      elseif dist <= 2 and has_vision and math.random(2) == 1 then
        if self.eq.weapon.ammo > 0 then
          self:fire(player, self.eq.weapon)
        end
      elseif dist <= 3 and has_vision and math.random(5) == 1 then
        if self.eq.weapon.ammo > 0 then
          self:fire(player, self.eq.weapon)
        end
      end
      if self.__ptr and self.scount >= 5000 then
        self.boredom = self.boredom + 1
        self:direct_seek(player:get_position())
      end
      if self.__ptr and self.scount >= 5000 then
        self.scount = self.scount - 1000
        self.boredom = self.boredom + 2
      end
      if self.__ptr and self.boredom + math.random(5) > 20 then
        self.boredom = 0
        return "lurk"
      end
    end
  }
})

AI({
  name = "cyberlord_ai",
  OnCreate = function(self)
    self:add_property("ai_state", "lurk")
    self:add_property("lurking", true)
    self:add_property("lurk_radius", 9)
    self:add_property("sound_pending", false)
  end,
  OnAttacked = function(self)
    if self.ai_state == "lurk" then
      LurkAI.unlurk(self)
    end
  end,
  states = {
    lurk = function(self)
      if self:in_sight(player) then
        self.__proto.OnAttacked(self)
        return "active"
      end
      self.scount = self.scount - 1000
    end,
    active = function(self)
      LurkAI.sound_sight_check(self)
      if math.random(20) == 20 then
        self:play_sound(self.__proto.sound_act)
      end
      if self.eq.weapon and self.eq.weapon.ammo < math.max(1, self.eq.weapon.shotcost) then
        if being.reload(self) then
          return
        end
      end
      if self.eq.prepared and self.eq.prepared.ammo < math.max(1, self.eq.prepared.shotcost) then
        being.swap(self)
        if being.reload(self) then
          return
        end
        being.swap(self)
      end
      if self.eq.weapon and self.eq.weapon.id == "umbazooka" and math.random(3) == 1 then
        being.swap(self)
      elseif self.eq.weapon and self.eq.weapon.id == "bfg9000" then
        being.swap(self)
      end
      local dist = self:distance_to(player)
      local has_vision = self:in_sight(player)
      if dist <= 1 then
        self:attack(player)
      elseif has_vision and math.random(100) <= self.__proto.attackchance then
        if self.eq.weapon and self.eq.weapon.ammo >= math.max(self.eq.weapon.shotcost, 1) then
          self:fire(player, self.eq.weapon)
        else
          being.swap(self)
        end
      end
      if self.__ptr and self.scount >= 5000 then
        self:direct_seek(player:get_position())
      end
      if self.__ptr and self.scount >= 5000 then
        self.scount = self.scount - 1000
      end
    end
  }
})

AI({
  name = "hwitch_ai",
  OnCreate = function(self)
    self:add_property("ai_state", "active")
    self:add_property("boredom", 0)
  end,
  states = {
    passive = function(self)
      if math.random(20) == 20 then
        self:play_sound(self.__proto.sound_act)
      end
      if self:in_sight(player) then
        return "active"
      end
      self.scount = self.scount - 500
    end,
    active = function(self)
      if math.random(20) == 20 then
        self:play_sound(self.__proto.sound_act)
      end
      local dist = self:distance_to(player)
      if self:in_sight(player) then
        if math.random(100) <= self.__proto.attackchance then
          self:msg(nil, "The " .. self.name .. " points a finger at you.")
          ui.msg("You feel drained!")
          player:apply_damage(8, TARGET_INTERNAL, DAMAGE_IGNOREARMOR)
          self.hp = math.min(self.hpmax * 2, self.hp + 8)
          self.scount = self.scount - 1000
        else
          self.scount = self.scount - 1000
        end
      else
        self.boredom = self.boredom + 1
        self:direct_seek(player:get_position())
      end
      if self.__ptr and self.scount >= 5000 then
        self.scount = self.scount - 1000
        self.boredom = self.boredom + 2
      end
      if self.__ptr and self.boredom + math.random(5) > 30 then
        self.boredom = 0
        return "passive"
      end
    end
  }
})

inferno.simulacrum_lib = {}

function inferno.simulacrum_lib.reload_all(self, ...)
  local first = ...
  for _, w in ipairs({...}) do
    if w.ammo < w.ammomax then
      if self.eq.weapon ~= w then
        self:wear(w)
        --ui.msg("wear" .. w.name)
        return true
      end
      if self.eq.weapon.flags[IF_CHAMBEREMPTY] and self.eq.weapon.ammo > 0 then
        self:reload()
        --ui.msg("rel1" .. w.name)
        return true
      end
      local ammo = item.new(self.eq.weapon.ammoid)
      ammo.ammo = 1
      self.inv:add(ammo)
      self:reload()
      --ui.msg("rel2" .. w.name)
      return true
    end
  end
  if self.eq.weapon ~= first then
    --ui.msg("wear1" .. first.name)
    self:wear(first)
    return true
  end
  return false
end

function inferno.simulacrum_lib.use_weapon(self, w)
  if self.eq.weapon ~= w then
    self:wear(w)
    return
  end
  if self.eq.weapon.flags[IF_CHAMBEREMPTY] and self.eq.weapon.ammo > 0 then
    self:reload()
    return
  end
  if self.eq.weapon.ammo == 0 then
    local ammo = item.new(self.eq.weapon.ammoid)
    ammo.ammo = 1
    self.inv:add(ammo)
    self:reload()
    return
  end
  self:fire(player, self.eq.weapon)
end

function inferno.simulacrum_lib.summon(self)
  local function pick(list)
    local index = math.random(#list)
    if math.random(3) > DIFFICULTY then
      index = math.max(1, index - 1)
    end
    if 2 + math.random(3) < DIFFICULTY then
      index = math.min(#list, index + 1)
    end
    return list[index]
  end
  local id1 = pick(self.melee_summons)
  local id2 = pick(self.ranged_summons)
  local ar = area.around(player:get_position(), 4)
  Level.area_summon(ar, id1, 2 + math.random(2))
  Level.area_summon(ar, id2, 1 + math.random(2))
  ui.msg("Monsters appear from nowhere!")
end

AI({
  name = "simulacrum_ai",
  OnCreate = function(self)
    self.flags[BF_QUICKSWAP] = true
    self:add_property("long_weapon", item.new("bazooka"))
    self:add_property("short_weapon", item.new("ashotgun"))
    self.eq.weapon = self.short_weapon
    self.inv:add(self.long_weapon)
    self:add_property("ai_state", "monologue")
    self:add_property("lurking", false)
    self:add_property("lurk_radius", 9)
    self:add_property("sound_pending", false)
    self:add_property("monologue_phase", 1)
    self:add_property("monologue", {
      "The Simulacrum speaks: \"Mortals cannot be allowed to leave hell.\"",
      "The Simulacrum raises his arms.",
      "Lava erupts for the earth.",
      "\"Now, I'm afraid you'll have to die!\"",
    })
    self:add_property("boredom", 0)
    self:add_property("melee_summons", {"lostsoul", "demon", "spectre"})
    self:add_property("ranged_summons", {"imp", "knight", "baron"})
  end,
  states = {
    monologue = function(self)
      if self.monologue_phase > #self.monologue then
        return "active"
      end
      local trigger_function = inferno.Boss["trigger" .. self.monologue_phase]
      if trigger_function then
        trigger_function(self)
      end
      ui.msg(self.monologue[self.monologue_phase])
      self.monologue_phase = self.monologue_phase + 1
      self.scount = self.scount - 1000
    end,
    active = function(self)
      return "punish"
    end,
    punish = function(self)
      if self:in_sight(player) then
        self:msg(nil, "The Simulacrum points at you. You feel yanked away!")
        local target
        local tries = 100
        repeat
          target = Generator.random_empty_coord{ EF_NOBEINGS, EF_NOITEMS, EF_NOSTAIRS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }
          tries = tries - 1
        until target and target:distance(self:get_position()) >= 15 and tries > 0
        if target then
          phase_to(player, target)
        end
        self.scount = self.scount - 1000
        return "summon"
      else
        self.boredom = 25
        return "avoid"
      end
    end,
    summon = function(self)
      inferno.simulacrum_lib.summon(self)
      self.scount = self.scount - 1000
      self.boredom = 0
      return "avoid"
    end,
    ambush = function(self)
      local candidates = {}
      for c in area.around(player:get_position()):coords() do
        local cell = cells[Level[c]]
        local b = Level.get_being(c)
        if not b and not cell.flag_set[CF_BLOCKMOVE] then
          table.insert(candidates, c:clone())
        end
      end
      if #candidates == 0 then
        --ui.msg("no candidates")
        self.boredom = 20
        return "avoid"
      end
      table.shuffle(candidates)
      local best_c
      local best_distance = 0
      for _, c in ipairs(candidates) do
        local distance = self:distance_to(c)
        if distance > best_distance then
          best_c = c
          best_distance = distance
        end
      end
      if best_c then
        --ui.msg("phasing")
        phase_to(self, best_c)
        self.scount = self.scount - 1000
        self.boredom = 0
        return "attack"
      else
        --ui.msg("no best")
        self.boredom = 20
        return "avoid"
      end
    end,
    avoid = function(self)
      self.boredom = self.boredom + 1
      local player_visible = self:in_sight(player)
      if not player_visible then
        if inferno.simulacrum_lib.reload_all(self, self.short_weapon, self.long_weapon) then
          --ui.msg("reloading!/avoid")
          return "avoid"
        end
      end
      local all_dead = true
      for b in Level.beings() do
        if b ~= player and b ~= self then
          all_dead = false
        end
      end
      if all_dead then
        self.boredom = self.boredom + 5
      end
      if player_visible then
        self.boredom = 0
        return "attack"
      end
      if self.boredom > 30 then
        --ui.msg("bored now!")
        return "ambush"
      end
      local c = self:get_position() + self:get_position() - player:get_position()
      --ui.msg("avoiding!")
      area.FULL:clamp_coord(c)
      if self:direct_seek(c) ~= MOVEOK then
        self.scount = self.scount - 1000
      end
    end,
    attack = function(self)
      self.boredom = self.boredom + 1
      if self.boredom > 12 then
        return "escape"
      end
      local player_visible = self:in_sight(player)
      local distance = self:distance_to(player)
      if player_visible and distance == 1 then
        self:attack(player)
      elseif player_visible and distance < 4 then
        inferno.simulacrum_lib.use_weapon(self, self.short_weapon)
      elseif player_visible then
        inferno.simulacrum_lib.use_weapon(self, self.long_weapon)
      else
        self.boredom = self.boredom + 3
        if self:direct_seek(player) ~= MOVEOK then
          self.boredom = self.boredom + 4
          self.scount = self.scount - 1000
        end
      end
    end,
    escape = function(self)
      local player_visible = self:in_sight(player)
      if player_visible then
        return "punish"
      end
      self:phase()
      return "punish"
    end,
  }
})