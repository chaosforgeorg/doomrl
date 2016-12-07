Features({
  id = "city",
  type = "layout",
  weight = 25,
  Check = function(room, rm)
    return Generator.check_dims(rm, 18, 9)
  end,
  Create = function(room)
    local rm = Generator.room_meta[room]
    rm.layout = rm.layout - 1
    local floor_cell = styles[Level.style].floor
    local wall_cell = styles[Level.style].wall
    local pwall_cell = styles[Level.style].pwall
    local wall_list = {wall_cell, pwall_cell}
    local door_cell = "door"
    local interior = room:shrinked(1)
    local interior_dims = interior:dim()
    local tries = 20
    local dim_max = coord.new(math.max(5, math.min(15, interior_dims.x)), math.max(5, math.min(11, interior_dims.y)))
    local dim_min = coord.new(5, 5)
    for i = 1, tries do
      local inner_room = area.random_subarea(interior, coord.random(dim_min, dim_max))
      if Generator.scan_not(inner_room, wall_list) then
        inner_room:shrink(1)
        Level.fill(wall_cell, inner_room)
        local doors = math.random(3)
        for j = 1, doors do
          local door_pos = area.random_inner_edge_coord(inner_room)
          if Generator.around(door_pos, door_cell) == 0 then
            Level[door_pos] = "door"
          end
        end
        inner_room:shrink(1)
        Level.fill(floor_cell, inner_room)
      end
    end
  end,
})