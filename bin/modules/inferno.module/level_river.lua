local corpses = {}

local function river_tick(force)
  -- Check for gibbed corpses
  local okay
  repeat
    okay = true
    for index, pos in ipairs(corpses) do
      if not Level.is_corpse(pos) then
        Level[pos] = "blood_river"
        table.remove(corpses, index)
        okay = false
        break
      end
    end
  until okay
  -- Move corpses
  if core.game_time() % 10 == 0 or force then
    -- Remove corpses from right side
    repeat
      okay = true
      for index, pos in ipairs(corpses) do
        if pos.x == 78 then
          --Level[pos] = "pblood_river"
          Level[pos] = "blood_river"
          table.remove(corpses, index)
          okay = false
          break
        end
      end
    until okay
    for _, pos in ipairs(corpses) do
      if Level.is_corpse(pos) and pos.x <= 77 then
        local fringe = {
          coord.new(pos.x + 1, pos.y),
          coord.new(pos.x + 1, pos.y + 1),
          coord.new(pos.x + 1, pos.y - 1),
        }
        while #fringe > 0 do
          local index = math.random(#fringe)
          local nextpos = fringe[index]
          if Level[nextpos] == "blood_river" then
            Level[nextpos] = Level[pos]
            Level[pos] = "blood_river"
            pos.x, pos.y = nextpos.x, nextpos.y
            break
          else
            table.remove(fringe, index)
          end
        end
      end
    end
    if math.random(12 - DIFFICULTY) == 1 then
      local c = coord.new(1, math.random(9, 12))
      local dl = rawget(Level, "danger_level")
      rawset(Level, "danger_level", 16)
      local bid = Level.random_being()
      rawset(Level, "danger_level", dl)
      local corpseid = beings[bid].corpse or "corpse"
      if not (cells[corpseid] and cells[corpseid].flag_set[CF_CORPSE]) then
        corpseid = "corpse"
      end
      Level[c] = corpseid
      table.insert(corpses, c)
    end
  end
end

Levels("RIVER", {

  name = "The Acheron",
  
  entry = "He reached the banks of the Acheron.",
  
  welcome = "A river is flowing nearby.",
  
  mortem_location = "by the waters of the Acheron",
  
  type = "special",
  
  Create = function()
    inferno.generate_river_dungeon()
    for _ = 1, 100 do
      river_tick(true)
    end
  end,
  
  OnEnter = function()
    Level.result(1)
    if inferno.test then
      player.eq.weapon = item.new("bazooka")
      for i = 1, 3 do
        local it = item.new("rocket")
        it.ammo = 10
        player.inv:add(it)
      end
    end
  end,
  
  OnExit = function()
    ui.msg("")
  end,
  
  OnKillAll = function()
    Level.result(3)
    ui.msg("The river of blood will carry their souls away.")
  end,
  
  OnKill = function(b)
    local c = b:get_position()
    if Level[c] == "blood_river" then
      if b.__proto.corpse and cells[b.__proto.corpse] then
        table.insert(corpses, c)
        Level[c] = b.__proto.corpse
      end
    end
  end,
  
  OnTick = function()
    river_tick()
  end,
})

local function scan_numset(area, set)
  for c in area:coords() do
    if not set[Generator.get_cell(c)] then
      return false
    end
  end
  return true
end

function inferno.generate_river_dungeon()
  local dl = rawget(Level, "danger_level")
  rawset(Level, "danger_level", 16)
  local player_coord = coord.new(2, 8)
  Level.player(player_coord.x, player_coord.y)
  Generator.fill("rwall")
  local function clamp(a, b, c)
    return math.max(a, math.min(b, c))
  end
  local function rebound(a, b, c)
    if b > c then
      return c - 1
    elseif b < a then
      return a + 1
    else
      return b
    end
  end
  local y = 9
  local h = 4
  local north = 3
  local south = 3
  local c = coord.new(1, 1)
  for x = 1, 78 do
    c.x = x
    for i = y - north, y - 1 do
      c.y = i
      Level[c] = "blood"
    end
    for i = y, y + h - 1 do
      c.y = i
      Level[c] = "blood_river"
    end
    for i = y + h, y + h + south - 1 do
      c.y = i
      Level[c] = "blood"
    end
    if math.random(3) == 1 then
      north = clamp(2, north + math.random(3) - 2, 4)
    end
    if math.random(5) == 1 then
      y = rebound(6, y + math.random(3) - 2, 12)
    end
    if math.random(3) == 1 then
      south = clamp(2, south + math.random(3) - 2, 4)
    end
  end
  Level[coord.new(78, y + h + south - 1)] = "stairs"
  local dim_max = coord.new(16, 12)
  local dim_min = coord.new(7, 6)
  local rooms = {}
  for _ = 1, 200 do
    local room = area.random_subarea(area.FULL, coord.random( dim_min, dim_max ) )
    if scan_numset(room, {[cells.blood.nid] = true, [cells.rwall.nid] = true}) and not Level.scan(room, "rwall") then
      room:shrink(1)
      Generator.fill("wall", room )
      room:shrink(1)
      Generator.fill( "floor", room )
      local d = room:random_coord()
      local dy = 1
      if d.y >= 11 then dy = -1 end
      local dcell
      repeat
        dcell = Level[d]
        if dcell == "wall" then
          Level[d] = "door"
        elseif dcell == "rwall" then
          Level[d] = "floor"
        end
        d.y = d.y + dy
      until dcell == "blood" or dcell == "blood_river"
      table.insert(rooms, room:expanded())
      --Generator.add_room( room:expanded() )
    end
  end
  for _, room in ipairs(rooms) do
    if math.random(5) <= 3 then
      local bg = inferno.Generator.random_group()
      inferno.Generator.summon_group(bg, room)
	end
  end
  if #rooms > 0 then
    for _ = 1, 16 do
      local room = table.random_pick(rooms)
      Level.drop_item(Level.roll_item_type({ITEMTYPE_PACK, ITEMTYPE_AMMO, ITEMTYPE_AMMOPACK}, 15), room:shrinked():random_coord())
    end
    for _ = 1, 4 + math.random(4) do
      local room = table.random_pick(rooms)
      Level.drop_item(Level.roll_item_type({ITEMTYPE_AMMO}, 15), room:shrinked():random_coord())
    end
  end
  for c in area.around(player_coord, player.vision - 2):clamped(area.FULL):coords() do
    Level.light[c][LFNOSPAWN] = true
  end
  Level.flood_monsters(Generator.being_weight() * 0.6)
  local viles = math.max(DIFFICULTY - 1, 1)
  for _ = 1, viles do
    local vile = Level.drop_being("arch", coord.new(77, y + math.random(2)))
    if vile then
      LurkAI.disable_lurking(vile)
    end
  end
  rawset(Level, "danger_level", dl)
end