inferno.ending = function()
  if Level.flags[LF_NUKED] and not player.flags[BF_INV] then
    -- No sacrifice wins :(
  else
    player:add_history("...and defeated the Simulacrum!")
    inferno.push_killed_by("defeated the Simulacrum")
    player.mortem_location = "and escaped from Hell"
    player.flags[BF_ENTERBOSS2] = true -- stops hard-coded trigger for HF
    player.victory = true
    player:win()
  end
end

inferno.Boss = {}

function inferno.Boss.trigger1(boss)
  for y = 9, 11 do
    local c = coord.new(73, y)
    Level[c] = "rwall"
    Level.light[c][LFPERMANENT] = true
  end
end

function inferno.Boss.trigger2(boss)
  local good = cells.floor.nid
  local code = {
    ['.'] = "blood",
    ['#'] = "lavawall",
    ['='] = "lava",
  }
  local tile = [[
.....
.###.
.#=#.
.###.
.....
]]
  local lines = string.split(tile, "[%s]+" )
  local size  = coord.new( string.len(lines[1]), #lines )
  local tries = 1000
  local count = 13
  repeat
    local c = area.FULL:random_coord()

    local ar = area.new( c, c + size - coord.UNIT )
    if Level.scan( ar ,good ) then
      if not ar:contains(player:get_position()) and not ar:contains(boss:get_position()) then
        Level.place_tile(code, tile, c.x,c.y)
        count = count - 1
      end
    end
    tries = tries - 1
  until count == 0 or tries == 0
end

function inferno.Boss.trigger3(boss)
  Generator.drunkard_walks(13, 49, "lava", nil, false, area.new(1, 1, 57, 20))
end

Levels("ESCAPE", {

  name = "Hell's Egress",
  
  entry = "He finally reached Hell's Egress...",
  
  mortem_location = "at Hell's Egress",
  
  type = "special",
  
  Create = function()
    local translation = {
      ["."] = "floor",
      ["v"] = "invis_wall",
      ["B"] = "blood",
      [">"] = "stairs",
      ["X"] = {"rwall", flags = {LFPERMANENT}},
      ["+"] = "door",
      ["|"] = {"floor", item = "cell"},
      ["/"] = {"floor", item = "rocket"},
      ["p"] = {"floor", item = "plasma"},
      ["r"] = {"floor", item = "bazooka"},
      ["M"] = {"floor", being = "mastermind"},
    }
    local map = [[
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
X.......................................................................X....X
X.......................................................................X.X..X
X...................................................................XX..X.XX.X
X............................................................BBB.....X..X.X..X
X..........................................................BB...BB......X....X
X........................................................BB.BB.BB.BB....XXXXXX
X.......................................................B..B.BBB.B..B...X....X
X......................................................B...BB...BB...B..v....X
X......................................................B..BB.....BB..B..v.>..X
X......................................................B.B..B...B..B.B..v....X
X.......................................................BBBBBBBBBBBBB...X....X
X........................................................BB..B.B..BB....XXXXXX
X..........................................................BB.B.BB......X....X
X............................................................BBB........X.X..X
X....................................................................X..X....X
X...................................................................XX..X..X.X
X.......................................................................X....X
X.......................................................................X.X..X
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    ]]
    Level.place_tile(translation, map, 1, 1)
    Level.player(3, 10)
    Level.result(1)
    for c in area.new(73, 1, 78, 20):coords() do
      Level.light[c][LFNOSPAWN] = true
    end
    Level.flags[LF_NOHOMING] = true
  end,
  OnTick = function()
    local result = Level.result()
    if result >= 2 then
      return
    end
    if player.x > 70 and player.y <= 12 and player.y >= 8  then
      Level.result(2)
      local anim = inferno.Animation.new()
      local pentagram_x = {
        63, 63, 63, 64, 64, 65, 66, 66, 66, 67,
        66, 65, 65, 64, 63, 62, 61, 60, 59, 58, 57,
        58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69,
        68, 67, 66, 65, 64, 63, 62, 61, 61, 60, 59,
        60, 60, 60, 61, 61, 62, 63, 63, 63,       
      }
      local pentagram_y = {
        15, 14, 14, 13, 12, 11, 10,  9,  8,  7,
         6,  6,  7,  7,  8,  8,  9, 10, 10, 11, 12,
        12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
        11, 10, 10,  9,  8,  8,  7,  7,  6,  6,  7,
         8,  9, 10, 11, 12, 13, 14, 14, 15, 
      }
      local circle_x = {
        63, 64, 65, 66, 67, 68, 69, 70,
        70, 70, 69, 68, 67, 66, 65, 64,
        63, 62, 61, 60, 59, 58, 57, 56,
        56, 56, 57, 58, 59, 60, 61, 62,
        63,
      }
      local circle_y = {
        15, 15, 14, 14, 13, 13, 12, 11,
        10,  9,  8,  7,  7,  6,  6,  5,
         5,  5,  6,  6,  7,  7,  8,  9,
        10, 11, 12, 13, 13, 14, 14, 15,
        15,
      }
      local s = core.resolve_sound_id("imp.explode")
      local function is_explosion(x, y)
        return x == 63 and y == 15 or
               x == 67 and y ==  7 or
               x == 57 and y == 12 or
               x == 69 and y == 12 or
               x == 59 and y ==  7
      end
      local total_len = 2000
      local pentagram_intervals = #pentagram_x - 1
      local circle_intervals = #circle_x - 1
      local lcm_intervals = math.lcm(pentagram_intervals, circle_intervals)
      total_len = math.ceil(total_len / lcm_intervals) * lcm_intervals
      local pentagram_delay = total_len / pentagram_intervals
      local circle_delay = total_len / circle_intervals
      for i = 1, #pentagram_x do
        local x = pentagram_x[i]
        local y = pentagram_y[i]
        local event = {}
        event.tile = {x = x, y = y, cell = "lava"}
        if is_explosion(x, y) then
          event.explosion = {x = x, y = y, radius = 3}
          event.sound = {x = x, y = y, id = "imp.explode"}
        end
        inferno.Animation.add_event(anim, (i - 1) * pentagram_delay, event)
      end
      for i = 1, #circle_x do
        local x = circle_x[i]
        local y = circle_y[i]
        local event = {}
        event.tile = {x = x, y = y, cell = "lava"}
        inferno.Animation.add_event(anim, (i - 1) * circle_delay, event)
      end
      inferno.Animation.play_animation(anim)
      local boss = Level.drop_being("simulacrum", coord.new(63, 10))
      boss.scount = 5000
    end
  end,
  OnEnter = function()
    if inferno.test then
      local it
      it = item.new("bfg9000")
      it.ammomax = 120
      it.ammo = 120
      player.eq.weapon = it
      player.eq.armor = item.new("rarmor")
      it = item.new("sboots")
      it.movemod = 20
      player.eq.boots = it
      for i = 1, 3 do
        it = item.new("cell")
        it.ammo = 40
        player.inv:add(it)
      end
      player.eq.prepared = item.new("bazooka")
      for i = 1, 2 do
        it = item.new("rocket")
        it.ammo = 10
        player.inv:add(it)
      end
      player.inv:add("lmed")
      player.inv:add("lmed")
      player.inv:add("phase")
      player.armor = 2
      player.hp = 70
      player.hpmax = 70
    end
  end,
})