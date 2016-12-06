local _timer = 0
local check_timer_open = function()
    if (_timer == 10) then
      player:play_sound("dspstop")
      generator.transmute("barondropwall", "flesh")
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


local baron_1a = {

  name = "baron 1a",

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

Elevator.WaveEngine.Add(baron_1a)