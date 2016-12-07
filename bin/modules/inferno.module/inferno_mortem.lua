function inferno.print_mortem(killedby)
  inferno.Statistics.OnMortem()
  inferno.Statistics.calculate()
  inferno.award_medals()
  
  local function p(...)
    player:mortem_print(...)
  end
  
  p(" " .. player.name .. ", level " .. player.explevel .. " " .. klasses[player.klass].name .. ",")
  p(" " .. (inferno.get_killed_by() or killedby or "???") .. " " .. player.mortem_location .. ".")
  p(" He survived " .. statistics.game_time .. " turns.")
  p(" He played for " .. seconds_to_string(math.floor(statistics.real_time)) .. ".")
  p(" " .. diff[DIFFICULTY].description)

  p()
  
  local percentage = 100
  local final_max_kills = inferno.Statistics.get("max_kills")
  local final_kills = inferno.Statistics.get("kills")
  if final_max_kills > 0 then
    percentage = math.floor(100 * final_kills / final_max_kills)
  end
  p(" He killed " .. final_kills .. " out of " .. final_max_kills .. " hellspawn. (" .. percentage .. "%)")

  p()
  
  p("-- Special levels --------------------------------------------")
  p()
  local function short_time_string(seconds)
    local minutes = math.floor(seconds / 60)
	seconds = seconds % 60
	local hours = math.floor(minutes / 60)
	minutes = minutes % 60
	local result = ""
	if hours > 0 then
	  result = tostring(hours) .. "h"
	end
	if minutes > 0 then
	  if minutes < 10 and hours > 0 then
	    result = result .. "0"
	  end
	  result = result .. tostring(minutes) .. "m"
	end
	if seconds < 10 and (hours > 0 or minutes > 0) then
	  result = result .. "0"
	end
	result = result .. tostring(seconds) .. "s"
	return result
  end
  local levs = player._statistics_visited.special or {}
  local bsmnts = player._statistics_visited.basement or {}
  if #levs + #bsmnts == 0 then
    p("  None")
    p()
  else
    local function align(str, len, lr)
      local string_len = string.len(str)
      if string_len == len then
        return str
      elseif string_len > len then
	    return string.sub(str, 1, len)
	  else
	    lr = lr or "left"
		if lr == "left" then
		  return str .. string.rep(" ", len - string_len)
		else
          return string.rep(" ", len - string_len) .. str
		end
	  end
	end
	-----Infernal Sanctuary Complete 1000/1000 9999999 20h20m20s
    p("  Name               Result       Kills   Turns      Time")
    local function print_level(lev_id)
      p("  " .. align(levels[lev_id].name, 18) .. " "
		     .. align(inferno.Statistics.level_result(lev_id), 8) .. " "
	         .. align(inferno.Statistics.get_level("kills", lev_id), 4, "right") .. "/"
		     .. align(inferno.Statistics.get_level("max_kills", lev_id), 4, "right") .. " "
		     .. align(inferno.Statistics.get_level("game_time", lev_id), 7, "right") .. " "
		     .. align(short_time_string(inferno.Statistics.get_level("real_time", lev_id)), 9, "right")
	  )
    end
    if #levs > 0 then
      for _, lev_id in ipairs(levs) do
	    if levels[lev_id].name and inferno.Statistics.get_level("game_time", lev_id) > 0 then
	      print_level(lev_id)
        end
      end
      p()
	end
    if #bsmnts > 0 then
      for _, lev_id in ipairs(bsmnts) do
	    if levels[lev_id].name and inferno.Statistics.get_level("game_time", lev_id) > 0 then
	      print_level(lev_id)
        end
      end
      p()
    end
  end
  
  local awarded = false
  p("-- Awards ----------------------------------------------------")
  p()
  for _, m in ipairs(medals) do
    if player.medals[m.id] then
      p("  " .. m.name)
      p("  -- " .. m.desc)
      p()
      awarded = true
    end
  end
  if not awarded then
    p("  None")
    p()
  end
  
  local function get_pic(c)
    local b = Level.get_being(c)
    if b then
      if b == player then
        return 'X'
      else
        return string.char(b.picture)
      end
    end
    local it = Level.get_item(c)
    if it then
      return string.char(it.picture)
    end
    return cells[Level[c]].asciilow
  end
  p("-- Graveyard -------------------------------------------------")
  p()
  for vy = 1, MAXY do
    local line = "  "
    for vx = math.min(20, math.max(1, player.x - 30)), math.min(20, math.max(1, player.x - 30)) + MAXX - 20 do
      line = line .. get_pic(coord.new(vx, vy))
    end
    p(line)
  end
  p()
  
  local function bonus(val)
    if val < 0 then
      return tostring(val)
    else
      return "+" .. val
    end
  end
  p("-- Statistics ------------------------------------------------")
  p()
  p("  Health " .. player.hp .. "/" .. player.hpmax .. "    Experience " .. player.exp .. "/" .. player.explevel)
  p("  ToHit Ranged " .. bonus(player.tohit) .. "  ToDmg Ranged " .. bonus(player.todamall))
  p("  ToHit Melee  " .. bonus(player.tohitmelee) .. "  ToDmg Melee  " .. bonus(player.todam))
  local affects = {}
  if player:is_affect("berserk") then
    table.insert(affects, "  Berserk")
  end
  if player:is_affect("inv") then
    table.insert(affects, "  Invulnerable")
  end
  if player:is_affect("enviro") then
    table.insert(affects, "  Envirosuit")
  end
  if player:is_affect("light") then
    table.insert(affects, "  Light-Amp Goggles")
  end
  if player:is_affect("invis") then
    table.insert(affects, "  Invisible")
  end
  if #affects > 0 then
    p()
    for _, affect in ipairs(affects) do
      p(affect)
    end
  end
  p()
  
  local function padded(str, size)
    return str .. string.rep(" ", math.max(0, size - string.len(str)))
  end
  p("-- Traits ----------------------------------------------------")
  p()
  p("  Class : " .. klasses[player.klass].name)
  p()
  for i = 1, traits.__counter do
    local value = player:get_trait(i)
    if value > 0 then
      p("    " .. padded(traits[i].name, 16) .. " (Level " .. value .. ")")
    end
  end
  if player.explevel > 1 then
    p()
    p("  " .. player:get_trait_hist())
  end
  p()
  
  local function letter(n)
    return string.char(string.byte("a") + n)
  end
  local slot_name = {"[ Armor      ]", "[ Weapon     ]", "[ Boots      ]", "[ Prepared   ]"}
  p("-- Equipment -------------------------------------------------")
  p()
  for i = 0, MAX_EQ_SIZE - 1 do
    local it = player.eq[i]
    if it then
      p("    [" .. letter(i) .. "] " .. slot_name[i + 1] .. "   " .. it.desc)
    else
      p("    [" .. letter(i) .. "] " .. slot_name[i + 1] .. "   nothing")
    end
  end
  p()
  
  p("-- Inventory -------------------------------------------------")
  p()
  
  local items = {}
  for it in player.inv:items() do
    table.insert(items, {itype = it.itype, nid = it.__proto.nid, desc = it.desc})    
  end
  table.sort(items, function(a,b)
    if (a.itype ~= b.itype) then
      return a.itype < b.itype
    else
      return a.nid < b.nid end
    end
  )
  for k,v in ipairs(items) do
    p("    [" .. letter(k - 1) .. "] " .. v.desc)
  end
  p()
  
  local resistance_present = false
  local function print_resistance( name )
    local res_id   = _G[ "RESIST_"..string.upper( name ) ]
    local internal = player.resistance[res_id]
    local torso    = player:get_total_resistance(res_id, TARGET_TORSO)
    local feet     = player:get_total_resistance(res_id, TARGET_FEET)
    if internal == 0 and torso == 0 and feet == 0 then return end
    player:mortem_print( "    "..padded( name, 10 ).." - "..
    "internal "..padded( internal.."%", 5 ).." "..
    "torso "..padded( torso.."%", 5 ).." "..
    "feet "..padded( feet.."%", 5 )
    )
    resistance_present = true
  end
  p("-- Resistances -----------------------------------------------")
  p()
  print_resistance("Bullet")
  print_resistance("Melee")
  print_resistance("Shrapnel")
  print_resistance("Acid")
  print_resistance("Fire")
  print_resistance("Plasma")
  if not resistance_present then
    player:mortem_print("    None")
  end
  p()
  
  p("-- Kills -----------------------------------------------------")
  p()
  for i = 1, beings.__counter do
    local kills = kills.get(i)
    if kills > 0 then
      if kills == 1 then
        p("    1 " .. beings[i].name)
      else
        p("    " .. kills .. " " .. beings[i].name_plural)
      end
    end
  end
  p()
  
  p("-- History ---------------------------------------------------")
  p()
  
  for _, v in ipairs(player.history) do
    local m = v --inferno.process_history(v)
    if m then
      p("  " .. m)
    end
  end
  p()
  
  p("-- Messages --------------------------------------------------")
  p()
  for i = 15, 0, -1 do
    local msg = ui.msg_history(i)
    if msg then
      p(" " .. msg)
    end
  end
  p()
  
  p("--------------------------------------------------------------")
  
