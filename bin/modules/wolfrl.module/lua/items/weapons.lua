function DoomRL.loadweapons()

	--[[German weapons are common.
	  British and American weapons are exotic.
	  Uniques are probably going to be weird things from other Wolf titles.

	  In a game, balance is more important than accuracy.
	  For that reason most fully automatic weapons are weaker than single shot
	  weapons.  Let's just assume that it's a built in 'recoil' penalty.
	  Balance also means that the German weapons get gimped a little bit in favor
	  of the exotics.  Let's say that's because BJ's more familiar with them.
	  Ammunition is a tricky point here; I'm not so crude as to make all weapons
	  accept 'ammo' or some equally poor substitute, but it's not reasonable to
	  assume a nazi fortress is going to be loaded with 303s..

	  There are a few ways around this:
	  Make all ammo types spawn at least semi-regularly
	  Try and affect the generator to bias ammo when dropping exotics
	  Treat ammo as rare and spawn 'exotics' with abandon
	  Use special levels to generate guaranteed exotic ammo caches

	  My current design focuses on weapon caches and with weapons being discarded
	  as better models become available.  For this reason biasing the generator
	  and relying on special levels seems a safe bet; you get a bunch of special
	  ammo with the weapon and simply discard it when you run out.

	  Lastly, to better divide our categories: shrapnel damage is used for pistol rounds
	  to give armor a boost, physical is used for the kurz, and plasma for the large rifle
	  rounds.  This gives us armor effectiveness values of 2, 1, and .5 (though this also
	  lets rifle rounds eat through walls--I'll fix it when possible)
	--]]

	--melee
	register_item "wolf_knife" {
		name     = "combat knife",
		color    = WHITE,
		sprite   = SPRITE_KNIFE,
		psprite  = SPRITE_PLAYER_KNIFE,
		level    = 1,
		weight   = 540,
		group    = "weapon-melee",
		desc     = "Some of your best work has been with a knife, but this situation calls for heavier firepower.",
		flags    = { IF_BLADE, IF_THROWDROP },

		type        = ITEMTYPE_MELEE,
		damage      = "2d5",
		damagetype  = DAMAGE_MELEE,
		acc         = 1,
		altfire     = ALT_THROW,
		missile     = "wolf_mknife",
	}
	register_item "wolf_axe" {
		name     = "battle axe",
		color    = CYAN,
		sprite   = SPRITE_SPEAR,
		psprite  = SPRITE_PLAYER_SPEAR,
		level    = 200,
		weight   = 0,
		group    = "weapon-melee",
		desc     = "This belonged to the Axe. Fitting.",
		flags    = { IF_HALFKNOCK },

		type        = ITEMTYPE_MELEE,
		damage      = "5d5",
		damagetype  = DAMAGE_MELEE,
	}
	register_item "wolf_spear" {
		name     = "Longinus Spear",
		color    = YELLOW,
		sprite   = SPRITE_SPEAR,
		psprite  = SPRITE_PLAYER_SPEAR,
	 	glow     = { 1.0,1.0,0.0,1.0 },
		level    = 200,
		weight   = 0,
		group    = "weapon-melee",
		desc     = "Legend says that no one wielding the Spear of Destiny can ever be defeated.",
		flags    = { IF_UNIQUE, IF_HALFKNOCK, IF_NUKERESIST },

		type        = ITEMTYPE_MELEE,
		damage      = "8d8",
		damagetype  = DAMAGE_PLASMA,
		altfire     = ALT_SCRIPT,
		altfirename = "holy flame",

		OnFirstPickup = function(self,being)
			ui.blink( WHITE, 100 )
			ui.msg("You perceive an aura of holiness around this weapon!")
		end,

		OnAltFire = function(self,being)
			if being.tired then
				ui.msg("You are too tired to invoke the Spear!");
			else
				level:explosion( being.position , 3, 50, 10, 10, YELLOW, "soldier.phase", DAMAGE_FIRE, self, { EFSELFSAFE } )
				ui.blink(YELLOW,50)
				ui.blink(WHITE,50)
				being.tired = true
				being.scount = being.scount - 1000
			end
			return false
		end,
	}

	--pistols.  No British pistol included so enjoy two German ones instead.
	register_item "wolf_pistol1" {
		name     = "luger", --German: Luger P08
		color    = LIGHTGRAY,
		sprite   = SPRITE_PISTOL1,
		psprite  = SPRITE_PLAYER_PISTOL,
		level    = 1,
		weight   = 60,
		group    = "weapon-pistol",
		desc     = "A guard's pistol. Quirky, but they get the job done.",
		flags    = { IF_PISTOL },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_9mm",
		ammomax       = 8,
		damage        = "2d4",
		damagetype    = DAMAGE_SHARPNEL,
		acc           = 4,
		fire          = 10,
		reload        = 12,
		altfire       = ALT_AIMED,
		altreload     = RELOAD_DUAL,
		missile       = "wolf_mpistol1",
	}
	register_item "wolf_pistol2" {
		name     = "mauser", --German: Mauser C96 "red 9"
		color    = RED,
		sprite   = SPRITE_PISTOL2,
		psprite  = SPRITE_PLAYER_PISTOL,
		level    = 2,
		weight   = 8,
		group    = "weapon-pistol",
		desc     = "A pistol with an internal box magazine and stock.",
		flags    = { IF_PISTOL, IF_EXOTIC },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_9mm",
		ammomax       = 10,
		damage        = "2d5",
		damagetype    = DAMAGE_SHARPNEL,
		acc           = 5,
		fire          = 11,
		reload        = 14,
		altfire       = ALT_AIMED,
		altreload     = RELOAD_DUAL,
		missile       = "wolf_mpistol2",
	}
	register_item "wolf_pistol3" {
		name     = "walther", --German: Walther P38
		color    = LIGHTGRAY,
		sprite   = SPRITE_PISTOL3,
		psprite  = SPRITE_PLAYER_PISTOL,
		level    = 3,
		weight   = 20,
		group    = "weapon-pistol",
		desc     = "The aging Luger's successor. Officers tend to carry one.",
		flags    = { IF_PISTOL },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_9mm",
		ammomax       = 8,
		damage        = "3d2+1",
		damagetype    = DAMAGE_SHARPNEL,
		acc           = 4,
		fire          = 10,
		reload        = 12,
		altfire       = ALT_AIMED,
		altreload     = RELOAD_DUAL,
		missile       = "wolf_mpistol3",
	}
	register_item "wolf_pistol4" {
		name     = "colt", --American: M1911
		color    = MAGENTA,
		sprite   = SPRITE_PISTOL4,
		psprite  = SPRITE_PLAYER_PISTOL,
		level    = 4,
		weight   = 12,
		group    = "weapon-pistol",
		desc     = "The 1911 fires the powerful .45 round and is an Allied favorite.",
		flags    = { IF_PISTOL, IF_EXOTIC },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_45acp",
		ammomax       = 7,
		damage        = "2d4+1",
		damagetype    = DAMAGE_SHARPNEL,
		acc           = 4,
		fire          = 10,
		reload        = 12,
		altfire       = ALT_AIMED,
		altreload     = RELOAD_DUAL,
		missile       = "wolf_mpistol4",
	}

	--shotguns.  Everything I've read indicates that they were largely unused even by resistance groups.
	register_item "wolf_shotgun" {
		name     = "shotgun",
		color    = DARKGRAY,
		sprite   = SPRITE_SHOTGUN,
		psprite  = SPRITE_PLAYER_SHOTGUN,
		level    = 2,
		weight   = 0,
		group    = "weapon-shotgun",
		desc     = "The humble shotgun may seem out of place in the war but it can still hold its own.",
		flags    = { IF_SHOTGUN, IF_PUMPACTION, IF_SINGLERELOAD },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_shell",
		ammomax       = 6,
		damage        = "8d3",
		damagetype    = DAMAGE_SHARPNEL,
		fire          = 10,
		reload        = 14,
		missile       = "wolf_sfocused",
	}
	register_item "wolf_dshotgun" {
		name     = "double shotgun",
		color    = YELLOW,
		sprite   = SPRITE_DSHOTGUN,
		psprite  = SPRITE_PLAYER_DSHOTGUN,
		level    = 4,
		weight   = 0,
		group    = "weapon-shotgun",
		desc     = "A double barreled breakaway shotgun. Fires twice, takes forever to reload.",
		flags    = { IF_SHOTGUN, IF_DUALSHOTGUN },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_shell",
		ammomax       = 2,
		damage        = "9d3",
		damagetype    = DAMAGE_SHARPNEL,
		fire          = 10,
		reload        = 20,
		shots         = 2,
		altfire       = ALT_SINGLE,
		altreload     = RELOAD_SINGLE,
		missile       = "wolf_snormal",
	}

	--machine pistols
	register_item "wolf_sub1" {
		name     = "machine pistol", --German: MP 40.
		color    = WHITE,
		level    = 5,
		weight   = 80,
		psprite  = SPRITE_PLAYER_CHAINGUN,
		sprite   = SPRITE_SUB1,
		group    = "weapon-sub",
		desc     = "This weapon is easy to handle but lacks both punch and a high rate of fire.",

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_9mm",
		ammomax       = 32,
		damage        = "1d6",
		damagetype    = DAMAGE_BULLET,
		acc           = 2,
		fire          = 10,
		reload        = 15,
		shots         = 3,
		altfire       = ALT_CHAIN,
		missile       = "wolf_msub1",

		OnFirstPickup = function(self,being)
			if not being:is_player() then return end
			being:play_sound(self.id..".pickup1")
		end
	}
	register_item "wolf_sub2" {
		name     = "sten", --British: Sten
		color    = LIGHTMAGENTA,
		level    = 5,
		weight   = 6,
		psprite  = SPRITE_PLAYER_CHAINGUN,
		sprite   = SPRITE_SUB2,
		group    = "weapon-sub",
		desc     = "A cheap weapon with a side mounted magazine.",
		flags    = { IF_EXOTIC },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_9mm",
		ammomax       = 32,
		damage        = "1d7",
		damagetype    = DAMAGE_BULLET,
		acc           = 2,
		fire          = 8,
		reload        = 15,
		shots         = 3,
		altfire       = ALT_CHAIN,
		missile       = "wolf_msub2",
	}
	register_item "wolf_sub3" {
		name     = "grease gun", --American: M3
		color    = LIGHTMAGENTA,
		level    = 5,
		weight   = 8,
		psprite  = SPRITE_PLAYER_CHAINGUN,
		sprite   = SPRITE_SUB3,
		group    = "weapon-sub",
		desc     = "The M3 is a cheap alternative to the Thompson.",
		flags    = { IF_EXOTIC },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_45acp",
		ammomax       = 30,
		damage        = "1d6+1",
		damagetype    = DAMAGE_BULLET,
		acc           = 4,
		fire          = 10,
		reload        = 15,
		shots         = 3,
		altfire       = ALT_CHAIN,
		missile       = "wolf_msub3",
	}
	register_item "wolf_sub4" {
		name     = "thompson", --American: Thompson of course
		color    = LIGHTMAGENTA,
		level    = 7,
		weight   = 8,
		psprite  = SPRITE_PLAYER_CHAINGUN,
		sprite   = SPRITE_SUB4,
		group    = "weapon-sub",
		desc     = "The tommy gun was originally designed for trench warfare. It is a legendary room sweeper.",
		flags    = { IF_EXOTIC },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_45acp",
		ammomax       = 30,
		damage        = "2d4",
		damagetype    = DAMAGE_BULLET,
		acc           = 3,
		fire          = 9,
		reload        = 15,
		shots         = 3,
		altfire       = ALT_CHAIN,
		missile       = "wolf_msub4",
	}

	--bolt action rifles.  Todo: consider OnReload override that replicates the pascal code but with better flavour text.  Possibly add OnFire that checks for nearby beings and decreases accuracy too.
	register_item "wolf_bolt1" {
		name     = "karabiner", --German: Karabiner 98k
		color    = BLUE,
		sprite   = SPRITE_BOLT1,
		psprite  = SPRITE_PLAYER_PLASMA,
		level    = 8,
		weight   = 50,
		group    = "weapon-bolt",
		desc     = "A bolt action rifle. While powerful they aren't quite as useful indoors.",
		flags    = { IF_PUMPACTION },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_8mm",
		ammomax       = 5,
		damage        = "3d4",
		damagetype    = DAMAGE_PLASMA,
		acc           = 6,
		fire          = 14,
		reload        = 17,
		missile       = "wolf_mbolt1",
	}
	register_item "wolf_bolt2" {
		name     = "enfield", --British: Lee-Enfield.  The version is undecided and not really important.
		color    = LIGHTMAGENTA,
		sprite   = SPRITE_BOLT2,
		psprite  = SPRITE_PLAYER_PLASMA,
		level    = 8,
		weight   = 10,
		group    = "weapon-bolt",
		desc     = "This rifle is one of those crazy British designs. Best not to think too much about it.",
		flags    = { IF_PUMPACTION, IF_EXOTIC },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_303",
		ammomax       = 10,
		damage        = "3d5-1",
		damagetype    = DAMAGE_PLASMA,
		acc           = 6,
		fire          = 14,
		reload        = 20,
		missile       = "wolf_mbolt2",
	}
	register_item "wolf_bolt3" {
		name     = "springfield", --American: M1903 Springfield
		color    = LIGHTMAGENTA,
		sprite   = SPRITE_BOLT3,
		psprite  = SPRITE_PLAYER_PLASMA,
		level    = 8,
		weight   = 8,
		group    = "weapon-bolt",
		desc     = "A classic bolt action rifle used by the Americans.",
		flags    = { IF_PUMPACTION, IF_EXOTIC },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_3006",
		ammomax       = 5,
		damage        = "3d5",
		damagetype    = DAMAGE_PLASMA,
		acc           = 6,
		fire          = 14,
		reload        = 17,
		missile       = "wolf_mbolt3",
	}

	--semi-auto rifles
	register_item "wolf_semi1" {
		name     = "gewehr", --German: Gewehr 43
		color    = LIGHTBLUE,
		sprite   = SPRITE_SEMI1,
		psprite  = SPRITE_PLAYER_PLASMA,
		level    = 10,
		weight   = 40,
		group    = "weapon-semi",
		desc     = "The German's most successful semi-automatic rifle. It feels a lot like the Kar98.",
		flags    = { },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_8mm",
		ammomax       = 8,
		damage        = "3d4",
		damagetype    = DAMAGE_PLASMA,
		acc           = 4,
		fire          = 10,
		reload        = 14,
		missile       = "wolf_msemi1",
	}
	register_item "wolf_semi2" {
		name     = "garand", --American: M1 Garand
		color    = LIGHTMAGENTA,
		sprite   = SPRITE_SEMI2,
		psprite  = SPRITE_PLAYER_PLASMA,
		level    = 10,
		weight   = 8,
		group    = "weapon-semi",
		desc     = "The Garand was the first truly widespread semi-auto rifle and is often considered the rifle that won the war.",
		flags    = { IF_EXOTIC, IF_NOUNLOAD },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_3006",
		ammomax       = 8,
		damage        = "3d5",
		damagetype    = DAMAGE_PLASMA,
		acc           = 4,
		fire          = 10,
		reload        = 14,
		missile       = "wolf_msemi2",

		OnReload = function( self, being )
			if self.ammo > 0 then
				being:msg("Burn through the clip first.")
				return false
			end

			return true
		end,
	}
	register_item "wolf_semi3" {
		name     = "carbine", --American: M1 Carbine, I know of no British variant so this gets the special spot at a discount level
		color    = LIGHTMAGENTA,
		sprite   = SPRITE_SEMI3,
		psprite  = SPRITE_PLAYER_PLASMA,
		level    = 7,
		weight   = 8,
		group    = "weapon-semi",
		desc     = "The M1 carbine is a lightweight rifle designed for support roles instead of heavy combat.",
		flags    = { IF_EXOTIC },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_30c",
		ammomax       = 15,
		damage        = "3d4",
		damagetype    = DAMAGE_BULLET,
		acc           = 5,
		fire          = 7,
		reload        = 14,
		missile       = "wolf_msemi3",
	}

	--automatic rifles
	register_item "wolf_auto1" {
		name     = "paratroop rifle", --German: FG 42.  I'd like a better common name; "Fallschirmjagergeweh" doesn't exactly roll off the tongue like sturmgewehr.
		color    = CYAN,
		sprite   = SPRITE_AUTO1,
		psprite  = SPRITE_PLAYER_PLASMA,
		level    = 14,
		weight   = 30,
		group    = "weapon-auto",
		desc     = "An automatic rifle that's very hard to control.",
		flags    = { },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_8mm",
		ammomax       = 20,
		damage        = "2d5",
		damagetype    = DAMAGE_PLASMA,
		acc           = 2,
		fire          = 12,
		reload        = 15,
		shots         = 3,
		missile       = "wolf_mauto1",
	}
	register_item "wolf_auto2" {
		name     = "bren", --British: Bren light machine gun
		color    = LIGHTMAGENTA,
		sprite   = SPRITE_AUTO2,
		psprite  = SPRITE_PLAYER_PLASMA,
		level    = 14,
		weight   = 10,
		group    = "weapon-auto",
		desc     = "Those crazy brits. Putting the magazine on top? Lunacy.",
		flags    = { IF_EXOTIC },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_303",
		ammomax       = 30,
		damage        = "3d4-1",
		damagetype    = DAMAGE_PLASMA,
		acc           = 3,
		fire          = 12,
		reload        = 15,
		shots         = 3,
		missile       = "wolf_mauto2",
	}
	register_item "wolf_auto3" {
		name     = "browning", --American: M1918 Browning Automatic Rifle
		color    = LIGHTMAGENTA,
		sprite   = SPRITE_AUTO3,
		psprite  = SPRITE_PLAYER_PLASMA,
		level    = 14,
		weight   = 8,
		group    = "weapon-auto",
		desc     = "The Browning Automatic Rifle was meant to be used as a light machine gun.",
		flags    = { IF_EXOTIC },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_3006",
		ammomax       = 20,
		damage        = "4d3-1",
		damagetype    = DAMAGE_PLASMA,
		acc           = 3,
		fire          = 12,
		reload        = 15,
		shots         = 3,
		missile       = "wolf_mauto3",
	}

	--assault (two very special weapons go here)
	register_item "wolf_assault1" {
		name     = "sturmgewehr", --German: StG 44
		color    = LIGHTCYAN,
		sprite   = SPRITE_ASSAULT1,
		psprite  = SPRITE_PLAYER_BFG9000,
		level    = 12,
		weight   = 20,
		group    = "weapon-assault",
		desc     = "The Sturmgewehr is the first modern assault rifle and is very effective in medium range combat.",
		flags    = { IF_EXOTIC },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_kurz",
		ammomax       = 30,
		damage        = "3d3",
		damagetype    = DAMAGE_BULLET,
		acc           = 4,
		fire          = 10,
		reload        = 12,
		shots         = 3,
		missile       = "wolf_massault1",
	}
	register_item "wolf_assault2" {
		name     = "chaingun", --Legacy wolfenstein weapon, called the viper in newer games (the justification used though was weak)
		color    = DARKGRAY,
		sprite   = SPRITE_ASSAULT2,
		psprite  = SPRITE_PLAYER_BFG9000,
		level    = 15,
		weight   = 10,
		group    = "weapon-assault",
		desc     = "This weapon must be a small scale prototype of some sort since infantry weapons usually don't have rotating barrels.",
		flags    = { IF_EXOTIC },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_kurz",
		ammomax       = 50,
		damage        = "3d3",
		damagetype    = DAMAGE_BULLET,
		acc           = 2,
		fire          = 13, --you pay for that fifth shot sonny.
		reload        = 25,
		shots         = 5,
		missile       = "wolf_massault2",

		OnFirstPickup = function(self,being)
			if not being:is_player() then return end
			ui.blink(YELLOW,50)

			--Play a different sound if it's Spear of Destiny
			if(DoomRL.isepisode()) then
				being:play_sound(self.id..".pickup1")
			else
				being:play_sound(self.id..".pickup2")
			end
		end
	}


	--other
	register_item "wolf_bazooka" {
		name     = "panzerschreck",
		color    = BROWN,
		sprite   = SPRITE_BAZOOKA,
		psprite  = SPRITE_PLAYER_BAZOOKA,
		level    = 7,
		weight   = 40,
		group    = "weapon-rocket",
		desc     = "The panzershreck can help you clear out any tanks you may come across indoors.",
		firstmsg = "Ride my rocket baby!",

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_rocket",
		ammomax       = 1,
		damage        = "6d6",
		damagetype    = DAMAGE_FIRE,
		acc           = 4,
		fire          = 10,
		radius        = 4,
		reload        = 15,
		altfire       = ALT_SCRIPT,
		altfirename   = "rocketjump",
		missile       = "wolf_mrocket",
		flags         = { IF_ROCKET },

		OnAltFire = function( self, being )
			self.missile = missiles[ "wolf_mrocketjump" ].nid
			return true
		end,
		OnFire = function( self, being )
			self.missile = missiles[ "wolf_mrocket" ].nid
			return true
		end,
	}
	register_item "wolf_flamethrower" {
		name     = "flammenwerfer",
		color    = LIGHTRED,
		level    = 12,
		weight   = 10,
		psprite  = SPRITE_PLAYER_PLASMA,
		sprite   = SPRITE_FLAME,
		group    = "weapon-energy",
		desc     = "Flamethrowers are proof positive that someone somewhere was once not close enough to set people they didn't like on fire.",
		flags    = { IF_NOUNLOAD },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_fuel",
		ammomax       = 15,
		damage        = "2d6",
		damagetype    = DAMAGE_FIRE,
		acc           = 4,
		fire          = 10,
		radius        = 2,
		reload        = 30,
		shots         = 3,
		missile       = "wolf_mflamethrower",
	}

	--[[ Tesla Cannon
	  The tesla cannon fires chain lightning.  When it hits
	  an enemy it will search for another nearby enemy and zap it as well.
	  The next target is chosen at random; closer enemies are not selected for
	  in any way.  As a result, since the cannon fires multiple bursts, there's
	  a good chance the lightning will arc differently for each shot.
	
	  Balancing considerations: 
	  Should the player be allowed to aim? (currently yes)
	  Should items or a dead enemy bounce lightning (curently no)
	  What is the range of the lightning? (currently 7 and 5 for the initial shot and the chain)
	  Should the lightning damage decay? (currently yes)
	  Should there be a maximum number of enemies hit? (currently yes, 5)
	  Should the weapon re-hit enemies if there's no one else in range? (currently no)
	
	  Currently I know of no way to actually draw the chained lightning.  I can
	  chain the lightning and damage multiple enemies but it must be done outside of normal
	  enemy damage missile bookkeeping channels.  Explosions are drawn to mark damaged enemies.
	--]]
	register_item "wolf_tesla" {
		name     = "tesla cannon", --Called the Blitzschlag in game sometimes
		color    = LIGHTGREEN,
		level    = 13,
		weight   = 5,
		psprite  = SPRITE_PLAYER_PLASMA,
		sprite   = SPRITE_FLAME,
		group    = "weapon-energy",
		desc     = "A futuristic weapon that shoots lightning at enemies.  The range is limited but it works well in crowds.",
		flags    = { IF_UNIQUE },

		type          = ITEMTYPE_RANGED,
		ammo_id        = "wolf_cell",
		ammomax       = 105,
		damage        = "1d7",
		damagetype    = DAMAGE_IGNOREARMOR,
		acc           = 9,
		fire          = 7,
		reload        = 15,
		shots         = 5,
		shotcost      = 3,
		missile       = "wolf_mtesla",

		OnHitBeing = function(self,being,target)
			--Todo: replace this with standard engine version once it is exposed
			local function roll_damage( dice, sides, bonus )
				local ret = bonus
				for c = 1,dice do
					ret = ret + math.random(sides)
				end

				return ret
			end

			local last_being = target
			local current_pos = target.position

			for hits = 1, 5 do
				--Find a target.  Target cannot equal the current being or the shooter.
				local choices = {}
				for b in level:beings_in_range( current_pos, 5 ) do
					if b.__ptr and b ~= being and b ~= last_being and b:eye_contact(current_pos) then table.insert(choices, b) end
				end
				if #choices == 0 then break end

				--Bounce the electricity.  Damage the target.
				local next_being = table.random_pick( choices )
				local damage = roll_damage(self.damage_dice, self.damage_sides, self.damage_add + being.todamall)
				current_pos = next_being.position
				damage = math.ceil(damage * (3 / (3 + hits)))
				level:explosion( current_pos, 1, 20, 0, 0, BLUE )
				next_being:apply_damage( damage, TARGET_TORSO, self.damagetype, self )

				--Variable upkeep
				last_being = next_being
			end

			--Runing the end-of-hit damage calcs on a deceased being WILL crash the game hard!  So don't do that.
			return target.__ptr ~= nil and target.__ptr ~= false
		end,
	}
	--[[ Particle Cannon
	  The particle cannon is just a big fancy lasery thingy.  It hurts people,
	  leaves no blood, and leaves no corpse (ideally, in reality I can't
	  prevent the blood in this version)
	--]]
	register_item "wolf_particle" {
		name     = "particle cannon",
		color    = LIGHTGREEN,
		level    = 18,
		weight   = 5,
		psprite  = SPRITE_PLAYER_PLASMA,
		sprite   = SPRITE_FLAME,
		group    = "weapon-energy",
		desc     = "This weapon fires a particle beam that disintegrates matter on contact.",
		flags    = { IF_UNIQUE, IF_SCATTER },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_cell",
		ammomax       = 168,
		damage        = "2d7",
		damagetype    = DAMAGE_IGNOREARMOR,
		acc           = 6,
		fire          = 8,
		reload        = 15,
		shots         = 7,
		shotcost      = 3,
		missile       = "wolf_mparticle",
	}
	--[[ Leichenfaust 44
	  The Leichenfaust 44, from Wolf 2009, messes with gravity and vaporizes enemies.
	  I'd like it to be bloodless and destroy enemies with no corpse chance, as well
	  as harming enemies and items NEAR the fired shot's trajectory without being in it.
	  But none of that is possible so instead it's become a ghostly boomer that passes
	  through enemies and spawns explosions as it does so.  The player is immune.
	--]]
	register_item "wolf_leichenfaust" {
		name     = "leichenfaust 44",
		color    = LIGHTGREEN,
		level    = 21,
		weight   = 5,
		psprite  = SPRITE_PLAYER_PLASMA,
		sprite   = SPRITE_FLAME,
		group    = "weapon-energy",
		desc     = "A gravity weapon that devastates anything that gets in its way.",
		flags    = { IF_UNIQUE, IF_AUTOHIT },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_cell",
		ammomax       = 180,
		damage        = "2d25",
		damagetype    = DAMAGE_IGNOREARMOR,
		acc           = 3,
		fire          = 15,
		reload        = 25,
		shots         = 1,
		shotcost      = 30,
		missile       = "wolf_mleichenfaust",

		OnHitBeing = function(self,being,target)
			level:explosion( target.position, 5, 40, self.damage_dice, self.damage_sides, MAGENTA, "wolf_leichenfaust.explode", self.damagetype, self, { EFSELFSAFE } )
			return false
		end,
	}


	register_item "blake_pistol1" {
		name     = "recharger pistol",
		color    = LIGHTGREEN,
		level    = 200,
		weight   = 0,
		psprite  = SPRITE_PLAYER_PLASMA,
		sprite   = SPRITE_FLAME,
		group    = "weapon-energy",
		desc     = "The recharger pistol makes a good backup but you'll definitely need something bigger to survive.",
		flags    = { IF_PISTOL, IF_RECHARGE },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_cell",
		ammomax       = 3,
		shotcost      = 3,
		rechargeamount= 1,
		rechargedelay = 2,
		damage        = "2d4",
		damagetype    = DAMAGE_BULLET,
		acc           = 5,
		fire          = 10,
		altfire       = ALT_AIMED,
		missile       = "blake_mpistol1",
	}
	register_item "blake_pistol2" {
		name     = "protector",
		color    = LIGHTGREEN,
		level    = 200,
		weight   = 0,
		psprite  = SPRITE_PLAYER_PLASMA,
		sprite   = SPRITE_FLAME,
		group    = "weapon-energy",
		desc     = "The protector is quick and accurate but still not quite what you need.",
		flags    = { IF_PISTOL },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_cell",
		ammomax       = 30,
		shotcost      = 3,
		damage        = "2d5",
		damagetype    = DAMAGE_BULLET,
		acc           = 5,
		fire          = 8,
		reload        = 10,
		altfire       = ALT_AIMED,
		missile       = "blake_mpistol2",

		OnFirstPickup = function(self,being)
			if not being:is_player() then return end
			being:play_sound(self.id..".pickup1")
		end
	}
	register_item "blake_rifle1" {
		name     = "assault rifle",
		color    = LIGHTGREEN,
		level    = 200,
		weight   = 0,
		psprite  = SPRITE_PLAYER_PLASMA,
		sprite   = SPRITE_FLAME,
		group    = "weapon-energy",
		desc     = "The assault rifle is easy to control and light on ammo.",
		flags    = { },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_cell",
		ammomax       = 60,
		shotcost      = 3,
		damage        = "3d2",
		damagetype    = DAMAGE_BULLET,
		acc           = 5,
		fire          = 8,
		reload        = 12,
		shots         = 3,
		missile       = "blake_mrifle1",

		OnFirstPickup = function(self,being)
			if not being:is_player() then return end
			being:play_sound(self.id..".pickup1")
		end
	}
	register_item "blake_rifle2" {
		name     = "neutron disruptor",
		color    = LIGHTGREEN,
		level    = 200,
		weight   = 0,
		psprite  = SPRITE_PLAYER_PLASMA,
		sprite   = SPRITE_FLAME,
		group    = "weapon-energy",
		desc     = "The neutron disruptor is big, ugly, and chews through ammo like candy.",
		flags    = { },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_cell",
		ammomax       = 80,
		shotcost      = 4,
		damage        = "3d3",
		damagetype    = DAMAGE_BULLET,
		acc           = 5,
		fire          = 8,
		reload        = 12,
		shots         = 3,
		missile       = "blake_mrifle2",

		OnFirstPickup = function(self,being)
			if not being:is_player() then return end
			being:play_sound(self.id..".pickup1")
		end
	}
	register_item "blake_bazooka" {
		name     = "plasma discharger",
		color    = LIGHTGREEN,
		level    = 200,
		weight   = 0,
		psprite  = SPRITE_PLAYER_PLASMA,
		sprite   = SPRITE_FLAME,
		group    = "weapon-energy",
		desc     = "The plasma discharger lobs an explosive ball of plasma. Be careful; its accuracy isn't very good.",
		flags    = { IF_AUTOHIT },

		type          = ITEMTYPE_RANGED,
		ammo_id       = "wolf_cell",
		ammomax       = 90,
		shotcost      = 30,
		damage        = "6d6",
		damagetype    = DAMAGE_FIRE,
		acc           = 3,
		fire          = 8,
		radius        = 5,
		reload        = 12,
		missile       = "blake_mbazooka",

		OnFirstPickup = function(self,being)
			if not being:is_player() then return end
			being:play_sound(self.id..".pickup1")
		end
	}

end
