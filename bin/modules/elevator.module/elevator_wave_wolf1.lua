local map01 = [[
````````````````````````BBBBBBBBBBB
```````````````````````BBXXXXXXXXXX
```````````````````````BXX.........
```````````````````````BXp..BB.....
`````````````````CCCCCCBBX.........
`````````````````CYYYYY3AAAaAA+AA1A
`````````````````CY....pAWp........
`````````````````CYYY...At...YYY...
`````````````````CCCy...=....yY7...
```````````````````CY...A....YYY..8
```````````````````CY...A....YYY..8
`````````````````CCCy...=....7Yy...
`````````````````CYYY...At...YYY...
`````````````````CY....pAWp........
`````````````````CYYYYY7AAAaAAAA1AA
`````````````````CCCCCCCC``````````
```````````````````````````````````
```````````````````````````````````
```````````````````````````````````
```````````````````````````````````
]]
local map02 = [[
BBBBBBBBB
XXXXXXXXX
.........
BB.....BB
.........
A1AA+AA1A
.........
...YYY...
...yY7...
8..YYY..8
8..YYY..8
...7Yy...
...YYY...
.........
AAa...aAA
]]
local map03 = [[
BBBBBBBBBBB```````````````````````
XXXXXXXXXXBBDDDDD`````````````````
.........XXBZZZZD`````````````````
.....BB..tXBZ..ZD`````````````````
.........XBBZ..ZDDDDDDDD``````````
A1AA+AAaAAADZ..ZZZZZZZZD``````````
........pWAp....pZZZ..ZD``````````
...YYY...tA......8ZZ..ZD``````````
...yY7....=...........ZD``````````
8..YYY....A......ZZZZZZD``````````
8..YYY....A......zZZZZZD``````````
...7Yy....=...........ZD``````````
...YYY...tA......8ZZ..ZD``````````
........pWAp....pZZZ..ZD``````````
AA1AAAAaAAAZzZZzZZZZZZZD``````````
``````````DDDDDDDDDDDDDD``````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
]]
local map_items = [[
``````````````````````````````````````````````````````````````````````````````
`````````````````````````BBBBBBBBBBBBBBBBBBBBBBBBBBBBB````````````````````````
````````````````````````BBhhhhhhhhhhhhhhhhhhhhhhhhhhhBB`DDDD``````````````````
````````````````````````BphhBBhhhhhBBhhhhhBBhhhhhBBhhtB`D..D``````````````````
````````````````````````BB...........................BB`D..D``````````````````
``````````````````CCCCCCCAAAAA=AAAAAAAA=AAAAAAAA=AAAAADDD..DDD`DDDD```````````
``````````````````C....pAAp...j..J.....R.....J..j...pAAp....pD`D..D```````````
``````````````````CCC...At.!.YYY....+.YYY.!....YYY.+.tA......DDD..D```````````
````````````````````C...=....YYY......YYY......YYY....=...........D```````````
````````````````````C...A..L.YYY..DD..YYY..DD..YYY.L..A......DDDDDD```````````
````````````````````C...A....YYY..DD..YYY..DD..YYY....A......DDDDDD```````````
````````````````````C...=..j.YYY......YYY......YYY.j..=...........D```````````
``````````````````CCC...At...YYY.l....YYY....l.YYY...tA......DDD..D```````````
``````````````````C....pAAp...J........S........J...pAAp....pD`D..D```````````
``````````````````CCCCCCCAAAAAAAAAAAAA...AAAAAAAAAAAAADDDDDDDD`DDDD```````````
```````````````````````````````````###===###``````````````````````````````````
```````````````````````````````````#:P:::P:#``````````````````````````````````
```````````````````````````````````|:::::::|``````````````````````````````````
```````````````````````````````````#:T:M:C:#``````````````````````````````````
```````````````````````````````````###---###``````````````````````````````````
]]

local _TICKS_TIL_WAVE1_DONE = 120
local item_translation_1 =  {
  ['M'] = { sid = "garmor",   rate = 120, rate_next = 0, },
  ['R'] = { sid = "bazooka",  count = 5, },
  ['S'] = { sid = "skminigun", },
  ['+'] = { sid = "smed", count = 5, rate = 30, rate_next = 30, },
  ['!'] = { sid = "smed", count = 5, rate = 90, rate_next = 30, },
  ['j'] = { sid = "ammo",   count =  5, ammo = 50, },
  ['J'] = { sid = "ammo",   count = 10, ammo = 50, },
  ['l'] = { sid = "rocket", count =  5, ammo = 5, rate = 120, rate_next = 60 },
  ['L'] = { sid = "rocket", count = 10, ammo = 5, rate = 120, rate_next = 60 },
}
local item_translation_1a =  {
  ['M'] = { sid = "sboots",   rate = 120, rate_next = 10, },
}
local being_translation_1a = {
  ['h'] = { beings = { {sid = "wolf_guard", count = 100, }, }, rate = math.floor(_TICKS_TIL_WAVE1_DONE / 100), rate_next = 0, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_RANDOM, },
}
local being_translation_1b = {
  ['h'] = { beings = { {sid = "wolf_dog",   count =  70, }, }, rate = math.floor(_TICKS_TIL_WAVE1_DONE /  70), rate_next = 0, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_RANDOM, },
}
local being_translation_1c = {
  ['h'] = { beings = { {sid = "wolf_ss",    count =  40, }, }, rate = math.floor(_TICKS_TIL_WAVE1_DONE /  40), rate_next = 0, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_RANDOM, },
}


