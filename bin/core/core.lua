require( "core:constants" )
require( "core:commands" )
require( "core:functions" )
require( "core:generator" )
require( "core:level" )
require( "core:thing" )
require( "core:being" )
require( "core:item" )
require( "core:player" )
require( "core:ai" )
require( "core:blueprints" )
require( "core:ui" )

module = false

register_cell = core.register_storage( "cells", "cell", function( c )
		c.asciilow   = c.asciilow or c.ascii
		c.hp         = c.hp or c.armor
		if c.set then
			core.add_to_cell_set( c.set, c.nid )
			if not generator.cell_sets[ c.set ] then
				generator.cell_sets[ c.set ] = {}
			end
			generator.cell_sets[ c.set ][ c.id ] = true
			generator.cell_sets[ c.set ][ c.nid ] = true
		end
		core.register_cell( c.nid )
	end	
)

function register_corpse( being_proto )
	local proto = {
		name = being_proto.name.." corpse";
		ascii = "%";
		color = RED;
		armor = math.max(being_proto.armor, 1);
		hp = being_proto.hp;
		flags = {CF_CORPSE, CF_NOCHANGE, CF_OVERLAY, CF_VBLOODY, CF_RAISABLE};
		sprite = being_proto.sprite + ROW_SKIP;
		set = CELLSET_FLOORS;
		destroyto = "bloodpool";
		raiseto = being_proto.id;
	}
	if being_proto.flags[ F_LARGE ] then
		proto.flags = { F_LARGE, CF_CORPSE, CF_NOCHANGE, CF_OVERLAY, CF_VBLOODY, CF_RAISABLE}
		proto.sprite = being_proto.sprite + LARGE_CORPSE_SKIP
	end
	return register_cell( being_proto.id.."corpse" ) (proto)
end

register_room       = core.register_storage( "rooms", "room" )
register_event      = core.register_storage( "events", "event" )
register_difficulty = core.register_storage( "diff", "difficulty" )
register_medal      = core.register_storage( "medals", "medal" )
register_badge      = core.register_storage( "badges", "badge" )
register_affect     = core.register_storage( "affects", "affect", function (a) core.register_affect( a.nid ) end )
register_trait      = core.register_storage( "traits", "trait" )
register_ai         = core.register_storage( "ais", "ai" )
register_challenge  = core.register_storage( "chal", "challenge" )
register_itemset    = core.register_storage( "itemsets", "itemset" )
register_shotgun    = core.register_storage( "shotguns", "shotgun", function (s) core.register_shotgun( s.nid ) end )
register_missile    = core.register_storage( "missiles", "missile", function (m)
		m.sound_id = m.sound_id or m.id
		if m.content ~= 0 then
			m.content = cells[m.content].nid
		end
		core.register_missile(m.nid)
		return m.nid
	end
)
register_mod_array = core.register_storage( "mod_arrays", "mod_array", function (m) 
		m.sig   = core.mod_list_signature(m.mods)
		m.desc  = core.mod_array_description(m)
	end
)
register_klass      = core.register_storage( "klasses", "klass", function(k)
		k.trait = {}
		for i,t in ipairs(k.traits) do
			assert(t.id, "id undefined!")
			assert(traits[t.id], t.id.." undefined!")
			local tnid = traits[t.id].nid
			k.trait[tnid] = t
			k.trait[t.id] = t
		end

		k.traitlist = {}
		for i,t in ipairs(k.traits) do
			k.traitlist[i] = traits[t.id].nid
			traits[t.id][k.id] = t
			t.id = traits[t.id].nid
			if type( t.requires ) == "table" then
				for k,v in ipairs( t.requires ) do
					assert(traits[v[1]], v[1].." undefined!")
					v[1] = traits[v[1]].nid
				end
			end
			if type( t.blocks ) == "table" then
				for ii,v in ipairs( t.blocks ) do
					t.blocks[ii] = traits[v].nid
				end
			end
		end
	end
)

register_level   = core.register_storage( "levels", "level" )
levels.default = {}

register_requirement   = core.register_storage( "requirements", "requirement" )
register_exp_rank      = core.register_array_storage( "exp_ranks",   "rank" )
register_skill_rank    = core.register_array_storage( "skill_ranks", "rank" )
register_being_group   = core.register_array_storage( "being_groups", "being_group" )

