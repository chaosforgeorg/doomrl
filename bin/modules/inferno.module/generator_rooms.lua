core.declare("Features", function(feature)
  table.insert(features[feature.type], feature)
  features[feature.id] = feature
end)

Generator.feature_types = {
  {
    id = "full",
    noweight = 900,
  },
  {
    id = "layout",
    noweight = 35,
  },
  {
    id = "floor",
    noweight = 80,
  },
  {
    id = "monster",
    noweight = 10,
  },
  {
    id = "doodad",
    noweight = 0,
  }
}

core.declare("features", {})
for _, feature_type in ipairs(Generator.feature_types) do
  features[feature_type.id] = {}
end

function inferno.Generator.initialize_rooms()
  player:add_property("unique_rooms", {})
end

Generator.handle_rooms = function(rate)
  if type(rate) ~= "number" then
    rate = 100
  end
  for _, room in ipairs(Generator.room_list) do
    if math.random(100) <= rate then
      Generator.handle_room(room)
    end
  end
end

Generator.handle_room = function(room)
  local rm = Generator.room_meta[room]
  rm.full = false
  rm.layout = 1
  rm.floor = 1
  rm.monster = 1
  rm.doodad = 0
  local roll = math.random(100)
  if roll <= 2 then
    rm.doodad = math.random(5)
  elseif roll <= 15 then
    rm.doodad = math.random(3)
  elseif roll <= 35 then
    rm.doodad = 1
  end
  local ltype = level_types[inferno.level_type]
  for _, feature_type in ipairs(Generator.feature_types) do
    if not (feature_type.id == "full" and not ltype.allow_full_rooms) then
      local candidates = {}
      table.insert(candidates, {id = false, weight = feature_type.noweight})
      local sum = feature_type.noweight
      for _, feature in ipairs(features[feature_type.id]) do
        if Generator.check_feature(room, feature) then
          table.insert(candidates, feature)
          sum = sum + feature.weight
        end
      end
      local limit = rm[feature_type.id]
      if type(limit) == "boolean" then
        limit = 1
      end
      if sum > 0 then
        for count = 1, limit do
          local feature = Level.roll_weight(candidates, sum)
          if feature.id then
            core.log("feature: " .. feature.id)
            local result = feature.Create(room)
            if result and feature.unique then
              player.unique_rooms[feature.id] = true
            end
          end
        end
      end
    end
  end
end

Generator.check_feature = function(room, feature)
  local rm = Generator.room_meta[room]
  if rm.full then
    return false
  end
  if feature.unique and player.unique_rooms[feature.id] then
    return false
  end
  if rm.used and feature.type == "full" then
    return false
  end
  if feature.type ~= "full" and rm[feature.type] <= 0 then
    return false
  end
  if not feature.Check then
    ui.msg("no check: " .. feature.id)
    return false
  end
  return feature.Check(room, rm)
end

function Generator.check_dims(rm, x_min, y_min, x_max, y_max)
  return
    rm.dims.x >= x_min and
    rm.dims.y >= y_min and
    rm.dims.x <= (x_max or 78) and
    rm.dims.y <= (y_max or 20)
end

Generator.get_auxiliary_room = function()
  local choice_list = {}
  for _, r in ipairs(Generator.room_list) do
    local rm = Generator.room_meta[r]
    if not rm.full then
      table.insert(choice_list, r)
    end
  end
  if #choice_list > 0 then
    return table.random_pick(choice_list)
  else
    return nil
  end
end

-- This is a hack to use a specific room for the built-in room
-- generation functions.
Generator.current_room = nil

-- check_feature handles the checking that is usually done in get_room.
Generator.get_room = function()
  return Generator.current_room
end

Features({
  id = "fluid",
  type = "full",
  weight = 15,
  Check = function(room, rm)
    return
      Generator.check_dims(rm, 3, 3, 40) and
      rm.dims.x * rm.dims.y <= 120
  end,
  Create = function(room)
    Generator.room_meta[room].full = true
    Generator.current_room = room
    Generator.generate_basain()
  end,
})

Features({
  id = "warehouse",
  type = "layout",
  weight = 30,
  Check = function(room, rm)
    return Generator.check_dims(rm, 8, 8)
  end,
  Create = function(room)
    local rm = Generator.room_meta[room]
    rm.layout = rm.layout - 1
    Generator.current_room = room
    Generator.generate_warehouse_room()
  end,
})

Features({
  id = "ammo",
  type = "floor",
  weight = 10,
  Check = function(room, rm)
    return Generator.check_dims(rm, 3, 3)
  end,
  Create = function(room)
    local rm = Generator.room_meta[room]
    rm.floor = rm.floor - 1
    Generator.current_room = room
    Generator.generate_ammo_room()
  end,
})

Features({
  id = "teleport",
  type = "doodad",
  weight = 15,
  Check = function(room, rm)
    return Generator.check_dims(rm, 3, 3, 20, 15)
  end,
  Create = function(room)
    local rm = Generator.room_meta[room]
    rm.doodad = rm.doodad - 1
    Generator.current_room = room
    Generator.generate_teleport_room()
  end,
})