function DoomRL.load_traits()

	register_trait "ironman"
	{
		name   = "Ironman",
		desc   = "Increases hitpoints by 20% starting HP/lv.",
		quote  = "\"Just a couple of broken ribs, it's nothing. To stop me... you've got to smash my head or take my heart out.\"",
		full   = "You're a diehard piece of shit. You'll keep on fighting until all your bones are broken and you have no blood left. Every level of this trait increases your health by 20% of your starting HP.",
		abbr   = "Iro",

		OnPick = function (being)
			local inc = math.floor(0.2 * being.hpnom)
			being.hpmax = being.hpmax + inc
			being.hp    = being.hp + inc
		end,
	}

	register_trait "finesse"
	{
		name   = "Finesse",
		desc   = "Attack time by -15%/lv.",
		quote  = "\"Dance! Dance, bonedaddy!\"",
		full   = "Have you heard of an itchy trigger finger? Yours are itchier than the chicken pox, and because of that you can fire rounds and attack 15% faster with every level of this trait.",
		abbr   = "Fin",

		OnPick = function (being)
			being.firetime = being.firetime - 15
		end,
	}

	register_trait "hellrunner"
	{
		name   = "Hellrunner",
		desc   = "Movecost -15%/lv, Dodge chance +15%/lv.",
		quote  = "\"Ohh, here it comes! Here comes the night train! Choo choo cha boogie!\"",
		full   = "You're like a train on legs - not only do you move 15% faster for every level of this trait but you also get an extra 15% chance to dodge those pesky bullets coming your way.",
		abbr = "HR",

		OnPick = function (being)
			being.movetime = being.movetime - 15
			being.dodgebonus = being.dodgebonus + 15
		end,
	}

	register_trait "nails"
	{
		name   = "Tough as nails",
		desc   = "Increases body armor by 1/lv.",
		quote  = "\"The horrors of Hell could not kill you!\"",
		full   = "That sound you're hearing isn't from the bullets flying off the walls, but from the bullets flying off of YOU! Your skin is so hard that you'll shrug off 1 more point of damage for every level of this trait.",
		abbr   = "TaN",

		OnPick = function (being)
			being.armor = being.armor + 1
		end,
	}

	register_trait "bitch"
	{
		name   = "Son of a bitch",
		desc   = "Increases damage by 1/lv.",
		quote  = "\"Kill them all, let God sort them out.\"",
		full   = "You're the meanest, toughest bastard in your entire squad. You relish pain and enjoy dishing it out even more. Even demons know you by name, because with every level of this trait, you do 1 more damage than your average Marine.",
		abbr   = "SoB",

		OnPick = function (being)
			being.todamall = being.todamall + 1
		end,
	}

	register_trait "gun"
	{
		name   = "Son of a gun",
		desc   = "Pistol: firing time -20%/lv, Dmg+1/lv.",
		quote  = "\"Dig the prowess, the capacity for violence!\"",
		full   = "You love your pistols. You clean them every day and make sure they are always in top condition. You know your pistols so well that for every level of this trait you can fire them 20% faster and deal 1 more damage.",
		abbr   = "SoG",

		OnPick = function (being)
			being.pistolbonus = being.pistolbonus + 1
		end,
	}

	register_trait "reloader"
	{
		name   = "Reloader",
		desc   = "Each level reduces reload time by 20%.",
		quote  = "\"The humanity! My big gun is out of bullets! I can't believe it!\"",
		full   = "So you're out of ammo... no problem! You're especially gifted at keeping your gun well-fed - for every level of this trait, you can reload your gun 20% faster than the average marine!",
		abbr   = "Rel",

		OnPick = function (being)
			being.reloadtime = being.reloadtime - 20
		end,
	}

	register_trait "eagle"
	{
		name   = "Eagle Eye",
		desc   = "Each level increases to hit chance by 2.",
		quote  = "\"One in the heart and one in the head, and don't you hesitate.\"",
		full   = "You could knock a fly off the wall at 200 yards, but you prefer to hunt bigger, nastier prey. With each level of this trait, you'll increase your chance to hit by 2 points.",
		abbr   = "EE",

		OnPick = function (being)
			being.tohit = being.tohit + 2
		end,
	}

	register_trait "brute"
	{
		name   = "Brute",
		desc   = "Increases melee damage by +3/lv.",
		quote  = "\"There's nothing wrong that I can't fix... with my hands!\"",
		full   = "You don't need a gun - guns are for wusses! With each level of this trait you'll deal 3 more damage while bashing your enemies with your hands, knives, body parts, or whatever else is available. Also your melee accuracy increases by 2.",
		abbr   = "Bru",

		OnPick = function (being)
			being.todam = being.todam + 3
			being.tohitmelee = being.tohitmelee + 2
		end,
	}

	register_trait "juggler"
	{
		name   = "Juggler",
		desc   = "Uses melee weapon if prepared.",
		quote  = "\"Allow me to communicate to you my desire to have your guns.\"",
		full   = "Your hands are so nimble you could work at a circus.  Unfortunately, the army got you first. The only benefit of your skill now is that you instantly swap prepared and quickkeyed weapons, and automatically use a prepared melee weapon when need arises!",
		abbr   = "Jug",

		OnPick = function (being)
			being.flags[ BF_QUICKSWAP ] = true
		end,
	}

	register_trait "berserker"
	{
		name   = "Berserker",
		desc   = "Gives chance of berserking in melee.",
		quote  = "\"Who's a man and a half? I'm a man and a half! Berserker packin' man and a half!\"",
		full   = "You hate this place, you hate these stupid monsters, and you HATE that this is all happening to you. In fact you hate it so much that there's a chance that you'll fly into a berserk rage when you repeatedly smack someone in melee, or get hit hard enough. (NOTE: You do NOT get the healing effect of a Berserk Pack.)",
		abbr   = "Ber",

		OnPick = function (being)
			being.flags[ BF_BERSERKER ] = true
		end,
	}

	register_trait "dualgunner"
	{
		name   = "Dualgunner",
		desc   = "Allows dual pistol firing.",
		quote  = "\"The only thing I believe is I need another gun.\"",
		full   = "You're the kind of guy for whom one is never enough. When you and your buddies cruised bars Earthside, you always had a beer in each hand and when you left, you left with two girls. Where you're going now there aren't beer or girls, but there are guns! This trait lets you wield two pistols at once, firing them almost as fast as one (120% time taken).",
		abbr   = "DG",

		OnPick = function (being)
			being.flags[ BF_DUALGUN ] = true
		end,
	}

	register_trait "dodgemaster"
	{
		name   = "Dodgemaster",
		desc   = "First dodge in turn always succeeds.",
		quote  = "\"Knock, knock. Who's there? Me, me, me, me, ME!\"",
		full   = "The battlefield is a dance for you! Each first sidestep after your move will automatically succeed.",
		author = "Kornel",
		abbr   = "DM",

		OnPick = function (being)
			being.flags[ BF_MASTERDODGE ] = true
		end,
	}

	register_trait "intuition"
	{
		name   = "Intuition",
		desc   = "Provides additional sense.",
		quote  = "\"As I stride knee deep through the dead, all is clear. I know what must be done.\"",
		full   = "Something's kept you alive all these years. Call it a sixth sense, call it a survival instinct, call it blind friggin' luck. All you know for sure is that where other men die, you live. The first level of this trait lets you evaluate levers and sense powerups, the second level lets you sense monsters.",
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

	register_trait "whizkid"
	{
		name   = "Whizkid",
		desc   = "Increases maximum amount of mod slots",
		quote  = "\"Not big guns, but they are guns!  And I need guns!\"",
		full   = "You were always a brainy guy... Mom said you could have been an inventor but the Marine Corps picked you up first. Whether it's a toaster or a chaingun, there's always room for improvement! And with each level of this trait you can increase the number of mod slots on a weapon by 2 (by 1 for armor/boot).",
		author = "Kornel",
		abbr   = "WK",

		OnPick = function (being)
			being.techbonus = being.techbonus + 1
		end,
	}

	register_trait "badass"
	{
		name   = "Badass",
		desc   = "Decreases knockback taken and increases health decay limit",
		quote  = "\"Who's the man? I'm the man! How bad? Real bad! I'm a 12.0 on a 10.0 scale of badness!\"",
		full   = "You're the ultimate badass. Your blood runs so cold that it could make Hell freeze over (if they weren't too scared to take you). For each level, your maximum health before decay sets in is 50% higher, and you're knocked back one space less.",
		author = "Malek",
		abbr   = "Bad",

		OnPick = function (being)
			being.bodybonus  = being.bodybonus + 1
			being.hpdecaymax = being.hpdecaymax + 50
		end,
	}

	register_trait "shottyman"
	{
		name   = "Shottyman",
		desc   = "Allows shotgun reloading on the move.",
		quote  = "\"At this particular moment in time I don't believe I have a more deepfelt respect for any object than this shotgun...\"",
		full   = "You and your shotgun have been through a lot together. You take care of him, and he \"takes care\" of any dumb bastard to get in your way. Through it all, you've learned that, in the middle of a firefight, if you stand still to reload, you die. So by taking this trait you gain the ability to reload shotguns on the move... ALL shotguns, and it surprisingly works for rocket launchers too!",
		author = "Malek",
		abbr   = "SM",

		OnPick = function (being)
			being.flags[ BF_SHOTTYMAN ] = true
			being.flags[ BF_ROCKETMAN ] = true
		end,
	}

	register_trait "triggerhappy"
	{
		name   = "Triggerhappy",
		desc   = "+1 rapid weapon shots per weapon.",
		quote  = "\"Ooh, I like it! The sugar-sweet kiss of heavy ordinance!\"",
		full   = "\"Shoot first and shoot fast\" has always been your motto. And nobody shoots faster than you. With each weapon you get an extra rapid shot per level of this trait.",
		author = "Kornel",
		abbr   = "TH",

		OnPick = function (being)
			being.rapidbonus = being.rapidbonus + 1
		end,
	}

	register_trait "blademaster"
	{
		name   = "Blademaster",
		desc   = "Free action after melee kill.",
		quote  = "\"Aaah! Chainsaw! The great communicator!\"",
		full   = "You've mastered melee combat. Each time you finish off an opponent, you're immediately ready for another kill, and gain a free action!",
		author = "Kornel",
		abbr   = "MBm",
		master = true,

		OnPick = function (being)
			being.flags[ BF_CLEAVE ] = true
		end,
	}

	register_trait "vampyre"
	{
		name   = "Vampyre",
		desc   = "+10% target MaxHP added to HP after melee kill.",
		quote  = "\"I crave for blood on this kind of night...\"",
		full   = "You hunger for blood! Each time you finish off an opponent with a melee attack, 10% of the target's max HP is added to your HP.",
		author = "Kornel",
		abbr   = "MVm",
		master = true,

		OnPick = function (being)
			being.flags[ BF_VAMPYRE ] = true
		end,
	}

	register_trait "malicious"
	{
		name   = "Malicious Blades",
		desc   = "Allows dual attack using blades and gives 75% melee resist if blade in off-hand",
		quote  = "\"Don't need a gun! Guns are for wusses!\"",
		full   = "Knives, knives, knives! You can attack with a blade in each hand at the same time, and while carrying a blade in your off-hand, you parry 75% melee damage, and shield against 50% bullet, shrapnel and fire damage!",
		abbr   = "MMB",
		master = true,

		OnPick = function (being)
			being.flags[ BF_DUALBLADE ] = true
			being.flags[ BF_BLADEDEFEND ] = true
		end,
	}

	register_trait "bulletdance"
	{
		name   = "Bullet Dance",
		desc   = "Allows triggerhappy to work on pistols",
		quote  = "\"Righteousness -- and superior firepower -- has triumphed!\"",
		full   = "Pistols are your game -- you can squeeze an additional shot from each of your pistols for each level of Triggerhappy at half the time cost!",
		abbr   = "MBD",
		master = true,

		OnPick = function (being)
			being.flags[ BF_BULLETDANCE ] = true
		end,
	}

	register_trait "gunkata"
	{
		name   = "Gun Kata",
		desc   = "Free action after pistol kill.",
		quote  = "\"Not without incident.\"",
		full   = "You've mastered the martial art of pistol combat. After each successful dodge you can fire your pistols in almost no time. Also, each time you finish off an opponent, you immediately reload your guns!",
		author = "Kornel",
		abbr   = "MGK",
		master = true,

		OnPick = function (being)
			being.flags[ BF_GUNKATA ] = true
		end,
	}

	register_trait "sharpshooter"
	{
		name   = "Sharpshooter",
		desc   = "Pistol shots always deal max damage",
		quote  = "\"My cause is just... my will is strong...\"",
		full   = "You always hit them where it counts! Each pistol shot you inflict deals maximum possible damage!",
		abbr   = "MSs",
		master = true,

		OnPick = function (being)
			being.flags[ BF_PISTOLMAX ] = true
		end,
	}

--[[
	register_trait "regenerator"
	{
		name   = "Regenerator",
		desc   = "Regenerate up to 20 Hp.",
		quote  = "",
		full   = "Your skin has unnatural healing abilities. You regenerate up to 10 HP at a rate of +1 per turn.",
		author = "Kornel",
		abbr   = "MRg",
		master = true,

		OnPick = function (being)
			being.flags[ BF_REGENERATE ] = true
		end
	}
--]]

	register_trait "armydead"
	{
		name   = "Army of the Dead",
		desc   = "Shotguns ignore armor.",
		quote  = "\"Might makes light! And I feel mighty!\"",
		full   = "You're the fucking army of justice. When you fire your trusty shotgun, no armor is a protection!",
		author = "Kornel",
		abbr   = "MAD",
		master = true,

		OnPick = function (being)
			being.flags[ BF_ARMYDEAD ] = true
		end,
	}

	register_trait "shottyhead"
	{
		name   = "Shottyhead",
		desc   = "Shotgun fire time is %20",
		quote  = "\"Groovy.\"",
		full   = "Shotgun is the gun on the move! While you can already reload on the move, this trait allows you to cut firetime to 1/3rd of the original!",
		abbr   = "MSh",
		master = true,

		OnPick = function (being)
			being.flags[ BF_SHOTTYHEAD ] = true
		end,
	}

	register_trait "fireangel"
	{
		name   = "Fireangel",
		desc   = "Explosion damage has no effect, only direct hits.",
		quote  = "\"Woo baby, I'm burnin' out of control!\"",
		full   = "You love heat, you're the angel of fire! No explosion affects you, unless you take a direct hit.",
		author = "Kornel",
		abbr   = "MFa",
		master = true,

		OnPick = function (being)
			being.flags[ BF_FIREANGEL ] = true
		end,
	}

	register_trait "ammochain"
	{
		name   = "Ammochain",
		desc   = "Rapid-fire shots take 1 ammo per volley.",
		quote  = "\"Hey, Chaingun! The hell with respect!\"",
		full   = "True gunners do not think of such unimportant things like ammo supply! As long as you use your trusty chain-fire weapons you only use up one ammo per volley!",
		author = "Kornel",
		abbr   = "MAc",
		master = true,

		OnPick = function (being)
			being.flags[ BF_AMMOCHAIN ] = true
		end,
	}

	register_trait "cateye"
	{
		name   = "Cateye",
		desc   = "Increases sight range by 2.",
		quote  = "\"Huh? Whuzzat? Whuzzat? I like what I see!\"",
		full   = "Your eyes are so sharp they could cut through concrete. This trait lets you see your enemies from two spaces further away - and that means more time to shoot them!",
		abbr   = "MCe",
		master = true,

		OnPick = function (being)
			being.vision = being.vision + 2
		end,
	}

	register_trait "entrenchment"
	{
		name   = "Entrenchment",
		desc   = "When chainfiring your resistances get a +30% bonus",
		quote  = "\"Hoy, hoy, I'm the boy... Packin' 80 pounds of heavenly joy!\"",
		full   = "Once the barrels get rollin' you become one hardcore fighting platform... when chainfiring a rapid weapon you get +30% to all resistances!",
		abbr   = "MEn",
		master = true,

		OnPick = function (being)
			being.flags[ BF_ENTRENCHMENT ] = true
		end,
	}

	register_trait "survivalist"
	{
		name   = "Survivalist",
		desc   = "No minimum damage taken, medpacks heal over 100%",
		quote  = "\"You want a piece of me? C'mon, c'mon. Come at me with it!\"",
		full   = "You're the mean motherfucker who gets through every predicament! Half the time you completely shrug off damage that would graze others and you heal over 100% using simple medpacks!",
		abbr   = "MSv",
		master = true,

		OnPick = function (being)
			being.flags[ BF_MEDPLUS ] = true
			being.flags[ BF_HARDY ] = true
		end,
	}

	register_trait "running"
	{
		name   = "Running Man",
		desc   = "Running time *2, no to hit penalty",
		quote  = "\"Movin' right along.\"",
		full   = "You're the man on the run! Not only can you run twice as long, but you do not suffer any aiming penalties while doing so!",
		abbr   = "MRM",
		master = true,

		OnPick = function (being)
			being.runningtime = being.runningtime * 2
			being.flags[ BF_NORUNPENALTY ] = true
		end,
	}

	register_trait "gunrunner"
	{
		name   = "Gunrunner",
		desc   = "Running time *1.5, free non-rapid shot if run moving",
		quote  = "\"Movin' right along.\"",
		full   = "You're the man on the run! Not only can you run longer, but while running with a loaded non-rapid weapon in your hands, every move you automatically shoot the nearest enemy for free!",
		abbr   = "MGr",
		master = true,

		OnPick = function (being)
			being.runningtime = math.floor( being.runningtime * 1.5 )
			being.flags[ BF_GUNRUNNER ] = true
		end,
	}

	register_trait "scavenger"
	{
		name   = "Scavenger",
		desc   = "Allows dissasembling uniques and exotics into mods",
		quote  = "\"I do need a gun. I need a big gun. I need a really big gun...\"",
		full   = "Whether it's a unique, exotic, assembled or modified gun, you can always make use of it! Just Unload it once it's fully unloaded and you can scrap it for a useful mod pack!",
		abbr   = "MSc",
		master = true,

		OnPick = function (being)
			being.flags[ BF_SCAVENGER ] = true
		end,
	}

end
