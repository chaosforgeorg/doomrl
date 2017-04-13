require("elevator:ai/demon_ai_fixed")
register_being "wolf_ndog" {
	name         = "hellhound",
	sound_id     = "wolf_dog",
	ascii        = "d",
	color        = BROWN + (RED * 16),
	sprite       = 0,
	hp           = 20,
	armor        = 1,
	speed        = 160,
	todam        = 6,
	tohit        = 4,
	min_lev      = 35,
	max_lev      = 65,
	corpse       = false,
	danger       = 4,
	weight       = 2,
	bulk         = 80,
	flags        = { },
	ai_type      = "demon_ai_fixed",

	desc            = "A German Hellhound. Apparently not all dogs go to Heaven.",
	kill_desc_melee = "bitten by a hellhound",

	OnCreate = function (self)

		--Hellion bonus
		self.todamall = self.todamall + 2

		--Tinker
		if(level.danger_level > 5) then
			if(level.danger_level > 15) then
				if(math.random(9) == 1)  then self.todam = self.todam + 1                                    self.expvalue = self.expvalue + 2 end
				if(math.random(15) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 2 end
			end
			if(math.random(13) == 1) then self.todam = self.todam + 1                                    self.expvalue = self.expvalue + 2 end
			if(math.random(19) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 2 end
		end

		if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 2 end
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["wolf_ndog"].sound_die   = core.resolve_sound_id("wolf_dog.die")
	beings["wolf_ndog"].sound_act   = core.resolve_sound_id("wolf_dog.act")
	beings["wolf_ndog"].sound_melee = core.resolve_sound_id("wolf_dog.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)