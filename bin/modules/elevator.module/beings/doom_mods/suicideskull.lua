--The suicide skull came from some invasion mod.  I liked it so I added it in.  I'm sure it was lifted prior to my finding it; if anyone knows the bonafide original source that'd be nice to know.

--A long standing bug (though KK considers it a design inevitebility) prevents us from firing off an explosion IN the
--OnDie portion of this code.  This requirement is for an event library that can bypass this.
require("elevator:data_structures")
register_being "suicideskull" {
	name         = "suicide skull",
	ascii        = "s",
	color        = LIGHTRED,
	sprite       = SPRITE_LOSTSOUL,
	overlay      = { 1.0,0.5,0.5,1.0 },
	glow         = { 0.0,0.0,0.0,1.0 },
	hp           = 12,
	armor        = 0,
	speed        = 140,
	attackchance = 10,
	todam        = -10,
	tohit        = -10,
	min_lev      = 9,
	corpse       = false,
	danger       = 4,
	weight       = 6,
	bulk         = 100,
	flags        = { BF_ENVIROSAFE },
	ai_type      = "lostsoul_ai",

	resist = { fire = 75, bullet = 50 },

	desc            = "Small. Fast. Explodes on contact.  Take them out before they get too close.",

	OnAction = function(self)

		if(self:distance_to( player ) <= 1) then
			self.hp = 1
			EventQueue.AddEvent(level.explosion, 0, { level, self.position, 4, 40, 6, 6, COLOR_LAVA, "barrel.explode", DAMAGE_SHARPNEL } )
		end
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["suicideskull"].sound_hit   = core.resolve_sound_id("lostsoul.hit")
	beings["suicideskull"].sound_die   = core.resolve_sound_id("lostsoul.die")
	beings["suicideskull"].sound_act   = core.resolve_sound_id("lostsoul.act")
	beings["suicideskull"].sound_melee = core.resolve_sound_id("blank.wav")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
