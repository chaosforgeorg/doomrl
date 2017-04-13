--I've can only remember seeing the diabloist in Elevator of Dimensions but I'm certain it's not native to that.

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
	flags        = { BF_OPENDOORS, BF_ENVIROSAFE }, --BF_ENVIROSAFE is here as a quick hack for Elevator, remove it for other mods
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

--Fixing up sounds
local FixSounds = function()
	beings["diabloist"].sound_die   = core.resolve_sound_id("diabloist.die")
	beings["diabloist"].sound_act   = core.resolve_sound_id("diabloist.act")
	beings["diabloist"].sound_hit   = core.resolve_sound_id("diabloist.hit")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
