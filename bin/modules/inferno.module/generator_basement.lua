local function coord_to_integer(c)
  return c.x + MAXX * c.y
end

function inferno.Generator.initialize_basements()
  player:add_property("basements", false)
  player:add_property("basement_restore_state", false)
  player:add_property("basement_x", 2)
  player:add_property("basement_y", 2)
  player:add_property("force_basement", 5 + math.random(18))
  player:add_property("generated_basements", {})
  if player.force_basement >= 15 then
    player.force_basement = player.force_basement + 1
  end
end

function inferno.Generator.reset_basements()
  player.basements = {}
end

function inferno.Generator.set_basement(c, id)
  player.basements[coord_to_integer(c)] = id
end

function inferno.Generator.get_basement(c)
  return player.basements[coord_to_integer(c)]
end

function inferno.Generator.place_basements()
  local basement = false
  local dlevel = Level.danger_level
  if player:has_property("force_basement") and player.force_basement == dlevel then
    basement = true
  elseif math.random(17) == 1 then
    basement = true
  end
  if basement then
    local candidates = {}
    for id, lev in pairs(levels) do
      if type(id) == "string" and string.sub(id, 1, 8) == "basement" then
        if lev.range and lev.range[1] <= dlevel and lev.range[2] >= dlevel and not player.generated_basements[id] then
          if (not lev.canGenerate) or lev.canGenerate() then
            table.insert(candidates, id)
          end
        end
      end
    end
    if #candidates > 0 then
      local id = table.random_pick(candidates)
      player.generated_basements[id] = true
      inferno.Generator.generate_basement(id)
    end
  end
end

function inferno.Generator.generate_basement(id)
  local c = Generator.standard_empty_coord()
  if c then
    Generator.set_cell(c, "bstairs")
    inferno.Generator.set_basement(c, id)
    ui.msg(levels[id].hint)
  end
end

Cells({
  id = "bstairs",
  name = "down stairs",
  ascii = ">",
  color = LIGHTBLUE,
  color_dark = BLUE,
  flags = {CF_NOCHANGE, CF_NORUN, CF_OVERLAY, CF_CRITICAL, CF_HIGHLIGHT, CF_STAIRS},
  sprite = 245,

  OnEnter = function(c, being)
    local b = inferno.Generator.get_basement(c)
    if b then
      being:msg("There are stairs leading to " .. levels[b].name.. " here.")
    else
      Level[c] = "floor"
      ui.msg_enter("ERROR #19685: please report to tehtmi!")
    end
  end,
  
  OnExit = function(c)
    local b = inferno.Generator.get_basement(c)
    if b then
      player.episode[player.episode_index].number = 0
      player.basement_restore_state = inferno.Generator.serialize()
      player.basement_x = c.x
      player.basement_y = c.y
      player:exit(b)
    else
      error("Basement isn't registered!")
    end
  end,
  
  OnDescribe = function(c)
    local b = inferno.Generator.get_basement(c)
    if b then
      return "stairs leading to " .. levels[b].name
    else
      Level[c] = "floor"
      ui.msg_enter("ERROR #19684: please report to tehtmi!")
      return "floor"
    end
  end,
})

Cells({
  id = "unbstairs",
  name = "up stairs",
  ascii = ">",
  color = LIGHTBLUE,
  color_dark = BLUE,
  flags = {CF_NOCHANGE, CF_NORUN, CF_OVERLAY, CF_CRITICAL, CF_HIGHLIGHT, CF_STAIRS},
  sprite = 245,

  OnEnter = function(c, being)
    being:msg("There are stairs leading upwards here.")
  end,
  
  OnExit = function(c)
    player.episode[player.episode_index].number = player.episode_index - 1
    player:exit(player.episode_index)
  end,
  
  OnDescribe = function(c)
    return "stairs leading upwards"
  end,
})