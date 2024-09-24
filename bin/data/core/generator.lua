generator.styles = {}
generator.cell_sets = {}
generator.cell_lists = {}
generator.room_list = {}
generator.room_meta = {}

function generator.cell_set( list )
	local s = {}
	for _,v in ipairs( list ) do
		s[cells[v].nid] = true
	end
	return s
end

function generator.merge_cell_sets( list1, list2 )
	local s = {}
	for k,v in pairs( list1 ) do
		s[k] = v
	end
	for k,v in pairs( list2 ) do
		s[k] = v
	end
	return s
end

function generator.merge_cell_lists( list1, list2 )
	local s = {}
	for _,v in ipairs( list1 ) do
		table.insert( s, v )
	end
	for _,v in ipairs( list2 ) do
		table.insert( s, v )
	end
	return s
end

function generator.scan(scan_area,good)
	if type(good) == "string" then good = cells[good].nid end
	for c in scan_area() do
		if generator.get_cell(c) ~= good then
			return false
		end
	end
	return true
end

function generator.scatter(scatter_area,good,fill,count)
	if type(good) == "string" then good = cells[good].nid end
	if type(fill) == "string" then fill = cells[fill].nid end
	for c = 1, count do
		local c = scatter_area:random_coord()
		if generator.get_cell(c) == good then generator.set_cell(c, fill) end
	end
end

function generator.transmute_marker( marker, fill, ar )
	local a = ar or area.FULL
	for c in a() do 
		if level.light[ c ][ marker ] then
			level.map[ c ] = fill
		end
	end
end

function generator.transmute_style( from, to, fstyle, tstyle, ar )
	local a = ar or area.FULL
	for c in a() do 
		if level.map[ c ] == from and level:get_raw_style( c ) == fstyle then
			level.map[ c ] = to
			if tstyle then
				level:set_raw_style( c, tstyle )
			end
		end
	end
end


function generator.scatter_blood(scatter_area,good,count)
	if type(good) == "string" then good = cells[good].nid end
	for c = 1, count do
		local c = scatter_area:random_coord()
		if not good or generator.get_cell(c) == good then level.light[ c ][ LFBLOOD ] = true end
	end
end

