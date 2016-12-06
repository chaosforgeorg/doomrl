--The arch-lich is the final boss in the EoD and it is everything a final boss should be--script and event heavy.
--Actions:
-- The arch-lich is a mook maker and will summon skeleton dragons.
-- The arch-lich will at predictable health breaks teleport to the very center of the room, become invincible, and rain fire down upon doomguy in a dodge-the-fireball like pattern.  The first four patterns are predictable: top->bottom, left->right, diagonal->diagonal, and center spiral.  The direction can chance if doomguy is on the side of tghe screen that would give him no reaction time.  Once the fourth round has transpired successive rounds will be random both in timing and in direction.
-- The arch-lich will res doomguy corpses.  They'll have the same traits you do and will be able to pick up items.  On the plus side they're a one-time only res.
-- The arch-lich will summon illusions of itself that appear to attack normally but cause no damage.  They cannot be killed; they just expire after a while.
-- boss must teleport but not as much as shambler, hallu must have a fake melee attack that displays the usual messages but doesn't actually attack the player
local archlich_ai_findbody = function( self )
	for c in area.around( self.position, self.vision ):clamped( area.FULL ):coords() do
		local id = generator.get_cell( c )
		if level.map[ c ] == "corpse" and level:eye_contact(c, self.position) then
			return c
		end
	end

	return nil
