local map01 = [[
```````````````````````````````````#$$$$$$$#``````````````````````````````````
````````````````````################*******################```````````````````
```````````````````##********~~~~~~~*******~~~~~~~********##``````````````````
```````````````````#*********~~~~~~~*******~~~~~~~*********#``````````````````
```````````````````#***************************************#``````````````````
```````````````````#YYYYYYYYYYYYYYYY"""""""YYYYYYYYYYYYYYYY#``````````````````
```````````````````#......,......XXX'''''''XXX.............#``````````````````
```````````````````#...,,,.......XXX"""""""XXX.............Q``````````````````
```````````````````#..,,,,,.......YY'''''''YY.........^^^^^#``````````````````
```````````````````#..,,,,,.,,...XXX"""""""XXX........*****#``````````````````
```````````````````#..,,,,.,.....XXX'''''''XXX........^^^^^#``````````````````
```````````````````#..............YY..:::..YY.......,......Q``````````````````
```````````````````#~~~~~~~~~~~~~~~~~~~!~~~~~~~~~~~~~~~~~~~#``````````````````
```````````````````#######............:::............#######``````````````````
`````````````````````````#######...............#######````````````````````````
```````````````````````````````####%%%=.=%%%####``````````````````````````````
```````````````````````````````````%;......%``````````````````````````````````
```````````````````````````````````|;;...;.|``````````````````````````````````
```````````````````````````````````%;T..;C.%``````````````````````````````````
```````````````````````````````````%%%---%%%``````````````````````````````````
]]
local map_items = [[
```````````````````````````````````#$$$$$$$#``````````````````````````````````
````````````````````################*******################```````````````````
```````````````````##********???????***2***???????********##``````````````````
```````````````````#*F*******???????*******???????*******G*#``````````````````
```````````````````#**j****************@****************J**#``````````````````
```````````````````#YYYYYYYYYYYYYYYY"""""""YYYYYYYYYYYYYYYY#``````````````````
```````````````````#.+..J,.k..L..XXX'''''''XXX..l..K..j..+.#``````````````````
```````````````````#...,,,.......XXX"""""""XXX.............Q``````````````````
```````````````````#..,,,,,.......YY'''''''YY.........^^^^^#``````````````````
```````````````````#..,,,,,.,,...XXX"""""""XXX........****1#``````````````````
```````````````````#..,,,,.,.....XXX'''''''XXX........^^^^^#``````````````````
```````````````````#.3............YY..:::..YY.......,......Q``````````````````
```````````````````#~~~~~~~~~~~~~~~~~~~!~~~~~~~~~~~~~~~~~~~#``````````````````
```````````````````#######............:::............#######``````````````````
`````````````````````````#######...............#######````````````````````````
```````````````````````````````####%%%=.=%%%####``````````````````````````````
```````````````````````````````````%;......%``````````````````````````````````
```````````````````````````````````|;;...;.|``````````````````````````````````
```````````````````````````````````%;T..;C.%``````````````````````````````````
```````````````````````````````````%%%---%%%``````````````````````````````````
]]


local _TICKS_TIL_WAVE1_DONE = 0
local being_translation = {
  ['@'] = { beings = { {sid = "archlich", count = 1, }, }, rate = _TICKS_TIL_WAVE1_DONE, rate_next = 0, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, },
}
local item_translation =  {
  ['F'] = { sid = "skbfg9000",  count = 1, rate = 300, rate_next = 300, },
  ['G'] = { sid = "skbfg10000", count = 1, rate = 300, rate_next = 300, },
  ['1'] = { sid = "sr_drain",  count = 1, rate = 120, rate_next =  90, },
  ['2'] = { sid = "sp_random",            rate = 120, rate_next =  60, },
  ['3'] = { sid = "scglobe",   count = 2, rate = 200, rate_next = 200, },
  ['+'] = { sid = "lmed",   count = 5, rate = 120, rate_next = 100, },
  ['j'] = { sid = "ammo",   rate = 50, ammo = 50, },
  ['J'] = { sid = "ammo",   rate = 70, ammo = 50, },
  ['k'] = { sid = "rocket", rate = 60, ammo =  5, },
  ['K'] = { sid = "rocket", rate = 80, ammo =  5, },
  ['l'] = { sid = "cell",   rate = 70, ammo = 20, },
  ['L'] = { sid = "cell",   rate = 90, ammo = 20, },
}


