register_ai "former_ai"
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
register_ai "flee_former_ai"
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

			if visible then
				self.boredom = 0
				if dist == 1 then
					self.ai_state = "melee"
				elseif math.random(100) <= self.attackchance and not no_ammo then
					self.ai_state = "attack"
				elseif dist < 4 then
					self.ai_state = "flee"
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
				elseif self.ai_state == "flee" then
					local pos = self.position
					walk = pos + (pos - player.position)
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

		flee = function( self )
			if self:distance_to( self.move_to ) == 0 then
				self.assigned = false
			elseif self:direct_seek( self.move_to ) ~= MOVEOK then
				self.scount = self.scount - 500
				self.assigned = false
			end
			return "thinking"
		end,

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

register_ai "baron_ai"
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
			local visible = self:in_sight( player )

			if visible then
				self.boredom = 0
				if self:distance_to( player ) == 1 then
					self.ai_state = "melee"
				elseif math.random(100) <= self.attackchance then
					self.ai_state = "attack"
				else
					self.ai_state = "pursue"
				end
			else
				self.ai_state = "pursue"
				self.boredom = self.boredom + 1
				if self.boredom > 8 and not self.flags[BF_HUNTING] then
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
	}
}

register_ai "lostsoul_ai"
{

	OnCreate = function( self )
		self:add_property( "ai_state", "thinking" )
		self:add_property( "assigned", false )
		self:add_property( "attacked", false )
		self:add_property( "move_to_player", coord.new(0,0) )
		self:add_property( "move_to", coord.new(0,0) )
		self:add_property( "attackchance", math.min( self.__proto.attackchance * diff[DIFFICULTY].speed, 90 ) )
		self:add_property( "move_count", 0 )
	end,

	OnAttacked = function( self )
		self.attacked = true
		if self.ai_state ~= "thinking" then
			self.scount = self.scount - 500
		end
	end,

	states = {
		thinking = function( self )
			local visible = self:in_sight( player )
			local dist    = self:distance_to( player )

			if self.attacked or (visible and self.attackchance <= math.random(100)) then
				self.ai_state = "charge"
				self.attacked = false
				self.assigned = false
			else
				self.ai_state = "idle"
			end

			if not self.assigned then
				local s = self.position
				local p = player.position
				local walk
				if self.ai_state == "idle" then
					walk = area.around( self.position, 3 ):clamped( area.FULL ):random_edge_coord()
				end
				if self.ai_state == "charge" then
					local v = p - s
					walk = p
					repeat
						walk = walk + v
					until not area.FULL:contains( walk )
					self.move_to_player = p
				end
				if walk then
					self.move_to = walk
					self.assigned = true
				end
			end
			return self.ai_state
		end,

		idle = function( self ) return ai_tools.idle_action_melee( self ) end,

		charge = function( self )
			local move_check,move_coord = self:direct_seek( self.move_to_player )
			if move_check ~= MOVEOK then
				if player:distance_to(move_coord) == 0 then
					self:attack(move_coord)
				end
				self.move_count = 0
				self.assigned = false
				return "thinking"
			else
				self.scount = self.scount + 750
				self.move_count = self.move_count + 1
				if move_coord == self.move_to_player then
					return "charge2"
				end
			end
		end,

		charge2 = function( self )
			if self.move_count > 15 or self.attacked then
				self.move_count = 0
				self.assigned = false
				self.attacked = false
				return "thinking"
			else
				local move_check,move_coord = self:direct_seek( self.move_to )
				if move_check ~= MOVEOK then
					if player:distance_to(move_coord) == 0 then
						self:attack(move_coord)
					end
					self.move_count = 0
					self.assigned = false
					return "thinking"
				else
					self.scount = self.scount + 750
					self.move_count = self.move_count + 1
				end
			end
		end,
	}
}

