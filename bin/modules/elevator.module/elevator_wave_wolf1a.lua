local _timer = 0
local check_timer_open = function()
    if    (_timer == 200) then generator.transmute("wolf_ldoor1", "wolf_door1", area.new( 2, 2,  MAXX-1,  5 ))
    elseif(_timer == 180) then generator.transmute("wolf_ldoor1", "wolf_door1", area.new( 2, 2,  MAXX-1,  7 ))
    elseif(_timer == 160) then generator.transmute("wolf_ldoor1", "wolf_door1", area.new( 2, 2,  MAXX-1,  9 ))
    elseif(_timer == 140) then generator.transmute("wolf_ldoor1", "wolf_door1", area.new( 2, 2,  MAXX-1, 11 ))
    elseif(_timer == 120) then generator.transmute("wolf_ldoor1", "wolf_door1", area.new( 2, 2,  MAXX-1, 13 ))
    elseif(_timer == 100) then generator.transmute("wolf_ldoor1", "wolf_door1", area.new( 2, 2,  MAXX-1, 15 ))
    elseif(_timer ==  80) then generator.transmute("wolf_ldoor1", "wolf_door1", area.new( 2, 2,  MAXX-1, 17 ))
    elseif(_timer ==  60) then generator.transmute("wolf_ldoor1", "wolf_door1", area.new( 2, 2,  MAXX-1, 19 ))
    end
end
local check_timer_countdown = function()
    if    (_timer == 80) then Elevator.AnnouncerPlaySound("three")
    elseif(_timer == 50) then Elevator.AnnouncerPlaySound("two")
    elseif(_timer == 20) then Elevator.AnnouncerPlaySound("one")
    elseif(_timer == 0)  then
      Elevator.AnnouncerPlaySound("fight")
      Elevator.WaveEngine.Next(true)
    end
end
local check_timer = function()
    _timer = _timer - 1

    check_timer_open()
    check_timer_countdown()
end
local wolf_1a = {

  name = "wolf 1a",

  OnLoad = function()
    _timer = 250
  end,

  OnTick = function()
    check_timer()
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

    return false
  end,
}

Elevator.WaveEngine.Add(wolf_1a)