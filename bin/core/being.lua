table.merge( being,thing )

being.items = thing.children

being.inv = {
	clear = function(self)
		for i in being.inv.items(self) do
			i:destroy()
		end
	end,
	add = function(self,it,params)
		if type(it) == "string" then it = item.new(it) end
		if params then
			for k,v in pairs(params) do
				it[k] = v
			end
		end
		return being.add_inv_item(self, it)
	end,
	size = function(self)
		local result = 0
		for i in being.inv.items(self) do
			result = result + 1
		end
		return result
	end,
	items = being.inv_items,
	empty = function(self)
		for i in being.inv.items(self) do
			return false
		end
		return true
	end,
}

setmetatable(being.inv, {
	__newindex = function (self, key, value)
	end,
	__index = function (self, key)
		if type(key) == "string" then
			local itemlist = {}

			--Return every item in the being's inventory with the given sid.
			for item in self:items() do
				if item.id == key then
					table.insert(itemlist, item)
				end
			end

			return unpack(itemlist)
		end
		return nil
	end,
})

being.eq =  {
	clear = function(self)
		for i=0,MAX_EQ_SIZE-1 do
			being["set_eq_item"]( self, i, nil )
		end
	end,
	empty = function(self)
		local i = -1
		while i < MAX_EQ_SIZE-1 do
			i = i + 1
			local item = being["get_eq_item"](self, i)
			if item then return false end
		end
		return true
	end,
	items = function(self)
		local i = -1
		return function ()
			while i < MAX_EQ_SIZE-1 do
				i = i + 1
				local item = being["get_eq_item"](self, i)
				if item then return item end
			end
		end
	end,

}

setmetatable(being.eq, {
	__newindex = function (self, key, value)
		if type(key) == "string" then key = _G["SLOT_"..string.upper(key)] end
		if type(value) == "string" then value = item.new(value) end
		being["set_eq_item"]( self, key, value )
	end,
	__index = function (self, key)
		if type(key) == "string" then key = _G["SLOT_"..string.upper(key)] end
		return being["get_eq_item"]( self, key )
	end,
})

function being:flock_target( range, mind, maxd )
	local pos     = self.position
	local id      = self.id
	local flock   = {}
	local closest = nil
	local cdist   = range*2

	for b in level:beings_in_range( pos, range ) do
		if b.id == id and b ~= self and b:eye_contact( pos ) then
			local c = b.position
			if closest then
				local dist = coord.distance( c, pos )
				if dist < cdist then
					closest = c
					cdist = dist
					if dist == 1 then break end
				end
			else
				closest = c
				cdist = coord.distance( c, pos )
			end
		end
	end

	if closest then
		if cdist >= maxd then
			return closest
		elseif cdist <= mind then
			closest = 2*pos - closest
			area.FULL:clamp_coord(closest)
			if not level:get_being(closest) or cells[level.map[closest]].flags[CF_BLOCKMOVE] then
				return closest
			end
		end
	end

	local scan = area.around( pos, range ):clamped( area.FULL )
	return scan:random_coord()
end

function being:msg( msg_player, msg_being )
	if self:is_player() then
		if msg_player then
			ui.msg( msg_player )
		end
	elseif msg_being then
		if self:is_visible() then
			ui.msg( msg_being )
		end
	end
end

function being:select_slot_by_letter( letter )
	local result = nil
	if letter == "a" then result = self.eq.armor end
	if letter == "b" then result = self.eq.boots end
	if letter == "w" then result = self.eq.weapon end
	if letter == "p" then result = self.eq.prepared end
	return result
end

function being:phase( cell )
	local target = generator.random_empty_coord{ EF_NOBEINGS, EF_NOITEMS, EF_NOSTAIRS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }
	if cell then
		cell = cells[ cell ].nid
		local targets = {}
		for c in area.FULL_SHRINKED() do
			if generator.get_cell( c ) == cell then
				table.insert( targets, c:clone() )
			end
		end
		if #targets ~= 0 then
			target = generator.drop_coord( table.random_pick( targets ), {EF_NOITEMS,EF_NOBEINGS,EF_NOBLOCK}  )
		end
	end
	if target then
		self:relocate( target )
	end
end

function being:spawn( monster )
	local b = level:drop_being( monster, self.position )
	if b then
		b.flags[ BF_NOEXP ] = true
	end
end

function being:act( coord )
	local id = level.map[ coord ]
	if not cells[ id ].OnAct then return false end
	return cells[ id ].OnAct( coord.x, coord.y, self )
end

function being:eye_contact( other )
	return level:eye_contact( self, other )
end

function being:in_sight( other )
	local corner_shooting = true
	if other == player then
		if corner_shooting then
			return self:distance_to( other ) <= self.vision and level:eye_contact( self, other )
		else
			return self:is_visible() and self:distance_to( other ) <= self.vision
		end
	else
		return self:distance_to( other ) <= self.vision and level:eye_contact( self, other )
	end
end

function being:is_player()
	return self.__ptr == player.__ptr
end

function being:set_items( set )
	local result = 0
	for i in self.eq:items() do
		if i.__proto.set == set then result = result + 1 end
	end
	return result
end

function being:nuke( time )
	player.nuketime = time or 1
	if not cells[ level.map[ self.position ] ].flags[ CF_CRITICAL ] then
		level.map[ self.position ] = 'nukecell'
	end
end

function being:pick_mod_item( modletter, techbonus )
	if not self:is_player() then return nil end
	local slot = ui.msg_choice( "Modify @<w@>eapon, @<a@>rmor or @<b@>oots? (Escape to cancel)", "wab\001" )
	if slot == "\001" then return nil, false end
	local item = self:select_slot_by_letter( slot )
	if not item then
		ui.msg( "Nothing to modify!" )
		return nil, false
	end
	if item:check_mod_array( modletter, techbonus ) then
		return nil, true
	end
	if not item:can_mod( modletter ) then
		ui.msg( "This item can't be modified anymore with this mod!" )
		return nil, false
	end
	return item, true
end

setmetatable(being,getmetatable(thing))
