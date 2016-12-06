--Exposed interface.
Elevator.SpawnEngine = {}
Elevator.SpawnEngine.SpawnDefines = {}

Elevator.SpawnEngine.Init = nil
Elevator.SpawnEngine.AddSpawn = nil
Elevator.SpawnEngine.AddMap = nil
Elevator.SpawnEngine.OnTick = nil
Elevator.SpawnEngine.ClearSpawns = nil

--Constants
local TICK_DELAY_BETWEEN_CHECKS = 10
Elevator.SpawnEngine.SPAWN_BEING_LINEAR = 0
Elevator.SpawnEngine.SPAWN_BEING_ALTERNATE = 1
Elevator.SpawnEngine.SPAWN_BEING_RANDOM = 2
Elevator.SpawnEngine.SPAWN_COORD_LINEAR = 0
Elevator.SpawnEngine.SPAWN_COORD_ALTERNATE = 0
Elevator.SpawnEngine.SPAWN_COORD_RANDOM = 1

--Local vars
local spawn_check_timer = 0
local spawn_array = {}

--local procs
local _createBeingEntry = function(proto)
    local new_entry = {
        being_sid   = proto.sid
      , spawn_count = proto.count or 1
      , being_adj   = proto.adjust or 0.0 --Adjusting doesn't work as well on enemies with swapping weapons but it is still a very helpful balancing hack 0:)
    }

    return new_entry
end
local _createEntry = function(proto, coords)
    local new_entry = {}

    new_entry.being_entries = {}
    for i,v in ipairs(proto.beings) do
        new_entry.being_entries[i] = _createBeingEntry(v)
    end
    new_entry.spawn_method = proto.beingorder or Elevator.SpawnEngine.SPAWN_BEING_LINEAR
    new_entry.last_being = 0

    new_entry.coord_entries = {}
    for i,v in ipairs(coords) do
        new_entry.coord_entries[i] = coord.clone(v)
    end
    new_entry.coord_method = proto.coordorder or Elevator.SpawnEngine.SPAWN_COORD_ALTERNATE
    new_entry.last_coord = 0

    new_entry.spawn_rate  = proto.rate or 15 --by default once every 15 seconds
    new_entry.spawn_timer = proto.rate_next or 0 --by default one is spawned immediately

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

