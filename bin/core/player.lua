function player:remove_medals( medallist )
	if medallist then
		for _,v in ipairs( medallist ) do
			self:remove_medal( v )
		end
	end
end

function player:remove_award( award )
	self.__props.awards[award] = nil
end

function player:set_award( award, level )
	self.__props.awards[award] = level
end

function player:has_award( award, level )
	return self.__props.awards[award] and self.__props.awards[award] >= (level or 1)
end

function player:get_award( award )
	return self.__props.awards[award]
end

function player:remove_medal( medal )
	self.__props.medals[medal] = nil
end

function player:add_medal( medal )
	self.__props.medals[medal] = true
end

function player:has_medal( medal )
	return self.__props.medals[medal]
end

function player:remove_badge( badge )
	self.__props.badges[badge] = nil
end

function player:add_badge( badge )
	self.__props.badges[badge] = true
end

function player:has_badge( badge )
	return self.__props.badges[badge]
end

function player:remove_assembly( assembly )
	self.__props.assemblies[assembly] = nil
end

function player:add_assembly( assembly )
	self.__props.assemblies[assembly] = ( self.__props.assemblies[assembly] or 0 ) + 1
end

function player:has_assembly( assembly )
	return self.__props.assemblies[assembly]
end

function player:remove_found_item( found_item_id )
	self.__props.items_found[found_item_id] = nil
end

function player:add_found_item( found_item_id )
	self.__props.items_found[found_item_id] = true
end

function player:has_found_item( found_item_id )
	return self.__props.items_found[found_item_id]
end

function player:add_history( history )
	if history then
		table.insert( self.__props.history, (string.gsub( history, "@1", self.depth )) )
	end
end

table.merge( player, being )
setmetatable(player,getmetatable(being))
