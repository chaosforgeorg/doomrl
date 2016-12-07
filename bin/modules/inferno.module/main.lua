core.declare("inferno", {})

--inferno.cheat = true

--inferno.debug = true

--inferno._noinclude = true

--inferno.no_acheron = true

--inferno.vision_cheat = true

--inferno.debug_intuition = true

--inferno.force_level_type = "city"

--inferno.debug_spec_level = "WAVES"

--inferno.debug_basement = "basement_tide"

--inferno.debug_being = "spectre"

if not rawget(_G, "DIFFICULTY") then
  rawset(_G, "DIFFICULTY", player.difficulty)
end

local path = "inferno:"

require(path .. "lib_item")
require(path .. "lib_being")
require(path .. "lib_level")
require(path .. "lib_serialize")
require(path .. "lib_igen")
require(path .. "inferno_animation")
require(path .. "inferno_cells")
require(path .. "generator_styles")
require(path .. "lurk_ai")
require(path .. "inferno_util")
require(path .. "inferno_ai")
require(path .. "inferno_items")
require(path .. "inferno_lever")
require(path .. "inferno_invisibility")
require(path .. "inferno_beings")
require(path .. "inferno_groups")
require(path .. "inferno_statistics")
require(path .. "inferno_medals")
require(path .. "inferno_mortem")
require(path .. "level_welcome")
require(path .. "level_hellkeep")
require(path .. "level_acidpits")
require(path .. "level_blood")
require(path .. "level_shadow")
require(path .. "level_waves")
require(path .. "level_singularity")
require(path .. "level_river")
require(path .. "level_witch")
require(path .. "level_tech")
require(path .. "level_escape")
require(path .. "inferno_tweaks")
require(path .. "generator_main")
require(path .. "generator_level_types")
require(path .. "generator_rooms")
require(path .. "generator_events")
require(path .. "generator_basement")
require(path .. "generator_utility")
require(path .. "feature_lever")
require(path .. "feature_vault")
require(path .. "feature_crusher")
require(path .. "feature_city")
require(path .. "feature_cover")
require(path .. "feature_corpse")
require(path .. "feature_warp")
require(path .. "feature_shambler")
require(path .. "feature_backpack")
require(path .. "basement_unholy")
require(path .. "basement_prison")
require(path .. "basement_dark")
require(path .. "basement_babylon")
require(path .. "basement_warpcore")
require(path .. "basement_crossing")
require(path .. "basement_carnival")
require(path .. "basement_antenora")
require(path .. "basement_imps")
require(path .. "basement_hanged")
require(path .. "basement_train")
require(path .. "basement_volcano")
require(path .. "basement_halls")
require(path .. "basement_throne")
require(path .. "basement_tide")
require(path .. "inferno_sound")
if inferno._noinclude then
  require(path .. "_noinclude/secret")
else
  require(path .. "inferno_secret")
end
require(path .. "save_hack")

inferno.test = false

Invisibility.register()
inferno.load_levers()
inferno.make_groups()

function DoomRL.award_medals() end -- TODO: still needed?

function cells.rstairs.OnExit(x, y)
  -- Setting .number to 0 is a hack to suppress
  -- the level enter message for bonus levels.
  player.episode[player.episode_index].number = 0
  -- The style gets reloaded for the special level,
  -- so we set it to the appropriate level style
  local style = levels[Level.special_exit].style
  if style then
    player.episode[player.episode_index].style = style
  end
  player:exit(Level.special_exit)
end
function cells.stairs.OnExit(x, y)
  player.episode_index = player.episode_index + 1
  player:exit()
end

-- Custom hook, interfaces with SaveHack; called gratuitously
function inferno.OnLoad()
  -- Loading these later 
  inferno.load_beings()
  inferno.Sound.load()
end

function inferno.OnCreateEpisode()
  -- General setup
  inferno.OnLoad()
  player.episode = {}
  for level = 1, 25 do
    local level_proto = {style = 3, number = level, name = "Hell", danger = level}
    if math.random(7) == 1 then
      level_proto.style = 2
    end
    if math.random(7) == 1 then
      level_proto.style = 1
    end
    table.insert(player.episode, level_proto)
  end
  player.episode[1] = {script = "HELLKEEP", style = 3}
  if inferno.debug and inferno.debug_spec_level then
    player.episode[2] = {script = inferno.debug_spec_level, style = levels[inferno.debug_spec_level].style or 1}
  end
  if not (inferno.debug and inferno.no_acheron) then
    player.episode[15] = {script = "RIVER", style = 3}
  end
  player.episode[25] = {script = "ESCAPE", style = 3}

  player.episode[4 + math.random(2)].special = "ACIDPITS"
  player.episode[7].special = "BLOOD"
  player.episode[8 + math.random(5)].special = "SHADOW"
  local temp = 10 + math.random(4)
  if player.episode[temp].special then
    temp = temp + 1
  end
  player.episode[temp].special = "SINGULARITY"
  player.episode[16 + math.random(2)].special = "WITCH"
  player.episode[20].special = "WAVES"
  player.episode[20 + math.random(3)].special = "TECH"
  
  table.insert(player.episode, 1, {script = "WELCOME", style = 3})
  
  statistics.bonus_levels_count = 7
  
  player:add_property("turns_on_level", 0)
  player:add_property("kills", 0)
  player:add_property("damage_on_start", 0)
  player:add_property("mortem_location", false)
  player:add_property("killed_by_stack", {})
  player:add_property("difficulty", DIFFICULTY)
  player:add_property("victory", false)
  player:add_property("episode_index", 1)
  player:add_property("completed_levels", {}) -- Lazy so far
  player:add_property("level_statistics", {})
  inferno.Statistics.initialize()
  inferno.Generator.initialize_rooms()
  inferno.Generator.initialize_events()
  inferno.Generator.initialize_basements()
  Invisibility.initialize()