function generator.roll_pair( list )
	if #list < 2 then return list[1] end
	local roll1 = math.random( #list )
	local roll2
	repeat 
		roll2 = math.random( #list )
	until roll2 ~= roll1
	return list[roll1], list[roll2]
end

function generator.place_dungen_tile( code, tile_object, tile_pos )
	local tile_area   = tile_object:get_area()
	generator.tile_place( tile_pos, tile_object )

	for c in tile_area() do
		local char       = string.char( tile_object:get_ascii(c) )
		local tile_entry = code[ char ]
		assert( tile_entry, "Character in map not defined -> "..char)
		local p = tile_pos + c - coord.UNIT
		if tile_entry.being then level:drop_being_ext( tile_entry.being, p ) end
		if tile_entry.item  then level:drop_item_ext( tile_entry.item, p ) end
		if tile_entry.flags then
			for _, flag in ipairs(tile_entry.flags) do
				level.light[p][flag] = true
			end
		end
		if tile_entry.style then
			level:set_raw_style( p, generator.styles[ tile_entry.style ].style )
		end
		if tile_entry.deco then
			level:set_raw_deco( p, tile_entry.deco )
		end
	end
end

function generator.create_translation( code )
	local translation = {}
	for k,v in pairs(code) do
		translation[k] = v
		if type(v) == "table"  then translation[k] = translation[k][1] end
		if type(v) == "string" then translation[k] = cells[v].nid end
	end
	return translation
end

function generator.place_tile( code, tile, x, y )
	local translation = generator.create_translation( code )
	local tile_pos  = coord.new( x, y )
	local tile_object = generator.tile_new( tile, translation, true )
	generator.place_dungen_tile( code, tile_object, tile_pos )
end

function generator.place_symmetry_quad( tile, trans )
	local translation = generator.create_translation( trans )
	local tile_object = generator.tile_new( tile, translation, true )
	local tile_size   = tile_object:get_size_coord()
	generator.place_dungen_tile( trans, tile_object, coord.new( 2, 2 ) )
	tile_object:flip_x()
	generator.place_dungen_tile( trans, tile_object, coord.new( 78 - tile_size.x , 2 ) )
	tile_object:flip_y()
	generator.place_dungen_tile( trans, tile_object, coord.new( 78 - tile_size.x , 20 - tile_size.y ) )
	tile_object:flip_x()
	generator.place_dungen_tile( trans, tile_object, coord.new( 2 , 20 - tile_size.y ) )
end

function generator.place_proto_map( where, proto_map, proto_key, code )
	local trans = generator.create_translation( code )
	local proto = generator.tile_new( proto_map, {}, true )
	local pdim  = proto:get_size_coord()
	local tpos  = where:clone()
	for py = 1, pdim.y do
		tpos.x = where.x
		local mdim
		for px = 1, pdim.x do
			local map  = proto_key[ string.char( proto:get_ascii( coord.new(px,py) ) ) ]
			assert( map, "Key has no map!" )
			if type(map) == "table" then
				map = table.random_pick(map)
			end
			local mobj = generator.tile_new( map, trans, true )
			mdim = mobj:get_size_coord()
			generator.place_dungen_tile( code, mobj, where + tpos )
			tpos.x = tpos.x + mdim.x
		end
		tpos.y = tpos.y + mdim.y
	end
end


function generator.scatter_put(scatter_area,code,tile,good,count)
	if type(good) == "string" then good = cells[good].nid end

	local translation = generator.create_translation( code )
	local tile_object = generator.tile_new( tile, translation, true )
	local tile_size   = tile_object:get_size_coord()
	local tries       = 10000

	repeat
		local c = scatter_area:random_coord()

		if generator.scan( area.new( c, c + tile_size - coord.UNIT ),good ) then
			generator.place_dungen_tile(code,tile_object,c)
			count = count - 1
		end
		tries = tries - 1
	until count == 0 or tries == 0
end

function generator.safe_empty_coord( a )
	local result = generator.random_empty_coord({ EF_NOBEINGS, EF_NOITEMS, EF_NOSTAIRS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN, EF_NOSAFE }, area )
	if not result then
		result = generator.random_empty_coord({ EF_NOBEINGS, EF_NOITEMS, EF_NOSTAIRS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }, a )
	end
	if not result then
		result = generator.random_empty_coord({ EF_NOBEINGS, EF_NOITEMS, EF_NOBLOCK, EF_NOSPAWN }, a )
	end
	if not result and a then 
		return generator.safe_empty_coord()
	end
	return result
end

function generator.standard_empty_coord( param1, param2 )
	return generator.random_empty_coord( { EF_NOBEINGS, EF_NOITEMS, EF_NOSTAIRS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }, param1, param2 )
end

function generator.set_permanence( ar, val, tile )
	if type(val) ~= "boolean" then val = true end
	if tile then
		tile = cells[ tile ].nid
		for c in generator.each( tile, ar ) do
			level.light[ c ][ LFPERMANENT ] = val
		end
	else
		for c in ar:coords() do
			local id = generator.get_cell( c )
			if generator.cell_sets[ CELLSET_WALLS ][ id ] then
				level.light[ c ][ LFPERMANENT ] = val
			end
		end
	end
end

function generator.set_blood( ar, val, tile )
	if type(val) ~= "boolean" then val = true end
	if tile then
		tile = cells[ tile ].nid
		for c in generator.each( tile, ar ) do
			level.light[ c ][ LFBLOOD ] = val
		end
	else
		level.light[ ar ][ LFBLOOD ] = true
	end
end

function generator.drunkard_walks( amount, steps, cell, ignore, break_on_edge, drunk_area )
	core.log("generator.drunkard_walks("..amount..","..steps..","..cell.."...)")
	if amount <= 0 then return end
	drunk_area = drunk_area or area.FULL_SHRINKED
	for i=1,amount do
		generator.run_drunkard_walk( drunk_area, drunk_area:random_coord(), steps, cell, ignore, break_on_edge )
	end
end

function generator.contd_drunkard_walks( amount, steps, cell, edges1, edges2, ignore, break_on_edge, drunk_area )
	core.log("generator.contd_drunkard_walks("..amount..","..steps..","..cell.."...)")
	if amount <= 0 then return end
	drunk_area = drunk_area or area.FULL_SHRINKED
	local c
	for i=1,amount do
		repeat
			c = drunk_area:random_coord()
		until generator.cross_around( c, edges1 ) > 0 and
			generator.cross_around( c, edges2 ) > 0
		generator.run_drunkard_walk( drunk_area, c, steps, cell, ignore, break_on_edge )
	end
end


function generator.plot_lines( where, larea, horiz, cell, block )
	core.log("generator.plot_lines(...)")
	local step = function( point, px, py )
		point.x = point.x + px
		point.y = point.y + py
		if block[ generator.get_cell( point ) ] then
			return true
		else
			generator.set_cell( point, cell )
			return false
		end
	end
	local hcoord = function( c ) if horiz then return c.x else return c.y end end

	local sx, sy, minv, maxv = 0, 0, 0, 0
	if horiz then
		sx = 1; minv = larea.a.x; maxv = larea.b.x
	else
		sy = 1; minv = larea.a.y; maxv = larea.b.y
	end

	local c
	c = coord.clone( where )
	while hcoord(c) < maxv do if step( c, sx, sy ) then break end end
	c = coord.clone( where )
	while hcoord(c) > minv do if step( c, -sx, -sy ) then break end end
end

function generator.maze_dungeon( floor_cell, wall_cell, granularity, tries, minl, maxl, maze_area )
	core.log("generator.maze_dungeon()")
	if type(floor_cell) == "string" then floor_cell = cells[floor_cell].nid end
	maze_area = maze_area or area.FULL
	local rx = math.floor( ( maze_area.b.x - maze_area.a.x ) / granularity )
	local ry = math.floor( ( maze_area.b.y - maze_area.a.y ) / granularity )
	local rl = math.floor( ( maxl - minl ) / granularity + 1 )
	for i=1,tries do
		local c = coord.new(
			granularity * math.random( rx ) + maze_area.a.x,
			granularity * math.random( ry ) + maze_area.a.y
		)
		if generator.get_cell( c ) == floor_cell and generator.cross_around( c, floor_cell ) == 4 then
			local step = coord.new( 0, 0 )
			local length = minl + granularity * ( math.random( rl ) - 1 )
			if math.random( 2 ) == 1 then
				step.x = math.random(2)*2-3
			else
				step.y = math.random(2)*2-3
			end
			while maze_area:contains( c + step ) and generator.get_cell( c + step ) == floor_cell and length > 0 do
				generator.set_cell( c, wall_cell )
				c = c + step
				length = length - 1
			end
			generator.set_cell( c, wall_cell )
		end
	end
end

function generator.warehouse_fill( wall_cell, fill_area, boxsize, amount, special_chance, special_fill )
	local floor_cell   = generator.styles[ level.style ].floor

	boxsize = boxsize or 2
	amount  = amount or 50
	local dim = coord.new( boxsize+2, boxsize+2 )
	for i = 1, amount do
		local ar = fill_area:random_subarea( dim )
		if generator.scan( ar, floor_cell ) then
			ar:shrink(1)
			local fill_cell = wall_cell
			if special_chance and special_fill and boxsize < 4 then
				local dim = ar:dim()
				local roll = math.random(math.max(100 * (boxsize-1),100))
				if roll <= special_chance then fill_cell = special_fill end
			end
			if type(fill_cell) == "table" then fill_cell = table.random_pick( fill_cell ) end
			generator.fill( fill_cell, ar )
		end
	end
end

function generator.read_rooms()
	core.log("generator.add_rooms()")
	local room_list      = {}
	local cell_meta      = generator.merge_cell_sets( generator.cell_sets[ CELLSET_WALLS ], generator.cell_sets[ CELLSET_DOORS ] )
	local cell_meta_list = generator.merge_cell_lists( generator.cell_lists[ CELLSET_WALLS ], generator.cell_lists[ CELLSET_DOORS ] )
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
			table.insert( room_list, area.new( start, ec ) )
		end
	end
	return room_list
end

function generator.add_room( room, class )
	local r = room:clone()
	local rm = {}
	rm.class = class or "closed"
	rm.used  = false
	rm.dims  = area.dim( r )
	rm.size  = rm.dims.x * rm.dims.y
	table.insert( generator.room_list, r )
	generator.room_meta[ r ] = rm
end

function generator.add_rooms()
	core.log("generator.add_rooms()")
	local room_list = generator.read_rooms()
	for _,room in ipairs( room_list ) do
		generator.add_room( room )	
	end
end

function generator.get_room( min_size, max_x, max_y, max_area, class )
	core.log("generator.get_room()")
	local cl = class or "any"
	local marea = max_area or 10000
	local choice_list = {}
	for _,r in ipairs( generator.room_list ) do
		local rm = generator.room_meta[r]
		if not rm.used and ( rm.class == "any" or class == "any" or rm.class == cl ) then
			if rm.dims.x >= min_size and rm.dims.y >= min_size and
				rm.dims.x <= max_x and rm.dims.y <= max_y and rm.size <= marea then
				table.insert( choice_list, r )
			end
		end
	end
	return table.random_pick( choice_list )
end

function generator.restore_walls( wall_cell, fluid_to_perm )
	core.log("generator.restore_walls("..wall_cell..")")
	if fluid_to_perm then
		for c in area.edges( area.FULL ) do
			local sub = fluid_to_perm[ cells[generator.get_cell( c )].id ] or wall_cell
			generator.set_cell( c, sub )
		end
	else
		generator.fill_edges( wall_cell )
	end
end

function generator.handle_rooms( count, no_monsters, restore_walls )
	core.log("generator.handle_rooms()")
	if count < 1 or #(generator.room_list) == 0 then return end
	local choice = weight_table.new()
	for _,r in ipairs(rooms) do
		if not no_monsters or r.no_monsters then choice:add( r ) end
	end
	if choice:size() == 0 then return end

	for i = 1,count do
		local room      = choice:roll()
		local room_area = generator.get_room( room.min_size, room.max_size_x, room.max_size_y, room.max_area, room.class )
		if room_area then
			core.log("generator.handle_rooms() > setting up room : "..room.id)
			if room.setup( room_area ) then
				generator.room_meta[room_area].used = true
			end
		end
	end
	generator.restore_walls( generator.styles[ level.style ].wall, restore_walls )
end


function generator.roll_event()
	core.log("generator.roll_event()")

	local lvl = level.danger_level
	local choice = weight_table.new()
	for _,e in ipairs(events) do
		if lvl >= e.min_dlevel and DIFFICULTY >= e.min_diff then choice:add( e ) end
	end
	if choice:size() == 0 then return end
	local event = choice:roll()

	core.log("generator.roll_event() > setting up event : "..event.id)
	level.data.event = {}
	level.data.event.id = event.id
	event.setup()
	generator.OnTick = event.on_tick
	generator.OnExit = event.on_leave
	if event.message then ui.msg_feel( event.message ) end
	if event.history then player:add_history( event.history ) end
end

function generator.on_save()
	generator.OnTick = nil
	generator.OnExit = nil
end

function generator.on_load()
	if level.data.event then
		generator.OnTick = events[ level.data.event.id ].on_tick
		generator.OnExit = events[ level.data.event.id ].on_leave
	end
end

function generator.reset()
	core.log("generator.reset()")
	ui.clear_feel()
	generator.OnKill    = nil
	generator.OnKillAll = nil
	generator.OnEnter   = nil
	generator.OnExit    = nil
	generator.OnTick    = nil

	generator.room_list = {}
	generator.room_meta = {}

	level:set_generator_style( level.style )
	generator.fill( generator.styles[ level.style ].floor )
	generator.fill_edges( generator.styles[ level.style ].wall )
end

function generator.place_player()
	core.log("generator.place_player()")
	local pos = generator.safe_empty_coord()
	level:drop_being( player, pos )
	return pos
end

function generator.generate_stairs( stairs_id )
	core.log("generator.generate_stairs()")
	local pos = generator.standard_empty_coord()
	generator.set_cell( pos, stairs_id )
	return pos
end

function generator.generate_special_stairs( stairs_id, feelings )
	core.log("generator.generate_special_stairs()")
	local pos
	if level.special_exit ~= "" then
		pos = generator.generate_stairs( stairs_id )
		if feelings then
			if type(feelings) == "string" then feelings = { feelings } end
			ui.msg_feel( table.random_pick( feelings ) )
		end
	end
	return pos
end

function generator.generate_tiled_level( settings )
	core.log("generator.generate_tiled_level()")
	local settings     = settings or {}
	local wall_cell    = settings.wall_cell  or cells[generator.styles[ level.style ].wall].nid
	local door_cell    = settings.door_cell  or cells[generator.styles[ level.style ].door].nid
	local floor_cell   = settings.floor_cell or cells[generator.styles[ level.style ].floor].nid

	local block = generator.cell_set{ wall_cell }

	local plot = function( horiz, where )
		generator.plot_lines( where, area.FULL, horiz, wall_cell, block )
		generator.set_cell( where, door_cell )
	end

	local div_point = function( x, yrange, ymult, ymod )
		return coord.new( x, math.random(yrange)*ymult+ymod )
	end

	local MAX2 = math.floor(MAXX / 2)
	local MAX4 = math.floor(MAXX / 4)
	local MAX8 = math.floor(MAXX / 8)

	local nfirst = settings.subdiv      or 5
	local ndoors = settings.extra_doors or 4
	local pdoors = settings.add_doors   or 8

	if math.random(3) == 1 then
		plot( false, div_point( math.random(MAX4-8)*2+4,       8,2,2 ) )
		plot( false, div_point( math.random(MAX4-8)*2+4+MAX4*2,8,2,2 ) )
	else
		plot( false, div_point( math.random(MAX4-12)*2+4,            8,2,2 ) )
		plot( false, div_point( math.random(MAX4-4)*2 + MAX2 - MAX4, 8,2,2 ) )
		plot( false, div_point( math.random(MAX4-12)*2+8+MAX4*2,     8,2,2 ) )
	end
	for i = 1,4 do
		plot( true, div_point( math.random(MAX8-6)*2+MAX4*(i-1)+2,4,4,1 ) )
	end

	for i = 1,nfirst do
		if math.random(3) == 3 then
			plot( true, div_point( math.random(MAX2-2)*2+1, 8,2,1 ) )
		else
			plot( false, div_point( math.random(MAX2-2)*2+2, 6,2,2 ) )
		end
	end

	local door_positions = {}
	local priority_doors = {}
	
	for c in area.coords( area.FULL_SHRINKED ) do
		if generator.get_cell( c ) == wall_cell
		and generator.around( c, door_cell ) == 0 
		and generator.cross_around( c, wall_cell ) == 2
		and generator.cross_around( c, floor_cell ) == 2
		then
			local walls = generator.around( c, wall_cell )
			if walls > 4 then
				if generator.around( c, door_cell ) == 0 then
					generator.set_cell( c, door_cell )
				end
			elseif walls > 3 then
				table.insert( priority_doors, c:clone() )
			else
				table.insert( door_positions, c:clone() )
			end
		end
	end

	for i = 1,pdoors do
		local pos = table.random_remove( priority_doors )
		if pos and generator.around( pos, door_cell ) == 0 then
			generator.set_cell( pos, door_cell )
		end
	end

	for i = 1,ndoors do
		local pos = table.random_remove( door_positions )
		if pos and generator.around( pos, door_cell ) == 0 then
			generator.set_cell( pos, door_cell )
		end
	end

	generator.restore_walls( wall_cell )
	generator.add_rooms()
end

function generator.generate_archi_level( settings )
	core.log("generator.generate_archi_level()")
	assert( settings, "no settings for archi level!" )
	local data = nil
	if settings.size then
		data = settings
	else
		assert( settings.data, "no data for archi level!" )
		if settings.data.size then
			data = settings.data
		else
			data = table.random_pick( settings.data )
			assert( data.size, "malformed data for archi level!" )
		end
	end
		
	local wall_cell    = generator.styles[ level.style ].wall
	local translation = {
		["X"] = wall_cell,
		["."] = generator.styles[ level.style ].floor,
		["+"] = generator.styles[ level.style ].door,
	}

	generator.fill( wall_cell )

	local blocks = data.blocks
	local bsize  = data.size
	local shift  = data.shift 
	if not blocks then
		blocks = coord.new( math.floor( (MAXX-1) / (bsize.x-1) ), math.floor( (MAXY-1) / (bsize.y-1) ) )
	end
	if not shift then
		shift = coord.new( MAXX, MAXY ) - blocks * (bsize - coord.UNIT)
		shift.x = math.max( 1, math.floor( shift.x / 2 ) )
		shift.y = math.max( 1, math.floor( shift.y / 2 ) )
	end
	core.log( "blocks: "..blocks.x.."x"..blocks.y.." size: "..bsize.x.."x"..bsize.y.." shift: "..shift.x..","..shift.y )
	if data.trans then
		for k,v in pairs( data.trans ) do translation[k] = v end
	end
	if settings.trans then
		for k,v in pairs( settings.trans ) do translation[k] = v end
	end

	for bx=1,blocks.x do
		for by=1,blocks.y do
			local block = table.random_pick( data )
			local pos   = coord.new( (bx-1) * (bsize.x-1) + shift.x, (by-1) * (bsize.y-1) + shift.y )
			local tile  = generator.tile_new( block, translation )
			tile:flip_random()
			generator.tile_place( pos, tile )
		end
	end

	for c in generator.each( generator.styles[ level.style ].door ) do
		if generator.cross_around( c, wall_cell ) > 2 then
			generator.set_cell( c, wall_cell )
		end
	end

	generator.restore_walls( wall_cell )
	generator.generate_fluids(area.new(shift.x+1, shift.y+1, MAXX - shift.x-1, MAXY - shift.y-1))
end