end
local archlich_ai_generatelineexplosions = function( center, trace_angle, rows_x, rows_y )
	local coords = {}

	--What we do is simple: we have an 82x82 grid that we rotate around and lay on top of the game world.
	--We then start at one side and start spamming explosions until we finish.
	local trace_rect = { coord.new(-41,-41), coord.new(-41,41), coord.new(41,-41), coord.new(41,41)}
	for i = 1, 4 do
		trace_rect[i] = center +
		                coord.new( trace_rect[i].x * math.cos(math.rad(trace_angle))  - trace_rect[i].y * math.sin(math.rad(trace_angle))
		                         , trace_rect[i].x * math.sin(math.rad(trace_angle))  + trace_rect[i].y * math.cos(math.rad(trace_angle)) )
	end

	local start_vector = coord.new( (trace_rect[2].x - trace_rect[1].x) / rows_x, (trace_rect[2].y - trace_rect[1].y) / rows_x)
	local trace_vector = coord.new( (trace_rect[3].x - trace_rect[1].x) / rows_y, (trace_rect[3].y - trace_rect[1].y) / rows_y)

	local trace_starts = {}
	for i = 1, rows_x do
		trace_starts[i] = trace_rect[1] + coord.new(start_vector.x * (i-1), start_vector.y * (i-1))
	end
	for j = 1, rows_y do
		local adjust = coord.new(trace_vector.x * (j-1), trace_vector.y * (j-1))
		local coord_batch = {}
		for i = 1, rows_x do
			--To get the zigzag effect we want that lets you dodge explosions we only plot every OTHER explosion.
			if ((i + j) % 2 == 0) then
				local explo_coord = trace_starts[i] + adjust
				if (area.FULL_SHRINKED:contains(explo_coord) and level.map[explo_coord] ~= "void") then
					table.insert(coord_batch,explo_coord)
				end
			end
		end

		if (#coord_batch > 0) then
			table.insert(coords,coord_batch)
		end
	end

	return coords
end
local archlich_ai_generatespiralexplosions = function( center, tines, speed, distance )
	local pos = 1
	local coords = {}

	--Rotate around the zero coord.  The first rotation is a half rotation.
	local continue
	local trace_angle = 360 / tines
	repeat
		local adjust = pos - 1
		local coord_batch = {}

		continue = false
		for i = 1, tines do
			local new_angle = (trace_angle * i) + (speed * adjust)
			local new_dist = (distance * adjust)
			local coord_rotatedvector = coord.new(new_dist * math.cos(math.rad(new_angle)), new_dist * math.sin(math.rad(new_angle)))

			local explo_coord = center + coord_rotatedvector
			if (area.FULL_SHRINKED:contains(explo_coord) and level.map[explo_coord] ~= "void" and coord_batch[#coord_batch] ~= explo_coord) then
				table.insert(coord_batch,explo_coord)
			end
			if (area.FULL_SHRINKED:contains(explo_coord)) then continue = true end
		end

		if (#coord_batch > 0) then table.insert(coords,coord_batch) end
		pos = pos + 1
	until not continue

	return coords
end

register_ai "archlich_ai" {
	OnCreate = function( self )
		self:add_property( "ai_state", "wait" )
		self:add_property( "assigned", false )
		self:add_property( "move_to", coord.new(0,0) )
		self:add_property( "attacked", false )
		self:add_property( "attackchance", math.min( self.__proto.attackchance * diff[DIFFICULTY].speed, 90 ) )
		self:add_property( "previous_hp", self.hpmax )
		self:add_property( "previous_time", 0 )
		self:add_property( "teleport_delay", 20 )
		self:add_property( "teleport_basedelay", 10 )
		self:add_property( "teleport_chance", 10 )
		self:add_property( "firebomb_active", false )
		self:add_property( "firebomb_state", 0 )
		self:add_property( "firebomb_delay", 180 )
		self:add_property( "firebomb_basedelay", 250 )
		self:add_property( "firebomb_chance", 10 )
		self:add_property( "firebomb_precompute", {} )
		self:add_property( "firebomb_index", 0 )
		self:add_property( "firebomb_damage", { 8, 8 } )
		self:add_property( "firebomb_explrate", 900 )
		self:add_property( "firebomb_explvariance", .1 )
		self:add_property( "firebomb_location", coord.new(40,11) )
		self:add_property( "summon_delay", 40 )
		self:add_property( "summon_basedelay", 90 )
		self:add_property( "summon_chance", 40 )
		self:add_property( "res_delay", 50 )
		self:add_property( "res_basedelay", 20 )
		self:add_property( "res_chance", 60 )
		self:add_property( "illusion_delay", 100 )
		self:add_property( "illusion_basedelay", 150 )
		self:add_property( "illusion_chance", 100 )
		self:add_property( "illusion_lifespan", 50 )
	end,

	OnAttacked = function( self )
		self.attacked = true
		if self.ai_state == "wait" then
			self:play_sound( self.id .. ".speak" )
			self.ai_state = "thinking"
		end
	end,

	states = {

		wait = function( self )
			self.scount = self.scount - 1000
			if self:in_sight( player ) then
				self:play_sound( self.id .. ".speak" )
				return "thinking"
			else
				return "wait"
			end
		end,

		thinking = function( self )
			local dist       = self:distance_to( player )
			local visible    = self:in_sight( player )
			self.previous_hp = self.hp

			--Evaluate timers.  Being in firebomb mode overrides other timers so work that out first.
			if self.firebomb_active then
				self.ai_state = "firewait"
			elseif self.hp < ((4 - self.firebomb_state) / 5 * self.hpmax) then
				--Breakpoints at 80,60,40,20% health
				self.firebomb_active = true
				self.firebomb_state = self.firebomb_state + 1
				self.ai_state = "firestart"
			elseif self.previous_time ~= statistics.game_time then
				if self.firebomb_state >= 5 then
					self.firebomb_delay = self.firebomb_delay - 1
				end
				self.summon_delay = self.summon_delay - 1
				self.res_delay = self.res_delay - 1
				self.illusion_delay = self.illusion_delay - 1
				self.teleport_delay = self.teleport_delay - 1

				self.previous_time = statistics.game_time
			end

			--Decide on actions.
			if not self.firebomb_active then
				if self.firebomb_delay <= 0 and visible and math.random(100) < self.firebomb_chance then
					self.firebomb_active = true
					self.firebomb_delay = self.firebomb_delay + self.firebomb_basedelay
					self.ai_state = "firestart"
				elseif self.summon_delay <= 0 and visible and math.random(100) < self.summon_chance then
					self.summon_delay = self.summon_delay + self.summon_basedelay
					self.ai_state = "summon"
				elseif self.res_delay <= 0 and math.random(100) < self.res_chance and archlich_ai_findbody( self ) ~= nil then
					self.res_delay = self.res_delay + self.res_basedelay
					self.ai_state = "res"
				elseif self.illusion_delay <= 0 and visible and math.random(100) < self.illusion_chance then
					self.illusion_delay = self.illusion_delay + self.illusion_basedelay
					self.ai_state = "illusion"
				elseif self.teleport_delay <= 0 and visible and math.random(100) < self.teleport_chance then
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

		attack_melee = function( self ) return ai_tools.melee_action( self ) end,

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

		summon = function( self )
			--Summoning is straightforward.
			for c=1,2 do self:spawn("skeletondragon") end

			if self:is_visible() then
				self:msg("","Bones coalesce near the " .. self.name .. "!")
			end

			self.summon_delay = math.min(self.summon_delay, 0) + self.summon_basedelay --Summing this way allows me to force a summon with penalty, which I don't currently do but you never know
			self.scount = self.scount - 2000
			return "thinking"
		end,

		res = function( self )
			--Find a soldier corpse and resurrect it.  Corpses that are in the river do not count.
			local c = archlich_ai_findbody( self )
			if c then
				level.map[c] = "bloodpool"
				local b = level:drop_being( "clone", c)
				if (b) then
					--Bestow all the bonuses the player has, heh heh heh
					b.armor = player.armor
					b.bodybonus  = player.bodybonus
					b.dodgebonus = player.dodgebonus
					b.firetime = player.firetime
					b.hpdecaymax = player.hpdecaymax
					b.hpmax = player.hpmax * 2
					b.hp = b.hpmax
					b.movetime = player.movetime
					b.pistolbonus = player.pistolbonus
					b.rapidbonus = player.rapidbonus
					b.reloadtime = player.reloadtime
					--b.runningtime = player.runningtime
					b.techbonus = player.techbonus
					b.todam = player.todam
					b.todamall = player.todamall
					b.tohit = player.tohit
					b.tohitmelee = player.tohitmelee
					b.vision = player.vision

					--Most of these probably don't work on non-players but what the hell
					b.flags[ BF_AMMOCHAIN ]    = player.flags[ BF_AMMOCHAIN ]
					b.flags[ BF_ARMYDEAD ]     = player.flags[ BF_ARMYDEAD ]
					b.flags[ BF_BEINGSENSE  ]  = player.flags[ BF_BEINGSENSE  ]
					b.flags[ BF_BERSERKER ]    = player.flags[ BF_BERSERKER ]
					b.flags[ BF_BLADEDEFEND ]  = player.flags[ BF_BLADEDEFEND ]
					b.flags[ BF_BULLETDANCE ]  = player.flags[ BF_BULLETDANCE ]
					b.flags[ BF_CLEAVE ]       = player.flags[ BF_CLEAVE ]
					b.flags[ BF_DUALBLADE ]    = player.flags[ BF_DUALBLADE ]
					b.flags[ BF_DUALGUN ]      = player.flags[ BF_DUALGUN ]
					b.flags[ BF_ENTRENCHMENT ] = player.flags[ BF_ENTRENCHMENT ]
					b.flags[ BF_FIREANGEL ]    = player.flags[ BF_FIREANGEL ]
					b.flags[ BF_GUNKATA ]      = player.flags[ BF_GUNKATA ]
					b.flags[ BF_GUNRUNNER ]    = player.flags[ BF_GUNRUNNER ]
					b.flags[ BF_HARDY ]        = player.flags[ BF_HARDY ]
					b.flags[ BF_LEVERSENSE1 ]  = player.flags[ BF_LEVERSENSE1 ]
					b.flags[ BF_LEVERSENSE2 ]  = player.flags[ BF_LEVERSENSE2 ]
					b.flags[ BF_MASTERDODGE ]  = player.flags[ BF_MASTERDODGE ]
					b.flags[ BF_MEDPLUS ]      = player.flags[ BF_MEDPLUS ]
					b.flags[ BF_NORUNPENALTY ] = player.flags[ BF_NORUNPENALTY ]
					b.flags[ BF_PISTOLMAX ]    = player.flags[ BF_PISTOLMAX ]
					b.flags[ BF_POWERSENSE  ]  = player.flags[ BF_POWERSENSE  ]
					b.flags[ BF_QUICKSWAP ]    = player.flags[ BF_QUICKSWAP ]
					b.flags[ BF_ROCKETMAN ]    = player.flags[ BF_ROCKETMAN ]
					b.flags[ BF_SCAVENGER ]    = player.flags[ BF_SCAVENGER ]
					b.flags[ BF_SHOTTYHEAD ]   = player.flags[ BF_SHOTTYHEAD ]
					b.flags[ BF_SHOTTYMAN ]    = player.flags[ BF_SHOTTYMAN ]
					b.flags[ BF_VAMPYRE ]      = player.flags[ BF_VAMPYRE ]

					if b:is_visible() then
						self:msg("","The Lich resurrects a former Marine!")
					end
				end
			end

			return "thinking"
		end,

		illusion = function( self )
			--Get three coords (one being self.position), get three beings (one being self) and shuffle them.
			--Our hallucinations are invincible, start with the same HP, and do no damage.  They expire on
			--their own in time.  Telling them apart requires tracking them through teleportations and
			--seeing who gets damaged when attacked.
			local coords = { }
			local near_area = area.around( self.position, 6 ):clamped( area.FULL )
			local count = 0
			repeat
				if count > 50 then return end
				count = count + 1
				local c = generator.random_empty_coord( { EF_NOBEINGS, EF_NOITEMS, EF_NOSTAIRS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }, near_area )
				if (c and c:distance( self.position) > 3 and level:eye_contact( c, self)) then
					coords[#coords+1] = c
				end
			until #coords >= 3

			local b = nil
			coords = table.shuffle(coords)
			self:relocate( coords[1] )
			b = level:drop_being( "archlich_hallu", coords[2])
			if (b) then
				b.hpmax = self.hpmax
				b.hp = self.hp
				b.illusion_lifespan = self.illusion_lifespan
			end
			b = level:drop_being( "archlich_hallu", coords[3])
			if (b) then
				b.hpmax = self.hpmax
				b.hp = self.hp
				b.illusion_lifespan = self.illusion_lifespan
			end
			level:play_sound("soldier.phase", coords[1])
			level:play_sound("soldier.phase", coords[2])
			level:play_sound("soldier.phase", coords[3])
			level:explosion( coords[1], 2, 50, 0, 0, MAGENTA )
			level:explosion( coords[2], 2, 50, 0, 0, MAGENTA )
			level:explosion( coords[3], 2, 50, 0, 0, MAGENTA )

			return "thinking"
		end,

		firewait = function( self )
			--All of the firebomb logic was computed and added to our being who will now go through
			--and create the explosions based on that logic.  This means that the timing and any variance
			--is dependant on the being's speed and must be managed accordingly.  Yes this is complicated,
			--perhaps needlessly so, but it is also very proper and easier to adapt to other beings.
			--The cheater hacky way out is to just abuse the event queue.
			local targets = self.firebomb_precompute[ self.firebomb_index ]
			if not targets then return "fireend" end
			self.firebomb_index = self.firebomb_index + 1

			--Spawn asplosions
			for i=1,#targets do
				level:explosion( targets[i], 1, 30, self.firebomb_damage[1], self.firebomb_damage[2], YELLOW, "barrel.explode", DAMAGE_FIRE )
			end

			--Rest til next action (there is some variance possible)
			self.scount = self.scount - (self.firebomb_explrate * (1 + ((math.random() - 0.5) * (self.firebomb_explvariance * 2))))
			return "thinking"
		end,

		firestart = function( self )
			--Teleport to center stage and set self as invincible
			self:play_sound("soldier.phase")
			if (self.position ~= self.firebomb_location) then
				level:explosion( self.position, 1, 50, 0, 0, LIGHTBLUE )
				local target = generator.drop_coord( self.firebomb_location, {EF_NOBEINGS,EF_NOBLOCK} )
				self:relocate( target )
			end
			level:explosion( self.position, 3, 50, 0, 0, LIGHTBLUE )

			self.flags[ BF_INV ] = true
			self.color = RED + (WHITE * 16)

			--Calculate the explosions
			if (self.firebomb_state == 1) then
				if (player.x < 40) then self.firebomb_precompute = archlich_ai_generatelineexplosions(self.position, 180, 39, 78)
				else                    self.firebomb_precompute = archlich_ai_generatelineexplosions(self.position, 0,   39, 78)
				end
			elseif (self.firebomb_state == 2) then
				if (player.y < 12) then self.firebomb_precompute = archlich_ai_generatelineexplosions(self.position, 270, 39, 78)
				else                    self.firebomb_precompute = archlich_ai_generatelineexplosions(self.position, 90,  39, 78)
				end
			elseif (self.firebomb_state == 3) then
				if    (player.y < 12 and player.x < 40) then self.firebomb_precompute = archlich_ai_generatelineexplosions(self.position, 315, 29, 69)
				elseif(player.y > 12 and player.x < 40) then self.firebomb_precompute = archlich_ai_generatelineexplosions(self.position, 45,  29, 69)
				elseif(player.y < 12 and player.x > 40) then self.firebomb_precompute = archlich_ai_generatelineexplosions(self.position, 225, 29, 69)
				else                                         self.firebomb_precompute = archlich_ai_generatelineexplosions(self.position, 135, 29, 69)
				end               
			elseif (self.firebomb_state == 4) then
				self.firebomb_precompute = archlich_ai_generatespiralexplosions(self.position, 6, 35, 1)
			else
				if (math.random(3) ~= 1) then self.firebomb_precompute = archlich_ai_generatelineexplosions(self.position, math.random(360), 29, 69)
				else                          self.firebomb_precompute = archlich_ai_generatespiralexplosions(self.position, 2 + math.random(7), 24 + math.random(20), 1)
				end
			end

			self.firebomb_index = 1

			--Sleep for a bit to give the player a chance to move their ass out of the way
			self.scount = 0

			return "thinking"
		end,

		fireend = function( self )
			self.firebomb_active = false
			self.firebomb_precompute = {}

			--End the invincibility and reset the color.  No teleport though.
			self.flags[ BF_INV ] = false
			self.color = LIGHTRED

			--Whew.  Bet the big meanie is exhausted.
			--Better clean out the scount to let the player take some cheap shots.
			self.scount = 0

			return "thinking"
		end,

	}
}
