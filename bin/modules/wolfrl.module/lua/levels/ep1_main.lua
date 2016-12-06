-- Episode 1: Escape from Wolfenstein
require( "doomrl:levels/ep1_intro1" )
require( "doomrl:levels/ep1_spec1" )
require( "doomrl:levels/ep1_boss1" )

--[[ Wolf3d Level notes (I don't like brown BTW, there's no way to make it look good):

    blue then white (brown hall)
    -s purple
    blue white brown
    white
    white some blue
    mostly blue white some red brown
    red
    brown some white
    red
    red
--possible dungeon setting for a special level
]]--

function DoomRL.loadepisode1()
	register_badge "castle1" {
		name  = "Houdini Bronze Badge",
		desc  = "Reach level 5 of Castle Wolfenstein",
		level = 1,
	}
	register_badge "castle2" {
		name  = "Houdini Silver Badge",
		desc  = "Confront Hans Grosse",
		level = 2,
	}
	register_badge "castle3" {
		name  = "Houdini Gold Badge",
		desc  = "Escape from Castle Wolfenstein on DHM",
		level = 3,
	}
	register_badge "castle4" {
		name  = "Houdini Platinum Badge",
		desc  = "Escape from Castle Wolfenstein on BMO",
		level = 4,
	}
	register_badge "castle5" {
		name  = "Houdini Diamond Badge",
		desc  = "Escape from Castle Wolfenstein on DI",
		level = 5,
	}
	register_badge "castle6" {
		name  = "Houdini Angelic Badge",
		desc  = "Escape in 8 minutes on DI",
		level = 6,
	}
	register_medal "award1" {
		name  = "Bronze Star",
		desc  = "Awarded for escaping Castle Wolfenstein.",
		hidden  = false,
	}

	register_challenge "challenge_ep1" {
		name        = "Escape from Wolfenstein",
		description = "Episode 1 of Wolfenstein.",
		rating      = "EASY",
		rank        = 0,
		abbr        = "Ep1",
		let         = "1",
		secondary   = { "Ber", "Mark", "Shot", "Seer", "Demo", "Stat", "MDK", "Game", "Surv", },
		removemedals = { "icarus1", "icarus2", "explorer", "conqueror", "competn1", "competn2", "competn3", "untouchable1", "untouchable2", "untouchable3" },
		win_mortem    = "Escaped Castle Wolfenstein",
		win_highscore = "Completed Episode 1",

		--I would like to prevent officers, zombies, mutants, and everything above them
		--from spawning.  This could be doable with some generous level generation abuse.
		--It is explicitly NOT doable by modifying the current beings[] records; any such
		--change would be reverted on a save/load.
		OnCreateEpisode = function ()
			DoomRL.ep1_OnCreateEpisode()
		end,
		OnIntro = function ()
			return DoomRL.ep1_OnIntro()
		end,
		OnWinGame = function ()
			return DoomRL.ep1_OnWinGame()
		end,
		OnGenerate = function ()
			DoomRL.ep1_OnGenerate()
			return false
		end,

		OnMortem = function ()
			if player.depth >= 5 then player:add_badge("castle1") end
			if player.depth >= 10 then player:add_badge("castle2") end
			if player:has_won() and DIFFICULTY >= DIFF_MEDIUM then player:add_badge("castle3") end
			if player:has_won() and DIFFICULTY >= DIFF_HARD then player:add_badge("castle4") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD then player:add_badge("castle5") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD and statistics.real_time <= 8*60 then player:add_badge("castle6") end
			if player:has_won() then player:add_medal("award1") end
		end,
	}
end

function DoomRL.ep1_OnCreateEpisode()

	--Assign our levels.  There's too much flair to loop
	player.episode = {}
--[[--]]	player.episode[1]  = {style = table.random_pick( { STYLE_BLUE,     STYLE_WHITE,                  } ), number = 1,  name = "Wolfenstein", deathname = "Castle Wolfenstein", danger = 2}
	player.episode[2]  = {style = table.random_pick( { STYLE_BLUE,     STYLE_WHITE                   } ), number = 2,  name = "Wolfenstein", deathname = "Castle Wolfenstein", danger = 2}
	player.episode[3]  = {style = table.random_pick( { STYLE_BLUE,     STYLE_WHITE,    STYLE_BROWN   } ), number = 3,  name = "Wolfenstein", deathname = "Castle Wolfenstein", danger = 3}
	player.episode[4]  = {style = STYLE_WHITE,                                                            number = 4,  name = "Wolfenstein", deathname = "Castle Wolfenstein", danger = 3}
	player.episode[5]  = {style = table.random_pick( { STYLE_BLUE,     STYLE_WHITE,    STYLE_WHITE   } ), number = 5,  name = "Wolfenstein", deathname = "Castle Wolfenstein", danger = 4}
	player.episode[6]  = {style = table.random_pick( { STYLE_BLUE,     STYLE_WHITE,    STYLE_RED     } ), number = 6,  name = "Wolfenstein", deathname = "Castle Wolfenstein", danger = 4}
	player.episode[7]  = {style = STYLE_RED,                                                              number = 7,  name = "Wolfenstein", deathname = "Castle Wolfenstein", danger = 5}
	player.episode[8]  = {style = table.random_pick( { STYLE_WHITE,    STYLE_BROWN                   } ), number = 8,  name = "Wolfenstein", deathname = "Castle Wolfenstein", danger = 5}
	player.episode[9]  = {style = STYLE_RED,                                                              number = 9,  name = "Wolfenstein", deathname = "Castle Wolfenstein", danger = 6}
--[[--]]	player.episode[10] = {style = STYLE_RED,                                                              number = 10, name = "Wolfenstein", deathname = "Castle Wolfenstein", danger = 6}

	player.episode[1]  = {script = "intro1", style=table.random_pick({ STYLE_BLUE, STYLE_WHITE }), deathname = "Castle Wolfenstein"}
	player.episode[10] = {script = "boss1", style=STYLE_RED, deathname = "Castle Wolfenstein"}

	--Episodes only get one special level.
	local level_proto = levels["spec1"]
	if (not level_proto.canGenerate) or level_proto.canGenerate() then
		player.episode[resolverange(level_proto.level)].special = level_proto.id
	end
	statistics.bonus_levels_count = 0
end
function DoomRL.ep1_OnIntro()
	DoomRL.plot_intro_1()
	return false
end
function DoomRL.ep1_OnWinGame()
	DoomRL.plot_outro_1()
	return false
end
function DoomRL.ep1_OnGenerate()
	--Maybe I can tweak this later.
	DoomRL.ep7_OnGenerate()
end