local leftriver_start = coord.new(21, 13)
local rightriver_start = coord.new(59, 13)
local oblivion = coord.new(40, 13)
local leftriver_table = {}
local rightriver_table = {}
local portal_start = coord.new(37, 1)
local portal_end = coord.new(43, 1)
local portal_table = {}
local portal_position = 1

for c in area.new(leftriver_start.x, leftriver_start.y, oblivion.x-1, oblivion.y):coords() do
  table.insert(leftriver_table, 1, c)
end
for c in area.new(oblivion.x+1, oblivion.y, rightriver_start.x, rightriver_start.y):coords() do
  table.insert(rightriver_table, c)
end
for c in area.new(portal_start.x, portal_start.y, portal_end.x, portal_end.y):coords() do
  table.insert(portal_table, c)
end

local move_blood = function(coord_table)

  for i=1, #coord_table do
    local coord = coord_table[i]
    local coord_next = coord_table[i-1]

    --expanded form of level:is_corpse so that the river doesn't spawn rezzable corpses
    local cell = cells[ level.map[ coord ] ]
    if cell.id == "corpse" or cell.id == "corpse2" or cell.flags[ CF_CORPSE ] then
      if(coord_next ~= nil) then
        level.map[coord_next] = level.map[coord]
      end
      level.map[coord] = "bloodriver"
    end

    local item = level:get_item(coord)
    if (item ~= nil) then
      if(coord_next ~= nil) then
        item:displace(coord_next)
      else
        item:destroy()
      end
    end
  end

end
local cycle_portal = function()

  local coord = portal_table[portal_position]
  if not coord then
    portal_position = 1
    coord = portal_table[portal_position]
  end
  portal_position = portal_position + 1

  if (level.map[coord] == "bloodportal1") then
    level.map[coord] = "bloodportal2"
  else
    level.map[coord] = "bloodportal1"
  end
end
local portal_expl = function()

  local coord = coord.clone(table.random_pick(portal_table))
  local size = 1
  if (math.random(9) == 1) then
    size = size + 1
  end

  local color = table.random_pick({BLUE, GREEN, MAGENTA})
  level:explosion( coord, size, 20, 0, 0, color ) 
end


