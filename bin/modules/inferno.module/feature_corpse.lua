Features({
  id = "corpse",
  type = "floor",
  weight = 10,
  Check = function(room, rm)
    return Generator.check_dims(rm, 4, 4, 40)
  end,
  Create = function(room)
    local rm = Generator.room_meta[room]
    rm.floor = rm.floor - 1
    local floor_cell = styles[Level.style].floor
    local count = math.ceil(rm.dims.x * rm.dims.y / 12)
    count = math.max(count, 1)
    count = math.random(count)
    for i = 1, count do
      local c = room:shrinked():random_coord()
      if Level[c] == floor_cell then
        local corpse_id = Generator.random_corpse()
        Generator.splat(c, corpse_id, room)
      end
    end
    local roll = math.random(5) + Level.danger_level + DIFFICULTY
    if roll >= 18 and math.random(2) == 1 then
      Level.area_summon(room:shrinked(), "arch")
      rm.monsters = true
    end
  end,
})