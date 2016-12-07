core.declare("LurkAI", {})

-- This value determines how much scount a being spends each turn while lurking.
LurkAI.idle_scount = 500

-- This value determines how much scount a being spends when it is startled.
LurkAI.startle_scount = 500

-- This is meant to allow interaction with other features
function LurkAI.OnSoundCast(being)
  if being.__proto.ai_proto then
    being.__proto.ai_proto.OnAttacked(being)
  end
end

-- This needs to be added to the module hook
function LurkAI.OnFired(item, being)
  LurkAI.sound_cast(being:get_position(), 9)
end

function LurkAI.is_lurking(being)
  if not being or not being.__ptr or being:is_player() then
    return false
  end
  if not being:has_property("ai_state") then
    return false
  end
  return being.ai_state == "_lurk_ai_lurk"
end

function LurkAI.unlurk(being)
  if not being or not being.__ptr or being:is_player() then
    return
  end
  if LurkAI.is_lurking(being) then
    being.ai_state = "_lurk_ai_startled"
  end
  if being._lurk_ai_radius > 0 then
    LurkAI.sound_cast(being:get_position(), being._lurk_ai_radius)
  end
end

function LurkAI.sound_cast(origin, radius)
  LurkAI.sound_cast_cone(origin, 1, 0, 0, 1, radius)
  LurkAI.sound_cast_cone(origin, -1, 0, 0, 1, radius)
  LurkAI.sound_cast_cone(origin, 0, 1, 1, 0, radius)
  LurkAI.sound_cast_cone(origin, 0, -1, 1, 0, radius)
end

function LurkAI.sound_cast_cone(origin, major_x, major_y, minor_x, minor_y, radius)
  local prev
  local next = {true, true, true}
  for r = 1, radius do
    local axis = origin + coord.new(major_x * r, major_y * r)
    prev = next
    next = {false, false}
    for h = -r, r do
      if prev[h + r + 1] then 
        local c = axis + coord.new(minor_x * h, minor_y * h)
        if area.FULL_SHRINKED:contains(c) then
          --if Level[c] == "floor" then Level[c] = "blood" end
          local b = Level.get_being(c)
          if b then
            LurkAI.OnSoundCast(b)
          end
          if b and LurkAI.is_lurking(b) and b:distance_to(origin) <= radius then
            LurkAI.unlurk(b)
          end
          if not cells[Level[c]].flag_set[CF_BLOCKMOVE] then
            next[h + r + 1] = true
            next[h + r + 2] = true
            table.insert(next, true)
          else
            table.insert(next, false)
          end
        else
          table.insert(next, false)
        end
      else
        table.insert(next, false)
      end
    end
  end
end

function LurkAI.disable_lurking(b)
  if b:has_property("_lurk_ai_default_ai_state") then
    b.ai_state = b._lurk_ai_default_ai_state
  end
end

-- Sets a being type to have lurking behavior. This actually changes
-- the AI (once for each AI), but it should be harmless to non-lurkers
-- using the AI barring any name conflicts.
function LurkAI.enable_lurk_ai(being_proto, radius, use_items)
  if type(being_proto) == "string" or type(being_proto) == "number" then
    being_proto = beings[being_proto]
  end
  if being_proto._lurk_ai_enabled then
    error("LurkAI is already enabled for being " .. being_proto.name)
    return
  end
  being_proto._lurk_ai_enabled = true
  being_proto._lurk_ai_use_items = use_items or false
  local OnCreate = function(self)
    self:add_property("_lurk_ai_radius", radius)
    self:add_property("_lurk_ai_default_ai_state", self.ai_state)
    self:add_property("_lurk_ai_use_items", false)
    self:add_property("_lurk_ai_position", false)
    self:add_property("_lurk_ai_target", false)
    self.ai_state = "_lurk_ai_lurk"
  end
  local OnAttacked = function(self)
    if self.ai_state == "_lurk_ai_lurk" then
      LurkAI.unlurk(self)
    end
  end
  being_proto.OnCreate = create_seq_function(being_proto.OnCreate, OnCreate)
  being_proto.OnAttacked = create_seq_function(OnAttacked, being_proto.OnAttacked)
  local ai = ais[being_proto.ai_type]
  if not ai._lurk_ai_enabled then
    ai._lurk_ai_enabled = true
    function ai.states._lurk_ai_lurk(self)
      if self.flags[BF_HUNTING] then
        return self._lurk_ai_default_ai_state
      end
      local player_is_visible = self:in_sight(player)
      if player_is_visible then
        LurkAI.unlurk(self)
        return "_lurk_ai_startled"
      end
      self.scount = self.scount - LurkAI.idle_scount
      return "_lurk_ai_lurk"
    end
    function ai.states._lurk_ai_startled(self)
      if self.__proto.sound_sight then
        local sound = self.__proto.sound_sight
        if type(self.__proto.sound_sight) == "table" then
          sound = table.random_pick(sound)
        end
        self:play_sound(sound)
      end
      self.scount = self.scount - LurkAI.startle_scount
      return self._lurk_ai_default_ai_state
    end
  end
end

-- Looks through all lurking beings. If any of them are flagged to
-- use items, then nearby items may be added automatically to their
-- inventories or equipped (up to one each)
function LurkAI.auto_pickup()
  core.log("LurkAI.auto_pickup()")
  for b in Level.beings() do
    local pickup_it = nil
    if LurkAI.is_lurking(b) and b.__proto._lurk_ai_use_items then
      for it in Level.items_in_range(b, b.vision) do
        if it.flags[IF_AIHEALPACK] or it.itype == ITEMTYPE_ARMOR then
          if b:distance_to(it) <= b.vision and Level.eye_contact(b, it) then
            if not it.__proto.OnPickupCheck and not it.__proto.OnEquipCheck then
              pickup_it = it
              break
            end
          end
        end
      end
    end
    if pickup_it then
      b.inv:add(pickup_it)
      if pickup_it.itype == ITEMTYPE_ARMOR then
        b.eq.armor = pickup_it
      end
    end
  end
  core.log("LurkAI.auto_pickup()...end")
end