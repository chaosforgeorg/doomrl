local map01 = [[
````````````````````````````````#X.
```````````````````##############X.
```````````````````#####XXXXXXXXXX.
```````````````````##..Y...........
```````````````````#####...........
```````````````````##..Y........;;;
```````````````````#####........;..
```````````````````##..Y........;..
```````````````````#####........;..
```````````````````#X,,.........;..
```````````````````#X,X.......##;..
```````````````````#X,,.......##;;;
```````````````````#X,X...........,
```````````````````#X,,X,X.......,,
```````````````````#X,,,,,,,,.....,
```````````````````#XXXXXXXXXXXXXXX
```````````````````################
```````````````````````````````````
```````````````````````````````````
```````````````````````````````````
]]
local map02 = [[
.........
.........
..,,,,,..
.,,,,,,,.
..,,,,,..
;;;;;;;;;
.........
.........
.........
.........
.........
;;;;;;;;;
.........
,.......,
.........
]]
local map03 = [[
.X#```##########``````````````````
.X#####........#``````````````````
.X#............#``````````````````
..ZZZZ...#######``````````````````
.....Z####XXXXX#``````````````````
;;;##.......,,X#``````````````````
..;##.......X,X#``````````````````
..;....,....,,X#``````````````````
..;...,,,...X,X#``````````````````
..;....,....,,X#``````````````````
..;##.......X,X#``````````````````
;;;##.......,,X#``````````````````
,...........X,X#``````````````````
,,.......X,X,,X#``````````````````
,.....,,,,,,,,X#``````````````````
XXXXXXXXXXXXXXX#``````````````````
################``````````````````
``````````````````````````````````
``````````````````````````````````
``````````````````````````````````
]]
local map_items = [[
````````````````````````````````#XoookmmmkoooX##############``````````````````
```````````````````##############XcckkkmkkkccX#XXXX.2..1..S#``````````````````
```````````````````#####XXXXXXXXXXccbbbmbbbccX#....+.1...2.#``````````````````
```````````````````##x.Y..........bb,,1,1,,bb.ZZZZ...#######``````````````````
```````````````````#####.............,,,,,.......Z####XXXXX#``````````````````
```````````````````##y.Y...1....;;;;;;;;;;;;;;;##..1....,MX#``````````````````
```````````````````#####........;.............;##.......X,X#``````````````````
```````````````````##z.Y........;.............;....,....,1X#``````````````````
```````````````````#####...2....;.............;...,2,...X,X#``````````````````
```````````````````#XD,.........;.............;....,....,1X#``````````````````
```````````````````#X,X.......##;.............;##.......X,X#``````````````````
```````````````````#X,,.......##;;;;;;;;;;;;;;;##.......,1X#``````````````````
```````````````````#X2X.....1.....,.........,.....1.....X,X#``````````````````
```````````````````#X,,X,X.......,2,.......,2,.......X,X,1X#``````````````````
```````````````````#XO,2,,,!,.....,.........,.....,+,,,,,,X#``````````````````
```````````````````#XXXXXXXXXXXXXXX###===###XXXXXXXXXXXXXXX#``````````````````
```````````````````#################:P:::P:#################``````````````````
```````````````````````````````````|:::::::|``````````````````````````````````
```````````````````````````````````#:T:::C:#``````````````````````````````````
```````````````````````````````````###---###``````````````````````````````````
]]


local _TICKS_TIL_WAVE1_DONE = 600
local item_translation_1 = {
  ['M'] = { sid = "chaingun",      rate =  20, rate_next = 60, },
  ['D'] = { sid = "sp_doomsphere", rate = 120, rate_next = 200, },
  ['S'] = { sid = "scglobe",       rate = 200, rate_next = 200, },
  ['1'] = { sid = "ammo",  ammo = 50 },
  ['2'] = { sid = "shell", ammo = 20  },
  ['+'] = { sid = "lmed",  rate = 60, rate_next = 30, },
  ['!'] = { sid = "lmed",  rate = 90, rate_next = 60, },
}
local item_translation_2 = {
  ['O'] = { sid = "ashotgun", rate = 20, rate_next = 20, },
}
local being_translation_1 = {
  ['c'] = { beings = { {sid = "sanddemon",      count = 20, adjust = -1/3, }, }, rate = math.floor((_TICKS_TIL_WAVE1_DONE - math.random(30))       / 20), rate_next = math.random(30),       coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, },
  ['k'] = { beings = { {sid = "undeadwarrior",  count = 20, adjust = -1/2, },
                       {sid = "skeletonarcher", count = 20,                }, }, rate = math.floor((_TICKS_TIL_WAVE1_DONE - math.random(30))       / 40), rate_next = math.random(30),       coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, beingorder = Elevator.SpawnEngine.SPAWN_BEING_RANDOM, },
  ['m'] = { beings = { {sid = "mancubus",       count = 10, adjust = -2/3, }, }, rate = math.floor((_TICKS_TIL_WAVE1_DONE - math.random(30) - 100) / 10), rate_next = math.random(30) + 100, coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, },
  ['b'] = { beings = { {sid = "suicidebrute",   count = 20,                }, }, rate = math.floor((_TICKS_TIL_WAVE1_DONE - math.random(30) - 200) / 20), rate_next = math.random(30),       coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, }, --brutes are a first wave beastie.  Get them out early.
  ['o'] = { beings = { {sid = "cacolantern",    count = 10, adjust = -2/3, }, }, rate = math.floor((_TICKS_TIL_WAVE1_DONE - math.random(30))       / 10), rate_next = math.random(30),       coordorder = Elevator.SpawnEngine.SPAWN_COORD_RANDOM, },
}
local being_translation_2 = {
  ['x'] = { beings = { {sid = "anubis", count = 5, adjust = -2/3, }, }, rate = 45, rate_next = 0, },
  ['y'] = { beings = { {sid = "anubis", count = 5, adjust = -2/3, }, }, rate = 45, rate_next = 0, },
  ['z'] = { beings = { {sid = "anubis", count = 5, adjust = -2/3, }, }, rate = 45, rate_next = 0, },
}


local _WAVE1_COUNT = 100
local _WAVE2_COUNT = 15
local _wave = 1
local _timer = 0
local _dead_guys = 0
local _next_reward = math.random(10) + 15
local check_wave_1_reward = function()

    if(_dead_guys >= _WAVE1_COUNT) then
      _wave = 2
      _timer = 250
      _dead_guys = 0

      Elevator.ItemEngine.AddMap( item_translation_2, map_items, coord.new(1, 1) )
      Elevator.SpawnEngine.ClearSpawns()
      Elevator.SpawnEngine.AddMap( being_translation_2, map_items, coord.new(1, 1) )
    end

end
local check_wave_2_reward = function()
    if(_dead_guys >= _WAVE2_COUNT) then
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
local check_wave_2_timer = function()

    if(_timer > 0) then
      _timer = _timer - 1

      if(_timer == 0) then
        generator.transmute("tombglyph", "sand")
      end
    end
end
local check_mod_reward = function()
    _next_reward = _next_reward - 1
    if(_next_reward <= 0) then
      --Drop a mod somewhere for kicks
      Elevator.Level.DropItemNearPlayer( table.random_pick({"mod_agility","mod_bulk","mod_tech","mod_agility","mod_bulk","mod_tech","mod_power"}), 7 )
      _next_reward = math.random(10) + 15
    end
end


local _elevator_first = true
local _elevator_closed = false
local _elevator_area = area.new(37, 17, 43, 19)
local _elevator_door_center = coord.new(40, 16)
local _elevator_door_area = area.new(39, 16, 41, 16)
local _elevator_door_open = area.new(38, 17, 42, 17)
local check_elevator_doors = function()

    local a = _elevator_area:contains( player.position )
    local b = _elevator_door_open:contains( player.position ) 
    local c = _elevator_door_open:contains( player.position ) 


    if(_elevator_first and not _elevator_area:contains( player.position )) then
        _elevator_first = false
    end

    if(_elevator_closed) then
      if(not _elevator_area:contains( player.position ) or _elevator_door_open:contains( player.position )) then
        level:play_sound("door.open", _elevator_door_center)
        generator.transmute("edoor", "oedoor")
        _elevator_closed = false
      end
    elseif(not _elevator_first and _elevator_area:contains( player.position ) and not _elevator_door_open:contains( player.position )) then

      --Check for a being ON the elevator doors and abort if found
      local found = false
      for b in level:beings_in_range( _elevator_door_center, 1 ) do
        if(_elevator_door_area:contains( b.position )) then
          found = true
          break
        end
      end

      if(not found) then
        level:play_sound("door.close", _elevator_door_center)
        generator.transmute("oedoor", "edoor")
        _elevator_closed = true
      end
    end
end


local tomb_1 = {

  name = "tomb 1",

  OnLoad = function()

    local translation = {
      ['`'] = { "void", flags = { LFPERMANENT } },
      ['#'] = { "tombwall", flags = { LFPERMANENT } },
      ['X'] = "tombwall",
      ['Y'] = { "tombglyph", flags = { LFPERMANENT } },
      ['Z'] = { "tombarch", flags = { LFPERMANENT } },
      ['.'] = "sand",
      [','] = { "sandhill", flags = { LFBLOOD } }, --"sandhill",
      [';'] = "tile",
    }

    generator.place_tile( translation, map01,  1, 1 )
    generator.place_tile( translation, map02, 36, 1 )
    generator.place_tile( translation, map03, 45, 1 )
    level.danger_level = 1
    generator.transmute("edoor", "oedoor")

    Elevator.ItemEngine.PauseSounds(true)
    Elevator.ItemEngine.AddMap( item_translation_1, map_items, coord.new(1, 1) )
    Elevator.ItemEngine.CheckItems()
    Elevator.ItemEngine.PauseSounds(false)
    Elevator.SpawnEngine.AddMap( being_translation_1, map_items, coord.new(1, 1) )
    Elevator.HUD.Reset()

    core.play_music("FIREFIEL")
      --_dead_guys = _WAVE2_COUNT
      --check_wave_2_reward()
  end,

  OnTick = function()
    check_elevator_doors()
    if(_wave == 2) then check_wave_2_timer() end
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

Elevator.WaveEngine.Add(tomb_1)