--The railgunner is another, very dangerous, progression.
--MY version of the railgunner uses MY version of the railgun.  You can modify that fairly easily, but since it's a custom tweak I won't be adding in any fancy requires or switches.
register_being "railgunner" {
	name         = "former sniper",
	ascii        = "h",
	color        = LIGHTCYAN,
	sprite       = SPRITE_PLAYER_PLASMA,
	coscolor     = { 0.0,1.0,1.0,1.0 },
	hp           = 20,
	armor        = 2,
	speed        = 90,
	todam        = 2,
	tohit        = 1,
	min_lev      = 20,
	max_lev      = 45,
	corpse       = true,
	danger       = 8,
	weight       = 4,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "former_ai",

	desc            = "Snipers don't believe in volume of fire, they believe in hitting their targets with the most elegant big gun around.",
	kill_desc       = "railed by a former sniper",
	kill_desc_melee = "maimed by a former sniper",

	OnCreate = function(self)
		self.eq.weapon = item.new("skrailgun")
		self.inv:add( item.new("cell"), { ammo = 40 } )
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["railgunner"].sound_hit   = core.resolve_sound_id("former.pain")
	beings["railgunner"].sound_die   = core.resolve_sound_id("former.die")
	beings["railgunner"].sound_act   = core.resolve_sound_id("former.act")
	beings["railgunner"].sound_melee = core.resolve_sound_id("soldier.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)