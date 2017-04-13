--[[
  WolfRL's generator leaves the original, hard-to-understand-because-KK-doesn't-document
  generator mostly intact.  Of course some changes are unavoidable, and some are just desired:
  * Some level events have been massaged/removed
  * Code for tile flair has been slopped in, it changes slightly in G-mode
  * Treasure has its own special code handling so as not to interfere with useful drops
  * Rare weapons spawn with ammo (only applies to vaults)
  * Ammo basins can spawn rare ammo if you have an appropriate weapon in your inventory
  * No perm water walls on map edges.  Me no likey that.
  * Default SIDs change wherever I need them changed
  * Water and Acid rivers still show up on higher levels
  * Barrels are more varied
--]]

require( "doomrl:archi" )
generator.fluid_to_perm = {
	water  = "water",
	lava   = "lava",
	acid   = "acid",
	pwater = "water",
	plava  = "lava",
	pacid  = "acid",
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

	if type( gen.treasure ) == "function" then
		gen.treasure( generator.treasure_amount() ) 
	elseif gen.treasure > 0.01 then
		generator.flood_treasure( math.ceil( generator.treasure_amount() * gen.treasure ) )
	end

	if type( gen.flair_rwall ) == "function" then
		gen.flair_rwall()
	elseif gen.flair_rwall > 0.0 then
		generator.add_random_flair_wall(area.FULL, generator.styles[ level.style ].flairwall, gen.flair_rwall)
	end
	if type( gen.flair_rdoor ) == "function" then
		gen.flair_rdoor()
	elseif gen.flair_rdoor > 0.0 then
		generator.add_random_flair_door(area.FULL, generator.styles[ level.style ].flairdoor, gen.flair_rdoor)
	end

	for _,r in ipairs( generator.room_list ) do
		--For each room try to add the three flair types.
		if (gen.flair_nwall > 0.0) then
			if type( gen.flair_cwall ) == "function" then
				gen.flair_cwall(gen.flair_nwall)
			elseif gen.flair_cwall > 0.0 and math.random() < gen.flair_cwall then
				generator.add_room_flair_wall( r, generator.styles[ level.style ].flairwall, gen.flair_nwall )
			end
		end
		if (gen.flair_ncorn > 0.0) then
			if type( gen.flair_ccorn ) == "function" then
				gen.flair_ccorn(gen.flair_ncorn)
			elseif gen.flair_ccorn > 0.0 and math.random() < gen.flair_ccorn then
				generator.add_room_flair_corner( r, generator.styles[ level.style ].flaircorner, gen.flair_ncorn )
			end
		end
		if (gen.flair_ndoor > 0.0) then
			if type( gen.flair_cdoor ) == "function" then
				gen.flair_cdoor(gen.flair_ndoor)
			elseif gen.flair_cdoor > 0.0 and math.random() < gen.flair_cdoor then
				generator.add_room_flair_door( r, generator.styles[ level.style ].flairdoor, gen.flair_ndoor )
			end
		end
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

-- Flair related
function generator.set_flair( coord, flair )
	--Necessary since blood can be flair
	if (flair == "blood") then
		level.light[ coord ][ LFBLOOD ] = true
	else
		level.map[ coord ] = flair
	end
end
function generator.set_flair_safe( coord, flair )
	if (generator.is_flair_safe( coord )) then
		generator.set_flair( coord, flair )
	end
end
function generator.is_flair_safe( coord )

	--In G-mode flair cannot be on a vertical wall.
	--This is easily checked by looking at the cell beneath our coord.
	--In C-mode flair can be in more places; originally it had to be in
	--between two walls as that was guaranteed to be non-distracting
	--but I've decided now that up to THREE walls in any direction is
	--fine (and also it prevents maze levels from being barren).
 	if generator.styles[ level.style ].wall ~= level.map[ coord ] then return false end
	if (string.find(VERSION_STRING, "G")) then
		local coordBottom = coord.new(coord.x, coord.y+1)
		if (not area.FULL:contains(coordBottom) or cells[ generator.get_cell(coordBottom) ].flags[CF_STICKWALL]) then return false end
		return true
	else
		local count = 0
		local coordCross
		coordCross = coord.new(coord.x, coord.y+1)
		if (area.FULL:contains(coordCross) and cells[ generator.get_cell(coordCross) ].flags[CF_STICKWALL]) then count = count + 1 end
		coordCross = coord.new(coord.x, coord.y-1)
		if (area.FULL:contains(coordCross) and cells[ generator.get_cell(coordCross) ].flags[CF_STICKWALL]) then count = count + 1 end
		coordCross = coord.new(coord.x+1, coord.y)
		if (area.FULL:contains(coordCross) and cells[ generator.get_cell(coordCross) ].flags[CF_STICKWALL]) then count = count + 1 end
		coordCross = coord.new(coord.x-1, coord.y)
		if (area.FULL:contains(coordCross) and cells[ generator.get_cell(coordCross) ].flags[CF_STICKWALL]) then count = count + 1 end

		return count < 4
	end
end

function generator.add_room_flair_wall(room, flair, rate)
	core.log("generator.add_room_flair_wall")

	if (flair and #flair > 0) then
		--Check every edge cell to see if it's a door.
		for c in room:edges() do
			if (math.random() < rate) then
				generator.set_flair_safe( c, table.random_pick(flair) )
			end
		end
	end
end
function generator.add_room_flair_corner(room, flair, rate)
	core.log("generator.add_room_flair_corner")

	--Corners are straightforward.
	if (flair and #flair > 0) then
		for c in room:corners() do
			if (math.random() < rate) then
				for cc in c:cross_coords() do
					if (room:contains(cc)) then
						generator.set_flair_safe( cc, table.random_pick(flair) )
					end
				end
			end
		end
	end
end
function generator.add_room_flair_door(room, flair, rate)
	core.log("generator.add_room_flair_door")

	if (flair and #flair > 0) then
		--Check every edge cell to see if it's a door.
		for c in room:edges() do
			if (generator.cell_sets[ CELLSET_DOORS ][ level.map[ c ] ] and math.random() < rate) then
				--Found a door, get the flanking walls.
				--Doing a cross should be safe.  We could figure out which two cells if we wanted to.
				for cc in c:cross_coords() do
					generator.set_flair_safe( cc, table.random_pick(flair) )
				end
			end
		end
	end
end
function generator.add_random_flair_wall(ar, flair, rate)
	core.log("generator.add_random_flair_wall")

	--Random flair.  Unlike before this is an area, not a room, so we iterate through every coord.
	if (flair and #flair > 0) then
		--There's no way around this.  We must check every cell to see if it's a door.
		for c in ar:coords() do
			if (math.random() < rate) then
				generator.set_flair_safe( c, table.random_pick(flair) )
			end
		end
	end
end
function generator.add_random_flair_door(ar, flair, rate)
	core.log("generator.add_random_flair_door")

	if (flair and #flair > 0) then
		--There's no way around this.  We must check every cell to see if it's a door.
		for c in ar:coords() do
			if (generator.cell_sets[ CELLSET_DOORS ][ level.map[ c ] ] and math.random() < rate) then
				--Found a door, get the flanking walls.
				for cc in c:cross_coords() do
					generator.set_flair_safe( cc, table.random_pick(flair) )
				end
			end
		end
	end
end


-- Treasure related
function generator.flood_treasure(treasureValue)
	core.log("generator.flood_treasure()")

	while treasureValue > 0 do
		local treasureType
		    if(treasureValue >= 50 and math.random(4) == 4) then treasureType = "wolf_crown"   treasureValue = treasureValue - 50
		elseif(treasureValue >= 10 and math.random(3) == 3) then treasureType = "wolf_chest"   treasureValue = treasureValue - 10
		elseif(treasureValue >=  5 and math.random(2) == 2) then treasureType = "wolf_chalice" treasureValue = treasureValue -  5
		else                                                     treasureType = "wolf_cross"   treasureValue = treasureValue -  1
		end

		level:drop_item( treasureType, generator.random_empty_coord{ EF_NOITEMS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN } )
	end
end
function generator.treasure_amount()
	local treasureValue = 0
	for i = 0, math.min(level.danger_level, 25), 1 do
		treasureValue = treasureValue + i
	end
	return math.ceil(treasureValue / 3)
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
	    if lvl < 17 or math.random(10) == 1 then cell = "water"
	elseif lvl < 27 or math.random(5)  == 1 then cell = "acid" end

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

function generator.warehouse_dungeon()
	local wall_cell    = generator.styles[ level.style ].wall
	local floor_cell   = generator.styles[ level.style ].floor
	local door_cell    = generator.styles[ level.style ].door

	local areas = {}
	local divs = 2
	if math.random(3) == 1 then divs = math.random(3) end
	local block = generator.cell_set{ wall_cell }
	local divpoint = 1

	for i=1,divs do
		local newdiv = math.floor( MAXX / (divs+1) )*i + math.random(16)-8
		local where = coord.new( newdiv, math.random(12)+4 )
		generator.plot_lines( where, area.FULL, false, wall_cell, block )
		generator.set_cell( where, door_cell )
		table.insert( areas, area.new( divpoint+1, 2, newdiv-1, MAXY-1 ) )
		divpoint = newdiv
	end
	table.insert( areas, area.new( divpoint+1, 2, MAXX-1, MAXY-1 ) )

	local fill    = wall_cell
	local sfill   = nil
	local schance = nil
	if math.random( 3 ) < 3 then
		fill = { "crate", "ycrate" }
		sfill = { "crate_ammo", "crate_armor" }
		schance = 10
	end

	for _,ar in ipairs(areas) do
		local size = 3
		local tries = 50
		if math.random(3) == 1 then size = math.random(3)+1 end
		if math.random(3) == 1 then tries = 200 end

		generator.warehouse_fill( fill, ar, size, tries, schance, sfill )
	end
end

-- TODO: use Cells generated cellsets!
function generator.add_rooms()
	core.log("generator.add_rooms()")
	local cell_meta_list = { "wolf_whwall", "wolf_flrflag1", "door", "odoor", "mdoor1", "omdoor1" }
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

function generator.generate_caves_dungeon()
	core.log("generator.generate_caves_dungeon()")
	local dlevel = level.danger_level

	--Todo: force into cave tileset if I have the sprites
	local wall_cell    = generator.styles[ level.style ].wall
	local floor_cell   = generator.styles[ level.style ].floor

	local amount, step, fluid

	    if dlevel < 7  or math.random(10) == 1 then amount = math.random(3); step = math.random(40)+22; fluid = "water"
	elseif dlevel < 12 or math.random(5)  == 1 then amount = math.random(3); step = math.random(40)+42; fluid = "acid"
	else                                            amount = math.random(5); step = math.random(50)+42; fluid = "lava"
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
		    if lvl < 17 or math.random(10) == 1 then cell = "water"
		elseif lvl < 27 or math.random(5)  == 1 then cell = "acid" end

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
		{ level = { 1,  10 }, weight = 1, list = {"wolf_dog1","wolf_dog2"} },
		{ level = { 1,  16 }, weight = 2, list = {"wolf_guard1","wolf_guard2"} },
		{ level = { 4,  20 }, weight = 2, list = {"wolf_mutant1","wolf_mutant2"} },
		{ level = { 7,  25 }, weight = 2, list = {"wolf_ss1","wolf_ss2"} },
		{ level = { 10, 50 }, weight = 2, list = {"wolf_officer1","wolf_officer2"} },
		{ level = { 15 }, weight = 1, list = { "wolf_soldier1", "wolf_soldier2", "wolf_soldier3" } },
		{ level = { 20 }, weight = 1, list = { "wolf_trooper1", "wolf_trooper2", "wolf_trooper3" } },
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

  	ui.msg( "Twisted passages carry the smell of death..." )

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

	--Todo: force into cave tileset if I have the sprites
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
	    if lvl < 7  or math.random(10) == 1 then generator.drunkard_walks( math.random(3)-1, math.random(40)+2, "water", nil, nil, drunk_area )
	elseif lvl < 12 or math.random(5)  == 1 then generator.drunkard_walks( math.random(3)-1, math.random(40)+2, "acid",  nil, nil, drunk_area )
	elseif lvl < 17 or math.random(5)  == 1 then generator.drunkard_walks( math.random(5)-1, math.random(50)+2, "lava",  nil, nil, drunk_area )
	else                                         generator.drunkard_walks( math.random(5)+3, math.random(40)+2, "lava",  nil, nil, drunk_area )
	end
end

function generator.generate_barrels()
	core.log("generator.generate_barrels()")
	local lvl = level.danger_level + math.random(5)
	local count = math.random(8, 16)
	if math.random(22) == 22 then
		count = math.random(35, 55)
		ui.msg( "Khe, he, he, this will be a mess..." )
	end

	for i=1,count do
		local dlevel = math.random(level.danger_level)
		    if dlevel < 4  then generator.set_cell( generator.standard_empty_coord(), "barrel" )
		elseif dlevel < 8  then generator.set_cell( generator.standard_empty_coord(), "barrela" )
		else                    generator.set_cell( generator.standard_empty_coord(), "barreln" )
		end
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
		ui.msg( table.random_pick{
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
