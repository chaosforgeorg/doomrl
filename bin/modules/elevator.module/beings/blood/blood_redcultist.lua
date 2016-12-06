--Blood has four cultist type enemies.  BloodRL has seven in order to flesh out the weapons and mid ranges (some come from zblood).
require("elevator:items/blood/blood_pistol")
require("elevator:ai/blood_cultist_ai")

register_being "blood_redcultist" {
	name         = "ackolyte",
	ascii        = "h",
	color        = LIGHTRED,
	sprite       = 0,
	todam        = -1,
	tohit        = -4,
	speed        = 90,
	min_lev      = 0,
	max_lev      = 12,
	corpse       = true,
	danger       = 1,
	weight       = 10,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "blood_cultist_ai",

	desc            = "Low level Cabal initiates that can't hit the broad side of a barn.",
	kill_desc       = "punctured by an ackolyte",
	kill_desc_melee = "maimed by an ackolyte",

	OnCreate = function (self)
		self.eq.weapon = "blood_pistol"
		--self.inv:add( "blood_coltammo" )
		self.inv:add( "ammo" )

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
	--beings["blood_redcultist"].sound_hit   = core.resolve_sound_id("cultist.hit2")
	--beings["blood_redcultist"].sound_die   = core.resolve_sound_id("cultist.die2")
	--beings["blood_redcultist"].sound_act   = core.resolve_sound_id("cultist2.act2")
	beings["blood_redcultist"].sound_melee = core.resolve_sound_id("blood.punch")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)