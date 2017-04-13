register_ai "marine_ai"
{
	OnCreate = function( self )
		self:add_property( "ai_state", "thinking" )
		self:add_property( "assigned", false )
		self:add_property( "boredom", 9 ) --idle triggers for boredom > 8
		self:add_property( "move_to", coord.new(0,0) )
		self:add_property( "attackchance", math.min( self.__proto.attackchance * diff[DIFFICULTY].speed, 90 ) )
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

			if no_ammo then
				self.ai_state = "idle"
			elseif visible then
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
					--Look for healing, weapons, ammo, or armor.  Only gather what we need.
					local move_dist = self.vision+1
					local step
					if not (self.inv:size() >= MAX_INV_SIZE) then
						for item in level:items_in_range( self, self.vision ) do
							if ( (item.flags[ IF_AIHEALPACK ]
							or   ( item.itype == ITEMTYPE_ARMOR and not self.eq.armor )
							or   ( item.itype == ITEMTYPE_BOOTS and not self.eq.boots )
							or   ( item.itype == ITEMTYPE_RANGED and (not self.eq.weapon or no_ammo) )
							or   ( item.itype == ITEMTYPE_AMMO and (not self.eq.weapon or no_ammo or (self.eq.weapon and self.eq.weapon.ammoid and items[self.eq.weapon.ammoid] and not self.eq.weapon.flags[ IF_NOAMMO ] and items[self.eq.weapon.ammoid].id == item.id))) )
							and self:in_sight( item )  ) then
								local item_dist = self:distance_to( item )
								if item_dist < move_dist then
									move_dist = item_dist
									step = item.position
								end
								break
							end
						end
					end
					if not step then
						step = area.around( self.position, 3 ):clamped( area.FULL ):random_coord()
					end
					walk = step
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

		idle = function( self ) 
			--Modified to equip armor, weapons, etc
			if self:distance_to( self.move_to ) == 0 then
				if not (self.inv:size() >= MAX_INV_SIZE) then
					local item = level:get_item( self.move_to )
					local no_ammo = ai_tools.noammo_check( self )
					if  ( item
					and ( (item.flags[ IF_AIHEALPACK ])
					   or (item.itype == ITEMTYPE_ARMOR and not self.eq.armor)
					   or (item.itype == ITEMTYPE_BOOTS and not self.eq.boots)
					   or (item.itype == ITEMTYPE_RANGED and (not self.eq.weapon or no_ammo))
					   or (item.itype == ITEMTYPE_AMMO and (not self.eq.weapon or no_ammo or (self.eq.weapon and self.eq.weapon.ammoid and items[self.eq.weapon.ammoid] and not self.eq.weapon.flags[ IF_NOAMMO ] and items[self.eq.weapon.ammoid].id == item.id))) ) ) then
						self:pickup( self.move_to )
						if (item and item.__ptr) then --ammo will vanish when collected
							self:wear( item ) --If item is not wearable this just fails silently
						end
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
		end,

		melee = function( self ) return ai_tools.melee_action( self ) end,

		attack = function( self ) return ai_tools.attack_action( self ) end,

		use_item = function( self ) return ai_tools.use_item_action( self ) end,

		pursue = function( self ) return ai_tools.pursue_action( self, false, false ) end,

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