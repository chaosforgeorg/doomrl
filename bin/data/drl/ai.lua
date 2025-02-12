register_ai "smart_evasive_ai"
{

	OnCreate = function( self )
		aitk.basic_init( self, true, true )
	end,

	OnAttacked = aitk.basic_on_attacked, 
	states = {
		idle   = aitk.basic_smart_idle,
		pursue = aitk.basic_pursue,
		hunt   = aitk.evade_hunt,
	}
}

register_ai "smart_hybrid_ai"
{
	OnCreate = function( self )
		aitk.basic_init( self, true, true )
	end,

	OnAttacked = aitk.basic_on_attacked, 
	states = {
		idle   = aitk.basic_smart_idle,
		pursue = aitk.basic_pursue,
		hunt   = aitk.pursue_hunt,
	}
}
register_ai "charger_ai"
{
	OnCreate = function( self )
		aitk.charge_init( self, 30 )
	end,
	OnAttacked = aitk.charge_on_attacked,
	states = {
		idle        = aitk.charge_idle,
		hunt        = aitk.charge_idle,
		pursue      = aitk.basic_pursue,
		charge      = aitk.charge_charge,
		post_charge = aitk.charge_post_charge,
	}
}

register_ai "flock_ai"
{

	OnCreate = function( self )
		aitk.flock_init( self, 1, 4 )
	end,

	OnAttacked = aitk.flock_on_attacked,
	states = {
		idle = aitk.flock_idle,
		hunt = aitk.flock_hunt,
	}
}

register_ai "melee_ranged_ai"
{
	OnCreate = function( self )
		aitk.basic_init( self, false, false )
	end,

	OnAttacked = aitk.basic_on_attacked,
	states = {
		idle   = aitk.basic_smart_idle,
		pursue = aitk.basic_pursue,
		hunt   = aitk.pursue_hunt,
	}
}

register_ai "ranged_ai"
{
	OnCreate = function( self )
		aitk.basic_init( self, false, false )
	end,

	OnAttacked = aitk.basic_on_attacked,
	states = {
		idle   = aitk.basic_smart_idle,
		pursue = aitk.basic_pursue,
		hunt   = aitk.ranged_hunt,
	}
}

register_ai "sequential_ai"
{
	OnCreate = function( self )
		aitk.basic_init( self, false, false )
		self:add_property( "sequential", {3,5,3} )
		self:add_property( "sequence", 0 )
	end,

	OnAttacked = aitk.basic_on_attacked,
	states = {
		idle   = aitk.basic_smart_idle,
		pursue = aitk.basic_pursue,
		hunt   = aitk.ranged_hunt,
	}
}

register_ai "archvile_ai"
{
	OnCreate = function( self )
		aitk.basic_init( self, false, false )
		self:add_property( "attack_to", false )
		self:add_property( "on_fire", "on_fire" )
	end,

	OnAttacked = aitk.basic_on_attacked,
	states = {
		idle   = function ( self )
			if math.random(4) == 1 then
				self:ressurect(6)
				self.scount = self.scount - 1000
				return "idle"
			end
			return aitk.basic_smart_idle( self )
		end,
		pursue = function ( self )
			if math.random(4) == 1 then
				self:ressurect(6)
				self.scount = self.scount - 1000
				return "pursue"
			end
			return aitk.basic_pursue( self )
		end,
		hunt   = function( self )
			if math.random(4) == 1 then
				self:ressurect(6)
				self.scount = self.scount - 1000
				return "hunt"
			end
			local action, dist, target = aitk.try_hunt( self )
			if action then return action end
		
			local target = target.position
			if dist < 4  then
				local pos = self.position
				target = pos + (pos - target)
				area.FULL:clamp_coord( target )
			end
			if self.move_to == target then
				if aitk.move_path( self ) then
					return "hunt"
				end
			end
			self.move_to = target
			if not self:path_find( self.move_to, 10, 40 ) or ( not aitk.move_path( self ) ) then
				self.move_to = false
				self.scount  = self.scount - 1000
			end
			return "hunt"
		end,
		on_fire = function( self )
			local target = uids.get( self.target )
			if not target then return "idle" end
			self.attack_to = target.position
			self:msg("", "The " .. self.name .. " raises his arms!" )
			self.scount = self.scount - 2500
			return "fire"
		end,
		fire = function( self )
			local target = uids.get( self.target )
			if target and self:in_sight( target ) then
				self:fire( target.position, self.eq.weapon )
			else
				self:fire( self.attack_to, self.eq.weapon )
			end
			return "hunt"
		end,
	}
}

