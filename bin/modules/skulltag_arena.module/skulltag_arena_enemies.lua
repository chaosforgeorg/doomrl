--[[ New enemies:
     Abaddon --skulltag, black, hardest caco
     Belphegor --skulltag & kdizd, blood red, harder knight
     BFG Guy --natural progression but not spawned since there's no way to make the BFG not harm allies at this time
     Blood Demon --skulltag & kdizd, blood red, harder demon
     Bruiser Demon --KDIZD, orange, fires explosions in the ground, hardest demon.  Three attacks--big fireball, small spread fireball, ground explosions.
     Cacolantern --skulltag, orange, harder caco (possibly ignore, fires blue)
     Dark Imp --skulltag & kdizm, black,
     Diabloist --Skulltag mods, red, burns mucho but doesn't revive enemies
     Hectebus --skulltag, black, harder mancubus (fires green)
     Railgun Guy --natural progression (adding these guys in is DANGEROUS)
     Rocket Guy --natural progression
     Super Shotgun Guy --skulltag
     Spectre --doom, invisible (possibly adjust), no tougher than demon
     Suicide Soul --Skultag mods, black and red, suicides
--]]

Skulltag.Beings = {}
Skulltag.Beings.Init = nil


--Beings
register_being "abaddon" {
	name         = "abaddon",
	id           = "abaddon",
	ascii        = "O",
	color        = LIGHTBLUE, --A good 'black'
	sprite       = SPRITE_PAIN,
	overlay      = { 0.5,0.7,1.0,1.0 },
	glow         = { 0.0,0.0,0.0,1.0 },
	hp           = 80,
	armor        = 2,
	speed        = 110,
	attackchance = 60,
	todam        = 8,
	tohit        = 6,
	min_lev      = 16,
	corpse       = "corpse",
	--corpse       = "abaddoncorpse",
	--corpse       = true,
	danger       = 14,
	weight       = 5,
	bulk         = 100,
	flags        = { BF_ENVIROSAFE },
	ai_type      = "melee_ranged_ai",

	desc            = "Abaddons are the toughest cacodemons around.  Lurking in the deepest corners of Hell abaddon's are rarely seen by anyone who lives to tell the tale.",
	kill_desc       = "smitten by an abaddon",
	kill_desc_melee = "became food for an abaddon",

	weapon = {
		damage     = "3d8",
		damagetype = DAMAGE_PLASMA,
		radius     = 1,
		missile = {
			sound_id   = "abaddon",
			ascii      = "*",
			color      = COLOR_LAVA,
			sprite     = SPRITE_PLASMABALL,
			delay      = 20,
			miss_base  = 20,
			miss_dist  = 2,
			expl_delay = 40,
			expl_color = MAGENTA,
		},
	},
}

