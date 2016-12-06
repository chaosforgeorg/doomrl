--The only thing we can mess with in the HUD is the level name or the player name.
--I used to modify the level name, giving me a paltry 19 colorable characters to
--abuse.  But that's all but useless in 0996; color changing is no longer possible
--and the level text quickly ends up an unreadable shade of dark blue.  The other
--option, the player name, requires more cleanup and looks a bit funky, but is legible.
--I've also tried making my own 'hud' with cells but that has not worked.

--This is the exposed interface
Elevator.HUD = {}
Elevator.HUD.PlayerName = 0
Elevator.HUD.NPCs = 0
Elevator.HUD.TotalNPCs = 0
Elevator.HUD.MarkDirty = nil
Elevator.HUD.Redraw    = nil
Elevator.HUD.Reset     = nil
Elevator.HUD.Init      = nil
Elevator.HUD.Dispose   = nil

--the rest
local dirty = false
local real_name = nil
local real_name_17 = nil

--older procs for level, may be useful again in later versions
local calcRune = function ()
    return Elevator.Runes.Ascii[player.rune]
end
local calcPowerup = function ()
    local ret = ""

    for i = 1, POWER_LIGHTAMP do
        if(player.powerup[i] > 0.0) then
            ret = ret .. Elevator.Powerups.Ascii[i]
        else
            ret = ret .. " "
        end
    end
    return ret
end
local calcKilloMeter = function ()

    local ret = ""

    --if    (Elevator.HUD.NPCs > 5) then ret = "@R"
    --elseif(Elevator.HUD.NPCs > 0) then ret = "@Y"
    --else                               ret = "@B"
    --end

    --padding space
    if    (Elevator.HUD.NPCs <  10) then ret = ret .. "  "
    elseif(Elevator.HUD.NPCs < 100) then ret = ret .. " "
    end
    if    (Elevator.HUD.TotalNPCs <  10) then ret = ret .. "  "
    elseif(Elevator.HUD.TotalNPCs < 100) then ret = ret .. " "
    end

    ret = ret .. Elevator.HUD.NPCs .. "/" .. Elevator.HUD.TotalNPCs
    return ret
end

--and the interface
Elevator.HUD.MarkDirty = function ()
    dirty = true
end
Elevator.HUD.Redraw = function ()
    if(dirty == true) then
      --Level.name = calcRune() .. calcPowerup() .. " " .. calcKilloMeter()

      local hud_17 = ""
      local spaces = 0
      local has_value = false

      hud_17 = Elevator.Runes.Ascii[player.rune]
      if (hud_17 ~= " ") then has_value = true end

      for i = 1, POWER_LIGHTAMP do
          if (player.powerup[i] > 0.0) then
              hud_17 = hud_17 .. Elevator.Powerups.Ascii[i]
              has_value = true
          else
              hud_17 = hud_17 .. " "
          end
      end

      if (has_value == true) then
          hud_17 = hud_17 .. "       "
      else
          hud_17 = real_name_17
      end


      --if    (player.explevel > 9) then spaces = 1 end
      if    (Elevator.HUD.NPCs <  10) then spaces = spaces + 2
      elseif(Elevator.HUD.NPCs < 100) then spaces = spaces + 1
      end

      player.name = hud_17 .. string.rep(" ", spaces) .. Elevator.HUD.NPCs .. "/" .. Elevator.HUD.TotalNPCs
      dirty = false
    end
end
Elevator.HUD.Reset = function ()
    Elevator.HUD.TotalNPCs = Elevator.HUD.NPCs
    dirty = true
end

--init code.
Elevator.HUD.Init = function ()

    --Level.name_number = 0
    Elevator.HUD.PlayerName = player.name
    real_name_17 = Elevator.HUD.PlayerName .. string.rep(" ", 17 - string.len(Elevator.HUD.PlayerName))

    --Hook being create and death in order to keep these counts accurate.
    for i=2, #beings, 1 do
        beings[i].OnCreate = core.create_seq_function(beings[i].OnCreate,
        function(self)
            Elevator.HUD.NPCs = Elevator.HUD.NPCs + 1
            Elevator.HUD.TotalNPCs = Elevator.HUD.TotalNPCs + 1
            Elevator.HUD.MarkDirty()
        end)
    end
    for i=2, #beings, 1 do
        beings[i].OnDie = core.create_seq_function(beings[i].OnDie,
        function(self)
            Elevator.HUD.NPCs = Elevator.HUD.NPCs - 1
            Elevator.HUD.MarkDirty()
        end)
    end
end
Elevator.HUD.Dispose = function ()
    player.name = Elevator.HUD.PlayerName
end

