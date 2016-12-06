generator.styles = {}
generator.cell_sets = {}
generator.room_list = {}
generator.room_meta = {}

function generator.cell_set( list )
	local s = {}
	for _,v in ipairs( list ) do
		s[cells[v].nid] = true
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
		if tile_entry.being then level:drop_being_ext( tile_entry.being, tile_pos + c - coord.UNIT ) end
		if tile_entry.item  then level:drop_item_ext( tile_entry.item, tile_pos + c - coord.UNIT ) end
		if tile_entry.flags then
			for _, flag in ipairs(tile_entry.flags) do
				level.light[tile_pos + c - coord.UNIT][flag] = true
			end
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

function generator.standard_empty_coord()
	return generator.random_empty_coord{ EF_NOBEINGS, EF_NOITEMS, EF_NOSTAIRS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }
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

function generator.handle_rooms( count, no_monsters )
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
	generator.restore_walls( generator.styles[ level.style ].wall, true )
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
	event.setup()
	if event.message then ui.msg_feel( event.message ) end
	if event.history then player:add_history( event.history ) end
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

	generator.fill( generator.styles[ level.style ].floor )
	generator.fill_edges( generator.styles[ level.style ].wall )
end
