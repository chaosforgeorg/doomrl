--The arch-lich is a boss and has a very lengthy AI dedicated to having it bust your chops in spectacular fashion.
require("elevator:ai/archlich_ai")

register_item "nat_archlich2" {
	name       = "nat_archlich2",
	sprite     = 0,
	weight     = 0,

	type       = ITEMTYPE_NRANGED,
	damage     = "1d3",
	damagetype = DAMAGE_IGNOREARMOR,
	fire       = 11,
	flags      = { IF_NODROP, IF_NOAMMO },
	missile    = {
		sound_id    = "archlich2",
		ascii       = 'o',
		color       = LIGHTRED,
		sprite      = 0,
		delay       = 35,
		miss_base   = 30,
		miss_dist   = 4,
	},

	OnHitBeing = function(self,being,target)
		local beingCoord  = being.position
		local playerCoord = target.position
		local distance    = being:distance_to( target )

		local trace_distance = 4
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
			EventQueue.AddEvent(level.explosion, 0, { level, playerCoord, 2, 30, 3, 3, LIGHTRED, "archlich2.explode", DAMAGE_BULLET } )
			if(area.FULL_SHRINKED:contains(explo_coord)) then
				--Don't play so many sounds!
				local tmp_sound = nil
				if(i == 1 or i == math.floor(explosions/2)) then
					tmp_sound = "archlich2.explode2"
				end

				EventQueue.AddEvent(level.explosion, 0, { level, explo_coord, 1, 50, 2, 2, MAGENTA, tmp_sound, DAMAGE_SHARPNEL } )
			end
		end

		return true
	end,
}
register_item "nat_archlich3" {
	name       = "nat_archlich3",
	sprite     = 0,
	weight     = 0,

	type       = ITEMTYPE_NRANGED,
	damage     = "4d5",
	damagetype = DAMAGE_FIRE,
	fire       = 11,
	radius     = 2,
	shots      = 1,
	flags      = { IF_NODROP, IF_NOAMMO },
	missile    = {
		sound_id    = "archlich3",
		ascii       = '*',
		color       = LIGHTRED,
		sprite      = 0,
		delay       = 25,
		miss_base   = 25,
		miss_dist   = 5,
		expl_delay  = 25,
		expl_color  = COLOR_LAVA,
	},
}

register_being "archlich" {
	name         = "arch-lich",
	ascii        = "L",
	color        = LIGHTRED,
	sprite       = 0,
	hp           = 1000,
	armor        = 3,
	speed        = 160,
	attackchance = 10,
	todam        = 15,
	tohit        = 8,
	min_lev      = 200,
	corpse       = false,
	danger       = 50,
	weight       = 0,
	bulk         = 100,
	xp           = 0,
	flags        = { BF_OPENDOORS, BF_UNIQUENAME, BF_SELFIMMUNE, BF_KNOCKIMMUNE },
	ai_type      = "archlich_ai",

	desc            = "The arch-lich is one of the most powerful creatures across time and space. Go kill it.",
	kill_desc       = "feared the arch-lich",
	kill_desc_melee = "feared the arch-lich",

	OnCreate = function (self)
		self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 40
		self.hp = self.hpmax

		self.eq.weapon = item.new("nat_archlich3")
	end,

	OnAction = function(self)
		if(math.random(10) <= 1) then
			self.eq.weapon = item.new("nat_archlich2")
		else
			--Face
			self.eq.weapon = item.new("nat_archlich3")
		end
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["archlich"].sound_die   = core.resolve_sound_id("archlich.die")
	items["nat_archlich2"].sound_fire  = core.resolve_sound_id("archlich2.fire")
	items["nat_archlich3"].sound_fire  = core.resolve_sound_id("archlich3.fire")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
