function level:get_being_table( dlevel, weights, reqs, dmod )
	local dmod   = dmod or math.clamp( (DIFFICULTY-2)*3, 0, 6 )
	local danger = dlevel or self.danger_level
	local list   = weight_table.new()

	for _,b in ipairs(beings) do
		if b.weight > 0	and danger+dmod >= b.min_lev and danger <= b.max_lev then
			if core.proto_reqs_met( b, reqs ) then
				local weight = core.proto_weight( b, weights )
				list:add( b, weight )
			end
		end
	end

	for _,bg in ipairs(being_groups) do
		if bg.weight > 0 and danger+dmod >= bg.min_lev and danger <= bg.max_lev then
			if core.proto_reqs_met( bg, reqs ) then
				local weight = core.proto_weight( bg, weights )
				list:add( bg )
			end
		end
	end
	return list
end

function level:get_item_table( dlevel, weights, reqs )
	local danger       = dlevel or self.danger_level
	local allow_exotic = self.danger_level > DIFFICULTY
	local allow_unique = self.danger_level > DIFFICULTY+3
	local list         = weight_table.new()
	for _,i in ipairs(items) do
		if i.weight > 0 and danger >= i.level then
			if (not i.is_exotic or allow_exotic) and (not i.is_unique or allow_unique) then
				if core.proto_reqs_met( i, reqs ) then
					local weight = core.proto_weight( i, weights )
					if weight > 0 and (not i.is_unique or not player.__props.items_found[i.id]) then
						list:add( i, weight )
					end
				end
			end
		end
	end
	return list
end

function level:flood_monsters( params )
	if not params.danger and not params.amount then 
		error("level:flood_monsters expects at least danger or count!")
	end
	local flags  = params.flags  or { EF_NOBEINGS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }
	local dtotal = params.danger or 100000000
	local count  = params.amount or 100000000 
	local reqs   = params.reqs
	if params.no_groups then 
		reqs = reqs or {}
		reqs.is_group = false
	end
	local list
	if params.list then
		list = weight_table.new()
		for k,v in pairs( params.list ) do
			if type(k) == "string" then
				list:add( beings[k], v )
			else
				list:add( beings[v] )
			end
		end
	else
		list = self:get_being_table( params.level, params.weights, reqs, params.diffmod )
	end

	while (dtotal > 0) and (count > 0) do
		local bp    = list:roll()
		local where = generator.random_empty_coord( flags, params.area )
		if not where then break end
		if bp.is_group then
			for _,group in ipairs(bp.beings) do
				local count = resolverange(group.amount or 1)
				for i=1,count do
					self:drop_being( group.being, where )
					dtotal = dtotal - beings[group.being].danger
					count  = count - 1
				end
			end
		else
			self:drop_being( bp.id, where )
			dtotal = dtotal - beings[bp.id].danger
			count  = count - 1
		end
	end
end

function level:flood_monster( params )
	if not params.id or (not params.danger and not params.amount) then 
		error("level:flood_monster expects at least id and danger or count!")
	end
	local id     = params.id
	local flags  = params.flags  or { EF_NOBEINGS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }
	local dtotal = params.danger or 100000000
	local count  = params.amount or 100000000 
	while (dtotal > 0) and (count > 0) do
		local being = self:drop_being( id, generator.random_empty_coord( flags, params.area ) )
		if not being then return end
		dtotal = dtotal - beings[id].danger
		count  = count - 1
	end
end

function level:flood_items( params )
	params = params or {}
	local amount  = params.amount or params
	local list    = self:get_item_table( params.level or level.danger_level, params.weights, params.reqs )

	while amount > 0 do
		local ip = list:roll()
		if not ( ip.is_unique and self.flags[ LF_UNIQUEITEM ] ) then
			if ip.is_unique then
				self.flags[ LF_UNIQUEITEM ] = true
			end
			local where = generator.random_empty_coord{ EF_NOITEMS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }
			self:drop_item( ip.id, where, true )
			amount = amount - 1
		end
	end
end

function level:roll_being( params )
	local flags  = params.flags  or { EF_NOBEINGS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }
	local reqs   = params.reqs or {}
	reqs.is_group = false
	local list
	if params.list then
		list = weight_table.new()
		for k,v in pairs( params.list ) do
			if type(k) == "string" then
				list:add( beings[k], v )
			else
				list:add( beings[v] )
			end
		end
	else
		list = self:get_being_table( params.level, params.weights, reqs, params.diffmod )
	end
	return list:roll().id
end

function level:roll_item( params )
	params = params or {}
	local reqs    = params.reqs
	local weights = params.weights
	if self.flags[ LF_UNIQUEITEM ] then 
		reqs = reqs or {}
		reqs.is_unique = false
	end
	if params.type then
		reqs = reqs or {}
		reqs.type = params.type
	end
	if params.unique_mod or params.special_mod or params.exotic_mod then
		weights = weights or {}
		weights[ IF_UNIQUE ]  = params.unique_mod
		weights[ IF_EXOTIC ]  = params.exotic_mod
		weights.is_special    = params.special_mod
	end
	local list    = self:get_item_table( params.level, weights, reqs )
	if list:size() == 0 then return nil end
	local ip    = list:roll()
	if ip.is_unique then
		self.flags[ LF_UNIQUEITEM ] = true
	end
	return ip.id
end

