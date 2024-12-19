-- You can get much higher quality Doom MP3 tracks from
-- http://www.sirgalahad.org/paul/doom/
-- See musicmp3.lua
--
-- All tracks are from original Doom except:
-- Unholy Cathedral, Final Showdown, Hells Weapons, Something Wicked,
-- Of Skull And Bone, The Brick Song, and Too Hot Down Here tracks composed 
-- by Simon Volpert (thanks!)
--
-- MP3 and OGG versions of Simons tracks can be obtained on 
-- the ChaosForge forums:
-- http://forum.chaosforge.org/index.php/topic,3446.0.html

music = {
	start     = "music/0  - intro.mid",
	interlude = "music/00 - inter.mid",
	bunny     = "music/99 - bunny.mid",
	intro     = "music/11 - hangar.mid",
	hellgate  = "music/18 - phobos anomaly.mid",

	level2    = "music/12 - nuclear plant.mid",
	level3    = "music/13 - toxin refinery.mid",
	level4    = "music/17 - computer station.mid",
	level5    = "music/15 - phobos lab.mid",
	level6    = "music/16 - central processing.mid",
	level7    = "music/14 - command control.mid",
	level8    = "music/19 - military base.mid",
	level9    = "music/11 - hangar.mid",
	level10   = "music/12 - nuclear plant.mid",
	level11   = "music/13 - toxin refinery.mid",
	level12   = "music/14 - command control.mid",
	level13   = "music/15 - phobos lab.mid",
	level14   = "music/16 - central processing.mid",
	level15   = "music/22 - containment area.mid",
	level16   = "music/24 - deimos lab.mid",
	level17   = "music/26 - halls of the damned.mid",
	level18   = "music/27 - spawning vats.mid",
	level19   = "music/29 - fortress of mystery.mid",
	level20   = "music/32 - slough of despair.mid",
	level21   = "music/33 - pandemonium.mid",
	level22   = "music/22 - containment area.mid",
	level23   = "music/24 - deimos lab.mid",
	level24   = "music/26 - halls of the damned.mid",

	hells_arena       = "music/32 - slough of despair.mid",
	the_chained_court = "music/rage.mid",
	military_base     = "music/19 - military base.mid",
	halls_of_carnage  = "music/19 - military base.mid",
	hells_armory      = "music/hells_weapons.mid",
	spiders_lair      = "music/27 - spawning vats.mid",
	city_of_skulls    = "music/of_skull_and_bone.mid",
	the_wall          = "music/the_brick_song.mid",
	unholy_cathedral  = "music/unholy_cathedral.mid",
	the_mortuary      = "music/something_wicked.mid",
	the_vaults        = "music/dark_secrets.mid",
	house_of_pain     = "music/dark_secrets.mid",
	the_lava_pits     = "music/too_hot_down_here.mid",

	phobos_lab        = "music/15 - phobos lab.mid",
	deimos_lab        = "music/24 - deimos lab.mid",
	containment_area  = "music/22 - containment area.mid",
	abyssal_plains    = "music/of_skull_and_bone.mid",
	limbo             = "music/something_wicked.mid",
	mt_erebus         = "music/too_hot_down_here.mid",

	tower_of_babel    = "music/28 - tower of babel.mid",
	hell_fortress     = "music/final_showdown.mid",
	dis               = "music/38 - dis.mid",
	victory           = "music/98 - victory.mid",
}

