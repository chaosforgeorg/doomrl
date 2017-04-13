-- Episode 7: Spear of Destiny.  This is the main game.
require( "doomrl:levels/ep7_spear1" )
require( "doomrl:levels/ep7_spear2" )
require( "doomrl:levels/ep7_spear3" )
require( "doomrl:levels/ep7_spear4" )
require( "doomrl:levels/ep7_spear5" )
require( "doomrl:levels/ep7_spec1" )
require( "doomrl:levels/ep7_spec2" )
require( "doomrl:levels/ep7_spec3" )
require( "doomrl:levels/ep7_spec4" )
require( "doomrl:levels/ep7_spec5" )
require( "doomrl:levels/ep7_tll1" )
require( "doomrl:levels/ep7_tll2" )
require( "doomrl:levels/ep7_tll3" )
require( "doomrl:levels/ep7_tll4" )

--[[ Wolf3d Level notes (I don't like brown BTW, there's no way to make it look good ):

mossy + white 701 - XTIPTOE.mp3
moss very little red/white - 720 - XFUNKIE.mp3
stone white some red - 703 - XDEATH.mp3
lots of brown stone, some hidden purple - 704 - XGETYOU.mp3
*s* stone purple blue black - 719 - XJAZNAZI.mp3
*b* dark stone
blue red - 210 - DUNGEON.mp3
blue moss - 203 - GOINGAFT 208.mp3
blue some moss - 103 - POW 107.mp3
 mostly blue red moss - 303 - TWELFTH.mp3
*b* blue red
white - 201 - NAZI OMI 205.mp3
white stone occasional blue - 101 - GETTHEM 105.mp3
*s* black stone white purple - 720 - XFUNKIE.mp3
stone dark stone - 104 - SUSPENSE.mp3
stone dark stone (minor) red white purple wood - 102 - SEARCHN 106.mp3
red white stone dark wood - 304 - ZEROHOUR.mp3
*b* white wood red dark
white darkstone - 717 - XPUTIT.mp3
*b* stone
*b* blood
]]--

function DoomRL.ep7_OnCreateEpisode()

	--Assign our levels.  There's too much flair to loop
	player.episode = {}
	player.episode[1]  = {style = table.random_pick( { STYLE_GREEN,    STYLE_GREEN,    STYLE_WHITE                  } ), number = 1, name = "Nuremberg Tunnels",  deathname = "the Nuremberg Tunnels",  danger = 2}
	player.episode[2]  = {style = table.random_pick( { STYLE_GREEN,    STYLE_GREEN,    STYLE_WHITE,    STYLE_RED    } ), number = 2, name = "Nuremberg Tunnels",  deathname = "the Nuremberg Tunnels",  danger = 2}
	player.episode[3]  = {style = table.random_pick( { STYLE_GREEN,    STYLE_WHITE,    STYLE_WHITE,    STYLE_RED    } ), number = 3, name = "Nuremberg Tunnels",  deathname = "the Nuremberg Tunnels",  danger = 3}
	player.episode[4]  = {style = table.random_pick( { STYLE_GREEN,    STYLE_WHITE,    STYLE_DARK                   } ), number = 4, name = "Nuremberg Tunnels",  deathname = "the Nuremberg Tunnels",  danger = 4}
	player.episode[5]  = {style = STYLE_WHITE,                                                                           number = 5, name = "Nuremberg Tunnels",  deathname = "the Nuremberg Tunnels",  danger = 5}
--[[--]]	player.episode[6]  = {style = STYLE_WHITE,                                                                           number = 6, name = "Nuremberg Tunnels",  deathname = "the Nuremberg Tunnels",  danger = 6}
	player.episode[7]  = {style = table.random_pick( { STYLE_BLUE,     STYLE_RED                                    } ), number = 1, name = "Nuremberg Dungeon",  deathname = "the Nuremberg Dungeon",  danger = 7}
	player.episode[8]  = {style = table.random_pick( { STYLE_BLUE,     STYLE_GREEN                                  } ), number = 2, name = "Nuremberg Dungeon",  deathname = "the Nuremberg Dungeon",  danger = 8}
	player.episode[9]  = {style = table.random_pick( { STYLE_BLUE,     STYLE_BLUE,     STYLE_GREEN                  } ), number = 3, name = "Nuremberg Dungeon",  deathname = "the Nuremberg Dungeon",  danger = 9}
	player.episode[10] = {style = table.random_pick( { STYLE_BLUE,     STYLE_BLUE,     STYLE_RED                    } ), number = 4, name = "Nuremberg Dungeon",  deathname = "the Nuremberg Dungeon",  danger = 10}
	player.episode[11] = {style = table.random_pick( { STYLE_BLUE,     STYLE_RED                                    } ), number = 5, name = "Nuremberg Dungeon",  deathname = "the Nuremberg Dungeon",  danger = 11}
