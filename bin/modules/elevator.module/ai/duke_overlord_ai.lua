--Similar to mastermind but uses rockets

local overlord_ai_chooseattack = function( self )

	local player_dist = self:distance_to( player )
	if self.eq.weapon.id == "nat_duke_battlelord1" then
		if player_dist == 1 then
			return "attack_melee"
		elseif math.max((math.min(0, player_dist - 4) * 10), 90) <= math.random(100) then
			return "attack_line"
		else
			return "attack_spray"
		end
	else
		if player_dist == 1 then
			return "attack_melee"
		elseif player_dist < 4 then
			return "attack_line"
		else
			return "attack_full_spray"
		end
	end
end

register_ai "duke_overlord_ai" {
	OnCreate = function( self )
		self:add_property( "ai_state", "thinking" )
		self:add_property( "assigned", false )
		self:add_property( "move_to", coord.new(0,0) )
		self:add_property( "attackchance", math.min( self.__proto.attackchance * diff[DIFFICULTY].speed, 90 ) )
		self:add_property( "stun_time", 0 )
		self:add_property( "previous_hp", self.hpmax )
		self:add_property( "attacked", false )
	end,

	OnAttacked = function( self )
		self.attacked = true
		local damage_taken = self.previous_hp - self.hp
		if damage_taken >= 30 then
			self.stun_time = 1
			self.assigned = false
			self:msg("", "The ".. self.name .." flinched!")
		end
	end,

	states = {
		thinking = function( self )
			local dist       = self:distance_to( player )
			local visible    = self:in_sight( player )
			self.previous_hp = self.hp

			--Choose target or other action
			if visible and self.stun_time == 0 then
				if dist == 1 then
					self.ai_state = "attack_melee"
				else
					self.ai_state = "attack_line"
				end
			else
				if self.stun_time > 0 then
					self.ai_state = "stagger"
				elseif self.attacked then
					if level:eye_contact(self.position, player.position) then
						self.ai_state = "attack_blind"
						self.attacked = false
					else
						self.ai_state = "maneuver"
					end
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
				elseif self.ai_state == "stagger" then
					self.move_to = generator.random_empty_coord( { EF_NOBEINGS, EF_NOBLOCK }, area.around( self.position ) )
				end
			end

			return self.ai_state
		end,

		attack_melee = function( self ) return ai_tools.melee_action( self ) end,

		attack_line = function( self ) return ai_tools.attack_action( self ) end,

		attack_blind = function( self )
			--Blind fire is a single rocket fired at an unknown attacker.
			local dist = self:distance_to( player )
			local spray = area.around( player.position, math.floor(dist/5) )
			local num_fire = self.eq.weapon.shots
			self.eq.weapon.shots = 1

			if math.random(2) == 1 then
				self:fire( player, self.eq.weapon )
			else
				local hit = spray:random_coord()
				area.FULL:clamp_coord(hit)
				self:fire( hit, self.eq.weapon )
			end

			self.eq.weapon.shots = num_fire
			return "thinking"
		end,

		stagger = function( self )
			self:direct_seek( self.move_to )
			self.stun_time = self.stun_time - 1
			return "thinking"
		end,

		pursue = function( self )
			if self:distance_to( self.move_to ) == 0 then
				self.assigned = false
				return "thinking"
			end
			if math.random(30) == 1 and self.__proto.sound_act then
				self:play_sound( self.__proto.sound_act )
			end
			local move_check, move_coord
			move_check,move_coord = self:path_next()

			-- hack to prevent crash, think of something better later
			if not move_check then
				self.scount = self.scount - 100
			end

			if not move_check or self:distance_to( player ) <= self.vision then
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
			local move_check, move_coord = self:path_next()
			if not move_check or self:in_sight(player) then
				self.assigned = false
				self.attacked = false
			end
			return "thinking"
		end,
	}
}