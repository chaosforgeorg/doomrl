aitk = {}

function aitk.scan( self )
    local visible = self:in_sight( player )
    if visible then
        return player.uid
    end
    return false
end

-- aitk.pursue( self, target )
--  * self - being
--  * target - coord
-- direct_seek the target coord. If not possible, seek a coord around
-- self that is closer to the target.
function aitk.pursue( self, target )
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

function aitk.flock_init( self )
    self:add_property( "ai_state", "idle" )
    self:add_property( "boredom", 6 )
    self:add_property( "move_to", false )
    self:add_property( "target", false )
end

function aitk.flock_alert( self, range, target )
    local target = target or self.target
    for b in level:beings_in_range( self, range ) do
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
        aitk.flock_alert( self, 4 )
        return true
    end
    return false
end

function aitk.flock_idle( self, dmin, dmax )
    if aitk.flock_scan( self ) then
        return "hunt"
    end
    if math.random(30) == 1 then
        self:play_sound( "act" )
    end
    if not self.move_to then
        self.move_to = self:flock_target( self.vision, dmin or 1, dmax or 4 )
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
    if not aitk.pursue( self, target.position ) then
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
-- Looks to s