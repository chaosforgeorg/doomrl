-- Inferno Generator module
inferno.Generator = {}

local cardinal_dirs = {coord.new(1, 0), coord.new(0, 1), coord.new(-1, 0), coord.new(0, -1)}

-- For convenience, a list of Generator hooks
inferno.Generator.hooks = {
  "OnKill",
  "OnKillAll",
  "OnEnter",
  "OnExit",
  "OnTick",
}

-- Schedules a hook to be included in the current (random) level.
-- Multiple hooks that run off the same event are okay.
-- Must be a hook that has been loaded into the Serialize system.
function inferno.Generator.register_hook(hook, id, ...)
  local env = inferno.Generator.hook_environments[hook]
  env:instantiate(nil, id, ...)
end

-- Resolves all hooks that have been scheduled for inclusion in the current level.
function inferno.Generator.create_hooks()
  for _, hook in ipairs(inferno.Generator.hooks) do
    local env = inferno.Generator.hook_environments[hook]
    if not env:empty() then
      Generator[hook] = function(...)
        local retn
        for _, f in env:entries() do
          retn = f(...)
        end
        return retn
      end
    end
  end
end

-- Returns a serializable structure representing the current state of the current random level.
function inferno.Generator.serialize()
  local data = {}
  data.level = Level.serialize()
  data.hooks = {}
  for _, hook in ipairs(inferno.Generator.hooks) do
    data.hooks[hook] = inferno.Generator.hook_environments[hook]:serialize()
  end
  return data
end

-- Restores a state returned by inferno.Generator.serialize().
function inferno.Generator.load(data)
  Level.load(data.level)
  for _, hook in ipairs(inferno.Generator.hooks) do
    inferno.Generator.hook_environments[hook] = Serialize.load_environment(data.hooks[hook])
  end
  inferno.Generator.create_hooks()
end

function inferno.Generator.clear()
  inferno.Generator.reset()
  Level.clear()
  for _, hook in ipairs(inferno.Generator.hooks) do
    Generator[hook] = function() end -- need stubs if hooks were previously declared
  end
end

-- Resets the inferno Generator; should be called before creating a new random level.
function inferno.Generator.reset()
  Generator.reset()
  inferno.Generator.hook_environments = {}
  for _, hook in ipairs(inferno.Generator.hooks) do
    inferno.Generator.hook_environments[hook] = Serialize.create_environment()
  end
  if not player.basement_restore_state then
    inferno.Generator.reset_basements()
  end
end

-- Standard random level generation function of the inferno module.
function inferno.Generator.generate()
  if player.basement_restore_state then
    inferno.Generator.reset()
    inferno.Generator.load(player.basement_restore_state)
    Generator.OnEnter = nil
    player.basement_restore_state = false
    local c = coord.new(player.basement_x, player.basement_y)
    Level.drop_being(player, c)
    Level[c] = "floor"
    ui.msg("The stairs collapse behind you.")
    return
  end
  local level = Level.danger_level
  local roll
  inferno.Generator.reset()
  local level_type = inferno.Generator.roll_level_type(level)
  if inferno.cheat and inferno.force_level_type then
    level_type = level_types[inferno.force_level_type]
  end
  inferno.level_type = level_type.id
  level_type.Create()
  local allow_events
  if level_type.allow_events ~= nil then
    allow_events = level_type.allow_events
  else
    allow_events = true
  end
  if allow_events and math.random(100) <= math.min(Level.danger_level / 2, 20) then
    inferno.Generator.roll_event()
  end
  if inferno.debug and inferno.debug_basement then
    --inferno.Generator.roll_event()
    --Generator.level_events["soul_keeper"].OnGenerate()
    inferno.Generator.generate_basement(inferno.debug_basement)
  end
  inferno.Generator.place_basements()
  if math.random(25) == 1 then
    inferno.Generator.generate_teleport_pair()
  end
  LurkAI.auto_pickup()
  inferno.Generator.create_hooks()
end

-- inferno.Generator.wrap(FUNCTION f, BOOLEAN allow_rivers)

-- Calls f but ignores any calls to non-layout generator functions.
-- Rivers are optionally allowed.
do
  local helpers = {
    {module = Generator, name = "generate_rivers"},
    {module = Generator, name = "generate_fluids"},
    {module = Generator, name = "generate_barrels"},
    {module = Generator, name = "generate_stairs"},
    {module = Generator, name = "generate_special_stairs"},
    {module = Generator, name = "handle_rooms"},
    {module = Generator, name = "place_player"},
    {module = Level, name = "flood_monsters"},
    {module = Level, name = "flood_monster"},
    {module = Level, name = "flood_items"},
    {module = player, name = "add_history"},
    {module = ui, name = "msg"},
  }
  function inferno.Generator.wrap(f, allow_rivers)
    local usual = {}
    for _, helper in ipairs(helpers) do
      usual[helper.name] = helper.module[helper.name]
      if not allow_rivers or helper.name ~= "generate_rivers" then
        helper.module[helper.name] = function() end
      end
    end
    f()
    for _, helper in ipairs(helpers) do
      helper.module[helper.name] = usual[helper.name]
    end
  end
end

do
  local usual_generate_caves_dungeon = Generator.generate_caves_dungeon
  function Generator.generate_caves()
    inferno.Generator.wrap(usual_generate_caves_dungeon)
  end
end

function inferno.Generator.place_trees()
  local flor = styles[Level.style].floor
  Level.scatter(area.FULL, flor, "treeb", 25 + math.random(25))
end

