--Blood has four cultist type enemies.  BloodRL has seven in order to flesh out the weapons and mid ranges (some come from zblood).
require("elevator:items/blood/blood_tommygun")
require("elevator:ai/blood_cultist_ai")

register_being "blood_graycultist" {
	name         = "fanatic",
	ascii        = "h",
	color        = DARKGRAY,
	sprite       = 0,
	speed        = 80,
	min_lev      = 5,
	max_lev      = 15,
	corpse       = true,
	danger       = 3,
	weight       = 10,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "blood_cultist_ai",

	desc            = "Fanatics are short on sanity but long on ammo.",
	kill_desc       = "made hole-y by a fanatic",
	kill_desc_melee = "maimed by a fanatic",

	OnCreate = function (self)
		self.eq.weapon = "blood_tommygun"
		--self.inv:add( "blood_ammo", { ammo = 100 } )
		self.inv:add( "ammo", { ammo = 100 } )

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
	--beings["blood_graycultist"].sound_hit   = core.resolve_sound_id("cultist.hit4")
	--beings["blood_graycultist"].sound_die   = core.resolve_sound_id("cultist.die4")
	--beings["blood_graycultist"].sound_act   = core.resolve_sound_id("cultist2.act4")
	beings["blood_graycultist"].sound_melee = core.resolve_sound_id("blood.punch")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)