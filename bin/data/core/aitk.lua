aitk = {}

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

