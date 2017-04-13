--Duke enemies.  Trooper/Captain == former/imp, pig == sergeant, enforcer == captain, commander == something higher up

require("elevator:items/duke3d/duke_blaster")
register_being "duke_trooper" {
	name         = "trooper",
	ascii        = "g",
	color        = LIGHTGRAY,
	sprite       = 0,
	hp           = 10,
	armor        = 0,
	speed        = 90,
	todam        = -1,
	tohit        = -4,
	min_lev      = 0,
	max_lev      = 12,
	corpse       = true,
	danger       = 1,
	weight       = 10,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "former_ai",

	desc            = "Assault troopers do all of the alien grunt work on the front lines. Plentiful but weak.",

	OnCreate = function(self)
		self.eq.weapon = item.new("duke_blaster")
		self.inv:add( item.new("ammo"), { ammo = 24 } ) --The assault trooper drops ammo.  No one knows why.

		if(self.eq.weapon ~= nil) then
			self.eq.weapon.flags[IF_NODROP] = true
			self.eq.weapon.flags[IF_NOAMMO] = true
		end
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["duke_trooper"].sound_hit   = core.resolve_sound_id("duke_trooper.hit")
	beings["duke_trooper"].sound_die   = core.resolve_sound_id("duke_enforcer.die")
	beings["duke_trooper"].sound_act   = core.resolve_sound_id("duke_trooper.act")
	beings["duke_trooper"].sound_melee = core.resolve_sound_id("soldier.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)