register_ai "demon_ai"
{

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

		idle = function( self ) return ai_tools.idle_action_melee( self ) end,

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
					if not self:direct_seek( table.random_pick(moves) ) then
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

register_ai "melee_seek_ai"
{

	OnCreate = function( self )
		self:add_property( "ai_state", "thinking" )
		self:add_property( "attacked", false )
		self:add_property( "assigned", false )
		self:add_property( "move_to", coord.new(0,0) )
		self:add_property( "steps", 0 )
	end,

	OnAttacked = function( self )
		self.attacked = true
	end,

	states = {
		thinking = function( self )
			local dist    = self:distance_to( player )
			local visible = self:in_sight( player )

			if dist == 1 then
				self.ai_state = "melee"
			elseif visible or dist <= 5 or self.flags[BF_HUNTING] then
				self.ai_state = "pursue"
			else
				self.ai_state = "idle"
			end

			if not self.assigned then
				if self.ai_state == "pursue" then
					self.move_to = self:path_find( player, 40, 100 )
					self.assigned = true
				end
			end
			return self.ai_state
		end,

		idle = function( self )
			self.scount = self.scount - 500
			return "thinking"
		end,

		melee = function( self ) return ai_tools.melee_action( self )	end,

		pursue = function( self )
			if math.random(30) == 1 then
				self:play_sound( self.__proto.sound_act )
			end
			self.steps = self.steps + 1
			local step = self:path_next()
			if self.steps == 5 or self.steps > self:distance_to( player ) or step == MOVEBLOCK or step == MOVEBEING then
				self.steps = 0
				self.assigned = false
				self.scount = self.scount - 500
			end
			return "thinking"
		end,
	}
}

register_ai "melee_ranged_ai"
{

	OnCreate = function( self )
		self:add_property( "boredom", 9 ) --idle triggers for boredom > 8
		self:add_property( "assigned", false )
		self:add_property( "ai_state", "thinking" )
		self:add_property( "move_to", coord.new(0,0) )
		self:add_property( "attackchance", math.min( self.__proto.attackchance * diff[DIFFICULTY].speed, 90 ) )
	end,

	OnAttacked = function( self )
		self.boredom = 0
		self.assigned = false
	end,

	states = {
		thinking = function( self )
			local visible = self:in_sight( player )

			if visible then
				local dist = self:distance_to( player )
				self.boredom = 0
				if dist == 1 then
					self.ai_state = "melee"
				elseif not ai_tools.noammo_check( self ) and math.random(100) <= self.attackchance then
					self.ai_state = "attack"
				else
					self.ai_state = "pursue"
				end
			else
				self.ai_state = "pursue"
				self.boredom = self.boredom + 1
				if self.boredom > 8 then
					self.ai_state = "idle"
				end
			end

			if not self.assigned then
				local walk
				if self.ai_state == "idle" then
					walk = ai_tools.idle_assignment( self, false )
				elseif self.ai_state == "pursue" then
					walk = player.position
				end
				if walk then
					self.move_to = walk
					self:path_find( self.move_to, 10, 40)
					self.assigned = true
				end
			end
			return self.ai_state
		end,

		idle = function( self ) return ai_tools.idle_action_ranged( self, false ) end,

		melee = function( self ) return ai_tools.melee_action( self ) end,

		attack = function( self ) return ai_tools.attack_action( self ) end,

		pursue = function( self ) return ai_tools.pursue_action( self, true, false ) end,
	}
}

register_ai "ranged_ai"
{

	OnCreate = function( self )
		self:add_property( "boredom", 9 ) --idle triggers for boredom > 8
		self:add_property( "assigned", false )
		self:add_property( "ai_state", "thinking" )
		self:add_property( "move_to", coord.new(0,0) )
		self:add_property( "attackchance", math.min( self.__proto.attackchance * diff[DIFFICULTY].speed, 90 ) )
	end,

	OnAttacked = function( self )
		self.boredom = 0
		self.assigned = false
	end,

	states = {
		thinking = function( self )
			local visible = self:in_sight( player )

			if visible then
				local dist    = self:distance_to( player )
				self.boredom = 0
				if dist == 1 then
					self.ai_state = "melee"
				elseif not ai_tools.noammo_check( self ) and math.random(100) <= self.attackchance then
					self.ai_state = "attack"
				else
					self.ai_state = "pursue"
				end
			else
				self.ai_state = "pursue"
				self.boredom = self.boredom + 1
				if self.boredom > 8 then
					self.ai_state = "idle"
				end
			end

			if not self.assigned then
				local walk
				if self.ai_state == "idle" then
					walk = ai_tools.idle_assignment( self, false )
				elseif self.ai_state == "pursue" then
					walk = player.position
				end
				if walk then
					self.move_to = walk
					self:path_find( self.move_to, 10, 40)
					self.assigned = true
				end
			end
			return self.ai_state
		end,

		idle = function( self ) return ai_tools.idle_action_ranged( self, false ) end,

		melee = function( self ) return ai_tools.melee_action( self ) end,

		attack = function( self ) return ai_tools.attack_action( self ) end,

		pursue = function( self ) return ai_tools.pursue_action( self, true, true) end,
	}
}

register_ai "flee_ranged_ai"
{

	OnCreate = function( self )
		self:add_property( "boredom", 9 ) --idle triggers for boredom > 8
		self:add_property( "assigned", false )
		self:add_property( "ai_state", "thinking" )
		self:add_property( "move_to", coord.new(0,0) )
		self:add_property( "attackchance", math.min( self.__proto.attackchance * diff[DIFFICULTY].speed, 90 ) )
	end,

	OnAttacked = function( self )
		self.boredom = 0
		self.assigned = false
	end,

	states = {
		thinking = function( self )
			local visible = self:in_sight( player )

			if visible then
				local dist    = self:distance_to( player )
				self.boredom = 0
				if dist == 1 then
					self.ai_state = "melee"
				elseif not ai_tools.noammo_check( self ) and math.random(100) <= self.attackchance then
					self.ai_state = "attack"
				elseif dist < 4 then
					self.ai_state = "flee"
				else
					self.ai_state = "pursue"
				end
			else
				self.ai_state = "pursue"
				self.boredom = self.boredom + 1
				if self.boredom > 8 then
					self.ai_state = "idle"
				end
			end

			if not self.assigned then
				local walk
				if self.ai_state == "idle" then
					walk = ai_tools.idle_assignment( self, false )
				elseif self.ai_state == "pursue" then
					walk = player.position
				elseif self.ai_state == "flee" then
					local pos = self.position
					walk = pos + (pos - player.position)
					area.FULL:clamp_coord( walk )
				end
				if walk then
					self.move_to = walk
					self:path_find( self.move_to, 10, 40)
					self.assigned = true
				end
			end
			return self.ai_state
		end,

		idle = function( self ) return ai_tools.idle_action_ranged( self, false ) end,

		melee = function( self ) return ai_tools.melee_action( self ) end,

		attack = function( self ) return ai_tools.attack_action( self ) end,

		flee = function( self )
			if self:distance_to( self.move_to ) == 0 then
				self.assigned = false
			elseif self:direct_seek( self.move_to ) ~= MOVEOK then
				self.scount = self.scount - 500
				self.assigned = false
			end
			return "thinking"
		end,

		pursue = function( self ) return ai_tools.pursue_action( self, true, true) end,
	}
}

register_ai "sequential_ai"
{

	OnCreate = function( self )
		self:add_property( "boredom", 10 ) --idle triggers for boredom > 9
		self:add_property( "assigned", false )
		self:add_property( "shots", 0 )
		self:add_property( "move_to", coord.new(0,0) )
		self:add_property( "attack_to", coord.new(0,0) )
		self:add_property( "ai_state", "thinking" )
		self:add_property( "attackchance", math.min( self.__proto.attackchance * diff[DIFFICULTY].speed, 90 ) )
		self:add_property( "sound_attack", core.resolve_sound_id(self.id .. ".attack") )
	end,

	OnAttacked = function( self )
		self.boredom = 0
		self.shots = 0
		self.assigned = false
		self.ai_state = "thinking"
	end,

	states = {
		thinking = function( self )
			local dist    = self:distance_to( player )
			local visible = self:in_sight( player )

			if visible then
				self.boredom = 0
				if dist == 1 then
					self.ai_state = "melee"
				elseif math.random(100) <= self.attackchance and self.shots == 0 then
					self.assigned = false
					self.ai_state = "fire"
				else
					self.ai_state = "pursue"
				end
			else
				self.ai_state = "pursue"
				self.boredom = self.boredom + 1
				if self.boredom > 8 then
					self.ai_state = "idle"
				end
			end

			if self.shots > 0 then self.shots = self.shots - 1 end

			if not self.assigned then
				local walk
				if self.ai_state == "idle" then
					walk = ai_tools.idle_assignment( self, false )
				elseif self.ai_state == "pursue" then
					walk = player.position
				elseif self.ai_state == "fire" then
					self:play_sound( self.sound_attack )
					self.attack_to = player.position
					self.shots = 2 + math.random(3)
					self.assigned = true
				end
				if walk then
					self.move_to = walk
					self:path_find( self.move_to, 10, 40)
					self.assigned = true
				end
			end
			return self.ai_state
		end,

		idle = function( self ) return ai_tools.idle_action_ranged( self, false ) end,

		melee = function( self ) return ai_tools.melee_action( self ) end,

		--has potential loop uninterrupted by thinking
		fire = function( self )
			local next_state = ""
			if self.shots > 0 then self.shots = self.shots - 1 end
			if not self:in_sight( player ) or self.shots == 0 then
				self.shots = 3 -- cooldown
				next_state = "thinking"
			else
				self.attack_to = player.position
				next_state = "fire"
			end
			self:fire( self.attack_to, self.eq.weapon )
			return next_state
		end,

		pursue = function( self ) return ai_tools.pursue_action( self, true, true ) end,
	}
}

register_ai "teleboss_ai"
{

	OnCreate = function( self )
		self:add_property( "ai_state", "thinking" )
		self:add_property( "assigned", false )
		self:add_property( "boredom", 0 )
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
			local no_melee = false

			if (self:has_property("telechance") and math.random(self.telechance) == 1) or (not self:has_property("telechance") and math.random(10) == 1) then
				self.assigned = false
				self.ai_state = "teleport"
				no_melee = true
			else
				self.ai_state = "hunt"
			end
			if visible and not no_melee then
				if dist == 1 then
					self.ai_state = "melee"
				elseif math.random(100) <= self.attackchance then
					self.ai_state = "attack"
				end
			end
			no_melee = false

			if not self.assigned then
				local p = player.position
				local s = self.position
				if self.ai_state == "hunt" then
					self:path_find( p, 10, 40 )
					self.move_to = p
					self.assigned = true
				elseif self.ai_state == "teleport" then
					local phase = nil
					local phase_check = 0
					local phase_rad = self.teleradius or 5

					if dist <= phase_rad then
						local flee = coord.new(2*(s.x-p.x), 2*(s.y-p.y))
						phase = table.random_pick{ p + flee, p - flee }
						area.FULL_SHRINKED:clamp_coord( phase )
						phase = generator.drop_coord( phase, {EF_NOBEINGS,EF_NOBLOCK} )
					end

					if not phase then
						local parea = area.around( p, phase_rad ):clamped( area.FULL_SHRINKED )
						repeat
							phase = generator.random_empty_coord( { EF_NOBEINGS, EF_NOBLOCK }, parea )
							phase_check = phase_check + 1
						until ( phase and level:eye_contact( p, phase ) ) or phase_check == 25
					end
					if phase_check == 25 then
						return "thinking"
					end
					self.move_to = phase
					self.assigned = true
				end
			end
			return(self.ai_state)
		end,

		melee = function( self ) return ai_tools.melee_action( self ) end,

		attack = function( self ) return ai_tools.attack_action( self ) end,

		hunt = function( self )
			if math.random(30) == 1 then
				self:play_sound( self.__proto.sound_act )
			end

			if self:distance_to( self.move_to ) == 0 then
				self.assigned = false
			else
				local move_check,move_coord = self:path_next()
				if move_check ~= MOVEOK then
					if move_check == MOVEDOOR then
--						being:open( move_coord )
					else
						self.assigned = false
						self.scount = self.scount - 200
					end
				end
			end
			self.boredom = self.boredom + 1
			if self.boredom >= 3 then
				self.assigned = false
			end
			return "thinking"
		end,

		teleport = function( self )
			self.assigned = false
			self:play_sound("soldier.phase")
			level:explosion( self, 2, 50, 0, 0, YELLOW )
			local target = generator.drop_coord( self.move_to, {EF_NOBEINGS,EF_NOBLOCK} )
			self:relocate( target )
			level:explosion( self, 1, 50, 0, 0, YELLOW )
			self.scount = self.scount - 1000
			return "thinking"
		end,
	}
}

