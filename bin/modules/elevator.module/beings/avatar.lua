--The avatar sprite comes from Heretic or one of its sequels.  The avatar being however seems more distinct to Elevator of Dimensions.  Not being much of a Heretic player I don't know how much of a similarity is there.

--weapons 1-4
register_item "nat_avatar1" {
	name       = "nat_avatar1",
	sprite     = 0,
	weight     = 0,

	type       = ITEMTYPE_NRANGED,
	damage     = "3d6",
	damagetype = DAMAGE_PLASMA,
	fire       = 4,
	shots      = 1,
	flags      = { IF_NODROP, IF_NOAMMO, IF_SCATTER, IF_SPREAD },
	missile    = {
		sound_id    = "avatar1",
		ascii       = '~',
		color       = MAGENTA,
		sprite      = 0,
		delay       = 40,
		miss_base   = 20,
		miss_dist   = 4,
		flags       = { MF_HARD },
	},
}
register_item "nat_avatar2" {
	name       = "nat_avatar2",
	sprite     = 0,
	weight     = 0,

	type       = ITEMTYPE_NRANGED,
	damage     = "2d3", --Just to screw with the distribution >)
	damagetype = DAMAGE_IGNOREARMOR,
	fire       = 11,
	flags      = { IF_NODROP, IF_NOAMMO },
	missile    = {
		sound_id    = "avatar2",
		ascii       = 'o',
		color       = LIGHTBLUE,
		sprite      = 0,
		delay       = 35,
		miss_base   = 30,
		miss_dist   = 4,
	},

	OnHitBeing = function(self,being,target)
		--I would like to both run this code for ANY collision as well as make the resulting
		--mini-'missiles' collide with walls instead of just spawning a few blocks away.
		local beingCoord  = being.position
		local playerCoord = target.position
		local distance    = being:distance_to( target )

		local trace_distance = 3
		local explosions = 5
		local trace_angle  = 360 / explosions

		--Remember: we want floats so keep the coord struct out of our calcs.
		local tmp_vector = (playerCoord - beingCoord)
		local tmp_scalar = (trace_distance / distance)
		local starter = { tmp_vector.x * tmp_scalar, tmp_vector.y * tmp_scalar }

		--Rotate around the zero coord.  The first rotation is a half rotation.

		for i = 1, explosions do

			local new_angle = (trace_angle * i) - (trace_angle / 2)
			local new_adjust = coord.new( starter[1] * math.cos(math.rad(new_angle))  - starter[2] * math.sin(math.rad(new_angle))
			                            , starter[1] * math.sin(math.rad(new_angle))  + starter[2] * math.cos(math.rad(new_angle)) )

			local explo_coord = playerCoord + new_adjust
			EventQueue.AddEvent(level.explosion, 0, { level, playerCoord, 2, 30, 4, 4, BLUE, "avatar2.explode", DAMAGE_BULLET } )
			if(area.FULL_SHRINKED:contains(explo_coord)) then
				--Don't play so many sounds!
				local tmp_sound = nil
				if(i == 1 or i == math.floor(explosions/2)) then
					tmp_sound = "avatar2.explode2"
				end

				EventQueue.AddEvent(level.explosion, 0, { level, explo_coord, 1, 50, 2, 3, LIGHTBLUE, tmp_sound, DAMAGE_ACID } )
			end
		end

		return true
	end,
}
register_item "nat_avatar3" {
	name       = "nat_avatar3",
	sprite     = 0,
	weight     = 0,

	type       = ITEMTYPE_NRANGED,
	damage     = "4d3",
	damagetype = DAMAGE_FIRE,
	fire       = 12,
	radius     = 1,
	shots      = 5,
	flags      = { IF_NODROP, IF_NOAMMO },
	missile    = {
		sound_id    = "avatar3",
		ascii       = '*',
		color       = LIGHTRED,
		sprite      = 0,
		delay       = 25,
		miss_base   = 35,
		miss_dist   = 5,
		expl_delay  = 25,
		expl_color  = COLOR_LAVA,
	},
}
register_item "nat_avatar4" {
	name       = "nat_avatar4",
	sprite     = 0,
	weight     = 0,

	type       = ITEMTYPE_NRANGED,
	damage     = "25d2",
	damagetype = DAMAGE_IGNOREARMOR,
	fire       = 10,
	flags      = { IF_NODROP, IF_NOAMMO },
	missile    = {
		sound_id    = "avatar4",
		ascii       = '*',
		color       = WHITE,
		sprite      = 0,
		delay       = 40,
		miss_base   = 0,
		miss_dist   = 5,
		flags      = { MF_EXACT },
		expl_delay  = 25,
		expl_color  = WHITE,
	},
}

register_being "avatar" {
	name         = "avatar",
	ascii        = "A",
	color        = DARKGRAY,
	sprite       = 0,
	hp           = 200,
	armor        = 3,
	speed        = 150,
	todam        = 8,
	tohit        = 3,
	min_lev      = 14,
	corpse       = false,
	danger       = 13,
	weight       = 1,
	bulk         = 100,
	flags        = { },
	ai_type      = "ranged_ai",

	desc            = "The avatar has a wide array of attacks designed to smash annoying adventurers like you into bits. As a vessel of pure destruction, what else would you expect?",
	kill_desc       = "smoten by an avatar",
	kill_desc_melee = "smoten by an avatar",

	OnCreate = function (self)
		self.eq.weapon = item.new("nat_avatar1")
	end,

	OnAction = function(self)
		--I checked the AI--it just randomly selects the next attack.
		--The original odds are as follows when you factor in how the odds compound: .2275 .25 .45 .0725
		local rand = math.random(100)
		if(rand <= 25) then
			--Red Lightning
			self.eq.weapon = item.new("nat_avatar1")
		elseif(rand <= 50) then
			--Blue Ball
			self.eq.weapon = item.new("nat_avatar2")
		elseif(rand <= 90) then
			--Fire Fire Fire
			self.eq.weapon = item.new("nat_avatar3")
		else
			--Face
			self.eq.weapon = item.new("nat_avatar4")
		end
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["avatar"].sound_die   = core.resolve_sound_id("avatar.die")
	beings["avatar"].sound_act   = core.resolve_sound_id("avatar.act")
	beings["avatar"].sound_hit   = core.resolve_sound_id("avatar.hit")
	items["nat_avatar1"].sound_fire  = core.resolve_sound_id("avatar1.fire")
	items["nat_avatar2"].sound_fire  = core.resolve_sound_id("avatar2.fire")
	items["nat_avatar3"].sound_fire  = core.resolve_sound_id("avatar3.fire")
	items["nat_avatar4"].sound_fire  = core.resolve_sound_id("avatar4.fire")
	--Explosion sounds aren't resolved until they actually explode
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)