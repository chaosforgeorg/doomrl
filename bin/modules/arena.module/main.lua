core.declare( "arena", {} )

function arena.OnMortemPrint(killedby)
	if arena.result then killedby = arena.result end
	player:mortem_print( " "..player.name..", level "..player.explevel.." "..klasses[player.klass].name..", "..killedby )
	player:mortem_print(" at the Hell Arena...")
end

function arena.OnEnter()
	core.play_music("doom_the_roguelike")
	player:play_sound("preparetofight")
	arena.wave = 1
	player.eq.weapon = "shotgun"
	player.inv:add( "shell", { ammo = 50 } )

	Level.result(1)
	ui.msg("A devilish voice announces:")
	ui.msg("\"Welcome to Hell's Arena, mortal!\"")
	ui.msg("\"You are either very foolish, or very brave. Either way I like it!\"")
	ui.msg("\"And so do the crowds!\"")
	player:play_sound("fight")
	ui.msg("Suddenly you hear screams everywhere! \"Blood! Blood! BLOOD!\"")
	ui.msg("The voice booms again, \"Kill all enemies and I shall reward thee!\"")
	player:play_sound("one")

	Level.summon("demon",3)
	Level.summon("lostsoul",2)
	Level.summon("cacodemon",1)
	
end

function arena.OnKill()
	local temp = math.random(3)
	if     temp == 0 then ui.msg("The crowds go wild! \"BLOOD! BLOOD!\"") 
	elseif temp == 1 then ui.msg("The crowds cheer! \"Blood! Blood!\"") 
	else                  ui.msg("The crowds cheer! \"Kill! Kill!\"") end
end

function arena.OnKillAll()
	if Level.result() == 1 then
	ui.msg("The voice booms, \"Not bad mortal! For a weakling that you ")
	ui.msg("are, you show some determination.\"");
	ui.msg("You hear screams everywhere! \"More Blood! More BLOOD!\"")
	ui.msg("The voice continues, \"I can now let you go free, or")
	ui.msg("you may try to complete the challenge!\"");

	local choice = ui.msg_confirm("\"Do you want to continue the fight?\"")

	if choice then
		player:play_sound("two")
		arena.wave = 2
		ui.msg("The voice booms, \"I like it! Let the show go on!\"")
		ui.msg("You hear screams everywhere! \"More Blood! More BLOOD!\"")
		Level.drop("chaingun")  
		Level.summon("demon",3)
		Level.summon("cacodemon",2)
		Level.result(2);
	else
		ui.msg("The voice booms, \"Coward!\" ")
		ui.msg("You hear screams everywhere! \"Coward! Coward! COWARD!\"")
	end
	return
	end

	if Level.result() == 2 then
	ui.msg("The voice booms, \"Impressive mortal! Your determination")
	ui.msg("to survive makes me excited!\"")
	ui.msg("You hear screams everywhere! \"More Blood! More BLOOD!\"")
	ui.msg("\"I can let you go now, and give you a small reward, or")
	ui.msg("you can choose to fight the final challenge!\"")
	
	local choice = ui.msg_confirm("\"Do you want to continue the fight?\"")

	if choice then
		arena.wave = 3
		player:play_sound("three")
		ui.msg("The voice booms, \"Excellent! May the fight begin!!!\"")
		ui.msg("You hear screams everywhere! \"Kill, Kill, KILL!\"")

		Level.drop("shell",4)
		Level.drop("ammo",4)
	
		Level.summon("cacodemon",3) 
		Level.result(3);
	else
		ui.msg("The voice booms, \"Too bad, you won't make it far then...!\" ")
		ui.msg("You hear screams everywhere! \"Boooo...\"")
		
		Level.drop("shell",3) 
		Level.drop("lmed")
		Level.drop("smed")
	end
	return
	end

	if Level.result() == 3 then
	ui.msg("The voice booms, \"Congratulations mortal! A pity you came to")
	ui.msg("destroy us, for you would make a formidable hell warrior!\"")
	ui.msg("\"I grant you the title of Hell's Arena Champion!\"")
	ui.msg("\"And a promise is a promise... search the arena again...\"")

	Level.drop("scglobe")
	Level.drop("barmor")
	Level.drop("lmed")

	Level.result(4)
	end
end

function arena.OnExit()
	ui.msg("The voice laughs, \"Flee mortal, flee! There's no hiding in hell!\"")
	local result = Level.result()
	if result < 4
		then arena.result = "fled alive the trials at wave "..arena.wave
		else arena.result = "completed the trials"
	end
end

function arena.run()
	Level.name = "Hell Arena"
	Level.name_number = 0
	Level.fill("rwall")
	local translation = {
		['.'] = "floor",
		[','] = "blood",
		['#'] = "rwall",
		['>'] = "stairs"
	}

	local map = [[
#######################.............................########################
###########.....................................................############
#####..................................................................#####
##........................................................................##
#..........................................................................#
............................................................................
..................................,,,,,,....................................
..,,,.............................,,,,,,,...................................
..,>,............................,,,,,,,,,..................................
..,,,............................,,,,,,,,...................................
..................................,,,,,,....................................
............................................................................
............................................................................
#..........................................................................#
##........................................................................##
#####..................................................................#####
###########.....................................................############
#######################.............................########################
	]]
	local column = [[
,..,.,
,####.
.####,
.####.
,..,.,
	]]
	
	Level.place_tile( translation, map, 2, 2 )
	Level.scatter_put( area.new(5,3,68,15), translation, column, "floor",9+math.random(8))
	Level.scatter( area.FULL_SHRINKED,"floor","blood",100)
	Level.player(38,10)
end
