-- Some statistics are also tracked by the Episode module.

inferno.Statistics = {}

-- This should be called once per game to add properties to the player.
function inferno.Statistics.initialize()
  player:add_property("secrets_found", 0)
  player:add_property("corpse_kills", 0)
  player:add_property("worn_armor", false)
  player:add_property("killspree", 0)
  player:add_property("kill_time_list", {})
  player:add_property("assemblies", 0)
  player:add_property("sniper_kills", 0)
  player:add_property("_statistics_add", {})
  player:add_property("_statistics_levels", {})
  player:add_property("_statistics_visited", {})
  player:add_property("_statistics_completed", {})
  player:add_property("extra_max_kills", 0)
end

local function level_id()
  local id = Level.id
  if not levels[Level.id] then
    local level_number = tonumber(string.sub(Level.id, 6))
    id = player.episode[level_number].script or id
  end
  return id
end

inferno.Statistics.statistics = {}

function inferno.Statistics.register_statistic(stat)
  table.insert(inferno.Statistics.statistics, stat)
  inferno.Statistics.statistics[stat.id] = stat
end

function inferno.Statistics.get(stat_id)
  local inherent = 0
  if not inferno.Statistics.statistics[stat_id] then
    error("Statistic does not exist: " .. stat_id)
  end
  local get = inferno.Statistics.statistics[stat_id].get
  if get then
    inherent = get()
  end
  local added = player._statistics_add[stat_id] or 0
  return inherent + added
end

function inferno.Statistics.get_level(stat_id, lev_id)
  local level_id = lev_id or level_id()
  local lstats = player._statistics_levels[level_id]
  if not lstats then
    return 0
  end
  local is_open = lstats._open
  local result
  if is_open then
    inferno.Statistics.close_level(level_id)
  end
  result = lstats[stat_id]
  if is_open then
    inferno.Statistics.open_level(level_id)
  end
  return result
end

function inferno.Statistics.add(stat_id, amt)
  amt = amt or 1
  local initial = player._statistics_add[stat_id] or 0
  player._statistics_add[stat_id] = initial + amt
end

function inferno.Statistics.level_result(id)
  local level_id = id or level_id()
  local lstats = player._statistics_levels[level_id]
  return lstats._result or "???"
end

function inferno.Statistics.open_level(id, current)
  if current == nil then
    current = (not id) or (id == level_id())
  end
  local level_id = id or level_id()
  core.log("open_level(" .. level_id .. ")")
  local lstats = player._statistics_levels[level_id]
  --ui.msg("level opened: " .. level_id)
  if not lstats then
    lstats = {}
    player._statistics_levels[level_id] = lstats
  end
  lstats._start = {}
  for _, stat in ipairs(inferno.Statistics.statistics) do
    lstats._start[stat.id] = inferno.Statistics.get(stat.id)
  end
  if current then
    if levels[level_id] and levels[level_id].type then
      local type = levels[level_id].type
      local visited = player._statistics_visited[type] or {}
      player._statistics_visited[type] = visited
      table.insert(visited, level_id)
    end
  end
  lstats._open = true
end

function inferno.Statistics.close_level(id, current)
  if current == nil then
    current = (not id) or (id == level_id())
  end
  local level_id = id or level_id()
  local lstats = player._statistics_levels[level_id]
  core.log("close_level(" .. level_id .. ")")
  for _, stat in ipairs(inferno.Statistics.statistics) do
    lstats[stat.id] = (lstats[stat.id] or 0) + inferno.Statistics.get(stat.id) - lstats._start[stat.id]
  end
  if current then
    local result = "???"
    if levels[level_id] and levels[level_id].IsCompleted then
      if levels[level_id].IsCompleted() then
	    result = "Complete"
	  else
	    result = "Escaped"
	  end
    else
      if lstats.kills == lstats.max_kills then
	    result = "Complete"
	  else
	    result = "Escaped"
	  end
    end
    if player.hp <= 0 then
      result = "Death"
    end
    if result == "Complete" and levels[level_id] and levels[level_id].type then
      local type = levels[level_id].type
      local completed = player._statistics_completed[type] or {}
      player._statistics_completed[type] = completed
      table.insert(completed, level_id)
    end
    lstats._result = result
  end
  lstats._open = false
end

inferno.Statistics.register_statistic({
  id = "kills",
  get = function()
    return statistics.kills
  end,
})

inferno.Statistics.register_statistic({
  id = "max_kills",
  get = function()
    return statistics.max_kills
  end,
})

inferno.Statistics.register_statistic({
  id = "damage_taken",
  get = function()
    return statistics.damage_taken
  end,
})

inferno.Statistics.register_statistic({
  id = "game_time",
  get = function()
    return statistics.game_time
  end,
})

inferno.Statistics.register_statistic({
  id = "real_time",
  get = function()
    return statistics.real_time
  end,
})

inferno.Statistics.register_statistic({
  id = "tactical_clears",
})

inferno.Statistics.register_statistic({
  id = "assemblies",
})

function inferno.Statistics.OnEnter()
  player.corpse_kills = player.corpse_kills + inferno.Statistics.count_corpses()
end

function inferno.Statistics.OnPreCreate(level_id)
  inferno.Statistics.open_level(level_id, true)
end

function inferno.Statistics.OnExit()
  if not levels[Level.id] then
    local cleared = inferno.Statistics.get("kills") == inferno.Statistics.get("max_kills")
    local no_damage = inferno.Statistics.get("damage_taken") == 0
    if cleared and no_damage then
      inferno.Statistics.add("tactical_clears")
    end
  end
  player.corpse_kills = player.corpse_kills - inferno.Statistics.count_corpses()
  inferno.Statistics.close_level()
