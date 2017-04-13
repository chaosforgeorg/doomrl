--Same as demon ai but has one extra sound.
register_ai "zerker_ai" {
	OnCreate = function( self )
		self:add_property( "boredom", 6 ) --idle triggers for boredom > 5
		self:add_property( "ai_state", "thinking" )
		self:add_property( "assigned", false )
		self:add_property( "move_to", coord.new(0,0) )
	end,

	OnAttacked = function( self )
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
			
			if visible then
				if self.boredom > 5 then
					self:play_sound( self.id .. ".act2" )
				end
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
				local moves = {}
				local dist = self:distance_to( player )
				for c in self.position:around_coords() do
					if player:distance_to(c) < dist and generator.is_empty(c, { EF_NOBEINGS, EF_NOBLOCK } ) then
						table.insert(moves,c:clone())
					end
				end
				if #moves > 0 then
					if self:direct_seek( table.random_pick(moves) ) ~= MOVEOK then
						self.scount = self.scount - 500
					end
				else
					self.scount = self.scount - 200
				end
			end
			self.assigned = false
			return "thinking"
		end
	}
}
