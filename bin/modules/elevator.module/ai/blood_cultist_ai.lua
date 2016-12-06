--AI is identical to former AI but uses different sound playing logic.
local _csounds = { { 1, 2}, { 2, 1}, { 2, 2} }
function ai_tools.blood_idle_action( self, use_item )

	if self.flags[BF_HUNTING] == true then
		self.move_to = player.position
		self:path_find( self.move_to, 10, 40 )
		self.assigned = false
		return "pursue"
	end

	if math.random(30) == 1 then
		self:play_sound( "cultist" .. self.blood_sound_user .. ".act" .. math.random(_csounds[self.blood_sound_user][1]) )
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
function ai_tools.blood_pursue_action( self, approach, wander )
	if self.eq.weapon.itype ~= ITEMTYPE_NRANGED and self.eq.weapon.ammo < math.max(self.eq.weapon.shotcost,1) then
		self:reload()
		return "thinking"
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
	if math.random(30) == 1 then
		self:play_sound( "cultist" .. self.blood_sound_user .. ".pursue" .. math.random(_csounds[self.blood_sound_user][2]) )
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

register_ai "blood_cultist_ai" {
	OnCreate = function( self )
		self:add_property( "ai_state", "thinking" )
		self:add_property( "assigned", false )
		self:add_property( "boredom", 9 ) --idle triggers for boredom > 8
		self:add_property( "move_to", coord.new(0,0) )
		self:add_property( "attackchance", math.min( self.__proto.attackchance * diff[DIFFICULTY].speed, 90 ) )

		self:add_property( "blood_sound_user", math.random(3) )
	end,

	OnAttacked = function( self )
		self.boredom = 0
		self.assigned = false
	end,

	states = {
		thinking = function( self )
			local dist    = self:distance_to( player )
			local visible = self:in_sight( player )
			local no_ammo = ai_tools.noammo_check( self )

			if visible then
				self.boredom = 0
				if dist == 1 then
					self.ai_state = "melee"
				elseif math.random(100) <= self.attackchance and not no_ammo then
					self.ai_state = "attack"
				else
					self.ai_state = "evade"
				end
			else
				self.ai_state = "pursue"
				self.boredom = self.boredom + 1
				if self.boredom > 8 then
					self.ai_state = "idle"
				end
			end

			if self.hp < self.hpmax / 2 and ai_tools.use_item_check( self ) then
				self.ai_state = "use_item"
			end

			if not self.assigned then
				local walk
				if self.ai_state == "idle" then
					walk = ai_tools.idle_assignment( self, true )
				elseif self.ai_state == "pursue" then
					walk = player.position
				elseif self.ai_state == "evade" then
					local s = self.position
					local p = player.position
					if dist < 4 then
						walk = s + (s - p)
						area.FULL:clamp_coord( walk )
						if coord.distance( p, s ) >= coord.distance( p, walk ) then
							walk = area.around( s, 1 ):random_edge_coord()
						end
					else
						local v = s - p
						walk = table.random_pick{ p+coord.new( -v.y, v.x ), p+coord.new( v.y, -v.x ) }
					end
					area.FULL:clamp_coord( walk )
				end
				if walk then
					self.move_to = walk
					self:path_find( self.move_to, 10, 40 )
					self.assigned = true
				end
			end
			return self.ai_state
		end,

		idle = function( self ) return ai_tools.blood_idle_action( self, true ) end,

		melee = function( self ) return ai_tools.melee_action( self ) end,

		attack = function( self ) return ai_tools.attack_action( self ) end,

		use_item = function( self ) return ai_tools.use_item_action( self ) end,

		pursue = function( self ) return ai_tools.blood_pursue_action( self, false, false ) end,

		evade = function( self )
			if self:distance_to( self.move_to ) == 0 then
				self.assigned = false
			else
				local move_check = self:path_next()
				if move_check ~= MOVEOK then
					if not self:path_find( self.move_to, 10, 40 ) then
						self.assigned = false
						self.scount = self.scount - 200
					else
						if self:path_next() ~= MOVEOK then
							self.assigned = false
							self.scount = self.scount - 200
						end
					end
				end
			end
			return "thinking"
		end,
	}
}
