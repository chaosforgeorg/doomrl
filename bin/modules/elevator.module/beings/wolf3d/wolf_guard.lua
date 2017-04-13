require("elevator:items/wolf3d/wolf_pistol1")
require("elevator:items/wolf3d/wolf_pistol2")
require("elevator:items/wolf3d/wolf_armor1")

register_being "wolf_guard" {
	name         = "guard",
	ascii        = "h",
	color        = BROWN,
	sprite       = 0,
	hp           = 10,
	armor        = 0,
	speed        = 90,
	todam        = -1,
	tohit        = -4,
	min_lev      = 0,
	max_lev      = 20,
	corpse       = false,
	danger       = 1,
	weight       = 20,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "former_ai",

	desc            = "A guard.  Poorly trained and poorly equipped, guards are only a threat in large numbers.",
	kill_desc       = "killed by a guard",
	kill_desc_melee = "killed by a guard",

	OnCreate = function (self)

		--Tinker with health and accuracy slightly
		local weapon = "wolf_pistol1"
		--local ammo   = "wolf_9mm"
		local ammo   = "ammo"
		local armor  = nil

		if(level.danger_level > 5) then
			if(level.danger_level > 15) then
				if(math.random(9) == 1)  then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 2 end
				if(math.random(15) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 2 end
			end
			if(math.random(13) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 2 end
			if(math.random(19) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 2 end
			if(math.random(80) == 1) then weapon = "wolf_pistol2"                                        self.expvalue = self.expvalue + 2 end
			if(math.random(70) == 1) then armor = "wolf_armor1"                                          self.expvalue = self.expvalue + 2 end
		end

		--Weaker guard (must have stubbed a toe)
		if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 2 end

		--Generate weapon
		if(weapon) then self.eq.weapon = item.new(weapon) end
		if(armor)  then self.eq.armor  = item.new(armor)  end
		if(ammo)   then self.inv:add(item.new(ammo))      end

		--EoD tweak to help with overabundance of weaponry
		if(math.random(10) ~= 1) then
			if(self.eq.weapon ~= nil) then self.eq.weapon.flags[IF_NODROP] = true end
			for tmp_item in self.inv:items() do tmp_item.flags[IF_NODROP] = true end
		end
	end,
	OnDie = function (self)
		--This lets us randomly choose a death cry.
		local s = self.id .. ".die" .. math.random(7)
		self:play_sound( { s } )
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["wolf_guard"].sound_act   = core.resolve_sound_id("wolf_guard.act")
	beings["wolf_guard"].sound_melee = core.resolve_sound_id("soldier.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)