local _getNextBeingIndex = function(current_index, being_entries, method)

    --Shortcut since a single entry is probably the most common case
    if (#being_entries == 1) then
        if (being_entries[1].spawn_count > 0) then
            return 1
        else
            return 0
        end
    end

    local valid_indexes = {}

    for i,v in ipairs(being_entries) do
        if (v.spawn_count > 0) then
            table.insert(valid_indexes, i)
        end
    end

    if (#valid_indexes > 0) then
        if    (method == Elevator.SpawnEngine.SPAWN_BEING_LINEAR) then
            return valid_indexes[1]
        elseif(method == Elevator.SpawnEngine.SPAWN_BEING_ALTERNATE) then
            for _,v in ipairs(valid_indexes) do
                if (v > current_index) then
                    return v
                end
                return valid_indexes[1]
            end
        elseif(method == Elevator.SpawnEngine.SPAWN_BEING_RANDOM) then
            return table.random_pick(valid_indexes)
        end
    end

    return 0
end
local _getNextCoordIndex = function(current_index, coord_entries, method)

    --coords never become invalid making this pretty easy
    if    (method == Elevator.SpawnEngine.SPAWN_COORD_ALTERNATE) then
        return current_index % #coord_entries + 1
    elseif(method == Elevator.SpawnEngine.SPAWN_COORD_RANDOM) then
        return math.random(#coord_entries)
    end

    return 0
end

--Small stuff
Elevator.SpawnEngine.ClearSpawns = function ()
    spawn_array = {}
end

--Spawn management
Elevator.SpawnEngine.AddSpawn = function (spawn)
    table.insert(spawn_array, spawn)
end
Elevator.SpawnEngine.AddMap = function(lookup_table, map, coord)
    --This code is taken largely from level:place_tile but modified to
    --return a very specific item array that ignores unrecognized characters
    --thus making it easier to visualize the map whilst editing the item placement.
    local lines = _split( map, "[%s]+" )

    local tile_height = #lines
    local tile_width  = 0
    for i = 1, #lines do
        tile_width = math.max(tile_width, string.len(lines[i]))
    end

    local collated_coords = {}
    local collated_coord_counts = {}
    for k,v in pairs(lookup_table) do
        collated_coords[k] = {}
        collated_coord_counts[k] = 0
    end

    local tile_area = area.new( coord.UNIT, coord.new( tile_width, tile_height ) )
    for c in tile_area() do
        local index_char = string.sub( lines[c.y], c.x, c.x )
        if lookup_table[index_char] ~= nil then

            local i = collated_coord_counts[index_char] + 1
            local seqcoordorder = lookup_table[index_char].seqcoordorder

            --Sometimes top left to bottom right doesn't do the job, at least not when running sequentially.
            --I haven't bothered to make this very robust.  Don't pass in bad values or arrays.
            if seqcoordorder ~= nil then
                collated_coords[index_char][seqcoordorder[i]] = c + coord - coord.UNIT
            else
                collated_coords[index_char][i] = c + coord - coord.UNIT
            end

            collated_coord_counts[index_char] = i
        end
    end

    for k,v in pairs(lookup_table) do
        Elevator.SpawnEngine.AddSpawn(_createEntry(v, collated_coords[k]))
    end

end

--Item deployment
Elevator.SpawnEngine.OnTick = function ()

    local _spawned = false

    spawn_check_timer = spawn_check_timer - 1
    if(spawn_check_timer <= 0) then
        spawn_check_timer = TICK_DELAY_BETWEEN_CHECKS

        for i,v in ipairs(spawn_array) do
            if(not v.done) then
                if(v.spawn_timer <= 0) then
                    _spawned = true

                    --Check our coord first.  It may be occupied.
                    v.last_coord = _getNextCoordIndex(v.last_coord, v.coord_entries, v.coord_method)
                    local temp_coord = v.coord_entries[v.last_coord]

                    if(level:get_being(temp_coord) == nil) then
                        --Get our being
                        local temp_being_index = _getNextBeingIndex(v.last_being, v.being_entries, v.spawn_method)
                        local new_being = v.being_entries[temp_being_index]

                        if(new_being ~= nil) then
                            --Make our being!
                            local b = level:drop_being( new_being.being_sid, temp_coord)
                            if(b ~= nil) then
                                --Difficulty bonuses to screw with Tormuse
                                b.todamall = b.todamall + core.bydiff{ -2, -1, 0, 1, 2 }

                                --Regular adjustments
                                b.expvalue = math.floor(b.expvalue * (1.0 + new_being.being_adj))
                                b.hpmax = math.floor(b.hpmax * (1.0 + new_being.being_adj))
                                b.hp = math.floor(b.hp * (1.0 + new_being.being_adj))
                                b.speed = math.floor(b.speed * (1.0 + (new_being.being_adj / 2)))
                                if (b.eq.weapon and b.eq.weapon.flags[ IF_NODROP ]) then
                                    b.eq.weapon.damage_sides = math.floor(b.eq.weapon.damage_sides * (1.0 + (new_being.being_adj / 2)))
                                else
                                    b.todamall = b.todamall + math.floor(1 * (new_being.being_adj * 2))
                                end

                                v.last_being = temp_being_index
                                v.spawn_timer = v.spawn_rate
                                new_being.spawn_count = new_being.spawn_count - 1
                            end
                        else
                            v.done = true
                        end
                    end
                else
                    v.spawn_timer = v.spawn_timer - 1
                end
            end
        end
    end

    return _spawned
end

--Init code.
Elevator.SpawnEngine.Init = function ()

end
