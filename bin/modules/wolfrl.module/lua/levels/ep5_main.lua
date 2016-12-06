-- Episode 5: Trail of a Madman
require( "doomrl:levels/ep5_boss5" )
require( "doomrl:levels/ep5_spec5" )

--[[ Wolf3d Level notes (I don't like brown BTW, there's no way to make it look good):

    blue and white
    mostly white
    white
    white red blue
    wooden then white
    s-redwhiteblueequal
    white
    white
    rwb
    white & brown
--poss flair: more treasure, less ammo
]]--

function DoomRL.loadepisode5()
	register_badge "erlangen1" {
		name  = "Decadent Bronze Badge",
		desc  = "Find the chemical plans in Castle Erlangen",
		level = 1,
	}
	register_badge "erlangen2" {
		name  = "Decadent Silver Badge",
		desc  = "Capture the chemical plans on DHM",
		level = 2,
	}
	register_badge "erlangen3" {
		name  = "Decadent Gold Badge",
		desc  = "Capture the chemical plans on BMO",
		level = 3,
	}
	register_badge "erlangen4" {
		name  = "Decadent Platinum Badge",
		desc  = "Capture the chemical plans on DI",
		level = 4,
	}
	register_badge "erlangen5" {
		name  = "Decadent Diamond Badge",
		desc  = "Succeed w/o any damage bonus traits on DI",
		level = 5,
	}
	register_badge "erlangen6" {
		name  = "Decadent Angelic Badge",
		desc  = "Succeed w/o any offensive traits on DI",
		level = 6,
	}
	register_medal "award5" {
		name  = "Legion of Merit",
		desc  = "Awarded for capturing the chemical war plans.",
		hidden  = false,
	}

	register_challenge "challenge_ep5" {
		name        = "Trail of a Madman",
		description = "Episode 5 of Wolfenstein.",
		rating      = "HARD",
		rank        = 3,
		abbr        = "Ep5",
		let         = "5",
		secondary   = { "Ber", "Mark", "Shot", "Seer", "Demo", "Stat", "MDK", "Game", "Surv", },
		removemedals = { "icarus1", "icarus2", "explorer", "conqueror", "competn1", "competn2", "competn3", "untouchable1", "untouchable2", "untouchable3" },
		win_mortem    = "Defeated Gretel Grosse",
		win_highscore = "Completed Episode 5",

		OnCreateEpisode = function ()
			DoomRL.ep5_OnCreateEpisode()
		end,
		OnIntro = function ()
			return DoomRL.ep5_OnIntro()
		end,
		OnWinGame = function ()
			return DoomRL.ep5_OnWinGame()
		end,
		OnGenerate = function ()
			DoomRL.ep5_OnGenerate()
			return false
		end,

		OnMortem = function ()
			if player:has_won() then player:add_badge("erlangen1") end
			if player:has_won() and DIFFICULTY >= DIFF_MEDIUM then player:add_badge("erlangen2") end
			if player:has_won() and DIFFICULTY >= DIFF_HARD then player:add_badge("erlangen3") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD then player:add_badge("erlangen4") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD and player:get_trait( traits["bitch"].nid ) <= 0 and player:get_trait( traits["gun"].nid ) <= 0 and player:get_trait( traits["brute"].nid ) <= 0 then player:add_badge("erlangen5") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD and player:get_trait( traits["finesse"].nid ) <= 0 and player:get_trait( traits["bitch"].nid ) <= 0 and player:get_trait( traits["gun"].nid ) <= 0 and player:get_trait( traits["reloader"].nid ) <= 0 and player:get_trait( traits["brute"].nid ) <= 0 and player:get_trait( traits["eagle"].nid ) <= 0 then player:add_badge("erlangen6") end
			if player:has_won() then player:add_medal("award5") end
		end,
	}
end

function DoomRL.ep5_OnCreateEpisode()

	--Assign our levels.  There's too much flair to loop
	player.episode = {}
	player.episode[1]  = {style = table.random_pick( { STYLE_BLUE,     STYLE_WHITE                 } ), number = 1,  name = "Erlangen", deathname = "Castle Erlangen", danger = 2}
	player.episode[2]  = {style = STYLE_WHITE,                                                          number = 2,  name = "Erlangen", deathname = "Castle Erlangen", danger = 2}
	player.episode[3]  = {style = table.random_pick( { STYLE_BLUE,     STYLE_RED,      STYLE_WHITE } ), number = 3,  name = "Erlangen", deathname = "Castle Erlangen", danger = 3}
	player.episode[4]  = {style = table.random_pick( { STYLE_WHITE,    STYLE_BROWN                 } ), number = 4,  name = "Erlangen", deathname = "Castle Erlangen", danger = 5}
	player.episode[5]  = {style = table.random_pick( { STYLE_BLUE,     STYLE_RED,      STYLE_WHITE } ), number = 5,  name = "Erlangen", deathname = "Castle Erlangen", danger = 6}
	player.episode[6]  = {style = STYLE_WHITE,                                                          number = 6,  name = "Erlangen", deathname = "Castle Erlangen", danger = 7}
	player.episode[7]  = {style = STYLE_WHITE,                                                          number = 7,  name = "Erlangen", deathname = "Castle Erlangen", danger = 9}
	player.episode[8]  = {style = table.random_pick( { STYLE_BLUE,     STYLE_RED,      STYLE_WHITE } ), number = 8,  name = "Erlangen", deathname = "Castle Erlangen", danger = 10}
	player.episode[9]  = {style = table.random_pick( { STYLE_WHITE,    STYLE_BROWN                 } ), number = 9,  name = "Erlangen", deathname = "Castle Erlangen", danger = 11}
--[[--]]	player.episode[10] = {style = STYLE_WHITE,                                                          number = 10, name = "Erlangen", deathname = "Castle Erlangen", danger = 12}

	player.episode[10] = {script = "boss5", style=STYLE_WHITE, deathname = "Castle Erlangen"}

	--Episodes only get one special level.
	local level_proto = levels["spec5"]
	if (not level_proto.canGenerate) or level_proto.canGenerate() then
		player.episode[resolverange(level_proto.level)].special = level_proto.id
	end
	statistics.bonus_levels_count = 1
end
function DoomRL.ep5_OnIntro()
	DoomRL.plot_intro_5()
	return false
end
function DoomRL.ep5_OnWinGame()
	DoomRL.plot_outro_5()
	return false
end
function DoomRL.ep5_OnGenerate()
	--Maybe I can tweak this later.
	DoomRL.ep7_OnGenerate()
end
