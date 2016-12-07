core.declare("is_coord", false)
core.declare("is_area", false)

function is_coord(c)
  return getmetatable(coord.UNIT) == getmetatable(c)
end

function is_area(a)
  return getmetatable(area.FULL) == getmetatable(a)
end

function coord:serialize()
  return {self.x, self.y}
end

function coord.load(data)
  return coord.new(unpack(data))
end

function area:serialize()
  return {self.a.x, self.a.y, self.b.x, self.b.y}
end

function area.load(data)
  return area.new(unpack(data))
end

core.declare("Serialize", {})

function Serialize.serialize(obj)
  if type(obj) == "string" then
    return obj
  elseif type(obj) == "number" then
    return obj
  elseif type(obj) == "table" then
    local data = {}
    for k, v in pairs(obj) do
      data[Serialize.serialize(k)] = Serialize.serialize(v)
    end
    return data
  elseif type(obj) == "nil" then
    return obj
  elseif type(obj) == "boolean" then
    return obj
  elseif type(obj) == "thread" then
    error("can't serialize thread")
  elseif type(obj) == "function" then
    error("can't serialize function")
  elseif type(obj) == "userdata" then
    if is_coord(obj) then
      return {"__coord__", obj:serialize()}
    elseif is_area(obj) then
      return {"__area__", obj:serialize()}
    else
      error("can't serialize userdata")
    end
  end
end

function Serialize.load(obj)
  if type(obj) == "string" then
    return obj
  elseif type(obj) == "number" then
    return obj
  elseif type(obj) == "table" then
    if obj[1] == "__coord__" then
      return coord.load(obj[2])
    elseif obj[1] == "__area__" then
      return coord.load(obj[2])
    else
      local rtn = {}
      for k, v in pairs(obj) do
        rtn[Serialize.load(k)] = Serialize.load(v)
      end
      return rtn
    end
  elseif type(obj) == "nil" then
    return obj
  elseif type(obj) == "boolean" then
    return obj
  elseif type(obj) == "thread" then
    error("can't load thread")
  elseif type(obj) == "function" then
    error("can't load function")
  elseif type(obj) == "userdata" then
    error("can't serialize userdata")
  end
end

-- Example
-- Serialize.register({
--   id = "flood_event_OnTick",
--   Initialize = function(self, fluid, rate)
--     self.fluid = fluid
--     self.rate = rate
--   end,
--   Run = function(self)
--     if core.game_time() > self.rate then Level.flood(self.fluid)
--   end,
-- })

local generators = {}

function Serialize.register(generator_proto)
  local id = generator_proto.id
  if generators[id] then
    error("Already registered generator with id " .. id)
  end
  generators[id] = generator_proto
end

local environment = {}

function Serialize.create_environment()
  return setmetatable({state_table = {}, function_table = {}, _auto = 0, _size = 0}, { __index = environment})
end

function environment:instantiate(index, id, ...)
  if index == nil then index = self:auto_index() end
  local gen = generators[id]
  local func
  local state = {id = id}
  gen.Initialize(state, ...)
  function func(...)
    gen.Run(state, ...)
  end
  if not self.state_table[index] then
    self._size = self._size + 1
  end
  self.state_table[index] = state
  self.function_table[index] = func
  return func
end

function environment:auto_index()
  local index
  repeat
    self._auto = self._auto + 1
    index = "_auto_index_" .. self._auto
  until not self.function_table[index]
  return index
end

function environment:get(index)
  return self.function_table[index]
end

function environment:entries()
  return pairs(self.function_table)
end

function environment:empty()
  return self._size == 0
end

function environment:serialize()
  local data = table.deep_copy(self.state_table)
  for index, state in pairs(data) do
    local id = state.id
    local gen = generators[id]
    if gen.Serialize then
      gen.Serialize(state)
    end
  end
  return data
end

function Serialize.load_environment(state_table)
  local env = {}
  env.state_table = state_table
  env.function_table = {}
  for index, state in pairs(state_table) do
    local gen = generators[state.id]
    if gen.Restore then
      gen.Restore(state)
    end
    env.function_table[index] = function(...)
      gen.Run(state, ...)
    end
  end
  return setmetatable(env, { __index = environment})
end