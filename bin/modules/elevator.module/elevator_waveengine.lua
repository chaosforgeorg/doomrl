--Waves are predefined objects with rules and other fun things.
--The 'prototypes' follow:

--This is the exposed interface
Elevator.WaveEngine = {}
Elevator.WaveEngine.Add  = nil
Elevator.WaveEngine.OnLoad = nil
Elevator.WaveEngine.OnTick = nil
Elevator.WaveEngine.OnKill = nil
Elevator.WaveEngine.OnUnload = nil
Elevator.WaveEngine.Next = nil
Elevator.WaveEngine.Init = nil

local wave_index = 0 --internal, what actual instructions are used
Elevator.WaveEngine.Round = 0 --external, what round is visibly being run

local waves = {}

Elevator.WaveEngine.Add = function (wave)
  table.insert(waves, wave)
end
Elevator.WaveEngine.OnLoad = function ()
  local wave = waves[wave_index]
  if wave ~= nil and wave.OnLoad ~= nil then
    --ui.msg("Loading module: " .. wave.name)
    wave.OnLoad()
  else
    --ui.msg("No more modules to load.")
  end
end
Elevator.WaveEngine.OnTick = function ()
  local wave = waves[wave_index]
  if wave ~= nil and wave.OnTick ~= nil then
    wave.OnTick()
  end
end
Elevator.WaveEngine.OnKill = function (being)
  local wave = waves[wave_index]
  if wave ~= nil and wave.OnKill ~= nil then
    wave.OnKill(being)
  end
end
Elevator.WaveEngine.OnKillAll = function ()
  local wave = waves[wave_index]
  if wave ~= nil and wave.OnKillAll ~= nil then
    wave.OnKillAll()
  end
end
Elevator.WaveEngine.OnPlayerDieCheck = function (player)
  local wave = waves[wave_index]
  if wave ~= nil and wave.OnDieCheck ~= nil then
    return wave.OnDieCheck(player)
  else
    return true
  end
end
Elevator.WaveEngine.OnUnload = function ()
  local wave = waves[wave_index]
  if wave ~= nil and wave.OnUnload ~= nil then
    --ui.msg("Unloading module: " .. wave.name)
    wave.OnUnload()
  end
end

Elevator.WaveEngine.Next = function (newround)

  Elevator.WaveEngine.OnUnload()
  wave_index = wave_index + 1
  if(newround) then Elevator.WaveEngine.Round = Elevator.WaveEngine.Round + 1 end
  Elevator.WaveEngine.OnLoad()
end

--And here's some init code.
Elevator.WaveEngine.Init = function ()

end
