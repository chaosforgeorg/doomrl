table.merge( item, thing )

function item:is_damaged()
	if self.flags[ IF_NOREPAIR ] then return false end
	return self.durability < self.maxdurability
end

function item:fix( amount )
	if amount == nil then
		self.durability = self.maxdurability
		return true
	else
		self.durability = math.min(self.maxdurability, self.durability + amount)
		return not self:is_damaged()
	end
end

function item:get_mods()
	local mods = {}
	for c=string.byte("A"),string.byte("Z") do
		local count = self:get_mod(string.char(c))
		if count > 0 then
			mods[string.char(c)] = count
		end
	end
	return mods
end

function item:get_mod_ids()
	local mods = {}

	local function find( mod_letter )
		for _,i in ipairs( items ) do
			if i.mod_letter == mod_letter then
				return i.id
			end
		end
		return nil
	end

	for c=string.byte("A"),string.byte("Z") do
		local count = self:get_mod(string.char(c))
		if count > 0 then
			local id = find( string.char(c) )
			if id then table.insert( mods, id ) end
		end
	end
	return mods
end

function item:can_overcharge( msg )
	if self.flags[ IF_DESTROY ] then
		ui.msg("The "..self.name.." is already overcharged!")
		return false
	end
	if self.ammo ~= self.ammomax then
		ui.msg("You need a full magazine to overcharge the "..self.name.."!")
		return false
	end
	if not ui.confirm("Are you sure you want to overcharge the "..self.name.."? "..msg) then
		ui.msg("Chicken.")
		return false
	end
	self.flags[ IF_DESTROY ]  = true
	self.flags[ IF_NOUNLOAD ] = true
	ui.msg("You overcharge the "..self.name.."!")
	self.name          = "overcharged "..self.name
	return true
end

function item:find_mod_array( nextmod, techbonus )
	if self.flags[ IF_ASSEMBLED ] then return nil end
	if not self.flags[ IF_MODIFIED ] then return nil end

	local function match( sig,mod_array_proto )
		if sig ~= mod_array_proto.sig then return false end
		if mod_array_proto.request_id and mod_array_proto.request_id ~= self.id then return false end
		if mod_array_proto.request_type and mod_array_proto.request_type ~= self.itype then return false end
		if mod_array_proto.Match and not mod_array_proto.Match(self) then return false end
		if mod_array_proto.level and mod_array_proto.level > techbonus then return false end
		return true
	end


	local mods = self:get_mods()
	if mods[nextmod] then
		mods[nextmod] = mods[nextmod] + 1
	else
		mods[nextmod] = 1
	end
	local modsig = core.mod_list_signature( mods )


	local found_mod_array = nil
	for _,ma in ipairs(mod_arrays) do
		if match(modsig,ma) then
			found_mod_array = ma
			break
		end
	end

	return found_mod_array
end

function item:apply_mod_array( ma )
	if not ma then return end
	ma.OnApply(self)
	self.color = LIGHTCYAN
	self.flags[ IF_MODIFIED ] = false
	self.flags[ IF_ASSEMBLED ] = true
	self:clear_mods()
	player:add_assembly( ma.id )
	player:add_history("On level @1 he assembled a "..ma.name.."!")
end

function item:reset_resistances()
	if self.__proto.resist then
		self.resist.bullet   = (self.__proto.resist.bullet or 0)
		self.resist.shrapnel = (self.__proto.resist.shrapnel or 0)
		self.resist.melee    = (self.__proto.resist.melee or 0)
		self.resist.fire     = (self.__proto.resist.fire or 0)
		self.resist.acid     = (self.__proto.resist.acid or 0)
		self.resist.plasma   = (self.__proto.resist.plasma or 0)
	else
		self.resist.bullet   = 0
		self.resist.shrapnel = 0
		self.resist.melee    = 0
		self.resist.fire     = 0
		self.resist.acid     = 0
		self.resist.plasma   = 0
	end		
end

function item:get_lever_description( full, good )
	full = full or self.__proto.desc
	good = good or self.__proto.good
	if player.flags[ BF_LEVERSENSE2 ] then return "lever ("..full..")" end
	if player.flags[ BF_LEVERSENSE1 ] then return "lever ("..good..")" end
	return "lever"
end

setmetatable(item,getmetatable(thing))
