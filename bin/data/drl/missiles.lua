function drl.register_missiles()

	register_missile "mgun"
	{
		sound_id   = "pistol",
		color      = LIGHTGRAY,
		sprite     = SPRITE_SHOT,
		hitsprite  = SPRITE_BLAST,
		delay      = 15,
		miss_base  = 10,
		miss_dist  = 3,
	}

	register_missile "mchaingun"
	{
		sound_id   = "chaingun",
		color      = WHITE,
		sprite     = SPRITE_SHOT,
		hitsprite  = SPRITE_BLAST,
		delay      = 10,
		miss_base  = 10,
		miss_dist  = 3,
	}

	register_missile "mplasma"
	{
		sound_id   = "plasma",
		ascii      = "*",
		color      = MULTIBLUE,
		sprite     = SPRITE_PLASMASHOT,
		hitsprite  = SPRITE_BLAST,
		delay      = 10,
		miss_base  = 30,
		miss_dist  = 3,
	}

	register_missile "mrocket"
	{
		sound_id   = "bazooka",
		color      = BROWN,
		sprite     = SPRITE_ROCKETSHOT,
		hitsprite  = SPRITE_BLAST,
		delay      = 30,
		miss_base  = 30,
		miss_dist  = 5,
		expl_delay = 40,
		expl_color = RED,
	}

	register_missile "mrocketjump"
	{
		sound_id   = "bazooka",
		color      = BROWN,
		sprite     = SPRITE_ROCKETSHOT,
		hitsprite  = SPRITE_BLAST,
		delay      = 30,
		miss_base  = 30,
		miss_dist  = 5,
		flags      = { MF_EXACT },
		range      = 1,
		expl_delay = 40,
		expl_color = RED,
		expl_flags = { EFSELFKNOCKBACK, EFSELFHALF },
	}

	register_missile "mexplround"
	{
		sound_id   = "pistol",
		color      = LIGHTGRAY,
		sprite     = SPRITE_SHOT,
		hitsprite  = SPRITE_BLAST,
		delay      = 15,
		miss_base  = 10,
		miss_dist  = 3,
		expl_delay = 40,
		expl_color = RED,
	}

	register_missile "mexplground"
	{
		sound_id   = "pistol",
		color      = LIGHTGRAY,
		sprite     = SPRITE_SHOT,
		hitsprite  = SPRITE_BLAST,
		delay      = 15,
		miss_base  = 10,
		miss_dist  = 3,
		expl_delay = 40,
		expl_color = GREEN,
	}

	register_missile "mbfg"
	{
		sound_id   = "bfg9000",
		ascii      = "*",
		color      = WHITE,
		sprite     = SPRITE_BFGSHOT,
		hitsprite  = SPRITE_BLAST,
		delay      = 100,
		miss_base  = 50,
		miss_dist  = 10,
		flags      = { MF_EXACT },
		expl_delay = 33,
		expl_color = GREEN,
		expl_flags = { EFSELFSAFE, EFAFTERBLINK, EFCHAIN, EFHALFKNOCK, EFNODISTANCEDROP },
	}

	register_missile "mbfgover"
	{
		sound_id   = "bfg9000",
		ascii      = "*",
		color      = WHITE,
		sprite     = SPRITE_BFGSHOT,
		hitsprite  = SPRITE_BLAST,
		delay      = 200,
		miss_base  = 50,
		miss_dist  = 10,
		flags      = { MF_EXACT },
		expl_delay = 33,
		expl_color = GREEN,
		expl_flags = { EFSELFSAFE, EFAFTERBLINK, EFCHAIN, EFHALFKNOCK, EFNODISTANCEDROP },
	}

	register_missile "mblaster"
	{
		sound_id   = "plasma",
		color      = MULTIYELLOW,
		sprite     = SPRITE_SHOT,
		hitsprite  = SPRITE_BLAST,
		delay      = 10,
		miss_base  = 30,
		miss_dist  = 5,
	}

	register_missile "mknife"
	{
		sound_id   = "knife",
		color      = LIGHTGRAY,
		sprite     = SPRITE_KNIFE,
		hitsprite  = SPRITE_BLAST,
		delay      = 50,
		miss_base  = 10,
		miss_dist  = 3,
		flags      = { MF_EXACT },
		range      = 5,
	}

	register_shotgun "snormal"
	{
		range      = 15,
		spread     = 3,
		reduce     = 0.07,
		hitsprite  = SPRITE_BLAST,
	}

	register_shotgun "swide"
	{
		range      = 8,
		spread     = 3,
		reduce     = 0.1,
		hitsprite  = SPRITE_BLAST,
	}

	register_shotgun "sfocused"
	{
		range      = 15,
		spread     = 2,
		reduce     = 0.05,
		hitsprite  = SPRITE_BLAST,
	}

	register_shotgun "splasma"
	{
		range      = 15,
		spread     = 3,
		reduce     = 0.05,
		hitsprite  = SPRITE_BLAST,
	}
end
