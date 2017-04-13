function DoomRL.loadammo()

	--Ammo management is a big part of wolfrl.  Most exotics and uniques are point in time boosts; you
	--use them until you've expended their ammo, and by then the regular weapon cycle will have caught up.
	--Sprites are an issue.  I am considering whether I want to draw a bunch of sprites or think of a coloring
	--scheme that could do the work.
	register_item "wolf_9mm" {
		name     = "9mm ammo",
		color    = LIGHTGRAY,
		sprite   = SPRITE_9MMAMMO,
		level    = 1,
		weight   = 160,
		desc     = "9mm ammo. The cornerstone of the German war machine.",

		type    = ITEMTYPE_AMMO,
		ammo    = 24,
		ammomax = 100,
	}
	register_item "wolf_45acp" {
		name     = "45 ammo",
		color    = WHITE,
		sprite   = SPRITE_45AMMO,
		level    = 1,
		weight   = 0,
		desc     = ".45 ACP is to the Allies what 9mm is to the Germans.",

		type    = ITEMTYPE_AMMO,
		ammo    = 30,
		ammomax = 80,

	}
	--[[
	--A 30sw/455 break top revolver would be a worse weapon than our 9 and 45s.
	--Supply issues make either one unrealistic and the infamous 'manstopper' 455
	--was both against the hague convention and was really only a competitor in its time.
	--By WW2 it was nothing.  So I don't have a good 'exotic' british pistol.
	register_item "wolf_455c" { 
		name     = "455w ammo",
		color    = WHITE,
		sprite   = SPRITE_WEBAMMO,
		level    = 1,
		weight   = 0,
		desc     = "The Webley manstopper.",

		type    = ITEMTYPE_AMMO,
		ammo    = 30,
		ammomax = 80,
	}
	--]]

	register_item "wolf_8mm" {
		name     = "8mm ammo",
		color    = CYAN,
		sprite   = SPRITE_8MMAMMO,
		level    = 2,
		weight   = 80,
		desc     = "8mm Mauser rifle cartridges, also known as 7.92x57mm.",

		type    = ITEMTYPE_AMMO,
		ammo    = 15,
		ammomax = 30,
	}
	register_item "wolf_3006" {
		name     = "30-06 ammo",
		color    = BLUE,
		sprite   = SPRITE_3006AMMO,
		level    = 2,
		weight   = 0,
		desc     = "30 aught is the rifle round of choice for the Allies.",

		type    = ITEMTYPE_AMMO,
		ammo    = 15,
		ammomax = 30,
	}
	register_item "wolf_303" {
		name     = "303 ammo",
		color    = LIGHTBLUE,
		sprite   = SPRITE_303AMMO,
		level    = 2,
		weight   = 0,
		desc     = "The .303 British is a bit past its prime but a few odd weapons still use it.",

		type    = ITEMTYPE_AMMO,
		ammo    = 15,
		ammomax = 30,

	}

	register_item "wolf_kurz" {
		name     = "7.92mmK ammo",
		color    = LIGHTCYAN,
		sprite   = SPRITE_KURZAMMO,
		level    = 7,
		weight   = 180,
		desc     = "The 7.92x33mm Kurz is quite possibly the first cartridge ever designed with medium range combat in mind.",

		type    = ITEMTYPE_AMMO,
		ammo    = 25,
		ammomax = 50,
	}
	register_item "wolf_30c" {
		name     = "30c ammo",
		color    = YELLOW,
		sprite   = SPRITE_30CAMMO,
		level    = 7,
		weight   = 0,
		desc     = "the .30 Carbine is a nice in-between round used by the Allies.",

		type    = ITEMTYPE_AMMO,
		ammo    = 25,
		ammomax = 50,
	}

	register_item "wolf_fuel" {
		name     = "fuel pack",
		color    = RED,
		sprite   = SPRITE_GASAMMO,
		level    = 4,
		weight   = 0,
		desc     = "Flamethrower fuel. Perfect for a body bonfire.",

		type    = ITEMTYPE_AMMO,
		ammo    = 30,
		ammomax = 60,
	}
	register_item "wolf_rocket" {
		name     = "rocket",
		color    = BROWN,
		sprite   = SPRITE_RLAMMO,
		level    = 5,
		weight   = 360,
		desc     = "Rockets. Heavy, big, and go boom.",

		type    = ITEMTYPE_AMMO,
		ammo    = 3,
		ammomax = 10,
	}
	register_item "wolf_cell" {
		name     = "energy cell",
		color    = GREEN,
		sprite   = SPRITE_CELLAMMO,
		level    = 5,
		weight   = 0,
		desc     = "These energy packs feed various futuristic weapons the Nazis have developed.",

		type    = ITEMTYPE_AMMO,
		ammo    = 100,
		ammomax = 250,
	}

	register_item "wolf_shell" {
		name     = "shotgun shell",
		color    = DARKGRAY,
		sprite   = SPRITE_SHOTAMMO,
		level    = 2,
		weight   = 0,
		desc     = "Buckshot always works well against the unarmored.",

		type    = ITEMTYPE_AMMO,
		ammo    = 25,
		ammomax = 50,
	}

	--Ammo boxes don't fit snugly into Wolf3d with so many ammo types.  I will have to consider ways of adding them.  Possibly only 9mm 8mm kuz and cells?
end

