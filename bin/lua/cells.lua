function DoomRL.loadcells()

	register_cell "floor"
	{
		name       = "floor",
		ascii      = "ù",
		asciilow   = '.',
		set        = CELLSET_FLOORS,
		blname     = "blood",
		blcolor    = RED;
		bloodto    = "bloodpool";
		sprite     = SPRITE_FLOOR,
		blsprite   = SPRITE_BLOOD;
	}

	register_cell "floorc"
	{
		name       = "floor",
		ascii      = "ù",
		asciilow   = '.',
		set        = CELLSET_FLOORS,
		blname     = "blood",
		blcolor    = RED;
		bloodto    = "bloodpool";
		sprite     = SPRITE_CAVEFLOOR,
		blsprite   = SPRITE_BLOOD;
	}

	register_cell "floorb"
	{
		name       = "floor",
		ascii      = "ù",
		asciilow   = '.',
		set        = CELLSET_FLOORS,
		blname     = "blood",
		blcolor    = RED;
		bloodto    = "bloodpool";
		sprite     = SPRITE_HELLFLOOR,
		blsprite   = SPRITE_BLOOD;
	}

-- Phobos Walls --

	register_cell "wall"
	{
		name       = "stone wall",
		blname     = "blooded wall",
		ascii      = "#",
		color      = LIGHTGRAY,
		blcolor    = RED,
		armor      = 10,
		hp         = 10,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
		sprite     = SPRITE_WALL,
		blsprite   = SPRITE_WALLBLOOD,
	}

-- Phobos Walls End --

-- Deimos Walls --

	register_cell "dwall"
	{
		name       = "base wall",
		blname     = "blooded wall",
		ascii      = "#",
		color      = DARKGRAY,
		blcolor    = RED,
		armor      = 10,
		hp         = 10,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
		sprite     = SPRITE_TECHWALL,
		blsprite   = SPRITE_WALLBLOOD,
	}


-- Deimos Walls End --

-- Hell Walls --

	register_cell "rwall"
	{
		name       = "bloodstone",
		blname     = "blooded bloodstone",
		ascii      = "#",
		color      = RED,
		blcolor    = LIGHTRED,
		armor      = 10,
		hp         = 15,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
		coscolor   = { 1.0,0.2,0.2,1.0 },
		sprite     = SPRITE_BRICKWALL,
		blsprite   = SPRITE_WALLBLOOD,
	}

-- Hell Walls End --

-- Ice Walls --
	register_cell "iwall"
	{
		name       = "ice wall",
		blname     = "blooded ice wall",
		ascii      = "#",
		color      = LIGHTBLUE,
		blcolor    = RED,
		armor      = 3,
		hp         = 3,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL, CF_FRAGILE },
		coscolor   = { 0.6,0.6,1.0,1.0 },
		sprite     = SPRITE_CAVEWALL,
		blsprite   = SPRITE_WALLBLOOD,
	}

-- Ice Walls End --

-- Cave Walls --

	register_cell "cwall1"
	{
		name       = "cave wall",
		blname     = "blooded cave wall",
		ascii      = "#",
		color      = DARKGRAY,
		blcolor    = RED,
		armor      = 15,
		hp         = 30,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
		coscolor   = { 0.3,0.3,0.3,1.0 },
		sprite     = SPRITE_CAVEWALL,
		blsprite   = SPRITE_WALLBLOOD,
	}

	register_cell "cwall2"
	{
		name       = "cave wall",
		blname     = "blooded cave wall",
		ascii      = "#",
		color      = BROWN,
		blcolor    = RED,
		armor      = 15,
		hp         = 30,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
		coscolor   = { 1.0,0.6,0.2,1.0 },
		sprite     = SPRITE_CAVEWALL,
		blsprite   = SPRITE_WALLBLOOD,
	}

	register_cell "cwall3"
	{
		name       = "cave wall",
		blname     = "blooded cave wall",
		ascii      = "#",
		color      = RED,
		blcolor    = LIGHTRED,
		armor      = 15,
		hp         = 30,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
		coscolor   = { 1.0,0.2,0.2,1.0 },
		sprite     = SPRITE_CAVEWALL,
		blsprite   = SPRITE_WALLBLOOD,
	}

-- Cave Walls End --

-- Green Walls --
	register_cell "gwall"
	{
		name       = "green wall",
		blname     = "blooded green wall",
		ascii      = "#",
		color      = GREEN,
		blcolor    = RED,
		armor      = 15,
		hp         = 10,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_MULTISPRITE, CF_STICKWALL},
		sprite     = SPRITE_BOSSWALL,
		blsprite   = SPRITE_WALLBLOOD,
	}

-- Green Walls End --

