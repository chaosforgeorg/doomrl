require( "drl:archi" )

generator.fluid_to_perm = {
	water  = "pwater",
	mud    = "pmud",
	lava   = "plava",
	acid   = "pacid",
	blood  = "pblood",
	pwater = "pwater",
	pmud   = "pmud",
	plava  = "plava",
	pacid  = "pacid",
	pblood = "pblood",
}

generator.wall_to_ice = {
	lava   = "water",
	acid   = "water",
	mud    = "water",
	blood  = "water",
	plava  = "pwater",
	pacid  = "pwater",
	pblood = "pwater",
	pmud   = "pwater",
}

function generator.run( gen )
	generator.reset()
	core.log("generator.run > generating level type : "..gen.id)
	gen.run()

	if gen.fluids then
		if type( gen.fluids ) == "function" then
			gen.fluids() 
		elseif type( gen.fluids ) == "number" then
			if math.random(100) <= gen.fluids then
				generator.generate_fluids()
			end
		else
			generator.generate_fluids()
		end
	end

	if gen.rivers then
		if type( gen.rivers ) == "function" then
			gen.rivers() 
		elseif type( gen.rivers ) == "number" then
			if math.random(100) <= gen.rivers then
				generator.generate_rivers( true, true )
			end
		elseif type( gen.rivers ) == "table" then
			if math.random(100) <= gen.rivers[1] then
				generator.generate_rivers( gen.rivers[2], gen.rivers[3] )
			end
		else
			generator.generate_rivers( true, true )
		end
	end

	if gen.rooms then
		if type( gen.rooms ) == "function" then
			gen.rooms() 
		elseif type( gen.rooms ) == "table" then
			generator.handle_rooms( math.random( gen.rooms[1], gen.rooms[2] ), gen.rooms[3], generator.fluid_to_perm )
		end
	end

	if gen.barrels then
		generator.generate_barrels()
	end

	if type( gen.monsters ) == "function" then
		gen.monsters( generator.being_weight() ) 
	elseif gen.monsters > 0.01 then
		level:flood_monsters{ danger = math.ceil( generator.being_weight() * gen.monsters ) }
	end
	if type( gen.items ) == "function" then
		gen.items( generator.item_amount() ) 
	elseif gen.items > 0.01 then
		level:flood_items{ amount = math.ceil( generator.item_amount() * gen.items ) }
	end

	if gen.place_stairs then
		generator.generate_stairs( "stairs" )
		generator.generate_special_stairs( "rstairs", {
			"You feel a breeze of morbid air...",
			"You sense a passage to a place beyond...",
			"You shiver from cold...",
		} )
	end
	if gen.place_player then
		generator.place_player()
	end

	if gen.events then
		if math.min( math.floor( level.danger_level / 2), 20 ) > math.random(100) then
			generator.roll_event()
		end
	end

	if gen.post_run then gen.post_run() end

	core.log("generator.run > level generated successfully.")
end

function generator.being_weight()
	local danger = level.danger_level
	if danger > 16 then
		danger = danger + 2
	elseif danger > 8 then
		danger = danger + 1
	end
	local weight = 0

	    if DIFFICULTY == DIFF_EASY      then weight = math.ceil( danger*2.2+6 )
	elseif DIFFICULTY == DIFF_MEDIUM    then weight = math.ceil( math.sqrt(danger*500)*0.6)
	elseif DIFFICULTY == DIFF_HARD      then weight = math.ceil( math.sqrt(danger)*20)
	elseif DIFFICULTY == DIFF_VERYHARD  then weight = math.ceil( math.sqrt(danger)*32)
	elseif DIFFICULTY == DIFF_NIGHTMARE then weight = math.ceil( math.sqrt(danger)*40)
	else weight = math.ceil( math.sqrt(danger)*40)
	end
	core.log( "generator.being_weight() "..level.danger_level.." > "..weight )
	return weight
end

function generator.item_amount()
	return math.ceil( 21 - math.max( 25-level.danger_level, 0 ) / 3 )
end

