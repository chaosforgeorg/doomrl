Serialize.register({
  id = "warp_feature_OnTick",
  Initialize = function(self, room, being_list, count, threshold, freq)
    self.being_list = being_list
    self.count = count
    self.threshold = threshold
    self.freq = freq or 20
    self.room = room
  end,
  Serialize = function(self)
    self.room = self.room:serialize()
  end,
  Restore = function(self)
    self.room = area.load(self.room) -- careful... kills room_meta association
  end,
  Run = function(self)
    if self.count == 0 then
      return
    end
    if self.threshold == 0 and (player.turns_on_level % self.freq) == 0 then
      local b = Level.area_summon(self.room:shrinked(), table.random_pick(self.being_list))
      if b then
        b:msg(nil, "Suddenly " .. b:get_name(false, false) .. " appears out of nowhere!")
        Level.explosion(b:get_position(), 1, 50, 0, 0, GREEN, core.resolve_sound_id("teleport.use", "use"))
        b.scount = 3500
        LurkAI.unlurk(b)
        b.flags[BF_HUNTING] = true
      end
      self.count = self.count - 1
      return
    end
    if self.threshold > 0 and self.room:contains(player:get_position()) then
      self.threshold = self.threshold - 1
      if not self.done_message then
        self.done_message = true
        ui.msg("You feel uneasy.")
        player:play_sound(inferno.Sound.being_sound(table.random_pick(self.being_list), "sight"))
      end
    end
  end,
})

Features({
  id = "warp",
  type = "monster",
  weight = 10,
  Check = function(room, rm)
    return Generator.check_dims(rm, 8, 7, 16, 14)
  end,
  Create = function(room)
    if inferno.debug then
      ui.msg("!!!***WARP***!!!")
    end
    local rm = Generator.room_meta[room]
    rm.monster = rm.monster - 1
    local roll = math.max(1, math.random(5) + Level.danger_level + (DIFFICULTY - 2) * 3)
    local threshold = 49 + math.random(30)
    local count = math.random(DIFFICULTY)
    if DIFFICULTY >= 3 then
      count = count + 1
    end
    if DIFFICULTY >= 4 then
      count = count + 1
    end
    local being_list = {"former"}
    if roll <= 3 then
      count = count + roll
    elseif roll <= 9 then
      count = count + roll
      being_list = {"imp"}
    elseif roll <= 15 then
      count = count + 2
      being_list = {"demon"}
    elseif roll <= 22 then
      being_list = {"knight"}
    else
      being_list = {"baron"}
      if roll >= 30 and DIFFICULTY >= 4 and math.random(2) == 1 then
        being_list = {"arachno"}
      end
    end
    inferno.Generator.register_hook("OnTick", "warp_feature_OnTick", room, being_list, count, threshold)
  end,
})