-- Crates --

	register_cell "crate"
	{
		name       = "crate",
		blname     = "blooded crate",
		ascii      = "#",
		color      = BLUE,
		blcolor    = RED,
		armor      = 5,
		hp         = 5,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_STICKWALL},
		sprite     = SPRITE_YBOX,
		blsprite   = SPRITE_WALLBLOOD,
	}

	register_cell "ycrate"
	{
		name       = "crate",
		blname     = "blooded crate",
		ascii      = "#",
		color      = BROWN,
		blcolor    = RED,
		armor      = 5,
		hp         = 5,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_STICKWALL},
		sprite     = SPRITE_WBOX,
		blsprite   = SPRITE_WALLBLOOD,
	}


-- End Crates --

-- Doors --

	register_cell "door"
	{
		name       = "closed door",
		ascii      = "+",
		color      = BROWN,
		armor      = 4,
		hp         = 6,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_FRAGILE, CF_OVERLAY, CF_STICKWALL, CF_OPENABLE, CF_RUNSTOP, CF_HIGHLIGHT},
		sprite     = SPRITE_DOOR,

		OnAct = function(c,being)
			being:msg("You open the door.")
			being:play_sound("door.open")
			level.map[ c ] = "odoor"
			being.scount = being.scount - 500
			return true
		end,
	}

	register_cell "odoor"
	{
		name       = "open door",
		ascii      = "/",
		color      = BROWN,
		flags      = {CF_NOCHANGE, CF_NORUN, CF_OVERLAY, CF_STICKWALL, CF_CLOSABLE, CF_RUNSTOP, CF_NUKABLE, CF_HIGHLIGHT },
		sprite     = SPRITE_OPENDOOR,

		OnAct = function(c,being)
			if level:get_being(c) == nil and level:get_item(c) == nil then
				being:msg("You close the door.")
				being:play_sound("door.close")
				level.map[ c ] = "door"
				being.scount = being.scount - 500
				return true
			else
				being:msg("There's something blocking the door.")
				return false
			end
		end,
	}

	register_cell "ldoor"
	{
		name       = "locked door",
		ascii      = "+",
		color      = BROWN,
		armor      = 6,
		hp         = 6,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_FRAGILE, CF_OVERLAY, CF_STICKWALL, CF_RUNSTOP},
		sprite     = SPRITE_DOOR,

		OnAct = function(c,being)
			being:msg("The door is locked.")
			return false
		end,
	}

	register_cell "doorb"
	{
		name       = "closed door",
		ascii      = "+",
		color      = BROWN,
		armor      = 4,
		hp         = 6,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_FRAGILE, CF_OVERLAY, CF_STICKWALL, CF_OPENABLE, CF_RUNSTOP, CF_HIGHLIGHT},
		sprite     = SPRITE_HELLDOOR,

		OnAct = function(c,being)
			being:msg("You open the door.")
			being:play_sound("door.open")
			level.map[ c ] = "odoorb"
			being.scount = being.scount - 500
			return true
		end,
	}

	register_cell "odoorb"
	{
		name       = "open door",
		ascii      = "/",
		color      = BROWN,
		flags      = {CF_NOCHANGE, CF_NORUN, CF_OVERLAY, CF_STICKWALL, CF_CLOSABLE, CF_RUNSTOP, CF_NUKABLE, CF_HIGHLIGHT },
		sprite     = SPRITE_HELLOPENDOOR,

		OnAct = function(c,being)
			if level:get_being(c) == nil and level:get_item(c) == nil then
				being:msg("You close the door.")
				being:play_sound("door.close")
				level.map[ c ] = "doorb"
				being.scount = being.scount - 500
				return true
			else
				being:msg("There's something blocking the door.")
				return false
			end
		end,
	}

-- End Doors --

-- Stairs --

	register_cell "stairs"
	{
		name       = "down stairs",
		ascii      = ">",
		color      = LIGHTGRAY,
		color_dark = LIGHTGRAY,
		flags      = {CF_NOCHANGE, CF_NORUN, CF_OVERLAY, CF_CRITICAL, CF_HIGHLIGHT, CF_STAIRS},
		sprite     = SPRITE_GRAYSTAIRS,

		OnEnter = function(c,being)
			being:msg("There are stairs leading downward here.")
		end,

		OnExit = function(c)
			player:exit()
		end,
	}

	register_cell "rstairs"
	{
		name       = "down stairs",
		ascii      = ">",
		color      = LIGHTRED,
		color_dark = RED,
		flags      = {CF_NOCHANGE, CF_NORUN, CF_OVERLAY, CF_CRITICAL, CF_HIGHLIGHT, CF_STAIRS},
		sprite     = SPRITE_REDSTAIRS,

		OnEnter = function(c,being)
			being:msg("There are stairs leading to "..levels[level.special_exit].name.." here.")
		end,

		OnExit = function(c)
			player:exit( level.special_exit )
		end,

		OnDescribe = function(c)
			return "stairs leading to "..levels[level.special_exit].name
		end,
	}

	register_cell "ystairs"
	{
		name       = "down stairs",
		ascii      = ">",
		color      = YELLOW,
		color_dark = YELLOW,
		coscolor   = { 1.0,1.0,0.0,1.0 },
		flags      = {CF_NOCHANGE, CF_NORUN, CF_OVERLAY, CF_CRITICAL, CF_HIGHLIGHT, CF_STAIRS},
		sprite     = SPRITE_STAIRS,
	}

