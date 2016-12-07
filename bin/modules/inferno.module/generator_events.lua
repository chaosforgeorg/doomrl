core.declare("LevelEvents", false)

Generator.level_events = {}

function inferno.Generator.initialize_events()
  player:add_property("unique_events", {})
end

function LevelEvents(event)
  table.insert(Generator.level_events, event)
  Generator.level_events[event.id] = event
end

function inferno.Generator.roll_event()
  local events = {}
  local sum = 0
  for _, event in ipairs(Generator.level_events) do
    if Level.danger_level >= event.min_lev and event.weight > 0 and not (event.unique and player.unique_events[event.id])then
      table.insert(events, event)
      sum = sum + event.weight
    end
  end
  if #events > 0 and sum > 0 then
    local event = Level.roll_weight(events, sum)
    if event then
      event.OnGenerate()
      if event.unique then
        player.unique_events[event.id] = true
      end
    end
  end
end

do
  local flood_tile = function(pos, cell)
    if area.FULL:is_edge(pos) then
      Generator.set_cell(pos, Generator.fluid_to_perm[cell])
    else
      local cell_data = cells[Generator.get_cell(pos)]
      if not cell_data.flag_set[CF_CRITICAL] then
        Generator.set_cell(pos, cell)
      end
      if cell_data.OnDestroy then
        cell_data.OnDestroy(pos.x, pos.y)
      end
      Level.clear_item(pos, true)
    end
  end
  
  Serialize.register({
    id = "flood_event_OnTick",
    Initialize = function(self, direction, step, cell)
      self.direction = direction
      self.step = step
      self.cell = cell
      self.timer = 0
      self.flood_min = 0
      if direction == -1 then
        self.flood_min = 80
      end
    end,
    Run = function(self)
      self.timer = self.timer + 1
      if self.timer == self.step then
        self.timer = 0
        self.flood_min = self.flood_min + self.direction
        if self.flood_min >= 1 and self.flood_min <= MAXX then
          for y = 1, MAXY do
            flood_tile(coord.new(self.flood_min, y), self.cell)
          end
        end
        if self.flood_min + self.direction >= 1 and self.flood_min + self.direction  <= MAXX then
          local switch = false
          for y = 1, MAXY do
            if switch then
              flood_tile(coord.new(self.flood_min + self.direction, y), self.cell)
            end
            if math.random(4) == 1 then
              switch = not switch
            end
          end
        end
      end
    end,
  })
end

LevelEvents({
  id = "flood",
  min_lev = 10,
  weight = 100,
  OnGenerate = function()
    local level = Level.danger_level
    local cell, step, direction
    cell = "acid"
    if math.random(level + DIFFICULTY * 5) >= 20 then
      cell = "lava"
    end
    if math.random(2) == 1 then direction = -1 else direction = 1 end
    step = math.max( 180 - 2 * Level.danger_level - DIFFICULTY * 5, 45 )
    if DIFFICULTY > 3 and Level.danger_level > 20 and math.random(5) == 1 then
      step = 25
    end
    
    inferno.Generator.register_hook("OnTick", "flood_event_OnTick", direction, step, cell)
    
    local left, right, count
    count = 0
    repeat left = Generator.safe_empty_coord() count = count + 1 until count > 1000 or left.x < 20
    count = 0
    repeat right = Generator.safe_empty_coord() count = count + 1 until count > 1000 or right.x > 60

    for c in area.FULL:coords() do
      if Level[ c ] == "stairs" then
        Level[ c ] = styles[ Level.style ].floor
        break
      end
    end

    if direction == 1 then
      thing.displace( player, left )
      Level[ right ] = "stairs"
    else
      thing.displace( player, right )
      Level[ left ] = "stairs"
    end

    ui.msg("You feel the sudden need to run!!!")
    player:add_history( "On level @1 he ran for his life from "..cells[cell].name.."!" )
  end,
})

LevelEvents({
  id = "ice",
  min_lev = 10,
  weight = 100,
  OnGenerate = Generator.setup_ice_event,
})

LevelEvents({
  id = "nuke",
  min_lev = 10,
  weight = 100,
  OnGenerate = function()
    local minutes = 10 - DIFFICULTY
    Generator.setup_nuke_event(minutes)
  end,
})

Serialize.register({
  id = "deadly_air_event_OnTick",
  Initialize = function(self, step)
    self.step = step
    self.timer = 0
  end,
  Run = function(self)
    self.timer = self.timer + 1
    if self.timer == self.step then
      self.timer = 0
      for b in Level.beings() do
        if b.hp > b.hpmax / 4 then
          if not b:is_player() or not b:is_affect("enviro") then
            b:msg("You feel a deadly chill!")
            b.hp = b.hp - 1
          end
        end
      end
    end
  end,
})

LevelEvents({
  id = "deadly_air",
  min_lev = 10,
  weight = 100,
  OnGenerate = function()
    inferno.Generator.register_hook("OnTick", "deadly_air_event_OnTick", 100 - DIFFICULTY * 5)
    ui.msg("The air seems deadly here, you better leave quick!")
    player:add_history( "Level @1 blasted him with unholy atmosphere!" )
  end,
})

LevelEvents({
  id = "perma",
  min_lev = 10,
  weight = 100,
  OnGenerate = Generator.setup_perma_event,
})

LevelEvents({
  id = "alarm",
  min_lev = 10,
  weight = 100,
  OnGenerate = Generator.setup_alarm_event,
})

LevelEvents({
  id = "blood_rain",
  min_lev = 16,
  weight = 100,
  OnGenerate = inferno.Generator.setup_blood_event,
})

LevelEvents({
  id = "imp_lord",
  min_lev = 13,
  weight = 50,
  unique = true,
  OnGenerate = function()
    Level.summon("imp_lord")
    Level.summon("imp", 8)
    Level.summon("nimp", 4)
    ui.msg("You feel hunted.")
  end,
})

Serialize.register({
  id = "soul_keeper_event_OnKill",
  Initialize = function(self)
    -- do nothing
  end,
  Run = function(self, b)
    if b ~= player and b.id ~= "lostsoul" and b.id ~= "pain" and b.id ~= "soul_keeper" then
      local c = b:get_position()
      for b in Level.beings() do
        if b.id == "soul_keeper" then
          table.insert(b.pending_souls, {x = c.x, y = c.y})
          break
        end
      end
    end
  end,
})

LevelEvents({
  id = "soul_keeper",
  min_lev = 16,
  weight = 50,
  unique = true,
  OnGenerate = function()
    Level.summon("soul_keeper")
    Level.summon("lostsoul", 15)
    ui.msg("Your heart skips a beat.")
    inferno.Generator.register_hook("OnKill", "soul_keeper_event_OnKill")
  end,
})