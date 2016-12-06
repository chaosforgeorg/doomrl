--Blood has four cultist type enemies.  BloodRL has seven in order to flesh out the weapons and mid ranges (some come from zblood).
require("elevator:items/blood/blood_shotgun")
require("elevator:ai/blood_cultist_ai")

register_being "blood_browncultist" {
	name         = "cultist",
	ascii        = "h",
	color        = BROWN,
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

	desc            = "The chief Cabal fodder, cultists are low on fear and big on scatterguns.",
	kill_desc       = "killed by a cultist",
	kill_desc_melee = "maimed by a cultist",

	OnCreate = function (self)
		self.eq.weapon = "blood_shotgun"
		--self.inv:add( "blood_shell", { ammo = 20 } )
		self.inv:add( "shell" )

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
	--beings["blood_browncultist"].sound_hit   = core.resolve_sound_id("cultist.hit3")
	--beings["blood_browncultist"].sound_die   = core.resolve_sound_id("cultist.die3")
	--beings["blood_browncultist"].sound_act   = core.resolve_sound_id("cultist1.act3")
	beings["blood_browncultist"].sound_melee = core.resolve_sound_id("blood.punch")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)