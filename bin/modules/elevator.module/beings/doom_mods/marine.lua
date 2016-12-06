--Ah, the BFGer.  Unfortunately without some sort of shared team system in place this guy kills everything, including his own team.
--Again, MY guy uses MY bfg implementation.  My BFG isn't really much different from KKs so 
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
	corpse       = true,
	danger       = 9,
	weight       = 0,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "former_ai",

	--Because fuck you, that's why
	resist = { bullet = 20, melee = 20, shrapnel = 20 },

	desc            = "You've already shown Hell what one dedicated marine and his rifle can do. Hell now seeks to return the favor.",
	kill_desc       = "splintered by a marine",
	kill_desc_melee = "brutally maimed by a marine",

	OnCreate = function(self)
		self.eq.weapon = item.new("skbfg9000")
		self.inv:add( item.new("cell"), { ammo = 20 } )
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["bfgmarine"].sound_hit   = core.resolve_sound_id("former.pain")
	beings["bfgmarine"].sound_die   = core.resolve_sound_id("former.die")
	beings["bfgmarine"].sound_act   = core.resolve_sound_id("former.act")
	beings["bfgmarine"].sound_melee = core.resolve_sound_id("soldier.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