sound = {
	--
	-- Enviroment
	
	-- Sound
	menu     = {
		change = "sound/dspstop.wav",
		pick   = "sound/dspistol.wav",
		cancel = "sound/dsswtchx.wav",
	},
	
	-- Barrel of Fuel
	
	barrel   = {
		move		= "sound/dsstnmov.wav",
		movefail	= "sound/dsnoway.wav",
		explode		= "sound/dsbarexp.wav",
	},
	
	-- Barrel of Acid
	
	barrela  = {
		move		= "sound/dsstnmov.wav",
		movefail	= "sound/dsnoway.wav",
		explode		= "sound/dsbarexp.wav",
	},
	
	-- Barrel of Napalm
	
	barreln  = {
		move		= "sound/dsstnmov.wav",
		movefail	= "sound/dsnoway.wav",
		explode		= "sound/dsbarexp.wav",
	},
	
	-- Door
	
	door			= {
		open		= "sound/dsbdopn.wav",
		close		= "sound/dsbdcls.wav",
		fail        = "sound/dsnoway.wav",
	},	

	-- Teleport
	
	teleport = {
		use			= "sound/dstelept.wav",
	},

	-- Hellgate
	
	hellgate = {
		use			= "sound/dstelept.wav",
	},
	
	-- Levers
	
	lever = {
		use				= "sound/dsswtchn.wav",
	},
	
	-- Gib
	
	gib				= "sound/dsslop.wav",
	
	--
	-- Powerups
	--
	
	-- Small Health Globe
	
	shglobe = {
		powerup		= "sound/dsgetpow.wav",
	},
	
	-- Large Health Globe
	
	lhglobe = {
		powerup		= "sound/dsgetpow.wav",
	},
	
	-- Supercharge Globe
	
	scglobe = {
		powerup		= "sound/dsgetpow.wav",
	},
	
	-- Invulnerability Globe
	
	iglobe = {
		powerup		= "sound/dsgetpow.wav",
	},
	
	-- Armor Shard
	
	ashard = {
		powerup		= "sound/dsgetpow.wav",
	},
	
	-- Berserk Pack
	
	bpack = {
		powerup		= "sound/dsgetpow.wav",
	},
	
	-- Computer Map
	
	map = {
		powerup		= "sound/dsgetpow.wav",
	},
	
	-- Backpack
	
	backpack = {
		powerup		= "sound/dsgetpow.wav",
	},
	
	--
	-- Pickups
	--
	
	-- Small Medkit
	
	smed = {
		pickup		= "sound/dsitemup.wav",
		use			= "sound/dsgetpow.wav",
	},
	
	-- Large Medkit
	
	lmed = {
		pickup		= "sound/dsitemup.wav",
		use			= "sound/dsgetpow.wav",
	},
	
	-- Phase Device
	
	phase = {
		pickup		= "sound/dsitemup.wav",
	},
	
	-- Homing Phase Device
	
	hphase = {
		pickup		= "sound/dsitemup.wav",
	},
	
	-- Envirosuit Pack
	
	epack = {
		pickup		= "sound/dsitemup.wav",
	},
	
	-- Thermonuclear Device
	
	nuke = {
		pickup		= "sound/dsitemup.wav",
		explode		= "sound/dsfirxpl.wav",
	},
	
	-- Power Mod Pack
	
	mod_power = {
		pickup		= "sound/dsitemup.wav",
	},
	
	-- Agility Mod Pack
	
	mod_agility = {
		pickup		= "sound/dsitemup.wav",
	},
	
	-- Bulk Mod Pack
	
	mod_bulk = {
		pickup		= "sound/dsitemup.wav",
	},
	
	-- Technical Mod Pack
	
	mod_tech = {
		pickup		= "sound/dsitemup.wav",
	},
	
	--
	-- Armor and Boots
	--
	
	-- Green Armor
	
	garmor = {
		pickup		= "sound/dsitemup.wav",
	},
	
	-- Blue Armor
	
	barmor = {
		pickup		= "sound/dsitemup.wav",
	},
	
	-- Red Armor
	
	rarmor = {
		pickup		= "sound/dsitemup.wav",
	},
	
	-- Steel Boots
	
	sboots = {
		pickup		= "sound/dsitemup.wav",
	},
	
	-- Protective Boots
	
	pboots = {
		pickup		= "sound/dsitemup.wav",
	},
	
	-- Plasteel Boots
	
	psboots = {
		pickup		= "sound/dsitemup.wav",
	},
	
	--
	-- Ammunition
	--
	
	-- 10mm Ammo
	
	ammo = {
		pickup		= "sound/dsitemup.wav",
	},
	
	-- Shotgun Shell
	
	shell = {
		pickup		= "sound/dsitemup.wav",
	},
	
	-- Rocket
	
	rocket = {
		pickup		= "sound/dsitemup.wav",
	},
	
	-- Power Cell
	
	cell = {
		pickup		= "sound/dsitemup.wav",
	},
	
	--
	-- Weapons
	--
	
	-- Combat Knife
	
	knife = {
		fire		= "sound/dspunch.wav",
		pickup		= "sound/dswpnup.wav",
	},
	
	-- Pistol
	
	pistol = {
		fire		= "sound/dspistol.wav",
		pickup		= "sound/dswpnup.wav",
		reload		= "sound/dswpnup.wav",
	},
	
	-- Shotgun
	
	shotgun = {
		fire		= "sound/dsshotgn.wav",
		pickup		= "sound/dswpnup.wav",
		reload		= "sound/dswpnup.wav",
	},
	
	-- Combat Shotgun
	
	ashotgun = {
		fire		= "sound/dsshotgn.wav",
		pickup		= "sound/dswpnup.wav",
		reload		= "sound/dswpnup.wav",
		pump		= "sound/dssgcock.wav",
	},
	
	-- Double Shotgun
	
	dshotgun = {
		fire		= "sound/dsdshtgn.wav",
		pickup		= "sound/dswpnup.wav",
		reload		= "sound/dswpnup.wav",
	},
	
	--sshotgun = {
	--	fire		= "sound/dsdshtgn.wav",
	--	pickup		= "sound/dswpnup.wav",
	--	reload		= "sound/dswpnup.wav",
	--},
	
	-- Chaingun
	
	chaingun = {
		fire		= "sound/dspistol.wav",
		pickup		= "sound/dswpnup.wav",
		reload		= "sound/dswpnup.wav",
	},
	
	-- Plasma Rifle
	
	plasma = {
		fire		= "sound/dsplasma.wav",
		pickup		= "sound/dswpnup.wav",
		reload		= "sound/dswpnup.wav",
	},
	
	-- Rocket Launcher
	
	bazooka = {
		fire		= "sound/dsrlaunc.wav",
		pickup		= "sound/dswpnup.wav",
		reload		= "sound/dswpnup.wav",
		explode		= "sound/dsrxplod.wav",
	},
	
	--
	-- Creatures
	--
	
	-- Player
	
	soldier = {
		die			= "sound/dspldeth.wav",
		hit			= "sound/dsplpain.wav",
		melee		= "sound/dspunch.wav",
		phase		= "sound/dstelept.wav",
	},
	
	-- Former Human
	
	former = {
		die			= "sound/dspodth1.wav",
		act			= "sound/dsposact.wav",
		hit			= "sound/dspopain.wav",
		melee		= "sound/dspunch.wav",
	},
	
	-- Former Sergeant
	
	sergeant = {
		die			= "sound/dspodth2.wav",
		act			= "sound/dsposact.wav",
		hit			= "sound/dspopain.wav",
		melee		= "sound/dspunch.wav",
	},
	
	-- Former Captain
	
	captain = {
		die			= "sound/dspodth2.wav",
		act			= "sound/dsposact.wav",
		hit			= "sound/dspopain.wav",
		melee		= "sound/dspunch.wav",
	},
	
	-- Former Commando
	
	commando = {
		die			= "sound/dspodth3.wav",
		act			= "sound/dsposact.wav",
		hit			= "sound/dspopain.wav",
		melee		= "sound/dspunch.wav",
	},
	
	-- Imp
	
	imp = {
		die			= "sound/dsbgdth1.wav",
		act			= "sound/dsbgact.wav",
		hit			= "sound/dspopain.wav",
		melee		= "sound/dsclaw.wav",
		fire		= "sound/dsfirsht.wav",
		explode		= "sound/dsfirxpl.wav",
	},
	
	-- Lost Soul
	
	lostsoul = {
		die			= "sound/dsfirxpl.wav",
		act			= "sound/dssklatk.wav",
		hit			= "sound/dsdmpain.wav",
		melee		= "sound/dssklatk.wav",
	},
	
	-- Pain Elemental
	
	pain = {
		die			= "sound/dspedth.wav",
		act			= "sound/dspesit.wav",
		hit			= "sound/dspepain.wav",
		melee		= "sound/dsclaw.wav";
	},
	
	-- Demon
	
	demon = {
		die			= "sound/dssgtdth.wav",
		act			= "sound/dsdmact.wav",
		hit			= "sound/dsdmpain.wav",
		melee		= "sound/dssgtatk.wav",
	},
	
	-- Cacodemon
	
	cacodemon = {
		die			= "sound/dscacdth.wav",
		act			= "sound/dscacsit.wav",
		hit			= "sound/dsdmpain.wav",
		melee		= "sound/dsclaw.wav",
		fire		= "sound/dsfirsht.wav",
		explode		= "sound/dsfirxpl.wav",
	},
	
	-- Arachnotron
	
	arachno = {
		die			= "sound/dsbspdth.wav",
		act			= "sound/dsbspact.wav",
		hit			= "sound/dsdmpain.wav",
		melee		= "sound/dsclaw.wav",
		fire		= "sound/dsplasma.wav",
	},
	
	-- Hell Knight
	
	knight = {
		die			= "sound/dskntdth.wav",
		act			= "sound/dskntsit.wav",
		hit			= "sound/dsdmpain.wav",
		melee		= "sound/dsclaw.wav",
		fire		= "sound/dsfirsht.wav",
		explode		= "sound/dsfirxpl.wav",
	},
	
	-- Baron of Hell
	
	baron = {
		die			= "sound/dsbrsdth.wav",
		act			= "sound/dsbrssit.wav",
		hit			= "sound/dsdmpain.wav",
		melee		= "sound/dsclaw.wav",
		fire		= "sound/dsfirsht.wav",
		explode		= "sound/dsfirxpl.wav",
	},
	
	-- Mancubus
	
	mancubus = {
		die			= "sound/dsmandth.wav",
		act			= "sound/dsmansit.wav",
		hit			= "sound/dsmnpain.wav",
		fire		= "sound/dsfirsht.wav",
		explode		= "sound/dsfirxpl.wav",
		attack      = "sound/dsmanatk.wav",
	},
	
	-- Revenant
	
	revenant = {
		die			= "sound/dsskedth.wav",
		act			= "sound/dsskesit.wav",
		hit			= "sound/dspopain.wav",
		melee		= "sound/dsskepch.wav",
		fire		= "sound/dsskeatk.wav",
		explode		= "sound/dsbarexp.wav",
	},
	
	-- Arch-vile
	
	arch = {
		die			= "sound/dsvildth.wav",
		act			= "sound/dsvilact.wav",
		hit			= "sound/dsvipain.wav",
		fire		= "sound/dsvilatk.wav",
	},
	
	-- Bruiser Brothers
	
	bruiser = {
		die			= "sound/dsbrsdth.wav",
		act			= "sound/dsbrssit.wav",
		hit			= "sound/dsdmpain.wav",
		melee		= "sound/dsclaw.wav",
		fire		= "sound/dsfirsht.wav",
		explode		= "sound/dsfirxpl.wav",
	},
	
	-- Cyberdemon
	
	cyberdemon = {
		die			= "sound/dscybdth.wav",
		act			= "sound/dscybsit.wav",
		hit			= "sound/dsdmpain.wav",
		hoof		= "sound/dshoof.wav",
	},
	
	-- JC

	jc = {
		die			= "sound/dspodth1.wav",
		act			= "sound/dsposact.wav",
		hit			= "sound/dspopain.wav",
		melee		= "sound/dspunch.wav",
	},

	-- AoD

	angel = {
		die			= "sound/dsbrsdth.wav",
		act			= "sound/dsbrssit.wav",
		hit			= "sound/dsbrssit.wav",
		melee		= "sound/dsclaw.wav",
		hoof		= "sound/dshoof.wav";
	},
	
	-- Mastermind
	
	mastermind = {
		die			= "sound/dsspidth.wav",
		act			= "sound/dsdmact.wav",
		hit			= "sound/dsdmpain.wav",
		melee		= "sound/dsclaw.wav",
		hoof		= "sound/dsmetal.wav";
	},
	
	--
	-- Exotic Items
	--
	
	-- Exotic #18 (Chainsaw)
	
	chainsaw = {
		fire		= "sound/dssawhit.wav",
		pickup		= "sound/dswpnup.wav",
	},
	
	-- Exotic #19 (BFG 9000)
	
	bfg9000 = {
		fire		= "sound/dsbfg.wav",
		pickup		= "sound/dswpnup.wav",
		reload		= "sound/dswpnup.wav",
		explode		= "sound/dsrxplod.wav",
	},
	
	--
	-- Unique Items
	--
	
	-- Unique #17 (Longinus Spear)
	
	spear = {
		fire		= "sound/dsgetpow.wav",
		pickup		= "sound/dswpnup.wav",
		explode		= "sound/dsrxplod.wav",
	},
	
	--
	-- Default sounds
	--
	
	melee			= "sound/dsclaw.wav",
	reload			= "sound/dswpnup.wav",
	pickup			= "sound/dsitemup.wav",
	fire			= "sound/dsfirsht.wav",
	use				= "sound/dsgetpow.wav",
	explode			= "sound/dsfirxpl.wav",
	powerup			= "sound/dsgetpow.wav",
	phasing 	    = "sound/dstelept.wav",
}