local map_beings = [[
``````````````````````````````````````````````````````````````````````````````
``````````````````````````````````````````````````````````````````````````````
````````````````````````````````````SSSSSSS```````````````````````````````````
``````````````````````````````````SSS1.h.1SSS`````````````````````````````````
````````````````````````````````SSS.2J3.2j3.SSS```````````````````````````````
```````````````````````````````SS....4SSS4....SS``````````````````````````````
``````````````````````````````SS.1..SSS`SSS..1.SS`````````````````````````````
`````````````````````````````SSV2j3SS`````SS2J3.SS````````````````````````````
`````````````````````````````S...4SS```````SS4...S````````````````````````````
`````````````````````````````S.X.1SS```````SS1...S````````````````````````````
`````````````````````````````SS.2.3SS`````SS2j3.SS````````````````````````````
``````````````````````````````SS.4..SSS`SSS..4.SS`````````````````````````````
```````````````````````````````SS....1SSS1....SS``````````````````````````````
````````````````````````````````SSS.2.3.2J3.SSS```````````````````````````````
``````````````````````````````````SSS4...4SSS`````````````````````````````````
```````````````````````````````````###===###``````````````````````````````````
```````````````````````````````````#:P:::P:#``````````````````````````````````
```````````````````````````````````|:::::::|``````````````````````````````````
```````````````````````````````````#:T:::C:#``````````````````````````````````
```````````````````````````````````###---###``````````````````````````````````
]]

local _TICKS_TIL_WAVE1_DONE = 700
local _TICKS_TIL_WAVE2_DONE = 0
local item_translation =  {
  ['h'] = { sid = "lmed",   count =  5, rate = 120, ammo = 20, },
  ['j'] = { sid = "cell",   count = 10, rate =  60, ammo = 20, },
  ['J'] = { sid = "cell",   count =  5, rate =  90, ammo = 20, },
}
local being_translation_1 = {
  ['1'] = { beings = { --{sid = "uimp",         count =  0, },
                         {sid = "urevenant",    count = 16, },
                         {sid = "usdorb",       count = 29, }, }, rate = math.floor(_TICKS_TIL_WAVE1_DONE / 45), rate_next = 5,                                            coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_RANDOM, seqcoordorder = { 8, 1, 7, 2, 6, 3, 5, 4, }, },
  ['2'] = { beings = {   {sid = "uimp",         count = 30, },
                         {sid = "usdorb",       count =  5, },
                         {sid = "urevenant",    count = 10, }, }, rate = math.floor(_TICKS_TIL_WAVE1_DONE / 45), rate_next = 5,                                            coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 8, 1, 7, 2, 6, 3, 5, 4, }, },
  ['3'] = { beings = {   {sid = "uimp",         count = 30, },
                         {sid = "urevenant",    count = 10, },
                         {sid = "usdorb",       count =  5, }, }, rate = math.floor(_TICKS_TIL_WAVE1_DONE / 45), rate_next = 5,                                            coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 8, 1, 7, 2, 6, 3, 5, 4, }, },
  ['4'] = { beings = {   {sid = "uimp",         count = 12, },
                       --{sid = "urevenant",    count =  0, },
                         {sid = "usdorb",       count = 33, }, }, rate = math.floor(_TICKS_TIL_WAVE1_DONE / 45), rate_next = 5,                                            coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_RANDOM, seqcoordorder = { 8, 1, 7, 2, 6, 3, 5, 4, }, },
}
local being_translation_2 = {
  ['1'] = { beings = { {sid = "ucybruiser", count = 8, }, }, rate = _TICKS_TIL_WAVE2_DONE, rate_next = 7, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, },
}

local _WAVE1_COUNT = 180
local _WAVE2_COUNT = 8
local _wave = 1
local _dead_guys = 0
local _next_reward = math.random(20) + 20
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
      local roll
      repeat
        roll = table.random_pick({"umbazooka", "ulaser"})
      until not player.drops[roll]

      player.drops[roll] = true
      local item = Elevator.Level.DropItemNearPlayer(roll, 5)
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
      _next_reward = math.random(20) + 20
    end
end

local future_2 = {

  name = "future 2",

  OnLoad = function()
    level.danger_level = 8
    Elevator.ItemEngine.ResetRates()
    Elevator.ItemEngine.PauseSounds(true)
    Elevator.ItemEngine.AddMap( item_translation, map_beings, coord.new(1, 1) )
    Elevator.ItemEngine.CheckItems()
    Elevator.ItemEngine.PauseSounds(false)
    Elevator.SpawnEngine.AddMap( being_translation_1, map_beings, coord.new(1, 1) )
    Elevator.HUD.Reset()

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

Elevator.WaveEngine.Add(future_2)