--A passive AI doesn't do anything except move around.  A sessile being won't even do that.
--Optionally on player attack the AI can be switched.  For the switch to work you'll need to
--add any missing being properties!  I've only included the standards.
register_ai "passive_ai"
{
	OnCreate = function( self )
		self:add_property( "ai_state", "thinking" )
		self:add_property( "assigned", false )
		self:add_property( "move_to", coord.new(0,0) )
		self:add_property( "ai_type_attacked", false )
	end,

	OnAttacked = function( self )
		--Hack: chaining the OnAttacked hook manually is all kinds of wrong but seems like the only option
		if (self.ai_type == "passive_ai") then
			if (self.ai_type_attacked) then
				self.ai_type = self.ai_type_attacked
				self:remove_property( "ai_type_attacked" )
				ais[ self.ai_type ].OnCreate( self )
			end
			self.boredom = 0
			self.assigned = false
		end
		ais[ self.ai_type ].OnAttacked( self )
	end,

	states = {
		thinking = function( self )
			--Hack
			if (self.flags[ BF_SESSILE ] == true) then
				self.assigned = false
				self.scount = self.scount - 500
			else
				self.ai_state = "idle"
			end

			if not self.assigned then
				local walk
				if self.ai_state == "idle" then
					walk = ai_tools.idle_assignment( self, true )
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

		pursue = function( self )
			if self:distance_to( self.move_to ) == 0 then
				self.assigned = false
				return "thinking"
			end
			local move_check = nil
			local move_coord = nil
			if self:in_sight( player ) then
				move_check,move_coord = self:direct_seek( player )
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
		end,
	}
}
-- The robot AI is a standard AI with two differences: one, it breaks down at 30% damage and can't move very
-- well in that circumstance (something I couldn't implement with an OnAction cheat) and two, if it's broken
-- down it will blindfire at you if it takes damage.
register_ai "wolf_robot_ai"
{
	OnCreate = function( self )
		self:add_property( "boredom", 9 ) --idle triggers for boredom > 8
		self:add_property( "assigned", false )
		self:add_property( "ai_state", "thinking" )
		self:add_property( "move_to", coord.new(0,0) )
		self:add_property( "attack_to", coord.new(0,0) )
		self:add_property( "attackchance", math.min( self.__proto.attackchance * diff[DIFFICULTY].speed, 90 ) )
		self:add_property( "attacked", false)
		self:add_property( "damage_level", 0)
	end,

	OnAttacked = function( self )
		self.attack_to = player.position
		self.boredom = 0
	end,

	states = {
		thinking = function( self )
			local visible = self:in_sight( player )

			if visible then
				local dist = self:distance_to( player )
				self.boredom = 0
				if dist == 1 then
					self.ai_state = "melee"
				elseif not ai_tools.noammo_check( self ) and math.random(100) <= self.attackchance then
					self.ai_state = "attack"
				elseif self.damage_level <= 2 or math.random(6) == 1 then
					self.ai_state = "pursue"
				else
					--Tried to move, couldn't
					self.assigned = false
					self.scount = self.scount - 500
				end
			elseif self.damage_level > 2 and self.boredom <= 0 and math.random(100) <= math.floor(self.attackchance / 2) then
				--Was attacked offscreen, shoot back.
				self.ai_state = "attack"
			else
				if self.damage_level <= 2 or math.random(6) == 1 then
					self.ai_state = "pursue"
					self.boredom = self.boredom + 1
					if self.boredom > 8 then
						self.ai_state = "idle"
					end
				else
					--Tried to move, couldn't
					self.assigned = false
					self.scount = self.scount - 500
				end
			end

			if not self.assigned then
				local walk
				if self.ai_state == "idle" then
					walk = ai_tools.idle_assignment( self, false )
				elseif self.ai_state == "pursue" then
					walk = player.position
				end
				if walk then
					self.move_to = walk
					self:path_find( self.move_to, 10, 40)
					self.assigned = true
				end
			end
			return self.ai_state
		end,

		idle = function( self ) return ai_tools.idle_action_ranged( self, false ) end,

		melee = function( self ) return ai_tools.melee_action( self ) end,

		attack = function( self )
			self.assigned = false
			if self:in_sight( player ) then
				self:fire( player.position, self.eq.weapon )
			else
				self:fire( self.attack_to, self.eq.weapon )
			end
			return "thinking"
		end,

		pursue = function( self ) return ai_tools.pursue_action( self, true, false ) end,
	}
}

register_ai "pac_blinky_ai" {

	OnCreate = function( self )
		self:add_property( "last_square", coord.new(0, 0) )
		self:add_property( "last_player_square", coord.new(75, 17) )
		self:add_property( "current_player_square", coord.new(75, 17) )
		self:add_property( "home_square", coord.new(75, 17) )
		self:add_property( "attack_mode", "scatter")
		self:add_property( "attack_rank", 0)
		self:add_property( "attack_next", core.game_time())
		self:add_property( "cruise", false )
		self:add_property( "ai_state", "thinking" )
	end,
	OnAttacked = function( self ) end,

	states = {
		thinking = function( self )
			if (self.current_player_square ~= player.position) then 
				self.last_player_square = self.current_player_square
				self.current_player_square = player.position
			end

			if ( self.attack_next <= core.game_time()) then
				if ( self.attack_mode == "scatter" ) then
					self.ai_state = "switch_chase"
				else
					self.ai_state = "switch_scatter"
				end
			else
				self.ai_state = "action"
			end

			return self.ai_state
		end,

		switch_chase = function( self )
			self.attack_mode = "chase"
			self.attack_rank = self.attack_rank + 1
			self.attack_next = self.attack_next + 2000 + (200 * self.attack_rank)

			self.ai_state = "action"
			return self.ai_state
		end,
		switch_scatter = function( self )
			self.attack_mode = "scatter"
			self.attack_next = self.attack_next + (1000 - math.max(math.min((self.attack_rank * 50), 250), 750))

			--Force a reversal
			local coord_diff = (self.last_square - self.position)
			self.last_square = self.position + coord_diff * -2

			--Calc cruise mode
			if self.cruise ~= true then
				local pac_small = 0
				for item in level:items() do
					if ( item.id == "wolf_chalice" ) then
						pac_small = pac_small + 1
					end
				end
				if (pac_small < 20) then self.cruise = true end
			end

			self.ai_state = "action"
			return self.ai_state
		end,

		_calc_chase = function( self )
			--Blinky target mode: select Pac-Man's square
			return player.position
		end,
		_calc_scatter = function( self )
			if (self.cruise) then
				return player.position
			else
				return self.home_square
			end
		end,

		action = function( self )

			--Ghosts cannot move diagonally, nor can they go backwards (unless they are in a corner).
			--Calc all potential movement cells.
			local move_options = {}
			local move_norun_options = {}
			for c in self.position:cross_coords() do
				--if we can move there add to list
				--if ( and c ~= self.last_square)
				local cell = cells[ level.map[ c ] ]
				if not cell.flags[ CF_BLOCKMOVE ] and c ~= self.last_square then
					if not cell.flags[ CF_NORUN ] then
						table.insert(move_options, c:clone())
					else
						table.insert(move_norun_options, c:clone())
					end
				end
			end
			if (#move_options <=0 and #move_norun_options > 0) then move_options = move_norun_options end

			--If there is only one possible move that simplifies things.  Otherwise we must calc our target coord and determine the best path.
			local move
			if (#move_options <= 0) then
				--Should only happen on a dead end
				move = self.last_square
			elseif (#move_options == 1) then
				move = move_options[1]
			else
				local target
				if self.attack_mode == "chase" then
					target = ais[ self.ai_type ].states["_calc_chase"]( self )
				else
					target = ais[ self.ai_type ].states["_calc_scatter"]( self )
				end

				local closest = 999
				for _,cc in ipairs(move_options) do
					local distance = math.sqrt(math.abs(cc.x-target.x)^2 + math.abs(cc.y-target.y)^2)
					if distance  < closest then
						move = cc
						closest = distance
					end
				end
			end
 
			--Move or attack.
			if (move == player.position) then
				self:attack( player )
			else
				self.last_square = self.position
				if (self:direct_seek( move ) ~= MOVEOK) then
					--Blocked, most likely by a being.  Just wait a half-tick and try again and just to be safe free up the previous cell.
					self.scount = self.scount - 500
				end
			end

			return "thinking"
		end
	}
}
register_ai "pac_pinky_ai" {

	OnCreate = function( self )
		self:add_property( "last_square", coord.new(0, 0) )
		self:add_property( "last_player_square", coord.new(75, 4) )
		self:add_property( "current_player_square", coord.new(75, 4) )
		self:add_property( "home_square", coord.new(75, 4) )
		self:add_property( "attack_mode", "scatter")
		self:add_property( "attack_rank", 0)
		self:add_property( "attack_next", core.game_time())
		self:add_property( "ai_state", "thinking" )
	end,
	OnAttacked = function( self ) end,

	states = {
		thinking = function( self )
			if (self.current_player_square ~= player.position) then 
				self.last_player_square = self.current_player_square
				self.current_player_square = player.position
			end

			if ( self.attack_next <= core.game_time()) then
				if ( self.attack_mode == "scatter" ) then
					self.ai_state = "switch_chase"
				else
					self.ai_state = "switch_scatter"
				end
			else
				self.ai_state = "action"
			end

			return self.ai_state
		end,

		switch_chase = function( self )
			self.attack_mode = "chase"
			self.attack_rank = self.attack_rank + 1
			self.attack_next = self.attack_next + 2000 + (200 * self.attack_rank)

			self.ai_state = "action"
			return self.ai_state
		end,
		switch_scatter = function( self )
			self.attack_mode = "scatter"
			self.attack_next = self.attack_next + (1000 - math.max(math.min((self.attack_rank * 50), 250), 750))

			--Force a reversal
			local coord_diff = (self.last_square - self.position)
			self.last_square = self.position + coord_diff * -2

			self.ai_state = "action"
			return self.ai_state
		end,

		_calc_chase = function( self )
			--Pinky target mode: select the square four cells in front
			--of Pac-Man (and in a roguelike that means diagonals!)
			local direction = player.position - self.last_player_square
			local direction_normal = coord.new(math.max(math.min(direction.x, 1), -1), math.max(math.min(direction.y, 1), -1))
			return player.position + (direction_normal * 4)
		end,
		_calc_scatter = function( self )
			return self.home_square
		end,

		action = function( self )

			--Ghosts cannot move diagonally, nor can they go backwards (unless they are in a corner).
			--Calc all potential movement cells.
			local move_options = {}
			local move_norun_options = {}
			for c in self.position:cross_coords() do
				--if we can move there add to list
				--if ( and c ~= self.last_square)
				local cell = cells[ level.map[ c ] ]
				if not cell.flags[ CF_BLOCKMOVE ] and c ~= self.last_square then
					if not cell.flags[ CF_NORUN ] then
						table.insert(move_options, c:clone())
					else
						table.insert(move_norun_options, c:clone())
					end
				end
			end
			if (#move_options <=0 and #move_norun_options > 0) then move_options = move_norun_options end

			--If there is only one possible move that simplifies things.  Otherwise we must calc our target coord and determine the best path.
			local move
			if (#move_options <= 0) then
				--Should only happen on a dead end
				move = self.last_square
			elseif (#move_options == 1) then
				move = move_options[1]
			else
				local target
				if self.attack_mode == "chase" then
					target = ais[ self.ai_type ].states["_calc_chase"]( self )
				else
					target = ais[ self.ai_type ].states["_calc_scatter"]( self )
				end

				local closest = 999
				for _,cc in ipairs(move_options) do
					local distance = math.sqrt(math.abs(cc.x-target.x)^2 + math.abs(cc.y-target.y)^2)
					if distance  < closest then
						move = cc
						closest = distance
					end
				end
			end
 
			--Move or attack.
			if (move == player.position) then
				self:attack( player )
			else		self.last_square = self.position
				if (self:direct_seek( move ) ~= MOVEOK) then
					--Blocked, most likely by a being.  Just wait a half-tick and try again and just to be safe free up the previous cell.
					self.scount = self.scount - 500
				end
			end

			return "thinking"
		end
	}
}
register_ai "pac_inky_ai" {

	OnCreate = function( self )
		self:add_property( "last_square", coord.new(0, 0) )
		self:add_property( "last_player_square", coord.new(2, 19) )
		self:add_property( "current_player_square", coord.new(2, 19) )
		self:add_property( "home_square", coord.new(2, 19) )
		self:add_property( "attack_mode", "scatter")
		self:add_property( "attack_rank", 0)
		self:add_property( "attack_next", core.game_time())
		self:add_property( "ai_state", "thinking" )
	end,
	OnAttacked = function( self ) end,

	states = {
		thinking = function( self )
			if (self.current_player_square ~= player.position) then 
				self.last_player_square = self.current_player_square
				self.current_player_square = player.position
			end

			if ( self.attack_next <= core.game_time()) then
				if ( self.attack_mode == "scatter" ) then
					self.ai_state = "switch_chase"
				else
					self.ai_state = "switch_scatter"
				end
			else
				self.ai_state = "action"
			end

			return self.ai_state
		end,

		switch_chase = function( self )
			self.attack_mode = "chase"
			self.attack_rank = self.attack_rank + 1
			self.attack_next = self.attack_next + 2000 + (200 * self.attack_rank)

			self.ai_state = "action"
			return self.ai_state
		end,
		switch_scatter = function( self )
			self.attack_mode = "scatter"
			self.attack_next = self.attack_next + (1000 - math.max(math.min((self.attack_rank * 50), 250), 750))

			--Force a reversal
			local coord_diff = (self.last_square - self.position)
			self.last_square = self.position + coord_diff * -2

			self.ai_state = "action"
			return self.ai_state
		end,

		_calc_chase = function( self )
			--Inky's an odd one.  With him you start at blinky, head to the cell two squares
			--in front of Pac-Man, then double the distance you walked.

			--Find Blinky.
			local blinky = nil
			for b in level:beings() do
				if (b.id == "pac_blinky") then
					blinky = b
					break
				end
			end
			if (blinky == nil) then return player.position end

			--Work out target coord
			local direction = player.position - self.last_player_square
			local direction_normal = coord.new(math.max(math.min(direction.x, 1), -1), math.max(math.min(direction.y), 1, -1))
			local halfway_target = (player.position + (direction_normal * 2))
			local blinky_pos = blinky.position

			return ((halfway_target - blinky_pos) * 2) + blinky_pos
		end,
		_calc_scatter = function( self )
			return self.home_square
		end,

		action = function( self )

			--Ghosts cannot move diagonally, nor can they go backwards (unless they are in a corner).
			--Calc all potential movement cells.
			local move_options = {}
			local move_norun_options = {}
			for c in self.position:cross_coords() do
				--if we can move there add to list
				--if ( and c ~= self.last_square)
				local cell = cells[ level.map[ c ] ]
				if not cell.flags[ CF_BLOCKMOVE ] and c ~= self.last_square then
					if not cell.flags[ CF_NORUN ] then
						table.insert(move_options, c:clone())
					else
						table.insert(move_norun_options, c:clone())
					end
				end
			end
			if (#move_options <=0 and #move_norun_options > 0) then move_options = move_norun_options end

			--If there is only one possible move that simplifies things.  Otherwise we must calc our target coord and determine the best path.
			local move
			if (#move_options <= 0) then
				--Should only happen on a dead end
				move = self.last_square
			elseif (#move_options == 1) then
				move = move_options[1]
			else
				local target
				if self.attack_mode == "chase" then
					target = ais[ self.ai_type ].states["_calc_chase"]( self )
				else
					target = ais[ self.ai_type ].states["_calc_scatter"]( self )
				end

				local closest = 999
				for _,cc in ipairs(move_options) do
					local distance = math.sqrt(math.abs(cc.x-target.x)^2 + math.abs(cc.y-target.y)^2)
					if distance  < closest then
						move = cc
						closest = distance
					end
				end
			end
 
			--Move or attack.
			if (move == player.position) then
				self:attack( player )
			else		self.last_square = self.position
				if (self:direct_seek( move ) ~= MOVEOK) then
					--Blocked, most likely by a being.  Just wait a half-tick and try again and just to be safe free up the previous cell.
					self.scount = self.scount - 500
				end
			end

			return "thinking"
		end
	}
}
register_ai "pac_clyde_ai" {

	OnCreate = function( self )
		self:add_property( "last_square", coord.new(0, 0) )
		self:add_property( "last_player_square", coord.new(2,  2) )
		self:add_property( "current_player_square", coord.new(2,  2) )
		self:add_property( "home_square", coord.new(2,  2) )
		self:add_property( "attack_mode", "scatter")
		self:add_property( "attack_rank", 0)
		self:add_property( "attack_next", core.game_time())
		self:add_property( "ai_state", "thinking" )
	end,
	OnAttacked = function( self ) end,

	states = {
		thinking = function( self )
			if (self.current_player_square ~= player.position) then 
				self.last_player_square = self.current_player_square
				self.current_player_square = player.position
			end

			if ( self.attack_next <= core.game_time()) then
				if ( self.attack_mode == "scatter" ) then
					self.ai_state = "switch_chase"
				else
					self.ai_state = "switch_scatter"
				end
			else
				self.ai_state = "action"
			end

			return self.ai_state
		end,

		switch_chase = function( self )
			self.attack_mode = "chase"
			self.attack_rank = self.attack_rank + 1
			self.attack_next = self.attack_next + 2000 + (200 * self.attack_rank)

			self.ai_state = "action"
			return self.ai_state
		end,
		switch_scatter = function( self )
			self.attack_mode = "scatter"
			self.attack_next = self.attack_next + (1000 - math.max(math.min((self.attack_rank * 50), 250), 750))

			--Force a reversal
			local coord_diff = (self.last_square - self.position)
			self.last_square = self.position + coord_diff * -2

			self.ai_state = "action"
			return self.ai_state
		end,

		_calc_chase = function( self )
			--Clyde alternates between Pac-Man and his home coord depending on how close he is.
			if (self:distance_to( player ) < 5) then
				return self.home_square
			else
				return player.position
			end
		end,
		_calc_scatter = function( self )
			return self.home_square
		end,

		action = function( self )

			--Ghosts cannot move diagonally, nor can they go backwards (unless they are in a corner).
			--Calc all potential movement cells.
			local move_options = {}
			local move_norun_options = {}
			for c in self.position:cross_coords() do
				--if we can move there add to list
				--if ( and c ~= self.last_square)
				local cell = cells[ level.map[ c ] ]
				if not cell.flags[ CF_BLOCKMOVE ] and c ~= self.last_square then
					if not cell.flags[ CF_NORUN ] then
						table.insert(move_options, c:clone())
					else
						table.insert(move_norun_options, c:clone())
					end
				end
			end
			if (#move_options <=0 and #move_norun_options > 0) then move_options = move_norun_options end

			--If there is only one possible move that simplifies things.  Otherwise we must calc our target coord and determine the best path.
			local move
			if (#move_options <= 0) then
				--Should only happen on a dead end
				move = self.last_square
			elseif (#move_options == 1) then
				move = move_options[1]
			else
				local target
				if self.attack_mode == "chase" then
					target = ais[ self.ai_type ].states["_calc_chase"]( self )
				else
					target = ais[ self.ai_type ].states["_calc_scatter"]( self )
				end

				local closest = 999
				for _,cc in ipairs(move_options) do
					local distance = math.sqrt(math.abs(cc.x-target.x)^2 + math.abs(cc.y-target.y)^2)
					if distance  < closest then
						move = cc
						closest = distance
					end
				end
			end
 
			--Move or attack.
			if (move == player.position) then
				self:attack( player )
			else		self.last_square = self.position
				if (self:direct_seek( move ) ~= MOVEOK) then
					--Blocked, most likely by a being.  Just wait a half-tick and try again and just to be safe free up the previous cell.
					self.scount = self.scount - 500
				end
			end

			return "thinking"
		end
	}
}
