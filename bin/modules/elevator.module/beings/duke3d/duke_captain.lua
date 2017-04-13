--Duke enemies.  Trooper/Captain == former/imp, pig == sergeant, enforcer == captain, commander == something higher up

require("elevator:items/duke3d/duke_blaster")
require("elevator:ai/duke_trooper_ai")
register_being "duke_captain" {
	name         = "captain",
	ascii        = "g",
	color        = LIGHTRED,
	sprite       = 0,
	hp           = 15,
	armor        = 0,
	speed        = 100,
	todam        = 0,
	tohit        = -2,
	min_lev      = 0,
	max_lev      = 17,
	corpse       = true,
	danger       = 2,
	weight       = 6,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "duke_trooper_ai",

	desc            = "Assault captains are a step above troopers in the alien hierarchy but they're still expendible fodder.",

	OnCreate = function(self)
		self.eq.weapon = item.new("duke_blaster")
		self.inv:add( item.new("ammo"), { ammo = 24 } ) --The assault captain drops ammo.  No one knows why.

		if(self.eq.weapon ~= nil) then
			self.eq.weapon.flags[IF_NODROP] = true
			self.eq.weapon.flags[IF_NOAMMO] = true
		end
	end,
	OnAction = function(self)
		ai_tools.cloak(self)
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["duke_captain"].sound_hit   = core.resolve_sound_id("duke_trooper.hit")
	beings["duke_captain"].sound_die   = core.resolve_sound_id("duke_enforcer.die")
	beings["duke_captain"].sound_act   = core.resolve_sound_id("duke_captain.act")
	beings["duke_captain"].sound_melee = core.resolve_sound_id("soldier.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)