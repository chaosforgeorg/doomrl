--------------
-- BEINGLIB --
--------------
-- by tehmi

-- version 0.3.0

-- being:clone is untested; others should work

-- A being/player management library for DoomRL.

-- This library depends on ITEMLIB.

-- This module can be freely used and redestributed for the purpose
-- of modding for DoomRL. It is provided with no warranty.

-- being.clone(BEING b) -> BEING

-- Creates as near a copy of the being as possible.
-- The newly returned being is not yet placed on the
-- map (as being.new). This ignores many player-specific
-- properties.

-- Note: A few being properties are loaded from the
-- being prototype when it is created, so it is possible
-- the clone might not be perfect if the prototype has
-- been modified since the original being was created.

-- UNTESTED

do
  local __properties = {
    "hp",
    "hpmax",
    "vision",
    "scount",
    "tohit",
    "todam",
    "todamall",
    "tohitmelee",
    "speed",
    "armor",
    "expvalue",
    "techbonus",
    "pistolbonus",
    "rapidbonus",
    "bodybonus",
    "dodgebonus",
    "hpdecaymax",
    "reloadtime",
    "firetime",
    "movetime",
    "soundact",
    "soundhit",
    "sounddie",
    "soundattack",
    "soundmelee",
    "soundhoof",
    "picture",
    "color",
    "name",
    "nameplural",
    "res_bullet",
    "res_melee",
    "res_shrapnel",
    "res_acid",
    "res_fire",
    "res_plasma",
  }
  rawset(being, "clone", function(b)
    local usual_OnCreate = b.__proto.OnCreate
    b.__proto.OnCreate = function() end
    local cl = being.new(b.id)
    b.__proto.OnCreate = usual_OnCreate
    cl.eq:clear()
    cl.inv:clear()
    for eq_slot = 0, MAX_EQ_SIZE - 1 do
      local it = b.eq[eq_slot]
      if it then
        cl.eq[eq_slot] = item.clone(it)
      end
    end
    for it in b.inv:items() do
      cl.inv:add(item.clone(it))
    end
    for _, prop in ipairs(__properties) do
      cl[prop] = b[prop]
    end
    for flag = 1, 255 do
      cl.flags[flag] = b.flags[flag]
    end
    cl.__props = table.deep_copy(b.__props)
    return cl
  end)
  rawset(being, "serialize", function(b)
    local data = {}
    local c = b:get_position()
    data.x = c.x
    data.y = c.y
    data.id = b.id
    data.eq = {}
    for eq_slot = 0, MAX_EQ_SIZE - 1 do
      local it = b.eq[eq_slot]
      if it then
        data.eq[eq_slot] = it:serialize()
      end
    end
    data.inv = {}
    for it in b.inv:items() do
      table.insert(data.inv, it:serialize())
    end
    data.properties = {}
    for _, prop in ipairs(__properties) do
      data.properties[prop] = b[prop]
    end
    data.flags = {}
    for flag = 1, 255 do
      data.flags[flag] = b.flags[flag]
    end
    local result
    result, data.__props = pcall(Serialize.serialize, b.__props)
    if not result then
      error("Failed to serialize being " .. b.id .. ": " .. data.__props)
    end
    return data
  end)
  rawset(being, "load_and_drop", function(data)
    local b = being.load(data)
    local rtn = Level.drop_being(b, coord.new(data.x, data.y))
    if rtn and _G[module.id] and _G[module.id].OnRestoreBeing then
      _G[module.id].OnRestoreBeing(rtn)
	end
    return rtn
  end)
  rawset(being, "load", function(data)
    local proto = beings[data.id]
    local usual_OnCreate = proto.OnCreate
    proto.OnCreate = function() end
    local cl = being.new(data.id)
    proto.OnCreate = usual_OnCreate
    cl.eq:clear()
    cl.inv:clear()
    for eq_slot = 1, MAX_EQ_SIZE do
      local it_data = data.eq[eq_slot]
      if it_data then
        local it = item.load(it_data)
        local usual_OnEquip = it.__proto.OnEquip
        it.__proto.OnEquip = function() end
        cl.eq[eq_slot] = item.load(it_data)
        it.__proto.OnEquip = usual_OnEquip
      end
    end
    for _, it_data in ipairs(data.inv) do
      cl.inv:add(item.load(it_data))
    end
    for _, prop in ipairs(__properties) do
      cl[prop] = data.properties[prop]
    end
    for flag = 1, 255 do
      cl.flags[flag] = data.flags[flag]
    end
    cl.__props = Serialize.load(data.__props)
    return cl
  end)
  local __player_properties = {
    "running", "tired", -- tactics
    "exp",
    "explevel",
    -- "nuketime",
    "klass",
    "runningtime",
    "expfactor",
  }
  table.merge(__player_properties, __properties)
  --[[
  player:add_property("serialize", false)
  function player:serialize()
    if not self:is_player() then
      error("player:serialize() must be called with the player")
    end
    local data = {}
    data.properties = {}
    for _, prop in ipairs(__player_properties) do
      data.properties[prop] = self.prop
    end
    data.eq = {}
    for eq_slot = 1, MAX_EQ_SIZE do
      local it = self.eq[eq_slot]
      if it then
        data.eq[eq_slot] = it:serialize()
      end
    end
    data.inv = {}
    for it in self.inv:items() do
      table.insert(data.inv, it:serialize())
    end
    
  end
  ]]
end
