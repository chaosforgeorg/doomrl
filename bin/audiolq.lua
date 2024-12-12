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
	start     = "data/drllq/music/0  - intro.mid",
	interlude = "data/drllq/music/00 - inter.mid",
	bunny     = "data/drllq/music/99 - bunny.mid",
	intro     = "data/drllq/music/11 - hangar.mid",
	hellgate  = "data/drllq/music/18 - phobos anomaly.mid",

	level2    = "data/drllq/music/12 - nuclear plant.mid",
	level3    = "data/drllq/music/13 - toxin refinery.mid",
	level4    = "data/drllq/music/17 - computer station.mid",
	level5    = "data/drllq/music/15 - phobos lab.mid",
	level6    = "data/drllq/music/16 - central processing.mid",
	level7    = "data/drllq/music/14 - command control.mid",
	level8    = "data/drllq/music/19 - military base.mid",
	level9    = "data/drllq/music/11 - hangar.mid",
	level10   = "data/drllq/music/12 - nuclear plant.mid",
	level11   = "data/drllq/music/13 - toxin refinery.mid",
	level12   = "data/drllq/music/14 - command control.mid",
	level13   = "data/drllq/music/15 - phobos lab.mid",
	level14   = "data/drllq/music/16 - central processing.mid",
	level15   = "data/drllq/music/22 - containment area.mid",
	level16   = "data/drllq/music/24 - deimos lab.mid",
	level17   = "data/drllq/music/26 - halls of the damned.mid",
	level18   = "data/drllq/music/27 - spawning vats.mid",
	level19   = "data/drllq/music/29 - fortress of mystery.mid",
	level20   = "data/drllq/music/32 - slough of despair.mid",
	level21   = "data/drllq/music/33 - pandemonium.mid",
	level22   = "data/drllq/music/22 - containment area.mid",
	level23   = "data/drllq/music/24 - deimos lab.mid",
	level24   = "data/drllq/music/26 - halls of the damned.mid",

	hells_arena       = "data/drllq/music/32 - slough of despair.mid",
	the_chained_court = "data/drllq/music/rage.mid",
	military_base     = "data/drllq/music/19 - military base.mid",
	halls_of_carnage  = "data/drllq/music/19 - military base.mid",
	hells_armory      = "data/drllq/music/hells_weapons.mid",
	spiders_lair      = "data/drllq/music/27 - spawning vats.mid",
	city_of_skulls    = "data/drllq/music/of_skull_and_bone.mid",
	the_wall          = "data/drllq/music/the_brick_song.mid",
	unholy_cathedral  = "data/drllq/music/unholy_cathedral.mid",
	the_mortuary      = "data/drllq/music/something_wicked.mid",
	the_vaults        = "data/drllq/music/dark_secrets.mid",
	house_of_pain     = "data/drllq/music/dark_secrets.mid",
	the_lava_pits     = "data/drllq/music/too_hot_down_here.mid",

	phobos_lab        = "data/drllq/music/15 - phobos lab.mid",
	deimos_lab        = "data/drllq/music/24 - deimos lab.mid",
	containment_area  = "data/drllq/music/22 - containment area.mid",
	abyssal_plains    = "data/drllq/music/of_skull_and_bone.mid",
	limbo             = "data/drllq/music/something_wicked.mid",
	mt_erebus         = "data/drllq/music/too_hot_down_here.mid",

	tower_of_babel    = "data/drllq/music/28 - tower of babel.mid",
	hell_fortress     = "data/drllq/music/final_showdown.mid",
	dis               = "data/drllq/music/38 - dis.mid",
	victory           = "data/drllq/music/98 - victory.mid",
}

