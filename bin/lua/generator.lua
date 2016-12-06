require( "doomrl:archi" )

generator.fluid_to_perm = {
	water  = "pwater",
	lava   = "plava",
	acid   = "pacid",
	pwater = "pwater",
	plava  = "plava",
	pacid  = "pacid",
}

generator.wall_to_ice = {
	lava   = "water",
	acid   = "water",
	plava  = "pwater",
	pacid  = "pwater",
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

	if gen.barrels then
		generator.generate_barrels()
	end

	if gen.rooms then
		if type( gen.rooms ) == "function" then
			gen.rooms() 
		elseif type( gen.rooms ) == "table" then
			generator.handle_rooms( math.random( gen.rooms[1], gen.rooms[2] ), gen.rooms[3] )
		end
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
		generator.generate_stairs()
		generator.generate_special_stairs()
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
	    if DIFFICULTY == DIFF_EASY      then return math.ceil( level.danger_level*2.2+6 )
	elseif DIFFICULTY == DIFF_MEDIUM    then return math.ceil( math.sqrt(level.danger_level*500)*0.6)
	elseif DIFFICULTY == DIFF_HARD      then return math.ceil( math.sqrt(level.danger_level)*20)
	elseif DIFFICULTY == DIFF_VERYHARD  then return math.ceil( math.sqrt(level.danger_level)*32)
	elseif DIFFICULTY == DIFF_NIGHTMARE then return math.ceil( math.sqrt(level.danger_level)*40)
	else return math.ceil( math.sqrt(level.danger_level)*40)
	end
end

function generator.item_amount()
	return math.ceil( 21 - math.max( 25-level.danger_level, 0 ) / 3 )
end

function generator.restore_walls( wall_cell, keep_fluids )
	core.log("generator.restore_walls("..wall_cell..")")
	if keep_fluids then
		for c in area.edges( area.FULL ) do
			local sub = generator.fluid_to_perm[ cells[generator.get_cell( c )].id ] or wall_cell
			generator.set_cell( c, sub )
		end
	else
		generator.fill_edges( wall_cell )
	end
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
	generator.restore_walls( generator.styles[ level.style ].wall, true )
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
	generator.restore_walls( generator.styles[ level.style ].wall, true )
end

function generator.generate_rivers( allow_horiz, allow_more )
	local cell  = "lava"
	local lvl = level.danger_level + math.random(DIFFICULTY * 2 + 6)
	    if lvl < 17 then cell = "water"
	elseif lvl < 27 then cell = "acid" end

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

-- TODO: use Cells generated cellsets!
function generator.add_rooms()
	core.log("generator.add_rooms()")
	local cell_meta_list = { "wall", "rwall", "door", "odoor", "doorb", "odoorb" }
	local cell_meta = generator.cell_set( cell_meta_list )
	local room_begin = function(c)
		if c.x == MAXX or c.y == MAXY then return false end
		if c.x == 1 then return cell_meta[ generator.get_cell( coord.new(2, c.y) ) ] end
		if c.y == 1 then return cell_meta[ generator.get_cell( coord.new(c.x, 2) ) ] end
		local meta_count = generator.cross_around( c, cell_meta_list )
		if meta_count == 4 then return true end
		if meta_count == 3
			and cell_meta[ generator.get_cell( coord.new( c.x + 1, c.y ) ) ]
			and cell_meta[ generator.get_cell( coord.new( c.x, c.y + 1 ) ) ]
			then return true end
		return false
	end

	for start in area.coords( area.FULL ) do
		if room_begin( start ) then
			local ec = coord.clone( start )
			repeat
				ec.x = ec.x + 1
			until ec.x == MAXX or cell_meta[ generator.get_cell( coord.new( ec.x, start.y + 1 ) ) ]
			repeat
				ec.y = ec.y + 1
			until ec.y == MAXY or cell_meta[ generator.get_cell( coord.new( start.x + 1, ec.y ) ) ]
			generator.add_room( area.new( start, ec ) )
		end
	end
end

function generator.generate_tiled()
	core.log("generator.generate_tiled_dungeon()")
	local wall_cell    = cells[generator.styles[ level.style ].wall].nid
	local door_cell    = cells[generator.styles[ level.style ].door].nid


	local block = generator.cell_set{ wall_cell }

	local plot = function( horiz, where )
		generator.plot_lines( where, area.FULL, horiz, wall_cell, block )
		generator.set_cell( where, door_cell )
	end

	local div_point = function( x, yrange, ymod )
		return coord.new( x, math.random(yrange)*2+ymod )
	end

	local MAX2 = math.floor(MAXX / 2)
	local MAX4 = math.floor(MAXX / 4)

	local nfirst = 5
	local ndoors = 8

	plot( false, div_point( math.random(MAX4-2)*2+2,8,2 ) )
	plot( false, div_point( math.random(MAX4-2)*2+MAX4*2-2,8,2 ) )
	for i = 1,3 do
		plot( true, div_point( math.random(MAX2-2)*2+1,8,1 ) )
	end
	for i = 1,nfirst do
		if math.random(3) == 3 then
			plot( true, div_point( math.random(MAX2-2)*2+1, 8,1 ) )
		else
			plot( false, div_point( math.random(MAX2-2)*2+2, 6,2 ) )
		end
	end

	local door_positions = {}
	for c in area.coords( area.FULL_SHRINKED ) do
		if generator.get_cell( c ) == wall_cell
		and generator.around( c, wall_cell ) == 2 then
			table.insert( door_positions, c:clone() )
		end
	end

	for i = 1,ndoors do
		local pos = table.random_pick( door_positions )
		if generator.around( pos, door_cell ) == 0 then
			generator.set_cell( pos, door_cell )
		end
	end
	generator.restore_walls( wall_cell )
	generator.add_rooms()
end

function generator.generate_lava_dungeon()
	core.log("generator.generate_lava_dungeon()")
	generator.fill("lava")
	generator.fill_edges("plava")
	local wall_cell    = generator.styles[ level.style ].wall
	local floor_cell   = generator.styles[ level.style ].floor
	local door_cell    = generator.styles[ level.style ].door
	local lava_nid     = cells[ "lava" ].nid
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
			generator.fill( "lava", quad )
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
	local style  = 5
	if dlevel > 8  then style = 6 end
	if dlevel > 16 then style = 7 end
	if dlevel > 30 then style = math.random( 5, 7 ) end
	level.style = style

	local wall_cell    = generator.styles[ level.style ].wall
	local floor_cell   = generator.styles[ level.style ].floor

	local amount, step, fluid

	    if dlevel < 7  then amount = math.random(3); step = math.random(40)+22; fluid = "water"
	elseif dlevel < 12 then amount = math.random(3); step = math.random(40)+42; fluid = "acid"
	else                    amount = math.random(5); step = math.random(50)+42; fluid = "lava"
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
		local lvl = level.danger_level + math.random(DIFFICULTY * 2 + 6)
		    if lvl < 17 then cell = "water"
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
		{ level = { 20 },     weight = 1, list = "pain", min_diff = 3 },

		{ level = { 50, 250}, weight = 2, list = { "lostsoul", "pain", "agony" }, min_diff = 3 },
		{ level = { 30, 60 }, weight = 2, list = { "ndemon", "demon" } },
		{ level = { 40, 80 }, weight = 2, list = { "narachno", "arachno" } },
		{ level = { 50, 100}, weight = 2, list = { "ncacodemon", "cacodemon" } },

		{ level = { 30 },     weight = 5, list = "ndemon",         history = "On level @1 he stumbled into a nightmare demon cave!" },
		{ level = { 40 },     weight = 5, list = "narachno",       history = "On level @1 he stumbled into a nightmare arachnotron cave!" },
		{ level = { 50 },     weight = 5, list = "ncacodemon",     history = "On level @1 he stumbled into a nightmare cacodemon cave!" },
		{ level = { 60 },     weight = 1, list = "agony",          history = "On level @1 he stumbled into a agony elemental cave!", min_diff = 3 },
		{ level = { 70 },     weight = 1, list = "lava_elemental", history = "On level @1 he stumbled into a lava elemental cave!", min_diff = 3 },
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

  	ui.msg_feel( "Twisted passages carry the smell of death..." )

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
	local style  = 5
	if dlevel > 8  then style = 6 end
	if dlevel > 16 then style = 7 end
	if dlevel > 30 then style = math.random( 5, 7 ) end
	level.style = style

	local floor_cell = cells[generator.styles[ level.style ].floor].nid
	local cave_cell  = cells[generator.styles[ level.style ].wall ].nid
	local marker     = cells["crate"].nid
	local fluid      = cells["lava"].nid
	if math.random(4) == 1 then fluid = cells["water"].nid end
	if math.random(4) == 1 then fluid = cells["acid"].nid end
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
	local lvl = level.danger_level
	    if lvl < 7  then generator.drunkard_walks( math.random(3)-1, math.random(40)+2, "water", nil, nil, drunk_area )
	elseif lvl < 12 then generator.drunkard_walks( math.random(3)-1, math.random(40)+2, "acid", nil, nil, drunk_area )
	elseif lvl < 17 then generator.drunkard_walks( math.random(5)-1, math.random(50)+2, "lava", nil, nil, drunk_area )
	else generator.drunkard_walks( math.random(5)+3, math.random(40)+2, "lava", nil, nil, drunk_area ) end
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

	for i=1,count/2 do
		generator.set_cell( generator.standard_empty_coord(), cell1 )
		generator.set_cell( generator.standard_empty_coord(), cell2 )
	end
end

function generator.generate_stairs()
	core.log("generator.generate_stairs()")
	local pos = generator.standard_empty_coord()
	generator.set_cell( pos, "stairs" )
	return pos
end

function generator.generate_special_stairs()
	core.log("generator.generate_special_stairs()")
	local pos
	if level.special_exit ~= "" then
		pos = generator.standard_empty_coord()
		generator.set_cell( pos, "rstairs" )
		ui.msg_feel( table.random_pick{
			"You feel a breeze of morbid air...",
			"You sense a passage to a place beyond...",
			"You shiver from cold...",
			})
	end
	return pos
end

function generator.place_player()
	core.log("generator.place_player()")
	local pos = generator.safe_empty_coord()
	level:drop_being( player, pos )
	return pos
end