register_being         = core.register_storage( "beings", "being", function( bp )
		bp.name_plural = bp.name_plural or bp.name.."s"

		bp.xp = bp.xp or (bp.danger*bp.danger*3+20)
		bp.is_group = false

		if bp.ai_type and bp.ai_type ~= "" then
			local ai_proto = ais[ bp.ai_type ]
			if ai_proto == nil then
				assert(false, "LUA: being["..bp.id.."] has unknown ai_type '"..bp.ai_type.."'!" )
			end

			local OnCreate = function( self )
				self:add_property( "ai_type", bp.ai_type )
				if ai_proto.OnCreate then
					ai_proto.OnCreate( self )
				end
			end

			bp.OnCreate   = core.create_seq_function( OnCreate, bp.OnCreate )
			bp.OnAction   = core.create_seq_function( ai_tools.OnAction, bp.OnAction )
			bp.OnAttacked = core.create_seq_function( bp.OnAttacked, ai_proto.OnAttacked )
		end

		if bp.weapon then
			local wid = "nat_"..bp.id
			local ip  = bp.weapon
			ip.name   = wid
			ip.type   = ITEMTYPE_NRANGED
			ip.weight = 0
			ip.sprite = 0
			register_item( wid ) ( ip )
			ip.flags[ IF_NODROP ] = true
			ip.flags[ IF_NOAMMO ] = true

			local OnCreate = function( self )
				self.eq.weapon = item.new( wid )
			end

			bp.OnCreate = core.create_seq_function( OnCreate, bp.OnCreate )
		end

		if bp.corpse then
			if type(bp.corpse) == "boolean" then bp.corpse = register_corpse(bp)  end
			if type(bp.corpse) == "string"  then bp.corpse = cells[bp.corpse].nid end
		end

		core.resolve_thing_sound( bp, "act" )
		core.resolve_thing_sound( bp, "hit" )
		core.resolve_thing_sound( bp, "die" )
		core.resolve_thing_sound( bp, "hoof" )
		core.resolve_thing_sound( bp, "attack" )
		core.resolve_thing_sound( bp, "melee" )

		core.register_resistances( bp )
	end
)

register_item          = core.register_storage( "items", "item", function( ip )
		local set = ip.set
		if set then
			ip.flags[ IF_SETITEM ] = true

			local OnEquip = function (self,being)
				if being:set_items( set ) == (itemsets[ set ].trigger - 1) then
					itemsets[ set ].OnEquip(self,being)
				end
			end

			local OnRemove = function (self,being)
				if being:set_items( set ) == itemsets[ set ].trigger then
					itemsets[ set ].OnRemove(self,being)
				end
			end

			ip.OnRemove = core.create_seq_function( OnRemove, ip.OnRemove )
			ip.OnEquip  = core.create_seq_function( OnEquip, ip.OnEquip )
		end

		ip.flags[ ip.type ] = true
		ip.is_unique  = ip.flags[ IF_UNIQUE ] or false
		ip.is_exotic  = ip.flags[ IF_EXOTIC ] or false
		ip.is_special = ip.is_exotic or ip.is_unique

		if type(ip.ammo_id) == "string" then ip.ammo_id = items[ip.ammo_id].nid	end

		if ip.damage then
			local damage_dice, damage_sides, damage_bonus = string.match(ip.damage, "(%d+)d(%d+)([-+]?%d*)")
			ip.damage_dice = tonumber(damage_dice) or 0
			ip.damage_sides = tonumber(damage_sides) or 0
			ip.damage_bonus = tonumber(damage_bonus) or 0
		end


		if ip.firstmsg then ip.OnFirstPickup = function () ui.msg("\""..ip.firstmsg.."\"") end end

		if not ip.glow then
			if ip.flags[ IF_EXOTIC ] then ip.glow = { 1.0, 0.5, 1.0, 0.8 } end
			if ip.flags[ IF_UNIQUE ] then ip.glow = { 0.5, 1.0, 0.5, 0.8 } end
		end

		if type(ip.missile) == "table" then
			if ip.flags[ IF_SHOTGUN ] then
				ip.missile        = register_shotgun ( "s"..ip.id ) ( ip.missile )
			else
				ip.missile        = register_missile ( "m"..ip.id ) ( ip.missile )
			end
		end

		if type(ip.missile) == "string" then
			ip.missile = core.iif( ip.flags[ IF_SHOTGUN ], shotguns, missiles )[ip.missile].nid
		end

		core.register_resistances( ip )
	end
)

register_award = core.register_storage( "awards", "award" )

register_award_plain = function( id, name, t )
	local aid = id.."_module_award"
	if awards[aid] then return aid end
	t.module = id
	t.mname  = name
	register_award( aid )( t )
	return aid
end

function core.register_resistances( proto )
	local OnCreate = function (self)
		self:add_property( "resist", {} )
		if proto.resist then
			for k,v in pairs( proto.resist ) do
				self.resist[ k ] = v
			end
		end
	end
	proto.OnCreate = core.create_seq_function( OnCreate, proto.OnCreate )
end

