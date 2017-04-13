require("elevator:items/wolf3d/wolf_armor1")
require("elevator:items/wolf3d/wolf_armor2")
require("elevator:items/wolf3d/wolf_sub1")

register_being "wolf_nss" {
	name         = "nightmare schutzstaffel",
	sound_id     = "wolf_ss",
	ascii        = "h",
	color        = BLUE + (RED * 16),
	sprite       = 0,
	hp           = 30,
	armor        = 1,
	speed        = 110,
	todam        = 2,
	tohit        = 0,
	min_lev      = 35,
	max_lev      = 75,
	corpse       = false,
	danger       = 7,
	weight       = 1,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "former_ai",

	resist = { fire = 50 },

	desc            = "War takes both good men and bad men. Judging by the crimson aura this was not one of the good men.",
	kill_desc       = "killed by an SS nazi",
	kill_desc_melee = "beaten by an SS nazi",

	OnCreate = function (self)

		--Hellion bonus
		self.todamall = self.todamall + 2

		--Tinker
		local armor = 0

		if(level.danger_level > 5) then
			if(level.danger_level > 15) then
				if(math.random(9) == 1)  then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 4 end
				if(math.random(15) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 4 end
				if(math.random(5) == 1)  then armor = armor + 1                                              self.expvalue = self.expvalue + 4 end
			end
			if(math.random(13) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 4 end
			if(math.random(19) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 4 end
			if(math.random(5) == 1) then armor = armor + 1                                               self.expvalue = self.expvalue + 4 end
		end

		if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 4 end

		self.eq.weapon = item.new("wolf_sub1")
		if(armor > 0) then self.eq.armor  = item.new("wolf_armor" .. armor) end
		--self.inv:add(item.new("wolf_9mm", { ammo = 64 }))
		self.inv:add(item.new("ammo", { ammo = 64 }))

		--EoD tweak to help with overabundance of weaponry
		if(math.random(10) ~= 1) then
			if(self.eq.weapon ~= nil) then self.eq.weapon.flags[IF_NODROP] = true end
			if(self.eq.armor  ~= nil) then self.eq.armor.flags[IF_NODROP] = true end
			for tmp_item in self.inv:items() do tmp_item.flags[IF_NODROP] = true end
		end
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["wolf_nss"].sound_die   = core.resolve_sound_id("wolf_ss.die")
	beings["wolf_nss"].sound_act   = core.resolve_sound_id("wolf_ss.act")
	beings["wolf_nss"].sound_melee = core.resolve_sound_id("soldier.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
