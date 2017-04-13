--The reaver is a relatively weak Strife robot armed with a blaster (that sounds like a cannon but does not explode).  Reavers also explode when killed.
register_being "strife_reaver" {
	name         = "reaver",
	ascii        = "c",
	color        = LIGHTGRAY,
	sprite       = 0,
	hp           = 20,
	armor        = 1,
	todam        = 4,
	tohit        = 4,
	speed        = 120,
	min_lev      = 5,
	max_lev      = 18,
	corpse       = false,
	danger       = 4,
	weight       = 9,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "melee_ranged_ai",

	desc            = "Reavers are vaguely humanoid robots with blasters in one arm and cutlery in the other. They explode when destroyed so keep your distance.",
	kill_desc       = "shot down by a reaver",
	kill_desc_melee = "sliced open by a reaver",

	weapon = {
		damage     = "2d5",
		damagetype = DAMAGE_BULLET,
		missile = {
			sound_id   = "strife_reaver",
			ascii      = "-",
			color      = YELLOW,
			sprite     = 0,
			delay      = 30,
			miss_base  = 40,
			miss_dist  = 2,
		},
	},

	OnDie = function(self)
		EventQueue.AddEvent(level.explosion, 0, { level, self.position, 1, 40, 4, 4, COLOR_LAVA, "", DAMAGE_SHARPNEL } )
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["strife_reaver"].sound_hit    = core.resolve_sound_id("strife_reaver.hit")
	beings["strife_reaver"].sound_die    = core.resolve_sound_id("strife_reaver.die")
	beings["strife_reaver"].sound_act    = core.resolve_sound_id("strife_reaver.act")
	beings["strife_reaver"].sound_attack = core.resolve_sound_id("strife_reaver.fire")
	beings["strife_reaver"].sound_melee  = core.resolve_sound_id("strife_reaver.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)