--Duke enemies.  Trooper/Captain == former/imp, pig == sergeant, enforcer == captain, commander == something higher up

require("elevator:items/duke3d/duke_chaingun")
register_being "duke_enforcer" {
	name         = "enforcer",
	ascii        = "g",
	color        = DARKGRAY,
	sprite       = 0,
	hp           = 25,
	armor        = 0,
	speed        = 115,
	todam        = 0,
	tohit        = 0,
	min_lev      = 5,
	max_lev      = 19,
	corpse       = true,
	danger       = 4,
	weight       = 9,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "former_ai",

	desc            = "If you call an enforcer slow and ugly it might take offense to the slow part. Enforcers are quick with their feet and quick with their chainguns. Underestimate one and it will light you up, then spit on you while you're down.",
	kill_desc       = "perforated by an enforcer",
	kill_desc_melee = "clawed by an enforcer",

	OnCreate = function(self)
		self.eq.weapon = item.new("duke_chaingun")
		self.inv:add( item.new("chaingun") ) --Drop a normal chaingun and ammo.
		self.inv:add( item.new("ammo"), { ammo = 100 } )

		if(self.eq.weapon ~= nil) then
			self.eq.weapon.flags[IF_NODROP] = true
		end
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["duke_enforcer"].sound_hit   = core.resolve_sound_id("duke_enforcer.hit")
	beings["duke_enforcer"].sound_die   = core.resolve_sound_id("duke_enforcer.die")
	beings["duke_enforcer"].sound_act   = core.resolve_sound_id("duke_enforcer.act")
	beings["duke_enforcer"].sound_melee = core.resolve_sound_id("soldier.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)