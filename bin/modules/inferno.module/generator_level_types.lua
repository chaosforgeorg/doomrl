core.declare("level_types", {})

core.declare("LevelTypes", function(level_type)
  table.insert(level_types, level_type)
  level_types[level_type.id] = level_type
  if level_type.allow_full_rooms == nil then
    level_type.allow_full_rooms = true
  end
end)

function inferno.Generator.roll_level_type(dlvl)
  local types = {}
  local total_weight = 0
  for _, lt in ipairs(level_types) do
    if dlvl >= lt.min_lev then
      local weight = lt.weight
      if lt.decay then
        weight = weight - lt.decay * (dlvl - lt.min_lev)
        weight = math.max(weight, lt.decay_min or 0)
      end
      if weight > 0 then
        table.insert(types, {id = lt.id, weight = weight})
        total_weight = total_weight + weight
      end
    end
  end
  local result = Level.roll_weight(types, total_weight)
  if result then
    return level_types[result.id]
  else
    return level_types["tiled"]
  end
end

LevelTypes({
  id = "tiled",
  min_lev = 0,
  weight = 400,
  decay = 20,
  decay_min = 100,
  Create = Generator.generate_tiled_dungeon,
})

LevelTypes({
  id = "city",
  min_lev = 3,
  weight = 200,
  decay = 5,
  decay_min = 100,
  Create = function()
    local usual_add_room = Generator.add_room
    function Generator.add_room(room)
      usual_add_room(room)
      local rm = Generator.room_meta[Generator.room_list[#Generator.room_list]]
      rm.exterior = true
    end
    Generator.generate_city_dungeon()
    Generator.add_room = usual_add_room
  end,
})

LevelTypes({
  id = "warehouse",
  min_lev = 3,
  weight = 185,
  decay = 4,
  decay_min = 100,
  Create = Generator.generate_warehouse_dungeon,
})

LevelTypes({
  id = "maze",
  min_lev = 3,
  weight = 85,
  decay = 1,
  decay_min = 75,
  Create = Generator.generate_maze_dungeon,
})

LevelTypes({
  id = "archi",
  min_lev = 3,
  weight = 180,
  decay = 4,
  decay_min = 80,
  Create = inferno.Generator.generate_archi_room_dungeon,
})

LevelTypes({
  id = "braid",
  min_lev = 5,
  weight = 80,
  decay = 1,
  decay_min = 70,
  Create = inferno.Generator.generate_braid_dungeon
})

LevelTypes({
  id = "caves",
  min_lev = 3,
  weight = 70,
  Create = function()
    Generator.generate_caves()
    if math.random(3) == 1 then
      inferno.Generator.place_trees()
    end
    local amount = math.floor(Generator.being_weight() * 0.67)
    local monster = inferno.Generator.roll_cave_monster()
    Level.flood_items(10)
    Level.flood_monster(monster, amount)
    if monster ~= "lostsoul" and monster ~= "demon" and monster ~= "spectre" then
      if math.random(5) == 1 then
        Level.summon("demon", 4 + math.random(2))
      elseif math.random(6) == 1 then
        Level.summon("spectre", 3 + math.random(3))
      elseif math.random(4) == 1 then
        Level.summon("lostsoul", 5 + math.random(4))
      end
    end
    ui.msg( "Twisted passages carry the smell of death..." )
    Generator.generate_stairs()
    Generator.generate_special_stairs()
    Generator.place_player()
  end,
})

LevelTypes({
  id = "hybrid",
  min_lev = 3,
  weight = 80,
  Create = inferno.Generator.generate_hybrid_caves_dungeon,
})

LevelTypes({
  id = "arena",
  min_lev = 5,
  weight = 35,
  allow_events = false,
  Create = Generator.generate_arena_dungeon,
})

LevelTypes({
  id = "battle",
  min_lev = 11,
  weight = 50,
  allow_events = false,
  Create = inferno.Generator.generate_battlefield_dungeon,
})

LevelTypes({
  id = "swamp",
  min_lev = 13,
  weight = 60,
  Create = inferno.Generator.generate_swamp_dungeon,
})

LevelTypes({
  id = "hive",
  min_lev = 9,
  weight = 55,
  Create = inferno.Generator.generate_hive_dungeon,
})

LevelTypes({
  id = "glacier",
  min_lev = 5,
  weight = 5,
  allow_events = false,
  Create = inferno.Generator.generate_glacier_dungeon,
})

LevelTypes({
  id = "telemaze",
  min_lev = 12,
  weight = 5,
  allow_events = false,
  allow_full_rooms = false,
  Create = inferno.Generator.generate_telemaze_dungeon,
})

LevelTypes({
  id = "ruins",
  min_lev = 5,
  weight = 80,
  Create = inferno.Generator.generate_ruins_dungeon,
})