ai_tools = {}

function ai_tools.OnAction( self )
	local safe = 0
	repeat
		local ai        = ais[ self.ai_type ]
		local old_state = self.ai_state
		local new_state = ai.states[ old_state ]( self ) or old_state
		if not core.is_playing() then return end -- gracefully exit if being kills player
		if not self.__ptr then return end -- gracefully exit if being dies
		self.ai_state = new_state
		safe = safe + 1
	until self.scount < 5000 or safe > 1000
	if safe > 1000 then
		error( "AI : "..ais[ self.ai_type ].id.." entered infinite loop!" )
	end
end

-- Returns an item with IF_AIHEALPACK or nil
function ai_tools.use_item_check( self )
	for item in self.inv:items() do
		if item and item.flags[ IF_AIHEALPACK ] then
			return item
		end
	end
	return nil
end
-- Looks to see if a weapon is of any use
function ai_tools.noammo_check( self )
	return not (self.eq.weapon ~= nil and (self.eq.weapon.flags[ IF_NOAMMO ] or self.eq.weapon.ammo >= math.max( self.eq.weapon.shotcost, 1 ) or self.inv[items[self.eq.weapon.ammoid].id]) )
end

--
-- ASSIGNMENT FUNCTIONS
--

-- ai_tools.idle_assignment( self, use_item )

function ai_tools.idle_assignment( self, use_item )
	local move_dist = self.vision+1
	local step
	if use_item and not (self.inv:size() >= MAX_INV_SIZE) then
		for item in level:items_in_range( self, self.vision ) do
			if ( item.flags[ IF_AIHEALPACK ] or ( item.itype == ITEMTYPE_ARMOR and not self.eq.armor ) ) and self:in_sight( item ) then
				local item_dist = self:distance_to( item )
				if item_dist < move_dist then
					move_dist = item_dist
					step = item.position
				end
			end
		end
	end
	if not step then
		step = area.around( self.position, 3 ):clamped( area.FULL ):random_coord()
	end
	return step
end

--
-- ACTION FUNCTIONS
--

--[[
ai_tools.idle_action_ranged( self, use_item )
* play "act" sound
* if being has reached destination:
** if use_item is true, any item on the same tile as being is picked up
*** if the item is an armor, it is equipped
** unassign being
* otherwise:
** move along path_next
** if a door is found, open it
** if an obstacle is found, unassign being, lower energy a bit
--]]
function ai_tools.idle_action_ranged( self, use_item )

	if self.flags[BF_HUNTING] == true then
		self.move_to = player.position
		self:path_find( self.move_to, 10, 40 )
		self.assigned = false
		return "pursue"
	end

	if math.random(30) == 1 and self.__proto.sound_act then
		self:play_sound( self.__proto.sound_act )
	end

	if self:distance_to( self.move_to ) == 0 then
		if use_item and not (self.inv:size() >= MAX_INV_SIZE) then
			local item = level:get_item( self.move_to )
			if item and ( item.flags[ IF_AIHEALPACK ] or ( item.itype == ITEMTYPE_ARMOR and not self.eq.armor ) ) then
				self:pickup( self.move_to )
				self:wear( item )
			end
		end
		self.assigned = false
	else
		local move_check,move_coord = self:path_next()
		if move_check ~= MOVEOK then
			if move_check == MOVEDOOR and self.flags[BF_OPENDOORS] == true then
--					being:open( move_coord )
			else
				self.assigned = false
				self.scount = self.scount - 200
			end
		end
	end
	return "thinking"
end

function ai_tools.idle_action_melee( self )
	if math.random(30) == 1 then
		self:play_sound( self.__proto.sound_act )
	end
	if self:distance_to(self.move_to) == 0 then
		self.scount = self.scount - 500
		self.assigned = false
		return "thinking"
	end
	if not cells[ level.map[self.move_to] ].flags[ CF_HAZARD ] or self.flags[ BF_ENVIROSAFE ] == true then
		if self:direct_seek( self.move_to ) ~= MOVEOK then
			self.scount = self.scount - 500
			self.assigned = false
		end
	else
		self.scount = self.scount - 500
		self.assigned = false
	end
	return "thinking"
end

--[[
ai_tools.pursue_action( self, approach, wander )
* if being has ammo property on its weapon:
** if ammo is zero, reload weapon and return
* if enemy has "boredom" property:
** if boredom is zero, unassign being
* if being is at target coord, unassign and return
* play "act" sound
* if energy is in sight and wander or approach are true:
** if wander is true and 50%, move to a random tile around the being
** if approach is true and 50% and hasn't already moved, directly move to player
* if being hasn't already moved, move along path_next
** if a door is found, open it (given that the being is allowed)
** if an obstacle is found, unassign being, lower energy a bit
-]]
function ai_tools.pursue_action( self, approach, wander )
	if self.eq.weapon ~= nil and not self.eq.weapon.flags[ IF_NOAMMO ] and (self.eq.weapon.ammo < math.max(self.eq.weapon.shotcost,1) or (self.eq.weapon.flags[ IF_PUMPACTION ] == true and self.eq.weapon.flags[ IF_CHAMBEREMPTY ] == true) ) then
		if self:reload() then return "thinking" end
	end
	if self:has_property("boredom") then
		if self.boredom == 0 then
			self.assigned = false
		end
	end
	if self:distance_to( self.move_to ) == 0 then
		self.assigned = false
		return "thinking"
	end
	if math.random(30) == 1 and self.__proto.sound_act then
		self:play_sound( self.__proto.sound_act )
	end
	local move_check = nil
	local move_coord = nil
	if self:in_sight( player ) and (approach or wander) then
		if wander and math.random(2) > 1 then
			move_check,move_coord = self:direct_seek( area.around( self.position, 1 ):random_coord() )
		end
		if approach and math.random(2) > 1 and not move_check then
			move_check,move_coord = self:direct_seek( player )
		end
	end
	if not move_check then
		move_check,move_coord = self:path_next()
	end
	if move_check ~= MOVEOK then
		if move_check == MOVEDOOR and self.flags[BF_OPENDOORS] == true then
--			being:open( move_coord )
		else
			self.assigned = false
			self.scount = self.scount - 200
		end
	end
	if self:in_sight( player ) then
		self.assigned = false
	end
	return "thinking"
end

--[[
ai_tools.melee_action( self )
* use melee attack on player
--]]
function ai_tools.melee_action( self )
	self:attack( player )
	return "thinking"
end

--[[
ai_tools.attack_action( self )
* if being has an ammo-carrying weapon with zero ammo, reload
* otherwise, use ranged attack on player
--]]
function ai_tools.attack_action( self )
	if self.eq.weapon ~= nil then
		if not self.eq.weapon.flags[ IF_NOAMMO ] and (self.eq.weapon.ammo < math.max(self.eq.weapon.shotcost,1) or (self.eq.weapon.flags[ IF_PUMPACTION ] == true and self.eq.weapon.flags[ IF_CHAMBEREMPTY ] == true) ) then
			self:reload()
		else
			self:fire( player, self.eq.weapon )
		end
	end
	return "thinking"
end

--[[
ai_tools.use_item_action( self )
* check for first useable item in inventory
* use item, lower energy
--]]
function ai_tools.use_item_action( self )
	local item = ai_tools.use_item_check( self )
	self:use( item )
	self.scount = self.scount - 1000
	return "thinking"
end
