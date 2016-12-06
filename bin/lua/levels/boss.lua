-- BOSS LEVELS ----------------------------------------------------------

register_badge "hellgate1"
{
	name  = "Gatekeeper Bronze Badge",
	desc  = "Clear out the Anomaly",
	level = 1,
}

register_badge "hellgate2"
{
	name  = "Gatekeeper Silver Badge",
	desc  = "Clear the Anomaly w/o taking damage",
	level = 2,
}

register_badge "hellgate3"
{
	name  = "Gatekeeper Gold Badge",
	desc  = "Clear Babel on HNTR w/o taking damage",
	level = 3,
}

register_badge "hellgate4"
{
	name  = "Gatekeeper Platinum Badge",
	desc  = "Pass the Anomaly on N! w/o taking damage",
	level = 4,
}

register_badge "hellgate5"
{
	name  = "Gatekeeper Diamond Badge",
	desc  = "Clear Anomaly+Babel on UV w/o taking damage",
	level = 5,
}

register_level "hellgate"
{
	name  = "Phobos Anomaly",
	entry = "On level @1 he encountered the Phobos Anomaly.",
	welcome = "You arrive at the Phobos Anomaly.",

	OnRegister = function ()

		register_item "hellportal"
		{
			name     = "Hellgate",
			ascii    = "0",
			color    = MULTIPORTAL,
			sprite   = SPRITE_PORTAL,
			weight   = 0,
			flags    = { IF_NODESTROY, IF_NUKERESIST },

			type = ITEMTYPE_TELE,

			OnEnter = function( self, being )
				if not being:is_player() then return end
				level:explosion( being.position, 4, 50, 0, 0, GREEN, core.resolve_sound_id( "hellgate.use", "teleport.use", "use" ) )
				ui.msg_enter("You feel yanked in a non-existing direction!")
				player:exit()
				DoomRL.plot_outro_1()
			end,
		}
		
	end,

	Create = function ()
		generator.fill( "wall", area.FULL )
		generator.fill( "floor", area.FULL_SHRINKED )

		local translation = {
			['.'] = "floor",
			[','] = "rock",
			[':'] = { "floor", flags = { LFBLOOD } },
			['#'] = "wall",
			['%'] = "rwall",
			['*'] = { "rwall", flags = { LFBLOOD } },
			['+'] = "door",

			['B'] = { "floor", being = "bruiser" },
			['a'] = { "floor", being = core.bydiff{nil, "lostsoul",  "lostsoul",  "demon",     "ndemon"}     },
			['b'] = { "floor", being = core.bydiff{nil, "lostsoul",  "demon",     "imp",       "nimp"}       },
			['c'] = { "floor", being = core.bydiff{nil, "lostsoul",  "cacodemon", "cacodemon", "ncacodemon"} },
			['d'] = { "floor", being = core.bydiff{nil, "cacodemon", "cacodemon", "cacodemon", "ncacodemon"} },

			['^'] = { "floor", item = "lhglobe" },
			['!'] = { "floor", item = "lmed" },
			['|'] = { "floor", item = "ammo" },
			['/'] = { "floor", item = "rocket" },
			['-'] = { "floor", item = "shell" },
			['['] = { "floor", item = "rarmor" },

			['0'] = { "floor", item = "hellportal" },
		}

		if DIFFICULTY == DIFF_EASY then
			translation['a'] = "wall"
			translation['b'] = "wall"
			translation['c'] = "wall"
			translation['d'] = "wall"
		end

		local map = [=[
################################,,,,,,,,,,,,,,,,,%%%%%%%%%%%%%%%%%%%%%%%%%%%
################################,,,,,,,,,,,,,,,,,,%%%%%%..............%%%%%%
##########c###b#######b###d#####,,,,,,,,,,,,,,,,,,,%%%...................%%%
############a###a###a###a#######,,,,,,,,,,,,,,,,,,,%........::%%..........%%
################################,,,,,,,,,,,,,,,,,,,%.......::%%%%..........%
!-|/.^#:::..:..:::...:.:.:::#.....,,,,,,,,,,,,,,,,,*........:##B%....%%%%..%
....:.#:.....:.............:#.......,,,,,,,,,,,,,,,*........:%%%%...%%##%%.%
.....:#.....................#................,,,,..*........::%%....%####%/%
[...::+.....................+......................*................###0#%/%
.....:#.....................#..........,,,,........*.........:%%....%####%/%
....::#::....:...........:::#.......,,,,,,,,,,,,,,,*.......::%%%%...%%##%%.%
!-|/.^#::::.:.:::..::.:.:.::#.....,,,,,,,,,,,,,,,,,*........:##B%....%%%%..%
################################,,,,,,,,,,,,,,,,,,,%.......::%%%%..........%
############a###a###a###a#######,,,,,,,,,,,,,,,,,,,%........::%%..........%%
##########c###b#######b###d#####,,,,,,,,,,,,,,,,,,,%%%...................%%%
################################,,,,,,,,,,,,,,,,,,%%%%%%..............%%%%%%
################################,,,,,,,,,,,,,,,,,%%%%%%%%%%%%%%%%%%%%%%%%%%%
#################################################%%%%%%%%%%%%%%%%%%%%%%%%%%%
]=]

		generator.place_tile( translation, map, 2, 2 )
		generator.set_permanence( area.new( 1, 1, 50, 6 ) )
		generator.set_permanence( area.new( 1, 14, 50, MAXY ) )
		generator.set_permanence( area.new( 51, 1, MAXX, MAXY ) )

		level:player(2,10)
		level.flags[ LF_NOHOMING ] = true
	end,

	OnEnter = function ()
		level.status = 1
		ui.msg_feel("You sense a certain tension.")
		player:play_sound("baron.act")
	end,

	OnKillAll = function ()
		ui.msg("Why do they have to come in pairs? And what's that shimmering thing?")
		player:add_badge("hellgate1")
		if not level.flags[ LF_NUKED ] and statistics.damage_on_level == 0 then
			player:add_badge("hellgate2")
			if DIFFICULTY >= DIFF_VERYHARD then
				player:add_property("anomaly_win",true)
			end
		end
	end,

	OnTick = function ()
		local res = level.status
		if res > 2 then return end
		if res == 1 and player.x > 20 then
			if DIFFICULTY > DIFF_EASY then
				ui.msg("Suddenly the walls lower!")
				player:play_sound("door.close")
				generator.transmute( "wall", "floor", area.new( 9, 4, 29, 16 ) )
			end
			level.status = 2
		end
		if res == 2 and player.x > 50 then
			ui.msg("Suddenly the walls disappear!")
			player:play_sound("barrel.explode")
			generator.transmute( "rwall", "floor", area.new( 53, 7, 60, 13 ) )
			generator.transmute( "wall", "floor",  area.new( 60, 7, 74, 13 ) )
			level.status = 3
		end
	end,

	OnExit = function ()
		if DIFFICULTY >= DIFF_NIGHTMARE and not level.flags[ LF_NUKED ] and statistics.damage_on_level == 0 then player:add_badge("hellgate4") end
	end,


}

register_level "tower_of_babel"
{
	name  = "Tower of Babel",
	entry = "On level @1 he found the Tower of Babel!",
	welcome = "You enter a big arena. There's blood everywhere. You hear heavy mechanical footsteps...",
	welcome = "You reach the Tower of Babel.",

	Create = function ()
		generator.fill( "wall", area.FULL )
		generator.fill( "floor", area.FULL_SHRINKED )
		local scatter_area = area.new( 5,3,68,15 )
		local translation = {
			['.'] = { "floor", flags = { LFBLOOD } },
			['#'] = "gwall",
			['>'] = "stairs",
		}
		generator.scatter_put(scatter_area,translation, [[
.....
.###.
.###.
.###.
.....
]]
		,"floor",12)

		level.flags[ LF_NOHOMING ] = true
		generator.scatter_blood(area.FULL_SHRINKED,"floor",100)
	end,

	OnEnter = function ()
		local boss = level:summon("cyberdemon")
	end,

	OnKillAll = function ()
		if not (level.flags[ LF_NUKED ] and not player.flags[BF_INV]) then
			player:exit()
			DoomRL.plot_outro_2()
			if not level.flags[ LF_NUKED ] and statistics.damage_on_level == 0 then
				if DIFFICULTY >= DIFF_MEDIUM then player:add_badge("hellgate3") end
				if DIFFICULTY >= DIFF_VERYHARD and player:has_property("anomaly_win") then player:add_badge("hellgate5") end
			end
		end
	end,

}

register_level "dis"
{
	name = "Dis",
	entry = "Then at last he found Dis!",
	welcome = "You enter the damned city of Dis...",

	OnRegister = function ()

		register_item "dis_switch"
		{
			name   = "lever",
			color  = MAGENTA,
			sprite = SPRITE_LEVER,
			weight = 0,

			type     = ITEMTYPE_LEVER,
			flags    = { IF_NODESTROY },
			color_id = false,

			good = "dangerous",
			desc = "woah!",

			OnUse = function(self,being)
				generator.transmute( "wall", "floor" )
				return true
			end,
		}

	end,

	Create = function ()
		generator.fill( "rwall", area.FULL )
		generator.fill( "floor", area.FULL_SHRINKED )
		local translation = {
			['.'] = "floor",
			[','] = { "floor", flags = { LFBLOOD } },
			['Z'] = "wall",
			['W'] = "rwall",
			['#'] = "gwall",
			['>'] = "stairs",
			['/'] = { "floor", item = "dis_switch" },
		}

		generator.place_tile( translation, [[
>WWWWWWWWWWWWWWWWWWWWW................................WWWWWWWWWWWWWWWWWWWWW>
WWWWWWWWWWWWWWWWWWWWW...............####...............WWWWWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWWWW.......####.....####.....####.......WWWWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWWW........####.....####.....####........WWWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWW.........####.....####.....####.........WWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWZZZZ......####..............####......ZZZZWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWW....Z................,,................Z....WWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWW....####.........,,.,,,,,...........####....WWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWW.../####..........,,,,,,,,,,........####....WWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWW....####...........,,,,,,,,.........####/...WWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWW....####.........,,,,,,,,,..........####....WWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWW....Z...............,,,,...............Z....WWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWZZZZ......####..............####......ZZZZWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWW.........####.....####.....####.........WWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWWW........####.....####.....####........WWWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWWWW.......####.....####.....####.......WWWWWWWWWWWWWWWWWWWW
WWWWWWWWWWWWWWWWWWWWW...............####...............WWWWWWWWWWWWWWWWWWWWW
>WWWWWWWWWWWWWWWWWWWWW................................WWWWWWWWWWWWWWWWWWWWW>
]]
		, 2,2 )
		generator.set_permanence( area.new( 1, 1, 10, MAXY ) )
		generator.set_permanence( area.new( MAXX-10, 1, MAXX, MAXY ) )

		level.flags[ LF_NOHOMING ] = true
		if math.random( 2 ) == 1 then
			level:player(19,11)
		else
			level:player(60,10)
		end
		player.flags[ BF_STAIRSENSE ] = false
	end,

	OnNuked = function()
		if player.hp > 0 then
			ui.msg_enter("You ingenious son of a gun! You're as smart as Hell itself!")
			ui.msg("But... something's wrong!")
			ui.msg("You sense a menace, a threat so evil it kills your mind!")
			ui.msg("Was not all evil destroyed???")
			player.score = player.score + 10000
			player:continue_game()
		end
	end,

	OnEnter = function ()
		local boss = level:drop_being("mastermind",coord.new(39,19))
		boss.flags[ BF_BOSS ] = true
	end
}

register_level "hell_fortress"
{
	name = "Hell Fortress",
	entry = "He defeated the Mastermind and found the TRUE EVIL!",
	welcome = "This is it. This is the lair of all evil! What will you meet here?",

	Create = function ()
		generator.fill( "rwall", area.FULL )
		generator.fill( "floor", area.FULL_SHRINKED )
		local translation = {
			[','] = { "floor", flags = { LFBLOOD } },
			['.'] = "floor",
		}

		generator.place_tile( translation, [[
............................................................................
............................................................................
............................................................................
............................................................................
.....................,,,,,,,,,,,,,,,........................................
.....................,,,,,,,...,,,,,..........,,,,..........................
.....................,,,,,,,...,,,,,..........,,,...........................
.....................,,,,,,,,,,,,,,,..........,,,...........................
.....................,,,,,,....,,,,,....,,,,,,,,,...........................
.....................,,,,,,,...,,,,,...,,,...,,,,...........................
.....................,,,,,,,...,,,,,...,,.....,,,...........................
.....................,,,,,,,...,,,,,...,,,...,,,,...........................
.....................,,,,,......,,,,....,,,,,.,,,,..........................
.....................,,,,,,,,,,,,,,,........................................
............................................................................
............................................................................
............................................................................
............................................................................
]]
		, 2,2 )

		level.flags[ LF_NOHOMING ] = true
		level:player(2,10)

		local boss
		if player.eq.armor and player.eq.armor.id == "uberarmor" then
			boss = level:drop_being("apostle",coord.new(76,11))
		else
			boss = level:drop_being("jc",coord.new(76,11))
		end
		boss.flags[ BF_BOSS ] = true
	end,

}
