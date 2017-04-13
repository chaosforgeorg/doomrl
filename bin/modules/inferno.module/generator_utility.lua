local cardinal_dirs = {coord.new(1, 0), coord.new(0, 1), coord.new(-1, 0), coord.new(0, -1)}

Generator.scan_not = function(scan_area, cell_list)
  for c in scan_area() do
    for _, cell in ipairs(cell_list) do
      if Level[c] == cell then
        return false
      end
    end
  end
  return true
end

Generator.random_corpse = function()
  local corpse_id
  repeat
    corpse_id = Level.random_being() .. "corpse"
  until cells[corpse_id]
  return corpse_id
end

Generator.splat = function(c, cell, a)
  a = a or area.FULL
  for r = 1, 2 do
    for d in area.around(c, r)() do
      if coord.distance(c, d) <= r and math.random(3) <= 2 and a:contains(d) then
        Generator.bloodify(d)
      end
    end
  end
  Level[c] = cell
end

Generator.bloodify = function(c, disallow_pools)
  local cell = cells[Level[c]]
  if cell.bloodto and cell.bloodto ~= "" then
    if not (disallow_pools and cell.bloodto == "bloodpool") then
      Level[c] = cell.bloodto
    end
  end
end

-- Based of Generator.drunkard_walk
Generator.bloody_walk = function(start, steps)
  if steps <= 0 then
    return
  end
  local bloody_area = area.FULL
  local c = start:clone()
  for i = 1, steps do
    if not bloody_area:contains(c) then
      bloody_area:clamp_coord(c)
    end
    Generator.bloodify(c, true)
    local dir = table.random_pick(cardinal_dirs)
    c.x = c.x + dir.x
    c.y = c.y + dir.y
  end
end

function inferno.plus_around(c)
  local rtn = {
    coord.new(c.x, c.y - 1),
    coord.new(c.x, c.y + 1),
    coord.new(c.x - 1, c.y),
    coord.new(c.x + 1, c.y),
  }
  local i = 0
  return function()
    i = i + 1
    return rtn[i]
  end
end

function inferno.x_around(c)
  local rtn = {
    coord.new(c.x - 1, c.y - 1),
    coord.new(c.x - 1, c.y + 1),
    coord.new(c.x + 1, c.y - 1),
    coord.new(c.x + 1, c.y + 1),
  }
  local i = 0
  return function()
    i = i + 1
    return rtn[i]
  end
end

do
  local eflags = {EF_NOBLOCK, EF_NOTELE, EF_NOHARM}
  function Generator.is_blocker(c)
    local n = coord.new(c.x, c.y - 1)
    local s = coord.new(c.x, c.y + 1)
    local e = coord.new(c.x + 1, c.y)
    local w = coord.new(c.x - 1, c.y)
    local ne = coord.new(c.x + 1, c.y - 1)
    local se = coord.new(c.x + 1, c.y + 1)
    local nw = coord.new(c.x - 1, c.y - 1)
    local sw = coord.new(c.x - 1, c.y + 1)
    local n_empty = Generator.is_empty(n, eflags)
    local s_empty = Generator.is_empty(s, eflags)
    local e_empty = Generator.is_empty(e, eflags)
    local w_empty = Generator.is_empty(w, eflags)
    local ne_empty = Generator.is_empty(ne, eflags)
    local se_empty = Generator.is_empty(se, eflags)
    local nw_empty = Generator.is_empty(nw, eflags)
    local sw_empty = Generator.is_empty(sw, eflags)
    local num = 0
    if n_empty then num = num + 1 end
    if s_empty then num = num + 1 end
    if e_empty then num = num + 1 end
    if w_empty then num = num + 1 end
    if ne_empty then num = num + 1 end
    if se_empty then num = num + 1 end
    if nw_empty then num = num + 1 end
    if sw_empty then num = num + 1 end
    if num == 1 then return false end
    if (not n_empty) and (not s_empty) and (e_empty or w_empty) then return true end
    if (not e_empty) and (not w_empty) and (n_empty or s_empty) then return true end
    if ne_empty and not (n_empty or e_empty) then return true end
    if se_empty and not (s_empty or e_empty) then return true end
    if nw_empty and not (n_empty or w_empty) then return true end
    if sw_empty and not (s_empty or w_empty) then return true end
    return false
  end
end