sound = {
	--
	-- Enviroment
	
	-- Sound
	menu     = {
		change = "data/drllq/sound/dspstop.wav",
		pick   = "data/drllq/sound/dspistol.wav",
		cancel = "data/drllq/sound/dsswtchx.wav",
	},
	
	-- Barrel of Fuel
	
	barrel   = {
		move		= "data/drllq/sound/dsstnmov.wav",
		movefail	= "data/drllq/sound/dsnoway.wav",
		explode		= "data/drllq/sound/dsbarexp.wav",
	},
	
	-- Barrel of Acid
	
	barrela  = {
		move		= "data/drllq/sound/dsstnmov.wav",
		movefail	= "data/drllq/sound/dsnoway.wav",
		explode		= "data/drllq/sound/dsbarexp.wav",
	},
	
	-- Barrel of Napalm
	
	barreln  = {
		move		= "data/drllq/sound/dsstnmov.wav",
		movefail	= "data/drllq/sound/dsnoway.wav",
		explode		= "data/drllq/sound/dsbarexp.wav",
	},
	
	-- Door
	
	door			= {
		open		= "data/drllq/sound/dsbdopn.wav",
		close		= "data/drllq/sound/dsbdcls.wav",
	},
	
	-- Teleport
	
	teleport = {
		use			= "data/drllq/sound/dstelept.wav",
	},
	
	-- Levers
	
	lever = {
		use				= "data/drllq/sound/dsswtchn.wav",
	},
	
	-- Gib
	
	gib				= "data/drllq/sound/dsslop.wav",
	
	--
	-- Powerups
	--
	
	-- Small Health Globe
	
	shglobe = {
		powerup		= "data/drllq/sound/dsgetpow.wav",
	},
	
	-- Large Health Globe
	
	lhglobe = {
		powerup		= "data/drllq/sound/dsgetpow.wav",
	},
	
	-- Supercharge Globe
	
	scglobe = {
		powerup		= "data/drllq/sound/dsgetpow.wav",
	},
	
	-- Invulnerability Globe
	
	iglobe = {
		powerup		= "data/drllq/sound/dsgetpow.wav",
	},
	
	-- Armor Shard
	
	ashard = {
		powerup		= "data/drllq/sound/dsgetpow.wav",
	},
	
	-- Berserk Pack
	
	bpack = {
		powerup		= "data/drllq/sound/dsgetpow.wav",
	},
	
	-- Computer Map
	
	map = {
		powerup		= "data/drllq/sound/dsgetpow.wav",
	},
	
	-- Backpack
	
	backpack = {
		powerup		= "data/drllq/sound/dsgetpow.wav",
	},
	
	--
	-- Pickups
	--
	
	-- Small Medkit
	
	smed = {
		pickup		= "data/drllq/sound/dsitemup.wav",
		use			= "data/drllq/sound/dsgetpow.wav",
	},
	
	-- Large Medkit
	
	lmed = {
		pickup		= "data/drllq/sound/dsitemup.wav",
		use			= "data/drllq/sound/dsgetpow.wav",
	},
	
	-- Phase Device
	
	phase = {
		pickup		= "data/drllq/sound/dsitemup.wav",
	},
	
	-- Homing Phase Device
	
	hphase = {
		pickup		= "data/drllq/sound/dsitemup.wav",
	},
	
	-- Envirosuit Pack
	
	epack = {
		pickup		= "data/drllq/sound/dsitemup.wav",
	},
	
	-- Thermonuclear Device
	
	nuke = {
		pickup		= "data/drllq/sound/dsitemup.wav",
		explode		= "data/drllq/sound/dsfirxpl.wav",
	},
	
	-- Power Mod Pack
	
	mod_power = {
		pickup		= "data/drllq/sound/dsitemup.wav",
	},
	
	-- Agility Mod Pack
	
	mod_agility = {
		pickup		= "data/drllq/sound/dsitemup.wav",
	},
	
	-- Bulk Mod Pack
	
	mod_bulk = {
		pickup		= "data/drllq/sound/dsitemup.wav",
	},
	
	-- Technical Mod Pack
	
	mod_tech = {
		pickup		= "data/drllq/sound/dsitemup.wav",
	},
	
	--
	-- Armor and Boots
	--
	
	-- Green Armor
	
	garmor = {
		pickup		= "data/drllq/sound/dsitemup.wav",
	},
	
	-- Blue Armor
	
	barmor = {
		pickup		= "data/drllq/sound/dsitemup.wav",
	},
	
	-- Red Armor
	
	rarmor = {
		pickup		= "data/drllq/sound/dsitemup.wav",
	},
	
	-- Steel Boots
	
	sboots = {
		pickup		= "data/drllq/sound/dsitemup.wav",
	},
	
	-- Protective Boots
	
	pboots = {
		pickup		= "data/drllq/sound/dsitemup.wav",
	},
	
	-- Plasteel Boots
	
	psboots = {
		pickup		= "data/drllq/sound/dsitemup.wav",
	},
	
	--
	-- Ammunition
	--
	
	-- 10mm Ammo
	
	ammo = {
		pickup		= "data/drllq/sound/dsitemup.wav",
	},
	
	-- Shotgun Shell
	
	shell = {
		pickup		= "data/drllq/sound/dsitemup.wav",
	},
	
	-- Rocket
	
	rocket = {
		pickup		= "data/drllq/sound/dsitemup.wav",
	},
	
	-- Power Cell
	
	cell = {
		pickup		= "data/drllq/sound/dsitemup.wav",
	},
	
	--
	-- Weapons
	--
	
	-- Combat Knife
	
	knife = {
		fire		= "data/drllq/sound/dspunch.wav",
		pickup		= "data/drllq/sound/dswpnup.wav",
	},
	
	-- Pistol
	
	pistol = {
		fire		= "data/drllq/sound/dspistol.wav",
		pickup		= "data/drllq/sound/dswpnup.wav",
		reload		= "data/drllq/sound/dswpnup.wav",
	},
	
	-- Shotgun
	
	shotgun = {
		fire		= "data/drllq/sound/dsshotgn.wav",
		pickup		= "data/drllq/sound/dswpnup.wav",
		reload		= "data/drllq/sound/dswpnup.wav",
	},
	
	-- Combat Shotgun
	
	ashotgun = {
		fire		= "data/drllq/sound/dsshotgn.wav",
		pickup		= "data/drllq/sound/dswpnup.wav",
		reload		= "data/drllq/sound/dswpnup.wav",
		pump		= "data/drllq/sound/dssgcock.wav",
	},
	
	-- Double Shotgun
	
	dshotgun = {
		fire		= "data/drllq/sound/dsdshtgn.wav",
		pickup		= "data/drllq/sound/dswpnup.wav",
		reload		= "data/drllq/sound/dswpnup.wav",
	},
	
	--sshotgun = {
	--	fire		= "data/drllq/sound/dsdshtgn.wav",
	--	pickup		= "data/drllq/sound/dswpnup.wav",
	--	reload		= "data/drllq/sound/dswpnup.wav",
	--},
	
	-- Chaingun
	
	chaingun = {
		fire		= "data/drllq/sound/dspistol.wav",
		pickup		= "data/drllq/sound/dswpnup.wav",
		reload		= "data/drllq/sound/dswpnup.wav",
	},
	
	-- Plasma Rifle
	
	plasma = {
		fire		= "data/drllq/sound/dsplasma.wav",
		pickup		= "data/drllq/sound/dswpnup.wav",
		reload		= "data/drllq/sound/dswpnup.wav",
	},
	
	-- Rocket Launcher
	
	bazooka = {
		fire		= "data/drllq/sound/dsrlaunc.wav",
		pickup		= "data/drllq/sound/dswpnup.wav",
		reload		= "data/drllq/sound/dswpnup.wav",
		explode		= "data/drllq/sound/dsrxplod.wav",
	},
	
	--
	-- Creatures
	--
	
	-- Player
	
	soldier = {
		die			= "data/drllq/sound/dspldeth.wav",
		hit			= "data/drllq/sound/dsplpain.wav",
		melee		= "data/drllq/sound/dspunch.wav",
		phase		= "data/drllq/sound/dstelept.wav",
	},
	
	-- Former Human
	
	former = {
		die			= "data/drllq/sound/dspodth1.wav",
		act			= "data/drllq/sound/dsposact.wav",
		hit			= "data/drllq/sound/dspopain.wav",
		melee		= "data/drllq/sound/dspunch.wav",
	},
	
	-- Former Sergeant
	
	sergeant = {
		die			= "data/drllq/sound/dspodth2.wav",
		act			= "data/drllq/sound/dsposact.wav",
		hit			= "data/drllq/sound/dspopain.wav",
		melee		= "data/drllq/sound/dspunch.wav",
	},
	
	-- Former Captain
	
	captain = {
		die			= "data/drllq/sound/dspodth2.wav",
		act			= "data/drllq/sound/dsposact.wav",
		hit			= "data/drllq/sound/dspopain.wav",
		melee		= "data/drllq/sound/dspunch.wav",
	},
	
	-- Former Commando
	
	commando = {
		die			= "data/drllq/sound/dspodth3.wav",
		act			= "data/drllq/sound/dsposact.wav",
		hit			= "data/drllq/sound/dspopain.wav",
		melee		= "data/drllq/sound/dspunch.wav",
	},
	
	-- Imp
	
	imp = {
		die			= "data/drllq/sound/dsbgdth1.wav",
		act			= "data/drllq/sound/dsbgact.wav",
		hit			= "data/drllq/sound/dspopain.wav",
		melee		= "data/drllq/sound/dsclaw.wav",
		fire		= "data/drllq/sound/dsfirsht.wav",
		explode		= "data/drllq/sound/dsfirxpl.wav",
	},
	
	-- Lost Soul
	
	lostsoul = {
		die			= "data/drllq/sound/dsfirxpl.wav",
		act			= "data/drllq/sound/dssklatk.wav",
		hit			= "data/drllq/sound/dsdmpain.wav",
		melee		= "data/drllq/sound/dssklatk.wav",
	},
	
	-- Pain Elemental
	
	pain = {
		die			= "data/drllq/sound/dspedth.wav",
		act			= "data/drllq/sound/dspesit.wav",
		hit			= "data/drllq/sound/dspepain.wav",
		melee		= "data/drllq/sound/dsclaw.wav";
	},
	
	-- Demon
	
	demon = {
		die			= "data/drllq/sound/dssgtdth.wav",
		act			= "data/drllq/sound/dsdmact.wav",
		hit			= "data/drllq/sound/dsdmpain.wav",
		melee		= "data/drllq/sound/dssgtatk.wav",
	},
	
	-- Cacodemon
	
	cacodemon = {
		die			= "data/drllq/sound/dscacdth.wav",
		act			= "data/drllq/sound/dscacsit.wav",
		hit			= "data/drllq/sound/dsdmpain.wav",
		melee		= "data/drllq/sound/dsclaw.wav",
		fire		= "data/drllq/sound/dsfirsht.wav",
		explode		= "data/drllq/sound/dsfirxpl.wav",
	},
	
	-- Arachnotron
	
	arachno = {
		die			= "data/drllq/sound/dsbspdth.wav",
		act			= "data/drllq/sound/dsbspact.wav",
		hit			= "data/drllq/sound/dsdmpain.wav",
		melee		= "data/drllq/sound/dsclaw.wav",
		fire		= "data/drllq/sound/dsplasma.wav",
	},
	
	-- Hell Knight
	
	knight = {
		die			= "data/drllq/sound/dskntdth.wav",
		act			= "data/drllq/sound/dskntsit.wav",
		hit			= "data/drllq/sound/dsdmpain.wav",
		melee		= "data/drllq/sound/dsclaw.wav",
		fire		= "data/drllq/sound/dsfirsht.wav",
		explode		= "data/drllq/sound/dsfirxpl.wav",
	},
	
	-- Baron of Hell
	
	baron = {
		die			= "data/drllq/sound/dsbrsdth.wav",
		act			= "data/drllq/sound/dsbrssit.wav",
		hit			= "data/drllq/sound/dsdmpain.wav",
		melee		= "data/drllq/sound/dsclaw.wav",
		fire		= "data/drllq/sound/dsfirsht.wav",
		explode		= "data/drllq/sound/dsfirxpl.wav",
	},
	
	-- Mancubus
	
	mancubus = {
		die			= "data/drllq/sound/dsmandth.wav",
		act			= "data/drllq/sound/dsmansit.wav",
		hit			= "data/drllq/sound/dsmnpain.wav",
		fire		= "data/drllq/sound/dsfirsht.wav",
		explode		= "data/drllq/sound/dsfirxpl.wav",
		attack      = "data/drllq/sound/dsmanatk.wav",
	},
	
	-- Revenant
	
	revenant = {
		die			= "data/drllq/sound/dsskedth.wav",
		act			= "data/drllq/sound/dsskesit.wav",
		hit			= "data/drllq/sound/dspopain.wav",
		melee		= "data/drllq/sound/dsskepch.wav",
		fire		= "data/drllq/sound/dsskeatk.wav",
		explode		= "data/drllq/sound/dsbarexp.wav",
	},
	
	-- Arch-vile
	
	arch = {
		die			= "data/drllq/sound/dsvildth.wav",
		act			= "data/drllq/sound/dsvilact.wav",
		hit			= "data/drllq/sound/dsvipain.wav",
		fire		= "data/drllq/sound/dsvilatk.wav",
	},
	
	-- Bruiser Brothers
	
	bruiser = {
		die			= "data/drllq/sound/dsbrsdth.wav",
		act			= "data/drllq/sound/dsbrssit.wav",
		hit			= "data/drllq/sound/dsdmpain.wav",
		melee		= "data/drllq/sound/dsclaw.wav",
		fire		= "data/drllq/sound/dsfirsht.wav",
		explode		= "data/drllq/sound/dsfirxpl.wav",
	},
	
	-- Cyberdemon
	
	cyberdemon = {
		die			= "data/drllq/sound/dscybdth.wav",
		act			= "data/drllq/sound/dscybsit.wav",
		hit			= "data/drllq/sound/dsdmpain.wav",
		hoof		= "data/drllq/sound/dshoof.wav",
	},
	
	-- JC

	jc = {
		die			= "data/drllq/sound/dspodth1.wav",
		act			= "data/drllq/sound/dsposact.wav",
		hit			= "data/drllq/sound/dspopain.wav",
		melee		= "data/drllq/sound/dspunch.wav",
	},

	-- AoD

	angel = {
		die			= "data/drllq/sound/dsbrsdth.wav",
		act			= "data/drllq/sound/dsbrssit.wav",
		hit			= "data/drllq/sound/dsbrssit.wav",
		melee		= "data/drllq/sound/dsclaw.wav",
		hoof		= "data/drllq/sound/dshoof.wav";
	},
	
	-- Mastermind
	
	mastermind = {
		die			= "data/drllq/sound/dsspidth.wav",
		act			= "data/drllq/sound/dsdmact.wav",
		hit			= "data/drllq/sound/dsdmpain.wav",
		melee		= "data/drllq/sound/dsclaw.wav",
		hoof		= "data/drllq/sound/dsmetal.wav";
	},
	
	--
	-- Exotic Items
	--
	
	-- Exotic #18 (Chainsaw)
	
	chainsaw = {
		fire		= "data/drllq/sound/dssawhit.wav",
		pickup		= "data/drllq/sound/dswpnup.wav",
	},
	
	-- Exotic #19 (BFG 9000)
	
	bfg9000 = {
		fire		= "data/drllq/sound/dsbfg.wav",
		pickup		= "data/drllq/sound/dswpnup.wav",
		reload		= "data/drllq/sound/dswpnup.wav",
		explode		= "data/drllq/sound/dsrxplod.wav",
	},
	
	--
	-- Unique Items
	--
	
	-- Unique #17 (Longinus Spear)
	
	spear = {
		fire		= "data/drllq/sound/dsgetpow.wav",
		pickup		= "data/drllq/sound/dswpnup.wav",
		explode		= "data/drllq/sound/dsrxplod.wav",
	},
	
	--
	-- Default sounds
	--
	
	melee			= "data/drllq/sound/dsclaw.wav",
	reload			= "data/drllq/sound/dswpnup.wav",
	pickup			= "data/drllq/sound/dsitemup.wav",
	fire			= "data/drllq/sound/dsfirsht.wav",
	use				= "data/drllq/sound/dsgetpow.wav",
	explode			= "data/drllq/sound/dsfirxpl.wav",
	powerup			= "data/drllq/sound/dsgetpow.wav",
	phasing 	    = "data/drllq/sound/dstelept.wav",
}