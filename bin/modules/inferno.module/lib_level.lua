local persistent_light_flags = {
  LFEXPLORED,
  LFPERMANENT,
  LFNOSPAWN,
}

rawset(Level, "clear", function()
  for c in area.FULL:coords() do
    Level[c] = "floor"
    if Level.get_being(c) ~= player then
      Level.clear_being(c)
    end
    if Level.get_item(c) then
      Level.clear_item(c)
    end
    for _, flag in ipairs(persistent_light_flags) do
      Level.light_flag_set(c, flag, false)
    end
  end
end)

-- Although it is unusual, there can be beings in the list that aren't on the map.
-- Example: inferno's spectres.
-- Current implementation just drops them back on the map (first so they'll be under others)

-- There can also be items in the list and not on the map, but I don't care.
-- They can be handled analogously if you need.

rawset(Level, "serialize", function()
  local data = {}
  local index = 1
  local Generator_get_cell = Generator.get_cell
  local Level_hp_get = Level.hp_get
  local Level_light_flag_get = Level.light_flag_get
  local being_uids = {}
  for c in area.FULL:coords() do
    local cell_data = {}
    data[index] = cell_data
    cell_data.nid = Generator_get_cell(c)
    local b = Level.get_being(c)
    if b and b ~= player then
      cell_data.being = b:serialize()
      being_uids[b.uid] = true
    end
    local i = Level.get_item(c)
    if i then
      cell_data.item = i:serialize()
    end
    cell_data.hp = Level_hp_get(c)
    local flags = {}
    cell_data.flags = flags
    for _, flag in ipairs(persistent_light_flags) do
      flags[flag] = Level_light_flag_get(c, flag)
    end
    index = index + 1
  end
  data.extra_beings = {}
  for b in Level.beings() do
    if b ~= player and not being_uids[b.uid] then
      table.insert(data.extra_beings, b:serialize())
    end
  end
  return data
end)

rawset(Level, "load", function(data)
  local index = 1
  local Generator_set_cell = Generator.set_cell
  local Level_hp_set = Level.hp_set
  local Level_light_flag_set = Level.light_flag_set
  for _, b_data in ipairs(data.extra_beings) do
    being.load_and_drop(b_data)
  end
  for c in area.FULL:coords() do
    local cell_data = data[index]
    Generator_set_cell(c, cell_data.nid)
    local being_data = cell_data.being
    if being_data then
      being.load_and_drop(being_data)
    end
    local item_data = cell_data.item
    if item_data then
      item.load_and_drop(item_data)
    end
    Level_hp_set(c, cell_data.hp)
    local flags = cell_data.flags
    for _, flag in ipairs(persistent_light_flags) do
      Level_light_flag_set(c, flag, flags[flag])
    end
    index = index + 1
  end
end)