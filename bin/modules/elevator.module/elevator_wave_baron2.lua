local map_beings = [[
```````############W###W###W####``````````````````````````````````````````````
```````#.....;"'"..............#``````````````````````````````````````````````
```````#.....;"'"..............#``````````````````````````````````````````````
```````#.....###################``````````````````````````````````````````````
```````#.....#.................#``````````````````````````````````````````````
```````#.....########..........############```````````````````````````````````
```````#.....'"'"'"';..........;..........#```````````````````````````````````
```````#.....'"'"'"';..........;..........#```````````````````````````````````
```````##############..........#######....#```````````````````````````````````
````############,::::::::::....#```##~....#```````````````````````````````````
`````cacaca,,,,,,::::::::::....#```#r~....#```````````````````````````````````
`````ecacaa,,,,,,::/:::::::....#```##~....#```````````````````````````````````
`````fdbdbb,,,,,,::::::::::..,.#######....#```````````````````````````````````
`````dbdbdb,,,,,,:::::::/::..,.;..........#```````````````````````````````````
````############:::::::::::..,.;..........#```````````````````````````````````
```````````````##Z##Z##Z##Z###########===###``````````````````````````````````
```````````````````````````````````#:P:::P:#``````````````````````````````````
```````````````````````````````````|:::::::|``````````````````````````````````
```````````````````````````````````#:T:A:C:#``````````````````````````````````
```````````````````````````````````###---###``````````````````````````````````
]]

--Unlike tomb waves these are more highly structured.  Ideally two beings will spawn every round on the dot, although in practice spawn points are going to end up occupied.
local _TICKS_TIL_WAVE1_DONE = 700
local _TICKS_TIL_WAVE2_DONE = 0
local being_translation_1 = {
  ['a'] = { beings = { {sid = "knight",         count = 4, },
                     --{sid = "cyberknight",    count = 0, },
                       {sid = "cybruiser",      count = 5, },
                       {sid = "baron",          count = 2, },
                       {sid = "cyberbaron",     count = 1, },
                       {sid = "belphegor",      count = 4, },
                       {sid = "cyberbelphegor", count = 2, },
                       {sid = "bruiserdemon",   count = 1, }, }, rate = math.floor(_TICKS_TIL_WAVE1_DONE / 18), rate_next = 0,                                            coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
  ['b'] = { beings = { {sid = "knight",         count = 4, },
                     --{sid = "cyberknight",    count = 0, },
                       {sid = "cybruiser",      count = 5, },
                       {sid = "baron",          count = 2, },
                       {sid = "cyberbaron",     count = 1, },
                       {sid = "belphegor",      count = 4, },
                       {sid = "cyberbelphegor", count = 2, },
                       {sid = "bruiserdemon",   count = 1, }, }, rate = math.floor(_TICKS_TIL_WAVE1_DONE / 18), rate_next = math.floor((_TICKS_TIL_WAVE1_DONE / 72) * 1), coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
  ['c'] = { beings = { {sid = "knight",         count = 1, },
                       {sid = "cyberknight",    count = 5, },
                     --{sid = "cybruiser",      count = 0, },
                       {sid = "baron",          count = 3, },
                       {sid = "cyberbaron",     count = 4, },
                       {sid = "belphegor",      count = 1, },
                       {sid = "cyberbelphegor", count = 3, },
                       {sid = "bruiserdemon",   count = 1, }, }, rate = math.floor(_TICKS_TIL_WAVE1_DONE / 18), rate_next = math.floor((_TICKS_TIL_WAVE1_DONE / 72) * 2), coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
  ['d'] = { beings = { {sid = "knight",         count = 1, },
                       {sid = "cyberknight",    count = 5, },
                     --{sid = "cybruiser",      count = 0, },
                       {sid = "baron",          count = 3, },
                       {sid = "cyberbaron",     count = 4, },
                       {sid = "belphegor",      count = 1, },
                       {sid = "cyberbelphegor", count = 3, },
                       {sid = "bruiserdemon",   count = 1, }, }, rate = math.floor(_TICKS_TIL_WAVE1_DONE / 18), rate_next = math.floor((_TICKS_TIL_WAVE1_DONE / 72) * 3), coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
}
local being_translation_2 = {
  ['e'] = { beings = { {sid = "greatercyberbaron", count = 1, }, }, rate = _TICKS_TIL_WAVE2_DONE, rate_next = 7, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, },
  ['f'] = { beings = { {sid = "greatercyberbaron", count = 1, }, }, rate = _TICKS_TIL_WAVE2_DONE, rate_next = 7, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, },
}


local _WAVE1_COUNT = 74
local _WAVE2_COUNT = 2
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

local baron_2 = {

  name = "baron 2",

  OnLoad = function()
    level.danger_level = 4
    Elevator.ItemEngine.ResetRates()
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

Elevator.WaveEngine.Add(baron_2)