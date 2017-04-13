Items({
  name = "stealth armor",
  id = "ustealtharmor",
  color = LIGHTMAGENTA,
  sprite = SPRITE_ARMOR,
  coscolor = {0.2, 0.2, 0.2, 0.5},
  level = 8,
  weight = 3,
  desc = "This armor blends into the shadows.",
  type = ITEMTYPE_ARMOR,
  armor = 1,
  knockmod = -5,
  movemod = 5,
  dodgemod = 10,
  flags = {IF_EXOTIC},
  OnEquip = function(self, being)
    if being == player then
      being.stealth = being.stealth + 2
    end
  end,
  OnRemove = function(self, being)
    if being == player then
      being.stealth = being.stealth - 2
    end
  end,
})

--[[
do
  Items({
    name = "Tyrfing",
    id = "utyrfing",
    color = LIGHTGREEN,
    sprite = 0,
    psprite = 0,
    level = 16,
    weight = 1,
    group = "weapon-melee",
    desc = "A powerful sword said to bring death to its wielder.",
    type = ITEMTYPE_MELEE,
    damage = "0d0",
    damagetype = DAMAGE_IGNOREARMOR,
    
    OnPickup = function(self, being)
      if not self:has_property("curse") then
        self:add_property("curse", 0)
        self.name = self.proto.name .. " (0)"
      end
    end,
  
    OnHitBeing = function(self, being, target)
      ui.msg("hello!")
    end,
  })
end
]]

Items({
  name = "Lava Boots",
  id = "uhboots",
  color = LIGHTGREEN,
  sprite = SPRITE_BOOTS,
  coscolor = {1.0, 0.0, 0.0, 1.0},
  level = 16,
  weight = 2,
  desc = "These boots are warm to the touch.",
  type = ITEMTYPE_BOOTS,
  armor = 12,
  knockmod = 0,
  movemod = 50,
  flags = {IF_UNIQUE, IF_NODURABILITY},
  OnEquip = function(self, being)
    being:msg("The ground beneath your feet begins to boil.")
  end,
  OnEquipTick = function(self, being)
    local current_position = being:get_position()
    if not cells[Level[current_position]].flag_set[CF_CRITICAL] then
      Level[current_position] = "lava"
    end
  end
})

-- Filling a niche
Items({
  name = "Dagronslayer",
  id = "udagron",
  color = LIGHTGREEN,
  sprite = SPRITE_DRAGON,
  psprite = SPRITE_PLAYER_DRAGON,
  level = 16,
  weight = 1,
  type = ITEMTYPE_MELEE,
  damage = "8d8",
  damagetype = DAMAGE_MELEE,
  group = "weapon-melee",
  desc = "It was called the Dagronslayer, because it slayed dagrons.",
  flags = {
    IF_UNIQUE,
    IF_HALFKNOCK,
  },
})

-- For cheaters only
Items({
  name = "Homing Staff",
  id = "hstaff",
  color = BLUE,
  sprite = SPRITE_STAFF,
  level = 200,
  weight = 0,
  type = ITEMTYPE_PACK,
  desc = "Now this is a interesting piece of equipment...",
  ascii = "?",
  OnUse = function(self, being)
    if not being:is_player() then
      return false
    end
    being:play_sound("soldier.phase")
    ui.msg("You feel yanked in an non-existing direction!")
    being:phase("stairs")
    being.scount = being.scount - 1000
    return false
  end,
})

-- For cheaters only
Items({
  name = "Testing Staff",
  id = "tstaff",
  color = YELLOW,
  sprite = SPRITE_STAFF,
  level = 200,
  weight = 0,
  type = ITEMTYPE_PACK,
  desc = "Now this is a interesting piece of equipment...",
  ascii = "?",
  OnCreate = function(self)
    self:add_property("t", false)
    self:add_property("data", false)
  end,
  OnUse = function(self, b)
  --[[
    if not self.t then
      self.data = inferno.Generator.serialize()
      inferno.Generator.clear()
    else
      inferno.Generator.load(self.data)
      self.data = false
    end
    ]]
    if self.t then
      player:win()
    else
      for b in Level.beings() do
        if b ~= player then b:kill() end
      end
    end
    --[[
	for _, stat in ipairs(inferno.Statistics.statistics) do
	  ui.msg(stat.id .. ":" .. inferno.Statistics.get_level(stat.id))
	end
	]]
    --[[
    for b in Level.beings() do
      if b ~= player then
        b:kill()
      end
    end
    --]]
    self.t = not self.t
    return false
  end,
})