--This guy replaces the Brusier Brother (there's really nothing in between the two)
register_being "belphegor" {
	name         = "belphegor",
	ascii        = "B",
	color        = RED,
	sprite       = SPRITE_BRUISER,
	hp           = 80,
	armor        = 3,
	speed        = 100,
	attackchance = 30,
	todam        = 8,
	tohit        = 6,
	min_lev      = 15,
	corpse       = true,
	danger       = 14,
	weight       = 6,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "baron_ai",

	resist = { acid = 50 },

	desc            = "Belphegors are powerful demon nobles in Hell.",
	kill_desc       = "slain by a belphegor",
	kill_desc_melee = "slain by a belphegor",

	weapon = {
		damage     = "4d5",
		damagetype = DAMAGE_ACID,
		radius     = 2,
		missile = {
			sound_id   = "belphegor",
			ascii      = "*",
			color      = COLOR_ACID,
			sprite     = SPRITE_ACIDSHOT,
			coscolor   = { 0.0, 1.0, 0.0, 1.0 },
			delay      = 35,
			miss_base  = 35,
			miss_dist  = 4,
			expl_delay = 40,
			expl_color = GREEN,
		},
	},
}

register_being "blooddemon" {
	name         = "blood demon",
	ascii        = "c",
	color        = RED,
	sprite       = SPRITE_DEMON,
	overlay      = { 0.7, 0.3, 0.3, 1.0 },
	hp           = 50,
	armor        = 1,
	todam        = 8,
	tohit        = 3,
	speed        = 120,
	vision       = -1,
	min_lev      = 7,
	corpse       = true,
	danger       = 5,
	weight       = 7,
	bulk         = 100,
	flags        = { BF_CHARGE },
	ai_type      = "demon_ai",

	desc            = "Blood demons are really just ordinary demons that have lived long enough to learn how to stay alive.",
	kill_desc_melee = "chomped by a blood demon",
}

--Two natural weapons for the bruiser.  There are better ways to handle the bruiser now (this code was originally crafted before we had a being prepared slot or lua AIs) but I am not interested in modernizing it right now.0
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

register_being "cacolantern" {
	name         = "cacolantern",
	ascii        = "O",
	color        = YELLOW,
	sprite       = SPRITE_CACODEMON,
	overlay      = { 0.7, 1.0, 0.3, 1.0 },
	glow         = { 0.7,0.5,0.0,1.0 },
	hp           = 60,
	armor        = 1,
	speed        = 120,
	attackchance = 50,
	todam        = 6,
	tohit        = 6,
	min_lev      = 13,
	corpse       = true,
	danger       = 9,
	weight       = 7,
	bulk         = 100,
	flags        = { BF_ENVIROSAFE },
	ai_type      = "melee_ranged_ai",

	desc            = "Cacolanters are said to be colored by the flames of Hell itself.  They're a bit tougher cacodemons and their fireballs are nearly twice as fast.",
	kill_desc       = "smitten by an cacolantern",
	kill_desc_melee = "got too close to a cacolantern",

	weapon = {
		damage     = "2d8",
		damagetype = DAMAGE_PLASMA,
		radius     = 1,
		missile = {
			sound_id   = "cacolantern",
			ascii      = "*",
			color      = LIGHTBLUE,
			sprite     = SPRITE_PLASMABALL,
			delay      = 20,
			miss_base  = 50,
			miss_dist  = 4,
			expl_delay = 40,
			expl_color = BLUE,
		},
	},
}

register_being "darkimp" {
	name         = "dark imp",
	ascii        = "i",
	color        = LIGHTBLUE, --blue replacement
	sprite       = SPRITE_IMP,
	overlay      = { 0.5, 0.8, 1.0, 1.0 },
	glow         = { 0.2,0.2,0.3,1.0 },
	hp           = 35,
	todam        = 4,
	tohit        = 4,
	speed        = 115,
	min_lev      = 8,
	corpse       = true,
	danger       = 6,
	weight       = 9,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "melee_ranged_ai",

	resist = { fire = 50 },

	desc            = "Dark imps hurl blue fireballs instead of red ones.  Other than that they're not much tougher than their brown counterparts.",
	kill_desc       = "burned by a dark imp",
	kill_desc_melee = "slashed by a dark imp",

	weapon = {
		damage     = "2d5",
		damagetype = DAMAGE_FIRE,
		radius     = 1,
		missile = {
			sound_id   = "darkimp",
			ascii      = "*",
			color      = LIGHTBLUE,
			sprite     = SPRITE_FIREBALL,
			delay      = 30,
			miss_base  = 50,
			miss_dist  = 4,
			expl_delay = 40,
			expl_color = LIGHTBLUE,
		},
	},
}

register_item "nat_sk_diabloist1" {
	name       = "nat_sk_diabloist1",
	sprite     = SPRITE_FIREBALL,
	weight     = 0,

	type       = ITEMTYPE_NRANGED,
	damage     = "2d7",
	damagetype = DAMAGE_PLASMA,
	fire       = 3,
	shots      = 4,
	radius     = 0,
	flags      = { IF_NODROP, IF_NOAMMO, IF_SCATTER },
	missile    = {
		sound_id   = "diabloist",
		ascii      = '*',
		color      = LIGHTRED,
		sprite     = SPRITE_ACIDSHOT,
		coscolor   = { 1.0, 0.2, 0.0, 1.0 },
		delay      = 20,
		miss_base  = 50,
		miss_dist  = 4,
		expl_delay = 40,
		expl_color = RED,
	},
}
register_item "nat_sk_diabloist2" {
	name       = "nat_sk_diabloist2",
	sprite     = 0,
	weight     = 0,

	type       = ITEMTYPE_NRANGED,
	damage     = "2d2",
	damagetype  = DAMAGE_FIRE,
	fire       = 1,
	radius     = 1,
	flags      = { IF_NODROP, IF_NOAMMO, IF_AUTOHIT },
	missile    = {
		sound_id    = "archvile",
		ascii       = '*',
		color       = YELLOW,
		sprite      = 0,
		delay       = 50,
		miss_base   = 50,
		miss_dist   = 4,
		expl_delay  = 40,
		expl_color  = COLOR_LAVA,
		flags       = { MF_EXACT, MF_IMMIDATE },
	},
}
register_being "diabloist" {
	name         = "diabloist",
	ascii        = "V",
	color        = LIGHTRED,
	sprite       = SPRITE_ARCHVILE,
	overlay      = { 1.0,0.6,0.6,1.0 },
	glow         = { 1.0,0.0,0.0,1.0 },
	hp           = 90,
	armor        = 2,
	attackchance = 95,
	speed        = 150,
	todam        = 6,
	tohit        = 6,
	min_lev      = 19,
	corpse       = true,
	danger       = 14,
	weight       = 5,
	bulk         = 100,
	flags        = { BF_OPENDOORS, },
	ai_type      = "ranged_ai",

	resist = { fire = 80 },

	desc            = "Diabloists are similar to arch-viles, only far more offensive.  They can turn a marine into a crispy critter in no time; fortunately their offensive streak comes with a tradeoff--no reviving other monsters!",
	kill_desc       = "set ablaze by a diabloist",
	kill_desc_melee = "burned by a diabloist",

	--These should be converted into an AI.  It's on the list.
	OnCreate = function(self)
		self.eq.weapon = item.new("nat_sk_diabloist1")
	end,
	OnAction = function(self)
		--The diabloist's attacks work best at a distance so I have not added in any range bias.
		local chance = 6
		if(self.eq.weapon.id == "nat_sk_diabloist2" and self:in_sight(player)) then
			--Due to the low firetime this can end up checked three times as often.
			chance = chance / 3
		end

		if(math.random(100) < chance) then
			if(self.eq.weapon.id == "nat_sk_diabloist1") then
				self.eq.weapon = item.new("nat_sk_diabloist2")
			else
				self.eq.weapon = item.new("nat_sk_diabloist1")
			end
		end
	end,
}

register_being "hectebus" {
	name         = "hectebus",
	name_plural  = "hectebi",
	ascii        = "M",
	color        = LIGHTBLUE, --Substituting for black
	sprite       = SPRITE_MANCUBUS,
	overlay      = { 0.5,0.7,1.0,1.0 },
	glow         = { 0.3,0.3,0.3,1.0 },
	hp           = 70,
	armor        = 3,
	attackchance = 40,
	todam        = 9,
	tohit        = 3,
	speed        = 80,
	min_lev      = 19,
	corpse       = true,
	danger       = 13,
	weight       = 5,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "sequential_ai",

	desc            = "What's big, ugly, and fires acid? This thing. Better steer clear if you want to live to talk about it.",
	kill_desc       = "cremated by a hectebus",
	kill_desc_melee = "squashed by a hectebus",

	weapon = {
		damage     = "4d5",
		damagetype = DAMAGE_ACID,
		radius     = 2,
		fire       = 10,
		flags      = { IF_SPREAD },
		missile = {
			sound_id   = "hectebus",
			ascii      = "*",
			color      = LIGHTGREEN,
			sprite     = SPRITE_ROCKETSHOT,
			delay      = 30,
			miss_base  = 1,
			miss_dist  = 3,
			expl_delay = 50,
			expl_color = GREEN,
		},
	},

	OnCreate = function (self)
		self.inv:add( "rocket" )
	end
}

register_being "spectre" {
	name         = "spectre",
	ascii        = " ",
	color        = BLACK,
	sprite       = 127, --No transparency overlay effects yet
	hp           = 20,
	armor        = 1,
	todam        = 5,
	tohit        = 3,
	speed        = 100,
	vision       = -2,
	min_lev      = 9,
	corpse       = true,
	danger       = 4,
	weight       = 7,
	bulk         = 100,
	flags        = { BF_CHARGE },
	ai_type      = "demon_ai",

	desc            = "Spectres have traded in a little power for partial invisibility. Watch out for these guys; having one sneak up on you is about the worst way a firefight can go wrong.",
	kill_desc_melee = "eaten by a spectre",
}

register_being "suicideskull" {
	name         = "suicide skull",
	ascii        = "s",
	color        = LIGHTRED,
	sprite       = SPRITE_LOSTSOUL,
	overlay      = { 1.0,0.5,0.5,1.0 },
	glow         = { 0.0,0.0,0.0,1.0 },
	hp           = 12,
	armor        = 0,
	speed        = 140,
	attackchance = 10,
	todam        = -10,
	tohit        = -10,
	min_lev      = 9,
	corpse       = false,
	danger       = 4,
	weight       = 6,
	bulk         = 100,
	flags        = { BF_ENVIROSAFE },
	ai_type      = "lostsoul_ai",

  resist = { fire = 75, bullet = 50 },

	desc            = "Small. Fast. Explodes on contact.  Take them out before they get too close.",

	OnAction = function(self)

		if(self:distance_to( player ) <= 1) then
			self.hp = 1
			EventQueue.AddEvent(level.explosion, 0, { level, self.position, 4, 40, 6, 6, COLOR_LAVA, "barrel.explode", DAMAGE_SHARPNEL } )
		end
	end,
}

--Can't auto-register corpse cells since the player sprites have no death frames.
--There's a chicken/egg problem here with trying to use the prototype for values.  You must manually sync corpses to beings if you change anything.
--[[register_cell "majorcorpse" {
	name       = "major corpse",
	ascii      = "%",
	color      = RED,
	armor      = 0,
	hp         = 25,
	flags      = {CF_CORPSE, CF_NOCHANGE, CF_OVERLAY, CF_VBLOODY, CF_RAISABLE},
	sprite     = SPRITE_CORPSE,
	set        = CELLSET_FLOORS,
	destroyto  = "bloodpool",
	raiseto    = "major",
}--]]
register_being "major" {
	name         = "former major",
	ascii        = "h",
	color        = GREEN,
	sprite       = SPRITE_SERGEANT,
	overlay      = { 0.6,1.0,0.6,1.0 },
	glow         = { 0.0,0.2,0.0,1.0 },
	hp           = 25,
	armor        = 0,
	speed        = 100,
	todam        = 1,
	tohit        = 0,
	min_lev      = 8,
	max_lev      = 20,
	corpse       = "corpse",
	--corpse       = "majorcorpse",
	danger       = 6,
	weight       = 7,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "former_ai",

	desc            = "You used to swap war stories with these guys.  Now you're swapping lead.  Keep your distance; their shotguns are only scary at close range",
	kill_desc       = "jacked by a former major",
	kill_desc_melee = "maimed by a former major",

	OnCreate = function(self)
		self.eq.weapon = item.new("dshotgun")
		self.inv:add( item.new("shell"), { ammo = 30 } )
	end,
}

--[[register_cell "rocketeercorpse" {
	name       = beings["rocketeer"].name .. " corpse",
	ascii      = "%",
	color      = RED,
	armor      = math.max(beings["rocketeer"].armor, 1),
	hp         = beings["rocketeer"].hp,
	flags      = {CF_CORPSE, CF_NOCHANGE, CF_OVERLAY, CF_VBLOODY, CF_RAISABLE},
	sprite     = SPRITE_CORPSE,
	set        = CELLSET_FLOORS,
	destroyto  = "bloodpool",
	raiseto    = beings["rocketeer"].id
}--]]
register_being "rocketeer" {
	name         = "former specialist",
	id           = "rocketeer",
	ascii        = "h",
	color        = BROWN,
	sprite       = SPRITE_PLAYER_BAZOOKA,
	coscolor     = { 0.8,0.6,0.5,1.0 },
	hp           = 20,
	armor        = 1,
	speed        = 100,
	todam        = 2,
	tohit        = 1,
	min_lev      = 11,
	max_lev      = 25,
	corpse       = "corpse",
	--corpse       = "rocketeercorpse",
	danger       = 7,
	weight       = 7,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "former_ai",

	resist = { fire = 20 },

	desc            = "Demolitions experts are as dangerous to themselves as they are to you.",
	kill_desc       = "splattered by a specialist's rocket",
	kill_desc_melee = "maimed by a former specialist",

	OnCreate = function(self)
		self.eq.weapon = item.new("bazooka")
		self.inv:add( item.new("rocket"), { ammo = 3 } )
	end,
}

--[[register_cell "railgunnercorpse" {
	name       = beings["railgunner"].name .. " corpse",
	ascii      = "%",
	color      = RED,
	armor      = math.max(beings["railgunner"].armor, 1),
	hp         = beings["railgunner"].hp,
	flags      = {CF_CORPSE, CF_NOCHANGE, CF_OVERLAY, CF_VBLOODY, CF_RAISABLE},
	sprite     = SPRITE_CORPSE,
	set        = CELLSET_FLOORS,
	destroyto  = "bloodpool",
	raiseto    = beings["railgunner"].id
}--]]
register_being "railgunner" {
	name         = "former sniper",
	ascii        = "h",
	color        = LIGHTCYAN,
	sprite       = SPRITE_PLAYER_PLASMA,
	coscolor     = { 0.0,1.0,1.0,1.0 },
	hp           = 20,
	armor        = 2,
	speed        = 90,
	todam        = 2,
	tohit        = 1,
	min_lev      = 20,
	max_lev      = 45,
	corpse       = "corpse",
	--corpse       = "railgunnercorpse",
	danger       = 8,
	weight       = 4,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "former_ai",

	desc            = "Snipers don't believe in volume of fire, they believe in hitting their targets with the most elegant big gun around.",
	kill_desc       = "railed by a former sniper",
	kill_desc_melee = "maimed by a former sniper",

	OnCreate = function(self)
		self.eq.weapon = item.new("skrailgun")
		self.inv:add( item.new("cell"), { ammo = 40 } )
	end,
}

--[[register_cell "bfgmarinecorpse" {
	name       = beings["bfgmarine"].name .. " corpse",
	ascii      = "%",
	color      = RED,
	armor      = math.max(beings["bfgmarine"].armor, 1),
	hp         = beings["bfgmarine"].hp,
	flags      = {CF_CORPSE, CF_NOCHANGE, CF_OVERLAY, CF_VBLOODY, CF_RAISABLE},
	sprite     = SPRITE_CORPSE,
	set        = CELLSET_FLOORS,
	destroyto  = "bloodpool",
	raiseto    = beings["bfgmarine"].id
}--]]
register_being "bfgmarine" {
	name         = "marine", --There are no 'former' marines.
	ascii        = "h",
	color        = LIGHTGREEN,
	sprite       = SPRITE_PLAYER_BFG9000,
	coscolor     = { 0.0,1.0,0.0,1.0 },
	hp           = 20,
	armor        = 2,
	speed        = 90,
	todam        = 5,
	tohit        = 4,
	min_lev      = 200,
	max_lev      = 200,
	corpse       = "corpse",
	--corpse       = "bfgmarinecorpse",
	danger       = 9,
	weight       = 0,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "former_ai",

	--Because fuck you, that's why
  resist = { bullet = 20, shrapnel = 20, melee = 20 },

	desc            = "You've already shown Hell what one dedicated marine and his rifle can do. Hell now seeks to return the favor.",
	kill_desc       = "splintered by a marine",
	kill_desc_melee = "brutally maimed by a marine",

	OnCreate = function(self)
		self.eq.weapon = item.new("skbfg9000")
		self.inv:add( item.new("cell"), { ammo = 20 } )
	end,
}

register_being "sk_jc" {
	name         = "šber K…rm k",
	ascii        = "@",
	color        = LIGHTBLUE,
	sprite       = SPRITE_JC,
	glow         = { 1.0,0.0,0.0,1.0 },
	hp           = 250,
	armor        = 5,
	speed        = 100,
	todam        = 15,
	tohit        = 8,
	min_lev      = 45,
	max_lev      = 90,
	corpse       = true,
	danger       = 50,
	weight       = 0,
	xp           = 0,
	bulk         = 100,
	flags        = { BF_OPENDOORS, BF_UNIQUENAME, BF_SELFIMMUNE, BF_KNOCKIMMUNE },
	ai_type      = "uberjc_ai",

	desc      = "FUCK! NOOOO! NOOO! NOOOOOOO!",
	kill_desc = "pwned",

	OnCreate = function (self)
		self.eq.weapon = "bazooka"
		for i=1,8 do
			self.inv:add( "rocket", { ammo = 10 } )
		end

		self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 10
		self.hp = self.hpmax
	end,

	OnDie = function (self)
		if self.flags[BF_BOSS] then
			level:explosion( self.position, 17, 40, 0, 0, BLUE, "barrel.explode")
			for b in level:beings() do
				if not ( b:is_player() ) and b.id ~= "sk_jc" then
					b:kill()
				end
			end
			ui.msg_enter("Congratulations! You defeated Uber John Carmack!")
		end
	end,
}


--init code.
Skulltag.Beings.Init = function()

  --Swap imps and shotters since we want a shotgun early on, unlock angel, up all maxLevs, disable bruiser and nightmares
  beings["sergeant"].min_lev   = 1
  beings["imp"].min_lev        = 2
  beings["baron"].min_lev      = 13
  beings["revenant"].min_lev   = 14
  beings["arch"].min_lev       = 17
  beings["angel"].min_lev      = 25

  beings["bruiser"].weight    = 0
  beings["nimp"].weight       = 0
  beings["ncacodemon"].weight = 0
  beings["ndemon"].weight     = 0
  beings["narachno"].weight   = 0
  beings["narch"].weight      = 0
  beings["angel"].weight      = 1
  beings["arch"].weight       = 2

  for i=2, #beings, 1 do
    beings[i].max_lev = 2147483647
  end
  
  --Disable groups
  for i=1, #being_groups, 1 do
    being_groups[i].weight = 0
  end
end
