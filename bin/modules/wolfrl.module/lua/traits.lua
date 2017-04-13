--[[ Some quotes I've picked up that could be useful (Patton qotes are quite good for DoomRL :)
 *A good plan violently executed now is better than a perfect plan executed next week. 
 *A pint of sweat will save a gallon of blood.
 *A sucking chest wound is Nature's way of telling you to slow down.
 *All warfare is based on deception.
 *Alright you bastards, try and shoot me!
 *Any excuse to wear a sword is a good excuse.
 *Courage is fear holding on a minute longer. 
 *Few men are killed by the bayonet, many are scared by it. Bayonets should be fixed when the fire fight starts
 *Fixed fortifications are monuments to the stupidity of man.
 *God is not on the side of the big battalions, but on the side of those who shoot best.
 *I should have been delighted had it come to a fight. I felt absolutely sure of myself with a pistol in my hand.
 *If I want your opinion, I'll read it in your entrails.
 *If it's worth fighting for...it's worth fighting dirty for.
 *If the enemy is within range, so are you.
 *Incoming fire has the right of way.
 *It's not the one with your name on it; it's the one addressed "to whom it may concern" you've got to think about.
 *Just drive down that road, until you get blown up
 *Make your plans to fit the circumstances.
 *Never tell people how to do things. Tell them what to do and they will surprise you with their ingenuity. 
 *No bastard ever won a war by dying for his country. He won it by making the other poor dumb bastard die for his country.
 *No one ever goes into battle thinking God is on the other side.
 *Peace is that brief glorious moment in history when everybody stands around reloading.
 *The God of War hates those who hesitate.
 *There is only one tactical principle which is not subject to change. It is to use the means at hand to inflict the maximum amount of wound, death, and destruction on the enemy in the minimum amount of time.
 *To halt under fire is folly. To halt under fire and not fire back is suicide.
 *Wars may be fought with weapons, but they are won by men.
 *We're a simple people... but piss us off, and we'll bomb your cities.
 *We're all given some sort of skill in life. Mine just happens to be beating up on people.
 *Well, I'm about as tall as a shotgun, and just as noisy. 
 *Whoever said the pen is mightier then the sword obviously never encountered automatic weapons.
 *You're never beaten until you admit it.
 An army is a team. It lives, eats, sleeps, fights as a team.
 Battles are sometimes won by generals; wars are nearly always won by sergeants and privates.
 Beautiful that war and all its deeds of carnage, must in time be utterly lost; 
 Do your damnedest in an ostentatious manner all the time.
 Either war is obsolete or men are.
 Go forward until the last round is fired and the last drop of gas is expended...then go forward on foot!
 Great. Now we can shoot at those bastards from every direction.
 I am a soldier, I fight where I am told, and I win where I fight. 
 I have never advocated war except as a means of peace. 
 I love the smell of Napalm in the morning.
 I want to go where the guns are!
 In war there is no prize for the runner-up.
 It is foolish and wrong to mourn the men who died. Rather we should thank God that such men lived.
 It is war that shapes peace, and armament that shapes war.
 It is well that war is so terrible. We should grow too fond of it. 
 Lead me, follow me, or get out of my way. 
 May God have mercy upon my enemies, because I won't.
 Moral courage is the most valuable and usually the most absent characteristic in men.
 Never in the field of human conflict was so much owed by so many to so few. 
 Only the dead have seen the end of the war. 
 Only the dead have seen the end of war.
 Peace Through Superior Firepower
 The art of war is simple enough. Find out where your enemy is. Get at him as soon as you can. Strike him as hard as you can, and keep moving.
 The best weapon against an enemy is another enemy. 
 There is no arguing with him for if his pistol misses fire he simply knocks you down with the butt end of it
 There is no avoiding war; it can only be postponed to the advantage of others. 
 There never was a good war or a bad peace. 
 They are in front of us, behind us, and we are flanked on both sides by an enemy that outnumbers us 29:1. They can't get away from us now!
 Victory at all costs, victory in spite of all terror, victory however long and hard the road may be; for without victory there is no survival.
 War does not determine who is right - only who is left. 
 Wars have never hurt anybody except the people who die. 
 Watch what people are cynical about, and one can often discover what they lack.
 We shall fight on the beaches, we shall fight on the landing grounds, we shall fight in the fields and in the streets, we shall fight in the hills; we shall never surrender,
 We're surrounded. That simplifies our problem of getting to these people and killing them.
 When you have to kill a man it costs nothing to be polite.
 Where do you put the bayonet?
 You don't hurt 'em if you don't hit 'em
--]]
function DoomRL.load_traits()
	core.unregister( traits )
	traits.__name      = "traits"
	traits.__blueprint = "trait"

	register_trait "ironman" {
		name   = "Ironman",
		desc   = "Increases hitpoints by 20%/level.",
		quote  = "\"No bastard ever won a war by dying for his country.\"",
		full   = "You're a diehard piece of shit. You'll keep on fighting until all your bones are broken and you have no blood left. Every level of this trait increases your health by 20% of nominal value.",
		abbr   = "Iro",
		OnPick = function (being)
			local inc = math.floor(0.2 * being.hpnom)
			being.hpmax = being.hpmax + inc
			being.hp    = being.hp + inc
		end,
	}
	register_trait "finesse" {
		name   = "Finesse",
		desc   = "Attack time by -15%/level.",
		quote  = "\"The God of War hates those who hesitate.\"",
		full   = "Have you heard of an itchy trigger finger? Yours are itchier than the chicken pox, and because of that you can fire rounds and attack 15% faster with every level of this trait.",
		abbr   = "Fin",
		OnPick = function (being)
			being.firetime = being.firetime - 15
		end,
	}
	register_trait "hellrunner" {
		name   = "Hellrunner",
		desc   = "Movecost -15%/lv, Dodge chance +15%/lv.",
		quote  = "\"A good plan violently executed now is better than a perfect plan executed next week.\"",
		full   = "You're like a train on legs - not only do you move 15% faster for every level of this trait but you also get an extra 15% chance to dodge those pesky bullets coming your way.",
		abbr = "HR",
		OnPick = function (being)
			being.movetime = being.movetime - 15
			being.dodgebonus = being.dodgebonus + 15
		end,
	}
	register_trait "nails" {
		id     = "nails",
		name   = "Tough as nails",
		desc   = "Increases body armor by 1/level.",
		quote  = "\"A sucking chest wound is Nature's way of telling you to slow down.\"",
		full   = "That sound you're hearing isn't from the bullets flying off the walls, but from the bullets flying off of YOU! Your skin is so hard that you'll shrug off 1 more point of damage for every level of this trait.",
		abbr   = "TaN",
		OnPick = function (being)
			being.armor = being.armor + 1
		end,
	}
	register_trait "bitch" {
		id     = "bitch",
		name   = "Son of a bitch",
		desc   = "Increases damage by 1/level.",
		quote  = "\"There is only one tactical principle which is not subject to change. It is to use the means at hand to inflict the maximum amount of wound, death, and destruction on the enemy in the minimum amount of time.\"",
		full   = "You're the meanest, toughest bastard in your entire squad. You relish pain and enjoy dishing it out even more. Even demons know you by name, because with every level of this trait, you do 1 more damage than your average soldier.",
		abbr   = "SoB",
		OnPick = function (being)
			being.todamall = being.todamall + 1
		end,
	}
	register_trait "gun" {
		id     = "gun",
		name   = "Son of a gun",
		desc   = "Pistol: firing time -20%/lv. Dmg+1/lv.",
		quote  = "\"I should have been delighted had it come to a fight. I felt absolutely sure of myself with a pistol in my hand.\"",
		full   = "You love your pistols. You clean them every day and make sure they are always in top condition. You know your pistols so well that for every level of this trait you can fire them 20% faster and deal 1 more damage.",
		abbr   = "SoG",
		OnPick = function (being)
			being.pistolbonus = being.pistolbonus + 1
		end,
	}
	register_trait "reloader" {
		name   = "Reloader",
		desc   = "Each level reduces reload time by 20%.",
		quote  = "\"Peace is that brief glorious moment in history when everybody stands around reloading.\"",
		full   = "So you're out of ammo... no problem! You're especially gifted at keeping your gun well-fed - for every level of this trait, you can reload your gun 20% faster than the average marine!",
		abbr   = "Rel",
		OnPick = function (being)
			being.reloadtime = being.reloadtime - 20
		end,
	}
	register_trait "eagle" {
		id     = "eagle",
		name   = "Eagle Eye",
		desc   = "Each level increases to hit chance by 2.",
		quote  = "\"God is not on the side of the big battalions, but on the side of those who shoot best.\"",
		full   = "You could knock a fly off the wall at 200 yards, but you prefer to hunt bigger, nastier prey. With each level of this trait, you'll increase your chance to hit by 2 points.",
		abbr   = "EE",
		OnPick = function (being)
			being.tohit = being.tohit + 2
		end,
	}
	register_trait "brute" {
		name   = "Brute",
		desc   = "Increases melee damage by +3/lv.",
		quote  = "\"We're all given some sort of skill in life. Mine just happens to be beating up on people.\"",
		full   = "You don't need a gun - guns are for wusses! With each level of this trait you'll deal 3 more damage while bashing your enemies with your hands, knives, body parts, or whatever else is available. Also your melee accuracy increases by 2.",
		abbr   = "Bru",
		OnPick = function (being)
			being.todam = being.todam + 3
			being.tohitmelee = being.tohitmelee + 2
		end,
	}

	register_trait "juggler" {
		name   = "Juggler",
		desc   = "Uses melee weapon if prepared.",
		quote  = "\"Make your plans to fit the circumstances.\"",
		full   = "Your hands are so nimble you could work at a circus. Unfortunately, the army got you first. The only benefit of your skill now is that you instantly swap prepared and quickkeyed weapons, and automatically use a prepared melee weapon when need arises!",
		abbr   = "Jug",
		OnPick = function (being)
			being.flags[ BF_QUICKSWAP ] = true
		end,
	}
	register_trait "berserker" {
		name   = "Berserker",
		desc   = "Gives chance of berserking in melee.",
		quote  = "\"We're a simple people, but piss us off and we'll bomb your cities.\"",
		full   = "You hate this place, you hate these stupid nazis, and you HATE that this is all happening to you. In fact you hate it so much that there's a chance that you'll fly into a berserk rage when you repeatedly smack someone in melee, or get hit hard enough. (NOTE: You do NOT get the healing effect of a Berserk Pack.)",
		abbr   = "Ber",
		OnPick = function (being)
			being.flags[ BF_BERSERKER ] = true
		end,
	}
	register_trait "dualgunner" {
		name   = "Dualgunner",
		desc   = "Allows dual pistol firing.",
		quote  = "\"Gun plus gun equals more gun.\"",
		full   = "You're the kind of guy for whom one is never enough. When you and your buddies cruised bars stateside, you always had a beer in each hand and when you left, you left with two girls. Where you're going now there aren't beer or girls, but there are guns! This trait lets you wield two pistols at once, firing them almost as fast as one (120% time taken).",
		abbr   = "DG",
		OnPick = function (being)
			being.flags[ BF_DUALGUN ] = true
		end,
	}
	register_trait "dodgemaster" {
		name   = "Dodgemaster",
		desc   = "First dodge in turn always succeeds.",
		quote  = "\"Alright you bastards, try and shoot me!\"",
		full   = "The battlefield is a dance for you! Each first sidestep after your move will automatically succeed.",
		author = "Kornel",
		abbr   = "DM",
		OnPick = function (being)
			being.flags[ BF_MASTERDODGE ] = true
		end,
	}
	register_trait "intuition" {
		name   = "Intuition",
		desc   = "Provides additional sense.",
		quote  = "\"All warfare is based on deception.\"",
		full   = "Something's kept you alive all these years. Call it a sixth sense, call it a survival instinct, call it blind friggin' luck. All you know for sure is that where other men die, you live. The first level of this trait lets you evaluate levers and sense powerups, the second level lets you sense enemies.",
		author = "Derek",
		abbr   = "Int",
		OnPick = function (being,level)
			if level == 1 then
				being.flags[ BF_LEVERSENSE1 ] = true
				being.flags[ BF_POWERSENSE  ] = true
			elseif level == 2 then
				being.flags[ BF_LEVERSENSE2 ] = true
				being.flags[ BF_BEINGSENSE  ] = true
			end
		end,
	}
	register_trait "whizkid" {
		name   = "Whizkid",
		desc   = "Increases maximum amount of mod slots",
		quote  = "\"Never tell people how to do things. Tell them what to do and they will surprise you with their ingenuity.\"",
		full   = "You always were a brainy guy... Mom said you could have been an inventor but the Marine Corps picked you up first. Whether it's a toaster or a chaingun, there's always room for improvement! And with each level of this trait you can increase the number of mod slots on a weapon by 2 (by 1 on a armor).",
		author = "Kornel",
		abbr   = "WK",
		OnPick = function (being)
			being.techbonus = being.techbonus + 1
		end,
	}
	register_trait "badass" {
		name   = "Badass",
		desc   = "Decreases knockback taken and increases health decay limit",
		quote  = "\"If it's worth fighting for it's worth fighting dirty for.\"",
		full   = "You're the ultimate badass. Your blood runs so cold that it could make Hell freeze over (if they weren't too scared to take you). For each level, your maximum health before decay sets in is 50% higher, and you're knocked back one space less.",
		author = "Malek",
		abbr   = "Bad",
		OnPick = function (being)
			being.bodybonus  = being.bodybonus + 1
			being.hpdecaymax = being.hpdecaymax + 50
		end,
	}
	register_trait "shottyman" {
		name   = "Shottyman",
		desc   = "Allows shotgun reloading on the move.",
		quote  = "\"I think you need a shotgun blast.\"",
		full   = "You and your shotgun have been through a lot together. You take care of him, and he \"takes care\" of any dumb bastard to get in your way. Through it all, you've learned that, in the middle of a firefight, if you stand still to reload, you die. So by taking this trait you gain the ability to reload shotguns on the move... and I do mean ALL shotguns.",
		author = "Malek",
		abbr   = "SM",
		OnPick = function (being)
			being.flags[ BF_SHOTTYMAN ] = true
		end,
	}
	register_trait "triggerhappy" {
		name   = "Triggerhappy",
		desc   = "+1 rapid weapon shots per weapon.",
		quote  = "\"Whoever said the pen is mightier then the sword obviously never encountered automatic weapons.\"",
		full   = "\"Shoot first and shoot fast\" has always been your motto. And nobody shoots faster than you. With each weapon you get an extra rapid shot per level of this trait.",
		author = "Kornel",
		abbr   = "TH",
		OnPick = function (being)
			being.rapidbonus = being.rapidbonus + 1
		end,
	}

	register_trait "blademaster" {
		name   = "Blademaster",
		desc   = "Free action after melee kill.",
		quote  = "\"Any excuse to wear a sword is a good excuse.\"",
		full   = "You've mastered melee combat. Each time you finish off an opponent, you're immediately ready for another kill, and gain a free action!",
		author = "Kornel",
		abbr   = "MBm",
		master = true,
		OnPick = function (being)
			being.flags[ BF_CLEAVE ] = true
		end,
	}
	register_trait "vampyre" {
		name   = "Vampyre",
		desc   = "+3 HP after melee kill.",
		quote  = "\"A pint of sweat will save a gallon of blood.\"",
		full   = "You hunger for blood! Each time you finish off an opponent you gain +3 HP.",
		author = "Kornel",
		abbr   = "MVm",
		master = true,
		OnPick = function (being)
			being.flags[ BF_VAMPYRE ] = true
		end,
	}
	register_trait "malicious" {
		id     = "malicious",
		name   = "Malicious Blades",
		desc   = "Allows dual attack using blades and gives 75% melee resist if blade in off hand",
		quote  = "\"Few men are killed by the bayonet but many are scared by it\"",
		full   = "Knives, knives, knives! You can attack with a blade in each hand at the same time, and while carrying a blade in your off hand, you parry 75% melee damage, and shield against 50% bullet, shrapnel and fire damage!",
		abbr   = "MMB",
		master = true,
		OnPick = function (being)
			being.flags[ BF_DUALBLADE ] = true
			being.flags[ BF_BLADEDEFEND ] = true
		end,
	}
	register_trait "bulletdance" {
		id     = "bulletdance",
		name   = "Bullet Dance",
		desc   = "Allows triggerhappy to work on pistols",
		quote  = "\"It's not the one with your name on it, it's the one addressed 'to whom it may concern' you've got to think about.\"",
		full   = "Pistols are your game -- you can squeeze an additional shot from each of your pistols for each level of Triggerhappy at half the time cost!",
		abbr   = "MBD",
		master = true,
		OnPick = function (being)
			being.flags[ BF_BULLETDANCE ] = true
		end,
	}
	register_trait "gunkata" {
		id     = "gunkata",
		name   = "Gun Kata",
		desc   = "Free action after pistol kill.",
		quote  = "\"No one ever goes into battle thinking God is on the other side.\"",
		full   = "You've mastered the martial art of pistol combat. After each successful dodge you can fire your pistols in almost no time. Also, each time you finish off an opponent, you immediately reload your guns!",
		author = "Kornel",
		abbr   = "MGK",
		master = true,
		OnPick = function (being)
			being.flags[ BF_GUNKATA ] = true
		end,
	}
	register_trait "sharpshooter" {
		name   = "Sharpshooter",
		desc   = "Pistol shots always deal max damage",
		quote  = "\"Courage is fear holding on a minute longer.\"",
		full   = "You always hit them where it counts! Each pistol shot you inflict deals maximum possible damage!",
		abbr   = "MSs",
		master = true,
		OnPick = function (being)
			being.flags[ BF_PISTOLMAX ] = true
		end,
	}
	register_trait "armydead" {
		id     = "armydead",
		name   = "Army of the Dead",
		desc   = "Shotguns ignore armor.",
		quote  = "\"Just drive down that road until you get blown up.\"",
		full   = "You're the fucking army of justice. When you fire your trusty shotgun, no armor is a protection!",
		author = "Kornel",
		abbr   = "MAD",
		master = true,
		OnPick = function (being)
			being.flags[ BF_ARMYDEAD ] = true
		end,
	}
	register_trait "shottyhead" {
		name   = "Shottyhead",
		desc   = "Shotgun fire time is %20",
		quote  = "\"Well, I'm about as tall as a shotgun, and just as noisy.\"",
		full   = "Shotgun is the gun on the move! While you can already reload on the move, this trait allows you to cut firetime to 1/3rd of the original!",
		abbr   = "MSh",
		master = true,
		OnPick = function (being)
			being.flags[ BF_SHOTTYHEAD ] = true
		end,
	}
	register_trait "fireangel" {
		name   = "Fireangel",
		desc   = "Explosion damage has no effect, only direct hits.",
		quote  = "\"Napalm is an area support weapon.\"",
		full   = "You love heat, you're the angel of fire! No explosion affects you, unless you take a direct hit.",
		author = "Kornel",
		abbr   = "MFa",
		master = true,
		OnPick = function (being)
			being.flags[ BF_FIREANGEL ] = true
		end,
	}
	register_trait "ammochain" {
		name   = "Ammochain",
		desc   = "Rapid-fire shots take 1 ammo per volley.",
		quote  = "\"Incoming fire has the right of way.\"",
		full   = "True gunners do not think of such unimportant things like ammo supply! As long as you use your trusty rapid fire weapons you only use up one ammo per volley!",
		author = "Kornel",
		abbr   = "MAc",
		master = true,
		OnPick = function (being)
			being.flags[ BF_AMMOCHAIN ] = true
		end,
	}
	register_trait "cateye" {
		name   = "Cateye",
		desc   = "Increases sight range by 2.",
		quote  = "\"If the enemy is within range, so are you.\"",
		full   = "Your eyes are so sharp they could cut through concrete. This trait lets you see your enemies from two spaces further away - and that means more time to shoot them!",
		abbr   = "MCe",
		master = true,
		OnPick = function (being)
			being.vision = being.vision + 2
		end,
	}
	register_trait "entrenchment" {
		name   = "Entrenchment",
		desc   = "When chainfiring your resistances get a +30% bonus",
		quote  = "\"Fixed fortifications are monuments to the stupidity of man.\"",
		full   = "Once the barrels get rollin' you become one hardcore fighting platform... When chainfiring a rapid weapon you get +30% to all resistances!",
		abbr   = "MEn",
		master = true,
		OnPick = function (being)
			being.flags[ BF_ENTRENCHMENT ] = true
		end,
	}
	register_trait "survivalist" {
		name   = "Survivalist",
		desc   = "No minimum damage taken, medpacks heal over 100%",
		quote  = "\"You're never beaten until you admit it.\"",
		full   = "You're the mean motherfucker who gets through every predicament! Half the time you completely shrug off damage that would graze others and you heal over 100% using simple medpacks!",
		abbr   = "MSv",
		master = true,
		OnPick = function (being)
			being.flags[ BF_MEDPLUS ] = true
			being.flags[ BF_HARDY ] = true
		end,
	}
	register_trait "running" {
		id     = "running",
		name   = "Running Man",
		desc   = "Running time *2, no to hit penalty",
		quote  = "\"To halt under fire is folly.\"",
		full   = "You're the man on the run! Not only can you run twice as long, but you do not suffer any aiming penalties while doing so!",
		abbr   = "MRM",
		master = true,
		OnPick = function (being)
			being.runningtime = being.runningtime * 2
			being.flags[ BF_NORUNPENALTY ] = true
		end,
	}
--[[	register_trait "gunrunner" {
		name   = "Gunrunner",
		desc   = "Running time *1.5, free non-rapid shot if run moving",
		quote  = "\"To halt under fire is folly.\"",
		full   = "You're the man on the run! Not only can you run longer, but while running with a loaded non-rapid weapon in your hands, every move you automatically shoot the nearest enemy for free!",
		abbr   = "MGr",
		master = true,
		OnPick = function (being)
			being.runningtime = math.floor( being.runningtime * 1.5 )
			being.flags[ BF_GUNRUNNER ] = true
		end,
	}
--]]
	register_trait "scavenger" {
		name   = "Scavenger",
		desc   = "Allows dissasembling uniques and exotics into mods",
		quote  = "\"Wars may be fought with weapons, but they are won by men.\"",
		full   = "Whether it's a unique, exotic, assembled or modified gun, you can always make use of it! Just Unload it once it's fully unloaded and you can scrap it for a useful mod pack!",
		abbr   = "MSc",
		master = true,
		OnPick = function (being)
			being.flags[ BF_SCAVENGER ] = true
		end,
	}

end
