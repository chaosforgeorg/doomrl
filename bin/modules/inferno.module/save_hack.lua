core.declare("SaveHack", {})

local key = "_save_hack_data_"

local module = false

function SaveHack.initialize(module_id)
  if inferno.cheat then
    player:add_history("SaveHack initialized!")
  end
  if not rawget(_G, module_id) then
    error("Module " .. module_id .. " is not declared!")
  end
  module = _G[module_id]
  module.OnExit = create_seq_function(module.OnExit, SaveHack.OnExit)
  module.OnGenerate = create_seq_function(SaveHack.OnEnter, module.OnGenerate)
  local function fix_levels()
    for _, level in pairs(levels) do
      level.Create = create_seq_function(SaveHack.OnEnter, level.Create)
    end
  end
  --module.OnCreateEpisode = create_seq_function(module.OnCreateEpisode, fix_levels)
  fix_levels()
end

do
  local slots = {SLOT_ARMOR, SLOT_WEAPON, SLOT_PREPARED, SLOT_BOOTS}
  
  function SaveHack.OnExit()
    if not player:has_property(key) then
      player:add_property(key, false)
    end
    local saved = {}
    saved.eq = {}
    for _, slot in ipairs(slots) do
      if player.eq[slot] then
        saved.eq[slot] = player.eq[slot]:serialize()
        local proto = player.eq[slot].__proto
        local usual_OnRemove = proto.OnRemove
        proto.OnRemove = function() end
        player.eq[slot] = nil
        proto.OnRemove = usual_OnRemove
      end
    end
    saved.inv = {}
    for i in player.inv:items() do
      table.insert(saved.inv, i:serialize())
    end
    player.inv:clear()
    player[key] = saved
  end

  function SaveHack.OnEnter()
    if player:has_property(key) then
      local saved = player[key]
      for _, slot in ipairs(slots) do
        if saved.eq[slot] then
          local i = item.load(saved.eq[slot])
          local usual_OnEquip = i.__proto.OnEquip
          i.__proto.OnEquip = function() end
          player.eq[slot] = i
          i.__proto.OnEquip = usual_OnEquip
        end
      end
      for _, i in ipairs(saved.inv) do
        player.inv:add(item.load(i))
      end
      player:remove_property(key)
    end
    if module.OnLoad then
      module.OnLoad()
    end
  end
  
end