-- HOUSE OF PAIN --------------------------------------------------------
--[[
register_level "house_of_pain"
{
	name  = "House of Pain",
	entry = "On level @1 he trespassed on the House of Pain.",
	level = 19,
	welcome = "You enter the House of Pain.",

	canGenerate = function ()
		return DIFFICULTY > 1
	end,

	OnCompletedCheck = function ()
		return level.status > 1
	end,

	OnUse = function (item)
		if item.id == "phase" or item.id == "hphase" or item.id == "hstaff" then
			ui.msg("Hey, no teleporting in the House!")
			return false
		elseif item.id == "uarenastaff" then
			level.data.is_staff = true
		end
	end,

	Create = function ()
		level.style = 1
		generator.fill("rwall")
		level.data.is_staff = false

		local translation = {
			['.'] = "floor",
			[','] = {"floor", flags = {LFBLOOD} },
			['#'] = {"iwall", flags = {LFPERMANENT} },
			['$'] = {"gwall", flags = {LFPERMANENT} },
			['Z'] = {"rwall", flags = {LFPERMANENT} },
			['+'] = "door",
			['>'] = "stairs",
			['-'] = "water",
			['~'] = "acid",
			['='] = "lava",

			['c'] = { "floor", being = core.bydiff{"lostsoul", "demon", "demon", "demon", "demon"} },
			['w'] = { "water", being = core.bydiff{"demon", "demon", "demon", "arachno", "arachno"} },
			['A'] = { "floor", being = core.bydiff{"demon", "arachno", "arachno", "arachno", "narachno"} },
			['^'] = { "floor", item = "lhglobe" },
			['1'] = { "floor", item = "ammo" },
			['2'] = { "floor", item = "shell" },
			['3'] = { "floor", item = "rocket" },
			['4'] = { "floor", item = "cell" },
			['5'] = { "floor", item = "pammo" },
			['6'] = { "floor", item = "pshell" },
			['7'] = { "floor", item = "procket" },
			['8'] = { "floor", item = "pcell" },
		}

		local map = [=[
############################$$$$$$$$$$$$$$$$$$$$$$$$ZZZZZZZZZZZZZZZZZZZZZZZZZZ
#######3..A#####A..4#######..$12.......$$.......34$..ZZZZZZZ===========ZZZZZZZ
#####........#........#####..$4........$$........1$..ZZZZZ===.........===ZZZZZ
####2....---------....1####.^+..$$$....$$....$$$..+..ZZZZ==.............==ZZZZ
###....---#######---....###..+..$$2..........3$$..+..ZZZ==...ZZ....ZZ....==ZZZ
##1..--w###.....###w--..2##..$..$1............4$..$..ZZ==...ZZ......ZZ....==ZZ
#..---###c...#...c###---..#..$.....$$~~~...$$.....$..Z==...ZZ........ZZ....==Z
#..-###......#......###-..#..$.....$~~~~~~~~$.....$..Z=...ZZ...ZZZZ...ZZ....=Z
#..--.......###.......--..#..$......~~$$$$~~~.....$..Z...ZZ5..........8ZZ...=Z
#c.--.....###.#######.--..+..$$$$...~~$$$$~~~..$$$$.^+...ZZZZZ..ZZ..ZZZZZ...=Z
#..--.#######.###.....--.c+..$$$$..~~~$$$$~~...$$$$.^+...ZZZZZ..ZZ..ZZZZZ...=Z
#..--.......###.......--..#..$.....~~~$$$$~~......$..Z...ZZ6..........7ZZ...=Z
#..-###......#......###-..#..$.....$~~~~~~~~$.....$..Z=...ZZ...ZZZZ...ZZ....=Z
#..---###c...#...c###---..#..$.....$$...~~~$$.....$..Z==...ZZ........ZZ....==Z
##4..--w###.....###w--..3##..$..$4............1$..$..ZZ==...ZZ......ZZ....==ZZ
###....---#######---....###..+..$$3..........2$$..+..ZZZ==...ZZ....ZZ....==ZZZ
####3....---------....4####.^+..$$$....$$....$$$..+..ZZZZ==.............==ZZZZ
#####........#........#####..$3........$$........2$..ZZZZZ===.........===ZZZZZ
#######2..A#####A..1#######..$21.......$$.......43$..ZZZZZZZ===========ZZZZZZZ
############################$$$$$$$$$$$$$$$$$$$$$$$$ZZZZZZZZZZZZZZZZZZZZZZZZZZ
]=]
		generator.place_tile( translation, map, 1, 1 )
		generator.set_permanence( area.FULL )

		level:player(14,10)
	end,

	OnKillAll = function ()
		local res = level.status
		if res < 5 then
			if not level.data.is_staff then
				ui.msg("The doors unlock.")
				generator.transmute("ldoor","door")
				generator.set_permanence(area.FULL, true, "door")
			end
			if res == 0 then
				level.status = 1
			elseif res == 2 then
				level.status = 3
			elseif res == 4 then
				ui.msg("The voice wails: \"I'm impressed! Why don't you come back to ")
				ui.msg("the first room and we'll see if I can't give you a just reward.")
				generator.transmute( { "iwall", "gwall" }, "rwall")
				level.status = 5
			end
		end
	end,

	OnTick = function ()
		local res = level.status
		if res < 6 then
			if res == 1 and player.x > 33 then
				local room_2 = area.new( 31, 2, 50, 19 )
				level:summon{ core.ifdiff( 4, "ncacodemon", "cacodemon" ), core.ifdiff( 4, 2, 4 ), area = room_2 }
				level:summon{ core.ifdiff( 3, "baron", "knight" ), core.bydiff{ 0, 2, 2, 2, 4 }, area = room_2 }
				level.status = 2
			elseif res == 3 and player.x > 55 then
				local room_3 = area.new( 55, 2, 77, 19 )
				level:summon{ "mancubus", core.ifdiff( 4, 4, 2 ), area = room_3 }
				if DIFFICULTY > 1 then level:summon{ "revenant" , core.ifdiff( 5, 4, 2 ), area = room_3 } end
				if DIFFICULTY > 2 then level:summon{ "arch" , area = room_3 } end
				level.status = 4
			elseif res == 5 and player.x < 27 then
				ui.msg("The voice laughs: \"Allow me to present you your just reward!\"")
				local room_1 = area.new( 7, 7, 21, 14 )
				level:summon{ core.ifdiff( 3, "narch", "arch" ), core.bydiff{ 1, 1, 2, 1, 1 }, area = room_1 }
				for i=1,8 do
					level:area_drop( room_1, level:roll_item{ level = 20, type = ITEMTYPE_RANGED, unique_mod = 5 } )
					level:area_drop( room_1, level:roll_item{ level = 20, type = {ITEMTYPE_ARMOR,ITEMTYPE_BOOTS}, unique_mod = 5 } )
				end
				generator.set_cell( coord.new(14,11), "stairs" )
				level.status = 6
			else return
			end
			if not level.data.is_staff then
				player:play_sound("door.close")
				generator.transmute({"door","odoor"},"ldoor")
				generator.set_permanence(area.FULL, true, "ldoor")
				ui.msg("The doors shut violently!")
			end
		end
	end,


	OnEnter = function ()
		level.status = 0
		ui.msg("A deathly high-pitched voice cackles! \"Well, who do we have here?\"")
		ui.msg(" it begins. \"It seems that you've stumbled into my luxurious home.")
		local choice = ui.msg_confirm("Would you care to have access?")

		if choice then
			ui.msg("Well then, enjoy yourself. Just be wary of my other guests!")
			generator.transmute( "iwall", "floor", area.new(13,9,15,12) )
		else
			ui.msg("No? All right, I'll see you out then.")
			generator.set_cell( coord.new(14,11), "stairs" )
		end

	end,

	OnExit = function ()
		local result = level.status
		if result == 0 then
			ui.msg("Let it lie, that which is eternally dead...")
			-- XXX Originally "Armory", but I think it should refer to the House?
			player:add_history("He left the House without drawing too much attention.")
		elseif result == 1 then
			ui.msg("This is madness!")
			player:add_history("He fled being chased by a nightmare!")
		else
			ui.msg("Gotta love the craft...")
			player:add_history("He destroyed the evil within and reaped the rewards!")
		end
	end,


}
]]--