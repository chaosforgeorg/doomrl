function DoomRL.loaditems()

	-- Melee Items --

	register_item "knife"
	{
		name     = "combat knife",
		color    = WHITE,
		sprite   = SPRITE_KNIFE,
		psprite  = 2,
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 1,
		weight   = 640,
		group    = "weapon-melee",
		desc     = "Not what you'd really like to use, but it's better than your fists.",
		flags    = { IF_BLADE, IF_THROWDROP },

		type        = ITEMTYPE_MELEE,
		damage      = "2d5",
		damagetype  = DAMAGE_MELEE,
		acc         = 1,
		altfire     = ALT_THROW,
		missile     = "mknife",
	}

	-- Armors --

	register_item "garmor"
	{
		name     = "green armor",
		color    = GREEN,
		sprite   = SPRITE_ARMOR,
		coscolor = { 0.0,1.0,0.0,1.0 },
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 1,
		weight   = 400,
		desc     = "Offers little protection, but probably better than none.",

		resist = { bullet   = 15, shrapnel = 15 },

		type       = ITEMTYPE_ARMOR,
		armor      = 1,
		movemod    = -5,
	}

	register_item "barmor"
	{
		name     = "blue armor",
		color    = BLUE,
		sprite   = SPRITE_ARMOR,
		coscolor = { 0.0,0.0,1.0,1.0 },
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 4,
		weight   = 240,
		desc     = "Better than green armor, but it might not be enough.",

		resist = { plasma = 20 },

		type       = ITEMTYPE_ARMOR,
		armor      = 2,
		movemod    = -10,
	}

	register_item "rarmor"
	{
		name     = "red armor",
		color    = RED,
		sprite   = SPRITE_ARMOR,
		coscolor = { 1.0,0.0,0.0,1.0 },
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 9,
		weight   = 150,
		desc     = "Nice, red and shiny. Look out for it, because if it's gone, you're gone too.",

		resist = { fire = 25 },

		type       = ITEMTYPE_ARMOR,
		armor      = 4,
		movemod    = -20,
	}

	register_item "sboots"
	{
		name     = "steel boots",
		color    = WHITE,
		sprite   = SPRITE_SBOOTS,
		coscolor = { 1.0,1.0,1.0,1.0 },
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 4,
		weight   = 240,
		desc     = "Just enough to keep your feet warm, but protection is laughable.",

		type       = ITEMTYPE_BOOTS,
		armor      = 1,
		knockmod   = -10,
		flags      = { IF_PLURALNAME },
	}

	register_item "pboots"
	{
		name     = "protective boots",
		color    = GREEN,
		sprite   = SPRITE_BOOTS,
		coscolor = { 0.0,1.0,0.0,1.0 },
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 7,
		weight   = 150,
		desc     = "May help a little while walking through acid, but lava trips will still be hard.",

		resist = { acid = 25 },

		type       = ITEMTYPE_BOOTS,
		armor      = 2,
		knockmod   = -25,

		flags      = { IF_PLURALNAME },
	}

	register_item "psboots"
	{
		name     = "plasteel boots",
		color    = BLUE,
		sprite   = SPRITE_BOOTS,
		coscolor = { 0.0,0.0,1.0,1.0 },
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 11,
		weight   = 80,
		desc     = "The perfect boots for hazardous terrain.",

		resist = { acid = 50, fire = 25 },

		type       = ITEMTYPE_BOOTS,
		armor      = 2,
		knockmod   = -50,
		flags      = { IF_PLURALNAME },
	}

	-- Powerups --

	register_item "shglobe"
	{
		name     = "Small Health Globe",
		color    = LIGHTRED,
		sprite   = SPRITE_HGLOBE,
		level    = 1,
		weight   = 900,
		flags    = { IF_GLOBE },

		type    = ITEMTYPE_POWER,

		OnPickup = function(self,being)
			being:msg("You feel better.")
			being.tired = false
			being.hp = math.min( being.hp + 10 * diff[DIFFICULTY].powerfactor, 2*being.hpmax )
		end,
	}

	register_item "bpack"
	{
		name     = "Berserk Pack",
		color    = RED,
		sprite   = SPRITE_BERSERK,
		level    = 1,
		weight   = 200,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self,being)
			being:set_affect("berserk",core.power_duration(40))
			if (not being.flags[ BF_NOHEAL ]) and being.hp < being.hpmax then
				being.hp = being.hpmax
			end
			being.tired = false
		end,
	}

	register_item "iglobe"
	{
		name     = "Invulnerability Globe",
		color    = WHITE,
		sprite   = SPRITE_INV,
		level    = 7,
		weight   = 200,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self,being)
			being:set_affect("inv",core.power_duration(50))
			being.tired = false
		end,
	}

	register_item "scglobe"
	{
		name     = "Supercharge Globe",
		color    = LIGHTBLUE ,
		sprite   = SPRITE_SUPERCHARGE,
		level    = 4,
		weight   = 150,
		flags    = { IF_GLOBE },

		type    = ITEMTYPE_POWER,

		OnPickup = function(self,being)
			being:msg("SuperCharge!")
			ui.blink(LIGHTBLUE,100)
			being.hp = 2 * being.hpmax
			being.tired = false
		end,
	}

	register_item "lhglobe"
	{
		name     = "Large Health Globe",
		color    = RED,
		sprite   = SPRITE_LHGLOBE,
		level    = 6,
		weight   = 330,
		flags    = { IF_GLOBE },

		type    = ITEMTYPE_POWER,

		OnPickup = function(self,being)
			being:msg("You feel like new!")
			being.tired = false
			being.hp = math.min( being.hp + 10 * diff[DIFFICULTY].powerfactor, 2*being.hpmax )
			if being.hp < being.hpmax then
				being.hp = being.hpmax
			end
		end,
	}

	register_item "msglobe"
	{
		name     = "Megasphere",
		color    = LIGHTMAGENTA,
		sprite   = SPRITE_MEGASPHERE,
		level    = 16,
		weight   = 60,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self,being)
			being:msg("MegaSphere!")
			ui.blink(LIGHTMAGENTA,100)
			if not being.flags[ BF_NOHEAL ] then
				being.hp = 2*being.hpmax
			end
			being.tired = false
			if being.eq.armor then being.eq.armor:fix() end
			if being.eq.boots then being.eq.boots:fix() end
		end,
	}

	register_item "map"
	{
		name     = "Computer Map",
		color    = GREEN,
		sprite   = SPRITE_MAP,
		level    = 1,
		weight   = 200,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self,being)
			being:msg( "Everything seems clear now." )
			ui.blink(WHITE,50)
			for c in area.FULL() do
				local cell = cells[ level.map[ c ] ]
				if cell.flags[ CF_BLOCKMOVE ] or cell.flags[ CF_NOCHANGE ] then
					level.light[ c ][LFEXPLORED] = true
				end
			end
			level.flags[ LF_ITEMSVISIBLE ] = true
			if being.flags[BF_MAPEXPERT] then
				being:msg( "You download tracking data to your PDA." )
				level.flags[ LF_BEINGSVISIBLE ] = true
			end
		end,
	}

	register_item "pmap"
	{
		name     = "Tracking Map",
		color    = LIGHTGREEN,
		sprite   = SPRITE_TMAP,
		level    = 1,
		weight   = 80,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self,being)
			being:msg( "You download tracking data to your PDA." )
			ui.blink(LIGHTGREEN,50)
			for c in area.FULL() do
				local cell = cells[ level.map[ c ] ]
				if cell.flags[ CF_BLOCKMOVE ] or cell.flags[ CF_NOCHANGE ] then
					level.light[ c ][LFEXPLORED] = true
				end
			end
			level.flags[ LF_ITEMSVISIBLE ] = true
			level.flags[ LF_BEINGSVISIBLE ] = true
		end,
	}

	register_item "gpack"
	{
		name     = "Light-Amp Goggles",
		color    = BROWN,
		sprite   = SPRITE_LIGHTAMP,
		level    = 1,
		weight   = 80,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self,being)
			being:set_affect("light",core.power_duration(60))
		end,
	}

	register_item "backpack"
	{
		name     = "Backpack",
		color    = BROWN,
		sprite   = SPRITE_BACKPACK,
		glow     = { 1.0,1.0,0.0,1.0 },
		level    = 200,
		weight   = 0,
		firstmsg = "Duh, I'll ditch my junk here.",

		type    = ITEMTYPE_POWER,

		OnPickup = function(self,being)
			if being.flags[ BF_BACKPACK ] then
				ui.msg("Another backpack? Who needs two anyway.")
				return
			end
			ui.msg("BackPack!")
			ui.blink(YELLOW,50)
			being:power_backpack()
		end,
	}

	register_item "ashard"
	{
		name     = "armor shard",
		color    = YELLOW,
		sprite   = SPRITE_SHARD,
		level    = 5,
		weight   = 700,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self,being)
			local armor = being.eq.armor
			local boots = being.eq.boots
			if not armor and not boots then
				being:msg( "You have no armor to fix! Nothing happens." )
				return
			end
			local damaged_armor = armor and armor:is_damaged()
			local damaged_boots = boots and boots:is_damaged()
			if not damaged_armor and not damaged_boots then
				being:msg( "You have no armor that needs fixing! Nothing happens." )
				return
			end
			ui.blink( YELLOW, 20 )
			if damaged_armor then
				if armor:fix(25*diff[DIFFICULTY].powerfactor) then
					being:msg( "Your armor looks like new!" )
				else
					being:msg( "Your armor looks better!" )
				end
			end
			if damaged_boots then
				if boots:fix(10*diff[DIFFICULTY].powerfactor) then
					being:msg( "Your boots look like new!" )
				else
					being:msg( "Your boots look better!" )
				end
			end
		end,
	}

	-- Ammo --

	register_item "ammo"
	{
		name     = "10mm ammo",
		color    = LIGHTGRAY,
		sprite   = SPRITE_AMMO,
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 1,
		weight   = 500,
		desc     = "10mm ammo, the backbone of your firepower.",

		type    = ITEMTYPE_AMMO,
		ammo    = 24,
		ammomax = 100,
	}

	register_item "shell"
	{
		name     = "shotgun shell",
		color    = DARKGRAY,
		sprite   = SPRITE_SHELL,
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 2,
		weight   = 700,
		desc     = "Food for your trusty shotguns.",

		type    = ITEMTYPE_AMMO,
		ammo    = 8,
		ammomax = 50,
	}

	register_item "rocket"
	{
		name     = "rocket",
		color    = BROWN,
		sprite   = SPRITE_ROCKET,
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 5,
		weight   = 400,
		desc     = "Rockets -- heavy, big and go boom.",

		type    = ITEMTYPE_AMMO,
		ammo    = 3,
		ammomax = 10,
	}

	register_item "cell"
	{
		name     = "power cell",
		color    = CYAN,
		sprite   = SPRITE_CELL,
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 8,
		weight   = 200,
		desc     = "Power cells, the peak of monster frying technology.",

		type    = ITEMTYPE_AMMO,
		ammo    = 20,
		ammomax = 50,
	}

	register_item "pammo"
	{
		name     = "10mm ammo chain",
		color    = LIGHTGRAY,
		sprite   = SPRITE_PAMMO,
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 3,
		weight   = 60,
		desc     = "That reminds you about action films you've seen long ago.",

		type    = ITEMTYPE_AMMOPACK,
		ammo    = 250,
		ammomax = 250,
		ammo_id = "ammo",
	}

	register_item "pshell"
	{
		name     = "shell box",
		color    = DARKGRAY,
		sprite   = SPRITE_PSHELL,
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 4,
		weight   = 60,
		desc     = "Packed shells, like sardines!",

		type    = ITEMTYPE_AMMOPACK,
		ammo    = 100,
		ammomax = 100,
		ammo_id = "shell",
	}

	register_item "procket"
	{
		name     = "rocket box",
		color    = BROWN,
		sprite   = SPRITE_PROCKET,
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 7,
		weight   = 36,
		desc     = "Now this is the REAL 'boombox'!",

		type    = ITEMTYPE_AMMOPACK,
		ammo    = 20,
		ammomax = 20,
		ammo_id = "rocket",
	}

	register_item "pcell"
	{
		name     = "power battery",
		color    = CYAN,
		sprite   = SPRITE_PCELL,
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 10,
		weight   = 18,
		--desc     = "Ampere-hours of pure energy!",
		desc     = "Joules of energetic fun!",

		type    = ITEMTYPE_AMMOPACK,
		ammo    = 120,
		ammomax = 120,
		ammo_id = "cell",
	}

	-- Ranged  weapons --

	register_item "pistol"
	{
		name     = "pistol",
		color    = LIGHTGRAY,
		sprite   = SPRITE_PISTOL,
		psprite  = SPRITE_PLAYER_PISTOL,
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 1,
		weight   = 70,
		group    = "weapon-pistol",
		desc     = "Your trusty 10mm pistol. It may be nice, but better find something stronger.",
		flags    = { IF_PISTOL },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "ammo",
		ammomax       = 6,
		damage        = "2d4",
		damagetype    = DAMAGE_BULLET,
		acc           = 4,
		fire          = 10,
		reload        = 12,
		altfire       = ALT_AIMED,
		altreload     = RELOAD_DUAL,
		missile       = "mgun",
	}

	register_item "shotgun"
	{
		name     = "shotgun",
		color    = DARKGRAY,
		sprite   = SPRITE_SHOTGUN,
		psprite  = SPRITE_PLAYER_SHOTGUN,
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 2,
		weight   = 150,
		group    = "weapon-shotgun",
		desc     = "A 12g shotgun -- you gotta love its spread.",
		firstmsg = "Just what I needed!",
		flags    = { IF_SHOTGUN },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "shell",
		ammomax       = 1,
		damage        = "8d3",
		damagetype    = DAMAGE_SHARPNEL,
		fire          = 10,
		reload        = 10,
		missile       = "snormal",
	}

	register_item "dshotgun"
	{
		name     = "double shotgun",
		color    = WHITE,
		sprite   = SPRITE_DSHOTGUN,
		psprite  = SPRITE_PLAYER_DSHOTGUN,
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 4,
		weight   = 100,
		group    = "weapon-shotgun",
		desc     = "Double barreled shotgun -- the perfect weapon for a desperado.",
		firstmsg = "Now THIS is what I call a shotgun!",
		flags    = { IF_SHOTGUN, IF_DUALSHOTGUN },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "shell",
		ammomax       = 2,
		damage        = "9d3",
		damagetype    = DAMAGE_SHARPNEL,
		fire          = 10,
		reload        = 20,
		shots         = 2,
		altfire       = ALT_SINGLE,
		altreload     = RELOAD_SINGLE,
		missile       = "swide",
	}

	register_item "ashotgun"
	{
		name     = "combat shotgun",
		color    = LIGHTBLUE,
		sprite   = SPRITE_CSHOTGUN,
		psprite  = SPRITE_PLAYER_CSHOTGUN,
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 6,
		weight   = 200,
		group    = "weapon-shotgun",
		desc     = "Nothing beats the sound of pumping a combat shotgun.",
		firstmsg = "Pump'n'roll!",
		flags    = { IF_SHOTGUN, IF_PUMPACTION, IF_SINGLERELOAD },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "shell",
		ammomax       = 5,
		damage        = "7d3",
		damagetype    = DAMAGE_SHARPNEL,
		fire          = 10,
		reload        = 10,
		altreload     = RELOAD_FULL,
		missile       = "sfocused",
	}

	register_item "bazooka"
	{
		name     = "rocket launcher",
		color    = BROWN,
		sprite   = SPRITE_BAZOOKA,
		psprite  = SPRITE_PLAYER_BAZOOKA,
		--glow     = { 1.0,1.0,1.0,1.0 },
		level    = 7,
		weight   = 200,
		group    = "weapon-rocket",
		desc     = "The rocket launcher is the most standard way of blowing things up.",
		firstmsg = "Ride my rocket baby!",

		type          = ITEMTYPE_RANGED,
		ammo_id       = "rocket",
		ammomax       = 1,
		damage        = "6d6",
		damagetype    = DAMAGE_FIRE,
		acc           = 4,
		fire          = 10,
		radius        = 4,
		reload        = 15,
		altfire       = ALT_SCRIPT,
		altfirename   = "rocketjump",
		missile       = "mrocket",
		flags         = { IF_ROCKET },

		OnAltFire = function( self, being )
			self.missile = missiles[ "mrocketjump" ].nid
			return true
		end,

		OnFire = function( self, being )
			self.missile = missiles[ "mrocket" ].nid
			return true
		end,
	}

	register_item "chaingun"
	{
		name     = "chaingun",
		color    = LIGHTRED,
		level    = 5,
		weight   = 200,
		psprite  = SPRITE_PLAYER_CHAINGUN,
		sprite   = SPRITE_CHAINGUN,
		--glow     = { 1.0,1.0,1.0,1.0 },
		group    = "weapon-chain",
		desc     = "Chaingun directs heavy firepower into your opponent making him do the chaingun cha-cha.",
		firstmsg = "Phobos ReLEADed, oh yeah!",

		type          = ITEMTYPE_RANGED,
		ammo_id       = "ammo",
		ammomax       = 40,
		damage        = "1d6",
		damagetype    = DAMAGE_BULLET,
		acc           = 2,
		fire          = 10,
		reload        = 25,
		shots         = 4,
		altfire       = ALT_CHAIN,
		missile       = "mchaingun",
	}

	register_item "plasma"
	{
		name     = "plasma rifle",
		color    = CYAN,
		level    = 12,
		weight   = 70,
		psprite  = SPRITE_PLAYER_PLASMA,
		sprite   = SPRITE_PLASMA,
		--glow     = { 1.0,1.0,1.0,1.0 },
		group    = "weapon-plasma",
		desc     = "A plasma rifle shoots multiple rounds of plasma energy -- frying some demon butt!",
		firstmsg = "Peace through superior firepower!",

		type          = ITEMTYPE_RANGED,
		ammo_id       = "cell",
		ammomax       = 40,
		damage        = "1d7",
		damagetype    = DAMAGE_PLASMA,
		acc           = 2,
		fire          = 10,
		reload        = 20,
		shots         = 6,
		altfire       = ALT_CHAIN,
		altreload     = RELOAD_SCRIPT,
		altreloadname = "overcharge",
		missile       = "mplasma",

		OnAltReload = function(self)
			if not self:can_overcharge("This will destroy the weapon after the next shot...") then return false end
			self.shots         = self.shots * 2
			self.ammomax       = self.shots
			self.ammo          = self.shots
			self.damage_sides  = self.damage_sides + 1
			self.altfire       = ALT_NONE
			return true
		end,
	}

	-- Packs --

	register_item "smed"
	{
		name     = "small med-pack",
		ascii    = "+",
		color    = LIGHTRED,
		sprite   = SPRITE_MEDPACK,
		level    = 1,
		weight   = 600,
		desc     = "Great to treat a few burns; for major injuries, better find its larger cousin.",
		flags    = { IF_AIHEALPACK },

		type       = ITEMTYPE_PACK,

		OnUse = function(self,being)
			local isPlayer = being:is_player()
			if being.flags[ BF_NOHEAL ] then
				being:msg("Nothing happens.")
			else
				if isPlayer then being.tired = false end
				if being.hp >= being.hpmax * 2 or ( not being.flags[ BF_MEDPLUS ] and being.hp >= being.hpmax ) then
					being:msg("Nothing happens.")
					return true
				end
				local heal = (being.hpmax * diff[DIFFICULTY].powerfactor) / 4 + 2
				being.hp = math.min( being.hp + heal, being.hpmax * 2 )
				if not being.flags[ BF_MEDPLUS ] then being.hp = math.min( being.hp, being.hpmax ) end
				being:msg("You feel healed.",being:get_name(true,true).." looks healthier!")
			end
			return true
		end,
	}

	register_item "lmed"
	{
		name     = "large med-pack",
		ascii    = "+",
		color    = RED,
		sprite   = SPRITE_LMEDPACK,
		level    = 5,
		weight   = 400,
		desc     = "Your savior in times of need.",
		flags    = { IF_AIHEALPACK },

		type       = ITEMTYPE_PACK,

		OnUse = function(self,being)
			local isPlayer = being:is_player()
			if being.flags[ BF_NOHEAL ] then
				being:msg("Nothing happens.")
			else
				if isPlayer then being.tired = false end
				if being.hp >= being.hpmax * 2 or ( not being.flags[ BF_MEDPLUS ] and being.hp >= being.hpmax ) then
					being:msg("Nothing happens.")
					return true
				end
				being.hp = math.min( being.hp + (being.hpmax * diff[DIFFICULTY].powerfactor) / 2 + 2, being.hpmax * 2)
				being.hp = math.max( being.hp, being.hpmax )
				if not being.flags[ BF_MEDPLUS ] then being.hp = math.min( being.hp, being.hpmax ) end
				being:msg("You feel fully healed.",being:get_name(true,true).." looks a lot healthier!")
			end
			return true
		end,
	}

	register_item "phase"
	{
		name     = "phase device",
		ascii    = "+",
		color    = BLUE,
		sprite   = SPRITE_PHASE,
		coscolor = { 0.0,0.0,0.7,1.0 },
		level    = 5,
		weight   = 200,
		desc     = "Experimental technology -- might save you from a tight spot. Not always though.",
		flags    = { IF_AIHEALPACK },

		type       = ITEMTYPE_PACK,

		OnUse = function(self,being)
			being:play_sound("soldier.phase")
			being:msg("You feel yanked in a non-existing direction!","Suddenly "..being:get_name(true,false).." blinks away!")
			level:explosion( being.position, 2, 50, 0, 0, LIGHTBLUE )
			being:phase()
			level:explosion( being.position, 1, 50, 0, 0, LIGHTBLUE )
			being:msg(nil,"Suddenly "..being:get_name(false,false).." appears out of nowhere!")
			return true
		end,
	}

	register_item "hphase"
	{
		name     = "homing phase device",
		ascii    = "+",
		color    = LIGHTBLUE,
		level    = 7,
		weight   = 100,
		sprite   = SPRITE_PHASE,
		coscolor = { 0.3,0.3,1.0,1.0 },
		desc = "This upgraded phase device will definitely save your skin.",
		flags    = { IF_AIHEALPACK },

		type       = ITEMTYPE_PACK,

		OnUse = function(self,being)
			being:play_sound("soldier.phase")
			being:msg("You feel yanked in a non-existing direction!","Suddenly "..being:get_name(true,false).." blinks away!")
			level:explosion( being.position, 2, 50, 0, 0, GREEN )
			if level.flags[ LF_NOHOMING ] then
				being:phase()
			else
				being:phase( "stairs" )
			end
			level:explosion( being.position, 1, 50, 0, 0, GREEN )
			being:msg(nil,"Suddenly "..being:get_name(false,false).." appears out of nowhere!")
			return true
		end,
	}

	register_item "epack"
	{
		name     = "envirosuit pack",
		ascii    = "+",
		color    = GREEN,
		sprite   = SPRITE_ENVIRO,
		level    = 5,
		weight   = 100,
		desc     = "Planning a lava bath? You'll definitely need this.",

		type = ITEMTYPE_PACK,

		OnUse = function(self,being)
			if being:is_player() then
				being:set_affect("enviro",core.power_duration(70))
			end
			return true
		end,
	}

	register_item "nuke"
	{
		name     = "thermonuclear bomb",
		ascii    = "%",
		color    = LIGHTBLUE,
		level    = 10,
		weight   = 40,
		sprite   = SPRITE_NUKE,
		desc     = "Cool firepower, but how will you save yourself?",
		firstmsg = "\"Handle with care\"... WTF?",
		flags    = {},

		type       = ITEMTYPE_PACK,

		OnUse = function(self,being)
			if being:is_player() then
				if level.flags[ LF_NONUKE ] then
					ui.msg('You arm the thermonuclear bomb and step aside... but nothing happens!');
					return true
				end
				if being.flags[ BF_IMPATIENT ] then
					ui.msg("They told you so many times that patience is a virtue..")
				end
				local floor = level.map[ being.position ]
				if floor == "acid" or floor == "lava" then
					-- Added to make it sound less idiotic when invulnerable
					if not being:is_affect("inv") then
						ui.msg('Somehow, in an instant, you feel like an idiot...');
					end
					being:nuke(1)
					return true
				end
				ui.msg("Warning! Explosion in 10 seconds!")
				being:nuke(100)
			end
			return true
		end,

		OnUseCheck = function(self,being)
			if being.nuketime > 0 then
				ui.msg('ARE YOU OUT OF YOUR MIND???');
				return false
			end
			local floor = level.map[ being.position ]
			if floor == "stairs" or floor == "ystairs" or floor == "rstairs" then
				ui.msg('This thing is huge, better not block the stairs with it...');
				return false
			end
			if not ui.msg_confirm('Are you sure you want activate the thermonuclear bomb?', true) then
				ui.msg('Ufff... I knew you were a reasonable person.');
				return false
			end
			being:add_history('He nuked level @1!')
			return true
		end,
	}

	-- Mods --

	register_item "mod_power"
	{
		name     = "power mod pack",
		ascii    = "\"",
		color    = LIGHTRED,
		sprite   = SPRITE_MOD,
		coscolor = { 1.0,0.0,0.0,1.0 },
		level    = 7,
		weight   = 120,		
		desc     = "Power modification kit -- increases weapon damage or armor protection.",

		type       = ITEMTYPE_PACK,
		mod_letter = "P",

		OnUseCheck = function(self,being)
			local item, result = being:pick_mod_item('P',being.techbonus)
			if not result then return false end
			if item ~= nil then self:add_property("chosen_item", item) end
			return true
		end,

		OnUse = function(self,being)
			if not self:has_property("chosen_item") then return true end
			local item = self.chosen_item
			if item.itype == ITEMTYPE_MELEE then
				item.damage_sides = item.damage_sides + 1
			elseif item.itype == ITEMTYPE_RANGED then
				if item.damage_sides >= item.damage_dice then
					item.damage_sides = item.damage_sides + 1
				else
					item.damage_dice = item.damage_dice + 1
				end
			elseif item.itype == ITEMTYPE_ARMOR then
				item.armor = item.armor + 2
			elseif item.itype == ITEMTYPE_BOOTS then
				item.armor = item.armor * 2
			end
			item:add_mod('P')
			return true
		end,
	}

	register_item "mod_tech"
	{
		name     = "technical mod pack",
		ascii    = "\"",
		color    = YELLOW,
		sprite   = SPRITE_MOD,
		coscolor = { 1.0,1.0,0.0,1.0 },
		level    = 5,
		weight   = 120,
		desc     = "Technical modification kit -- decreases fire time for weapons, or increases armor knockback resistance.",

		type       = ITEMTYPE_PACK,
		mod_letter = "T",

		OnUseCheck = function(self,being)
			local item, result = being:pick_mod_item('T',being.techbonus)
			if not result then return false end
			if item ~= nil then self:add_property("chosen_item", item) end
			return true
		end,

		OnUse = function(self,being)
			if not self:has_property("chosen_item") then return true end
			local item = self.chosen_item
			if (item.itype == ITEMTYPE_RANGED) or (item.itype == ITEMTYPE_MELEE) then
				item.usetime = item.usetime * 0.85
			elseif item.itype == ITEMTYPE_ARMOR or item.itype == ITEMTYPE_BOOTS then
				item.knockmod = item.knockmod - 25
			end
			item:add_mod('T')
			return true
		end,
	}

	register_item "mod_agility"
	{
		name     = "agility mod pack",
		ascii    = "\"",
		color    = LIGHTCYAN,
		weight   = 120,
		coscolor = { 0.0,1.0,1.0,1.0 },
		level    = 6,
		sprite   = SPRITE_MOD,
		desc     = "Agility modification kit -- increases weapon accuracy or quickens armor move speed modifier.",

		type       = ITEMTYPE_PACK,
		mod_letter = "A",

		OnUseCheck = function(self,being)
			local item, result = being:pick_mod_item('A',being.techbonus)
			if not result then return false end
			if item ~= nil then self:add_property("chosen_item", item) end
			return true
		end,

		OnUse = function(self,being)
			if not self:has_property("chosen_item") then return true end
			local item = self.chosen_item
			if item.itype == ITEMTYPE_MELEE or item.itype == ITEMTYPE_RANGED then
				item.acc = item.acc + 1
			elseif item.itype == ITEMTYPE_ARMOR then
				item.movemod = item.movemod + 15
			elseif item.itype == ITEMTYPE_BOOTS then
				item.movemod = item.movemod + 10
			end
			item:add_mod('A')
			-- A little easter egg for applying A-mod on shotgun
			if item.flags[ IF_SHOTGUN ] then
				ui.msg( "You suddenly feel a little silly." )
			end
			return true
		end,
	}

	register_item "mod_bulk"
	{
		name     = "bulk mod pack",
		ascii    = "\"",
		color    = LIGHTBLUE,
		sprite   = SPRITE_MOD,
		coscolor = { 0.0,0.0,1.0,1.0 },
		level    = 6,
		weight   = 120,
		desc     = "Bulk modification kit -- increases weapon magazine for magazine weapons, decreases reload time for single-shot weapons, or increases armor durability. For melee weapons it increases the damage done.",

		type       = ITEMTYPE_PACK,
		mod_letter = "B",

		OnUseCheck = function(self,being)
			local item, result = being:pick_mod_item('B',being.techbonus)
			if not result then return false end
			if item ~= nil then self:add_property("chosen_item", item) end
			return true
		end,

		OnUse = function(self,being)
			if not self:has_property("chosen_item") then return true end
			local item = self.chosen_item
			if item.itype == ITEMTYPE_MELEE then
				item.damage_dice = item.damage_dice + 1
			elseif item.itype == ITEMTYPE_RANGED then
				if item.ammomax < 3 then
					item.reloadtime = item.reloadtime * 0.75
				else
					item.ammomax = item.ammomax * 1.3
				end
			elseif item.itype == ITEMTYPE_ARMOR or item.itype == ITEMTYPE_BOOTS then
				item.durability    = item.durability + 100
				item.maxdurability = item.maxdurability + 100
				item.movemod = item.movemod - 10
			end
			item:add_mod('B')
			return true
		end,
	}

	-- levers --

	register_item "lever_flood_water"
	{
		name     = "lever",
		color_id = "lever",
		color    = WHITE,
		sprite   = SPRITE_LEVER,
		weight   = 0,

		type       = ITEMTYPE_LEVER,
		good       = "neutral",
		desc       = "floods with water",
		warning    = "The air is really humid here...",
		fullchance = 50,

		OnCreate = function(self)
			self:add_property( "target_area", area.FULL_SHRINKED:clone() )
		end,

		OnUse = function(self,being)
			ui.msg("Suddenly water starts gushing from the ground!")
			level:flood( "water", self.target_area )
			return true
		end,
	}

	register_item "lever_flood_acid"
	{
		name     = "lever",
		color_id = "lever",
		color    = WHITE,
		sprite   = SPRITE_LEVER,
		weight   = 0,

		type       = ITEMTYPE_LEVER,
		good       = "dangerous",
		desc       = "floods with acid",
		warning    = "In the State of Denmark there was the odor of decay...",
		fullchance = 10,

		OnCreate = function(self)
			self:add_property( "target_area", area.FULL_SHRINKED:clone() )
		end,

		OnUse = function(self,being)
			if self.target_area:size() >= area.FULL_SHRINKED:size() then
				-- Really?  Censoring "f***" when the plot has it?
				ui.msg("WTF?! Acid splashes everywhere!")
				being:add_history("He flooded the entire level @1 with acid!")
			else
				ui.msg("Green acid covers the floor!")
			end
			level:flood( "acid", self.target_area )
			return true
		end,
	}

	register_item "lever_flood_lava"
	{
		name     = "lever",
		color    = WHITE,
		sprite   = SPRITE_LEVER,
		weight   = 0,
		color_id = "lever",

		type       = ITEMTYPE_LEVER,
		good       = "dangerous",
		desc       = "floods with lava",
		warning    = "You feel that smell? That gasoline smell? Oh hell...",
		fullchance = 10,

		OnCreate = function(self)
			self:add_property( "target_area", area.FULL_SHRINKED:clone() )
		end,

		OnUse = function(self,being)
			if self.target_area:size() >= area.FULL_SHRINKED:size() then
				ui.msg("Oh shit... oh shit... OH SHIT!!!!")
				being:add_history("He flooded the entire level @1 with lava!")
			else
				ui.msg("The ground explodes in flames!")
			end
			level:flood( "lava", self.target_area )
			return true
		end,
	}

	register_item "lever_kill"
	{
		name     = "lever",
		color    = WHITE,
		sprite   = SPRITE_LEVER,
		weight   = 0,
		color_id = "lever",

		type       = ITEMTYPE_LEVER,
		good       = "beneficial",
		desc       = "harms creatures",
		warning    = "The smell of a massacre...",
		fullchance = 33,

		OnCreate = function(self)
			self:add_property( "target_area", area.FULL_SHRINKED:clone() )
		end,

		OnUse = function(self,being)
			for c in self.target_area() do
				local target = level:get_being(c)
				if target and not target:is_player() then
					target:apply_damage( 20, TARGET_INTERNAL, DAMAGE_FIRE, nil )
				end
			end
			ui.msg("The smell of blood surrounds you!")
			return true
		end,
	}

	register_item "lever_explode"
	{
		name     = "lever",
		color    = WHITE,
		sprite   = SPRITE_LEVER,
		weight   = 0,
		color_id = "lever",

		type       = ITEMTYPE_LEVER,
		good       = "neutral",
		desc       = "forces explosions",
		fullchance = 100,

		OnCreate = function(self)
			self:add_property( "target_area", area.FULL_SHRINKED:clone() )
		end,

		OnUse = function(self,being)
			local position = self.position
			for c in self.target_area() do
				local tile = cells[ level.map[c] ]
				local is_barrel = tile.id == "barrel" or tile.id == "barrela" or tile.id == "barreln"
				if is_barrel and tile.OnDestroy then
					level.map[c] = "floor"
					tile.OnDestroy(c)
				end
			end
			return true
		end,
	}

	register_item "lever_walls"
	{
		name     = "lever",
		color    = WHITE,
		sprite   = SPRITE_LEVER,
		weight   = 0,
		color_id = "lever",

		type       = ITEMTYPE_LEVER,
		good       = "dangerous",
		desc       = "destroys walls",
		warning    = "You hear the trumpets of Jericho echoing in the distance...",
		fullchance = 33,

		OnCreate = function(self)
			self:add_property( "target_area", area.FULL_SHRINKED:clone() )
		end,

		OnUse = function(self,being)
			local room = self.target_area:clamped( area.FULL_SHRINKED )
			for c in room() do
				local tile = cells[level.map[c]]
				if tile.set == CELLSET_WALLS then
					level.map[c] = generator.styles[ level.style ].floor
					level.light[c][LFPERMANENT] = false
				end
			end
			ui.msg("The walls explode!")
			return true
		end,
	}

	register_item "lever_summon"
	{
		name     = "lever",
		color    = WHITE,
		sprite   = SPRITE_LEVER,
		weight   = 0,
		color_id = "lever",

		type       = ITEMTYPE_LEVER,
		good       = "dangerous",
		desc       = "summons enemies",

		OnCreate = function(self)
			self:add_property( "charges", math.random(3) )
			self:add_property( "target_area", area.FULL_SHRINKED:clone() )
		end,

		OnUseCheck = function( self )
			if self.charges == 0 then
				ui.msg("Nothing happens.")
				return false
			end
			return true
		end,

		OnUse = function(self,being)
			local amount = math.random(4)+1
			local list   = level:get_being_table( level.danger_level, nil, { is_group = false } )
			for c = 1,amount do
				being:spawn( list:roll().id )
			end
			self.charges = self.charges - 1
			return self.charges == 0
		end,
	}

	register_item "lever_repair"
	{
		name     = "lever",
		color    = WHITE,
		sprite   = SPRITE_LEVER,
		weight   = 0,
		color_id = "lever",

		type       = ITEMTYPE_LEVER,
		good       = "beneficial",
		desc       = "Armor depot",

		OnCreate = function(self)
			self:add_property( "charges", math.random(3) )
		end,

		OnUseCheck = function(self,being)
			ui.msg("Armor depot. Proceeding with repair of equipped armor...")
			local armor = being.eq.armor
			local boots = being.eq.boots
			if not armor and not boots then
				ui.msg( "You have no armor to fix! Nothing happens." )
				return false
			end
			local damaged_armor = armor and armor:is_damaged()
			local damaged_boots = boots and boots:is_damaged()
			if not damaged_armor and not damaged_boots then
				ui.msg( "You have no armor that needs fixing! Nothing happens." )
				return false
			end
			return true
		end,

		OnUse = function(self,being)
			local armor = being.eq.armor
			local boots = being.eq.boots
			local damaged_armor = armor and armor:is_damaged()
			local damaged_boots = boots and boots:is_damaged()
			self.charges = self.charges - 1
			ui.blink( YELLOW, 20 )
			if damaged_armor then
				if armor:fix(25) then
					ui.msg( "Your armor looks like new!" )
				else
					ui.msg( "Your armor looks better!" )
				end
			end
			if damaged_boots then
				if boots:fix(25) then
					ui.msg( "Your boots look like new!" )
				else
					ui.msg( "Your boots look better!" )
				end
			end
			return self.charges == 0
		end,
	}

	register_item "lever_medical"
	{
		name     = "lever",
		color    = WHITE,
		sprite   = SPRITE_LEVER,
		weight   = 0,
		color_id = "lever",

		type       = ITEMTYPE_LEVER,
		good       = "beneficial",
		desc       = "MediTech depot",

		OnCreate = function( self )
			self:add_property( "charges", math.random(3) )
		end,

		OnUseCheck = function(self,being)
			if being.flags[ BF_NOHEAL] then
				ui.msg("Nothing happens.")
				return false
			end
			if being.hp >= being.hpmax then
				ui.msg("MediTech depot. Proceeding with treatment...")
				ui.msg("You are at full health. Nothing happens.")
				return false
			end
			return true
		end,

		OnUse = function(self,being)
			ui.msg("MediTech depot. Proceeding with treatment...")
			being.tired = false
			self.charges = self.charges - 1
			local heal = (being.hpmax * diff[DIFFICULTY].powerfactor) / 4 + 2
			being.hp = math.min( being.hp + heal,being.hpmax )
			ui.msg("You feel healed.")
			return self.charges == 0
		end,
	}

	register_item "schematic_0"
	{
		name     = "schematics",
		color    = LIGHTGREEN,
		sprite   = SPRITE_SCHEMATIC,
		level    = 9999,
		weight   = 3,

		type    = ITEMTYPE_POWER,
		slevel  = 0,

		OnPickup = function(self,being)
			ui.blink(LIGHTGREEN,100)
			player:add_assembly(mod_arrays[self.ammo].id)
			ui.msg_enter("You suddenly know how to assemble "..mod_arrays[self.ammo].name.."!")
		end,
	}

	register_item "schematic_1"
	{
		name     = "schematics",
		color    = LIGHTGREEN,
		sprite   = SPRITE_SCHEMATIC,
		level    = 9999,
		weight   = 2,

		type    = ITEMTYPE_POWER,
		slevel  = 1,

		OnPickup = function(self,being)
			ui.blink(LIGHTGREEN,100)
			player:add_assembly(mod_arrays[self.ammo].id)
			ui.msg_enter("You suddenly know how to assemble "..mod_arrays[self.ammo].name.."!")
		end,
	}

	register_item "schematic_2"
	{
		name     = "schematics",
		color    = LIGHTGREEN,
		sprite   = SPRITE_SCHEMATIC,
		level    = 9999,
		weight   = 1,

		type    = ITEMTYPE_POWER,
		slevel  = 2,

		OnPickup = function(self,being)
			ui.blink(LIGHTGREEN,100)
			player:add_assembly(mod_arrays[self.ammo].id)
			ui.msg_enter("You suddenly know how to assemble "..mod_arrays[self.ammo].name.."!")
		end,
	}


	register_item "lava_element"
	{
		name   = "lava element",
		color  = WHITE,
		level  = 200,
		sprite = SPRITE_LAVAINV,
		weight = 0,
		type   = ITEMTYPE_PACK,
		ascii  = "+",
		flags  = { IF_NODESTROY },
		desc   = "A strange ball of shimmering light.",

		OnUse = function(self,being)
			if being:is_player() then
				being:play_sound("soldier.phase")
				being:set_affect("inv",core.power_duration(9))
			end
			return true
		end,
	}
end
