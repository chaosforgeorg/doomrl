core.declare( "simple", {} )

function simple.OnMortemPrint(killedby)
	if simple.status == 2 then
		killedby = "managed to clear the level"
	end
	player:mortem_print( " "..player.name..", level "..player.explevel.." "..klasses[player.klass].name..", "..killedby )
	player:mortem_print(" although it was Dead Simple...")
end

function simple.OnEnter()
	core.play_music("dead_simple")
	ui.msg("This should be dead simple...")
end
	

function simple.OnKill()
	if simple.status == 0 then
		simple.count = simple.count - 1
		if simple.count == 0 then
			simple.status = 1
			ui.msg("What... More???")
			Generator.transmute( "wall3", "floor" )
		end
	end
end

function simple.OnKillAll()
	if simple.status ~= 2 then
		ui.msg("Yeah. Dead Simple...")
		simple.status = 2
		for x = 38,39 do
			for y = 10,11 do
				Level[ coord.new(x,y) ] = "eye"
			end
		end
	end
end

function simple.run()
	Cells{
		id = "eye",
		name = "The Eye"; 
		ascii = "*"; 
		color = MULTIPORTAL;
		flags = {CF_NOCHANGE, CF_NORUN, CF_HIGHLIGHT};
		sprite = SPRITE_PORTAL,

		OnEnter = function( c, being )
			if not being:is_player() then return end
			Level.explosion( being:get_position(), 4, 50, 0, 0, GREEN, core.resolve_sound_id( "teleport.use", "use" ) )
			ui.msg_enter("You feel yanked in an non-existing direction!")
			player:exit()
		end,
	  
    }
    
 	Cells{ 
		id = "wall2"; 
		name = "stone wall"; 
		ascii = "#"; 
		color = LIGHTGRAY;  
		armor = 10;  
		hp = 10;  
		set = CELLSET_WALLS; 
		flags = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL}; 
		sprite = SPRITE_WALL;
  	}
 	Cells{ 
		id = "wall3"; 
		name = "stone wall"; 
		ascii = "#"; 
		color = LIGHTGRAY;  
		armor = 10;  
		hp = 10;  
		set = CELLSET_WALLS; 
		flags = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL}; 
		sprite = SPRITE_WALL;
  	}
    
	Items{
		id = "tehlever",
		name = "lever",
		color = MAGENTA,
		sprite = SPRITE_LEVER,
		weight = 0,
		color_id = "lever",
		type = ITEMTYPE_LEVER,
		flags = { IF_NODESTROY },

		good = "dangerous",
		desc = "woah!",

		OnUse = function(self,being)
			Generator.transmute( "wall2", "floor" )
			return true
		end,
	}

	Level.name = "Dead Simple"
	Level.name_number = 0
	Level.fill("wall")
	local translation = {
		['.'] = "floor",
		[','] = "blood",
		['#'] = "wall",
		['X'] = "wall2",
		['Z'] = "wall3",
		['1'] = { "blood", being = "mancubus" },
		['2'] = { "blood" },
		['3'] = { "blood" },
		['4'] = { "floor", being = "arachno" },
		['5'] = { "floor" },
		['6'] = { "floor" },
		['!'] = { "floor", item = "tehlever" },
		['+'] = { "floor", item = "lmed" },
		['a'] = { "floor", item = "chaingun" },
		['b'] = { "floor", item = "ashotgun" },
		['c'] = { "floor", item = "plasma" },
		['d'] = { "floor", item = "bazooka" },
		['e'] = { "floor", item = "bfg9000" },
		['-'] = { "floor", item = "pammo" },
		['|'] = { "floor", item = "pshell" },
		['='] = { "floor", item = "procket" },
		['_'] = { "floor", item = "pcell" },
		['['] = { "floor", item = "barmor" },
		[']'] = { "floor", item = "rarmor" },
	}
	
	simple.count = 2
	if DIFFICULTY > 2 then
		translation['2'].being = "mancubus"
		translation['5'].being = "arachno"
		simple.count = simple.count + 2
	end
	if DIFFICULTY > 3 then
		translation['3'].being = "mancubus"
		translation['6'].being = "arachno"
		simple.count = simple.count + 4
	end
	simple.status = 0

    local map = [[
#######..............................45..............................#######
#.....#.-............................6.............................+.#######
#e_...#.....###################ZZZZZZZZZZZZZZ###################.....#######
#.....#.....#+................................................=#.....#######
#######.....#|.................................................#.....#######
#######.....#c.....###########XXXXX######XXXXX###########XXXXXX#.....#######
#######.....#......#.......X,1,X............X,2,X.......#+...-a#.....#######
#######.....Z......X.......X,,3X............X3,,X.......X......Z.....#######
#######.4...Z......X.......XXXXX............XXXXX.......X!.....Z.6.4.#######
#######.5.6.Z].....X[......XXXXX............XXXXX.......X[.....Z...5.#######
#######.....Z......X.......X,,3X............X3,,X.......X......Z.....#######
#######.....#......#.......X,2,X............X,1,X.......#+...|b#.....#######
#######.....#d.....###########XXXXX######XXXXX###########XXXXXX#.....#######
#######.....#-.................................................#.....#######
#######.....#+................................................_#.....#######
#######.....###################ZZZZZZZZZZZZZZ###################.....#######
#######.+.............................6............................|.#######
#######..............................45..............................#######
    ]]
	Level.place_tile( translation, map, 2, 2 )
	Generator.set_permanence( area.FULL )
	Generator.set_permanence( area.new( 14, 5, MAXX-13, MAXY-4 ), false )
	Generator.set_permanence( area.new( 3, 3, 10, 6 ), false )

    Level.player(62,11)
end
