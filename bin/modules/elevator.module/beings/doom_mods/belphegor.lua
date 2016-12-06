--The belphegor is in Skulltag, possibly other mods since it's just a recolored baron.  It replaces the DoomRL bruiser brother with a slightly weaker but roughly equivalent generic.  The sounds are from KDIZD's Hell Knight.
register_being "belphegor" {
	name         = "belphegor",
	ascii        = "B",
	color        = RED,
	sprite       = SPRITE_BRUISER,
	hp           = 80,
	armor        = 3,
	speed        = 100,
	attackchance = 30,
	todam        = 8,
	tohit        = 6,
	min_lev      = 15,
	corpse       = true,
	danger       = 14,
	weight       = 6,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "baron_ai",

	resist = { acid = 50 },

	desc            = "Belphegors are powerful demon nobles in Hell.",
	kill_desc       = "slain by a belphegor",
	kill_desc_melee = "slain by a belphegor",

	weapon = {
		damage     = "4d5",
		damagetype = DAMAGE_ACID,
		radius     = 2,
		missile = {
			sound_id   = "belphegor",
			ascii      = "*",
			color      = COLOR_ACID,
			sprite     = SPRITE_ACIDSHOT,
			coscolor   = { 0.0, 1.0, 0.0, 1.0 },
			delay      = 35,
			miss_base  = 35,
			miss_dist  = 4,
			expl_delay = 40,
			expl_color = GREEN,
		},
	},
}

--Fixing up sounds
local FixSounds = function()
	beings["belphegor"].sound_hit = core.resolve_sound_id("belphegor.hit")
	beings["belphegor"].sound_die = core.resolve_sound_id("knight.die")
	beings["belphegor"].sound_act = core.resolve_sound_id("knight.act")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
