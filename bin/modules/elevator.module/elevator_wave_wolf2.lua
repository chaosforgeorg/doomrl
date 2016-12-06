
local map_beings = [[
``````````````````````````````````````````````````````````````````````````````
`````````````````````````BBBBBBBBBBBBBBBBBBBBBBBBBBBBB````````````````````````
````````````````````````BBhhhhhhhhhhhhhhhhhhhhhhhhhhhBB`DDDD``````````````````
````````````````````````BphhBBhhhhhBBhhhhhBBhhhhhBBhhtB`DiiD``````````````````
````````````````````````BB...........................BB`DiiD``````````````````
``````````````````CCCCCCCAAAAA=AAAAAAAA=AAAAAAAA=AAAAADDD..DDD`DDDD```````````
``````````````````CiiiipAAp...j..J.....R.....J..j...pAAp...ipD`DiiD```````````
``````````````````CCCii.At.!.YYY....+.YYY.!....YYY.+.tA.....iDDDiiD```````````
````````````````````Cii.=....YYY......YYY......YYY....=.........iiD```````````
````````````````````Cii.A..L.YYY..DD..YYY..DD..YYY.L..A......DDDDDD```````````
````````````````````Cii.A....YYY..DD..YYY..DD..YYY....A......DDDDDD```````````
````````````````````Cii.=..j.YYY......YYY......YYY.j..=.........iiD```````````
``````````````````CCCii.At...YYY.l....YYY....l.YYY...tA.....iDDDiiD```````````
``````````````````CiiiipAAp...J........S........J...pAAp...ipD`DiiD```````````
``````````````````CCCCCCCAAAAAAAAAAAAA...AAAAAAAAAAAAADDDDDDDD`DDDD```````````
```````````````````````````````````###===###``````````````````````````````````
```````````````````````````````````#:P:::P:#``````````````````````````````````
```````````````````````````````````|:::::::|``````````````````````````````````
```````````````````````````````````#:T:M:C:#``````````````````````````````````
```````````````````````````````````###---###``````````````````````````````````
]]

local _TICKS_TIL_WAVE1_DONE = 120
local being_translation_1a = {
  ['h'] = { beings = { {sid = "wolf_guard",  count = 40, },
                       {sid = "wolf_nguard", count = 10, }, }, rate = math.floor(_TICKS_TIL_WAVE1_DONE / 50), rate_next = 0, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, },
  ['i'] = { beings = { {sid = "wolf_guard",  count = 40, },
                       {sid = "wolf_nguard", count = 10, }, }, rate = math.floor(_TICKS_TIL_WAVE1_DONE / 50), rate_next = 0, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, },
  }
local being_translation_1b = {
  ['h'] = { beings = { {sid = "wolf_dog",    count = 40, },
                       {sid = "wolf_ndog",   count = 10, }, }, rate = math.floor(_TICKS_TIL_WAVE1_DONE / 50), rate_next = 0, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, },
  ['i'] = { beings = { {sid = "wolf_ss",     count = 40, },
                       {sid = "wolf_nss",    count = 10, }, }, rate = math.floor(_TICKS_TIL_WAVE1_DONE / 50), rate_next = 0, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, },
}

local _WAVE1_COUNT = 200
local _wave = 1
local _dead_guys = 0
local _next_reward = math.random(45) + 15
local check_wave_1_reward = function()
    if(_dead_guys >= _WAVE1_COUNT) then
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
      _next_reward = math.random(45) + 15
    end
end

local wolf_2 = {

  name = "wolf 2",

  OnLoad = function()
    level.danger_level = 6
    Elevator.ItemEngine.ResetRates()
    Elevator.SpawnEngine.AddMap( being_translation_1a, map_beings, coord.new(1, 1) )
    Elevator.SpawnEngine.AddMap( being_translation_1b, map_beings, coord.new(1, 1) )
    Elevator.HUD.Reset()

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

Elevator.WaveEngine.Add(wolf_2)