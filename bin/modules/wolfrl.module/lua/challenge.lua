function DoomRL.loadchallenges()

	-- CHALLENGE BERSERK
	register_badge "berserker1" {
		name  = "Berserker Bronze Badge",
		desc  = "Reach level 10 as a Berserker",
		level = 1,
	}
	register_badge "berserker2" {
		name  = "Berserker Silver Badge",
		desc  = "Win as a Berserker",
		level = 2,
	}
	register_badge "berserker3" {
		name  = "Berserker Gold Badge",
		desc  = "Win as a Berserker on DHM",
		level = 3,
	}
	register_badge "berserker4" {
		name  = "Berserker Platinum Badge",
		desc  = "Win as a Berserker on BMO",
		level = 4,
	}
	register_badge "berserker5" {
		name  = "Berserker Diamond Badge",
		desc  = "Win as a Berserker on DI",
		level = 5,
	}
	register_badge "berserker6" {
		name  = "Berserker Angelic Badge",
		desc  = "Berserker on DI with at least 60% kills",
		level = 6,
	}
	register_medal "gargulec1" {
		name  = "Gargulec Medal",
		desc  = "Win as a Berserker with 100% kills",
		hidden  = true,
	}
	register_medal "gargulec2" {
		name  = "Gargulec Cross",
		desc  = "Win as a Berserker with 100% kills on BMO",
		hidden  = true,
		removes = { "gargulec1" },
	}
	register_challenge "challenge_ber" {
		name        = "Berserker",
		description = "Your field kit consists of a bowie knife and some Lucky Strikes. You never bother with guns. And for some reason guns never bother you. So go pound some faces in, soldier.",
		rating      = "MEDIUM",
		rank        = 1,
		abbr        = "Ber",
		let         = "B",
		secondary   = { "Seer", "Demo", "Stat", "MDK", "100", "Game", "Surv", "Inf", "Para" },

		OnCreatePlayer = function ()
			DoomRL.generatePlayerInventory()
			player.armor = player.armor + 2
		end,

		OnFire = function (item,being)
			if not being:is_player() then return true end
			if item.itype == ITEMTYPE_MELEE then return true end
			ui.msg("Your can't even comprehend firing this weapon.")
			return false
		end,

		OnMortem = function ()
			if player.depth >= 10  then player:add_badge("berserker1") end
			if player:has_won() then player:add_badge("berserker2") end
			if player:has_won() and DIFFICULTY >= DIFF_MEDIUM then player:add_badge("berserker3") end
			if player:has_won() and DIFFICULTY >= DIFF_HARD then player:add_badge("berserker4") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD then player:add_badge("berserker5") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD and statistics.kills >= statistics.max_kills * 0.6 then player:add_badge("berserker6") end

			if player:has_won() and statistics.kills >= statistics.max_kills then player:add_medal("gargulec1") end
			if player:has_won() and DIFFICULTY >= DIFF_HARD and statistics.kills >= statistics.max_kills then player:add_medal("gargulec2") end
		end,
	}

	-- CHALLENGE MARKSMAN
	register_badge "marksman1" {
		name  = "Duelist Bronze Badge",
		desc  = "Reach level 15 as a Duelist",
		level = 1,
	}
	register_badge "marksman2" {
		name  = "Duelist Silver Badge",
		desc  = "Win as a Duelist",
		level = 2,
	}
	register_badge "marksman3" {
		name  = "Duelist Gold Badge",
		desc  = "Win as a Duelist on DHM",
		level = 3,
	}
	register_badge "marksman4" {
		name  = "Duelist Platinum Badge",
		desc  = "Win as a Duelist on BEO",
		level = 4,
	}
	register_badge "marksman5" {
		name  = "Duelist Diamond Badge",
		desc  = "Win as a Duelist on DI",
		level = 5,
	}
	register_badge "marksman6" {
		name  = "Duelist Angelic Badge",
		desc  = "Win as a Duelist on DI with 80% kills",
		level = 6,
	}
	register_challenge "challenge_mark" {
		name        = "Duelist",
		description = "The pistol is your friend. If you tend to its concerns it tends to hit yours. You've cared for your pistol for most of your military career so it's no surprise you brought it along with you. After all, it's all you've ever needed.",
		rating      = "MEDIUM",
		rank        = 1,
		abbr        = "Mark",
		let         = "M",
		secondary   = { "Seer", "Demo", "Stat", "MDK", "100", "Game", "Surv", "Inf", "Para" },

		OnCreatePlayer = function ()
			DoomRL.generatePlayerInventory()
		end,

		OnFire = function (item,being)
			if not being:is_player() then return true end
			if item.flags[IF_PISTOL] then return true end
			ui.msg("This is not a weapon worthy of a marksman.")
			return false
		end,

		OnMortem = function ()
			if player.depth >= 15  then player:add_badge("marksman1") end
			if player:has_won() then player:add_badge("marksman2") end
			if player:has_won() and DIFFICULTY >= DIFF_MEDIUM then player:add_badge("marksman3") end
			if player:has_won() and DIFFICULTY >= DIFF_HARD then player:add_badge("marksman4") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD then player:add_badge("marksman5") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD and statistics.kills >= statistics.max_kills * 0.8 then player:add_badge("marksman6") end
		end,
	}

	-- CHALLENGE SHOTGUNNERY
	register_badge "shotgun1" {
		name  = "Cowboy Bronze Badge",
		desc  = "Reach level 15 as a Cowboy",
		level = 1,
	}
	register_badge "shotgun2" {
		name  = "Cowboy Silver Badge",
		desc  = "Win as a Cowboy",
		level = 2,
	}
	register_badge "shotgun3" {
		name  = "Cowboy Gold Badge",
		desc  = "Win as a Cowboy on DHM",
		level = 3,
	}
	register_badge "shotgun4" {
		name  = "Cowboy Platinum Badge",
		desc  = "Win as a Cowboy on BMO",
		level = 4,
	}
	register_badge "shotgun5" {
		name  = "Cowboy Diamond Badge",
		desc  = "Win as a Cowboy on DI",
		level = 5,
	}
	register_badge "shotgun6" {
		name  = "Cowboy Angelic Badge",
		desc  = "Win as a Cowboy on DI with 80% kills",
		level = 6,
	}
	register_challenge "challenge_shot" {
		name        = "Cowboy",
		description = "When Uncle Sam asked you to defend the free world you jumped at the call. When he tried to trade you a rifle for daddy's shotgun you had other ideas. Nothing beats your shotgun and you're gonna make sure the Nazis know it. And fortunately for you you'll find 5 shells on every enemy to help spread the news.",
		rating      = "EASY",
		rank        = 2,
		abbr        = "Shot",
		let         = "C",
		secondary   = { "Seer", "Demo", "Stat", "MDK", "100", "Game", "Surv", "Inf", "Para" },

		OnCreatePlayer = function ()
			DoomRL.generatePlayerInventory()
		end,

		OnFire = function (item,being)
			if not being:is_player() then return true end
			if item.flags[IF_SHOTGUN] then return true end
			ui.msg("This is a weapon for wimps, not a true man!")
			return false
		end,

		OnCreate = function ( this )
			if this:is_being() and not this:is_player() then
				this.inv:add( "wolf_shell", { ammo = 5 } )
			end
		end,

		OnMortem = function ()
			if player.depth >= 15  then player:add_badge("shotgun1") end
			if player:has_won() then player:add_badge("shotgun2") end
			if player:has_won() and DIFFICULTY >= DIFF_MEDIUM then player:add_badge("shotgun3") end
			if player:has_won() and DIFFICULTY >= DIFF_HARD then player:add_badge("shotgun4") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD then player:add_badge("shotgun5") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD and statistics.kills >= statistics.max_kills * 0.8 then player:add_badge("shotgun6") end
		end,
	}

	-- CHALLENGE DARKNESS --
	register_badge "oracle1" {
		name  = "Oracle Bronze Badge",
		desc  = "Reach level 10 as an Oracle",
		level = 1,
	}
	register_badge "oracle2" {
		name  = "Oracle Silver Badge",
		desc  = "Win as an Oracle",
		level = 2,
	}
	register_badge "oracle3" {
		name  = "Oracle Gold Badge",
		desc  = "Win as an Oracle on DHM",
		level = 3,
	}
	register_badge "oracle4" {
		name  = "Oracle Platinum Badge",
		desc  = "Win as an Oracle on BMO",
		level = 4,
	}
	register_badge "oracle5" {
		name  = "Oracle Diamond Badge",
		desc  = "Win as an Oracle on DI",
		level = 5,
	}
	register_badge "oracle6" {
		name  = "Oracle Angelic Badge",
		desc  = "Win as an Oracle on DI as an Explorer",
		level = 6,
	}
	register_challenge "challenge_seer" {
		name        = "Oracle",
		description = "You're blind as a bat but you can sense your enemies anyway. No one can hide from you but they can run behind walls, and actually hitting them at anything beyond point blank range will either take a lot of skill or a lot of ammo.",
		rating      = "HARD",
		rank        = 3,
		abbr        = "Seer",
		let         = "O",
		secondary   = { "Ber", "Mark", "Shot", "Demo", "Stat", "MDK", "100", "Game", "Obj", "Surv", "Inf", "Para" },

		OnCreatePlayer = function ()
			DoomRL.generatePlayerInventory()

			player.vision = 2
		end,

		OnEnter = function (l)
			level.flags[ LF_BEINGSVISIBLE ] = true
		end,

		OnMortem = function ()
			if player.depth >= 10  then player:add_badge("oracle1") end
			if player:has_won() then player:add_badge("oracle2") end
			if player:has_won() and DIFFICULTY >= DIFF_MEDIUM then player:add_badge("oracle3") end
			if player:has_won() and DIFFICULTY >= DIFF_HARD then player:add_badge("oracle4") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD then player:add_badge("oracle5") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD and statistics.bonus_levels_visited == statistics.bonus_levels_count then player:add_badge("oracle6") end
		end,
	}

	-- CHALLENGE EXPLOSIONS
	register_badge "explosion1" {
		name  = "Demolitions Bronze Badge",
		desc  = "Reach level 10 as a Demoman",
		level = 1,
	}
	register_badge "explosion2" {
		name  = "Demolitions Silver Badge",
		desc  = "Win as a Demoman",
		level = 2,
	}
	register_badge "explosion3" {
		name  = "Demolitions Gold Badge",
		desc  = "Win as a Demoman on DHM",
		level = 3,
	}
	register_badge "explosion4" {
		name  = "Demolitions Platinum Badge",
		desc  = "Win as a Demoman on BMO",
		level = 4,
	}
	register_badge "explosion5" {
		name  = "Demolitions Diamond Badge",
		desc  = "Win as a Demoman on DI",
		level = 5,
	}
	register_badge "explosion6" {
		name  = "Demolitions Angelic Badge",
		desc  = "Demoman on DI taking less than 500 damage",
		level = 6,
	}
	register_challenge "challenge_demo" {
		name        = "Demoman",
		description = "Things always seem to blow up around you. Fuel barrels, medical waste containers, the occasional ammo cache, hell one time the coffee machine sprayed you before bursting into flames. And now on the front lines things are exploding even more! All explosions are twice as big and twice as painful--for both you and your enemies.",
		rating      = "HARD",
		rank        = 4,
		abbr        = "Demo",
		let         = "D",
		secondary   = { "Ber", "Mark", "Shot", "Seer", "Stat", "MDK", "100", "Game", "Obj", "Surv", "Inf", "Para" },

		OnCreate = function ( this )
			if this:is_item() then
				if this.blastradius > 0 then
					this.damage_sides = this.damage_sides * 2
					this.blastradius  = math.floor(this.blastradius * 1.5)
				else
					this.blastradius = 1
				end
			end
		end,

		OnMortem = function ()
			if player.depth >= 10  then player:add_badge("explosion1") end
			if player:has_won() then player:add_badge("explosion2") end
			if player:has_won() and DIFFICULTY >= DIFF_MEDIUM then player:add_badge("explosion3") end
			if player:has_won() and DIFFICULTY >= DIFF_HARD then player:add_badge("explosion4") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD then player:add_badge("explosion5") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD and statistics.damage_taken < 500 then player:add_badge("explosion6") end
		end,
	}

	-- CHALLENGE CARNAGE
	register_badge "carnage1" {
		name  = "Statistician Bronze Badge",
		desc  = "Win as a Statistician",
		level = 1,
	}
	register_badge "carnage2" {
		name  = "Statistician Silver Badge",
		desc  = "Win as a Statistician on DHM",
		level = 2,
	}
	register_badge "carnage3" {
		name  = "Statistician Gold Badge",
		desc  = "Statistician on DHM with under 500 damage",
		level = 3,
	}
	register_badge "carnage4" {
		name  = "Statistician Platinum Badge",
		desc  = "Statistician on BMO with under 200 damage",
		level = 4,
	}
	register_badge "carnage5" {
		name  = "Statistician Diamond Badge",
		desc  = "Statistician on DI with under 50 damage",
		level = 5,
	}
	register_badge "carnage6" {
		name  = "Statistician Angelic Badge",
		desc  = "Statistician DI with NO damage whatsoever!",
		level = 6,
	}
	register_challenge "challenge_stat" {
		name        = "Statistician",
		description = "Numbers don't lie, but liars do. When it comes to chance you are the expert, and your favorite odds are always 100%. That way you're guaranteed a hit at maximum damage! But be careful, because the enemies get that same bonus, and you can never fully remove the effects of chance...",
		rating      = "EASY",
		rank        = 5,
		abbr        = "Stat",
		let         = "S",
		secondary   = { "Ber", "Mark", "Shot", "Seer", "Demo", "MDK", "100", "Game", "Obj", "Surv", "Inf", "Para" },

		OnCreate = function ( this )
			if this:is_being() then
				this.tohit = this.tohit + 12
				this.flags[ BF_MAXDAMAGE ] = true
			end
		end,

		OnMortem = function ()
			if player:has_won() then player:add_badge("carnage1") end
			if player:has_won() and DIFFICULTY >= DIFF_MEDIUM then player:add_badge("carnage2") end
			if player:has_won() and DIFFICULTY >= DIFF_MEDIUM and statistics.damage_taken < 500 then player:add_badge("carnage3") end
			if player:has_won() and DIFFICULTY >= DIFF_HARD and statistics.damage_taken < 200 then player:add_badge("carnage4") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD and statistics.damage_taken < 50 then player:add_badge("carnage5") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD and statistics.damage_taken <= 0 then player:add_badge("carnage6") end
		end,
	}

	-- CHALLENGE RED ALERT
	register_badge "redalert1" {
		name  = "Fanatical Bronze Badge",
		desc  = "Reach level 15 as a Fanatic",
		level = 1,
	}
	register_badge "redalert2" {
		name  = "Fanatical Silver Badge",
		desc  = "Win as a Fanatic",
		level = 2,
	}
	register_badge "redalert3" {
		name  = "Fanatical Gold Badge",
		desc  = "Win as a Fanatic with 100% kills",
		level = 3,
	}
	register_badge "redalert4" {
		name  = "Fanatical Platinum Badge",
		desc  = "Win as a Fanatic on BMO with 100% kills",
		level = 4,
	}
	register_badge "redalert5" {
		name  = "Fanatical Diamond Badge",
		desc  = "Win as a Fanatic on DI with 80% kills",
		level = 5,
	}
	register_badge "redalert6" {
		name  = "Fanatical Angelic Badge",
		desc  = "Fanatic on DI 80% kills and no Hellrunner",
		level = 6,
	}
	register_challenge "challenge_mdk" {
		name        = "Fanatic",
		description = "You're going to complete your mission by any means necessary. Every time you enter a level you wire it to blow with a countdown of 5 minutes (around 240 moves). Scouting is not allowed.",
		rating      = "MEDIUM",
		rank        = 6,
		abbr        = "MDK",
		let         = "F",
		secondary   = { "Ber", "Mark", "Shot", "Seer", "Demo", "Stat", "100", "Game", "Obj", "Surv", "Inf", "Para" },
		removemedals = { "fallout1", "fallout2" },

		OnEnter = function (l)
			player.flags[ BF_STAIRSENSE ] = false
			player:nuke(5*60*10)
			ui.msg("\"Bomb deployed. 5 minutes till explosion.\"")
		end,

		OnMortem = function ()
			if player.depth >= 15  then player:add_badge("redalert1") end
			if player:has_won() then player:add_badge("redalert2") end
			if player:has_won() and statistics.kills >= statistics.max_kills then player:add_badge("redalert3") end
			if player:has_won() and DIFFICULTY >= DIFF_HARD and statistics.kills >= statistics.max_kills then player:add_badge("redalert4") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD and statistics.kills >= statistics.max_kills * 0.8 then player:add_badge("redalert5") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD and player:get_trait( traits["hellrunner"].nid ) == 0 and statistics.kills >= statistics.max_kills * 0.8 then player:add_badge("redalert6") end
		end,
	}

	-- CHALLENGE 100
	register_medal "dervis" {
		name  = "Dervis' Medallion",
		desc  = "Winning Ao100 on Nightmare!",
		hidden  = true,
	}
	register_badge "century1" {
		name  = "Pioneer Bronze Badge",
		desc  = "Reach level 26 as a Pioneer",
		level = 1,
	}
	register_badge "century2" {
		name  = "Pioneer Silver Badge",
		desc  = "Reach level 51 as a Pioneer",
		level = 2,
	}
	register_badge "century3" {
		name  = "Pioneer Gold Badge",
		desc  = "Win as a Pioneer",
		level = 3,
	}
	register_badge "century4" {
		name  = "Pioneer Platinum Badge",
		desc  = "Win as a Pioneer on BMO",
		level = 4,
	}
	register_badge "century5" {
		name  = "Pioneer Diamond Badge",
		desc  = "Win as a Pioneer on DI",
		level = 5,
	}
	register_badge "century6" {
		name  = "Pioneer Angelic Badge",
		desc  = "Win as a Pioneer on DI in under two hours",
		level = 6,
	}
	register_challenge "challenge_100" {
		name        = "Pioneer",
		description = "100 levels. No more, no less. By the time you get through this challenge you should be on the Russian front.",
		rating      = "HARD",
		rank        = 5,
		abbr        = "100",
		let         = "P",
		secondary   = { "Ber", "Mark", "Shot", "Seer", "Demo", "Stat", "MDK", "Game", "Obj", "Surv" },
		removemedals = { "gambler", "aurora", "explorer", "conqueror", "fallout1", "fallout2", "ironskull1" },
		win_mortem    = "completed 100 levels of torture",
		win_highscore = "completed 100 levels",

		arch_name        = "Valhalla",
		arch_description = "A life of never ending battle. There is no victory to be had here, you simply fight forever.",
		arch_rating      = "BLADE",
		arch_rank        = 7,

		OnCreateEpisode = function ()
			local LevCount = 100
			local LevName = "Killing Fields"
			local DethName = "the Killing Fields"
			player.episode = {}

			if ARCHANGEL then
				LevCount = 1000
				LevName = "Valhalla"
				DethName = "Valhalla"
			end

			for i=1,LevCount do
				player.episode[i] = { style = math.random(7), number = i, name = LevName, deathname = DethName, danger = i }
			end
			statistics.bonus_levels_count = 0
		end,

		OnIntro = function ()
			return false
		end,

		OnUnLoad = function ()
			DoomRL.OnCreateEpisode()
		end,

		OnEnter = function (l)
			if ARCHANGEL and l % 1000 == 0 then
				--Add another 1000 levels.  FOREVER.
				--(I realize eventually we'd hit 4 bil and everything would break but you will stop caring long before that point)
				for i=l - 1001, l - 1 do
					player.episode[i] = nil
				end
				for i=l+1, l + 1000 do
					player.episode[i] = { style = math.random(7), number = i, name = "Valhalla", danger = i }
				end
			end
		end,

		OnExit = function (l)
			if not ARCHANGEL then
				if l == 25 then ui.msg_enter("Well, that was easy. Now starts the really hard part...")
				elseif l == 50 then ui.msg_enter("Halfway there, and it's getting less and less funny!")
				elseif l == 75 then ui.msg_enter("Just 25 more, you can make it!")
				elseif l == 90 then ui.msg_enter("Ten more! Can you really take the heat?")
				elseif l == 99 then ui.msg_enter("Just one more! Just one more! Will you die here?")
				elseif l == 100 then
					ui.msg_enter("You did it! You completed 100 levels of WolfRL! You are the champion!")
					player:win()
				end
			end
		end,

		OnWinGame = function ()
			ui.blood_slide()
			ui.plot_screen(
	[[
	You've completed 100 levels of WolfRL!

	You can rest easy knowing that you're boss.
	Seriously. Go outside! Talk to people!
	]])
			return false
		end,

		OnMortem = function ()
			if player.depth >= 26 then player:add_badge("century1") end
			if player.depth >= 51 then player:add_badge("century2") end
			if player:has_won() then player:add_badge("century3") end
			if player:has_won() and DIFFICULTY >= DIFF_HARD then player:add_badge("century4") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD then player:add_badge("century5") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD and statistics.real_time <= 120*60 then player:add_badge("redalert6") end
		end,
	}

	-- CHALLENGE D&D
	register_badge "dnd1" {
		name  = "Third Edition Bronze Badge",
		desc  = "Win as a Roleplayer",
		level = 1,
	}
	register_badge "dnd2" {
		name  = "Third Edition Gold Badge",
		desc  = "Win as a Roleplayer in under 20000 turns",
		level = 3,
	}
	register_badge "dnd3" {
		name  = "Third Edition Diamond Badge",
		desc  = "Win as a Roleplayer on DI",
		level = 5,
	}
	register_challenge "challenge_game" {
		name        = "Roleplayer",
		description = "Even in the field you could always find a few guys willing to roll up some parchment, whittle some dice, and craft exotic worlds with knights and knaves. Because of that you gain +5 HP each level and +1 toHit every 2 levels. However, you only gain traits every 4 levels.",
		rating      = "MEDIUM",
		rank        = 6,
		abbr        = "Game",
		let         = "R",
		secondary   = { "Ber", "Mark", "Shot", "Seer", "Demo", "Stat", "MDK", "100", "Obj", "Surv", "Inf", "Para" },
		removemedals = { "fallout1", "fallout2" },


		OnPreLevelUp = function ()
			if level % 4 == 0 then
				ui.clear()
				ui.blood_slide()
				player:choose_trait()
			end

			player.hpmax = player.hpmax + 5
			ui.msg("You gain +5HP!")

			if level % 2 == 0 then
				player.tohit = player.tohit + 1
				ui.msg("You gain +1 toHit!")
			end

			ui.msg("You now have " .. player.hpmax .." HP and +" .. player.tohit .. " toHit!")
			return false
		end,

		OnMortem = function ()
			if player:has_won() then player:add_badge("dnd1") end
			if player:has_won() and statistics.game_time <= 20000 then player:add_badge("dnd2") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD then player:add_badge("dnd3") end
		end,

	}

	-- CHALLENGE PACIFISM
	register_badge "pacifism1" {
		name  = "Pacifist Silver Badge",
		desc  = "Win as a Pacifist on DHM",
		level = 2,
	}
	register_badge "pacifism2" {
		name  = "Pacifist Platinum Badge",
		desc  = "Pacifist on BMO in under 10 minutes",
		level = 4,
	}
	register_badge "pacifism3" {
		name  = "Pacifist Angelic Badge",
		desc  = "Pacifist DI without a single person dying!",
		level = 6,
	}
	register_challenge "challenge_obj" {
		name        = "Objector",
		description = "Nazis are people too! Killing them is wrong, and you know that if you could just get to the spear you can end this whole horrible war peacefully. Due to your pacifistic beliefs you gain a level every two floors. Of course *no* weapon usage is allowed...",
		rating      = "EASY",
		rank        = 5,
		abbr        = "Obj",
		let         = "J",
		removemedals = { "fist", "knives" },
		secondary   = { "Seer", "Demo", "Stat", "MDK", "100", "Game", "Surv" },

		OnCreatePlayer = function ()
			DoomRL.generatePlayerInventory()
			player.flags[ BF_STAIRSENSE ] = false
			player.flags[ BF_NOMELEE ] = true
		end,

		OnEnter = function (l)
			if (l - 1) / 2 <= player.explevel then
				player:level_up()
			end

			generator.transmute("lmdoor1", "mdoor1")
			generator.transmute("lmdoor2", "mdoor2")
		end,

		OnFire = function (item,being)
			if not being:is_player() then return true end
			ui.msg("No way! You're a pacifist!")
			return false
		end,

		OnMortem = function ()
			if player:has_won() and DIFFICULTY >= DIFF_MEDIUM then player:add_badge("pacifism1") end
			if player:has_won() and DIFFICULTY >= DIFF_HARD and statistics.real_time <= 10*60 then player:add_badge("pacifism2") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD and statistics.kills <= 0 then player:add_badge("pacifism3") end
		end,
	}

	-- CHALLENGE HUMANITY
	register_badge "everyman4" {
		name  = "Survivalist Platinum Badge",
		desc  = "Win as a Survivalist on BMO as a Conqueror",
		level = 4,
	}
	register_badge "everyman5" {
		name  = "Survivalist Diamond Badge",
		desc  = "Win as a Survivalist on DI",
		level = 5,
	}
	register_badge "everyman6" {
		name  = "Survivalist Angelic Badge",
		desc  = "Win as a Survivalist on DI as a Conqueror",
		level = 6,
	}
	register_challenge "challenge_surv" {
		name        = "Survivalist",
		description = "Let's face it. Most people die when they get shot, or at least aren't in good enough shape to stick around the front lines. Now those cold and harsh realities affect you as well.",
		rating      = "VERY HARD",
		rank        = 6,
		abbr        = "Surv",
		let         = "V",
		removemedals = {},
		secondary   = { "Ber", "Mark", "Shot", "Seer", "Demo", "Stat", "MDK", "100", "Game", "Obj", "Inf", "Para" },

		OnCreatePlayer = function ()
			DoomRL.generatePlayerInventory()
			player.hp = player.hp / 5
			player.hpmax = player.hp
			player.hpnom = player.hp
		end,

		OnMortem = function ()
			if player:has_won() and DIFFICULTY >= DIFF_HARD and statistics.bonus_levels_completed == statistics.bonus_levels_count then player:add_badge("everyman4") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD then player:add_badge("everyman5") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD and statistics.bonus_levels_completed == statistics.bonus_levels_count then player:add_badge("everyman6") end
		end,
	}

	-- CHALLENGE CONFIDENCE
	register_badge "confident1" {
		name  = "Daredevil Bronze Badge",
		desc  = "Win as an Infiltrator",
		level = 1,
	}
	register_badge "confident2" {
		name  = "Daredevil Silver Badge",
		desc  = "Win as an Infiltrator on DHM",
		level = 2,
	}
	register_badge "confident4" {
		name  = "Daredevil Platinum Badge",
		desc  = "Win as an Infiltrator on DI",
		level = 4,
	}
	register_challenge "challenge_inf" {
		name        = "Infiltrator",
		description = "Some people break into enemy fortifications through tunnels or sewers. You always preferred the direct route of knocking on the front door. True there will be a rough welcoming party but you never show up to these engagements underdressed.",
		rating      = "HARD",
		rank        = 4,
		abbr        = "Inf",
		let         = "I",
		secondary   = { "Ber", "Mark", "Shot", "Seer", "Demo", "Stat", "MDK", "Game", "Surv", },
		removemedals = { "icarus1", "icarus2", "explorer", "conqueror", "competn1", "competn2", "competn3", "untouchable1", "untouchable2", "untouchable3" },

		OnCreateEpisode = function ()

			--Assign our levels.  There's too much flair to loop
			player.episode = {}
			player.episode[1]  = {style = STYLE_WHITE,                                                                           number = 1, name = "Nuremberg Castle",   deathname = "the Nuremberg Castle",   danger = 10}
			player.episode[2]  = {style = STYLE_WHITE,                                                                           number = 2, name = "Nuremberg Castle",   deathname = "the Nuremberg Castle",   danger = 11}
			player.episode[3]  = {style = table.random_pick( { STYLE_WHITE,    STYLE_WHITE,    STYLE_BLUE   } ),                 number = 3, name = "Nuremberg Castle",   deathname = "the Nuremberg Castle",   danger = 12}
			player.episode[4]  = {style = STYLE_WHITE,                                                                           number = 4, name = "Nuremberg Castle",   deathname = "the Nuremberg Castle",   danger = 13}
			player.episode[5]  = {style = table.random_pick( { STYLE_WHITE,    STYLE_WHITE,    STYLE_RED,      STYLE_BROWN  } ), number = 5, name = "Nuremberg Castle",   deathname = "the Nuremberg Castle",   danger = 14}
			player.episode[6]  = {style = table.random_pick( { STYLE_WHITE,    STYLE_WHITE,    STYLE_RED,      STYLE_BROWN  } ), number = 6, name = "Nuremberg Castle",   deathname = "the Nuremberg Castle",   danger = 15}
			player.episode[7]  = {style = table.random_pick( { STYLE_WHITE,    STYLE_WHITE,    STYLE_RED,      STYLE_BROWN  } ), number = 7, name = "Nuremberg Castle",   deathname = "the Nuremberg Castle",   danger = 16}
--[[--]]			player.episode[8]  = {style = STYLE_WHITE,                                                                           number = 8, name = "Nuremberg Castle",   deathname = "the Nuremberg Castle",   danger = 17}
			player.episode[9]  = {style = STYLE_WHITE,                                                                           number = 1, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 18}
			player.episode[10] = {style = STYLE_WHITE,                                                                           number = 2, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 19}
			player.episode[11] = {style = STYLE_WHITE,                                                                           number = 3, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 20}
			player.episode[12] = {style = table.random_pick( { STYLE_WHITE,    STYLE_WHITE,    STYLE_PURPLE } ),                 number = 4, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 21}
			player.episode[13] = {style = table.random_pick( { STYLE_WHITE,    STYLE_WHITE,    STYLE_BLUE   } ),                 number = 5, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 22}
			player.episode[14] = {style = table.random_pick( { STYLE_WHITE,    STYLE_WHITE,    STYLE_PURPLE } ),                 number = 6, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 23}
			player.episode[15] = {style = STYLE_WHITE,                                                                           number = 7, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 24}
--[[--]]			player.episode[16] = {style = STYLE_WHITE,                                                                           number = 8, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 25}
--[[--]]			player.episode[17] = {style = STYLE_HELL,                                                                            number = 1, name = "Hell",               deathname = "Hell",                   danger = 50}

			player.episode[8]  = {script = "spear3", style=STYLE_WHITE, deathname = "the Nuremberg Castle"}
			player.episode[16] = {script = "spear4", style=STYLE_WHITE, deathname = "the Nuremberg Ramparts"}
			player.episode[17] = {script = "spear5", style=STYLE_HELL,  deathname = "Hell"}

			--Handle the special levels
			for _,level_proto in ipairs(levels) do
				if level_proto.level then
					if (not level_proto.canGenerate) or level_proto.canGenerate() then
						if not (level_proto.chance and (math.random(100) > level_proto.chance)) then
							local range = resolverange(level_proto.level) - 9
							if (range == 8) then range = range + 1 end
							if (range > 0 and range < 16) then
								player.episode[range].special = level_proto.id
							end
						end
					end
				end
			end

			local SpecLevCount = 0
			for i=1,#player.episode do
				if player.episode[i].special then
					SpecLevCount = SpecLevCount + 1
				end
			end
			statistics.bonus_levels_count = SpecLevCount
		end,

		OnCreatePlayer = function ()
			DoomRL.generatePlayerInventory()
		end,

		OnMortem = function ()
			if player:has_won() then player:add_badge("confident1") end
			if player:has_won() and DIFFICULTY >= DIFF_MEDIUM then player:add_badge("confident2") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD then player:add_badge("confident4") end
		end,
	}

	-- CHALLENGE OVERCONFIDENCE
	register_badge "confident3" {
		name  = "Daredevil Gold Badge",
		desc  = "Win as a Paratrooper on BMO",
		level = 3,
	}
	register_badge "confident5" {
		name  = "Daredevil Diamond Badge",
		desc  = "Win as a Paratrooper on DI",
		level = 5,
	}
	register_badge "confident6" {
		name  = "Daredevil Angelic Badge",
		desc  = "Win as a Paratrooper on DI with 80% kills",
		level = 6,
	}
	register_challenge "challenge_para" {
		name        = "Paratrooper",
		description = "Why walk when you can rise above? Instead of sneaking your way into the castle you hopped on a plane and skydived your way through bomb and bullet landing right on the ramparts, fully loaded and ready to go!",
		rating      = "VERY HARD",
		rank        = 6,
		abbr        = "Para",
		let         = "T",
		secondary   = { "Ber", "Mark", "Shot", "Seer", "Demo", "Stat", "MDK", "Game", "Surv", },
		removemedals = { "icarus1", "icarus2", "explorer", "conqueror", "competn1", "competn2", "competn3", "untouchable1", "untouchable2", "untouchable3" },

		OnCreateEpisode = function ()

			--Assign our levels.  There's too much flair to loop
			player.episode = {}
			player.episode[1] = {style = STYLE_WHITE,                                                           number = 1, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 18}
			player.episode[2] = {style = STYLE_WHITE,                                                           number = 2, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 19}
			player.episode[3] = {style = STYLE_WHITE,                                                           number = 3, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 20}
			player.episode[4] = {style = table.random_pick( { STYLE_WHITE,    STYLE_WHITE,    STYLE_PURPLE } ), number = 4, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 21}
			player.episode[5] = {style = table.random_pick( { STYLE_WHITE,    STYLE_WHITE,    STYLE_BLUE   } ), number = 5, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 22}
			player.episode[6] = {style = table.random_pick( { STYLE_WHITE,    STYLE_WHITE,    STYLE_PURPLE } ), number = 6, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 23}
			player.episode[7] = {style = STYLE_WHITE,                                                           number = 7, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 24}
--[[--]]			player.episode[8] = {style = STYLE_WHITE,                                                           number = 8, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 25}
--[[--]]			player.episode[9] = {style = STYLE_HELL,                                                            number = 1, name = "Hell",               deathname = "Hell",                   danger = 50}

			player.episode[8] = {script = "spear4", style=STYLE_WHITE, deathname = "the Nuremberg Ramparts"}
			player.episode[9] = {script = "spear5", style=STYLE_HELL,  deathname = "Hell"}

			--Handle the special levels
			for _,level_proto in ipairs(levels) do
				if level_proto.level then
					if (not level_proto.canGenerate) or level_proto.canGenerate() then
						if not (level_proto.chance and (math.random(100) > level_proto.chance)) then
							local range = resolverange(level_proto.level) - 17
							if (range > 0 and range < 8) then
								player.episode[range].special = level_proto.id
							end
						end
					end
				end
			end

			local SpecLevCount = 0
			for i=1,#player.episode do
				if player.episode[i].special then
					SpecLevCount = SpecLevCount + 1
				end
			end
			statistics.bonus_levels_count = SpecLevCount
		end,

		OnCreatePlayer = function ()
			DoomRL.generatePlayerInventory()
		end,

		OnMortem = function ()
			if player:has_won() and DIFFICULTY >= DIFF_HARD then player:add_badge("confident3") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD then player:add_badge("confident5") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD and statistics.kills >= statistics.max_kills * 0.8 then player:add_badge("confident6") end
		end,
	}

end
