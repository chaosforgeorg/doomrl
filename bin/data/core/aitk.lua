-- General definitions:
-- idle - being is not doing anything in particular (wander)
-- hunt - being is attacking a visible target
-- pursue - being is seaching a not visible target

aitk = {}

function aitk.scan( self )
    local visible = self:in_sight( player )
    if visible then
        return player.uid
    end
    return false
end

function aitk.move_path( self )
    local move_check, move_coord = self:path_next()
    if move_check ~= MOVEOK and (move_check ~= MOVEDOOR or (not self.flags[BF_OPENDOORS])) then
        return false, nil
    end
    return true, move_coord
end


-- aitk.flock_seek( self, target )
--  * self - being
--  * target - coord
-- direct_seek the target coord. If not possible, seek a coord around
-- self that is closer to the target.
function aitk.flock_seek( self, target )
    if self:direct_seek( target ) == MOVEOK then 
        return true
    end

    local moves = {}
    local dist = self:distance_to( target )
    for c in self.position:around_coords() do
        if coord.distance(c,target) < dist and generator.is_empty(c, { EF_NOBEINGS, EF_NOBLOCK } ) then
            table.insert( moves,c:clone() )
        end
    end

    while #moves > 0 do
        if self:direct_seek( table.random_remove( moves ) ) == MOVEOK then
            return true
        end
    end
    return false
end

function aitk.flock_init( self, flock_min, flock_max )
    self:add_property( "ai_state", "idle" )
    self:add_property( "boredom", 6 )
    self:add_property( "flock_min", flock_min or 1 )
    self:add_property( "flock_max", flock_max or 4 )
    self:add_property( "move_to", false )
    self:add_property( "target", false )
end

function aitk.flock_on_attacked( self, target )
    local target = target or self.target
    for b in level:beings_in_range( self, self.flock_max or 4 ) do
        if b.id == self.id then
            b.target   = self.target
            b.boredom  = 0
            b.ai_state = "hunt"
        end
    end
end

function aitk.flock_scan( self )
    self.target = aitk.scan( self )
    if self.target then
        aitk.flock_on_attacked( self )
        return true
    end
    return false
end

function aitk.flock_idle( self )
    if aitk.flock_scan( self ) then
        return "hunt"
    end
    if math.random(30) == 1 then
        self:play_sound( "act" )
    end
    if not self.move_to then
        self.move_to = self:flock_target( self.vision, self.flock_min or 1, self.flock_max or 4 )
    end

    if not cells[ level.map[self.move_to] ].flags[ CF_HAZARD ] or self.flags[ BF_ENVIROSAFE ] == true then
        if self:direct_seek( self.move_to ) ~= MOVEOK then
            self.scount =  self.scount - 500
            self.move_to = false
            return "idle"
        end
    else
        self.scount =  self.scount - 500
        self.move_to = false
        return "idle"
    end

    if self:distance_to( self.move_to ) == 0 then
        self.move_to = false
    end
    return "idle"
end

function aitk.flock_hunt( self )
    if not self.target then return "idle" end
    local target = uids.get( self.target )
    if not target then
        self.target = false
        return "idle"
    end
    local visible = self:in_sight( target )
    if not visible then
        self.boredom = self.boredom + 1
        if self.boredom > 5 then
            self.target = false
            return "idle"
        end
    end
    local dist = self:distance_to( target )
    if dist == 1 then
        self:attack( target )
        return "hunt"
    end
    if not aitk.flock_seek( self, target.position ) then
        self.scount = self.scount - 500
    end
    return "hunt"
end

function aitk.try_heal_item( self )
    local item
    for i in self.inv:items() do
		if i and i.flags[ IF_AIHEALPACK ] then
            item = i
			break
		end
	end
    if item then
        self:use( item )
        self.scount = self.scount - 1000
        return true
    end
	return false
end

-- aitk.ammo_check( self )
-- returns has_ammo, needs reload
-- * has_ammo - entity has a weapon with ammo available
-- * needs_reload - entity needs to reload to fire
function aitk.ammo_check( self )
    if self.eq.weapon == nil then return false, false end
    local w = self.eq.weapon
    if w.flags[ IF_NOAMMO ] then return true, false end
    if w.ammo >= math.max( w.shotcost, 1 ) then 
        if w.flags[ IF_PUMPACTION ] and w.flags[ IF_CHAMBEREMPTY ] then return true, true end
        return true, false 
    end
    if self.inv[ items[w.ammoid].id ] then return true, true end
    return false, false
