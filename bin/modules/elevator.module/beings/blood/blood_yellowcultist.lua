--Blood has four cultist type enemies.  BloodRL has seven in order to flesh out the weapons and mid ranges (some come from zblood).
--A proper on fire effect would require a new affect and some other custom handling.  I am taking that off the 1.0 release list.  I may add it in later.
require("elevator:items/blood/blood_flaregun")
require("elevator:ai/blood_cultist_ai")

register_being "blood_yellowcultist" {
	name         = "cultist",
	ascii        = "h",
	color        = YELLOW,
	sprite       = 0,
	todam        = -1,
	tohit        = -2,
	speed        = 70,
	min_lev      = 2,
	max_lev      = 15,
	corpse       = true,
	danger       = 2,
	weight       = 10,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "blood_cultist_ai",

	desc            = "Cabal scouts.  'Armed' with flare guns, these guys can't really put up much of a fight.",
	kill_desc       = "set ablaze by a cultist",
	kill_desc_melee = "maimed by a cultist",

	OnCreate = function (self)
		self.eq.weapon = "blood_flaregun"
		self.inv:add( "blood_flare", { ammo = 5 } )

		--EoD tweak because we have enough weapons
		if(self.eq.weapon ~= nil) then self.eq.weapon.flags[IF_NODROP] = true end
		for tmp_item in self.inv:items() do tmp_item.flags[IF_NODROP] = true end
	end,
	OnAttacked = function( self )
		self:play_sound( "cultist.hit" .. math.random(4) )
	end,
	OnDie = function( self )
		self:play_sound( "cultist.die" .. math.random(4) )
	end,
}

--Fixing up sounds
local FixSounds = function()
	--beings["blood_yellowcultist"].sound_hit   = core.resolve_sound_id("cultist.hit1")
	--beings["blood_yellowcultist"].sound_die   = core.resolve_sound_id("cultist.die1")
	--beings["blood_yellowcultist"].sound_act   = core.resolve_sound_id("cultist2.act7")
	beings["blood_yellowcultist"].sound_melee = core.resolve_sound_id("blood.punch")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)