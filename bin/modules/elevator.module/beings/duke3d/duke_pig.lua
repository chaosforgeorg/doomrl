--Duke enemies.  Trooper/Captain == former/imp, pig == sergeant, enforcer == captain, commander == something higher up

require("elevator:items/duke3d/duke_shotgun")
register_being "duke_pig" {
	name         = "pig cop",
	ascii        = "p",
	color        = BLUE,
	sprite       = 0,
	hp           = 25,
	armor        = 0,
	speed        = 80,
	todam        = -1,
	tohit        = -2,
	min_lev      = 3,
	max_lev      = 18,
	corpse       = true,
	danger       = 3,
	weight       = 9,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "former_ai",

	desc            = "These guys can really take a punch! Pig cops have been mutated into misanthropic boars that would like nothing more than to give you a few extra holes.",
	kill_desc       = "shot by the L.A.R.D.",
	kill_desc_melee = "porked by the L.A.R.D.",

	OnCreate = function(self)
		self.eq.weapon = item.new("duke_shotgun")
		self.inv:add( item.new("shotgun") ) --Drop a normal shotgun and ammo.
		self.inv:add( item.new("shell"), { ammo = 30 } )

		if(self.eq.weapon ~= nil) then
			self.eq.weapon.flags[IF_NODROP] = true
		end
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["duke_pig"].sound_hit   = core.resolve_sound_id("duke_pig.hit")
	beings["duke_pig"].sound_die   = core.resolve_sound_id("duke_pig.die")
	beings["duke_pig"].sound_act   = core.resolve_sound_id("duke_pig.act")
	beings["duke_pig"].sound_melee = core.resolve_sound_id("soldier.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)