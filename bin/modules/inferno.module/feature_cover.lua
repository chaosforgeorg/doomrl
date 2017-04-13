Features({
  id = "cover",
  type = "layout",
  weight = 25,
  Check = function(room, rm)
    return Generator.check_dims(rm, 7, 7)
  end,
  Create = function(room, split)
    local rm = Generator.room_meta[room] or {}
    if not split then
      rm.layout = rm.layout - 1
    end
    local wall_cell = styles[Level.style].wall
    local wall_cell_nid = cells[wall_cell].nid
    if inferno.level_type == "archi" then
      return
    end
    local interior = room:shrinked(2)
    local interior_dims = interior:dim()
    if not split then
      if rm.dims.x >= rm.dims.y * 1.3 and rm.dims.x >= 11 then
        local x_mid = room.a.x + math.floor(rm.dims.x / 2)
        local left_subroom = area.new(room.a:clone(), coord.new(x_mid + 1, room.b.y))
        local right_subroom = area.new(coord.new(x_mid - 1, room.a.y), room.b:clone())
        features.cover.Create(left_subroom, true)
        features.cover.Create(right_subroom, true)
        return
      elseif rm.dims.y >= 13 then
        local y_mid = room.a.y + math.floor(rm.dims.y / 2)
        local upper_subroom = area.new(room.a:clone(), coord.new(room.b.x, y_mid + 1))
        local lower_subroom = area.new(coord.new(room.a.x, y_mid - 1), room.b:clone())
        features.cover.Create(upper_subroom, true)
        features.cover.Create(lower_subroom, true)
        return
      end
    end
    local elements = 1
    if math.random(8) == 8 then
      elements = elements + 1
    end
    if math.random(8) == 8 then
      elements = elements + 1
    end
    for i = 1, elements do
      local roll = math.random(100) -- more types are planned (maybe)
      if roll <= 100 then
        -- segment
        local c = interior:random_coord()
        if math.random(2) == 1 then
          -- x axis
          local width = math.random(3, interior_dims.x)
          local x0 = interior.a.x - 1
          local y0 = c.y
          for x = 1, width do
            Generator.set_cell(coord.new(x0 + x, y0), wall_cell_nid)
          end
        else
          local height = math.random(3, interior_dims.y)
          local y0 = interior.a.y - 1
          local x0 = c.x
          for y = 1, height do
            Generator.set_cell(coord.new(x0, y0 + y), wall_cell_nid)
          end
        end
      end
    end
  end,
})