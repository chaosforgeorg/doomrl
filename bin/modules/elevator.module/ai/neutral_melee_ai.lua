
register_ai "neutral_melee_ai" {
	OnCreate = function( self )
		self:add_property( "boredom", 6 ) --idle triggers for boredom > 5
		self:add_property( "ai_state", "thinking" )
		self:add_property( "assigned", false )
		self:add_property( "agitated", false )
		self:add_property( "move_to", coord.new(0,0) )
	end,

	OnAttacked = function( self )
		if self.agitated == false and self:in_sight( player ) then
			self.agitated = true
		end
		for b in level:beings_in_range( self, 4 ) do
			if b.id == self.id then
				b.boredom = 0
				b.assigned = false
			end
		end
	end,

	states = {
		thinking = function( self )
			local visible = self:in_sight( player )
			local dist    = self:distance_to( player )

			if self.agitated then
				if visible then
					self.__proto.OnAttacked( self )
				end
				if dist == 1 then
					self.ai_state = "melee"
				else
					self.ai_state = "pursue"
					self.boredom = self.boredom + 1
					if self.boredom > 5 and not visible then
						self.ai_state = "idle"
					end
				end
			else
				self.ai_state = "idle"
			end

			if not self.assigned then
				local walk
				if self.ai_state == "idle" then
					walk = self:flock_target( self.vision, 1, 4 )
				end
				if self.ai_state == "pursue" then
					walk = player.position
				end
				if walk then
					self.move_to = walk
					self.assigned = true
				end
			end
			return self.ai_state
		end,

		idle = function( self )
			if math.random(30) == 1 then
				self:play_sound( self.__proto.sound_act )
			end
			if self:distance_to(self.move_to) == 0 then
				self.scount = self.scount - 500
				self.assigned = false
				return "thinking"
			end
			if not cells[ level.map[self.move_to] ].flags[ CF_HAZARD ] then
				if self:direct_seek( self.move_to ) ~= MOVEOK then
					self.scount = self.scount - 500
					self.assigned = false
				end
			else
				self.scount = self.scount - 500
				self.assigned = false
			end
			return "thinking"
		end,

		melee = function( self ) return ai_tools.melee_action( self ) end,

		pursue = function( self )
			if self:direct_seek( self.move_to ) ~= MOVEOK then
				self.scount = self.scount - 500
			end
			self.assigned = false
			return "thinking"
		end
	}
}