function generator.horiz_river( cell, width, bridge )
	local floor = generator.styles[ level.style ].floor
	if bridge then bridge = 8 + math.random(60) else bridge = 100 end
	local y = 10 + math.random(2*width) - width
	local fill = cell
	for x = 1,MAXX do
		if x == bridge or x == bridge + 1 then fill = "bridge" else fill = cell end
		for w = 1,width do
			generator.set_cell( coord.new( x, w + y ), fill )
		end
		if math.random(6) == 1 then y = math.min( math.max( y + math.random(3) - 2, 3 ), MAXY - width - 2 ) end
	end
	generator.restore_walls( generator.styles[ level.style ].wall, generator.fluid_to_perm )
end

function generator.vert_river( cell, width, bridge, pos )
	-- guarantee bridges - needs to be tested
	bridge = true
	local floor = generator.styles[ level.style ].floor
	if bridge then bridge = 3 + math.random(14) else bridge = 100 end
	local x_start, y_start
	if type(pos) == "userdata" then
		x_start = math.min( math.max( pos.x + 1 - math.random(width), 3), MAXX - width - 3)
		y_start = pos.y
	else
		x_start = pos or ( 18 + math.random(40) )
		y_start = 1
	end
	local fill = cell
	local x
	local function iteration(y)
		if y == bridge or y == bridge + 1 then fill = "bridge" else fill = cell end
		for w = 1,width do
			generator.set_cell( coord.new( w + x, y ), fill )
		end
		if math.random(3) == 1 then x = math.min( math.max( x + math.random(3) - 2, 3 ), MAXX - width - 3 ) end
	end
	x = x_start
	for y = y_start, MAXY do
		iteration(y)
	end
	x = x_start
	for y = y_start, 1, -1 do
		iteration(y)
	end
	generator.restore_walls( generator.styles[ level.style ].wall, generator.fluid_to_perm )
end

function generator.generate_rivers( allow_horiz, allow_more )
	local cell  = "lava"
	local lvl = level.danger_level + math.random(DIFFICULTY * 2 + 6)
	    if lvl < 17 then cell = table.random_pick{ "water", "water", "water", "mud" }
	elseif lvl < 27 then cell = "acid"
	elseif lvl > 50 then cell = table.random_pick{ "lava", "lava", "acid", "blood" } end

	if allow_horiz and math.random(4) == 1 then
		generator.horiz_river( cell, math.random(3)+1, math.random(6) ~= 1 )
	else
		if allow_more and math.random(3) == 1 then
			if math.random(4) == 1 then
				generator.vert_river( cell, math.random(3)+1, math.random(4) ~= 1, 8  + math.random(20) )
				generator.vert_river( cell, math.random(3)+1, math.random(4) ~= 1, 32 + math.random(16) )
				generator.vert_river( cell, math.random(3)+1, math.random(4) ~= 1, 50 + math.random(20) )
			else
				generator.vert_river( cell, math.random(3)+2, math.random(3) ~= 1, 8  + math.random(22) )
				generator.vert_river( cell, math.random(3)+2, math.random(3) ~= 1, 48 + math.random(22) )
			end
		else
			generator.vert_river( cell, math.random(3)+3, math.random(4) ~= 1 )
		end
	end
end

function generator.generate_lava_dungeon()
	core.log("generator.generate_lava_dungeon()")
	local fluids = {
		{ "lava", "plava" },
		{ "lava", "plava" },
		{ "acid", "pacid" },
		{ "blood","pblood" },
	}
	local range = 2
	if level.danger_level > 30 then range = 3 end
	if level.danger_level > 40 then range = 4 end
	local fluid = fluids[ math.random( range ) ]

	generator.fill( fluid[1] )
	generator.fill_edges( fluid[2] )
	local wall_cell    = generator.styles[ level.style ].wall
	local floor_cell   = generator.styles[ level.style ].floor
	local door_cell    = generator.styles[ level.style ].door
	local lava_nid     = cells[ fluid[1] ].nid
	local wall_nid     = cells[ wall_cell ].nid

	local tries = 3
	local dim_max = coord.new( 70, 18 )
	local dim_min = coord.new( 10, 8 )
	local a = area.shrinked( area.FULL, 2 )
	local even_coord = function ( c )
		local result = c:clone()
		if result.x % 2 == 1 then result.x = result.x+1 end
		if result.y % 2 == 1 then result.y = result.y+1 end
		return result
	end

	for i=1,tries do
		local quad = area.random_subarea( a, coord.random( dim_min, dim_max ) ):clamped( a )
		quad.a = even_coord( quad.a )
		quad.b = even_coord( quad.b )

		if math.random(2) == 1 then
			quad:shrink(1)
			generator.fill( fluid[1], quad )
			quad:expand(1)
		end

		for c in quad:edges() do
			if generator.get_cell(c) == lava_nid then
				generator.set_cell(c, "bridge")			
			end
		end

		for c in quad:corners() do
			generator.fill( floor_cell, area.around(c,1) )
		end
	end

	local tries = 8
	local dim_max = coord.new( 20, 16 )
	local dim_min = coord.new( 12, 10 )
	local a = area.shrinked( area.FULL, 2 )
	for i=1,tries do
		local quad = area.random_subarea( a, coord.random( dim_min, dim_max ) ):clamped( a )
		local good = true
		for c in quad() do 
			if generator.get_cell(c) == wall_nid then 
				good = false
				break
			end
		end
		if good then
			generator.fill( floor_cell, quad )
			quad:shrink(1)
			generator.fill( wall_cell, quad )
			generator.set_cell( area.random_inner_edge_coord( quad ), door_cell )
			quad:shrink(1)
			generator.fill( "crate", quad )
			generator.add_room( quad:expanded() )
		end
	end
	generator.transmute( "crate", floor_cell )
