--Blood has four cultist type enemies.  BloodRL has seven in order to flesh out the weapons and mid ranges (some come from zblood).
require("elevator:items/blood/blood_tesla")
require("elevator:ai/blood_cultist_ai")

register_being "blood_bluecultist" {
	name         = "zealot",
	ascii        = "h",
	color        = LIGHTBLUE,
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

	resist = { plasma  = 50 }, --Using their own weapons against them doesn't work well in Blood

	desc            = "Zealots are the shock troopers of the Cabal and have received specialized training in order to be more nasty.",
	kill_desc       = "zapped by a zealot",
	kill_desc_melee = "maimed by a zealot",

	OnCreate = function(self)
		self.eq.weapon = item.new("blood_tesla")
		self.inv:add( item.new("cell"), { ammo = 40 } )
		--self.inv:add( item.new("blood_charge"), { ammo = 3 } )

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
	--beings["blood_bluecultist"].sound_hit   = core.resolve_sound_id("cultist.hit3")
	--beings["blood_bluecultist"].sound_die   = core.resolve_sound_id("cultist.die3")
	--beings["blood_bluecultist"].sound_act   = core.resolve_sound_id("cultist1.act2")
	beings["blood_bluecultist"].sound_melee = core.resolve_sound_id("blood.punch")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
