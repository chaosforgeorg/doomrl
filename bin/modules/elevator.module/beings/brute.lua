--I've only ever seen brutes in Elevator of Dimensions but they don't strike me as original to that.  Brutes explode.  That's about all they do.  They are similar to Suicide skulls.
require("elevator:data_structures")
require("elevator:ai/demon_ai_fixed")
register_being "suicidebrute" {
	name         = "brute",
	ascii        = "H",
	color        = RED,
	sprite       = 0,
	hp           = 30,
	armor        = 1,
	speed        = 90,
	attackchance = 10,
	todam        = -10,
	tohit        = -10,
	min_lev      = 5,
	corpse       = true,
	danger       = 2,
	weight       = 2,
	bulk         = 100,
	flags        = { },
	ai_type      = "demon_ai_fixed",

	desc            = "Brutes are big and loaded with explosives. They'll blow themselves up if they can get close to you, or if they're taking too much incoming fire.",

	OnAction = function(self)

		--If hp is halved OR the player nearby is then suicide.
		local dist_to = self:distance_to( player )
		if(self.hp < self.hpmax / 3 or (self:in_sight( player ) and (dist_to <= 1 or (dist_to <= 2 and self.hp < self.hpmax * 2 / 3)))) then
			self.hp = math.min(self.hp, 1)
			EventQueue.AddEvent(level.explosion, 0, { level, self.position, 4, 40, 6, 6, COLOR_LAVA, "barrel.explode", DAMAGE_SHARPNEL } )
		end
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["suicidebrute"].sound_hit   = core.resolve_sound_id("brute.hit")
	beings["suicidebrute"].sound_die   = core.resolve_sound_id("brute.die")
	beings["suicidebrute"].sound_act   = core.resolve_sound_id("brute.act")
	beings["suicidebrute"].sound_melee = core.resolve_sound_id("blank.wav")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)