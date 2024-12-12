
-- High quality remixes of the original Doom music are a courtesy of Sonic 
-- Clang ( http://sonicclang.ringdev.com/ ) used with permission.

-- Doom the Roguelike theme, Unholy Cathedral, Final Showdown, Hells 
-- Weapons, Something Wicked, Of Skull And Bone, The Brick Song, and 
-- Too Hot Down Here tracks composed by Simon Volpert (thanks!)

music = {
	start     = "data/drlhq/music/doom_the_roguelike.mp3",
	interlude = "data/drlhq/music/d1inter.mp3",
	bunny     = "data/drlhq/music/d1end.mp3",
	intro     = "data/drlhq/music/cde1m1.mp3",
	hellgate  = "data/drlhq/music/cde1m8.mp3",

	level2    = "data/drlhq/music/cde1m2.mp3",
	level3    = "data/drlhq/music/cde1m3.mp3",
	level4    = "data/drlhq/music/cde1m7.mp3",
	level5    = "data/drlhq/music/cde1m5.mp3",
	level6    = "data/drlhq/music/cde1m6.mp3",
	level7    = "data/drlhq/music/cde1m4.mp3",
	level8    = "data/drlhq/music/cde1m8.mp3",
	level9    = "data/drlhq/music/cde1m1.mp3",
	level10   = "data/drlhq/music/cde1m2.mp3",
	level11   = "data/drlhq/music/cde1m3.mp3",
	level12   = "data/drlhq/music/cde1m4.mp3",
	level13   = "data/drlhq/music/cde1m5.mp3",
	level14   = "data/drlhq/music/cde1m6.mp3",
	level15   = "data/drlhq/music/cde1m7.mp3",
	level16   = "data/drlhq/music/cde1m9.mp3",
	level17   = "data/drlhq/music/cde1m2.mp3",
	level18   = "data/drlhq/music/cde1m3.mp3",
	level19   = "data/drlhq/music/cde1m4.mp3",
	level20   = "data/drlhq/music/cde1m5.mp3",
	level21   = "data/drlhq/music/cde1m6.mp3",
	level22   = "data/drlhq/music/cde1m7.mp3",
	level23   = "data/drlhq/music/cde1m9.mp3",
	level24   = "data/drlhq/music/cde1m2.mp3",
	level25   = "data/drlhq/music/cde1m3.mp3",

	hells_arena       = "data/drlhq/music/cde1m9.mp3",
	the_chained_court = "data/drlhq/music/rage.mp3",
	military_base     = "data/drlhq/music/cde1m9.mp3",
	halls_of_carnage  = "data/drlhq/music/cde1m9.mp3",
	hells_armory      = "data/drlhq/music/hells_weapons.mp3",
	spiders_lair      = "data/drlhq/music/cde1m3.mp3",
	city_of_skulls    = "data/drlhq/music/of_skull_and_bone.mp3",
	the_wall          = "data/drlhq/music/the_brick_song.mp3",
	unholy_cathedral  = "data/drlhq/music/unholy_cathedral.mp3",
	the_mortuary      = "data/drlhq/music/something_wicked.mp3",
	the_vaults        = "data/drlhq/music/dark_secrets.mp3",
	house_of_pain     = "data/drlhq/music/dark_secrets.mp3",
	the_lava_pits     = "data/drlhq/music/too_hot_down_here.mp3",

	phobos_lab        = "data/drlhq/music/cde1m5.mp3",
	deimos_lab        = "data/drlhq/music/hells_weapons.mp3",
	containment_area  = "data/drlhq/music/the_brick_song.mp3",
	abyssal_plains    = "data/drlhq/music/of_skull_and_bone.mp3",
	limbo             = "data/drlhq/music/something_wicked.mp3",
	mt_erebus         = "data/drlhq/music/too_hot_down_here.mp3",

	tower_of_babel    = "data/drlhq/music/cde1m8.mp3",
	hell_fortress     = "data/drlhq/music/final_showdown.mp3",
	dis               = "data/drlhq/music/cde1m8.mp3",
	victory           = "data/drlhq/music/d1readme.mp3",
}

sound = {
	--
	-- Enviroment
	
	-- Sound
	menu     = {
		change = "data/drlhq/sound/dspstop.wav",
		pick   = "data/drlhq/sound/dspistol.wav",
		cancel = "data/drlhq/sound/dsswtchx.wav",
	},
	
	-- Barrel
	
	barrel   = {
		move		= "data/drlhq/sound/dsstnmov.wav",
		movefail	= "data/drlhq/sound/dsnoway.wav",
		explode		= "data/drlhq/sound/dsbarexp.wav",
	},
	
	barrela  = {
		move		= "data/drlhq/sound/dsstnmov.wav",
		movefail	= "data/drlhq/sound/dsnoway.wav",
		explode		= "data/drlhq/sound/dsbarexp.wav",
	},
	
	barreln  = {
		move		= "data/drlhq/sound/dsstnmov.wav",
		movefail	= "data/drlhq/sound/dsnoway.wav",
		explode		= "data/drlhq/sound/dsbarexp.wav",
	},
	
	-- Door
	
	door			= {
		open		= "data/drlhq/sound/dsbdopn.wav",
		close		= "data/drlhq/sound/dsbdcls.wav",
	},
	
	-- Teleport
	
	teleport = {
		use			= "data/drlhq/sound/dstelept.wav",
	},
	
	-- Levers
	
	lever = {
		use				= "data/drlhq/sound/dsswtchn.wav",
	},
	
	-- Gib
	
	gib				= "data/drlhq/sound/dsslop.wav",
	
	--
	-- Powerups
	--
	
	-- Small Health Globe
	
	shglobe = {
		powerup		= "data/drlhq/sound/dsgetpow.wav",
	},
	
	-- Large Health Globe
	
	lhglobe = {
		powerup		= "data/drlhq/sound/dsgetpow.wav",
	},
	
	-- Supercharge Globe
	
	scglobe = {
		powerup		= "data/drlhq/sound/dsgetpow.wav",
	},
	
	-- Invulnerability Globe
	
	iglobe = {
		powerup		= "data/drlhq/sound/dsgetpow.wav",
	},
	
	-- Armor Shard
	
	ashard = {
		powerup		= "data/drlhq/sound/dsgetpow.wav",
	},
	
	-- Berserk Pack
	
	bpack = {
		powerup		= "data/drlhq/sound/dsgetpow.wav",
	},
	
	-- Computer Map
	
	map = {
		powerup		= "data/drlhq/sound/dsgetpow.wav",
	},
	
	-- Backpack
	
	backpack = {
		powerup		= "data/drlhq/sound/dsgetpow.wav",
	},
	
	--
	-- Pickups
	--
	
	-- Small Medkit
	
	smed = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
		use			= "data/drlhq/sound/dsgetpow.wav",
	},
	
	-- Large Medkit
	
	lmed = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
		use			= "data/drlhq/sound/dsgetpow.wav",
	},
	
	-- Phase Device
	
	phase = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
	},
	
	-- Homing Phase Device
	
	hphase = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
	},
	
	-- Envirosuit Pack
	
	epack = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
	},
	
	-- Thermonuclear Device
	
	nuke = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
		explode		= "data/drlhq/sound/dsfirxpl.wav",
	},
	
	-- Power Mod Pack
	
	mod_power = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
	},
	
	-- Agility Mod Pack
	
	mod_agility = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
	},
	
	-- Bulk Mod Pack
	
	mod_bulk = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
	},
	
	-- Technical Mod Pack
	
	mod_tech = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
	},
	
	--
	-- Armor and Boots
	--
	
	-- Green Armor
	
	garmor = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
	},
	
	-- Blue Armor
	
	barmor = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
	},
	
	-- Red Armor
	
	rarmor = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
	},
	
	-- Steel Boots
	
	sboots = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
	},
	
	-- Protective Boots
	
	pboots = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
	},
	
	-- Plasteel Boots
	
	psboots = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
	},
	
	--
	-- Ammunition
	--
	
	-- 10mm Ammo
	
	ammo = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
	},
	
	-- Shotgun Shell
	
	shell = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
	},
	
	-- Rocket
	
	rocket = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
	},
	
	-- Power Cell
	
	cell = {
		pickup		= "data/drlhq/sound/dsitemup.wav",
	},
	
	--
	-- Weapons
	--
	
	-- Combat Knife
	
	knife = {
		fire 		= "data/drlhq/sound/dspunch.wav",
		pickup		= "data/drlhq/sound/dswpnup.wav",
	},
	
	-- Pistol
	
	pistol = {
		fire		= "data/drlhq/sound/dspistol.wav",
		pickup		= "data/drlhq/sound/dswpnup.wav",
		reload		= "data/drlhq/sound/dswpnup.wav",
	},
	
	-- Shotgun
	
	shotgun = {
		fire		= "data/drlhq/sound/dsshotgn.wav",
		pickup		= "data/drlhq/sound/dswpnup.wav",
		reload		= "data/drlhq/sound/dswpnup.wav",
	},
	
	-- Combat Shotgun
	
	ashotgun = {
		fire		= "data/drlhq/sound/dsshotgn.wav",
		pickup		= "data/drlhq/sound/dswpnup.wav",
		reload		= "data/drlhq/sound/dswpnup.wav",
		pump		= "data/drlhq/sound/dssgcock.wav",
	},
	
	-- Double Shotgun
	
	dshotgun = {
		fire		= "data/drlhq/sound/dsdshtgn.wav",
		pickup		= "data/drlhq/sound/dswpnup.wav",
		reload		= "data/drlhq/sound/dswpnup.wav",
	},
	
	--sshotgun = {
	--	fire		= "data/drlhq/sound/dsdshtgn.wav",
	--	pickup		= "data/drlhq/sound/dswpnup.wav",
	--	reload		= "data/drlhq/sound/dswpnup.wav",
	--},
	
	-- Chaingun
	
	chaingun = {
		fire		= "data/drlhq/sound/dspistol.wav",
		pickup		= "data/drlhq/sound/dswpnup.wav",
		reload		= "data/drlhq/sound/dswpnup.wav",
	},
	
	-- Plasma Rifle
	
	plasma = {
		fire		= "data/drlhq/sound/dsplasma.wav",
		pickup		= "data/drlhq/sound/dswpnup.wav",
		reload		= "data/drlhq/sound/dswpnup.wav",
	},
	
	-- Rocket Launcher
	
	bazooka = {
		fire		= "data/drlhq/sound/dsrlaunc.wav",
		pickup		= "data/drlhq/sound/dswpnup.wav",
		reload		= "data/drlhq/sound/dswpnup.wav",
		explode		= "data/drlhq/sound/dsrxplod.wav",
	},
	
	--
	-- Creatures
	--
	
	-- Player
	
	soldier = {
		die			= "data/drlhq/sound/dspldeth.wav",
		hit			= "data/drlhq/sound/dsplpain.wav",
		melee		= "data/drlhq/sound/dspunch.wav",
		phase		= "data/drlhq/sound/dstelept.wav",
	},
	
	-- Former Human
	
	former = {
		die			= "data/drlhq/sound/dspodth1.wav",
		act			= "data/drlhq/sound/dsposact.wav",
		hit			= "data/drlhq/sound/dspopain.wav",
		melee		= "data/drlhq/sound/dspunch.wav",
	},
	
	-- Former Sergeant
	
	sergeant = {
		die			= "data/drlhq/sound/dspodth2.wav",
		act			= "data/drlhq/sound/dsposact.wav",
		hit			= "data/drlhq/sound/dspopain.wav",
		melee		= "data/drlhq/sound/dspunch.wav",
	},
	
	-- Former Captain
	
	captain = {
		die			= "data/drlhq/sound/dspodth2.wav",
		act			= "data/drlhq/sound/dsposact.wav",
		hit			= "data/drlhq/sound/dspopain.wav",
		melee		= "data/drlhq/sound/dspunch.wav",
	},
	
	-- Former Commando
	
	commando = {
		die			= "data/drlhq/sound/dspodth3.wav",
		act			= "data/drlhq/sound/dsposact.wav",
		hit			= "data/drlhq/sound/dspopain.wav",
		melee		= "data/drlhq/sound/dspunch.wav",
	},
	
	-- Imp
	
	imp = {
		die			= "data/drlhq/sound/dsbgdth1.wav",
		act			= "data/drlhq/sound/dsbgact.wav",
		hit			= "data/drlhq/sound/dspopain.wav",
		melee		= "data/drlhq/sound/dsclaw.wav",
		fire		= "data/drlhq/sound/dsfirsht.wav",
		explode		= "data/drlhq/sound/dsfirxpl.wav",
	},
	
	-- Lost Soul
	
	lostsoul = {
		die			= "data/drlhq/sound/dsfirxpl.wav",
		act			= "data/drlhq/sound/dssklatk.wav",
		hit			= "data/drlhq/sound/dsdmpain.wav",
		melee		= "data/drlhq/sound/dssklatk.wav",
	},
	
	-- Pain Elemental
	
	pain = {
		die			= "data/drlhq/sound/dspedth.wav",
		act			= "data/drlhq/sound/dspesit.wav",
		hit			= "data/drlhq/sound/dspepain.wav",
		melee		= "data/drlhq/sound/dsclaw.wav";
	},
	
	-- Demon
	
	demon = {
		die			= "data/drlhq/sound/dssgtdth.wav",
		act			= "data/drlhq/sound/dsdmact.wav",
		hit			= "data/drlhq/sound/dsdmpain.wav",
		melee		= "data/drlhq/sound/dssgtatk.wav",
	},
	
	-- Cacodemon
	
	cacodemon = {
		die			= "data/drlhq/sound/dscacdth.wav",
		act			= "data/drlhq/sound/dscacsit.wav",
		hit			= "data/drlhq/sound/dsdmpain.wav",
		melee		= "data/drlhq/sound/dsclaw.wav",
		fire		= "data/drlhq/sound/dsfirsht.wav",
		explode		= "data/drlhq/sound/dsfirxpl.wav",
	},
	
	-- Arachnotron
	
	arachno = {
		die			= "data/drlhq/sound/dsbspdth.wav",
		act			= "data/drlhq/sound/dsbspact.wav",
		hit			= "data/drlhq/sound/dsdmpain.wav",
		melee		= "data/drlhq/sound/dsclaw.wav",
		fire		= "data/drlhq/sound/dsplasma.wav",
	},
	
	-- Hell Knight
	
	knight = {
		die			= "data/drlhq/sound/dskntdth.wav",
		act			= "data/drlhq/sound/dskntsit.wav",
		hit			= "data/drlhq/sound/dsdmpain.wav",
		melee		= "data/drlhq/sound/dsclaw.wav",
		fire		= "data/drlhq/sound/dsfirsht.wav",
		explode		= "data/drlhq/sound/dsfirxpl.wav",
	},
	
	-- Baron of Hell
	
	baron = {
		die			= "data/drlhq/sound/dsbrsdth.wav",
		act			= "data/drlhq/sound/dsbrssit.wav",
		hit			= "data/drlhq/sound/dsdmpain.wav",
		melee		= "data/drlhq/sound/dsclaw.wav",
		fire		= "data/drlhq/sound/dsfirsht.wav",
		explode		= "data/drlhq/sound/dsfirxpl.wav",
	},
	
	-- Mancubus
	
	mancubus = {
		die			= "data/drlhq/sound/dsmandth.wav",
		act			= "data/drlhq/sound/dsmansit.wav",
		hit			= "data/drlhq/sound/dsmnpain.wav",
		fire		= "data/drlhq/sound/dsfirsht.wav",
		explode		= "data/drlhq/sound/dsfirxpl.wav",
	},
	
	-- Revenant
	
	revenant = {
		die			= "data/drlhq/sound/dsskedth.wav",
		act			= "data/drlhq/sound/dsskesit.wav",
		hit			= "data/drlhq/sound/dspopain.wav",
		melee		= "data/drlhq/sound/dsskepch.wav",
		fire		= "data/drlhq/sound/dsskeatk.wav",
		explode		= "data/drlhq/sound/dsbarexp.wav",
	},
	
	-- Arch-vile
	
	arch = {
		die			= "data/drlhq/sound/dsvildth.wav",
		act			= "data/drlhq/sound/dsvilact.wav",
		hit			= "data/drlhq/sound/dsvipain.wav",
		fire		= "data/drlhq/sound/dsvilatk.wav",
	},

	-- Shambler
	
	shambler = {
		act			= "data/drlhq/sound/dsbrssit.wav",
		die			= "data/drlhq/sound/dsbspdth.wav",
	},

	-- Lava Elemental
	
	lava_elemental = {
		die			= "data/drlhq/sound/dsvildth.wav",
	},

	-- Bruiser Brothers
	
	bruiser = {
		die			= "data/drlhq/sound/dsbrsdth.wav",
		act			= "data/drlhq/sound/dsbrssit.wav",
		hit			= "data/drlhq/sound/dsdmpain.wav",
		melee		= "data/drlhq/sound/dsclaw.wav",
		fire		= "data/drlhq/sound/dsfirsht.wav",
		explode		= "data/drlhq/sound/dsfirxpl.wav",
	},
	
	-- Cyberdemon
	
	cyberdemon = {
		die			= "data/drlhq/sound/dscybdth.wav",
		act			= "data/drlhq/sound/dscybsit.wav",
		hit			= "data/drlhq/sound/dsdmpain.wav",
		hoof		= "data/drlhq/sound/dshoof.wav",
	},
	
	-- JC

	jc = {
		die			= "data/drlhq/sound/dspodth1.wav",
		act			= "data/drlhq/sound/dsposact.wav",
		hit			= "data/drlhq/sound/dspopain.wav",
		melee		= "data/drlhq/sound/dspunch.wav",
	},

	-- AoD

	angel = {
		die			= "data/drlhq/sound/dsbrsdth.wav",
		act			= "data/drlhq/sound/dsbrssit.wav",
		hit			= "data/drlhq/sound/dsbrssit.wav",
		melee		= "data/drlhq/sound/dsclaw.wav",
		hoof		= "data/drlhq/sound/dshoof.wav";
	},
	
	-- Mastermind
	
	mastermind = {
		die			= "data/drlhq/sound/dsspidth.wav",
		act			= "data/drlhq/sound/dsdmact.wav",
		hit			= "data/drlhq/sound/dsdmpain.wav",
		melee		= "data/drlhq/sound/dsclaw.wav",
		hoof		= "data/drlhq/sound/dsmetal.wav";
	},
	
	--
	-- Exotic Items
	--
	
	-- Exotic #18 (Chainsaw)
	
	chainsaw = {
		fire		= "data/drlhq/sound/dssawhit.wav",
		pickup		= "data/drlhq/sound/dswpnup.wav",
	},
	
	-- Exotic #19 (BFG 9000)
	
	bfg9000 = {
		fire		= "data/drlhq/sound/dsbfg.wav",
		pickup		= "data/drlhq/sound/dswpnup.wav",
		reload		= "data/drlhq/sound/dswpnup.wav",
		explode		= "data/drlhq/sound/dsrxplod.wav",
	},
	
	--
	-- Unique Items
	--
	
	-- Unique #17 (Longinus Spear)
	
	spear = {
		fire		= "data/drlhq/sound/dsgetpow.wav",
		pickup		= "data/drlhq/sound/dswpnup.wav",
		explode		= "data/drlhq/sound/dsrxplod.wav",
	},
	
	--
	-- Default sounds
	--
	
	melee			= "data/drlhq/sound/dsclaw.wav",
	reload			= "data/drlhq/sound/dswpnup.wav",
	pickup			= "data/drlhq/sound/dsitemup.wav",
	fire			= "data/drlhq/sound/dsfirsht.wav",
	use				= "data/drlhq/sound/dsgetpow.wav",
	explode			= "data/drlhq/sound/dsfirxpl.wav",
	powerup			= "data/drlhq/sound/dsgetpow.wav",
	phasing			= "data/drlhq/sound/dstelept.wav",
}