end

function inferno.Statistics.OnRestoreBeing(b)
  inferno.Statistics.add("max_kills", -1)
end

function inferno.Statistics.OnMortem()
  inferno.Statistics.close_level()
end

function inferno.Statistics.OnTick() -- TODO: move to a different hook
  if player.eq.armor then
    player.worn_armor = player.eq.armor.id
  end
end

function inferno.Statistics.OnKill()
  if not Level.flags[LF_NUKED] then -- TODO: improve detection
    table.insert(player.kill_time_list, core.game_time())
  end
end

-- Overload player:assembled_item to count assemblies.
do
  local usual_assembled_item = player.assembled_item
  player.assembled_item = function(self, mod_array_id)
    inferno.Statistics.add("assemblies", 1)
    return usual_assembled_item(self, mod_array_id)
  end
end

-- For sniper kills, we need the flexibility of beings' OnDie hooks.
do
  for index = 1, beings.__counter do
    local b_proto = beings[index]
    if b_proto then
      b_proto.OnDie = create_seq_function(b_proto.OnDie, function(self)
        if self ~= player and self:distance_to(player) > 8 then
          player.sniper_kills = player.sniper_kills + 1
        end
        if b_proto.corpse and b_proto.corpse ~= 0 and cells[b_proto.corpse].flag_set[CF_CORPSE] then
          player.corpse_kills = player.corpse_kills + 1
        end
      end)
    end
  end
end

-- Resurrection needs to be accounted for in corpse_kill counting.

do
  local usual_resurrect = being.ressurect
  being.ressurect = function(...)
    local count = 0
    for b in Level.beings() do -- TODO: count corpses?
      count = count - 1
    end
    local result = usual_resurrect(...)
    for b in Level.beings() do
      count = count + 1
    end
    player.corpse_kills = player.corpse_kills - count
    return result
  end
end

function inferno.Statistics.count_corpses()
  local count = 0
  for c in area.FULL_SHRINKED() do
    if cells[Level[c]].flag_set[CF_CORPSE] then
      count = count + 1
    end
  end
  return count
end

function inferno.Statistics.OnRespawn(b) -- TODO: Work with N!? ... OnCreateBeing
  player.corpse_kills = player.corpse_kills - 1
end

-- For some statistics, it makes sense to calculate them lazily here.

function inferno.Statistics.calculate()
  inferno.Statistics.melee_kills = inferno.Statistics.calculate_kills(
    function(iid)
      return iid == 0 or items[iid] and items[iid].type == ITEMTYPE_MELEE
    end,
    nil)
  inferno.Statistics.pistol_kills = inferno.Statistics.calculate_kills(
    function(iid)
      return items[iid] and items[iid].flag_set[IF_PISTOL]
    end,
    nil)
  inferno.Statistics.shotgun_kills = inferno.Statistics.calculate_kills(
    function(iid)
      return items[iid] and items[iid].flag_set[IF_SHOTGUN]
    end,
    nil)
  inferno.Statistics.chaintype_kills = inferno.Statistics.calculate_kills(
    function(iid)
      return items[iid] and items[iid].type == ITEMTYPE_RANGED and items[iid].group == "weapon-chain"
    end,
    nil)
  inferno.Statistics.plasmatype_kills = inferno.Statistics.calculate_kills(
    function(iid)
      return items[iid] and items[iid].type == ITEMTYPE_RANGED and (items[iid].group == "weapon-plasma" or items[iid].group == "weapon-bfg")
    end,
    nil)
  inferno.Statistics.calculate_killspree()
end

function inferno.Statistics.calculate_kills(item_cond, being_cond)
  local count = 0
  if not item_cond and not being_cond then
    return statistics.kills -- Only works in mortem
  elseif not item_cond then
    for bid = 1, beings.__counter do
      if being_cond(bid) then
        for iid = 0, items.__counter do
          count = count + kills.get(bid, iid)
        end
      end
    end
  else
    for iid = 0, items.__counter do
      if item_cond(iid) then
        for bid = 1, beings.__counter do
          if not being_cond or being_cond(bid) then
            count = count + kills.get(bid, iid)
          end
        end
      end
    end
  end
  return count
end

function inferno.Statistics.hydra_queen_pistol_check()
  local hydraq_nid = beings.hydraq.nid
  local hydraq_kills = inferno.Statistics.calculate_kills(
    nil,
    function(bid)
      return bid == hydraq_nid
    end)
  local hydraq_pistol_kills = inferno.Statistics.calculate_kills(
    function(iid)
      return items[iid] and items[iid].flag_set[IF_PISTOL]
    end,
    function(bid)
      return bid == hydraq_nid
    end)
  return hydraq_kills == hydraq_pistol_kills
end

function inferno.Statistics.calculate_killspree()
  local list = player.kill_time_list
  local head = 0
  local tail = 0
  local current_time = 0
  local length = #list
  local best_spree = 0
  local current_spree = 0
  local window_size = 50
  while head < length do
    head = head + 1
    current_spree = current_spree + 1
    current_time = list[head]
    while list[tail + 1] < current_time - window_size do
      tail = tail + 1
      current_spree = current_spree - 1
    end
    best_spree = math.max(best_spree, current_spree)
  end
  player.killspree = best_spree
end