-- Episode 6: Confrontation
require( "doomrl:levels/ep6_boss6" )
require( "doomrl:levels/ep6_spec6" )

--[[ Wolf3d Level notes (I don't like brown BTW, there's no way to make it look good):

    blue then red
    white
    white
    s-brown starts moss
    white
    white
    brown red white layers
    blue purple brown ivy
    white
    brown
--Possible flair: more cave-like tricks and traps-like special level w miniHans
]]--

function DoomRL.loadepisode6()
	register_badge "offenbach1" {
		name  = "Nocturnal Bronze Badge",
		desc  = "Defeat General Fettgesicht",
		level = 1,
	}
	register_badge "offenbach2" {
		name  = "Nocturnal Silver Badge",
		desc  = "Defeat General Fettgesicht on DHM",
		level = 2,
	}
	register_badge "offenbach3" {
		name  = "Nocturnal Gold Badge",
		desc  = "Defeat General Fettgesicht on BMO",
		level = 3,
	}
	register_badge "offenbach4" {
		name  = "Nocturnal Platinum Badge",
		desc  = "Defeat General Fettgesicht on DI",
		level = 4,
	}
	register_badge "offenbach5" {
		name  = "Nocturnal Diamond Badge",
		desc  = "Defeat Gen. Fett w/o defensive traits on DI",
		level = 5,
	}
	register_badge "offenbach6" {
		name  = "Nocturnal Angelic Badge",
		desc  = "Defeat Fett w purely offensive traits on DI",
		level = 6,
	}
	register_medal "award6" {
		name  = "Distinguished Service Cross",
		desc  = "Awarded for preventing chemical war.",
		hidden  = false,
	}

	register_challenge "challenge_ep6" {
		name        = "Confrontation",
		description = "Episode 6 of Wolfenstein.",
		rating      = "HARD",
		rank        = 3,
		abbr        = "Ep6",
		let         = "6",
		secondary   = { "Ber", "Mark", "Shot", "Seer", "Demo", "Stat", "MDK", "Game", "Surv", },
		removemedals = { "icarus1", "icarus2", "explorer", "conqueror", "competn1", "competn2", "competn3", "untouchable1", "untouchable2", "untouchable3" },
		win_mortem    = "Defeated General Fettgesicht",
		win_highscore = "Completed Episode 6",

		OnCreateEpisode = function ()
			DoomRL.ep6_OnCreateEpisode()
		end,
		OnIntro = function ()
			return DoomRL.ep6_OnIntro()
		end,
		OnWinGame = function ()
			return DoomRL.ep6_OnWinGame()
		end,
		OnGenerate = function ()
			DoomRL.ep6_OnGenerate()
			return false
		end,

		OnMortem = function ()
			if player:has_won() then player:add_badge("offenbach1") end
			if player:has_won() and DIFFICULTY >= DIFF_MEDIUM then player:add_badge("offenbach2") end
			if player:has_won() and DIFFICULTY >= DIFF_HARD then player:add_badge("offenbach3") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD then player:add_badge("offenbach4") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD and player:get_trait( traits["ironman"].nid ) <= 0 and player:get_trait( traits["nails"].nid ) <= 0 then player:add_badge("offenbach5") end
			if player:has_won() and DIFFICULTY >= DIFF_VERYHARD and player:get_trait( traits["ironman"].nid ) <= 0 and player:get_trait( traits["hellrunner"].nid ) <= 0 and player:get_trait( traits["nails"].nid ) <= 0 and player:get_trait( traits["eagle"].nid ) <= 0 then player:add_badge("offenbach6") end
			if player:has_won() then player:add_medal("award6") end
		end,
	}
end

function DoomRL.ep6_OnCreateEpisode()

	--Assign our levels.  There's too much flair to loop
	player.episode = {}
	player.episode[1]  = {style = table.random_pick( { STYLE_BLUE,     STYLE_RED                                     } ), number = 1,  name = "Offenbach", deathname = "Offenbach", danger = 2}
	player.episode[2]  = {style = STYLE_WHITE,                                                                            number = 2,  name = "Offenbach", deathname = "Offenbach", danger = 2}
	player.episode[3]  = {style = STYLE_WHITE,                                                                            number = 3,  name = "Offenbach", deathname = "Offenbach", danger = 4}
	player.episode[4]  = {style = table.random_pick( { STYLE_GREEN,    STYLE_BROWN                                   } ), number = 4,  name = "Offenbach", deathname = "Offenbach", danger = 5}
	player.episode[5]  = {style = STYLE_WHITE,                                                                            number = 5,  name = "Offenbach", deathname = "Offenbach", danger = 7}
	player.episode[6]  = {style = STYLE_WHITE,                                                                            number = 6,  name = "Offenbach", deathname = "Offenbach", danger = 8}
	player.episode[7]  = {style = table.random_pick( { STYLE_BROWN,    STYLE_RED,      STYLE_WHITE                   } ), number = 7,  name = "Offenbach", deathname = "Offenbach", danger = 10}
	player.episode[8]  = {style = table.random_pick( { STYLE_BROWN,    STYLE_BLUE,     STYLE_GREEN,    STYLE_PURPLE  } ), number = 8,  name = "Offenbach", deathname = "Offenbach", danger = 11}
	player.episode[9]  = {style = STYLE_WHITE,                                                                            number = 9,  name = "Offenbach", deathname = "Offenbach", danger = 13}
--[[--]]	player.episode[10] = {style = STYLE_WHITE,                                                                            number = 10, name = "Offenbach", deathname = "Offenbach", danger = 14}

	player.episode[10] = {script = "boss6", style=STYLE_WHITE, deathname = "Offenbach"}

	--Episodes only get one special level.
	local level_proto = levels["spec6"]
	if (not level_proto.canGenerate) or level_proto.canGenerate() then
		player.episode[resolverange(level_proto.level)].special = level_proto.id
	end
	statistics.bonus_levels_count = 1
end
function DoomRL.ep6_OnIntro()
	DoomRL.plot_intro_6()
	return false
end
function DoomRL.ep6_OnWinGame()
	DoomRL.plot_outro_6()
	return false
end
function DoomRL.ep6_OnGenerate()
	--Maybe I can tweak this later.
	DoomRL.ep7_OnGenerate()
end
