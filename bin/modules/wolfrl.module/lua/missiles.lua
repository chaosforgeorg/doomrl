function DoomRL.loadmissiles()

	register_missile "wolf_mknife" {
		sound_id   = "knife",
		color      = LIGHTGRAY,
		sprite     = SPRITE_KNIFE,
		delay      = 50,
		miss_base  = 10,
		miss_dist  = 3,
		flags      = { MF_EXACT },
		range      = 5,
	}

	register_missile "wolf_mpistol1" {
		sound_id   = "wolf_pistol1",
		color      = LIGHTGRAY,
		sprite     = SPRITE_SHOT,
		delay      = 14,
		miss_base  = 10,
		miss_dist  = 3,
	}
	register_missile "wolf_mpistol2" {
		sound_id   = "wolf_pistol2",
		color      = LIGHTGRAY,
		sprite     = SPRITE_SHOT,
		delay      = 15,
		miss_base  = 10,
		miss_dist  = 3,
	}
	register_missile "wolf_mpistol3" {
		sound_id   = "wolf_pistol3",
		color      = LIGHTGRAY,
		sprite     = SPRITE_SHOT,
		delay      = 13,
		miss_base  = 10,
		miss_dist  = 3,
	}
	register_missile "wolf_mpistol4" {
		sound_id   = "wolf_pistol4",
		color      = LIGHTGRAY,
		sprite     = SPRITE_SHOT,
		delay      = 14,
		miss_base  = 10,
		miss_dist  = 3,
	}

	register_shotgun "wolf_snormal" {
		maxrange   = 15,
		spread     = 3,
		reduce     = 0.07,
	}
	register_shotgun "wolf_swide" {
		maxrange   = 8,
		spread     = 3,
		reduce     = 0.1,
	}
	register_shotgun "wolf_sfocused" {
		maxrange   = 15,
		spread     = 2,
		reduce     = 0.05,
	}


	register_missile "wolf_msub1" {
		sound_id   = "wolf_sub1",
		color      = LIGHTGRAY,
		sprite     = SPRITE_SHOT,
		delay      = 30,
		miss_base  = 10,
		miss_dist  = 5,
	}
	register_missile "wolf_msub2" {
		sound_id   = "wolf_sub2",
		color      = LIGHTGRAY,
		sprite     = SPRITE_SHOT,
		delay      = 30,
		miss_base  = 10,
		miss_dist  = 5,
	}
	register_missile "wolf_msub3" {
		sound_id   = "wolf_sub3",
		color      = LIGHTGRAY,
		sprite     = SPRITE_SHOT,
		delay      = 30,
		miss_base  = 10,
		miss_dist  = 5,
	}
	register_missile "wolf_msub4" {
		sound_id   = "wolf_sub4",
		color      = LIGHTGRAY,
		sprite     = SPRITE_SHOT,
		delay      = 30,
		miss_base  = 10,
		miss_dist  = 5,
	}

	register_missile "wolf_mbolt1" {
		sound_id   = "wolf_bolt1",
		color      = WHITE,
		sprite     = SPRITE_SHOT,
		delay      = 8,
		miss_base  = 5,
		miss_dist  = 3,
	}
	register_missile "wolf_mbolt2" {
		sound_id   = "wolf_bolt2",
		color      = WHITE,
		sprite     = SPRITE_SHOT,
		delay      = 8,
		miss_base  = 5,
		miss_dist  = 3,
	}
	register_missile "wolf_mbolt3" {
		sound_id   = "wolf_bolt3",
		color      = WHITE,
		sprite     = SPRITE_SHOT,
		delay      = 8,
		miss_base  = 5,
		miss_dist  = 3,
	}

	register_missile "wolf_msemi1" {
		sound_id   = "wolf_semi1",
		color      = WHITE,
		sprite     = SPRITE_SHOT,
		delay      = 9,
		miss_base  = 5,
		miss_dist  = 4,
	}
	register_missile "wolf_msemi2" {
		sound_id   = "wolf_semi2",
		color      = WHITE,
		sprite     = SPRITE_SHOT,
		delay      = 9,
		miss_base  = 5,
		miss_dist  = 4,
	}
	register_missile "wolf_msemi3" {
		sound_id   = "wolf_semi3",
		color      = WHITE,
		sprite     = SPRITE_SHOT,
		delay      = 9,
		miss_base  = 5,
		miss_dist  = 4,
	}

	register_missile "wolf_mauto1" {
		sound_id   = "wolf_auto1",
		color      = WHITE,
		sprite     = SPRITE_SHOT,
		delay      = 28,
		miss_base  = 10,
		miss_dist  = 5,
	}
	register_missile "wolf_mauto2" {
		sound_id   = "wolf_auto2",
		color      = WHITE,
		sprite     = SPRITE_SHOT,
		delay      = 28,
		miss_base  = 10,
		miss_dist  = 5,
	}
	register_missile "wolf_mauto3" {
		sound_id   = "wolf_auto3",
		color      = WHITE,
		sprite     = SPRITE_SHOT,
		delay      = 28,
		miss_base  = 10,
		miss_dist  = 5,
	}

	register_missile "wolf_massault1" {
		sound_id   = "wolf_assault1",
		color      = LIGHTCYAN,
		sprite     = SPRITE_SHOT,
		delay      = 25,
		miss_base  = 10,
		miss_dist  = 3,
	}
	register_missile "wolf_massault2" {
		sound_id   = "wolf_assault2",
		color      = LIGHTCYAN,
		sprite     = SPRITE_SHOT,
		delay      = 28,
		miss_base  = 20,
		miss_dist  = 5,
	}

	register_missile "wolf_mrocket" {
		sound_id   = "wolf_bazooka",
		color      = BROWN,
		sprite     = SPRITE_ROCKETSHOT,
		delay      = 30,
		miss_base  = 30,
		miss_dist  = 5,
		expl_delay = 40,
		expl_color = RED,
	}
	register_missile "wolf_mrocketjump" {
		sound_id   = "wolf_bazooka",
		color      = BROWN,
		sprite     = SPRITE_ROCKETSHOT,
		delay      = 30,
		miss_base  = 30,
		miss_dist  = 5,
		flags      = { MF_EXACT },
		range      = 1,
		expl_delay = 40,
		expl_color = RED,
		expl_flags = { EFSELFKNOCKBACK, EFSELFHALF },
	}

	register_missile "wolf_mflamethrower" {
		sound_id   = "wolf_flamethrower",
		ascii      = "*",
		color      = LIGHTRED,
		sprite     = SPRITE_PLASMASHOT,
		delay      = 30,
		miss_base  = 50,
		miss_dist  = 5,
		range      = 5,
		maxrange   = 8,
		expl_delay = 40,
		expl_color = RED,
	}

	register_missile "wolf_mtesla" {
		sound_id    = "wolf_particle",
		ascii      = "-",
		color      = WHITE,
		sprite     = SPRITE_PLASMASHOT,
		delay      = 10,
		miss_base  = 0,
		miss_dist  = 10,
		range      = 7,
		maxrange   = 7,
		flags      = { MF_RAY },
	}
	register_missile "wolf_mparticle" {
		sound_id    = "wolf_particle",
		ascii      = "-",
		color      = LIGHTCYAN,
		sprite     = SPRITE_PLASMASHOT,
		delay      = 10,
		miss_base  = 10,
		miss_dist  = 3,
		maxrange   = 10,
		flags      = { MF_RAY, MF_HARD },
	}
	register_missile "wolf_mleichenfaust" {
		sound_id    = "wolf_leichenfaust",
		ascii      = "é",
		color      = CYAN,
		sprite     = SPRITE_PLASMASHOT,
		delay      = 40,
		miss_base  = 10,
		miss_dist  = 5,
		flags      = { MF_HARD },
	}


	register_missile "blake_mpistol1" {
		sound_id   = "blake_pistol1",
		color      = MULTIYELLOW,
		sprite     = LIGHTGRAY,
		delay      = 14,
		miss_base  = 10,
		miss_dist  = 3,
	}
	register_missile "blake_mpistol2" {
		sound_id   = "blake_pistol2",
		color      = MULTIYELLOW,
		sprite     = SPRITE_SHOT,
		delay      = 14,
		miss_base  = 10,
		miss_dist  = 3,
	}
	register_missile "blake_mrifle1" {
		sound_id   = "blake_rifle1",
		color      = MULTIYELLOW,
		sprite     = SPRITE_SHOT,
		delay      = 30,
		miss_base  = 10,
		miss_dist  = 3,
	}
	register_missile "blake_mrifle2" {
		sound_id   = "blake_rifle2",
		color      = MULTIYELLOW,
		sprite     = SPRITE_SHOT,
		delay      = 30,
		miss_base  = 10,
		miss_dist  = 3,
	}
	register_missile "blake_mbazooka" {
		sound_id   = "blake_bazooka",
		ascii      = "*",
		color      = LIGHTRED,
		sprite     = SPRITE_PLASMASHOT,
		delay      = 30,
		miss_base  = 50,
		miss_dist  = 5,
		range      = 3,
		maxrange   = 6,
		expl_delay = 40,
		expl_color = RED,
		expl_flags = { EFSELFHALF },
	}

end
