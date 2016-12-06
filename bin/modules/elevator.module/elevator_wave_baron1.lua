local map01 = [[
```````############W###W###W####```
```````#.....;"'".............X#```
```````#.....;"'".............X#```
```````#.....###################```
```````#.....#X................#```
```````#.....########..........####
```````#.....'"'"'"';..........;...
```````#.....'"'"'"';..........;...
```````##############..........####
````############,::::::::::....#```
`````YYYYYYYYYYY,::::::::::....#```
`````YYYYYYYYYYY,::/:::::::....#```
`````YYYYYYYYYYY,::::::::::..,.####
`````YYYYYYYYYYY,:::::::/::..,.;...
````############:::::::::::..,.;...
```````````````##Z##Z##Z##Z########
```````````````````````````````````
```````````````````````````````````
```````````````````````````````````
```````````````````````````````````
]]
local map02 = [[
`````````
`````````
`````````
`````````
`````````
########`
.......#`
.......#`
###....#`
##~....#`
#~~....#`
##~....#`
###....#`
.......#`
.......#`
]]
local map03 = [[
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
]]
local map_items = [[
```````############W###W###W####``````````````````````````````````````````````
```````#..*..;"'"....1.......3B#``````````````````````````````````````````````
```````#.1.1.;"'"............33#``````````````````````````````````````````````
```````#.....###################``````````````````````````````````````````````
```````#.....#p...............D#``````````````````````````````````````````````
```````#.....########..........############```````````````````````````````````
```````#.1.1.'"'"'"';..........;.........2#```````````````````````````````````
```````#.._..'"'"'"';........2.;.!........#```````````````````````````````````
```````##############..........#######....#```````````````````````````````````
````############,::::::::::....#```##~....#```````````````````````````````````
`````,,,,,,,,,,Y,::::::::::..2.#```#r~....#```````````````````````````````````
`````,,,,,,,,,,Y,::L:1:::::1...#```##~....#```````````````````````````````````
`````,,,,,,,,,,Y,::::::::::..,.#######....#```````````````````````````````````
`````,,,,,,,,,,Y,:::::::J::..2.;.+........#```````````````````````````````````
````############/::::1:::::1.,.;.........2#```````````````````````````````````
```````````````##Z##Z##Z##Z###########===###``````````````````````````````````
```````````````````````````````````#:P:::P:#``````````````````````````````````
```````````````````````````````````|:::::::|``````````````````````````````````
```````````````````````````````````#:T:A:C:#``````````````````````````````````
```````````````````````````````````###---###``````````````````````````````````
]]
local map_beings = [[
```````############W###W###W####``````````````````````````````````````````````
```````#ggggg;"'".............h#``````````````````````````````````````````````
```````#ggggg;"'"..............#``````````````````````````````````````````````
```````#.....###################``````````````````````````````````````````````
```````#.....#.......ddd.......#``````````````````````````````````````````````
```````#.....########ddd.......############```````````````````````````````````
```````#.....f"'"'"';..........;bbb.......#```````````````````````````````````
```````#.....f"'"'"';..........;bbb.......#```````````````````````````````````
```````##############..........#######....#```````````````````````````````````
````############iii::::::::..cc#```##~....#```````````````````````````````````
`````,,,,,,,,,,Yiii::::::::..cc#```#r~....#```````````````````````````````````
`````,,,,,,,,,,Yiii::::::::..cc#```##~....#```````````````````````````````````
`````,,,,,,,,,,Yjjj::::::::..,.#######....#```````````````````````````````````
`````,,,,,,,,,,Yjjj::eee:::..,.;aaa.......#```````````````````````````````````
````############jjj::eee:::..,.;aaa.......#```````````````````````````````````
```````````````##Z##Z##Z##Z###########===###``````````````````````````````````
```````````````````````````````````#:P:::P:#``````````````````````````````````
```````````````````````````````````|:::::::|``````````````````````````````````
```````````````````````````````````#:T:A:C:#``````````````````````````````````
```````````````````````````````````###---###``````````````````````````````````
]]


local _TICKS_TIL_WAVE1_DONE = 60
local _TICKS_TIL_WAVE2_DONE = 60
local _TICKS_TIL_WAVE3_DONE = 90
local _TICKS_TIL_WAVE4_DONE = 250
local _TICKS_TIL_WAVE5_DONE = 0
local _TICKS_TIL_WAVE6_DONE = 0
local _TICKS_TIL_WAVE7_DONE = 0
local _TICKS_TIL_WAVE8_DONE = 250
local item_translation_1 =  {
  ['A'] = { sid = "garmor", rate = 120, rate_next = 0, },
  ['r'] = { sid = "sr_rage", count = 1, rate_next = 30, },
  ['1'] = { sid = "ammo",   ammo = 100 },
  ['2'] = { sid = "shell",  ammo = 20  },
  ['3'] = { sid = "rocket", ammo = 5   },
}
local item_translation_1a =  {
  ['A'] = { sid = "sboots", rate = 120, rate_next = 10, },
}
local item_translation_2 =  {
  ['D'] = { sid = "chaingun", rate = 120, rate_next = 60, },
  ['+'] = { sid = "smed", count = 5, rate = 30, rate_next = 30, },
  ['!'] = { sid = "smed", count = 5, rate = 90, rate_next = 30, },
  ['p'] = { sid = "sr_prosperity", count = 1, rate_next = 30, },
  ['/'] = { sid = "sp_guardsphere", count = 5, rate = 200, rate_next = 200, },
}
local item_translation_3 =  {
  ['J'] = { sid = "lmed", count = 5, rate = 60, rate_next = 60, },
  ['L'] = { sid = "lmed", count = 5, rate = 90, rate_next = 60, },
}
local item_translation_4 =  {
  ['B'] = { sid = "bazooka",  rate = 120, rate_next = 60, },
}
--Once I get around to changing the GB's AI to not use health packs merge 4 and 5.
local item_translation_5 =  {
  ['*'] = { sid = "smed", count = 5, rate = 30, rate_next = 30, },
  ['_'] = { sid = "smed", count = 5, rate = 90, rate_next = 30, },
}
local being_translation_1 = {
  ['a'] = { beings = { {sid = "knight",            count = 6, }, }, rate = math.floor(_TICKS_TIL_WAVE1_DONE / 6), rate_next = 5, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, },
}
local being_translation_2 = {
  ['b'] = { beings = { {sid = "cyberknight",       count = 6, }, }, rate = math.floor(_TICKS_TIL_WAVE2_DONE / 6), rate_next = 5, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, },
}
local being_translation_3 = {
  ['c'] = { beings = { {sid = "cybruiser",         count = 6, }, }, rate = math.floor(_TICKS_TIL_WAVE3_DONE / 6), rate_next = 5, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, },
}
local being_translation_4 = {
  ['d'] = { beings = { {sid = "baron",             count = 3, },
                       {sid = "cyberbaron",        count = 3, }, }, rate = math.floor(_TICKS_TIL_WAVE4_DONE / 6), rate_next = 10, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_RANDOM},
  ['e'] = { beings = { {sid = "baron",             count = 3, },
                       {sid = "cyberbaron",        count = 3, }, }, rate = math.floor(_TICKS_TIL_WAVE4_DONE / 6), rate_next = 10, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_RANDOM},
}
local being_translation_5 = {
  ['f'] = { beings = { {sid = "greaterbaron",      count = 2, }, }, rate = math.floor(_TICKS_TIL_WAVE5_DONE / 2), rate_next = 10, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, },
}
local being_translation_6 = {
  ['g'] = { beings = { {sid = "bruiserdemon",      count = 1, }, }, rate = math.floor(_TICKS_TIL_WAVE6_DONE / 1), rate_next = 10, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, },
}
local being_translation_7 = {
  ['h'] = { beings = { {sid = "greatercyberbaron", count = 1, }, }, rate = math.floor(_TICKS_TIL_WAVE7_DONE / 1), rate_next = 10, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, },
}
local being_translation_8 = {
  ['i'] = { beings = { {sid = "belphegor",         count = 4, },
                       {sid = "cyberbelphegor",    count = 3, }, }, rate = math.floor(_TICKS_TIL_WAVE8_DONE / 8), rate_next = 5, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_RANDOM},
  ['j'] = { beings = { {sid = "belphegor",         count = 4, },
                       {sid = "cyberbelphegor",    count = 3, }, }, rate = math.floor(_TICKS_TIL_WAVE8_DONE / 6), rate_next = 5, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_RANDOM},
}


local _WAVE1_COUNT = 6
local _WAVE2_COUNT = 6
local _WAVE3_COUNT = 6
local _WAVE4_COUNT = 12
local _WAVE5_COUNT = 2
local _WAVE6_COUNT = 1
local _WAVE7_COUNT = 1
local _WAVE8_COUNT = 14
local _wave = 1
local _dead_guys = 0
local _next_reward = math.random(15) + 15
local check_wave_1_reward = function()

    if(_dead_guys >= _WAVE1_COUNT) then
      _wave = 2
      _dead_guys = 0

      Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_2, map_beings, coord.new(1, 1) )
    end
end
local check_wave_2_reward = function()

    if(_dead_guys >= _WAVE2_COUNT) then
      _wave = 3
      _dead_guys = 0

      Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_3, map_beings, coord.new(1, 1) )
      Elevator.ItemEngine.AddMap( item_translation_2, map_items, coord.new(1, 1) )
      generator.transmute("barrier", "greenfloor", area.new( 30, 2, MAXX-1, MAXY-1 ) )
    end
end
local check_wave_3_reward = function()

    if(_dead_guys >= _WAVE3_COUNT) then
      _wave = 4
      _dead_guys = 0

      Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_4, map_beings, coord.new(1, 1) )
    end
end
local check_wave_4_reward = function()

    if(_dead_guys >= _WAVE4_COUNT) then
      _wave = 5
      _dead_guys = 0

      Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_5, map_beings, coord.new(1, 1) )
      Elevator.ItemEngine.AddMap( item_translation_3, map_items, coord.new(1, 1) )

      local roll
      repeat
        roll = table.random_pick({"ucpistol", "ublaster", "uashotgun", "udshotgun"})
      until not player.drops[roll]

      player.drops[roll] = true
      local item = Elevator.Level.DropItemNearPlayer(roll, 5)
      item.flags[IF_NODESTROY] = true

      generator.transmute("barrier", "stair2",     area.new( 15, 2, MAXX-1, MAXY-1 ) )
    end
end
local check_wave_5_reward = function()

    if(_dead_guys >= _WAVE5_COUNT) then
      _wave = 6
      _dead_guys = 0

      Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_6, map_beings, coord.new(1, 1) )
    end
end
local check_wave_6_reward = function()

    if(_dead_guys >= _WAVE6_COUNT) then
      _wave = 7
      _dead_guys = 0

      Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_7, map_beings, coord.new(1, 1) )
      Elevator.ItemEngine.AddMap( item_translation_4, map_items, coord.new(1, 1) )
      generator.transmute("barrier", "stair1",     area.new( 2,  2, MAXX-1, MAXY-1 ) )
    end
end
local check_wave_7_reward = function()

    if(_dead_guys >= _WAVE7_COUNT) then
      _wave = 8
      _dead_guys = 0

      Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_8, map_beings, coord.new(1, 1) )
      Elevator.ItemEngine.AddMap( item_translation_5, map_items, coord.new(1, 1) )

      generator.transmute("barrier", "greenfloor", area.new( 30, 2, MAXX-1, MAXY-1 ) )
      generator.transmute("barrier", "stair2",     area.new( 15, 2, MAXX-1, MAXY-1 ) )
      generator.transmute("barrier", "stair1",     area.new( 2,  2, MAXX-1, MAXY-1 ) )
    end
end
local check_wave_8_reward = function()

    if(_dead_guys >= _WAVE8_COUNT) then
      local roll
      repeat
        roll = table.random_pick({"uparmor", "upboots", "uduelarmor", "umedarmor"})
      until not player.drops[roll]

      player.drops[roll] = true
      local item = Elevator.Level.DropItemNearPlayer(roll, 5)
      item.flags[IF_NODESTROY] = true
      item.flags[IF_RECHARGE] = true

      Elevator.SpawnEngine.ClearSpawns()
      Elevator.WaveEngine.Next(false)
    end
end
local check_mod_reward = function()
    _next_reward = _next_reward - 1
    if(_next_reward <= 0) then
      --Drop a mod somewhere for kicks
      Elevator.Level.DropItemNearPlayer( table.random_pick({"mod_agility","mod_bulk","mod_tech","mod_power"}), 7 )
      _next_reward = math.random(15) + 15
    end
end

local baron_1 = {

  name = "baron 1",

  OnLoad = function()

    local translation = {
      ['`'] = { "void", flags = { LFPERMANENT } },
      ['#'] = { "baronwall", flags = { LFPERMANENT } },
      ['W'] = { "barongate", flags = { LFPERMANENT } },
      ['X'] = "telebase",
      ['Y'] = { "barondropwall", flags = { LFPERMANENT } },
      ['Z'] = { "baronface", flags = { LFPERMANENT } },
      ['.'] = "greenfloor",
      [','] = "flesh",
      [';'] = { "barrier", flags = { LFPERMANENT } },
      [':'] = "tile",
      ['/'] = "baronfface",
      ['~'] = "water",
      ["'"] = "stair1",
      ['"'] = "stair2",
    }

    generator.place_tile( translation, map01,  1, 1 )
    generator.place_tile( translation, map02, 36, 1 )
    generator.place_tile( translation, map03, 45, 1 )
    level.danger_level = 3
    generator.transmute("edoor", "oedoor")

    Elevator.ItemEngine.PauseSounds(true)
    Elevator.ItemEngine.AddMap( item_translation_1, map_items, coord.new(1, 1) )
    Elevator.ItemEngine.AddMap( item_translation_1a, map_items, coord.new(1, 1) )
    Elevator.ItemEngine.CheckItems()
    Elevator.ItemEngine.PauseSounds(false)
    Elevator.SpawnEngine.AddMap( being_translation_1, map_beings, coord.new(1, 1) )
    Elevator.HUD.Reset()

    core.play_music("FIREFIEL")
      --_dead_guys = _WAVE8_COUNT
      --check_wave_8_reward()
  end,

  OnTick = function()
    --do nothing
  end,

  OnKill = function(being)
    _dead_guys = _dead_guys + 1

    --Wave handling
    if(    _wave == 1) then check_wave_1_reward()
    elseif(_wave == 2) then check_wave_2_reward()
    elseif(_wave == 3) then check_wave_3_reward()
    elseif(_wave == 4) then check_wave_4_reward()
    elseif(_wave == 5) then check_wave_5_reward()
    elseif(_wave == 6) then check_wave_6_reward()
    elseif(_wave == 7) then check_wave_7_reward()
    elseif(_wave == 8) then check_wave_8_reward()
    end

    check_mod_reward()
  end,

  OnKillAll = function ()
    --Make sure there's no dead air if the player is really fast or really good.
    --If it's not a brand new wave then fast forward to the next being.
    if (_dead_guys > 0) then
      local safe = 0
      repeat until Elevator.SpawnEngine.OnTick() or safe > 1000

      if safe > 1000 then
        error( "Infinite fast forward loop detected!" )
      end
    end
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
    player.eq.armor  = item.new("garmor")
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

Elevator.WaveEngine.Add(baron_1)