function level:summon(t,opt)
	local count = 1
	local where = nil
	local cid   = nil
	local bid   = nil
	local empty = { EF_NOBEINGS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }
	if type(t) == "string" then 
		bid = t
		count = opt or 1
	elseif type(t) == "table" then 
		bid   = t.id or t[1]
		count = t.count or t[2] or 1
		cid   = t.cell
		if cid then empty = { EF_NOBEINGS, EF_NOBLOCK } end
		where = t.area
		empty = t.empty or empty
	else
		error( "Bad argument #1 passed to summon!" )
	end
	if not bid then 
		error( "Being id not defined for summon!" )
	end
	if count <= 0 then return nil end
	local last_being = nil
	local c
	for i=1,count or 1 do
		if cid then
			c = generator.random_empty_coord(empty, cid, where)
		else
			c = generator.random_empty_coord(empty, where)
		end
		last_being = self:drop_being( bid, c )
	end
	return last_being
end

-- Overrides LuaMapNode API!
function level:drop(iid,count)
	if type(iid) == "string" then iid = items[iid].nid end
	local last_item = nil
	for i=1,count or 1 do
		last_item = self:drop_item(iid,generator.random_empty_coord{ EF_NOITEMS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN })
	end
	return last_item
end

function level:area_drop(where,iid,count,onfloor)
	if type(iid) == "string" then iid = items[iid].nid end
	onfloor = onfloor or false
	local last_item = nil
	for i=1,count or 1 do
		local pos = generator.random_empty_coord( { EF_NOITEMS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }, where )
		if not pos then break end
		last_item = self:drop_item(iid,pos,onfloor)
	end
	return last_item
end

function level:drop_item_ext( item, c )
	local id = item
	if type(id) == "table"  then id = id[1] end
	if type(id) == "string" then id = items[id].nid end
	local new_item = self:drop_item(id,c)
	if type(item) == "table" then
		for k,v in pairs(item) do
			if type(k) == "string" then
				new_item[k] = v
			end
		end
	end
end

function level:drop_being_ext( being, c )
	local id = being
	if type(id) == "table"  then id = id[1] end
	if type(id) == "string" then id = beings[id].nid end
	local new_being = self:drop_being(id,c)
	if type(being) == "table" then
		for k,v in pairs(being) do
			if type(k) == "string" then
				new_being[k] = v
			end
		end
	end
end

function level:try_destroy_item( coord )
	local item = self:get_item( coord )
	if item and not item.flags[ IF_UNIQUE ] and not item.flags[ IF_NODESTROY ] then item:destroy() end
end

function level:flood( tile, flood_area )
	local hazard = cells[tile].flags[ CF_HAZARD ]
	local nid    = cells[tile].nid
	for c in flood_area() do
		local cell_proto = cells[generator.get_cell(c)]
		if cell_proto.set == CELLSET_FLOORS or cell_proto.flags[ CF_LIQUID ] then
			generator.set_cell(c,nid)
		end
		if hazard then
			self:try_destroy_item(c)
		end
	end
	self:recalc_fluids()
end

function level:is_corpse( c )
	local cell = cells[ self.map[ c ] ]
	return cell.id == "corpse" or cell.flags[ CF_CORPSE ]
end

function level:push_cell(c, target, quiet)
	local cell_id = self.map[c]
	local name    = cells[ cell_id ].name
	if not area.FULL:contains(target) then
		if not quiet then ui.msg( "It doesn't seem to move there." ) end
		self:play_sound( cell_id .. ".movefail", c )
		return false
	end
	local cell = cells[cell_id]
	local target_cell_id = self.map[target]
	local target_cell = cells[target_cell_id]
	if target_cell.flags[CF_HAZARD] then
		if not quiet then ui.msg( "Oh my, how stupid!" ) end
		self:play_sound( cell_id .. ".move", c )
		--self.map[c] = cell.destroyto
		cell.OnDestroy( c )
		return true
	end
	if target_cell.set ~= CELLSET_FLOORS then
		if not quiet then ui.msg( "It doesn't seem to move there." ) end
		self:play_sound( cell_id .. ".movefail", c )
		return false
	end
	if not generator.is_empty( target, { EF_NOITEMS, EF_NOBEINGS } ) then
		if not quiet then ui.msg( "Something's blocking the "..name.."." ) end
		self:play_sound( cell_id .. ".movefail", c )
		return false
	end
	self:play_sound( cell_id .. ".move", c )
	--TODO: trigger smooth move animation in G-version?
	local hp_c = self.hp[c]
	local hp_target = self.hp[target]
	self.map[c] = target_cell_id
	self.map[target] = cell_id
	self.hp[target] = hp_c
	self.hp[c] = hp_target
	if not quiet then ui.msg( "You push the "..name.."." ) end
	return true
end

function level:beings()
	return self:children("being")
end

function level:items()
	return self:children("item")
end

function level:beings_in_range( position, range )
	return self:children_in_range( position, range, ENTITY_BEING )
end

function level:items_in_range( position, range )
	return self:children_in_range( position, range, ENTITY_ITEM )
end

level.data = setmetatable({}, {
	__newindex = function (_, k,v)
		local l = levels[level.id]
		if not l.data then 
			l.data = {}
		end
		l.data[k] = v
	end,
	__index = function (_, k,v)
		local l = levels[level.id]
		if not l.data then 
			l.data = {}
		end
		return l.data[k]
	end,
})

table.merge( level, game_object )
setmetatable( level, getmetatable(game_object) )