--[[--]]	player.episode[12] = {style = STYLE_BLUE,                                                                            number = 6, name = "Nuremberg Dungeon",  deathname = "the Nuremberg Dungeon",  danger = 12}
	player.episode[13] = {style = STYLE_WHITE,                                                                           number = 1, name = "Nuremberg Castle",   deathname = "the Nuremberg Castle",   danger = 13}
	player.episode[14] = {style = table.random_pick( { STYLE_WHITE,    STYLE_WHITE,    STYLE_BLUE                   } ), number = 2, name = "Nuremberg Castle",   deathname = "the Nuremberg Castle",   danger = 14}
	player.episode[15] = {style = STYLE_WHITE,                                                                           number = 3, name = "Nuremberg Castle",   deathname = "the Nuremberg Castle",   danger = 15}
	player.episode[16] = {style = table.random_pick( { STYLE_WHITE,    STYLE_WHITE,    STYLE_RED,      STYLE_BROWN  } ), number = 4, name = "Nuremberg Castle",   deathname = "the Nuremberg Castle",   danger = 16}
	player.episode[17] = {style = table.random_pick( { STYLE_WHITE,    STYLE_WHITE,    STYLE_RED,      STYLE_BROWN  } ), number = 5, name = "Nuremberg Castle",   deathname = "the Nuremberg Castle",   danger = 17}
	player.episode[18] = {style = table.random_pick( { STYLE_WHITE,    STYLE_WHITE,    STYLE_RED,      STYLE_BROWN  } ), number = 6, name = "Nuremberg Castle",   deathname = "the Nuremberg Castle",   danger = 18}
--[[--]]	player.episode[19] = {style = STYLE_WHITE,                                                                           number = 7, name = "Nuremberg Castle",   deathname = "the Nuremberg Castle",   danger = 19}
	player.episode[20] = {style = STYLE_WHITE,                                                                           number = 1, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 20}
	player.episode[21] = {style = table.random_pick( { STYLE_WHITE,    STYLE_WHITE,    STYLE_PURPLE                 } ), number = 2, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 21}
	player.episode[22] = {style = table.random_pick( { STYLE_WHITE,    STYLE_WHITE,    STYLE_BLUE                   } ), number = 3, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 22}
	player.episode[23] = {style = table.random_pick( { STYLE_WHITE,    STYLE_DARK,     STYLE_PURPLE                 } ), number = 4, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 23}
	player.episode[24] = {style = STYLE_WHITE,                                                                           number = 5, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 24}
--[[--]]	player.episode[25] = {style = STYLE_WHITE,                                                                           number = 6, name = "Nuremberg Ramparts", deathname = "the Nuremberg Ramparts", danger = 25}
--[[--]]	player.episode[26] = {style = STYLE_HELL,                                                                            number = 1, name = "Hell",               deathname = "Hell",                   danger = 50}

	player.episode[6]  = {script = "spear1", style=STYLE_WHITE, deathname = "the Nuremberg Tunnels"}
	player.episode[12] = {script = "spear2", style=STYLE_BLUE,  deathname = "the Nuremberg Dungeon"}
	player.episode[19] = {script = "spear3", style=STYLE_WHITE, deathname = "the Nuremberg Castle"}
	player.episode[25] = {script = "spear4", style=STYLE_WHITE, deathname = "the Nuremberg Ramparts"}
	player.episode[26] = {script = "spear5", style=STYLE_HELL,  deathname = "Hell"}

	--Handle the special levels
	for _,level_proto in ipairs(levels) do
		if level_proto.level then
			if (not level_proto.canGenerate) or level_proto.canGenerate() then
				if not (level_proto.chance and (math.random(100) > level_proto.chance)) then
					player.episode[resolverange(level_proto.level)].special = level_proto.id
				end
			end
		end
	end

	local SpecLevCount = 0
	for i=1,25 do
		if player.episode[i].special then
			SpecLevCount = SpecLevCount + 1
		end
	end
	statistics.bonus_levels_count = SpecLevCount
end
function DoomRL.ep7_OnIntro()
	DoomRL.plot_intro_7()
	return false
end
function DoomRL.ep7_OnWinGame()
	if kills.get("wolf_bossangel") > 0 then
		DoomRL.plot_outro_7(true)
	elseif player.depth > 25 then
		DoomRL.plot_outro_7()
	end

	return false
end
function DoomRL.ep7_OnGenerate()

	core.log("DoomRL.OnGenerate()")

	local dlevel = level.danger_level
	local choice = weight_table.new()
	for _,g in ipairs(generators) do
		if dlevel >= g.min_dlevel and DIFFICULTY >= g.min_diff then
			local weight = core.ranged_table( g.weight, dlevel ) 
			choice:add( g, weight )
		end
	end
	if choice:size() == 0 then error("NO GENERATOR AVAILABLE!") end
	local gen = choice:roll()
	generator.run( gen )
end