function inferno.Generator.roll_cave_monster()
  local dlevel = Level.danger_level
  local roll = dlevel + (DIFFICULTY - 2) * 3 + math.random(5) - 3
  local monster
  if roll < 6 then 
    monster = "lostsoul"
  elseif roll < 11 then
    monster = "demon"
    if math.random(3) == 1 then
      monster = "spectre"
    end
  elseif roll < 16 then
    monster = "cacodemon"
  else
    monster = "arachno"
  end
  if DIFFICULTY >= 3 and roll > 25 and math.random(5) == 1 then
    monster = "pain"
  end
  if roll >= 33 and math.random(3) == 1 then
    monster = "ndemon"
  end
  if roll >= 37 and math.random(2) == 1 then
    monster = "ncacodemon"
  end
  if roll >= 42 and math.random(2) == 1 then
    monster = "narachno"
  end
  if roll >= 42 and monster == "arachno" then
    monster = "narachno"
  end
  if roll >= 52 and DIFFICULTY >= 3 and math.random(4) == 1 then
    monster = "nskull"
  end
  if roll >= 60 and (monster == "pain" or math.random(20) == 1) and DIFFICULTY >= 4 then
    monster = "npain" -- prepare to die!
  end
  if roll >= 62 and DIFFICULTY >= 3 and math.random(6) == 1 then
    monster = "ember"
  end
  if roll >= 100 and DIFFICULTY >= 4 and math.random(20) == 1 then
    monster = "arch"
  end
  return monster
end

function inferno.Generator.roll_warren_monster()
  local dlevel = Level.danger_level
  local roll = dlevel + (DIFFICULTY - 2) * 3 + math.random(5) - 3
  local monster
  if roll < 10 then 
    monster = "imp"
  elseif roll < 14 then
    monster = "hydra"
  elseif roll < 18 then
    monster = "mist"
  else
    monster = "baron"
  end
  if roll >= 33 and math.random(3) == 1 then
    monster = "nimp"
  end
  if roll >= 37 and math.random(2) == 1 then
    monster = "nhydra"
  end
  if roll >= 42 and math.random(2) == 1 then
    monster = "narachno"
  end
  if roll >= 42 and monster == "arachno" then
    monster = "narachno"
  end
  if roll >= 52 and DIFFICULTY >= 3 and math.random(4) == 1 then
    monster = "nskull"
  end
  if roll >= 60 and (monster == "pain" or math.random(20) == 1) and DIFFICULTY >= 4 then
    monster = "npain" -- prepare to die!
  end
  if roll >= 62 and DIFFICULTY >= 3 and math.random(6) == 1 then
    monster = "nmist"
  end
  if roll >= 100 and DIFFICULTY >= 4 and math.random(20) == 1 then
    monster = "arch"
  end
  return monster
end

