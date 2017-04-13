require("elevator:ai/demon_ai_fixed")
register_being "wolf_dog" {
	name         = "dog",
	ascii        = "d",
	color        = BROWN,
	sprite       = 0,
	hp           = 5,
	armor        = 0,
	speed        = 110,
	todam        = 4,
	tohit        = 2,
	min_lev      = 0,
	max_lev      = 15,
	corpse       = false,
	danger       = 0,
	weight       = 20,
	bulk         = 80,
	flags        = { },
	ai_type      = "demon_ai_fixed",

	desc            = "A German Shepherd.  In another life this could have been your faithful companion, but right now it's either him or you and you'll have to put it down.",
	kill_desc_melee = "bitten by a dog",

	OnCreate = function (self)

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
	beings["wolf_dog"].sound_die   = core.resolve_sound_id("wolf_dog.die")
	beings["wolf_dog"].sound_act   = core.resolve_sound_id("wolf_dog.act")
	beings["wolf_dog"].sound_melee = core.resolve_sound_id("wolf_dog.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)