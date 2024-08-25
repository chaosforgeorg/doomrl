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

register_ai "cyberdemon_ai"
{

	OnCreate = function( self )
		self:add_property( "attacked", false )
		self:add_property( "ai_state", "thinking" )
		self:add_property( "assigned", false )
		self:add_property( "move_to", coord.new(0,0) )
		self:add_property( "ammo_regen", 0 )
		self:add_property( "attackchance", math.min( self.__proto.attackchance * diff[DIFFICULTY].speed, 90 ) )
	end,

	OnAttacked = function( self )
		self.attacked = true
	end,

	states = {
		thinking = function( self )
			local dist    = self:distance_to( player )
			local visible = self:in_sight( player )
			local no_ammo = self.eq.weapon.ammo < math.max( self.eq.weapon.shotcost, 1 ) and not self.inv[items[self.eq.weapon.ammoid].id]

			if dist <= self.vision then
				local shoot = math.random(100)
				if visible then
					shoot = shoot <= self.attackchance
				else
					shoot = shoot <= math.floor(self.attackchance / 2)
				end
				if dist == 1 then
					self.ai_state = "melee"
				elseif not no_ammo and ( self.attacked or shoot ) then
					self.ai_state = "attack"
				else
					self.assigned = false
					self.ai_state = "pursue"
				end
				self.attacked = false
			else
				self.ai_state = "pursue"
			end

			if no_ammo then
				self.ammo_regen = self.ammo_regen + 1
				if self.ammo_regen > 7 then
					self.ammo_regen = 0
					self.inv:add("rocket")
					self.inv:add("rocket")
				end
			end

			if self.hp < self.hpmax / 2 and ai_tools.use_item_check( self ) then
				self.ai_state = "use_item"
			end

			local walk
			if not self.assigned then
				if self.ai_state == "pursue" then
					local move_dist = self.vision+1
					if self:has_property( "has_item" ) and not visible then
						for item in level:items_in_range( self, self.vision ) do
							if ( item.flags[ IF_AIHEALPACK ] or ( item.itype == ITEMTYPE_ARMOR and not self.eq.armor ) ) and self:in_sight( item ) then
								local item_dist = self:distance_to( item )
								if item_dist < move_dist then
									move_dist = item_dist
									walk = item.position
								end
							end
						end
					end
					if move_dist > self.vision then
						walk = player.position
					end
				end
				if walk then
					self.move_to = walk
					self:path_find( self.move_to, 40, 200 )
					self.assigned = true
				end
			end
			return self.ai_state
		end,

		melee = function( self ) return ai_tools.melee_action( self )	end,

		attack = function( self ) return ai_tools.attack_action( self ) end,

		use_item = function( self ) return ai_tools.use_item_action( self ) end,

		pursue = function( self )
			if math.random(30) == 1 and self.__proto.sound_act then
				self:play_sound( self.__proto.sound_act )
			end

			if self:distance_to( self.move_to ) == 0 then
				local item = level:get_item( self.move_to )
				if item and ( item.flags[ IF_AIHEALPACK ] or ( item.itype == ITEMTYPE_ARMOR and not self.eq.armor ) ) then
					self:pickup( self.move_to )
					self:wear( item )
				end
				self.assigned = false
			else
				if self.eq.weapon.ammo < math.max( self.eq.weapon.shotcost ) then
					self:reload()
					return "thinking"
				end
				local move_check,move_coord = self:path_next()
				if move_check ~= MOVEOK then
					if move_check == MOVEDOOR then
		--					being:open( move_coord )
					else
						self.assigned = false
						self.scount = self.scount - 200
					end
				end
			end
			return "thinking"
		end,
	}
}

