local map01 = [[
```````````````````````````````````
```````````````````````````````....
````````````````````..```..```.....
```````````````````....MMMMMMMM..MM
```````````````````....XX.....MM.MM
````````````````````...Xx.........M
``````````````````.................
````````````````````..............M
`````````````````................M.
`````````````````.................M
```````````````````................
````````````````````...............
````````````````.......Xx..........
````````````````````...XX..........
``````````````````.......`.........
````````````````````...``````...```
```````````````````..``````````````
```````````````````````````````````
```````````````````````````````````
```````````````````````````````````
]]
local map02 = [[
`````````
````````.
```.M```.
.........
MMMMMMMMM
MMMMMMMMM
MMMMMMMMM
.MMM.MMM.
MMM.M.MMM
.MMMMMMM.
MMM...MMM
..MMMMM..
M.MMMMM.M
M.M...M.M
..M...M..
]]
local map03 = [[
``````````````````````````````````
.`````````````````````````````````
...`````...```````````````````````
MM..MMMMMMMM..````````````````````
MM.MM.....XX.....`````````````````
M.........xX.....`````````````````
...............```````````````````
M..............```````````````````
.M.............```````````````````
M...............``````````````````
...............```````````````````
....................``````````````
..........xX......````````````````
..........XX.......```````````````
...............```````````````````
`.....````......``````````````````
```````````.....``````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
]]
local map_items = [[
``````````````````````````````````````````````````````````````````````````````
```````````````````````````````3...````````..`````````````````````````````````
````````````````````d.```..```.....```.R```....`````..2```````````````````````
```````````````````...kMMMMMMMM.jMM.L.....l.MMJ.MMMMMMMMK.````````````````````
```````````````````....XX...+.Ml.MMMMMMMMMMMMM.LM.!...XX....a`````````````````
````````````````````...Xx.........MMMMMMMMMMM.........xX.....`````````````````
``````````````````e......L.........MMMMMMMMM.........l.....```````````````````
````````````````````...J..........MqMMM.MMMQM..........j...```````````````````
`````````````````1...............MsMMM.M.MMMSM.............```````````````````
`````````````````.................MuMMMMMMMUM..............5``````````````````
```````````````````....j...........MMM...MMM...........J...```````````````````
````````````````````.................MMMMM.....................f``````````````
````````````````6......Xx..........M.MMMMM.M..........xX......````````````````
````````````````````...XX...!......M.M...M.M.....+....XX.......```````````````
``````````````````.......`......J....M...M....j............```````````````````
````````````````````...``````...```###===###`....c````......``````````````````
```````````````````b.``````````````#:P:::P:#```````````....4``````````````````
```````````````````````````````````|:::::::|``````````````````````````````````
```````````````````````````````````#:T:H:C:#``````````````````````````````````
```````````````````````````````````###---###``````````````````````````````````
]]
local map_beings = [[
``````````````````````````````````````````````````````````````````````````````
```````````````````````````````....````````..`````````````````````````````````
````````````````````..```..```.....```..```....`````...```````````````````````
```````````````````....MMMMMMMM.MMM9...8...9MMM.MMMMMMMM..````````````````````
```````````````````....XX....9MM.MMMMMMMMMMMMM.MM9....XX.....`````````````````
````````````````````...XX..8......MMMMMMMMMMM.......8.XX.....`````````````````
``````````````````.......9.........MMMM1MMMM..........9....```````````````````
````````````````````..............M.MM121MM.M..............```````````````````
`````````````````.......8........M.MM3.3.3MM.M.........8...```````````````````
`````````````````.......9.........M.MM454MMM.M.........9.....``````````````````
```````````````````................MMM.4.MMM...............```````````````````
````````````````````.......8.........MMMMM..........8...........``````````````
````````````````.......XX..........M.MMMMM.M..........XX......````````````````
````````````````````...XX....9.....M.M...M.M.....9....XX.......```````````````
``````````````````.......`...........M...M.................```````````````````
````````````````````...``````...```###===###`.....````......``````````````````
```````````````````..``````````````#:P:::P:#```````````.....``````````````````
```````````````````````````````````|:::::::|``````````````````````````````````
```````````````````````````````````#:T:::C:#``````````````````````````````````
```````````````````````````````````###---###``````````````````````````````````
]]

--These 'waves' are staggered.  New waves start before the old wave is finished.
local _TICKS_TIL_WAVE1_DONE = 150
local _TICKS_TIL_WAVE2_DONE = 100
local _TICKS_TIL_WAVE3_DONE = 700
local _TICKS_TIL_WAVE4_DONE = 250
local _TICKS_TIL_WAVE5_DONE = 150
local _TICKS_TIL_WAVE6_DONE = 300
local _TICKS_TIL_WAVE7_DONE = 150
local item_translation_1 =  {
  ['H'] = { sid = "rarmor",   rate = 120, rate_next = 0, },
  ['R'] = { sid = "skrailgun",  count = 1, rate = 120, rate_next = 60, },
  ['1'] = { sid = "sr_strength",     count = 1, rate = 120, rate_next =  80, },
  ['2'] = { sid = "sr_resistance",   count = 1, rate = 120, rate_next =  90, },
  ['3'] = { sid = "sr_prosperity",   count = 1, rate = 120, rate_next = 100, },
  ['4'] = { sid = "sr_regeneration", count = 1, rate = 120, rate_next = 110, },
  ['5'] = { sid = "sr_reflection",   count = 1, rate = 120, rate_next = 120, },
  ['6'] = { sid = "sr_haste",        count = 1, rate = 120, rate_next = 130, },
  ['a'] = { sid = "scglobe", count = 1, rate = 120, rate_next =  80, },
  ['b'] = { sid = "scglobe", count = 1, rate = 120, rate_next =  90, },
  ['c'] = { sid = "scglobe", count = 1, rate = 120, rate_next = 100, },
  ['d'] = { sid = "scglobe", count = 1, rate = 120, rate_next = 110, },
  ['e'] = { sid = "scglobe", count = 1, rate = 120, rate_next = 120, },
  ['f'] = { sid = "scglobe", count = 1, rate = 120, rate_next = 130, },
  ['+'] = { sid = "lmed", count =  5, rate = 110, rate_next = 110, },
  ['!'] = { sid = "lmed", count =  5, rate = 130, rate_next =  90, },
  ['j'] = { sid = "ammo",   count = 10, rate = 50, ammo = 50, },
  ['J'] = { sid = "ammo",   count = 10, rate = 70, ammo = 50, },
  ['k'] = { sid = "rocket", count = 10, rate = 60, ammo =  5, },
  ['K'] = { sid = "rocket", count = 10, rate = 80, ammo =  5, },
  ['l'] = { sid = "cell",   count = 10, rate = 70, ammo = 20, },
  ['L'] = { sid = "cell",   count = 10, rate = 90, ammo = 20, },
}
local item_translation_1a =  {
  ['H'] = { sid = "psboots",   rate = 120, rate_next = 10, },
}
local item_translation_2 =  {
  ['q'] = { sid = "bazooka", count = 1, rate = 200, rate_next = 60, },
  ['Q'] = { sid = "plasma",  count = 1, rate = 200, rate_next = 60, },
}
local item_translation_3 =  {
  ['s'] = { sid = "bazooka", count = 1, rate = 200, rate_next = 60, },
  ['S'] = { sid = "plasma",  count = 1, rate = 200, rate_next = 60, },
}
local item_translation_4 =  {
  ['u'] = { sid = "bazooka", count = 1, rate = 200, rate_next = 60, },
  ['U'] = { sid = "plasma",  count = 1, rate = 200, rate_next = 60, },
}
if (math.random(2) == 1) then item_translation_2['q'], item_translation_2['Q'] = item_translation_2['Q'], item_translation_2['q'] end
if (math.random(2) == 1) then item_translation_2['s'], item_translation_2['S'] = item_translation_2['S'], item_translation_2['s'] end
if (math.random(2) == 1) then item_translation_2['u'], item_translation_2['U'] = item_translation_2['U'], item_translation_2['u'] end

local being_translation_1 = {
  ['1'] = { beings = { {sid = "former",            count =  5, },
                       {sid = "sergeant",          count =  5, },
                       {sid = "major",             count =  5, },
                       {sid = "captain",           count =  5, },
                       {sid = "commando",          count =  5, }, }, rate = math.floor((_TICKS_TIL_WAVE1_DONE -  5) /     25), rate_next =  5, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
  ['2'] = { beings = { {sid = "zerker",            count =  5, },
                       {sid = "rocketeer",         count =  3, },
                       {sid = "railgunner",        count =  1, }, }, rate = math.floor((_TICKS_TIL_WAVE1_DONE -  5) /      9), rate_next =  5, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
  ['3'] = { beings = { {sid = "demon",             count = 10, },
                       {sid = "icedemon",          count =  5, }, }, rate = math.floor((_TICKS_TIL_WAVE1_DONE - 10) / 15 + 5), rate_next = 10, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
  ['4'] = { beings = { {sid = "imp",               count = 15, },
                       {sid = "darkimp",           count = 10, }, }, rate = math.floor((_TICKS_TIL_WAVE1_DONE -  5) /     25), rate_next =  5, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
  ['5'] = { beings = { {sid = "belphegor",         count =  4, },
                       {sid = "cyberbelphegor",    count =  1, }, }, rate = math.floor((_TICKS_TIL_WAVE1_DONE - 80) /      5), rate_next = 80, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
}
local being_translation_2 = {
  ['9'] = { beings = { {sid = "undeadwarrior",     count = 10, }, }, rate = math.floor((_TICKS_TIL_WAVE2_DONE -  20) /    10), rate_next = 20, coordorder = Elevator.SpawnEngine.SPAWN_COORD_LINEAR, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
}
local being_translation_3 = {
  ['8'] = { beings = { {sid = "eyesore",           count =  8, }, }, rate = math.floor((_TICKS_TIL_WAVE3_DONE -  20) /     8), rate_next = 20, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
}
local being_translation_4 = {
  ['1'] = { beings = { {sid = "duke_trooper",      count = 10, },
                       {sid = "duke_captain",      count = 10, }, }, rate = math.floor((_TICKS_TIL_WAVE4_DONE -  5) /     20), rate_next =  5, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_RANDOM },
  ['2'] = { beings = { {sid = "duke_pig",          count =  5, },
                       {sid = "duke_enforcer",     count =  5, },
                       {sid = "duke_commander",    count =  5, }, }, rate = math.floor((_TICKS_TIL_WAVE4_DONE -  5) /     15), rate_next =  5, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_RANDOM },
  ['3'] = { beings = { {sid = "lostsoul",          count = 10, },
                       {sid = "suicideskull",      count =  5, }, }, rate = math.floor((_TICKS_TIL_WAVE4_DONE - 10) / 15 + 5), rate_next = 10, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
  ['4'] = { beings = { {sid = "abaddon",           count =  5, },
                       {sid = "cacolantern",       count =  5, }, }, rate = math.floor((_TICKS_TIL_WAVE4_DONE -  5) /     10), rate_next =  5, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
  ['5'] = { beings = { {sid = "hectebus",          count =  4, },
                       {sid = "anubis",            count =  2, }, }, rate = math.floor((_TICKS_TIL_WAVE4_DONE - 80) /      6), rate_next = 80, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
}
local being_translation_5 = {
  ['3'] = { beings = { {sid = "cyberdemon",        count =  2, }, }, rate = math.floor((_TICKS_TIL_WAVE5_DONE -  0) /      2), rate_next =  0, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
}
local being_translation_6 = {
  ['1'] = { beings = { {sid = "strife_reaver",     count =  5, },
                       {sid = "strife_crusader",   count =  5, }, }, rate = math.floor((_TICKS_TIL_WAVE6_DONE -  5) /     10), rate_next =  5, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_RANDOM },
  ['3'] = { beings = { {sid = "strife_reaver",     count =  5, },
                       {sid = "strife_crusader",   count =  5, },
                       {sid = "strife_inquisitor", count =  1, }, }, rate = math.floor((_TICKS_TIL_WAVE6_DONE - 15) /     11), rate_next = 15, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
  ['5'] = { beings = { {sid = "strife_reaver",     count =  5, },
                       {sid = "strife_crusader",   count =  5, }, }, rate = math.floor((_TICKS_TIL_WAVE6_DONE -  5) /     10), rate_next =  5, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_RANDOM },
}
local being_translation_7 = {
  ['3'] = { beings = { {sid = "duke_overlord",     count =  1, }, 
                       {sid = "duke_battlelord",   count =  1, }, }, rate = math.floor((_TICKS_TIL_WAVE7_DONE - 10) /      2), rate_next = 10, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_LINEAR },
}
--Moved spider mastermind and cycloid to wave 2

local _WAVE1_COUNT = 64 --Actually 79
local _WAVE2_COUNT = 10 --Actually 10
local _WAVE3_COUNT =  8 --Actually  8
local _WAVE4_COUNT = 66 --Actually 66
local _WAVE5_COUNT = 12 --Actually  2
local _WAVE6_COUNT = 36 --Actually 31
local _WAVE7_COUNT =  2 --Actually  2
local _wave = 1
local _dead_guys = 0
local _next_reward = math.random(15) + 20
local check_wave_1_reward = function()

    if(_dead_guys >= _WAVE1_COUNT) then
      _wave = 2
      _dead_guys = 0

      --Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_2, map_beings, coord.new(1, 1) )
    end
end
local check_wave_2_reward = function()

    if(_dead_guys >= _WAVE2_COUNT) then
      _wave = 3
      _dead_guys = 0

      --Elevator.SpawnEngine.ClearSpawns()
      Elevator.ItemEngine.AddMap( item_translation_2, map_items, coord.new(1, 1) )
      Elevator.SpawnEngine.AddMap( being_translation_3, map_beings, coord.new(1, 1) )
    end
end
local check_wave_3_reward = function()

    if(_dead_guys >= _WAVE3_COUNT) then
      _wave = 4
      _dead_guys = 0

      --Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_4, map_beings, coord.new(1, 1) )
    end
end
local check_wave_4_reward = function()

    if(_dead_guys >= _WAVE4_COUNT) then
      _wave = 5
      _dead_guys = 0

      --Elevator.SpawnEngine.ClearSpawns()
      Elevator.ItemEngine.AddMap( item_translation_3, map_items, coord.new(1, 1) )
      Elevator.SpawnEngine.AddMap( being_translation_5, map_beings, coord.new(1, 1) )
    end
end
local check_wave_5_reward = function()

    if(_dead_guys >= _WAVE5_COUNT) then
      _wave = 6
      _dead_guys = 0

      --Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_6, map_beings, coord.new(1, 1) )
    end
end
local check_wave_6_reward = function()

    if(_dead_guys >= _WAVE6_COUNT) then
      _wave = 7
      _dead_guys = 0

      --Elevator.SpawnEngine.ClearSpawns()
      Elevator.ItemEngine.AddMap( item_translation_4, map_items, coord.new(1, 1) )
      Elevator.SpawnEngine.AddMap( being_translation_7, map_beings, coord.new(1, 1) )
    end
end
local check_wave_7_reward = function()

    if(_dead_guys >= _WAVE7_COUNT) then
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
      _next_reward = math.random(15) + 15
    end
end

local void_1 = {

  name = "void 1",

  OnLoad = function()

    local translation = {
      ['`'] = "voidfloor",
      ['.'] = "floor",
      ['M'] = "flesh",
      ['x'] = "wall",
      ['X'] = { "wall", flags = { LFPERMANENT } },
    }

    generator.place_tile( translation, map01,  1, 1 )
    generator.place_tile( translation, map02, 36, 1 )
    generator.place_tile( translation, map03, 45, 1 )

    local newcoord = { coord.new(37,18), coord.new(43,18) }
    local safecoord = { coord.new(37,15), coord.new(43,15) }
    local targetcoord = { coord.new(23,8), coord.new(57,8) }
    for i = 1,2 do
      local otheritem = level:get_item(newcoord[i])
      if (otheritem ~= nil) then
        otheritem:displace(safecoord[i])
      end
      level:drop_item_ext( { "teleport", target = targetcoord[i] }, newcoord[i] )
    end

    level.danger_level = 9
    generator.transmute("edoor", "oedoor")

    Elevator.ItemEngine.PauseSounds(true)
    Elevator.ItemEngine.AddMap( item_translation_1, map_items, coord.new(1, 1) )
    Elevator.ItemEngine.AddMap( item_translation_1a, map_items, coord.new(1, 1) )
    Elevator.ItemEngine.CheckItems()
    Elevator.ItemEngine.PauseSounds(false)
    Elevator.SpawnEngine.AddMap( being_translation_1, map_beings, coord.new(1, 1) )
    Elevator.HUD.Reset()

    --Without boots this is a very dangerous level.  Even the odds.
    player.bodybonus = player.bodybonus + 2
    core.play_music("FIREFIEL")

      --_dead_guys = _WAVE7_COUNT
      --check_wave_7_reward()
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

Elevator.WaveEngine.Add(void_1)