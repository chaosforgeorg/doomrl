-- CONTAINMENT AREA -----------------------------------------------------

register_level "containment_area"
{
	name  = "Containment Area",
	entry = "On level @1 he arrived at the Containment Area.",
	welcome = "You enter the Containment Area. You feel something is hidden behind this wall.",
	level = 11,

	Create = function ()
		level:set_generator_style( 2 )
		level:fill( "wall" )

		local translation = {
			['.'] = "floor",
			['#'] = { "wall", style = 1, },
			['P'] = { "wall", flags = { LFPERMANENT } },
			['*'] = "gwall",
			[','] = { "floor", flags = { LFBLOOD } },
			['+'] = "door",
			['L'] = "ldoor",
			['>'] = "stairs",
			['$'] = "crate",
			['&'] = "ycrate",
			['%'] = "crate_ammo",
			['@'] = "crate_armor",
			['i'] = { "floor", being = "imp" },
			['c'] = { "floor", being = "demon" },


			['^'] = { "floor", item = "backpack" },
			['!'] = { "floor", item = "umbazooka" },
			['|'] = { "floor", item = "procket" },
			['-'] = { "floor", item = "pammo" },
		}

		local map = [[
...........######..........&&..................#.................PPP......PP
.>.........######..$$......&&...&&........%%...#...**...**...**..PP........P
...........######..$$..%%.......&&..&&....%%...#...**...**...**..P..........
...........######...&&&%%...$$.$$...&&.....&&..#.................P..........
...........######...&&&.....$$.$$..$$..$$..&&..#.................P..........
............#####.......$$.........$$..$$..$$..L........,,..................
............#####..$$...$$....&&..&&$$&&...$$..L......,,,,,............^....
............#####..$$...&&..$$&&..&&$$&&$$.....L.......,,...................
...........######.....$$@@..$$.....&&...$$.....#.................P..........
...........######.....$$@@...&&....&&....&&....#.................P..........
...........######..$$........&&...$$.....&&....#...**...**...**..P..........
...........######..$$..$$&&..$$...$$..@@....$$.#...**...**...**..PP........P
...........######......$$&&..$$.......@@....$$.#.................PPP......PP
PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPLPPPPLPPPPLPPPPPPPPPPPPPP
PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP..c.c.P...P.i.i..PPPPPPPPPPP
PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP...-..P.!.P..|...PPPPPPPPPPP
PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP..c.c.P...P.i.i..PPPPPPPPPPP
PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP
]]
		generator.place_tile( translation, map, 2, 2 )

		level.data.left   = area.new( 19, 2, 48, 14 ) 
		level.data.middle = area.new( 50, 2, 66, 14 ) 
		level.data.right  = area.new( 68, 2, 78, 14 ) 

		local total   = 5 + 2*DIFFICULTY
		level:summon{ "imp", total, area = level.data.left }

		level:player(2,2)
		level.status = 0
	end,

	OnKillAll = function ()
		if level.status ~= 3 then return end
		ui.msg("I guess I prefered the Wall.")
		level.status = 4
		if CHALLENGE == "challenge_aohu" then
			player:add_medal("everysoldier")
		end
	end,

	OnTick = function ()
		local res = level.status
		if res > 2 then return end
		if res < 2 and level.data.middle:contains( player.position ) then
			ui.msg( "\"This is too easy...\"" )
			res = 2
		end
		if level.data.right:contains( player.position ) then
			ui.msg( "\"It's a trap!\"" )
			level:transmute("ldoor","door")
			res = 3
			level:play_sound( "phasing", player.position )
			
			local total   = 8 + DIFFICULTY
			local knights = math.max( 9 - (3*( DIFFICULTY - 1 ) ), 0 )
			level:summon{ "knight", knights,         area = level.data.middle }
			level:summon{ "baron",  total - knights, area = level.data.middle }
			if DIFFICULTY >= 4 then
				level:summon{ "arch",  DIFFICULTY-3,     area = level.data.middle }
			end
			level:play_sound( "phasing", player.position, 50 ) 
			level:play_sound( "baron.act", player.position, 100 )
		end
		level.status = res
	end,

	OnKill = function ()
		if level.status < 1 then
			level.status = 1
		end
	end,

	OnExit = function ()
		local result = level.status
		if result == 0 then
			ui.msg("I guess this tincan will stay closed...")
			player:add_history("Not knowing what to do, he left.")
		elseif result < 4 then
			ui.msg("It's way too hairy down here!")
			player:add_history("He broke into the Containment Area, but gave up against the overwhelming forces.")
		elseif result == 4 then
			ui.msg("Luckily it's not as bad as tricks and traps...")
			player:add_history("He emerged from the Containment Area victorious!")
			player:add_badge("wall1")
			if core.is_challenge("challenge_aomr") or core.is_challenge("challenge_aob") or core.is_challenge("challenge_aosh") then
				player:add_badge("wall2")
			end
		end
	end,

	OnCompletedCheck = function ()
		return level.status > 3
	end,
}