local function is_assembly(item, assembly_name)
  return item.name == assembly_name or item.name == "modified " .. assembly_name
end

-- Currently, just for armor/boots
local function get_slot(item_proto)
  local type = item_proto.type
  if type == ITEMTYPE_BOOTS then
    return SLOT_BOOTS
  elseif type == ITEMTYPE_ARMOR then
    return SLOT_ARMOR
  end
end

local function register_assembly_hooks(item_id, assembly_name, OnEquip, OnRemove)
  local item = items[item_id] -- proto
  if OnEquip then
    items[item_id].OnEquip = create_seq_function(item.OnEquip, function(self, being)
      if is_assembly(self, assembly_name) then
        OnEquip(self, being)
       end
    end)
  end
  if OnRemove then
    items[item_id].OnRemove = create_seq_function(item.OnRemove, function(self, being)
      if is_assembly(self, assembly_name) then
        OnRemove(self, being)
      end
    end)
  end
end

local function scout_armor_OnEquip(self, being)
  being:msg("Targeting system online!")
  being.toHit = being.toHit + 2
end

local function scout_armor_OnRemove(self, being)
  being.toHit = being.toHit - 2
end

ModArray({
  name = "scout armor",
  mods = {A = 1, P = 1},
  request_id = "garmor",
  OnApply = function(base_item)
    -- cheat cheat cheat
    base_item.name = "scout armor"
    base_item:add_property("scout_armor", true)
    base_item.knockmod = 0
    base_item.movemod = 5
    base_item.armor = 2
    scout_armor_OnEquip(base_item, player)
  end,
})

register_assembly_hooks("garmor", "scout armor", scout_armor_OnEquip, scout_armor_OnRemove)

local function powered_exoskeleton_OnEquip(self, being)
  being:msg("You feel much stronger!")
  being.todam = being.todam + 6
end

local function powered_exoskeleton_OnRemove(self, being)
  being.todam = being.todam - 6
end

ModArray({
  name = "powered exoskeleton",
  mods = {B = 2},
  request_id = "barmor",
  OnApply = function(base_item)
    base_item.name = "powered exoskeleton"
    base_item.armor = 2
    if base_item.maxdurability == 100 then
      base_item.maxdurability = 200
      base_item.durability = base_item.durability + 100
    end
    base_item.movemod = -10
    powered_exoskeleton_OnEquip(base_item, player)
  end,
})

register_assembly_hooks("barmor", "powered exoskeleton", powered_exoskeleton_OnEquip, powered_exoskeleton_OnRemove)

local function shield_boots_OnEquip(self, being)
  being:msg("A protective field forms around you.")
  being.armor = being.armor + 1
end

local function shield_boots_OnRemove(self, being)
  being.armor = being.armor - 1
end

ModArray({
  name = "shield boots",
  mods = {B = 1, P = 1},
  request_id = "pboots",
  OnApply = function(base_item)
    base_item.name = "shield boots"
    base_item.armor = 4
    base_item.movemod = -15
    base_item.knockmod = -25
    shield_boots_OnEquip(base_item, player)
  end,
})

register_assembly_hooks("pboots", "shield boots", shield_boots_OnEquip, shield_boots_OnRemove)

local function enhanced_shield_boots_OnEquip(self, being)
  being:msg("A protective field forms around you.")
  being.armor = being.armor + 2
end

local function enhanced_shield_boots_OnRemove(self, being)
  being.armor = being.armor - 2
end

ModArray({
  name = "enhanced shield boots",
  mods = {B = 1, P = 2},
  level = 1,
  request_id = "psboots",
  OnApply = function(base_item)
    base_item.name = "enhanced shield boots"
    base_item.armor = 8
    if base_item.maxdurability == 100 then
      base_item.maxdurability = 200
      base_item.durability = base_item.durability + 100
    end
    base_item.movemod = -25
    base_item.knockmod = -50
    enhanced_shield_boots_OnEquip(base_item, player)
  end,
})

register_assembly_hooks("psboots", "enhanced shield boots", enhanced_shield_boots_OnEquip, enhanced_shield_boots_OnRemove)