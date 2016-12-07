inferno.Animation = {}

function inferno.Animation.delay(ms)
  
end

function math.gcd(a, b)
  if a == 0 then
    return b
  end
  while b ~= 0 and a ~= 0 do
    if a > b then
      a = a - b
    else
      b = b - a
    end
  end
  return math.max(a, b)
end

function math.lcm(a, b)
  return a * b / math.gcd(a, b)
end

function inferno.Animation.play_event(event)
  if event.tile then
    local x, y = event.tile.x, event.tile.y
    Level[coord.new(x, y)] = event.tile.cell
  end
  if event.sound then
    local x, y = event.sound.x, event.sound.y
    Level.play_sound(event.sound.id, coord.new(x, y))
  end
  if event.explosion then
    local x, y = event.explosion.x, event.explosion.y
    Level.explosion(coord.new(x, y), event.explosion.radius, event.explosion.delay or 25, 0, 0, event.explosion.color or RED, 0, 0)
  end
end

function inferno.Animation.new()
  return {
    schedule = {}
  }
end

function inferno.Animation.play_animation(anim)
  table.sort(anim.schedule)
  local t = 0
  for _, s in ipairs(anim.schedule) do
    if s > t then
      inferno.Animation.delay(s - t)
      t = s
    end
    local events = anim[s]
    --ui.msg(s); ui.msg(#anim[s])
    if events then
      for _, event in ipairs(events) do
        inferno.Animation.play_event(event)
      end
    end
  end
end

function inferno.Animation.add_event(anim, t, event)
  if not anim[t] then
    table.insert(anim.schedule, t)
    anim[t] = {}
  end
  table.insert(anim[t], event)
end