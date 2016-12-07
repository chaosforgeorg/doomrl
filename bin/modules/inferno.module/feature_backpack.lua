Features({
  id = "backpack",
  type = "full",
  weight = 400,
  unique = true,
  Check = function(room, rm)
    return
      Generator.check_dims(rm, 9, 9, 16, 12) and
      Level.danger_level >= 12
  end,
  Create = function(room)
    Generator.room_meta[room].full = true
    local floor_cell = styles[Level.style].floor
    local wall_cell = styles[Level.style].wall
    local translation = {
      ["."] = floor_cell,
      ["#"] = wall_cell,
      ["^"] = {floor_cell, item = "backpack"},
      ["V"] = {floor_cell},
      ["h"] = {floor_cell, being = "sergeant"},
      ["R"] = {floor_cell, being = "revenant"},
    }
    if DIFFICULTY >= 3 then
      translation["h"].being = "commando"
      translation["V"].being = "revenant"
    end
    if DIFFICULTY >= 4 then
      translation["V"].being = "arch"
    end
    local layouts = {[[
.h.....
..R##.h
.#...V.
.#.^.#.
.V...#.
h.##R..
.....h.
]], [[
...h...
.V#.#R.
.#...#.
h..^..h
.#...#.
.R#.#V.
...h...
]], [[
.....h.
R#.V##.
.....#.
.h.^.h.
.#.....
.##V.#R
.h.....
]], [[
...h...
.#.#V#.
.....R.
h#.^.#h
.R.....
.#V#.#.
...h...
    ]]}
    local interior = room:shrinked(1)
    -- We want a 7x7 area ... hence 6x6. What?
    local zone = interior:random_subarea(coord.new(6, 6))
    Level.place_tile(translation, table.random_pick(layouts), zone.a.x, zone.a.y)
    local ammos = {"ammo", "shell", "cell", "rocket"}
    for c in area.around(coord.new(zone.a.x + 3, zone.a.y + 3))() do
      if not Level.get_item(c) then
        Level.drop_item(table.random_pick(ammos), c)
      end
    end
    return true
  end,
})