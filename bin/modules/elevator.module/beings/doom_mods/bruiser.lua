--The bruiser baron comes straight out of KDIZD where it has enjoyed great popularity.  It is of course named after the bruiser brothers, of which DoomRL has its own unrelated variant.
register_item "nat_sk_bruiser1" {
	name       = "nat_sk_bruiser1",
	sprite     = 0,
	weight     = 0,

	type       = ITEMTYPE_NRANGED,
	damage     = "3d8",
	damagetype = DAMAGE_IGNOREARMOR,
	fire       = 16,
	radius     = 2,
	flags      = { IF_NODROP, IF_NOAMMO },
	missile    = {
		sound_id    = "baron",
		ascii       = '*',
		color       = LIGHTRED,
		sprite     = SPRITE_ACIDSHOT,
		coscolor   = { 1.0, 0.25, 0.0, 1.0 },
		delay       = 20,
		miss_base   = 25,
		miss_dist   = 8,
		expl_delay  = 40,
		expl_color  = COLOR_LAVA,
	},
}
register_item "nat_sk_bruiser2" { --Note: should adjust ai so that we can fake a five shot spread
	name       = "nat_sk_bruiser2",
	sprite     = 0,
	weight     = 0,

	type       = ITEMTYPE_NRANGED,
	damage     = "4d7",
	damagetype  = DAMAGE_FIRE,
	fire       = 11,
	radius     = 1,
	flags      = { IF_NODROP, IF_NOAMMO, IF_SPREAD },
	missile    = {
		sound_id    = "baron",
		ascii       = '*',
		color       = YELLOW,
		sprite     = SPRITE_ACIDSHOT,
		coscolor   = { 1.0, 1.0, 0.0, 1.0 },
		delay       = 20,
		miss_base   = 20,
		miss_dist   = 4,
		expl_delay  = 40,
		expl_color  = COLOR_LAVA,
	},
}
register_being "bruiserdemon" {
	name         = "bruiser demon",
	ascii        = "B",
	color        = YELLOW,
	sprite       = SPRITE_BARON,
	overlay      = { 0.7, 1.0, 0.4, 1.0 },
	glow         = { 1.0,0.75,0.0,1.0 },
	hp           = 200,
	armor        = 3,
	speed        = 100,
	todam        = 8,
	tohit        = 6,
	min_lev      = 20,
	corpse       = false,
	danger       = 18,
	weight       = 5,
	bulk         = 100,
	flags        = { BF_OPENDOORS, BF_HUNTING },
	ai_type      = "baron_ai",

	resist = { acid = 20 },

	desc            = "The bruiser demon is the highest form of demon nobility and should you hang around one you'll soon know why.",
	kill_desc       = "slaughtered by a bruiser demon",
	kill_desc_melee = "obliterated by a bruiser demon",

	--This pseudo-AI was written a long time ago and ported over many successive versions.
	--Now that we have proper AI tools I should go in and port this into a custom baron AI.
	--But I won't because this works and I won't have to merge new baron AI changes.
	OnCreate = function(self)
		self:add_property("bruiser_ai", {})
		self.bruiser_ai.current_weapon = 0
		self.bruiser_ai.current_timeout = 0
		self.bruiser_ai.bigblast_twomax = 0
		self.eq.weapon = item.new("nat_sk_bruiser1")
	end,

	OnAction = function(self)

		--handle weapon switching.
		--Rules: minimum of 3-6 actions before switching weapons.
		--Weapon preferences exist depending on range, whether player visible, and HP.
		--If the same weapon is selected don't reset timeout.
		--Bruisers cannot launch a big blast more than twice before swapping.
		if(self.bruiser_ai.current_timeout <= 0 or self.bruiser_ai.bigblast_twomax >= 2) then
			--switch
			local nextWeapon

			--Since the big blast has extra restrictions work it out first.
			--At the unattainable 0 HP there is a 25% chance of choosing this attack.
			--If the player is not visible that goes up 10%, or 5% if the player is visible but distant.
			local chance = ((self.hpmax - self.hp) * 50) / self.hpmax
			if(self:in_sight(player) == false) then chance = chance + 10
			elseif(self:distance_to(player) >= self.vision - 2) then chance = chance + 5
			end

			if(self.bruiser_ai.bigblast_twomax < 2 and math.random(100) < chance) then
				nextWeapon = 2
			else
				--For the other two weapons the bias is weighted towards distance.
				--If the player is not visible or is far away the 10% bias swaps.
				local chance2 = 40
				if(self:in_sight(player) == false or self:distance_to(player) >= self.vision - 2) then chance2 = chance2 + 20 end
				if(math.random(100) < chance2) then
					nextWeapon = 1
				else
					nextWeapon = 0
				end
			end

			if(nextWeapon ~= self.bruiser_ai.current_weapon) then
				self.bruiser_ai.current_timeout = 3 + math.random(3)
				self.bruiser_ai.current_weapon = nextWeapon
				self.bruiser_ai.bigblast_twomax = 0
				if(nextWeapon == 0) then
					self.eq.weapon = item.new("nat_sk_bruiser1")
				elseif(nextWeapon == 1) then
					self.eq.weapon = item.new("nat_sk_bruiser2")
				else
					--self.eq.weapon = nil --Newer AI is doesn't like no weapons
				end
			end
		else
			self.bruiser_ai.current_timeout = self.bruiser_ai.current_timeout - 1
		end

		--handle big blast 'weapon'
		if( self.bruiser_ai.current_weapon == 2 and self.bruiser_ai.bigblast_twomax < 2
		and self:in_sight(player) and self:distance_to( player ) >= 3) then

			self.scount = self.scount - 2000
			self.bruiser_ai.bigblast_twomax = self.bruiser_ai.bigblast_twomax + 1

			--Grab our coords and distance
			local beingCoord  = self.position
			local playerCoord = player.position
			local distance    = self:distance_to( player )

			--Begin number crunching
			self:msg("The floor around you erupts!", "The floor around the " .. self:get_name(true,false) .. " erupts!")

			--Constants that you can change to tweak the pattern
			local trace_length = 15
			local trace_angle  = 20
			local trace_skipexplosions = 1
			local trace_explosions     = 5

			--compute steps
			local adjusts = { }
			local tmp_vector = (playerCoord - beingCoord)
			local tmp_scalar = (trace_length / (distance * trace_explosions))
			adjusts[1] = coord.new(tmp_vector.x * tmp_scalar, tmp_vector.y * tmp_scalar)
			adjusts[2] = coord.new( adjusts[1].x * math.cos(math.rad(trace_angle))  - adjusts[1].y * math.sin(math.rad(trace_angle))
			                      , adjusts[1].x * math.sin(math.rad(trace_angle))  + adjusts[1].y * math.cos(math.rad(trace_angle)) )

			adjusts[3] = coord.new( adjusts[1].x * math.cos(math.rad(-trace_angle)) - adjusts[1].y * math.sin(math.rad(-trace_angle))
			                      , adjusts[1].x * math.sin(math.rad(-trace_angle)) + adjusts[1].y * math.cos(math.rad(-trace_angle)) )

			--Make the explosions!
			for i = 1, trace_skipexplosions + trace_explosions - 1 do

				if (i > trace_skipexplosions) then
					for j = 1, 3 do
						local explo_coord = beingCoord + coord.new(adjusts[j].x * (i-1), adjusts[j].y * (i-1))
						if(area.FULL_SHRINKED:contains(explo_coord)) then
							local sound = nil
							if(j == 1) then sound = "barrel.explode" end
							EventQueue.AddEvent(level.explosion, (i-1), { level, explo_coord, 1, 50, 6, 3, YELLOW, sound, DAMAGE_PLASMA } )
						end
					end
				end
			end
		end
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["bruiserdemon"].sound_die   = core.resolve_sound_id("bruiserdemon.die")
	beings["bruiserdemon"].sound_act   = core.resolve_sound_id("bruiserdemon.act")
	beings["bruiserdemon"].sound_hit   = core.resolve_sound_id("bruiserdemon.hit")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
