local map01 = [[
```````````````````````````````````
```````````````````````````````````
```````````````````````````````````
``````````````````````````````````S
````````````````````````````````SSS
```````````````````````````````SS..
``````````````````````````````SS...
`````````````````````````````SSVVV.
`````````````````````````````S...VS
`````````````````````````````S.X..S
`````````````````````````````SS....
``````````````````````````````SS...
```````````````````````````````SS..
````````````````````````````````SSS
``````````````````````````````````S
```````````````````````````````````
```````````````````````````````````
```````````````````````````````````
```````````````````````````````````
```````````````````````````````````
]]
local map02 = [[
`````````
`````````
`SSSSSSS`
SS.....SS
.........
...SSS...
.SSS`SSS.
SS`````SS
S```````S
S```````S
SS`````SS
.SSS`SSS.
...SSSV..
.....VV..
SS....VSS
]]
local map03 = [[
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
S`````````````````````````````````
SSS```````````````````````````````
..SS``````````````````````````````
...SS`````````````````````````````
....SS````````````````````````````
S....S````````````````````````````
S....S````````````````````````````
....SS````````````````````````````
...SS`````````````````````````````
..SS``````````````````````````````
SSS```````````````````````````````
S`````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
]]
local map_items = [[
``````````````````````````````````````````````````````````````````````````````
``````````````````````````````````````````````````````````````````````````````
````````````````````````````````````SSSSSSS```````````````````````````````````
``````````````````````````````````SSS.....SSS`````````````````````````````````
````````````````````````````````SSS.........SSS```````````````````````````````
```````````````````````````````SS.....SSS.....SS``````````````````````````````
``````````````````````````````SS....SSS`SSS....SS`````````````````````````````
`````````````````````````````SSVVV.SS`````SS....SS````````````````````````````
`````````````````````````````S131VSS```````SS....S````````````````````````````
`````````````````````````````S3X11SS```````SS....S````````````````````````````
`````````````````````````````SS11J1SS`````SS....SS````````````````````````````
``````````````````````````````SS1222SSS`SSS....SS`````````````````````````````
```````````````````````````````SS2222.SSSV....SS``````````````````````````````
````````````````````````````````SSS2.j..VV..SSS```````````````````````````````
``````````````````````````````````SSS..H.VSSS`````````````````````````````````
```````````````````````````````````###===###``````````````````````````````````
```````````````````````````````````#:P:::P:#``````````````````````````````````
```````````````````````````````````|:::::::|``````````````````````````````````
```````````````````````````````````#:T:M:C:#``````````````````````````````````
```````````````````````````````````###---###``````````````````````````````````
]]


local _TICKS_TIL_WAVE1_DONE = 200
local _TICKS_TIL_WAVE2_DONE = 0
local item_translation_1 =  {
  ['M'] = { sid = "barmor",   rate = 120, rate_next = 0, },
  ['H'] = { sid = "plasma",  count = 5, rate = 120, rate_next = 60 },
  ['j'] = { sid = "cell",   count = 10, rate = 60, ammo = 20, },
  ['J'] = { sid = "cell",   count =  5, rate = 90, ammo = 20, },
}
local item_translation_1a =  {
  ['M'] = { sid = "pboots",   rate = 120, rate_next = 10, },
}
local being_translation_1 = {
  ['1'] = { beings = { {sid = "uimp",      count = 60, }, }, rate = math.floor( _TICKS_TIL_WAVE1_DONE                                  / 60), rate_next = 0 ,                           coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, },
  ['2'] = { beings = { {sid = "uimp",      count = 20, }, }, rate = math.floor((_TICKS_TIL_WAVE1_DONE - (_TICKS_TIL_WAVE1_DONE   / 3)) / 20), rate_next = _TICKS_TIL_WAVE1_DONE    / 3, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, },
  ['3'] = { beings = { {sid = "urevenant", count = 20, }, }, rate = math.floor((_TICKS_TIL_WAVE1_DONE - (_TICKS_TIL_WAVE1_DONE*2 / 3)) / 20), rate_next = _TICKS_TIL_WAVE1_DONE*2  / 3, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, },
}
local being_translation_2 = {
  ['3'] = { beings = { {sid = "usdorb", count = 2, }, }, rate = math.floor(_TICKS_TIL_WAVE2_DONE / 2), rate_next = 5, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, },
}

local _WAVE1_COUNT = 100
local _WAVE2_COUNT = 2
local _wave = 1
local _dead_guys = 0
local _next_reward = math.random(15) + 15
local check_wave_1_reward = function()

    if(_dead_guys >= _WAVE1_COUNT) then
      _wave = 2
      _dead_guys = 0

      Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_2, map_items, coord.new(1, 1) )
    end
end
local check_wave_2_reward = function()

    if(_dead_guys >= _WAVE2_COUNT) then
      local roll
      repeat
        roll = table.random_pick({"umod_sniper", "umod_firestorm"})
      until not player.drops[roll]

      player.drops[roll] = true
      local item = Elevator.Level.DropItemNearPlayer(roll, 5)

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

local future_1 = {

  name = "future 1",

  OnLoad = function()

    local translation = {
      ['`'] = "void",
      ['.'] = "ceiling",
      ['V'] = { "futuredropwall", flags = { LFPERMANENT } },
      ['S'] = { "futurewall", flags = { LFPERMANENT } },
      ['X'] = { "futurepillar", flags = { LFPERMANENT } },
    }

    generator.place_tile( translation, map01,  1, 1 )
    generator.place_tile( translation, map02, 36, 1 )
    generator.place_tile( translation, map03, 45, 1 )
    level.danger_level = 7
    generator.transmute("edoor", "oedoor")

    Elevator.ItemEngine.PauseSounds(true)
    Elevator.ItemEngine.AddMap( item_translation_1, map_items, coord.new(1, 1) )
    Elevator.ItemEngine.AddMap( item_translation_1a, map_items, coord.new(1, 1) )
    Elevator.ItemEngine.CheckItems()
    Elevator.ItemEngine.PauseSounds(false)
    Elevator.SpawnEngine.AddMap( being_translation_1, map_items, coord.new(1, 1) )
    Elevator.HUD.Reset()

    core.play_music("REACT1")

      --_dead_guys = _WAVE2_COUNT
      --check_wave_2_reward()
  end,

  OnTick = function()
    --do nothing
  end,

  OnKill = function(being)
    _dead_guys = _dead_guys + 1

    --Wave handling
    if(    _wave == 1) then check_wave_1_reward()
    elseif(_wave == 2) then check_wave_2_reward()
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

Elevator.WaveEngine.Add(future_1)