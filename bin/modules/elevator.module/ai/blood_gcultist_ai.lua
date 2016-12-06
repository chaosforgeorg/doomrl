require("elevator:ai/blood_cultist_ai")

register_ai "blood_gcultist_ai" {
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

		--The change
		attack = function( self )
			if self.eq.weapon.itype ~= ITEMTYPE_NRANGED and self.eq.weapon.ammo < math.max(self.eq.weapon.shotcost,1) then
				self:reload()
			else
				--Whiff this throw (make a minor std distribution)
				local self_x = self.position.x
				local self_y = self.position.y
				local target_x = player.position.x
				local target_y = player.position.y
				local whiff_x = math.floor( ((math.random() + math.random() + math.random() + math.random() + math.random()) / 5) * 9) - 4
				local whiff_y = math.floor( ((math.random() + math.random() + math.random() + math.random() + math.random()) / 5) * 9) - 4

				--No matter how bad the thrower, I don't expect them to ever throw behind or on themselves
				if ((self_x < target_x and target_x + whiff_x <= self_x) or
				    (self_x > target_x and target_x + whiff_x >= self_x)) then
					whiff_x = 0
				end
				if ((self_y < target_y and target_y + whiff_y <= self_y) or
				    (self_y > target_y and target_y + whiff_y >= self_y)) then
					whiff_y = 0
				end

				self:fire( coord.new(target_x + whiff_x, target_y + whiff_y), self.eq.weapon )
			end
			return "thinking"
		end,

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
