local elevator_area = area.new(36, 16, 44, 20)
local map = [[
###===###
#:P:::P:#
|:::::::|
#:T:::C:#
###---###
]]

local sleep = function(n)
  local t0 = statistics.real_time_ms
  while statistics.real_time_ms - t0 <= n do end
end

local timer = 1000 --temp code
local boss_0a = {

  name = "boss 0a",

  OnLoad = function()

    generator.fill("floor", area.FULL)
    local translation = {
      [':'] = "floor",
      ['='] = { "edoor", flags = { LFPERMANENT } },
      ['#'] = { "ewall", flags = { LFPERMANENT } },
      ['-'] = { "ehwindow", flags = { LFPERMANENT } },
      ['|'] = { "evwindow", flags = { LFPERMANENT } },
      ['P'] = "plant1",
      ['T'] = { "tv", flags = { LFPERMANENT } },
      ['C'] = "couch",
      ['}'] = "floor",
      ['1'] = "floor",
      ['2'] = "floor",
      ['+'] = "floor",
    }
    generator.place_tile( translation, map, elevator_area.a.x, elevator_area.a.y )

    Elevator.ItemEngine.ClearItems()
    Elevator.ItemEngine.PauseSounds(true)
    --Elevator.ItemEngine.AddMap( item_translation, map, elevator_area.a )
    Elevator.ItemEngine.CheckItems()
    Elevator.ItemEngine.PauseSounds(false)

    for c in elevator_area:coords() do
      level.light[ c ][LFEXPLORED] = true
    end

    core.play_music("D_MAP08")
    timer = 250
  end,


  OnUnload = function()

    for c in area.FULL:coords() do
      if not elevator_area:contains( c ) then
        level.light[ c ][LFEXPLORED] = false
      end
    end

  end,

  OnTick = function()
    timer = timer - 1
    if    (timer == 190) then core.play_music("silence")
    elseif(timer == 180) then player:play_sound("STEEL1")
    elseif(timer == 120) then
      player:play_sound("STEEL2")
      sleep(3000)
      player:play_sound("GOLEMLAN")
      --Owing to a bug in 0996 UI the closest thing I can get to a multiflash is the following code
      --which, when fortunate, very briefly flashes white.  Best I can do it seems.
      ui.blink(BLACK,6000)
      ui.blink(WHITE,1000)
      Elevator.WaveEngine.Next(true)
    end
  end,

  OnDieCheck = function(player)

    player:play_sound(beings["soldier"].sound_die)
    if(not level.map[ player.position ].flags[ CF_NOCHANGE ]) then
      level.map[ player.position ] = "corpse"
    end
    Elevator.Player.DropEquipment(player)

    player:displace(coord.new(40,18))

    player.hp = player.hpmax
    return false
  end,
}

Elevator.WaveEngine.Add(boss_0a)