-- Episode 3:  Die Fuhrer Die
require( "doomrl:levels/ep3_spec3" )
require( "doomrl:levels/ep3_boss3" )

--[[ Wolf3d Level notes (I don't like brown BTW, there's no way to make it look good):

    white
    white
    white some blue little brown
    white
    white red
    red cyan slight brown
    brown
    *s* blue
    white slight brown/red
    white

]]--

function DoomRL.loadepisode3()

	register_badge "bunker1" {
		name  = "Bunker Bronze Badge",
		desc  = "Reach Hitler in his underground bunker",
		level = 1,
	}
	register_badge "bunker2" {
		name  = "Bunker Silver Badge",
		desc  = "Terminate Hitler with extreme prejudice",
		level = 2,
	}
	register_badge "bunker3" {
		name  = "Bunker Gold Badge",
		desc  = "Terminate Hitler on DHM",
		level = 3,
	}
	register_badge "bunker4" {
		name  = "Bunker Platinum Badge",
		desc  = "Terminate Hitler on BMO",
		level = 4,
	}
	register_badge "bunker5" {
		name  = "Bunker Diamond Badge",
		desc  = "Terminate Hitler on DI",
		level = 5,
	}
	register_badge "bunker6" {
		name  = "Bunker Angelic Badge",
		desc  = "Terminate Hitler and 90% of his forces on DI",
		level = 6,
	}
	register_medal "award3" {
		name  = "World War II Victory Medal",
		desc  = "Awarded for ending the war.",
		hidden  = false,
	}

	register_challenge "challenge_ep3" {
		name        = "Die, Fuhrer, Die",
		description = "Episode 3 of Wolfenstein.",
		rating      = "MEDIUM",
		rank        = 2,
		abbr        = "Ep3",
		let         = "3",
		secondary   = { "Ber", "Mark", "Shot", "Seer", "Demo", "Stat", "MDK", "Game", "Surv", },
		removemedals = { "icarus1", "icarus2", "explorer", "conqueror", "competn1", "competn2", "competn3", "untouchable1", "untouchable2", "untouchable3" },
		win_mortem    = "Defeated Adolf Hitler",
		win_highscore = "Completed Episode 3",

		--I would like to prevent everything above officers when reasonable
		OnCreateEpisode = function ()
			DoomRL.ep3_OnCreateEpisode()
		end,
		OnIntro = function ()
			return DoomRL.ep3_OnIntro()
		end,
		OnWinGame = function ()
			return DoomRL.ep3_OnWinGame()
		end,
		OnGenerate = function ()
			DoomRL.ep3_OnGenerate()
			return false
		end,

		OnMortem = function ()
			if player.depth >= 10 then player:add_badge("bunker1") end
			if player:has_won() then player:add_badge("bunker2") end
			if player:has_won() and DIFFICULTY >= DIFF_MEDIUM then player:add_badge("bunker3") end
			if player:has_won() and DIFFICULTY >= DIFF_HARD then player:add_badge("bunker4") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD then player:add_badge("bunker5") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD and statistics.kills >= statistics.max_kills * 0.9 then player:add_badge("bunker6") end
			if player:has_won() then player:add_medal("award3") end
		end,
	}
end

function DoomRL.ep3_OnCreateEpisode()

	--Assign our levels.  There's too much flair to loop
	player.episode = {}
	player.episode[1]  = {style = STYLE_WHITE,                                                         number = 1,  name = "Bunker", deathname = "the Bunker", danger = 2}
	player.episode[2]  = {style = STYLE_WHITE,                                                         number = 2,  name = "Bunker", deathname = "the Bunker", danger = 2}
	player.episode[3]  = {style = table.random_pick( { STYLE_WHITE,    STYLE_WHITE,    STYLE_BLUE } ), number = 3,  name = "Bunker", deathname = "the Bunker", danger = 3}
	player.episode[4]  = {style = STYLE_WHITE,                                                         number = 4,  name = "Bunker", deathname = "the Bunker", danger = 4}
	player.episode[5]  = {style = table.random_pick( { STYLE_WHITE,    STYLE_RED                  } ), number = 5,  name = "Bunker", deathname = "the Bunker", danger = 5}
	player.episode[6]  = {style = table.random_pick( { STYLE_RED,      STYLE_BROWN,    STYLE_CYAN } ), number = 6,  name = "Bunker", deathname = "the Bunker", danger = 6}
	player.episode[7]  = {style = STYLE_BROWN,                                                         number = 7,  name = "Bunker", deathname = "the Bunker", danger = 7}
	player.episode[8]  = {style = table.random_pick( { STYLE_WHITE,    STYLE_WHITE,    STYLE_RED  } ), number = 8,  name = "Bunker", deathname = "the Bunker", danger = 8}
	player.episode[9]  = {style = STYLE_WHITE,                                                         number = 9,  name = "Bunker", deathname = "the Bunker", danger = 9}
--[[--]]	player.episode[10] = {style = STYLE_WHITE,                                                         number = 10, name = "Bunker", deathname = "the Bunker", danger = 9}

	player.episode[10] = {script = "boss3", style=STYLE_WHITE, deathname = "the Bunker"}

	--Episodes only get one special level.
	local level_proto = levels["spec3"]
	if (not level_proto.canGenerate) or level_proto.canGenerate() then
		player.episode[resolverange(level_proto.level)].special = level_proto.id
	end
	statistics.bonus_levels_count = 1
end
function DoomRL.ep3_OnIntro()
	DoomRL.plot_intro_3()
	return false
end
function DoomRL.ep3_OnWinGame()
	DoomRL.plot_outro_3()
	return false
end
function DoomRL.ep3_OnGenerate()
	--Maybe I can tweak this later.
	DoomRL.ep7_OnGenerate()
end