local playmusic = true
local endgame = false
local river_tick = 1
local river_rate = 37
local river_bodyleft  = math.random(9)
local river_bodyright = math.random(9)
local river_bodyrate = 9
local river_bodyvariance = .3
local portal_tick = 1
local portal_rate = 9
local portal_random_tick = 13
local portal_random_rate = 18
local portal_random_variance = .7
local boss_1 = {

  name = "boss 1",

  OnLoad = function()

    local translation = {
      ['`'] = "void",
      ['.'] = "floor",
      ['='] = { "edoor", flags = { LFPERMANENT } },
      ['%'] = { "ewall", flags = { LFPERMANENT } },
      ['-'] = { "ehwindow", flags = { LFPERMANENT } },
      ['|'] = { "evwindow", flags = { LFPERMANENT } },
      ['T'] = { "brokentv", flags = { LFPERMANENT } },
      ['C'] = "couch",
      [';'] = "flesh",
      [':'] = "bloodpool",
      [','] = "redflesh",
      ['~'] = "bloodriver",
      ['!'] = "voidfloor",
      ['"'] = "stair1",
      ["'"] = "stair2",
      ['^'] = "ironfence",
      ['*'] = "ironfloor",
      ['Q'] = { "irondoor", flags = { LFPERMANENT } },
      ['#'] = { "bosswall1", flags = { LFPERMANENT } },
      ['X'] = "skullpillar",
      ['Y'] = { "bosswall2", flags = { LFPERMANENT } },
      ['$'] = { "bloodportal", flags = { LFPERMANENT } },
    }

    generator.place_tile( translation, map01, 1, 1 )

    Elevator.ItemEngine.PauseSounds(true)
    Elevator.ItemEngine.AddMap( item_translation, map_items, coord.new(1, 1) )
    Elevator.ItemEngine.CheckItems()
    Elevator.ItemEngine.PauseSounds(false)
    Elevator.SpawnEngine.AddMap( being_translation, map_items, coord.new(1, 1) )
    Elevator.HUD.Reset()

    --Do NOT play music yet.
  end,

  OnUnload = function()
    player:win()
  end,

  OnTick = function()

    --Blood River stuff
    river_tick = river_tick - 1
    if(river_tick <= 0) then
      river_tick = river_tick + river_rate

      --move bodies and items
      move_blood(leftriver_table)
      move_blood(rightriver_table)

      --spawn bodies
      river_bodyleft = river_bodyleft - 1
      if(river_bodyleft <= 0) then
        river_bodyleft  = river_bodyleft  + (river_bodyrate * (1 + ((math.random() - 0.5) * (river_bodyvariance * 2))))
        level.map[leftriver_start] = "corpse2"
      end
      river_bodyright = river_bodyright - 1
      if(river_bodyright <= 0) then
        river_bodyright = river_bodyright + (river_bodyrate * (1 + ((math.random() - 0.5) * (river_bodyvariance * 2))))
        level.map[rightriver_start] = "corpse2"
      end
    end

    --Portal stuff
    if(endgame == true) then
      portal_tick = portal_tick - 1
      if(portal_tick <= 0) then
        portal_tick = portal_tick + portal_rate
        cycle_portal()
      end

      portal_random_tick = portal_random_tick - 1
      if(portal_random_tick <= 0) then
        portal_random_tick = portal_random_tick + (portal_random_rate * (1 + ((math.random() - 0.5) * (portal_random_variance * 2))))
        portal_expl()
      end
    end

    --Music
    if(playmusic == true and player.y < 17) then 
      playmusic = false
      core.play_music("FIREFIEL")
    end

    --Win
    if(player.y <= 1) then
      Elevator.WaveEngine.Next(false)
    end
  end,

  OnKill = function(being)
    if (being.id == "archlich") then
      for b in level:beings() do
        if not ( b:is_player() ) and b.id ~= "archlich" then
          b:kill()
        end
      end
    end
  end,

  OnKillAll = function ()
    generator.transmute("bloodportal", "bloodportal1")
    endgame = true
  end,

  OnDieCheck = function(player)

    player:play_sound(beings["soldier"].sound_die)
    if(not cells[level.map[ player.position ]].flags[ CF_NOCHANGE ]) then
      level.map[ player.position ] = "corpse"
    end
    Elevator.Player.DropEquipment(player)

    player:displace(coord.new(40,18))

    player.tired = false
    player.hp = player.hpmax
    player.eq.weapon = item.new("shotgun")
    player.eq.prepared = item.new("chaingun")
    player.eq.armor  = item.new("garmor")
    player.inv:add(item.new("ammo"), { ammo = 40 })
    player.inv:add(item.new("shell"), { ammo = 20 })

    if(player:get_trait( traits["brute"].nid ) > 0) then
      player.inv:add(item.new("knife"))
    end
    if(player:get_trait( traits["gun"].nid ) > 0) then
      player.inv:add(item.new("pistol"))
      player.inv:add(item.new("ammo"), { ammo = 50 })
    end

    for b in level:beings() do
      if not ( b:is_player() ) then
        b.scount = math.max(b.scount - 3000, 0)
      end
    end

    return false
  end,
}

Elevator.WaveEngine.Add(boss_1)