-- End Stairs --

-- Barrels --

	register_cell "barrel"
	{
		name       = "barrel of fuel",
		ascii      = "0",
		color      = BROWN,
		armor      = 3,
		hp         = 2,
		flags      = { CF_BLOCKMOVE, CF_PUSHABLE, CF_FRAGILE, CF_OVERLAY, CF_HIGHLIGHT},
		sprite     = SPRITE_BARREL,

		OnAct = function(c,being)
			local source = being.position
			if level:push_cell(c, c + (c - source)) then
				being.scount = being.scount - 1000
			end
		end,

		OnDestroy = function(c)
			if level:is_visible(c) then ui.msg('The barrel explodes!') end
			level.map[ c ] = generator.styles[ level.style ].floor
			level:explosion(c,4,40,5,5,RED, "barrel.explode" )
		end
	}

	register_cell "barrela"
	{
		name       = "barrel of acid",
		ascii      = "0",
		color      = GREEN,
		armor      = 4,
		hp         = 2,
		flags      = { CF_BLOCKMOVE, CF_PUSHABLE, CF_FRAGILE, CF_OVERLAY, CF_HIGHLIGHT},
		sprite     = SPRITE_ACIDBARREL,

		OnAct = function(c,being)
			local source = being.position
			if level:push_cell(c, c + (c - source)) then
				being.scount = being.scount - 1000
			end
		end,

		OnDestroy = function(c)
			if level:is_visible(c) then ui.msg('The barrel explodes!') end
			level.map[ c ] = "acid"
			level:explosion(c,3,40,6,6,GREEN, "barrel.explode", DAMAGE_ACID, nil, {}, "acid")
		end
	}

	register_cell "barreln"
	{
		name       = "barrel of napalm",
		ascii      = "0",
		color      = LIGHTRED,
		armor      = 5,
		hp         = 2,
		flags      = { CF_BLOCKMOVE, CF_PUSHABLE, CF_FRAGILE, CF_OVERLAY, CF_HIGHLIGHT},
		sprite     = SPRITE_LAVABARREL,

		OnAct = function(c,being)
			local source = being.position
			if level:push_cell(c, c + (c - source)) then
				being.scount = being.scount - 1000
			end
		end,

		OnDestroy = function(c)
			if level:is_visible(c) then ui.msg('The barrel explodes!') end
			level.map[ c ] = "lava"
			level:explosion(c,2,40,7,7,RED, "barrel.explode", DAMAGE_FIRE, nil, {}, "lava")
		end
	}

-- End Barrels --

-- Fluids --

	register_cell "water"
	{
		name       = "water",
		ascii      = "=",
		color      = COLOR_WATER,
		flags      = {F_GTSHIFT, F_GFLUID, CF_LIQUID, CF_NOCHANGE},
		sprite     = SPRITE_WATER,
	}

	register_cell "acid"
	{
		name       = "acid",
		ascii      = "=",
		color      = COLOR_ACID,
		flags      = {F_GTSHIFT, F_GFLUID, CF_LIQUID, CF_NOCHANGE, CF_NORUN, CF_HAZARD, CF_HIGHLIGHT},
		sprite     = SPRITE_ACID,

		OnEnter = function(c,being)
			local damage   = 6
			if DIFFICULTY == DIFF_EASY then damage = damage / 2 end
			if being.flags[ BF_ENVIROSAFE ] then return end
			if being:get_total_resistance( DAMAGE_ACID, TARGET_FEET ) == 100 then return end
			if being:is_player() then
				if being.running then damage = damage / 2 end
				if being:is_affect("enviro") then return end
				ui.msg("Argh!!! Acid!")
				if core.game_time() % 3 == 0 then
					being:play_sound(being.soundhit)
				end
			end
			being:apply_damage(damage,TARGET_FEET,DAMAGE_ACID)
		end
	}

	register_cell "lava"
	{
		name       = "lava",
		ascii      = "=",
		color      = COLOR_LAVA,
		flags      = {F_GTSHIFT, F_GFLUID, CF_LIQUID, CF_NOCHANGE, CF_NORUN, CF_HAZARD, CF_HIGHLIGHT},
		sprite     = SPRITE_LAVA,

		OnEnter = function(c,being)
			local damage = 12
			if DIFFICULTY == DIFF_EASY then damage = damage / 2 end
			if being.flags[ BF_ENVIROSAFE ] then return end
			if being:get_total_resistance( DAMAGE_FIRE, TARGET_FEET ) == 100 then return end
			if being:is_player() then
				if being.running then damage = damage / 2 end
				if being:is_affect("enviro") then return end
				ui.msg("Argh!!! Lava!")
				if core.game_time() % 3 == 0 then
					being:play_sound(being.soundhit)
				end
			end
			being:apply_damage(damage,TARGET_FEET,DAMAGE_FIRE)
		end
	}

	register_cell "pwater"
	{
  		name       = "water",
		ascii      = "=",
		color      = COLOR_WATER,
		color_id   = "water",
		set        = CELLSET_WALLS,
		flags      = {F_GTSHIFT, F_GFLUID, CF_BLOCKLOS, CF_BLOCKMOVE},
		sprite     = SPRITE_WATER,
	}

	register_cell "pacid"
	{
		name       = "acid",
		ascii      = "=",
		color      = COLOR_ACID,
		color_id   = "acid",
		set        = CELLSET_WALLS,
		flags      = {F_GTSHIFT, F_GFLUID, CF_BLOCKLOS, CF_BLOCKMOVE, CF_HIGHLIGHT},
		sprite     = SPRITE_ACID,
	}

	register_cell "plava"
	{
		name       = "lava",
		ascii      = "=",
		color      = COLOR_LAVA,
		color_id   = "lava",
		set        = CELLSET_WALLS,
		flags      = {F_GTSHIFT, F_GFLUID, CF_BLOCKLOS, CF_BLOCKMOVE, CF_HIGHLIGHT},
		sprite     = SPRITE_LAVA,
	}