local _WAVE1_COUNT = 210
local _wave = 1
local _dead_guys = 0
local _next_reward = math.random(45) + 15
local check_wave_1_reward = function()
    if(_dead_guys >= _WAVE1_COUNT) then
      local item = Elevator.Level.DropItemNearPlayer( "uoarmor", 5)
      item.flags[IF_NODESTROY] = true

      Elevator.SpawnEngine.ClearSpawns()
      Elevator.WaveEngine.Next(false)
    end
end
local check_mod_reward = function()
    _next_reward = _next_reward - 1
    if(_next_reward <= 0) then
      --Drop a mod somewhere for kicks
      Elevator.Level.DropItemNearPlayer( table.random_pick({"mod_agility","mod_bulk","mod_tech","mod_power"}), 7 )
      _next_reward = math.random(45) + 15
    end
end

local wolf_1 = {

  name = "wolf 1",

  OnLoad = function()

    local translation = {
      ['`'] = "void",
      ['.'] = "floor",
      ['p'] = "plant1",
      ['t'] = "plant2",
      ['A'] = { "wolf_whwall", flags = { LFPERMANENT } },
      ['B'] = { "wolf_blwall", flags = { LFPERMANENT } },
      ['C'] = { "wolf_brwall", flags = { LFPERMANENT } },
      ['D'] = { "wolf_rewall", flags = { LFPERMANENT } },
      ['a'] = "wolf_f1whwall_x",
--    ['b'] = "wolf_f1blwall",
      ['c'] = "wolf_f1brwall_x",
      ['d'] = "wolf_f1rewall_x",
      ['1'] = "wolf_f2whwall_x",
--    ['2'] = "wolf_f2blwall",
      ['3'] = "wolf_f2brwall_x",
      ['4'] = "wolf_f2rewall_x",
      ['W'] = "wolf_whwall",
      ['X'] = "wolf_blwall",
      ['Y'] = "wolf_brwall",
      ['Z'] = "wolf_rewall",
      ['w'] = "wolf_f1whwall",
--    ['x'] = "wolf_f1blwall",
      ['y'] = "wolf_f1brwall",
      ['z'] = "wolf_f1rewall",
      ['5'] = "wolf_f2whwall",
--    ['6'] = "wolf_f2blwall",
      ['7'] = "wolf_f2brwall",
      ['8'] = "wolf_f2rewall",
      ['+'] = { "wolf_door1", flags = { LFPERMANENT } },
      ['='] = { "wolf_ldoor1", flags = { LFPERMANENT } },
    }

    generator.place_tile( translation, map01,  1, 1 )
    generator.place_tile( translation, map02, 36, 1 )
    generator.place_tile( translation, map03, 45, 1 )
    level.danger_level = 5
    generator.transmute("edoor", "oedoor")

    Elevator.ItemEngine.PauseSounds(true)
    Elevator.ItemEngine.AddMap( item_translation_1, map_items, coord.new(1, 1) )
    Elevator.ItemEngine.AddMap( item_translation_1a, map_items, coord.new(1, 1) )
    Elevator.ItemEngine.CheckItems()
    Elevator.ItemEngine.PauseSounds(false)
    Elevator.SpawnEngine.AddMap( being_translation_1a, map_items, coord.new(1, 1) )
    Elevator.SpawnEngine.AddMap( being_translation_1b, map_items, coord.new(1, 1) )
    Elevator.SpawnEngine.AddMap( being_translation_1c, map_items, coord.new(1, 1) )
    Elevator.HUD.Reset()

    core.play_music("FIREFIEL")

      --_dead_guys = _WAVE1_COUNT
      --check_wave_1_reward()
  end,

  OnTick = function()
    --do nothing
  end,

  OnKill = function(being)
    _dead_guys = _dead_guys + 1

    --Wave handling
    if(    _wave == 1) then check_wave_1_reward()
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

Elevator.WaveEngine.Add(wolf_1)