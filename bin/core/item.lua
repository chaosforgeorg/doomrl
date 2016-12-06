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
	if not ui.msg_confirm("Are you sure you want to overcharge the "..self.name.."? "..msg, true) then
		ui.msg("Chicken.")
		return false
	end
	self.flags[ IF_DESTROY ]  = true
	self.flags[ IF_NOUNLOAD ] = true
	ui.msg("You overcharge the "..self.name.."!")
	self.name          = "overcharged "..self.name
	return true
end

function item:check_mod_array( nextmod, techbonus )
	if self.flags[ IF_ASSEMBLED ] then return false end
	if not self.flags[ IF_MODIFIED ] then return false end

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

	if not found_mod_array then
		return false
	end

	-- Consider making this string shorter? (e.g. "Special assembly possible! Assemble the "..found_mod_array.name.."?")
	if not ui.msg_confirm("Special assembly possible! Do you want to assemble the "..found_mod_array.name.."?") then return false end
	ui.msg("You assemble the "..found_mod_array.name..".")
	found_mod_array.OnApply(self)
	self.color = LIGHTCYAN
	if techbonus == 2 then
		self.flags[ IF_SINGLEMOD ] = true
	else
		self.flags[ IF_NONMODABLE ] = true
	end
	self.flags[ IF_MODIFIED ] = false
	self.flags[ IF_ASSEMBLED ] = true
	self:clear_mods()
	player:add_assembly( found_mod_array.id )
	-- Maybe we should add something that handles the correct article
	player:add_history("On level @1 he assembled a "..found_mod_array.name.."!")
	return true
end

setmetatable(item,getmetatable(thing))