-- End Fluids --

-- Misc --

	register_cell "bridge"
	{
		name       = "bridge",
		ascii      = "=",
		color      = BROWN,
		set        = CELLSET_FLOORS,
		sprite     = SPRITE_BRIDGE,
		blname     = "blood",
		blcolor    = RED;
		blsprite   = SPRITE_BLOOD;
		flags      = {F_GFLUID},
	}

	register_cell "rock"
	{
		name       = "Phobos rock",
		ascii      = ".",
		color      = RED,
		set        = CELLSET_FLOORS,
		sprite     = SPRITE_CAVEFLOOR,
		flags      = { F_GFLUID },
	}

	register_cell "nukecell"
	{
		id         = "nukecell",
		name       = "a nuke!",
		ascii      = "0",
		color      = RED,
		color_dark = RED,
		flags      = { CF_NOCHANGE, CF_NORUN, CF_OVERLAY, CF_NUKABLE, CF_CRITICAL, CF_HIGHLIGHT},
		sprite     = SPRITE_NUKE,
	}

	register_cell "tree"
	{
		name       = "Phobos tree",
		ascii      = "T",
		color      = BROWN,
		armor      = 5,
		hp         = 5,
		set        = CELLSET_WALLS,
		flags      = { F_GFLUID, CF_BLOCKMOVE, CF_OVERLAY },
		destroyto  = "rock",
		sprite     = SPRITE_TREE,
	}

-- End Misc --

	register_cell "crate_ammo"
	{
		name       = "crate",
		blname     = "blooded crate",
		ascii      = "#",
		color      = LIGHTRED,
		blcolor    = RED,
		armor      = 5,
		hp         = 5,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_STICKWALL, CF_FRAGILE},
		sprite     = SPRITE_WBOXC,
		blsprite   = SPRITE_WALLBLOOD,
		coscolor   = {1.0,0.0,0.0,1.0},

		OnDestroy = function(c)
			if math.random(4) == 1 then
				local item_spawn = {"ammo","shell"}
				if math.random(5) == 1 then
					item_spawn = {"pammo","pshell"}
				end
				level:drop_item( table.random_pick( item_spawn ), c, true )
			end
		end,
	}

	register_cell "crate_armor"
	{
		name       = "crate",
		blname     = "blooded crate",
		ascii      = "#",
		color      = YELLOW,
		blcolor    = RED,
		armor      = 5,
		hp         = 5,
		set        = CELLSET_WALLS,
		flags      = {CF_BLOCKLOS, CF_BLOCKMOVE, CF_STICKWALL, CF_FRAGILE},
		sprite     = SPRITE_YBOXC,
		blsprite   = SPRITE_WALLBLOOD,
		coscolor   = {1.0,1.0,0.0,1.0},

		OnDestroy = function(c)
			if math.random(4) == 1 then
				local item_spawn = {"garmor","sboots","smed"}
				if math.random(5) == 1 then
					item_spawn = {"barmor","pboots","lmed"}
				end
				level:drop_item( table.random_pick( item_spawn ), c )
			end
		end,
	}

end
