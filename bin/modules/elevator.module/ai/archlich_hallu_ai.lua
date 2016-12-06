--The hallucination AI mimics the base AI in msot respects but has no special attacks.
register_ai "archlich_hallu_ai" {
	OnCreate = function( self )
		self:add_property( "ai_state", "thinking" )
		self:add_property( "assigned", false )
		self:add_property( "move_to", coord.new(0,0) )
		self:add_property( "attacked", false )
		self:add_property( "attackchance", math.min( self.__proto.attackchance * diff[DIFFICULTY].speed, 90 ) )
		self:add_property( "previous_hp", self.hpmax )
		self:add_property( "teleport_delay", 20 )
		self:add_property( "teleport_basedelay", 10 )
		self:add_property( "teleport_chance", 10 )
	end,

	OnAttacked = function( self )
		self.attacked = true
	end,

	states = {
		thinking = function( self )
			local dist       = self:distance_to( player )
			local visible    = self:in_sight( player )
			self.previous_hp = self.hp

			self.teleport_delay = self.teleport_delay - 1
			if self.teleport_delay <= 0 and visible and math.random(100) < self.teleport_chance then
				self.teleport_delay = self.teleport_delay + self.teleport_basedelay
				self.ai_state = "teleport"
			elseif visible then
				if dist == 1 then
					self.ai_state = "attack_melee"
				elseif math.random(100) <= self.attackchance then
					self.ai_state = "attack_line"
				end
			else
				if self.attacked then
					self.ai_state = "maneuver"
				else
					self.ai_state = "pursue"
				end
			end

			self.attacked = false

			if not self.assigned then
				local walk
				local moves = {}
				if self.ai_state == "pursue" then
					if dist > self.vision then
						self.move_to = player.position
						self:path_find( self.move_to, 40, 200 )
						self.assigned = true
					else
						for c in self.position:around_coords() do
							if player:distance_to(c) == dist and generator.is_empty(c, { EF_NOBEINGS, EF_NOBLOCK } ) then
								table.insert(moves,c:clone())
							end
						end
						if #moves > 0 then
							self.move_to = table.random_pick(moves)
							self:path_find( self.move_to, 1, 1 ) --resets normal pathfind
						else
							self.move_to = generator.random_empty_coord({ EF_NOBEINGS, EF_NOBLOCK }, area.around( self.position ))
							self:path_find( self.move_to, 1, 1 ) --hopefully these settings don't make it expensive
						end
					end
				elseif self.ai_state == "maneuver" then
					for itr = 1,5 do
						for c in area.around( self.position, itr ):corners() do
							if player:in_sight(c) then
								walk = c
								break
							end
						end
						if walk then
							break
						end
					end
					if walk then
						self.move_to = walk
						self:path_find( self.move_to, 40, 200 )
						self.assigned = true
					else
						self.move_to = generator.random_empty_coord({ EF_NOBEINGS, EF_NOBLOCK }, area.around( self.position, 5 ))
						self:path_find( self.move_to, 40, 200 ) --hopefully these settings don't make it expensive
					end
				end
			end

			return self.ai_state
		end,

		attack_melee = function( self )
			--Fake attack
			self:play_sound( self.soundmelee )
			if (math.random(2) == 1) then
				player:msg("Arch-lich hits you.")
			else
				player:msg("Arch-lich misses you.")
			end

			self.scount = self.scount - 1000
			return "thinking"
		end,

		attack_line = function( self ) return ai_tools.attack_action( self ) end,

		pursue = function( self )
			if self:distance_to( self.move_to ) == 0 then
				self.assigned = false
				return "thinking"
			end
			if math.random(30) == 1 then
				self:play_sound( self.id .. ".pursue" )
			end

			local move_check, move_coord
			move_check,move_coord = self:path_next()

			if move_check ~= MOVEOK then
				self.assigned = false
				self.scount = self.scount - 200
			end

			if self:distance_to( player ) <= self.vision then
				self.assigned = false
			end
			return "thinking"
		end,

		maneuver = function( self )
			if self:distance_to( self.move_to ) == 0 then
				self.assigned = false
				self.attacked = false
				return "thinking"
			end
			if math.random(30) == 1 and self.__proto.sound_act then
				self:play_sound( self.__proto.sound_act )
			end
			self:path_next()
			if self:in_sight(player) then
				self.assigned = false
				self.attacked = false
			end
			return "thinking"
		end,

		teleport = function( self )
			self.assigned = false
			self:play_sound("soldier.phase")
			level:explosion( self.position, 2, 50, 0, 0, MAGENTA )
			local target = generator.drop_coord( self.move_to, {EF_NOBEINGS,EF_NOBLOCK} )
			self:relocate( target )
			level:explosion( self.position, 1, 50, 0, 0, MAGENTA )
			self.scount = self.scount - 1000
			return "thinking"
		end,

	}
}

