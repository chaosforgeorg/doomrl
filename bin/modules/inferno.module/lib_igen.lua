core.declare("IGen", {})

function IGen.place_tile(translation, map, x, y)
  local upper_left = coord.new(x, y)
  local lines = string.split(map, "%s+")
  local map_size = coord.new(#lines[1], #lines)
  local map_area = area.new(coord.UNIT, map_size)
  for c in map_area:coords() do
    local char = string.sub(lines[c.y], c.x, c.x)
    local tile_entry = translation[char]
    if type(tile_entry) ~= "table" then
      tile_entry = {tile_entry}
      translation[char] = tile_entry
    end
    local c_adj = upper_left + c - coord.UNIT
    if tile_entry[1] then
      Level[c_adj] = tile_entry[1]
    end
    if tile_entry[2] then
      Level[c_adj] = tile_entry[2]
    end
    if tile_entry.being then
      Level.drop_being_ext(tile_entry.being, c_adj)
    end
    if tile_entry.item then
      Level.drop_item_ext(tile_entry.item, c_adj)
    end
    if tile_entry.flags then
      for _, flag in ipairs(tile_entry.flags) do
        Level.light[c_adj][flag] = true
      end
    end
  end
end