end

do
  local usual_add_history = player.add_history
  rawset(player, "add_history", function(self, m)
    if m then
      local unique_level, unique_name = string.match(m, "On level (%d+) he found the (.+)!")
      if unique_level and string.sub(Level.id, 1, 5) ~= "level" then
        local phrase = levels[Level.id].find_phrase
        if phrase then
          m = string.gsub(phrase, "@1", unique_name)
        end
      end
    end
    usual_add_history(player, m)
  end)
end

--[[
do
  local level_identifier
  function inferno.process_history(m)
    local level_override = string.match(m, "__LEVEL__:(.*)")
    if level_override then
      level_identifier = level_override
      return
    end
    local unique_level, unique_name = string.match(m, "On level (%d+) he found the (.+)!")
    if unique_level then
      return "UNIQUE REPLACE " .. unique_level .. " " .. unique_name
    end
    return m
  end
end
]]

-- This is a (portable) hack to froce the print_mortem to receive the killedby argument
do
  local hook_table = _G[module.id]
  local usual_doomrl_print_mortem = DoomRL.print_mortem
  DoomRL.print_mortem = function(killedby)
    local usual_module_print_mortem = hook_table.print_mortem
    hook_table.print_mortem = function()
      return usual_module_print_mortem(killedby)
    end
    return usual_doomrl_print_mortem(killedby)
  end
end