function core.resolve_thing_sound( proto, sound_id )
	if proto.sound_id then
		proto["sound_"..sound_id] = proto["sound_"..sound_id] or
			core.resolve_sound_id( proto.id.."."..sound_id, proto.sound_id.."."..sound_id, sound_id )
	else
		proto["sound_"..sound_id] = proto["sound_"..sound_id] or
			core.resolve_sound_id( proto.id.."."..sound_id, sound_id )
	end
end

function core.mod_list_signature( mod_list )
	local modsig = ""
	for c=string.byte("A"),string.byte("Z") do
		if mod_list[string.char(c)] then
			modsig = modsig..mod_list[string.char(c)]
		else
			modsig = modsig.."0"
		end
	end
	return modsig
end

function core.power_duration( base )
	if player.flags[ BF_POWERBONUS ] then
		return math.floor( base * diff[DIFFICULTY].powerfactor * diff[DIFFICULTY].powerbonus )
	else
		return math.floor( base * diff[DIFFICULTY].powerfactor )
	end
end

function core.is_challenge( chal_id )
	return CHALLENGE == chal_id or SCHALLENGE == chal_id
end

function core.proto_weight( proto, weights, one_only )
	local weight = proto.weight
	if not weights then return weight end
	for k,w in pairs( weights ) do
		if proto.flags[ k ] or proto[ k ] or proto.id == k then 
			weight = weight * w 
			if one_only then return weight end
		end
	end
	return weight
end

function core.proto_reqs_met( proto, reqs )
	if not reqs then return true end
	for k,r in pairs( reqs ) do
		local pv   = proto[k]
		local rist = ( type(r) == "table" )
		local pist = ( type(pv) == "table" )

		if rist and r[1] and type( r[1] ) ~= "boolean" then 
			r = table.toset( r ) 
			reqs[k] = r
		end

		if pist then 
			if rist then
				for req,_ in pairs( r ) do
					if not pv[ req ] then return false end
				end
			else
				if not pv[ r ] then return false end
			end
		else
			if rist then 
				if not r[ pv ] then return false end
			else
				if pv ~= r then return false end
			end
		end
	end
	return true
end


core.type_name = {
	[ITEMTYPE_NONE]    = "none",
	[ITEMTYPE_RANGED]  = "ranged",
	[ITEMTYPE_NRANGED] = "natural ranged",
	[ITEMTYPE_ARMOR]   = "armor",
	[ITEMTYPE_MELEE]   = "melee weapon",
	[ITEMTYPE_AMMO]    = "ammo",
	[ITEMTYPE_AMMOPACK]= "ammo pack",
	[ITEMTYPE_PACK]    = "pack",
	[ITEMTYPE_POWER]   = "powerup",
	[ITEMTYPE_BOOTS]   = "boots",
	[ITEMTYPE_TELE]    = "teleporter",
	[ITEMTYPE_LEVER]   = "lever",
}

function core.being_plural( id, amount )
	if amount and amount == 1 then
		return beings[ id ].name
	else
		return beings[ id ].name_plural or beings[ id ].name
	end
end
function core.mod_array_description( mod_array_proto )
	local first = true
	local desc = ""
	local function append(str)
		if first then desc = str else desc = desc.." + "..str end
		first = false
	end

	if mod_array_proto.desc         then append(mod_array_proto.desc) end
	if mod_array_proto.request_id   then append(items[mod_array_proto.request_id].name) end
	if mod_array_proto.request_type then append(core.type_name[mod_array_proto.request_type]) end

	local sig = ""
	for char,val in pairs(mod_array_proto.mods) do
		if val == 1 then
			sig = sig..char
		else
			sig = sig..char..val
		end
	end

	append("("..sig..")")
	return desc
end

function core.ifdiff( min, positive, negative )
	if DIFFICULTY >= min then return positive else return negative end
end

function core.bydiff( entries )
	if DIFFICULTY > #entries then return entries[ #entries ] end
	return entries[DIFFICULTY]
end

function core.less_than_table( value, param )
	for _, v in ipairs( value ) do
		if param < v[1] then return v[2] end
	end
	return value[#value][2]
end


function core.ranged_table( value, param )
	if type( value ) ~= "table" then return value end
	local result = value[1]
	for k, v in pairs( value ) do
		if type( k ) == "table" then
			local min, max = k[1], k[2]
			if not max then 
				if param == min then return v end
			else
				if param >= min and param <= max then result = v end
			end
		end
	end
	return result
end


setmetatable(_G, {
	__newindex = function (_, n)
		error("attempt to write to undeclared variable "..n, 2)
	end,
	__index = function (_, n)
		error("attempt to read undeclared variable "..n, 2)
	end,
})
