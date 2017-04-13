--I think the eyesore is unique to EoD.  "Cutman Mike" is credited with making them.  In this case that probably means the graphics are original, but I can't say for certain and the EoD citations never include source material.
require("elevator:ai/demon_ai_fixed")
register_being "eyesore" {
	name         = "eyesore",
	ascii        = "X",
	color        = BROWN,
	sprite       = 0,
	hp           = 100,
	armor        = 0,
	speed        = 170,
	todam        = 10,
	tohit        = 5,
	min_lev      = 18,
	corpse       = false,
	danger       = 11,
	weight       = 6,
	bulk         = 100,
	flags        = { },
	ai_type      = "demon_ai_fixed",

	resist = { bullet = 75, shrapnel = 75, fire = 75 },

	desc            = "Eyesores only come out at night. They are fast, tough, vicious, and they usually hunt in packs. If you see one, kill it as soon as possible with the biggest gun you have.",
	kill_desc_melee = "munched by an eyesore",

	OnCreate = function (self)
		if(math.random(3) == 1) then
			self.flags[ BF_HUNTING ] = true
		end
	end,
	OnDie = function (self)
		--These guys don't leave corpses, they combust. 
		level:explosion( self.position, 1, 20, 0, 0, YELLOW )
		level:play_sound(core.resolve_sound_id("arch.fire"), self.position)
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["eyesore"].sound_die   = core.resolve_sound_id("eyesore.die")
	beings["eyesore"].sound_act   = core.resolve_sound_id("eyesore.act")
	beings["eyesore"].sound_hit   = core.resolve_sound_id("eyesore.hit")
	beings["eyesore"].sound_melee = core.resolve_sound_id("eyesore.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
