-------------
-- ITEMLIB --
-------------
-- by tehmi

-- version 0.3.0

-- An item management library for DoomRL.

-- This module can be freely used and redestributed for the purpose
-- of modding for DoomRL. It is provided with no warranty.

--[[ Documentation:

table.deep_copy(TABLE t) -> TABLE

   Copies the given table, recursively copying subtables.
   (Really this should be in a utility package. Oh well.)

ITEM:clone() -> ITEM

   Creates as near a copy of the item as possible.
   The newly returned item is neither on the map nor
   held by any being (as item.new).

   Note: A few item properties are loaded from the
   item prototype when it is created, so it is possible
   the clone might not be perfect if the prototype has
   been modified since the original item was created.

ITEM:serialize() -> TABLE

  Creates a lua table that stores the state of the item
  as fully as possible. This table can later be turned into
  an actual item with item.load, but unlike an actual item,
  DoomRL's save system can serialize a table returned by this
  function as a player property (assuming the item itself was
  serializable).
  
  The fidelity is equivalent to ITEM:clone

item.load(TABLE t)

  Creates an item from a table value returned by ITEM:serialize.
  
]]

function table.deep_copy(t)
  local copy = {}
  for k, v in pairs(t) do
    if type(v) == "table" then
      copy[k] = table.deep_copy(v)
    else
      copy[k] = v
    end
  end
  return copy
end

do
  local __properties = {
    "armor",
    "rechargedelay",
    "rechargeamount",
    "itype",
    "durability",
    "maxdurability",
    "movemod",
    "knockmod",
	"dodgemod",
    "ammoid",
    "ammo",
    "ammomax",
    "acc",
    "damage_dice",
    "damage_sides",
    "damage_add",
    "missile",
    "blastradius",
    "shots",
    "shotcost",
    "reloadtime",
    "usetime",
    "damagetype",
    "altfire",
    "altreload",
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
  rawset(item, "clone", function(it)
    local usual_OnCreate = it.__proto.OnCreate
    it.__proto.OnCreate = function() end
    local cl = item.new(it.id)
    it.__proto.OnCreate = usual_OnCreate
    for _, prop in ipairs(__properties) do
      cl[prop] = it[prop]
    end
    local usual_techbonus = player.techbonus
    player.techbonus = 127
    for imod = string.byte("A"), string.byte("Z") do
      local cmod = string.char(imod)
      local count = it:get_mod(cmod)
      for _ = 1, count do
        cl:add_mod(cmod)
      end
    end
    player.techbonus = usual_techbonus
    for flag = 1, 255 do
      cl.flags[flag] = it.flags[flag]
    end
    cl.__props = table.deep_copy(it.__props)
    return cl
  end)
  rawset(item, "serialize", function(it)
    local data = {}
    local c = it:get_position()
    data.x = c.x
    data.y = c.y
    data.id = it.id
    data.properties = {}
    for _, prop in ipairs(__properties) do
      data.properties[prop] = it[prop]
    end
    data.mods = {}
    for imod = string.byte("A"), string.byte("Z") do
      local cmod = string.char(imod)
      local count = it:get_mod(cmod)
      if count > 0 then
        data.mods[imod] = count
      end
    end
    data.flags = {}
    for flag = 1, 255 do
      data.flags[flag] = it.flags[flag]
    end
    local result
    result, data.__props = pcall(Serialize.serialize, it.__props)
    if not result then
      error("Failed to serialize item " .. it.id .. ": " .. data.__props)
    end
    return data
  end)
  rawset(item, "load_and_drop", function(data)
    local it = item.load(data)
    return Level.drop_item(it, coord.new(data.x, data.y))
  end)
  rawset(item, "load", function(data)
    local proto = items[data.id]
    local usual_OnCreate = proto.OnCreate
    proto.OnCreate = function() end
    local cl = item.new(data.id)
    proto.OnCreate = usual_OnCreate
    for _, prop in ipairs(__properties) do
      cl[prop] = data.properties[prop]
    end
    local usual_techbonus = player.techbonus
    player.techbonus = 127
    for imod = string.byte("A"), string.byte("Z") do
      local cmod = string.char(imod)
      local count = data.mods[imod] or 0
      for _ = 1, count do
        cl:add_mod(cmod)
      end
    end
    player.techbonus = usual_techbonus
    for flag = 1, 255 do
      cl.flags[flag] = data.flags[flag]
    end
    cl.__props = Serialize.load(data.__props)
    return cl
  end)
end