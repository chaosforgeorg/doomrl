--The red trooper is similar to the human AI but there's an extra action available--a one time cloak.
--The below hack will need to be added to the being's OnAction.
local start_cloak_time = 10
function ai_tools.cloak( self )
  if not self.__ptr or not (self.cloak_time > 0) then
    return
  end

  if self.cloak_time ~= 1 or self:distance_to(player) ~= 0 then
    --A hack to ensure this critter doesn't phase in on the player!
    self.cloak_time = self.cloak_time - 1
  end

  if level:get_being(self.position) == self then
    local c = player.position
    thing.displace(player, self.position)
    thing.displace(player, c)
  end
end

register_ai "duke_trooper_ai" {
	OnCreate = function( self )
		self:add_property( "ai_state", "thinking" )
		self:add_property( "assigned", false )
		self:add_property( "boredom", 9 ) --idle triggers for boredom > 8
		self:add_property( "move_to", coord.new(0,0) )
		self:add_property( "attackchance", math.min( self.__proto.attackchance * diff[DIFFICULTY].speed, 90 ) )
		self:add_property( "cloak_time", -1 ) -- -1 == never cloaked
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

			if self.cloak_time > 0 then --Do not attack if cloaked
				self.ai_state = "evade"
			elseif visible then
				self.boredom = 0

				if(self.cloak_time <= 0 and self.hp < self.hpmax / 2 and math.random(100) < 5) then
					self:msg("",self:get_name(true,true).." vanishes!")
					self:play_sound("duke_captain.teleport")
					level:explosion( self.position, 1, 20, 0, 0, WHITE )
	
					self.cloak_time = start_cloak_time
					self.ai_state = "evade"
				elseif dist == 1 then
					self.ai_state = "melee"
				elseif math.random(100) <= self.attackchance then
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
		
		idle = function( self ) return ai_tools.idle_action_ranged( self, true ) end,
		
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
