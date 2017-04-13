--Similar to mastermind but uses a secondary weapon

--Grenades are 7-10 spaces, minigun is 0-6 and 12+
local switch_values = { nat_duke_battlelord1 = { {0, 100}, {5, 50}, {7, 20}, {10, 50}, {12, 100} }, nat_duke_battlelord2 = { {6, 50}, {7, 100}, {10, 50}, {12, 0} } }
local battlelord_ai_weaponswitch = function( self )

	local player_dist = self:distance_to( player )
	for weapon_name,switch_list in pairs(switch_values) do

		--Don't run the switch logic for our current weapon
		if (self.eq.weapon.id ~= weapon_name) then

			local percent_swap = 0
			for _,v in ipairs(switch_list) do
				if (player_dist >= v[1]) then
					percent_swap = v[2]
				else
					break
				end
			end

			if (percent_swap == 0 or math.random(100) > percent_swap) then
				return
			end

			for item in self.inv:items() do
				if item and item.itype == ITEMTYPE_NRANGED then
					local energy = self.scount
					if self:wear(item) == true then
						self.scount = energy
						return
					end
				end
			end
		end
	end
end
local battlelord_ai_chooseattack = function( self )

	local player_dist = self:distance_to( player )
	if self.eq.weapon.id == "nat_duke_battlelord1" then
		if player_dist == 1 then
			return "attack_melee"
		elseif math.max((math.min(0, player_dist - 6) * 10), 90) <= math.random(100) then
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

register_ai "duke_battlelord_ai" {
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
		if damage_taken >= 20 then
			self.stun_time = math.floor(damage_taken/20)
			self.assigned = false
			self:msg("", "The ".. self.name .." flinched!")
		end
	end,

	states = {
		thinking = function( self )
			local dist       = self:distance_to( player )
			local visible    = self:in_sight( player )
			self.previous_hp = self.hp

			--Consider weapon choice
			battlelord_ai_weaponswitch( self )

			--Choose target or other action
			if visible and self.stun_time == 0 then
				self.ai_state = battlelord_ai_chooseattack( self )
			else
				if self.stun_time > 0 then
					self.ai_state = "stagger"
				elseif self.attacked then
					if level:eye_contact(self.position, player.position) then
						self.ai_state = battlelord_ai_chooseattack( self )
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

		attack_melee = function( self )
			if math.random(100) <= self.attackchance then
				self:fire( player, self.eq.weapon )
			else
				self:attack( player )
			end
			return "thinking"
		end,

		attack_line = function( self ) return ai_tools.attack_action( self ) end,

		attack_spray = function( self )
			local dist = self:distance_to( player )
			local spray = area.around( player.position, math.floor(dist/3) )
			local num_fire = self.eq.weapon.shots
			self.eq.weapon.shots = 1
			for shot = 1,num_fire do
				local energy = self.scount
				if math.random(2) == 1 then
					self:fire( player, self.eq.weapon )
				else
					local hit = spray:random_coord()
					area.FULL:clamp_coord(hit)
					self:fire( hit, self.eq.weapon )
				end
				if shot ~= 1 then
					self.scount = energy
				end
			end
			self.eq.weapon.shots = num_fire
			return "thinking"
		end,

		attack_full_spray = function( self )
			local dist = self:distance_to( player )
			local spray = area.around( player.position, math.floor(dist/3) )
			local num_fire = self.eq.weapon.shots
			self.eq.weapon.shots = 1
			for shot = 1,num_fire do
				local energy = self.scount
				local hit = spray:random_coord()
				area.FULL:clamp_coord(hit)
				self:fire( hit, self.eq.weapon )

				if shot ~= 1 then
					self.scount = energy
				end
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