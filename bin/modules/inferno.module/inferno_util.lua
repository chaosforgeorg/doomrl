rawset(Level, "clear_item", function(c)
  local it = Level.get_item(c)
  if it then
    it:destroy()
  end
end)

core.declare("GLevel", {})

function GLevel.putc(c, t, b)
  Level[c] = "floor"
  if b then
    Level[c] = b
  end
  Level[c] = t
end

function GLevel.put(x, y, t, b)
  GLevel.putc(coord.new(x, y), t, b)
end

function inferno.roll_rare(type, level)
  local sum = 0
  local list = {}
  for index = 1, items.__counter do
    local p = items[index]
    if p then
      if (p.flag_set[IF_EXOTIC] or p.flag_set[IF_UNIQUE]) and p.type == type and p.weight > 0 and p.level <= level then
        sum = sum + p.weight
        table.insert(list, p)
      end
    end
  end
  local result = Level.roll_weight(list, sum)
  return result.id
end

function inferno.roll_unique(type, level)
  local sum = 0
  local list = {}
  for index = 1, items.__counter do
    local p = items[index]
    if p then
      if (p.flag_set[IF_UNIQUE]) and p.type == type and p.weight > 0 and p.level <= level then
        sum = sum + p.weight
        table.insert(list, p)
      end
    end
  end
  local result = Level.roll_weight(list, sum)
  return result.id
end