register_ai "jc_ai"
{

	OnCreate = function( self )
		self:add_property( "attacked", false )
		self:add_property( "ai_state", "wait" )
		self:add_property( "assigned", false )
		self:add_property( "move_to", coord.new(0,0) )
		self:add_property( "attackchance", math.min( self.__proto.attackchance * diff[DIFFICULTY].speed, 90 ) )
	end,

	OnAttacked = function( self )
		self.attacked = true
		if self.ai_state == "wait" then
			if not self:in_sight( player ) then
				local surround = area.around(player.position,7):clamped( area.FULL_SHRINKED )
				level:summon{ "baron", 6, area = surround }
				ui.msg("A voice bellows: \"Don't think you can surprise me!\"")
			end
			self.ai_state = "thinking"
		end
	end,

	states = {
		--pre-active state
		wait = function( self )
			self.scount = self.scount - 1000
			if self:in_sight( player ) then
				return "thinking"
			else
				return "wait"
			end
		end,

		thinking = function( self )
			local dist    = self:distance_to( player )
			local visible = self:in_sight( player )
			local no_ammo = self.eq.weapon.ammo < math.max( self.eq.weapon.shotcost, 1 ) and not self.inv[items[self.eq.weapon.ammoid].id]

			local shoot = math.random(100)
			if visible then
				shoot = shoot <= self.attackchance
			else
				shoot = shoot <= math.floor(self.attackchance / 2)
			end
			if self.attacked and math.random(3) == 1 then
				self.ai_state = "teleport"
				self.attacked = false
			elseif no_ammo or (visible and math.random(4) == 1) or (not visible and math.random(8) == 1)then
				self.ai_state = "summon"
			elseif not no_ammo and ( self.attacked or shoot ) then
				self.ai_state = "attack"
			else
				self.ai_state = "pursue"
			end

			local walk
			if not self.assigned then
				if self.ai_state == "teleport" then
					walk = area.around( self.position, 10 ):clamped( area.FULL_SHRINKED ):random_coord()
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

		attack = function( self ) return ai_tools.attack_action( self ) end,

		pursue = function( self ) return ai_tools.pursue_action( self, false, false ) end,

		teleport = function( self )
			self.assigned = false
			local mob = level:get_being( self.move_to )
			if mob then
				if mob:is_player() or mob == self then
					return "thinking"
				else
					mob:kill()
				end
			end
			self:play_sound("soldier.phase")
			level:explosion( self.position, 2, 50, 0, 0, LIGHTBLUE )
			self:relocate( self.move_to )
			level:explosion( self.position, 4, 50, 0, 0, LIGHTBLUE )
			self.scount = self.scount - 1000
			return "thinking"
		end,

		summon = function (self)
			local idx = math.max( math.min( 5 - math.floor((self.hp / self.hpmax) * 5), 5 ), 1 )
			if self.hp > self.hpmax then idx = 6 end
			-- White Rider requested this.  I had no part to play.
			local whom = { "lostsoul", "cacodemon", "knight", "baron", "revenant" , "mancubus" }
			for c=1,8 do self:spawn(whom[idx]) end
			if self:is_visible() then
				self:msg("","Carmack raises his hands and summons hellspawn!")
			end
			self.scount = self.scount - 2000
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

register_ai "archvile_ai"
{

	OnCreate = function( self )
		self:add_property( "boredom", 9 ) --idle triggers for boredom > 8
		self:add_property( "move_to", coord.new(0,0) )
		self:add_property( "attack_to", coord.new(0,0) )
		self:add_property( "assigned", false )
		self:add_property( "ai_state", "thinking" )
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
				elseif math.random(100) <= self.attackchance then
					self.assigned = false
					self.ai_state = "prepare"
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

			if math.random(4) == 1 then
				self.ai_state = "ressurect"
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
				elseif self.ai_state == "prepare" then
					self.attack_to = player.position
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

		melee = function( self ) return ai_tools.melee_action( self )	end,

		--prepare and fire are a chain of processes before thinking reoccurs
		prepare = function( self )
			self:msg("", "The " .. self.name .. " raises his arms!" )
			self.scount = self.scount - 2500
			return "fire"
		end,

		fire = function( self )
			self.assigned = false
			if self:in_sight( player ) then
				self:fire( player.position, self.eq.weapon )
			else
				self:fire( self.attack_to, self.eq.weapon )
			end
			return "thinking"
		end,

		ressurect = function( self )
			self:ressurect(6)
			self.scount = self.scount - 1000
			return "thinking"
		end,

		pursue = function( self ) return ai_tools.pursue_action( self, false, false ) end,

		flee = function( self )
			if self:distance_to( self.move_to ) == 0 then
				self.assigned = false
			elseif self:direct_seek( self.move_to ) ~= MOVEOK then
				self.scount = self.scount - 500
				self.assigned = false
			end
			return "thinking"
		end,
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

register_ai "spawnonly_ai"
{

	OnCreate = function( self )
		self:add_property( "ai_state", "thinking" )
		self:add_property( "assigned", false )
		self:add_property( "boredom", 5 )
		self:add_property( "move_to", coord.new(0,0) )
	end,

	OnAttacked = function( self )
		self.boredom = 0
		self.assigned = false
	end,

	states = {
		thinking = function( self )
			local dist    = self:distance_to( player )
			local visible = self:in_sight( player )

			if visible or self.boredom < 4 then
				if (self:has_property("spawnchance") and math.random(self.spawnchance) == 1) or (not self:has_property("spawnchance") and math.random(4) == 1) then
					self.ai_state = "spawn"
				else
					self.ai_state = "pursue"
				end
				if dist == 1 then
					self.ai_state = "melee"
				end
			else
				self.ai_state = "idle"
			end
			self.boredom = self.boredom + 1

			if not self.assigned then
				local p = player.position
				local s = self.position
				local walk
				if self.ai_state == "pursue" then
					if dist < 4 then
						walk = s + (p - s)
					else
						walk = p
					end
					self.move_to = walk
					self:path_find( self.move_to, 10, 40 )
					self.assigned = true
				elseif self.ai_state == "idle" then
					walk = area.around( s, 3 ):clamped( area.FULL ):random_coord()
					self.move_to = walk
					self:path_find( self.move_to, 10, 40 )
					self.assigned = true
				end
			end

			return self.ai_state
		end,

		idle = function( self )
			if math.random(30) == 1 then
				self:play_sound( self.__proto.sound_act )
			end

			if self:distance_to( self.move_to ) == 0 or self:in_sight(player) then
				self.assigned = false
			else
				local move_check = self:path_next()
				if move_check ~= MOVEOK then
					self.assigned = false
					self.scount = self.scount - 200
				end
			end
			return "thinking"
		end,

		pursue = function( self )
			if self:distance_to( self.move_to ) == 0 then
				self.assigned = false
				return "thinking"
			end
			local move_check = self:path_next()
			if move_check ~= MOVEOK then
				self.assigned = false
				self.scount = self.scount - 1000
			end
			return "thinking"
		end,

		spawn = function( self )
			local whom = "lostsoul"
			local num = 3
			if self:has_property("spawnlist") then
				local rand = math.random(#self.spawnlist)
				whom = self.spawnlist[rand].name
				num = self.spawnlist[rand].amt
			end
			for c=1,num do
				self:spawn(whom)
			end
			local spawnname = "a "..beings[whom].name
			if num > 1 then
				spawnname = beings[whom].name_plural
			end
			self:msg("", "The "..self.name.." spawns "..spawnname.."!")
			self.scount = self.scount - 1000
			return "thinking"
		end,

		melee = function( self ) return ai_tools.melee_action( self ) end,
	}
}

register_ai "mastermind_ai"
{

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

			if visible and self.stun_time == 0 then
				if dist == 1 then
					self.ai_state = "attack_melee"
				elseif dist < 4 then
					self.ai_state = "attack_line"
				else
					self.ai_state = "attack_spray"
				end
			else
				if self.stun_time > 0 then
					self.ai_state = "stagger"
				elseif self.attacked then
					if level:eye_contact(self.position, player.position) then
						self.ai_state = "attack_line"
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
				--ui.delay(missiles["mnat_mastermind"].delay * 2)
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
