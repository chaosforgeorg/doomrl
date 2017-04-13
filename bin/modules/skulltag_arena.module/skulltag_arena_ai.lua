--No changes except for what he spawns.
register_ai "uberjc_ai"
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
				level:summon{ "cyberdemon", math.random(2), area = surround }
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
					walk = generator.random_empty_coord({EF_NOBEINGS,EF_NOBLOCK}, area.around( self.position, 10 ):clamped( area.FULL_SHRINKED ))
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
			for c=math.random(2), 2 do self:spawn("cyberdemon") end
			if self:is_visible() then
				ui.msg("Oh no! Cyberdemons!")
			end
			self.scount = self.scount - 2000
			return "thinking"
		end,
	}
}