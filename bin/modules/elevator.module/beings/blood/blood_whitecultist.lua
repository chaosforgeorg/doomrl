--Blood has four cultist type enemies.  BloodRL has seven in order to flesh out the weapons and mid ranges (some come from zblood).
--A proper on fire effect would require a new affect and some other custom handling.  I am taking that off the 1.0 release list and I'll tweak it later.
require("elevator:items/blood/blood_napalm")
require("elevator:ai/blood_cultist_ai")

register_being "blood_whitecultist" {
	name         = "zealot",
	ascii        = "h",
	color        = WHITE,
	sprite       = 0,
	hp           = 20,
	armor        = 1,
	todam        = 2,
	tohit        = 1,
	min_lev      = 12,
	max_lev      = 25,
	corpse       = true,
	danger       = 6,
	weight       = 6,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "blood_cultist_ai",

	desc            = "Zealots have long served the Cabal and will stop at nothing to obliterate you in the name of their dark god.",
	kill_desc       = "blasted into bits by a zealot",
	kill_desc_melee = "maimed by a zealot",

	OnCreate = function(self)
		self.eq.weapon = item.new("blood_napalm")
		self.inv:add( item.new("rocket"), { ammo = 3 } )
		--self.inv:add( item.new("blood_gas"), { ammo = 3 } )

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
	--beings["blood_whitecultist"].sound_hit   = core.resolve_sound_id("cultist.hit2")
	--beings["blood_whitecultist"].sound_die   = core.resolve_sound_id("cultist.die2")
	--beings["blood_whitecultist"].sound_act   = core.resolve_sound_id("cultist1.act1")
	beings["blood_whitecultist"].sound_melee = core.resolve_sound_id("blood.punch")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)