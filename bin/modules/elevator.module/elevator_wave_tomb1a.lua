local _createEllipse = function(horiz, vert, center)

  local foci_distance = math.sqrt(math.abs((horiz * horiz) - (vert * vert)))
  local ellipse = {}
  if(horiz > vert) then
    ellipse.major = horiz
    ellipse.minor = vert
    ellipse.f1 = { x = center.x - foci_distance, y = center.y }
    ellipse.f2 = { x = center.x + foci_distance, y = center.y }
  else
    ellipse.major = vert
    ellipse.minor = horiz
    ellipse.f1 = { x = center.x, y = center.y  - foci_distance}
    ellipse.f2 = { x = center.x, y = center.y  + foci_distance}
  end
  return ellipse
end
local _isCoordInEllipse = function(coord, ellipse, isEdge)

  local distance = math.sqrt((ellipse.f1.x - coord.x)^2 + (ellipse.f1.y - coord.y)^2) + math.sqrt((ellipse.f2.x - coord.x)^2 + (ellipse.f2.y - coord.y)^2)
  if(isEdge) then
    if(math.floor(distance) == math.floor(ellipse.major * 2)) then return true end
  else
    if(math.floor(distance) <= math.floor(ellipse.major * 2)) then return true end
  end

  return false
end

local _timer = 0
local _lastRadius = 0
local _lavaCenter = coord.new(40, 9)
local _lavaArea = area.new(34, 7, 46, 11)
local _lavaEllipse = _createEllipse(_lastRadius, _lastRadius/2, _lavaCenter)
local check_timer_lava = function()

    local radius = math.floor(math.sqrt((250 - _timer) / 4))
    if(_lastRadius ~= radius) then
      --Before continuing make sure the inner tiles are filled.
      for c in _lavaArea:coords() do
        --DoomRL distance is not math based but tile based!
        if(_isCoordInEllipse(c, _lavaEllipse, false)) then
          level:try_destroy_item(c)
          level.map[ c ] = "lava"
        end
      end
      _lavaEllipse = _createEllipse(radius, radius/2, _lavaCenter)
      _lastRadius = radius
    end

    --Lava rises from the floor.
    if(radius > 0) then
      local tries = 5
      repeat
        tries = tries - 1
        local c = _lavaArea:random_coord()
        if(_isCoordInEllipse(c, _lavaEllipse, true)) then
          level:try_destroy_item(c)
          level.map[ c ] = "lava"
          tries = 0
        end
      until tries == 0
    end

    if(_timer == 0) then
      generator.fill("lava",_lavaArea) --Just in case
    end
end
local check_timer_open = function()

    --archway opens
    if (_timer == 100) then
      player:play_sound("door.open")
      generator.transmute("tombarch", "sand")
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

    check_timer_lava()
    check_timer_open()
    check_timer_countdown()
end

local _elevator_first = false
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


local tomb_1a = {

  name = "tomb 1a",

  OnLoad = function()
    _timer = 250
  end,

  OnTick = function()
    check_elevator_doors()
    check_timer()
  end,

  OnDieCheck = function(player)

    player:play_sound(beings["soldier"].sound_die)
    if(not cells[level.map[ player.position ]].flags[ CF_NOCHANGE ]) then
      level.map[ player.position ] = "corpse"
    end
    Elevator.Player.DropEquipment(player)

    thing.displace(player, coord.new(40,18))

    --You died in the intermission?  No weapon for you!
    player.hp = player.hpmax
    return false
  end,
}

Elevator.WaveEngine.Add(tomb_1a)