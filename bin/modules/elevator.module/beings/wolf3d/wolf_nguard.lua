require("elevator:items/wolf3d/wolf_pistol1")
require("elevator:items/wolf3d/wolf_pistol2")
require("elevator:items/wolf3d/wolf_armor1")

register_being "wolf_nguard" {
	name         = "nightmare guard",
	sound_id     = "wolf_guard",
	ascii        = "h",
	color        = BROWN + (RED * 16),
	sprite       = 0,
	hp           = 30,
	armor        = 1,
	speed        = 115,
	todam        = 1,
	tohit        = 0,
	min_lev      = 35,
	max_lev      = 60,
	corpse       = false,
	danger       = 6,
	weight       = 2,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "former_ai",

	resist = { fire = 50 },

	desc            = "War takes both good men and bad men. Judging by the crimson aura this was not one of the good men.",
	kill_desc       = "killed by a nightmare guard",
	kill_desc_melee = "beaten by a nightmare guard",

	OnCreate = function (self)

		--Hellion bonus
		self.todamall = self.todamall + 2

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
		local s = self.__proto.sound_id .. ".die" .. math.random(7)
		self:play_sound( { s } )
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["wolf_nguard"].sound_act   = core.resolve_sound_id("wolf_guard.act")
	beings["wolf_nguard"].sound_melee = core.resolve_sound_id("soldier.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