function Generator.flood_fill(start, target)
  local cell = Level[start]
  if cell == target then return end
  local fringe = {start}
  while #fringe > 0 do
    local c = table.remove(fringe, #fringe)
    local ccell = Level[c]
    if ccell == cell then
      Level[c] = target
      for c1 in area.around(c, 1):clamped(area.FULL)() do
        if c1 ~= c then
          table.insert(fringe, c1:clone())
        end
      end
    end
  end
end

-- Shamelessly pilfered from KK (then modified)
function inferno.Generator.drunkard_walk( start, steps, cell, ignore, break_on_edge, drunk_area)
  if steps <= 0 then return end
  ignore = ignore or {}
  drunk_area = drunk_area or area.FULL_SHRINKED
  local c = coord.clone( start )
  for i=1,steps do
    if not drunk_area:contains( c ) then
      if break_on_edge then return end
      drunk_area:clamp_coord( c )
    end
    if (not ignore) or (not ignore[ Generator.get_cell( c ) ]) then
      Generator.set_cell( c, cell )
    end
    coord.random_shift( c )
  end
end

function inferno.Generator.generate_swamp_dungeon()
  core.log("inferno.Generator.generate_swamp_dungeon()")
  local inner = area.FULL:shrinked(2)
  local wall_cell = styles[Level.style].wall
  local floor_cell = styles[Level.style].floor
  Level.fill("lava")
  inferno.Generator.drunkard_walk( coord.new( 38, 10 ), math.random(40)+100, floor_cell, nil, true, inner )
  for count = 1, 15 do
    inferno.Generator.drunkard_walk( inner:random_coord(), math.random(40) + 100, floor_cell, nil, true, inner)
  end
  Generator.flood_fill(coord.new(1, 1), "acid")
  Generator.transmute(floor_cell, wall_cell)
  Generator.transmute("lava", wall_cell)
  for count = 1, 25 do
    local c
    repeat
      c = area.FULL_SHRINKED:random_coord()
    until c and Generator.cross_around(c, {cells[floor_cell].nid, cells[wall_cell].nid}) and Generator.cross_around(c, {cells.floor.nid, cells.acid.nid})
    Generator.drunkard_walk(c, math.random(40) + 100, floor_cell, nil, true)
  end
  Generator.restore_walls("pacid")
  inferno.Generator.place_trees()
  Level.flood_items(math.min(13 + math.floor(Level.danger_level / 50), 18))
  Level.flood_monsters(Generator.being_weight(), nil, {"acid", "flying"})
  Level.drop("rocket", math.random(3), true)
  if math.random(DIFFICULTY) == 1 then
    Level.drop("epack")
  end
  ui.msg("It smells like something rotten.")
  Generator.generate_stairs()
  Generator.generate_special_stairs()
  Generator.place_player()
end

--TODO: probably unused now
function inferno.Generator.generate_caves_dungeon()
  core.log("inferno.Generator.generate_caves_dungeon()")
  Generator.generate_caves()
  local amount = math.floor(Generator.being_weight() * 0.67)
  local monster = inferno.Generator.roll_cave_monster()
  Level.flood_items(10)
  Level.flood_monster(monster, amount)
  ui.msg( "Twisted passages carry the smell of death..." )
  Generator.generate_stairs()
  Generator.generate_special_stairs()
  Generator.place_player()
end

-- Counts the number of cell in room
inferno.Generator.find = function(room, cell)
  local n = 0
  for c in room() do
    if Level[c] == cell then
      n = n + 1
    end
  end
  return n
end

inferno.Generator.check_room_collisions = function(interior)
  local function interval_check(a, b, c, d)
    return c <= a and a <= d or c <= b and b <= d or a <= c and c <= b or a <= d and d <= b
  end
  for _, room in ipairs(Generator.room_list) do
    if interval_check(interior.a.x, interior.b.x, room.a.x, room.b.x) and interval_check(interior.a.y, interior.b.y, room.a.y, room.b.y) then
      return false
    end
  end
  return true
end

area.is_corner = function(self, c)
  return (self.a.x == c.x or self.b.x == c.x) and (self.a.y == c.y or self.b.y == c.y)
end

inferno.Generator.place_hybrid_caves_room = function(room)
  if not inferno.Generator.check_room_collisions(area.expanded(room)) then
    return false
  end
  local wall_cell = styles[Level.style].wall
  local floor_cell = styles[Level.style].floor
  local x0 = room.a.x - 1
  local y0 = room.a.y - 1
  local x1 = room.b.x + 1
  local y1 = room.b.y + 1
  local dx = {1, 0, -1, 0}
  local dy = {0, 1, 0, -1}
  local lens = {x1 - x0 + 1, y1 - y0 + 1, x1 - x0 + 1, y1 - y0 + 1 - 1}
  local parts = {}
  local current_part = nil
  local x, y = x0, y0
  local first = true
  local first_part = false
  local all_hazard = true
  local surrounding = room:expanded(1)
  for side = 1, 4 do
    for i = 1, lens[side] do
      local c = coord.new(x, y)
      if x < 1 or y < 1 or x > 78 or y > 20 or Level[c] == wall_cell then
        current_part = nil
      else
        if not current_part then
          current_part = {}
          table.insert(parts, current_part)
          if first then
            first_part = true
          end
        end
        all_hazard = all_hazard and cells[Level[c]].flag_set[CF_HAZARD]
        -- Parts are used to add doors; we don't add doors in corners.
        if not surrounding:is_corner(c) then
          table.insert(current_part, c)
        end
      end
      x = x + dx[side]
      y = y + dy[side]
      first = false
    end
    x = x - dx[side]
    y = y - dy[side]
  end
  -- Merge the first and last parts if they are contiguous
  if current_part and first_part and current_part ~= parts[1] then
    for _, c in ipairs(parts[1]) do
      table.insert(current_part, c)
    end
    table.remove(parts, 1)
  end
  -- If there are no parts, the room would be inaccessible.
  -- If there are too many parts, the room has a silly number of doors.
  if #parts == 0 or #parts > 4 then
    return false
  end
  -- If the room is completely surrounded by rock/lava, this is bad.
  if all_hazard then
    return false
  end
  -- If a part is empty, it was corner only. This is also bad.
  for _, part in ipairs(parts) do
    if #part == 0 then
      return false
    end
  end
  -- Place the room.
  Level.fill(wall_cell, room)
  Level.fill(floor_cell, area.shrinked(room))
  -- Place a door in each part.
  for _, part in ipairs(parts) do
    local c
    -- Make some attempt not to open out into lava.
    for try = 1, 10 do
      c = table.random_pick(part)
      if not cells[Level[c]].flag_set[CF_HAZARD] then
        break
      end
    end
    local x, y = c.x, c.y
    -- If the coord is orthogonally adjacent to the corner, nudge it.
    if x == room.b.x then
      x = x - 1
    elseif x == room.a.x then
      x = x + 1
    end
    if y == room.b.y then
      y = y - 1
    elseif y == room.a.y then
      y = y + 1
    end
    -- Move the coord inward to be on the wall.
    local door_pos = coord.new(x, y)
    room:clamp_coord(door_pos)
    Level[door_pos] = "door"
  end
  -- It is possible that two doors are next to each other. Because of the
  -- way parts work, this is only possible when one of the doors was a nudged
  -- corner door. In this case, it is safe to remove the "unnudged" door.
  for corner in room:corners() do
    for _, d in ipairs(cardinal_dirs) do
      local adj = corner + d
      if Level[adj] == "door" then
        for _, d2 in ipairs(cardinal_dirs) do
          local adjadj = adj + d2
          if Level[adjadj] == "door" then
            Level[adjadj] = wall_cell
          end
        end
      end
    end
  end
  Generator.add_room(room)
  return true
end

-- Based on Generator.generate_caves_dungeon
function inferno.Generator.generate_hybrid_caves_dungeon()
  core.log("inferno.Generator.generate_hybrid_caves_dungeon")
  Generator.generate_caves()
  local room_count = math.random(3)
  if math.random(10) == 10 then
    -- Fewer rooms will actually generate...
    room_count = 10
  end
  local dim_min = coord.new(6, 5)
  local dim_max = coord.new(15, 11)
  for tries = 1, 10 do
    if room_count == 0 then
      break
    end
    if inferno.Generator.place_hybrid_caves_room(area.FULL_SHRINKED:random_subarea(coord.random(dim_min, dim_max))) then
      room_count = room_count - 1
    end
  end
  local amount = math.floor(Generator.being_weight() * 0.67)
  local monster = inferno.Generator.roll_cave_monster()
  Generator.handle_rooms()
  for _, room in ipairs(Generator.room_list) do
    if not room.monsters then
      local bg = inferno.Generator.random_group()
      inferno.Generator.summon_group(bg, room)
    end
  end
  Level.flood_items(12)
  Level.flood_monster(monster, amount)
  Generator.generate_stairs()
  Generator.generate_special_stairs()
  Generator.place_player()
end

function inferno.Generator.generate_braid_dungeon()
  core.log("inferno.Generator.generate_braid_dungeon()")
  local wall_cell = styles[Level.style].wall
  local floor_cell = styles[Level.style].floor
  local dim_max_small = coord.new(12, 4)
  local dim_min_small = coord.new(4, 2)
  local dim_max_large = coord.new(9, 9)
  local dim_min_large = coord.new(14, 10)
  Level.fill(wall_cell, area.FULL_SHRINKED)
  local begin = true
  local amount = 15 + math.random(7)
  for i = 1, 350 do
    if amount == 0 then
      break
    end
    local dim_max, dim_min
    if amount % 2 == 0 then
      dim_max = dim_max_small
      dim_min = dim_min_small
    else
      dim_max = dim_max_large
      dim_min = dim_min_large
    end
    local room = area.random_subarea(area.FULL_SHRINKED, coord.random(dim_min, dim_max))
    local overlap = inferno.Generator.find(room, floor_cell)
    if begin or (overlap >= 1 and overlap <= 12) then
      begin = false
      Level.fill(floor_cell, room)
      if amount % 2 == 1 and inferno.Generator.check_room_collisions(room) then
        Generator.add_room(area.expanded(room))
      end
      amount = amount - 1
    end
  end
  --Generator.generate_fluids()
  inferno.Generator.generate_wall_safe_fluids()
  Generator.generate_barrels()
  Generator.handle_rooms()
  Level.flood_monsters(Generator.being_weight() * 0.8)
  Level.flood_items(Generator.item_amount())
  Generator.generate_stairs()
  Generator.generate_special_stairs()
  Generator.place_player()
end

-- Iterators over the edges of an area continuously.
inferno.Generator.border_iterator = function(area, start)
  start = start or area:random_edge_coord()
  local function nextc(c)
    if c.x == area.a.x and c.y > area.a.y then
      c.y = c.y - 1
    elseif c.y == area.a.y and c.x < area.b.x then
      c.x = c.x + 1
    elseif c.x == area.b.x and c.y < area.b.y then
      c.y = c.y + 1
    else
      c.x = c.x - 1
    end
    return c
  end
  local c = nextc(start:clone())
  local done = false
  return function()
    if done then
      return nil
    end
    if c == start then
      done = true
    end
    return nextc(c)
  end
end

-- Based of Generator.drunkard_walk
inferno.Generator.bloody_walk = function(start, steps)
  if steps <= 0 then
    return
  end
  local bloody_area = area.FULL
  local c = start:clone()
  for i = 1, steps do
    if not bloody_area:contains(c) then
      bloody_area:clamp_coord(c)
    end
    inferno.Generator.bloodify(c, true)
    local dir = table.random_pick(cardinal_dirs)
    c.x = c.x + dir.x
    c.y = c.y + dir.y
  end
end

-- Inspired by the Halls of Carnage and Generator.generate_city_dungeon
function inferno.Generator.generate_battlefield_dungeon()
  core.log("inferno.Generator.generate_battlefield_dungeon()")
  local wall_cell = styles[Level.style].wall
  local floor_cell = styles[Level.style].floor
  local door_cell = "door"
  local dim_max = coord.new(11, 9)
  local dim_min = coord.new(6, 5)
  local tries = 250
  -- We fill the whole level with floor so that scan will allow rooms to be
  -- placed along the outer wall of the level (which will be restored later)
  Level.fill("floor")
  -- River before rooms so that they will not overlap
  if math.random(5) == 1 then
    -- Single vertical river only.
    Generator.generate_rivers(false, false)
  end
  for i = 1, tries do
    local room = area.random_subarea(area.FULL, coord.random(dim_min, dim_max))
    if Level.scan(room, floor_cell) then
      room:shrink(1)
      local dims = room:dim()
      -- allow rooms to touch the edge of the map
      if room.a.x == 2 then
        room.a = coord.new(1, room.a.y)
      end
      if room.a.y == 2 then
        room.a = coord.new(room.a.x, 1)
      end
      if room.b.x == 77 then
        room.b = coord.new(78, room.b.y)
      end
      if room.b.y == 19 then
        room.b = coord.new(room.b.x, 20)
      end
      Level.fill(wall_cell, room)
      local interior = room:shrinked(1)
      Level.fill("blood", interior)
      -- add doors
      local doors = math.random(3)
      if doors == 3 and dims.x * dims.y <= 25 then
        doors = 1
      end
      for j = 1, doors do
        local door_pos = room:random_inner_edge_coord()
        -- stop doors on map edge (to avoid inaccessible rooms)
        if door_pos.x == 1 then
          door_pos.x = room.b.x
        end
        if door_pos.y == 1 then
          door_pos.y = room.b.y
        end
        if door_pos.x == 78 then
          door_pos.x = room.a.x
        end
        if door_pos.y == 20 then
          door_pos.y = room.a.y
        end
        if Generator.cross_around(door_pos, cells[door_cell].nid) == 0 then
          Level[door_pos] = door_cell
        end
      end
      -- implement damage
      local len = 2 + math.random(4)
      local broken = false
      local last
      for c in inferno.Generator.border_iterator(room) do
        last = c
        if broken then
          len = len - 1
          if len <= 0 and Level[c] ~= door_cell then
            broken = false
            len = 2 + math.random(8)
          else
            Level[c] = floor_cell
          end
        else
          len = len - 1
          if len <= 0 then
            broken = true
            if Level[c] == door_cell then
              Level[c] = floor_cell
            end
            len = 4 + math.random(5)
          end
        end
      end
      Level[last] = wall_cell
      -- Possibly add some rockets
      if math.random(5) == 1 then
        Level.area_drop(interior, "rocket", 2 + math.random(3))
      end
    end
  end
  Generator.restore_walls(wall_cell, true)
  Generator.transmute("blood", floor_cell)
  -- Blood scattering
  for i = 1, 15 + math.random(5) do
    inferno.Generator.bloody_walk(area.FULL:random_coord(), 5 + math.random(12))
  end
  local area_near = area.new(coord.new(1, 1), coord.new(38, 20))
  local area_far = area.new(coord.new(39, 1), coord.new(78, 20))
  local swap = false
  if math.random(2) == 1 then
    area_near, area_far = area_far, area_near
    swap = true
  end
  Generator.generate_fluids()
  Generator.generate_barrels()
  Level.flood_monsters(Generator.being_weight() * 0.5, area_near, {"former"})
  Level.flood_monsters(Generator.being_weight() * 0.5, area_far)
  Level.flood_items(10)
  local player_start, stairs_loc
  local count = 0
  repeat
    player_start = Generator.safe_empty_coord()
    count = count + 1
  until count > 1000 or player_start.x <= 11
  count = 0
  repeat
    stairs_loc = Generator.safe_empty_coord()
    count = count + 1
  until count > 1000 or stairs_loc.x > 67
  if swap then
    player_start, stairs_loc = stairs_loc, player_start
  end
  Level[stairs_loc] = "stairs"
  Level.drop_being(player, player_start)
end

-- Based on Generator.generate_archi_dungeon
function inferno.Generator.generate_archi_room_dungeon()
  core.log("inferno.Generator.generate_archi_room_dungeon()")
  local wall_cell = styles[Level.style].wall
  local floor_cell = styles[Level.style].floor
  local door_cell = cells.door.nid
  local walls = {wall_cell}
  local translation = {
    ["X"] = wall_cell,
    ["."] = floor_cell,
    ["+"] = "door"}
  Level.fill(wall_cell)
  local dim = coord.new(18, 12)
  for bx = 1, 4 do
    for by = 1, 3 do
      local block = table.random_pick(Generator.archi_data)
      local pos = coord.new((bx - 1) * 18 + 3, (by - 1) * 6 + 1)
      local tile  = Generator.tile_new( block, translation )
      tile:flip_random()
      Generator.tile_place( pos, tile )
    end
  end
  for bx = 1, 4 do
    local by = math.random(2)
    local pos = coord.new((bx - 1) * 18 + 3, (by - 1) * 6 + 1)
    local room = area.new(pos, pos + dim)
    Generator.add_room(room)
  end
  for c in area.coords(area.FULL_SHRINKED) do
    if Generator.get_cell(c) == door_cell and 2 < Generator.cross_around(c, walls) then
      Generator.set_cell(c, wall_cell)
    end
  end
  Generator.restore_walls(wall_cell)
  if math.random(4) == 1 then
    Generator.generate_rivers(true, true)
  end
  Generator.generate_fluids()
  Generator.generate_barrels()
  Generator.handle_rooms()
  Level.flood_monsters(Generator.being_weight())
  Level.flood_items(Generator.item_amount())
  Generator.generate_stairs()
  Generator.generate_special_stairs()
  Generator.place_player()
end

inferno.Generator.generate_wall_safe_fluids = function()
  local wall_cell = cells[styles[Level.style].wall].nid
  local ignore = {[wall_cell] = true}
  local level = Level.danger_level
  if level < 6 then
    Generator.drunkard_walks(math.random(3) - 1, math.random(40) + 2, "water", ignore)
  elseif level < 11 then
    Generator.drunkard_walks(math.random(3) - 1, math.random(40) + 2, "acid", ignore)
  elseif level < 16 then
    Generator.drunkard_walks(math.random(5) - 1, math.random(50) + 2, "lava", ignore)
  else
    Generator.drunkard_walks(math.random(5) + 3, math.random(40) + 2, "lava", ignore)
  end
end

function inferno.Generator.generate_ruins_dungeon()
  core.log("inferno.Generator.generate_ruins_dungeon()")
  local wall_cell = styles[Level.style].wall
  local floor_cell = styles[Level.style].floor

  local tries = 40
  local dim_max = coord.new(13, 9)
  local dim_min = coord.new(5, 3)
  local city = area.FULL_SHRINKED

  Level.fill(wall_cell)
  
  local last_room = nil
  local door_mem = {}
  for i=1,tries do
    local dim_x = math.random((dim_max.x - dim_min.x) / 2 + 1) * 2 + dim_min.x - 2
    local dim_y = math.random((dim_max.y - dim_min.y) / 2 + 1) * 2 + dim_min.y - 2
    local x0 = 2 * math.random(38 - (dim_x - 1) / 2)
    local y0 = 2 * math.random(9 - (dim_y - 1) / 2)
    local x1 = x0 + dim_x - 1
    local y1 = y0 + dim_y - 1
    local room = area.new(x0, y0, x1, y1)
    room:expand(1)
    if Level.scan(room,wall_cell) then
      room:shrink(1)
      Generator.fill(floor_cell, room)
      room:expand(1)
      Generator.add_room(room)
      if last_room then
        local function random_even_coord(room, dims)
          local w = dims.x
          local h = dims.y
          -- room.a.x + 1 .. room.a.x + w - 2
          local x = room.a.x - 1 + 2 * math.random((w - 1) / 2)
          local y = room.a.y - 1 + 2 * math.random((h - 1) / 2)
          return coord.new(x, y)
        end
        local start = random_even_coord(room, room:dim())
        local finish = random_even_coord(last_room, last_room:dim())
        while start ~= finish do
          if start.x < finish.x then
            start.x = start.x + 1
          elseif start.x > finish.x then
            start.x = start.x - 1
          elseif start.y < finish.y then
            start.y = start.y + 1
          else
            start.y = start.y - 1
          end
          local in_room = false
          for _, r in ipairs(Generator.room_list) do
            if r:contains(start) then
              in_room = true
              break
            end
          end
          if in_room then
            if Level[start] == wall_cell then
              Level[start] = "door"
              door_mem[start:clone()] = {}
            end
            if not room:contains(start) then
              --Level[start] = "lava"
              break
            end
          else
            Level[start] = floor_cell
          end
        end
      end
      last_room = room
    end
  end
  
  for start, posts in pairs(door_mem) do
    for _, c in ipairs({coord.new(1, 0), coord.new(-1, 0), coord.new(0, 1), coord.new(0, -1)}) do
      local post = start + c
      if Level[post] == wall_cell then
        table.insert(posts, post)
      end
    end
  end
  
  local amount = 1 + math.random(3); local step = math.random(20)+10
  --drunk(8,  math.random(30)+15, floor_cell)
  --drunk(amount, step,   fluid)
  Generator.contd_drunkard_walks(14, math.random(30) + 15, "water", {floor_cell}, {wall_cell}, nil, true)
  Generator.contd_drunkard_walks(10, math.random(30) + 15, "acid", {"water"}, {wall_cell}, nil, true)
  Generator.transmute("water", "floor")
  Generator.contd_drunkard_walks(8, math.random(30) + 15, "water", {"acid"}, {wall_cell}, nil, true)
  Generator.transmute("acid", "floor")
  Generator.contd_drunkard_walks(amount, step, "lava", {"water"}, {wall_cell}, nil, true)
  Generator.transmute("water", "floor")
  
  for c, posts in pairs(door_mem) do
    if Level[c] == "door" then
      for _, post in ipairs(posts) do
        Level[post] = wall_cell
      end
    end
  end
  
  ui.msg("The air here is stale.")
  
  Generator.handle_rooms(50)
  
  Level.flood_items(Generator.item_amount() * 1.4)
  Level.flood_monsters(Generator.being_weight(), nil, {"bone"})
  
  Generator.generate_stairs()
  Generator.generate_special_stairs()
  Generator.place_player()
end

table.insert(styles, {
  floor = "floor", wall = "iwall", door="door", odoor = "odoor"
})

inferno.Generator.ice_style = #styles

function inferno.Generator.generate_glacier_dungeon()
  core.log("inferno.Generator.generate_glacier_dungeon()")
  Level.danger_level = Level.danger_level + 2
  Level.fill("iwall")
  local tries = 400
  local dim_max = coord.new(14, 10)
  local dim_min = coord.new(5, 5)
  local city = area.FULL:shrinked(2)
  for i=1,tries do
    local room = area.random_subarea(city, coord.random(dim_min, dim_max))
    if Level.scan(room,cells.iwall.nid) then
      Generator.fill("iwall", room)
      room:shrink(1)
      Generator.fill("floor", room)
      Generator.add_room(room:expanded())
    end
  end
  
  ui.msg("This place chills you to the bone.")
  
  rawset(Level, "style", inferno.Generator.ice_style)
  Generator.handle_rooms(20)
  rawset(Level, "style", nil)
  Level.flood_items(Generator.item_amount())
  Level.flood_monsters(1.1 * Generator.being_weight())
  
  Generator.generate_stairs()
  Generator.generate_special_stairs()
  Generator.place_player()
  Level.drop_item("shotgun", player:get_position())
  Level.drop_item("shell", player:get_position())
  Level.drop_item("shell", player:get_position())
  Level.drop_item("shell", player:get_position())
end

function inferno.Generator.generate_telemaze_dungeon()
  core.log("inferno.Generator.generate_telemaze_dungeon()")
  Level.danger_level = Level.danger_level + 2
  local wall = styles[Level.style].wall
  local flor = styles[Level.style].floor
  local rms = {}
  Level.fill(wall)
  local tries = 400
  local dim_max = coord.new(25, 14)
  local dim_min = coord.new(9, 6)
  local city = area.FULL:shrinked(2)
  local room_count = 3 + math.random(2)
  for i=1,tries do
    if #rms >= room_count then
	  break
	end
    local room = area.random_subarea(city, coord.random(dim_min, dim_max))
    if Level.scan(room,cells[wall].nid) then
      room:shrink(1)
      Generator.fill(flor, room)
      Generator.add_room(room:expanded())
      rms[#rms + 1] = room
    end
  end
  
  Generator.handle_rooms(80)
  
  --[[
  local children = {}
  local parents = {}
  
  for _, rm in ipairs(rms) do
    children[rm] = {}
    parents[rm] = {}
  end
  ]]
  
  local targets = {}
  
  local function connect(r1, r2)
    local c1
    local tries = 100
    repeat
      c1 = Generator.random_empty_coord({EF_NOITEMS, EF_NOBEINGS, EF_NOBLOCK, EF_NOTELE, EF_NOHARM, EF_NOSPAWN}, r1)
      tries = tries - 1
    until not Generator.is_blocker(c1) or tries < 0
    if tries < 0 then return false end
    local c2 = Generator.random_empty_coord({EF_NOITEMS, EF_NOBEINGS, EF_NOBLOCK, EF_NOTELE, EF_NOHARM, EF_NOSPAWN}, r2)
    if c2 and c2 then
      local it = Level.drop_item("teleport", c1)
      if it then
        it.target = c2
        Level.light[c2][LFNOSPAWN] = true
		table.insert(targets, c2)
        -- table.insert(children[r1], r2)
        -- table.insert(parents[r2], r1)
        return true
      end
    end
    return false
  end
  
  table.shuffle(rms)
  
  -- Make sure all rooms lead to rms[1]
  for i = 2, #rms do
    local target = math.random(i - 1)
    connect(rms[i], rms[target])
  end
  
  -- Shuffule again leaving rms[1] fixed
  for i = 2, #rms do
    local j = (i - 1) + math.random(#rms - (i - 1))
    rms[i], rms[j] = rms[j], rms[i]
  end
  
  -- Make sure rms[1] leads to all rooms
  for i = 2, #rms do
    local source = math.random(i - 1)
    connect(rms[source], rms[i])
  end
    
  ui.msg("Who the hell built this place!?!")
  
  Level.flood_items(Generator.item_amount())
  
  Generator.place_player()
  
  Level.flood_monsters(0.75 * Generator.being_weight())
  
  Generator.generate_stairs()
  Generator.generate_special_stairs()
  
  for _, target in ipairs(targets) do
    Level.light[target][LFNOSPAWN] = false
  end

end

function inferno.Generator.generate_hive_dungeon()
  core.log("inferno.Generator.generate_hive_dungeon()")
  local wall_cell = styles[Level.style].wall
  local floor_cell = styles[Level.style].floor
  for count = 1, 450 + math.random(200) do
    local c = area.FULL_SHRINKED:random_coord()
    if Level[c] == floor_cell then
      if Generator.cross_around(c, cells[wall_cell].nid) <= 1 then
        Level[c] = wall_cell
      end
    end
  end
  
  inferno.Generator.generate_scattered_fluids()
  
  if math.random(5) <= 2 then
    Generator.generate_rivers(true, true)
  end
  
  Level.flood_items(Generator.item_amount())
  
  local monster = inferno.Generator.roll_warren_monster()
  Level.flood_monster(monster, Generator.being_weight())
  
  local melee = "demon"
  if DIFFICULTY >= 3 then
    melee = "spectre"
  end
  
  Level.summon(melee, 1 + DIFFICULTY + math.random(3))
  
  ui.msg("Hungry eyes peer at you from the darkness.")
  
  Generator.generate_stairs()
  Generator.generate_special_stairs()
  Generator.place_player()
end

function inferno.Generator.roll_fluid()
  local roll = math.random(math.min(Level.danger_level, 30))
  if roll <= 5 then
    return "water"
  elseif roll <= 10 then
    return "acid"
  else
    return "lava"
  end
end

function inferno.Generator.generate_scattered_fluids()
  local fluid = inferno.Generator.roll_fluid()
  Generator.drunkard_walks(math.random(6) + 7, math.random(17) + 5, fluid)
end

inferno.Generator.summon_group = function(bg_proto, a, b)
  local danger = 0
  if not b then
    b = area.FULL
  end
  local expandable = not a
  if not a then
    local c = Generator.random_empty_coord({EF_NOBEINGS, EF_NOBLOCK, EF_NOTELE, EF_NOHARM, EF_NOSPAWN}, b)
    a = area.around(c, bg_proto.size)
  end
  for _, being_group_proto in ipairs(bg_proto.beings) do
    local count = resolverange(being_group_proto.amount or 1)
    for i = 1, count do
      local x = Generator.random_empty_coord({EF_NOBEINGS, EF_NOBLOCK, EF_NOTELE, EF_NOHARM, EF_NOSPAWN}, a)
      if x then
        local be = Level.drop_being(being_group_proto.being, x)
        if be then
          danger = danger + (be.__proto.danger_override or be.__proto.danger)
        end
      elseif expandable then
        a:expand()
      end
    end
  end
  return danger
end

inferno.Generator.random_group = function(amount)
  return Level.roll_weight(inferno.Group.being_list())
end

inferno.Generator.flood_monsters = function(amount, flood_area, boost)
  local list, sum
  amount = amount * 1.9
  if not flood_area then
    flood_area = area.FULL
  end
  if boost then
    if type(boost) ~= "table" then
      boost = {boost}
    end
    list, sum = inferno.Generator.boosted_list(boost)
  else
    list, sum = inferno.Group.being_list()
  end
  if sum > 0 then
    while amount > 0 do
      local bg_proto = Level.roll_weight(list, sum)
      amount = amount - inferno.Generator.summon_group(bg_proto, nil, flood_area)
    end
  end
end

Level.flood_monsters = inferno.Generator.flood_monsters

inferno.Generator.boosted_list = function(types)
  local list, sum = inferno.Group.being_list()
  local new_list = table.copy(list)
  for _, bg_proto in ipairs(list) do
    for _, boost in ipairs(types) do
      if bg_proto[boost] then
        table.insert(new_list, bg_proto)
        sum = sum + bg_proto.weight
      end
    end
  end
  return new_list, sum
end

inferno.Generator.flood_monster = function(sid, amount)
  local bg = inferno.single_groups[sid]
  if not bg then
    error("Missing single group: " .. sid)
  end
  while amount > 0 do
    amount = amount - inferno.Generator.summon_group(bg)
  end
end

Level.flood_monster = inferno.Generator.flood_monster

inferno.Generator.generate_teleport_pair = function()
  core.log("inferno.Generator.generate_teleport_pair")
  local floor_cell = styles[Level.style].floor
  local floor_nid = cells[floor_cell].nid
  local pos = {}
  for tries = 1, 100 do
    if #pos == 2 then
      break
    end
    local c = Generator.random_empty_coord{EF_NOBEINGS, EF_NOBLOCK, EF_NOITEMS, EF_NOHARM, EF_NOSPAWN}
    if Generator.cross_around(c, floor_nid) >= 4 then
      if not Level.get_being(c) then
        if not Level.get_item(c) then
          table.insert(pos, c)
        end
      end
    end
  end
  if #pos < 2 then
    return
  end
  if coord.distance(pos[1], pos[2]) <= 9 then
    return
  end
  local t1 = Level.drop_item("teleport", pos[1])
  local t2 = Level.drop_item("teleport", pos[2])
  if t1 then
    t1.target = pos[2] + coord.new(0, 1)
  end
  if t2 then
    t2.target = pos[1] + coord.new(0, -1)
  end
end

-- Returns true only if the 
inferno.Generator.scan_not = function(scan_area, cell_list)
  for c in scan_area() do
    for _, cell in ipairs(cell_list) do
      if Level[c] == cell then
        return false
      end
    end
  end
  return true
end

inferno.Generator.random_corpse = function()
  local corpse_id
  repeat
    corpse_id = Level.random_being() .. "corpse"
  until cells[corpse_id]
  return corpse_id
end

Serialize.register({
  id = "blood_event_OnTick",
  Initialize = function(self) end,
  Run = function(self)
    local floor_cell = styles[Level.style].floor
    for count = 1, 1 do
      inferno.Generator.bloodify(area.FULL:random_coord())
    end
    local c = player:get_position()
    if cells[Level[c]].id == floor_cell then
      Level[c] = "blood"
    end
  end,
})

inferno.Generator.setup_blood_event = function()
  core.log("inferno.Generator.setup_blood_event")
  player:add_history("It was raining blood!")
  ui.msg("What the fuck? It's raining blood!")
  local floor_cell = styles[Level.style].floor
  for being in Level.beings() do
    if not being:is_player() and math.random(3) == 3 then
      local corpse = cells[being.__proto.corpse]
      if corpse and corpse.id == "corpse" or corpse and corpse.flag_set[CF_CORPSE] then
        local c = Generator.random_empty_coord{EF_NOBLOCK, EF_NOTELE, EF_NOHARM, EF_NOSPAWN}
        if c and cells[Level[c]].set == CELLSET_FLOORS then
          inferno.Generator.splat(c, corpse.id)
        end
      end
    end
  end
  for count = 1, 200 do
    inferno.Generator.bloodify(area.FULL:random_coord())
  end
  if DIFFICULTY >= 4 then
    Level.summon("narch")
  else
    Level.summon("arch")
  end
  if Level.danger_level + DIFFICULTY >= 19 then
    Level.summon("arch")
  end
  if Level.danger_level + DIFFICULTY >= 24 then
    Level.summon("arch")
  end
  if Level.danger_level + DIFFICULTY >= 29 then
    Level.summon("arch")
  end
  
  inferno.Generator.register_hook("OnTick", "blood_event_OnTick")
end

inferno.Generator.splat = function(c, cell, a)
  a = a or area.FULL
  for r = 1, 2 do
    for d in area.around(c, r)() do
      if coord.distance(c, d) <= r and math.random(3) <= 2 and a:contains(d) then
        inferno.Generator.bloodify(d)
      end
    end
  end
  Level[c] = cell
end

inferno.Generator.bloodify = function(c, disallow_pools)
  local cell = cells[Level[c]]
  if cell.bloodto and cell.bloodto ~= "" then
    if not (disallow_pools and cell.bloodto == "bloodpool") then
      Level[c] = cell.bloodto
    end
  end
end

-- Valid types:
--   soldier (filler)
--   melee
--   tank    (strong, hp)
--   fast    (high speed/sneaky)
--   leader  (scary, not too many)
--   striker (high damage, low? hp)
function inferno.Generator.roll_monster_type(type, bonus)
  local dbonus = {1, 2, 4, 7, 8}
  dbonus = dbonus[DIFFICULTY]
  local roll = math.random(6) + dbonus + Level.danger_level - 2 + (bonus or 0)
  if type == "soldier" then
    if roll <= 6 then
      return "former"
    elseif roll <= 12 then
      if math.random(3) == 1 then
        return "imp"
      else
        return "sergeant"
      end
    elseif roll <= 15 then
      return "captain"
    elseif roll <= 25 then
      if math.random(2) == 1 then
        return "commando"
      else
        return "knight"
      end
    else
      if math.random(3) == 1 then
        return "nimp"
      else
        return "baron"
      end
    end
  elseif type == "melee" then
    if roll <= 8 then
      return "lostsoul"
    elseif roll <= 18 then
      if math.random(2) == 1 then
        return "spectre"
      else
        return "demon"
      end
    elseif roll <= 28 then
      if math.random(4) == 1 then
        return "cinder"
      else
        return "pain"
      end
    else
      return "ndemon"
    end
  elseif type == "tank" then
    if roll <= 3 then
      if math.random(2) == 1 then
        return "imp"
      else
        return "sergeant"
      end
    elseif roll <= 9 then
      return "demon"
    elseif roll <= 18 then
      return "cacodemon"
    elseif roll <= 26 then
      return "baron"
    elseif roll <= 31 then
      if math.random(2) == 1 then
        return "asura"
      else
        return "baron"
      end
    else
      return "ncacodemon"
    end
  elseif type == "fast" then
    if roll <= 8 then
      if math.random(2) == 1 then
        return "imp"
      else
        return "lostsoul"
      end
    elseif roll <= 16 then
      if math.random(2) == 1 then
        return "imp"
      else
        return "hydra"
      end
    elseif roll <= 22 then
      if math.random(5) == 1 then
        return "cinder"
      else
        return "mist"
      end
    elseif roll <= 27 then
      return "arachno"
    elseif roll <= 35 then
      if math.random(3) == 1 then
        return "nimp"
      else
        return "arachno"
      end
    else
      return "arch"
    end
  elseif type == "leader" then
    if roll <= 6 then
      return "sergeant"
    elseif roll <= 10 then
      return "captain"
    elseif roll <= 12 then
      if math.random(5) == 1 then
        return "pain"
      else
        return "knight"
      end
    elseif roll <= 17 then
      return "baron"
    elseif roll <= 20 then
      return "mancubus"
    else
      return "arch"
    end
  elseif type == "striker" then
    if roll <= 9 then
      return "sergeant"
    elseif roll <= 12 then
      return "captain"
    elseif roll <= 18 then
      return "commando"
    elseif roll <= 25 then
      return "revenant"
    elseif roll <= 29 then
      return "arachno"
    else
      return table.random_pick{"arachno", "mancubus", "asura"}
    end
  end
  return "imp"
end