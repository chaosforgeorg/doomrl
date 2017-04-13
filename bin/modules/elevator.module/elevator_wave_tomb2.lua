local map_items = [[
````````````````````````````````#XcckkkkkkkccX##############``````````````````
```````````````````##############XccbbbbbbbccX#XXXXoo....ii#``````````````````
```````````````````#####XXXXXXXXXX...,,,,,...X#oo...iii...i#``````````````````
```````````````````##..Y............,,,,,,,...ZZZZ.oo#######``````````````````
```````````````````#####.............,,,,,.......Z####XXXXX#``````````````````
```````````````````##..Y........;;;;;;;;;;;;;;;##.......,,X#``````````````````
```````````````````#####........;....2...3....;##.......X,X#``````````````````
```````````````````##..Y........;.1.........4.;....,....,,X#``````````````````
```````````````````#####........;.............;...,,,...X,X#``````````````````
```````````````````#X,,.........;.8.........5.;....,....,,X#``````````````````
```````````````````#X,X.......##;....7...6....;##.......X,X#``````````````````
```````````````````#X,,.......##;;;;;;;;;;;;;;;##.......,,X#``````````````````
```````````````````#X,X...........,.........,...........X,X#``````````````````
```````````````````#X,,X,X.......,,,.......,,,.......X,X,,X#``````````````````
```````````````````#Xa,,,,,,,.....,.........,.....,,,,,,,zX#``````````````````
```````````````````#XXXXXXXXXXXXXXX###===###XXXXXXXXXXXXXXX#``````````````````
```````````````````#################:P:::P:#################``````````````````
```````````````````````````````````|:::::::|``````````````````````````````````
```````````````````````````````````#:T:::C:#``````````````````````````````````
```````````````````````````````````###---###``````````````````````````````````
]]


local _TICKS_TIL_WAVE1_DONE = 500
local being_translation_1 = {
  ['c'] = { beings = { {sid = "sanddemon",      count = 20, adjust = -1/3, }, }, rate = math.floor((_TICKS_TIL_WAVE1_DONE - math.random(30))       / 20), rate_next = math.random(30),       coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM },
  ['k'] = { beings = { {sid = "skeletonarcher", count = 20,                }, }, rate = math.floor((_TICKS_TIL_WAVE1_DONE - math.random(30))       / 20), rate_next = math.random(30),       coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM },
  ['b'] = { beings = { {sid = "suicidebrute",   count = 20,                }, }, rate = math.floor((_TICKS_TIL_WAVE1_DONE - math.random(30) - 150) / 20), rate_next = math.random(30) + 150, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM },
  ['o'] = { beings = { {sid = "duke_octabrain", count = 12,                },
                       {sid = "cacodemon",      count = 12, adjust = -1/3, }, }, rate = math.floor((_TICKS_TIL_WAVE1_DONE - math.random(30))       / 24), rate_next = math.random(30),       coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
  ['i'] = { beings = { {sid = "darkimp",        count = 20,                },
                       {sid = "anubis",         count = 5,  adjust = -2/3, }, }, rate = math.floor((_TICKS_TIL_WAVE1_DONE - math.random(30))       / 25), rate_next = math.random(30),       coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
}
local being_translation_2 = {
  ['a'] = { beings = { {sid = "avatar", count = 1, adjust = -2/3 }, }, },
  ['z'] = { beings = { {sid = "avatar", count = 1, adjust = -2/3 }, }, },
}
local being_translation_3 = {
  ['1'] = { beings = { {sid = "diabloist", count = 1, adjust = -1/2 }, }, rate_next = 0,  },
  ['2'] = { beings = { {sid = "diabloist", count = 1, adjust = -1/2 }, }, rate_next = 10, },
  ['3'] = { beings = { {sid = "diabloist", count = 1, adjust = -1/2 }, }, rate_next = 20, },
  ['4'] = { beings = { {sid = "diabloist", count = 1, adjust = -1/2 }, }, rate_next = 30, },
  ['5'] = { beings = { {sid = "diabloist", count = 1, adjust = -1/3 }, }, rate_next = 40, },
  ['6'] = { beings = { {sid = "diabloist", count = 1, adjust = -1/3 }, }, rate_next = 50, },
  ['7'] = { beings = { {sid = "diabloist", count = 1, adjust = -1/3 }, }, rate_next = 60, },
  ['8'] = { beings = { {sid = "diabloist", count = 1, adjust = -1/3 }, }, rate_next = 70, },
}


local _WAVE1_COUNT = 109
local _WAVE2_COUNT = 2
local _WAVE3_COUNT = 8
local _wave = 1
local _dead_guys = 0
local _next_reward = math.random(10) + 15
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
      _wave = 3
      _dead_guys = 0

      Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_3, map_items, coord.new(1, 1) )
    end

end
local check_wave_3_reward = function()

    if(_dead_guys >= _WAVE3_COUNT) then
      local roll
      repeat
        roll = table.random_pick({"ucpistol", "ublaster", "uashotgun", "udshotgun"})
      until not player.drops[roll]

      player.drops[roll] = true
      local item = Elevator.Level.DropItemNearPlayer(roll, 5)
      if (item) then item.flags[IF_NODESTROY] = true end

      Elevator.SpawnEngine.ClearSpawns()
      Elevator.WaveEngine.Next(false)
    end
end
local check_mod_reward = function()
    _next_reward = _next_reward - 1
    if(_next_reward <= 0) then
      --Drop a mod somewhere for kicks
      Elevator.Level.DropItemNearPlayer( table.random_pick({"mod_agility","mod_bulk","mod_tech","mod_power"}), 7 )
      _next_reward = math.random(10) + 15
    end
end


local tomb_2 = {

  name = "tomb 2",

  OnLoad = function()

    level.danger_level = 2
    generator.transmute("edoor", "oedoor")

    Elevator.ItemEngine.ResetRates()
    Elevator.SpawnEngine.AddMap( being_translation_1, map_items, coord.new(1, 1) )
    Elevator.HUD.Reset()

      --_dead_guys = _WAVE3_COUNT
      --check_wave_3_reward()
  end,

  OnTick = function()
    --The doors STAY open on this one.  You have a freaking lava pit keeping most enemies at bay.
  end,

  OnKill = function(being)
    _dead_guys = _dead_guys + 1

    --Wave handling
    if(    _wave == 1) then check_wave_1_reward()
    elseif(_wave == 2) then check_wave_2_reward()
    elseif(_wave == 3) then check_wave_3_reward()
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

Elevator.WaveEngine.Add(tomb_2)