end

-- aitk.inventory_check( self, can_reload )
-- returns action_performed, has_ammo
-- * action_performed - entity has performed an action
-- * has_ammo - entity has a weapon with ammo available
function aitk.inventory_check( self, can_reload )
    local has_ammo, needs_reload = aitk.ammo_check( self )
    if needs_reload and can_reload then
        if self:reload() then
            return true, true
        else
            has_ammo = false
        end
    end

    if self.hp < self.hpmax / 2 and aitk.try_heal_item( self ) then
        return true, has_ammo
    end    

    return false, has_ammo
end

function aitk.basic_init( self, use_packs, use_armor )
    self:add_property( "ai_state", "idle" )
    self:add_property( "boredom", 0 )
    self:add_property( "move_to", false )
    self:add_property( "target", false )
    self:add_property( "use_packs", use_packs or false )
    self:add_property( "use_armor", use_armor or false )
    self:add_property( "attackchance", math.min( self.__proto.attackchance * diff[DIFFICULTY].speed, 90 ) )
end

function aitk.basic_scan( self )
    if self.target and self:in_sight( uids.get( self.target ) ) then
        return self.target
    end
    local target = aitk.scan( self )
    if target then self.target = target end
    return target 
end

-- aitk.basic_idle( self )
-- returns next_state
-- needs a valid set self.move_to
function aitk.basic_pursue( self )
    if aitk.basic_scan( self ) then
        self.move_to = false
        return "hunt"
    end
    if ( not self.move_to ) or self:distance_to( self.move_to ) == 0 then
        self.scount = self.scount - 200
        return "idle"
    end
    local move_check = aitk.move_path( self )
    if aitk.basic_scan( self ) then
        self.move_to = false
        return "hunt"
    end
    if math.random(30) == 1 then self:play_sound( "act" ) end
    if not move_check then
        self.scount = self.scount - 200
        return "idle"
    end
    if self:has_property("boredom") then
        self.boredom = self.boredom + 1
        if self.boredom > 8 then
            return "idle"
        end
    end
    return "pursue"
end

function aitk.basic_on_attacked( self, target )
    if self:has_property("boredom") then self.boredom = 0 end
    if target then 
        self.target = target.uid
        if self.ai_state == "idle" then
            self.move_to  = target.position
            self.ai_state = "pursue"
        end
    end
end

-- aitk.basic_smart_idle( self )
-- returns next_state
function aitk.basic_smart_idle( self )
    if aitk.basic_scan( self ) then
        self.move_to = false
        return "hunt"
    end
	if self.flags[ BF_HUNTING ] then
        if self:has_property("boredom") then self.boredom = 0 end
		self.move_to = player.position
        self.target  = player.uid
		self:path_find( self.move_to, 10, 40 )
		return "pursue"
	end
	if math.random(30) == 1 then
		self:play_sound( "act" )
	end
    if self.move_to then
        if self:distance_to( self.move_to ) == 0 then
            local use_armor = self.use_armor
            local use_packs = self.use_packs
            if use_armor or use_packs then
                if self.inv:size() < MAX_INV_SIZE then
                    local item = level:get_item( self.move_to )
                    if item and ( ( use_packs and item.flags[ IF_AIHEALPACK ] ) or 
                                ( use_armor and item.itype == ITEMTYPE_ARMOR and not self.eq.armor ) ) then
                        self:pickup( self.move_to )
                        if item.itype == ITEMTYPE_ARMOR then
                            self:wear( item )
                        end
                    end
                end
            end
            self.move_to = false
        else
            if not aitk.move_path( self ) then
                self.move_to = false
                self.scount = self.scount - 500
            end
        end
    end

    if not self.move_to then
        if aitk.inventory_check( self, true ) then
            return "idle"
        end
        local move_dist = self.vision+1
        local next_move
        local step
        local use_armor = self.use_armor
        local use_packs = self.use_packs
        if use_armor or use_packs then
            if not (self.inv:size() >= MAX_INV_SIZE) then
                for item in level:items_in_range( self, self.vision ) do
                    if ( (use_packs and item.flags[ IF_AIHEALPACK ] ) 
                      or (use_armor and item.itype == ITEMTYPE_ARMOR and not self.eq.armor ) ) 
                      and self:in_sight( item ) then
                        local item_dist = self:distance_to( item )
                        if item_dist < move_dist then
                            move_dist = item_dist
                            next_move = item.position
                        end
                    end
                end
            end
        end
        if not next_move then
            next_move = area.around( self.position, 3 ):clamped( area.FULL ):random_coord()
        end
        if next_move then
            self.move_to = next_move
            if not self:path_find( self.move_to, 10, 40 ) then
                self.scount = self.scount - 1000
                self.move_to = false
            end
        end
    end
	return "idle"