register_ai "spawner_ai"
{
	OnCreate = function( self )
		aitk.basic_init( self, false, false )
		self:add_property( "sequential", {3,5,3} )
		self:add_property( "sequence", 0 )
		self:add_property( "spawnchance", 25 )
		self:add_property( "spawnlist", false )
	end,

	OnAttacked = function( self, target )
		self.boredom = 0
	end,

	states = {
		idle   = aitk.basic_idle,
		pursue = function( self )
			if ais[ self.ai_type ].states.try_spawn( self ) then 
				return "pursue"
			end
			return aitk.basic_pursue( self )
		end,
		hunt   = function( self )
			if ais[ self.ai_type ].states.try_spawn( self ) then 
				return "hunt"
			end
			local target = player.position
			local dist   = self:distance_to( player )
			if dist < 4  then
				local pos = self.position
				target = pos + (pos - target)
				area.FULL:clamp_coord( target )
			end
			if self:direct_seek( target ) ~= MOVEOK then
				self.scount  = self.scount - 1000
			end
			return "hunt"
		end,
		try_spawn = function( self )
			if self.spawnlist and self.boredom < 4 and math.random(100) <= self.spawnchance then
				local list = self.spawnlist
				if not list.name then
					list = list[ math.random(#list) ]
				end
				local whom = list.name
				local num  = list.count
				for c=1,num do
					self:spawn(whom)
				end
				local spawnname = "a "..beings[whom].name
				if num > 1 then
					spawnname = beings[whom].name_plural
				end
				self:msg("", "The "..self.name.." spawns "..spawnname.."!")
				self.scount  = self.scount - 1000
				self.boredom = self.boredom + 1
				return true
			end
			return false
		end,
	}
}

-- BOSS AIs -------------------------------------------------------------

register_ai "angel_ai"
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
				self:attack( player )
				return "thinking"
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

		pursue = function( self )
			if math.random(30) == 1 then
				self:play_sound( "act" )
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
			local action, has_ammo = aitk.inventory_check( self, dist > 1 )
			if action then
				return "thinking"
			end

			if not has_ammo then
				self.ammo_regen = self.ammo_regen + 1
				if self.ammo_regen > 7 then
					self.ammo_regen = 0
					self.inv:add("rocket")
					self.inv:add("rocket")
				end
			end

			if dist <= self.vision then
				local shoot = math.random(100)
				if visible then
					shoot = shoot <= self.attackchance
				else
					shoot = shoot <= math.floor(self.attackchance / 2)
				end
				if dist == 1 then
					self:attack( player )
					return "thinking"
				elseif has_ammo and ( self.attacked or shoot ) then
					self:fire( player, self.eq.weapon )
					return "thinking"
				else
					self.assigned = false
					self.ai_state = "pursue"
				end
				self.attacked = false
			else
				self.ai_state = "pursue"
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

		pursue = function( self )
			if math.random(30) == 1 then
				self:play_sound( "act" )
			end

			if self:distance_to( self.move_to ) == 0 then
				local item = level:get_item( self.move_to )
				if item and ( item.flags[ IF_AIHEALPACK ] or ( item.itype == ITEMTYPE_ARMOR and not self.eq.armor ) ) then
					self:pickup( self.move_to )
					self:wear( item )
				end
				self.assigned = false
			else
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
			local action, has_ammo = aitk.inventory_check( self, dist > 1 )
			if action then
				return "thinking"
			end

			local shoot = math.random(100)
			if visible then
				shoot = shoot <= self.attackchance
			else
				shoot = shoot <= math.floor(self.attackchance / 2)
			end
			if self.attacked and math.random(3) == 1 then
				self.ai_state = "teleport"
				self.attacked = false
			elseif not has_ammo or (visible and math.random(4) == 1) or (not visible and math.random(8) == 1)then
				self.ai_state = "summon"
			elseif has_ammo and ( self.attacked or shoot ) then
				self:fire( player, self.eq.weapon )
				return "thinking"
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
			self:play_sound("phasing")
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
					self:attack( player )
					return "thinking"
				elseif math.random(100) <= self.attackchance then
					self:fire( player, self.eq.weapon )
					return "thinking"
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

		hunt = function( self )
			if math.random(30) == 1 then
				self:play_sound( "act" )
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
			self:play_sound("phasing")
			level:explosion( self, 2, 50, 0, 0, YELLOW )
			local target = generator.drop_coord( self.move_to, {EF_NOBEINGS,EF_NOBLOCK} )
			self:relocate( target )
			level:explosion( self, 1, 50, 0, 0, YELLOW )
			self.scount = self.scount - 1000
			return "thinking"
		end,
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

			self.attacked = false

			if visible and self.stun_time == 0 then
				if dist == 1 then
					if math.random(100) <= self.attackchance then
						self:fire( player, self.eq.weapon )
					else
						self:attack( player )
					end
					return "thinking"
				elseif dist < 4 then
					self:fire( player, self.eq.weapon )
					return "thinking"
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
			if math.random(30) == 1 then
				self:play_sound( "act" )
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
			if math.random(30) == 1 then
				self:play_sound( "act" )
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