end

function inferno.OnPreCreate(level_id)
  inferno.Statistics.OnPreCreate(level_id)
end

function inferno.OnGenerate()
  inferno.OnPreCreate(Level.id)
  inferno.Generator.generate()
end

for _, level in pairs(levels) do
  level.Create = create_seq_function(function()
    inferno.OnPreCreate(level.id)
  end, level.Create)
end

function inferno.push_killed_by(s)
  table.insert(player.killed_by_stack, s)
end

function inferno.pop_killed_by()
  player.killed_by_stack[#player.killed_by_stack] = nil
end

function inferno.get_killed_by()
  return player.killed_by_stack[#player.killed_by_stack]
end

-- TODO: welcome level
function inferno.FirstLevelLoadPlayer()
  local it
  
  if player:has_property("equipment_loadout") and player.equipment_loadout then
    local loadout = inferno.loadouts[player.equipment_loadout]
    for key, value in pairs(loadout.eq) do
      player.eq[key] = value
    end
    for _, i in ipairs(loadout.inv) do
      if type(i) == "table" then
        it = item.new(i[1])
        for key, value in pairs(i) do
          if type(key) == "string" then
            it[key] = value
          end
        end
        i = it
      end
      player.inv:add(i)
    end
  end
  
  if klasses[player.klass].id == "technician" then
    player.inv:add("mod_tech")
  end
  
  if inferno.cheat then
    player:add_history("He was a cheater!")
    it = item.new("urailgun")
    it.flags[IF_NOAMMO] = true
    player.inv:add(it)
    it = item.new("ashotgun")
    it.flags[IF_NOAMMO] = true
    it.flags[IF_PUMPACTION] = false
    player.inv:add(it)
    it = item.new("bazooka")
    it.flags[IF_NOAMMO] = true
    player.inv:add(it)
    it = item.new("udagron")
    it.damage_dice = 25
    it.damage_sides = 10
    player.inv:add(it)
    player.inv:add("nuke")
    player.inv:add("hstaff")
    player.inv:add("tstaff")
    player.inv:add("upack_duplicate")
    
    player.inv:add("mod_tech")
    player.inv:add("mod_agility")
    player.inv:add("mod_power")
    player.inv:add("mod_power")
    player.inv:add("mod_bulk")
    player.inv:add("ustealtharmor")
    player.inv:add("rarmor")
    player.inv:add("pboots")
    player.inv:add("uhboots")
    player.inv:add("uheart")
    
    player.flags[BF_INV] = true
    player.hpmax = 80
    player.hp = 80
    player.armor = 3
	player.firetime = 80
    player.techbonus = 2
  end
  if inferno.debug_intuition then
    player.flags[BF_POWERSENSE] = true
    player.flags[BF_BEINGSENSE] = true
    player.flags[BF_LEVERSENSE1] = true
    player.flags[BF_LEVERSENSE2] = true
  end
end

-- Engine module hook
function inferno.OnEnter()
  --SaveHack.OnEnter()
  inferno.Statistics.OnEnter()
  player.turns_on_level = 0
  player.damage_on_start = statistics.damage_taken
  if levels[Level.id] then
    player.mortem_location = levels[Level.id].mortem_location or "ERROR"
  else
    player.mortem_location = "on level " .. Level.name_number .. " of Hell"
  end
  if inferno.debug and inferno.vision_cheat then
    Level.flags[LF_ITEMSVISIBLE] = true
    Level.flags[LF_BEINGSVISIBLE] = true
    Level.light[LFEXPLORED] = true
  end
  if inferno.debug and not levels[Level.id] and inferno.debug_being then
    Level.summon(inferno.debug_being, 5)
  end
end

-- Engine module hook
function inferno.OnExit()
  inferno.Statistics.OnExit()
  --SaveHack.OnExit()
end

-- Engine module hook
function inferno.OnFired(i, b)
  LurkAI.OnFired(i, b)
end

-- Engine module hook
function inferno.OnKill()
  player.kills = player.kills + 1
  inferno.Statistics.OnKill()
end

-- Custom module hook
function inferno.OnRespawn(b)
  inferno.Statistics.OnRespawn(b)
end

-- Custom module hook
function inferno.OnRestoreBeing(b)
  inferno.Statistics.OnRestoreBeing(b)
end

-- Engine module hook
function inferno.OnTick()
  player.turns_on_level = player.turns_on_level + 1
  inferno.Statistics.OnTick()
  beings.nspectre.OnTick()
  beings.nrevenant.OnTick()
  cells.web.OnTick()
end

-- Helper function (TODO: ?)
function inferno.describe_mortem(dlvl)
  return "on level " .. dlvl .. " of the inferno"
end

function inferno.OnWinGame()
  -- TODO
end

if inferno._noinclude then
  require(path .. "_noinclude/debug_ai")
end

SaveHack.initialize("inferno")