end

function generator.generate_caves_dungeon()
	core.log("generator.generate_caves_dungeon()")
	local dlevel = level.danger_level
	local style  = 10
	if dlevel > 8  then style = 11 end
	if dlevel > 16 then style = 12 end
	if dlevel > 30 then style = math.random( 10, 12 ) end
	
	level:set_generator_style( style )

	local wall_cell    = generator.styles[ level.style ].wall
	local floor_cell   = generator.styles[ level.style ].floor

	local amount, step, fluid

	    if dlevel < 7  then amount = math.random(3); step = math.random(40)+22; fluid = table.random_pick{ "water", "water", "water", "mud" }
	elseif dlevel < 12 then amount = math.random(3); step = math.random(40)+42; fluid = "acid"
	else                    amount = math.random(5); step = math.random(50)+42; fluid = "lava"
	end

	if dlevel >= 30 then
		fluid = table.random_pick{ "lava", "lava", "acid", "blood" }
	elseif dlevel > 20 and fluid == "lava" and DIFFICULTY >= DIFF_HARD then
		fluid = math.random{ "lava", "lava", "blood" }
	end

	local drunk = function( amount, step, cell )
		generator.contd_drunkard_walks( amount, step, cell, { floor_cell, fluid }, {wall_cell}, nil, true )
	end

	generator.fill( wall_cell )

	generator.run_drunkard_walk( area.FULL_SHRINKED, coord.new( 38, 10 ), math.random(40)+100, floor_cell, nil, true )
	drunk( 5,  math.random(40)+35, floor_cell )
	drunk( amount, step,   fluid )
	drunk( 40, math.random(40)+25, floor_cell )
	drunk( amount, step+20, fluid )

	if math.random(3) == 1 then
		local cell  = "lava"
		if fluid == "blood" then cell = "blood" end
		local lvl = level.danger_level + math.random(DIFFICULTY * 2 + 6)
		    if lvl < 17 then cell = table.random_pick{ "water", "water", "water", "mud" }
		elseif lvl < 27 then cell = "acid" end

		if math.random(3) == 1 then
			generator.horiz_river( cell, math.random(3)+1, math.random(6) ~= 1 )
		else
			local pos = generator.standard_empty_coord()
			if pos then
				generator.vert_river( cell, math.random(3)+3, math.random(4) ~= 1, pos)
			end
		end
	end

	local sets = {
		{ level = { 0,  16 }, weight = 3, list = "lostsoul"},
		{ level = { 7,  20 }, weight = 2, list = {"demon","lostsoul"} },
		{ level = { 5,  22 }, weight = 3, list = "demon"},
		{ level = { 10, 20 }, weight = 2, list = {"demon","cacodemon"} },
		{ level = { 14, 28 }, weight = 1, list = {"lostsoul","demon","cacodemon"} },
		{ level = { 10, 25 }, weight = 3, list = "cacodemon"},
		{ level = { 15, 40 }, weight = 1, list = {"cacodemon","arachno"} },
		{ level = { 16, 50 }, weight = 3, list = "arachno"},
		{ level = { 30, 40 }, weight = 1, list = {"arachno","pain"}, min_diff = 3 },
		{ level = { 20, 99 }, weight = 1, list = { "lostsoul", "pain" } },
		{ level = { 20, 50 }, weight = 1, list = "pain", min_diff = 3 },
		{ level = { 51, 99 }, weight = 1, list = "pain", },
		{ level = { 100 },    weight = 1, list = "npain", },

		{ level = { 50, 250}, weight = 2, list = { "lostsoul", "pain", "agony" }, min_diff = 3 },
		{ level = { 30, 60 }, weight = 2, list = { "ndemon", "demon" } },
		{ level = { 40, 80 }, weight = 2, list = { "narachno", "arachno" } },
		{ level = { 50, 100}, weight = 2, list = { "ncacodemon", "cacodemon" } },

		{ level = { 30 },     weight = 5, list = "ndemon",         history = "On level @1 he stumbled into a nightmare demon cave!" },
		{ level = { 40 },     weight = 5, list = "narachno",       history = "On level @1 he stumbled into a nightmare arachnotron cave!" },
		{ level = { 50 },     weight = 1, list = "npain",          history = "On level @1 he stumbled into a nightmare elemental cave!" },
		{ level = { 60 },     weight = 5, list = "ncacodemon",     history = "On level @1 he stumbled into a nightmare cacodemon cave!" },
		{ level = { 70 },     weight = 1, list = "agony",          history = "On level @1 he stumbled into a agony elemental cave!", min_diff = 3, feeling = "You hear echoing wails of agony!" },
		{ level = { 80 },     weight = 1, list = "lava_elemental", history = "On level @1 he stumbled into a lava elemental cave!", min_diff = 3, feeling = "The cave temperature is insanely hot!" },
	}

	local mlevel = math.max( level.danger_level + (DIFFICULTY - 2)*3, 0 )
	local list   = weight_table.new()
	for _,s in ipairs( sets ) do
		local lmin, lmax = s.level[1] or 0, s.level[2] or 100000
		local dmin       = core.iif( mlevel > 2 * lmin, 0, s.min_diff or 0 )
		if mlevel >= lmin and mlevel <= lmax and DIFFICULTY >= dmin then
			list:add(s,s.weight)
		end
	end
	local set = list:roll()
	local amount  = math.floor( generator.being_weight() * 0.67 )
	if set.history then player:add_history(set.history) end
	level:flood_items{ amount = 10 }

	if type( set.list ) == "string" then
		level:flood_monster{ id = set.list, danger = amount }
	else
		level:flood_monsters{ list = set.list, danger = amount }
	end

  	ui.msg_feel( set.feeling or "Twisted passages carry the smell of death..." )

	generator.set_permanence( area.FULL )
