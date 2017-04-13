local map_beings = [[
``````````````````````````````````````````````````````````````````````````````
```````````````````````````````....````````..`````````````````````````````````
````````````````````..```..```.....```..```....`````...```````````````````````
```````````````````....MMMMMMMM..6543219123456..MMMMMMMM..````````````````````
```````````````````....XX....3219MMMMMMMMMMMMM9123....XX.....`````````````````
````````````````````...XX.654.....MMMMMMMMMMM.....456.XX.....`````````````````
``````````````````......29.........MMMMMMMMM.........91....```````````````````
````````````````````...3..........M7MMM0MMM7M..........2...```````````````````
`````````````````......4.........M.MMM8M8MMM.M.........3...```````````````````
`````````````````......5..........M7MMMMMMM7M..........4....``````````````````
```````````````````....6...........MMM...MMM...........5...```````````````````
````````````````````....19...........MMMMM...........96.........``````````````
````````````````.......XX.123......M.MMMMM.M......321.XX......````````````````
````````````````````...XX....4569..M.M...M.M..9654....XX.......```````````````
``````````````````.......`.......12.........21.............```````````````````
````````````````````...``````...```###===###`.....````......``````````````````
```````````````````..``````````````#:P:::P:#```````````.....``````````````````
```````````````````````````````````|:::::::|``````````````````````````````````
```````````````````````````````````#:T:::C:#``````````````````````````````````
```````````````````````````````````###---###``````````````````````````````````
]]

--Now you trade staggering for all at once.  Fun!
local being_translation_1 =  {
  ['9'] = { beings = { {sid = "skeletonarcher", count = 9, }, }, rate = 0, rate_next = 20, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 9, 8, 1, 7, 2, 6, 3, 5, 4, }, },
}
local being_translation_2 =  {
  ['9'] = { beings = { {sid = "skeletonarcher", count = 9, }, }, rate = 0, rate_next = 20, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 8, 7, 9, 6, 1, 5, 2, 4, 3, }, },
}
local being_translation_3 =  {
  ['9'] = { beings = { {sid = "cyberknight",    count = 9, }, }, rate = 0, rate_next = 20, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 7, 6, 8, 5, 9, 4, 1, 3, 2, }, },
}
local being_translation_4 =  {
  ['9'] = { beings = { {sid = "cyberknight",    count = 9, }, }, rate = 0, rate_next = 20, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 6, 5, 7, 4, 8, 3, 9, 2, 1, }, },
}
local being_translation_5 =  {
  ['1'] = { beings = { {sid = "blood_browncultist", count = 10, }, }, rate = 0, rate_next = 10, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 5, 6, 4, 7, 8, 3, 2, 9, 1, 10, }, },
  ['2'] = { beings = { {sid = "blood_redcultist",   count = 10, }, }, rate = 0, rate_next = 20, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 4, 5, 3, 6, 2, 7, 1, 8, 10, 9, }, },
  ['3'] = { beings = { {sid = "blood_greencultist", count =  8, }, }, rate = 0, rate_next = 30, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 3, 4, 2, 5, 1, 6, 8, 7, }, },
  ['4'] = { beings = { {sid = "blood_graycultist",  count =  8, }, }, rate = 0, rate_next = 40, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 2, 3, 1, 4, 8, 5, 7, 6, }, },
  ['5'] = { beings = { {sid = "blood_whitecultist", count =  8, }, }, rate = 0, rate_next = 50, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 1, 2, 8, 3, 7, 4, 6, 5, }, },
  ['6'] = { beings = { {sid = "blood_bluecultist",  count =  8, }, }, rate = 0, rate_next = 60, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 8, 1, 7, 2, 6, 3, 5, 4, }, },
}
local being_translation_6  = {
  ['1'] = { beings = { {sid = "blood_browncultist", count = 10, }, }, rate = 0, rate_next = 10, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 5, 6, 4, 7, 8, 3, 2, 9, 1, 10, }, },
  ['2'] = { beings = { {sid = "blood_redcultist",   count = 10, }, }, rate = 0, rate_next = 20, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 4, 5, 3, 6, 2, 7, 1, 8, 10, 9, }, },
  ['3'] = { beings = { {sid = "blood_greencultist", count =  8, }, }, rate = 0, rate_next = 30, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 3, 4, 2, 5, 1, 6, 8, 7, }, },
  ['4'] = { beings = { {sid = "blood_graycultist",  count =  8, }, }, rate = 0, rate_next = 40, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 2, 3, 1, 4, 8, 5, 7, 6, }, },
  ['5'] = { beings = { {sid = "blood_whitecultist", count =  8, }, }, rate = 0, rate_next = 50, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 1, 2, 8, 3, 7, 4, 6, 5, }, },
  ['6'] = { beings = { {sid = "blood_bluecultist",  count =  8, }, }, rate = 0, rate_next = 60, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 8, 1, 7, 2, 6, 3, 5, 4, }, },
}
local being_translation_7  = {
  ['9'] = { beings = { {sid = "cacolich",     count = 9, }, }, rate = 0, rate_next = 10, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 8, 7, 9, 6, 1, 5, 2, 4, 3, }, },
}
local being_translation_8  = {
  ['9'] = { beings = { {sid = "cacolich",     count = 9, }, }, rate = 0, rate_next = 10, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 7, 6, 8, 5, 9, 4, 1, 3, 2, }, },
}
local being_translation_9  = {
  ['6'] = { beings = { {sid = "inquisitor",   count = 8, }, }, rate = 0, rate_next = 10, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR, seqcoordorder = { 5, 6, 4, 7, 3, 8, 2, 1, }, },
}
local being_translation_10 = {
  ['7'] = { beings = { {sid = "avatar",       count = 4, }, }, rate = 0, rate_next = 10, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
}
local being_translation_11 = {
  ['8'] = { beings = { {sid = "duke_cycloid", count = 2, }, }, rate = 0, rate_next = 10, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
  ['0'] = { beings = { {sid = "mastermind",   count = 1, }, }, rate = 0, rate_next = 25, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
}

local _WAVE1_COUNT  = 7  --Actually  9
local _WAVE2_COUNT  = 9  --Actually  9
local _WAVE3_COUNT  = 9  --Actually  9
local _WAVE4_COUNT  = 11 --Actually  9
local _WAVE5_COUNT  = 42 --Actually 52
local _WAVE6_COUNT  = 62 --Actually 52
local _WAVE7_COUNT  =  4 --Actually  9
local _WAVE8_COUNT  = 14 --Actually  9
local _WAVE9_COUNT  =  8 --Actually  8
local _WAVE10_COUNT =  4 --Actually  4
local _WAVE11_COUNT =  3 --Actually  3
local _wave = 1
local _dead_guys = 0
local _next_reward = math.random(15) + 20
local check_wave_1_reward  = function()

    if(_dead_guys >= _WAVE1_COUNT) then
      _wave = 2
      _dead_guys = 0

      --Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_2, map_beings, coord.new(1, 1) )
    end
end
local check_wave_2_reward  = function()

    if(_dead_guys >= _WAVE2_COUNT) then
      _wave = 3
      _dead_guys = 0

      --Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_3, map_beings, coord.new(1, 1) )
    end
end
local check_wave_3_reward  = function()

    if(_dead_guys >= _WAVE3_COUNT) then
      _wave = 4
      _dead_guys = 0

      --Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_4, map_beings, coord.new(1, 1) )
    end
end
local check_wave_4_reward  = function()

    if(_dead_guys >= _WAVE4_COUNT) then
      _wave = 5
      _dead_guys = 0

      Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_5, map_beings, coord.new(1, 1) )
    end
end
local check_wave_5_reward  = function()

    if(_dead_guys >= _WAVE5_COUNT) then
      _wave = 6
      _dead_guys = 0

      --Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_6, map_beings, coord.new(1, 1) )
    end
end
local check_wave_6_reward  = function()

    if(_dead_guys >= _WAVE6_COUNT) then
      _wave = 7
      _dead_guys = 0

      Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_7, map_beings, coord.new(1, 1) )
    end
end
local check_wave_7_reward  = function()

    if(_dead_guys >= _WAVE7_COUNT) then
      _wave = 8
      _dead_guys = 0

      --Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_8, map_beings, coord.new(1, 1) )
    end
end
local check_wave_8_reward  = function()

    if(_dead_guys >= _WAVE8_COUNT) then
      _wave = 9
      _dead_guys = 0

      Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_9, map_beings, coord.new(1, 1) )
    end
end
local check_wave_9_reward  = function()

    if(_dead_guys >= _WAVE9_COUNT) then
      _wave = 10
      _dead_guys = 0

      Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_10, map_beings, coord.new(1, 1) )
    end
end
local check_wave_10_reward  = function()

    if(_dead_guys >= _WAVE10_COUNT) then
      _wave = 11
      _dead_guys = 0

      Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_11, map_beings, coord.new(1, 1) )
    end
end
local check_wave_11_reward = function()

    if(_dead_guys >= _WAVE11_COUNT) then
      Elevator.Level.DropItemNearPlayer( "umod_nano", 5)

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

local void_2 = {

  name = "void 2",

  OnLoad = function()
    level.danger_level = 10
    Elevator.ItemEngine.ResetRates()
    Elevator.ItemEngine.PauseSounds(true)
    Elevator.ItemEngine.CheckItems()
    Elevator.ItemEngine.PauseSounds(false)
    Elevator.SpawnEngine.AddMap( being_translation_1, map_beings, coord.new(1, 1) )
    Elevator.HUD.Reset()

      --_dead_guys = _WAVE11_COUNT
      --check_wave_11_reward()
  end,

  OnUnload = function()
    --Undo the knockback and kill the teleporters
    player.bodybonus = player.bodybonus - 2

    local telecoord = { coord.new(37,18), coord.new(43,18) }
    for i = 1,2 do
      local teleitem = level:get_item(telecoord[i])
      if (teleitem ~= nil and teleitem.id == "teleport") then
        teleitem:destroy()
      end
    end
  end,

  OnTick = function()
    --do nothing
  end,

  OnKill = function(being)
    _dead_guys = _dead_guys + 1

    --Wave handling
    if(    _wave == 1)  then check_wave_1_reward()
    elseif(_wave == 2)  then check_wave_2_reward()
    elseif(_wave == 3)  then check_wave_3_reward()
    elseif(_wave == 4)  then check_wave_4_reward()
    elseif(_wave == 5)  then check_wave_5_reward()
    elseif(_wave == 6)  then check_wave_6_reward()
    elseif(_wave == 7)  then check_wave_7_reward()
    elseif(_wave == 8)  then check_wave_8_reward()
    elseif(_wave == 9)  then check_wave_9_reward()
    elseif(_wave == 10) then check_wave_10_reward()
    elseif(_wave == 11) then check_wave_11_reward()
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

Elevator.WaveEngine.Add(void_2)