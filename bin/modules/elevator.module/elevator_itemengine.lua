--Respawnable items.  We add, we reset, and we play games with the teleport sound.
--[[ Item struct:
        item_sid
        item_coord
        item_count
        spawn_count
        spawn_rate
        spawn_timer
        item_ammo
     Tile definition:
        sid
        count=inf
        rate=60
        rate_next=0
        ammo
--]]

--Exposed interface.
Elevator.ItemEngine = {}
Elevator.ItemEngine.ItemDefines = {}

Elevator.ItemEngine.Init = nil
Elevator.ItemEngine.AddItem = nil
Elevator.ItemEngine.AddMap = nil
Elevator.ItemEngine.OnTick = nil
Elevator.ItemEngine.CheckItems = nil
Elevator.ItemEngine.ResetRates = nil
Elevator.ItemEngine.ClearItems = nil
Elevator.ItemEngine.PauseSounds = nil
Elevator.ItemEngine.ClearSound = nil

--Constants
local TICK_DELAY_BETWEEN_CHECKS = 10
local SOUND_MODE_NONE        = 0
local SOUND_MODE_ONCE        = 1
local SOUND_MODE_DIRECTIONAL = 2
local SOUND_MODE_ALL         = 3
local SOUND_MODE_PAUSED      = 4
local SOUND_STATE_NONE   = 0
local SOUND_STATE_LEFT   = 1
local SOUND_STATE_RIGHT  = 2
local SOUND_STATE_CENTER = 4
local SOUND_STATE_FULL   = 7

--Local vars
local teleport_sound_mode = SOUND_MODE_ALL
local teleport_sound_status = SOUND_STATE_NONE
local teleport_sound_id = 0
local item_check_timer = 0
local item_array = {}

--local procs
local _checkBit = function(flags, bit)
    return flags % (2*bit) >= bit
end
local _playTeleportSound = function(coord)

    if(teleport_sound_id == 0) then return end

    if    (teleport_sound_mode == SOUND_MODE_NONE or teleport_sound_mode >= SOUND_MODE_PAUSED) then
        return
    elseif(teleport_sound_mode == SOUND_MODE_ONCE) then
        if(teleport_sound_status ~= SOUND_STATE_FULL) then
            level:play_sound(teleport_sound_id, player.position + coord.new(0, 5))
            teleport_sound_status = SOUND_STATE_FULL
        end
        return
    elseif(teleport_sound_mode == SOUND_MODE_DIRECTIONAL) then
        local direction = 0
        local player_x = player.position.x

        if    (coord.x + 5 < player_x) then direction = SOUND_STATE_LEFT
        elseif(coord.x - 5 > player_x) then direction = SOUND_STATE_RIGHT
        else                                direction = SOUND_STATE_CENTER
        end

        if    (direction == SOUND_STATE_LEFT   and _checkBit(teleport_sound_status, SOUND_STATE_LEFT)) then
            level:play_sound(teleport_sound_id, player.position + coord.new(-10, 0))
            teleport_sound_status = teleport_sound_status + SOUND_STATE_LEFT
        elseif(direction == SOUND_STATE_RIGHT  and _checkBit(teleport_sound_status, SOUND_STATE_RIGHT)) then
            level:play_sound(teleport_sound_id, player.position + coord.new(10, 0))
            teleport_sound_status = teleport_sound_status + SOUND_STATE_RIGHT
        elseif(direction == SOUND_STATE_CENTER and _checkBit(teleport_sound_status, SOUND_STATE_CENTER)) then
            level:play_sound(teleport_sound_id, player.position + coord.new(0, 5))
            teleport_sound_status = teleport_sound_status + SOUND_STATE_CENTER
        end
        return
    elseif(teleport_sound_mode == SOUND_MODE_ALL) then
        level:play_sound(teleport_sound_id, coord)
        return
    end
end
local _createEntry = function(proto, coord)
    local new_entry = {
        item_sid    = proto.sid
      , item_coord  = coord
      , item_count  = proto.count or math.huge
      , spawn_count = proto.count or math.huge --By default respawns infinitely
      , spawn_rate  = proto.rate  or 60 --by default once every 60 seconds
      , spawn_timer = proto.rate_next or 0 --by default one is spawned immediately
      , item_ammo   = proto.ammo
    }

    return new_entry
end
local _split = function(str, pat)
   local t = {}  
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = string.find(str,fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
        table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = string.find(str, fpat, last_end)
   end
   if last_end <= #str then
      cap = string.sub(str,last_end)
      table.insert(t, cap)
   end
   return t
end

--Small stuff
Elevator.ItemEngine.PauseSounds = function (pause)
    if(pause and teleport_sound_mode < SOUND_MODE_PAUSED) then teleport_sound_mode = teleport_sound_mode + SOUND_MODE_PAUSED
    elseif(not pause and teleport_sound_mode >= SOUND_MODE_PAUSED) then teleport_sound_mode = teleport_sound_mode - SOUND_MODE_PAUSED
    end
end
Elevator.ItemEngine.ClearSound = function ()
    teleport_sound_status = SOUND_STATE_NONE
end
Elevator.ItemEngine.ClearItems = function ()
    item_array = {}
end

--Item management
Elevator.ItemEngine.AddItem = function (item)
    table.insert(item_array, item)
end
Elevator.ItemEngine.AddMap = function(lookup_table, map, coord)
    --This code is taken largely from an old version of level:place_tile but modified to
    --return a very specific item array that ignores unrecognized characters
    --thus making it easier to visualize the map whilst editing the item placement.
    local lines = _split( map, "[%s]+" )

    local tile_height = #lines
    local tile_width  = 0
    for i = 1, #lines do
        tile_width = math.max(tile_width, string.len(lines[i]))
    end

    local tile_area = area.new( coord.UNIT, coord.new( tile_width, tile_height ) )
    for c in tile_area() do
        local tile_entry = lookup_table[ string.sub( lines[c.y], c.x, c.x ) ]
        if tile_entry ~= nil then
            Elevator.ItemEngine.AddItem(_createEntry(tile_entry, c + coord - coord.UNIT))
        end
    end
end
Elevator.ItemEngine.ResetRates = function ()
    for i,v in ipairs(item_array) do
        v.spawn_count = v.item_count
    end
end

--Item deployment
Elevator.ItemEngine.OnTick = function ()

    --experiment with this later
    if(player.scount + player.speed >= 5000) then
        Elevator.ItemEngine.ClearSound()
    end

    item_check_timer = item_check_timer - 1
    if(item_check_timer > 0) then return end

    item_check_timer = TICK_DELAY_BETWEEN_CHECKS

    Elevator.ItemEngine.CheckItems()
end
Elevator.ItemEngine.CheckItems = function ()
    for i,v in ipairs(item_array) do
        if(v.spawn_count > 0 and level:get_item(v.item_coord) == nil) then
            v.spawn_timer = v.spawn_timer - 1
            if(v.spawn_timer <= 0) then
                v.spawn_timer = v.spawn_rate
                v.spawn_count = v.spawn_count - 1

                --create new item
                local new_item = item.new(v.item_sid)
                if(v.item_ammo) then new_item.ammo = v.item_ammo end
                level:drop_item(new_item, v.item_coord)
                _playTeleportSound(v.item_coord)
                level:explosion( v.item_coord, 1, 20, 0, 0, GREEN )
            end
        end
    end
end

--Init code.
Elevator.ItemEngine.Init = function ()
    teleport_sound_id = core.resolve_sound_id("soldier.phase", "phase")
end