end

function generator.place_blob( start, size, cell )
	local floor_cell = cells[generator.styles[ level.style ].floor ].nid
	local cells = { cell, floor_cell }
	local visit = {}
	table.insert( visit, start )
	for j = 1,size do
		if #visit == 0 then break end
		local idx = math.random( #visit )
		local n   = visit[ idx ]
		table.remove( visit, idx )
		if generator.around( n, cells ) == 8 then
			level:raw_set_cell( n, cell ) 
			for c in n:cross_coords() do 
				if level:raw_get_cell( c ) == floor_cell then
					table.insert( visit, c:clone() )
				end
			end
		end
	end
end

function generator.generate_caves_2_dungeon()
	local dlevel = level.danger_level
	local wall_cell  = cells[generator.styles[ level.style ].wall].nid
	local door_cell  = cells[generator.styles[ level.style ].door].nid
	local style  = 10
	if dlevel > 8  then style = 11 end
	if dlevel > 16 then style = 12 end
	if dlevel > 30 then style = math.random( 10, 12 ) end
	level:set_generator_style( style )

	local floor_cell = cells[generator.styles[ level.style ].floor].nid
	local cave_cell  = cells[generator.styles[ level.style ].wall ].nid
	local marker     = cells["crate"].nid
	local fluid      = cells["lava"].nid
	if math.random(4) == 1 then fluid = cells["water"].nid end
	if math.random(4) == 1 then fluid = cells["acid"].nid end
	if dlevel > 30 and math.random(3) == 1 then fluid = cells["blood"].nid end
	local level_area = area.FULL
	local w,h = level_area.b.x, level_area.b.y

	local drunk = function( amount, step, cell )
		generator.contd_drunkard_walks( amount, step, cell, { floor_cell, fluid }, {cave_cell}, nil, true )
	end

	generator.fill( cave_cell )
	local sub_area = level_area:shrinked( 7 )
	generator.fill( floor_cell, sub_area )
	sub_area:shrink( 4 )
	generator.fill( cave_cell, sub_area )

	drunk( 10, math.random(10)+40, floor_cell )
	drunk( 50, math.random(10)+20, floor_cell )

	for c in level_area:shrinked()() do
		if level:raw_get_cell(c) == cave_cell and generator.around( c, cave_cell ) < 4 then
			level:raw_set_cell( c, floor_cell )
		end
	end

	for c in level_area:shrinked(2)() do
		if level:raw_get_cell(c) == floor_cell and generator.cross_around( c, cave_cell ) > 2 then
			for k in c:cross_coords() do
				level:raw_set_cell( k, marker )
			end
		end
	end

	generator.transmute( marker, floor_cell )

	-- rest of the level will be destructible
	generator.set_permanence( area.FULL, true, cave_cell )


	local bcount = math.random(3) + 2
	for i = 1,bcount do
		local start = generator.random_square( floor_cell )
		local count = math.random( 5 ) + 5
		generator.place_blob( start, count, marker )
	end

	generator.transmute( marker, cave_cell )

	local cmax  = math.random( 5, 7 )
	local count = 0
	for i = 1,1000 do
		local dim = coord.new( math.random( 7,9 ), math.random( 6,9 ) )
		local a = area.FULL_SHRINKED:random_subarea( dim )
		if generator.scan( a, floor_cell ) then
			a:shrink()
			generator.fill( wall_cell, a )
			generator.set_cell( a:random_inner_edge_coord(), door_cell )
			a:shrink()
			generator.fill( marker, a )
			count = count + 1
			if count == cmax then break end
		end
	end

	local bcount = math.random(5) + 10
	for i = 1,bcount do
		local start = generator.random_square( floor_cell )
		local count = math.random( 40 ) + 20
		generator.place_blob( start, count, fluid )
	end

	generator.transmute( marker, floor_cell )

	for c in level_area:shrinked()() do
		if level:raw_get_cell(c) == fluid and generator.around( c, fluid ) < 4 then
			level:raw_set_cell( c, floor_cell )
		end
	end
end

function generator.generate_fluids( drunk_area )
	core.log("generator.generate_fluids()")
	local lvl  = level.danger_level
	local lava = "lava"
	if lvl > 30 then 
		lvl  = math.random(20) + 5
		lava = table.random_pick{ "lava", "lava", "blood" }
	end
	    if lvl < 7   then generator.drunkard_walks( math.random(3)-1, math.random(40)+2, table.random_pick{ "water", "water", "mud" }, nil, nil, drunk_area )
	elseif lvl < 12  then generator.drunkard_walks( math.random(3)-1, math.random(40)+2, "acid", nil, nil, drunk_area )
	elseif lvl < 17  then generator.drunkard_walks( math.random(5)-1, math.random(50)+2, lava, nil, nil, drunk_area )
	else generator.drunkard_walks( math.random(5)+3, math.random(40)+2, lava, nil, nil, drunk_area ) end
end

function generator.generate_barrels()
	core.log("generator.generate_barrels()")
	local lvl = level.danger_level + math.random(5)
	local count = 12
	if math.random(22) == 22 then
		count = 50
		ui.msg_feel( "Khe, he, he, this will be a mess..." )
	end
	local cell1 = "barrel"
	local cell2 = "barrel"

	if lvl > 18 then
		cell1, cell2 = "barreln", "barreln"
		if math.random(4) == 1 then cell1 = "barrela" end
	elseif lvl > 13 then
		cell2 = "barreln"
	elseif lvl > 6 then
		cell2 = "barrela"
	end

	local function barrel_coord()
		return generator.random_empty_coord( { EF_NOBEINGS, EF_NOITEMS, EF_NOSTAIRS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN, EF_NOLIQUID } )
	end
	

	for i=1,count/2 do
		level:drop_item( cell1, barrel_coord(), true )
		level:drop_item( cell2, barrel_coord(), true )
	end
end