end

function aitk.try_hunt( self )
    if not self.target then return "idle" end
    local target = uids.get( self.target )
    if not target then
        self.target = false
        return "idle"
    end
    local dist    = self:distance_to( target )
    local visible = self:in_sight( target )
    local action, has_ammo = aitk.inventory_check( self, dist > 1 )
    if action then return "hunt" end
    if not visible then
        if self:has_property("boredom") then self.boredom = 0 end
		self.move_to = target.position
		self:path_find( self.move_to, 10, 40 )
        return "pursue"
    end

    if dist == 1 then
        self:attack( target )
        return "hunt"
    elseif math.random(100) <= self.attackchance and has_ammo then
        self:fire( target, self.eq.weapon )
        return "hunt"
    end

    if math.random(30) == 1 then self:play_sound( "act" ) end

    return false, dist, target
end

function aitk.evade_hunt( self )
    local action, dist, target = aitk.try_hunt( self )
    if action then return action end

    if self.move_to then
        if self:distance_to( self.move_to ) == 0 then
            self.move_to = false
        else
            if not aitk.move_path( self ) then
                -- try another attempt
                if not self:path_find( self.move_to, 10, 40 ) or ( not aitk.move_path( self ) ) then
                    self.move_to = false
                end
            end
            if self.move_to then
                return "hunt"
            end
        end
    end

    -- self.move_to is false
    local s = self.position
    local t = target.position
    local walk
    if dist < 4 then
        walk = s + (s - t)
        area.FULL:clamp_coord( walk )
        if coord.distance( t, s ) >= coord.distance( t, walk ) then
            walk = area.around( s, 1 ):random_edge_coord()
        end
    else
        local v = s - t
        walk = table.random_pick{ t+coord.new( -v.y, v.x ), t+coord.new( v.y, -v.x ) }
    end
    area.FULL:clamp_coord( walk )
    self.move_to = walk
    if not self:path_find( self.move_to, 10, 40 ) or ( not aitk.move_path( self ) ) then
        self.scount  = self.scount - 500
        self.move_to = false
        core.log('path fail')
    end
    return "hunt"
end

function aitk.pursue_hunt( self )
    local action, dist, target = aitk.try_hunt( self )
    if action then return action end

    if self.move_to == target.position then
        if aitk.move_path( self ) then
            return "hunt"
        end
    end
    self.move_to = target.position

    if not self:path_find( self.move_to, 10, 40 ) or ( not aitk.move_path( self ) ) then
        self.move_to = false
        if not aitk.flock_seek( self, target.position ) then
            self.scount = self.scount - 1000
        end
    end
    return "hunt"
end

function aitk.ranged_hunt( self )
    local action, dist, target = aitk.try_hunt( self )
    if action then return action end

    local target = target.position
    if dist < 6 and math.random(3) > 1 then
        for _=1,3 do
            local c = area.around( self.position, 1 ):random_coord() 
            if level:is_passable( c ) then
                target = c
                break
            end
        end
    end

    if self.move_to == target then
        if aitk.move_path( self ) then
            return "hunt"
        end
    end
    self.move_to = target
    if not self:path_find( self.move_to, 10, 40 ) or ( not aitk.move_path( self ) ) then
        self.move_to = false
        self.scount  = self.scount - 1000
    end
    return "hunt"
end
