--[[
The Elevator makes use of some of the Skulltag modules.
Aside from the namespace change they have largely been
left intact.  Modularity is a beautiful thing :)
]]--
core.declare("Elevator", {})

core.declare("FixAllSounds")
FixAllSounds = function() end --don't change this to nil or stuff won't work


require "elevator:data_structures"
require "elevator:doomrl_mod_event_queue"
require "elevator:elevator_announcer"
require "elevator:elevator_cells"
require "elevator:elevator_runes"
require "elevator:elevator_powerups"
require "elevator:elevator_health"
require "elevator:elevator_items"
require "elevator:elevator_beings"
require "elevator:elevator_HUD"
require "elevator:elevator_level"
require "elevator:elevator_player"
require "elevator:elevator_spawnengine"
require "elevator:elevator_itemengine"
require "elevator:elevator_waveengine"

require "elevator:elevator_wave_inter0"
Elevator.WaveEngine.Add(Elevator.Intermission.level)
require "elevator:elevator_wave_tomb1"
require "elevator:elevator_wave_tomb1a"
require "elevator:elevator_wave_tomb2"
Elevator.WaveEngine.Add(Elevator.Intermission.close)
Elevator.WaveEngine.Add(Elevator.Intermission.level)
require "elevator:elevator_wave_baron1"
require "elevator:elevator_wave_baron1a"
require "elevator:elevator_wave_baron2"
Elevator.WaveEngine.Add(Elevator.Intermission.close)
Elevator.WaveEngine.Add(Elevator.Intermission.level)
require "elevator:elevator_wave_wolf1"
require "elevator:elevator_wave_wolf1a"
require "elevator:elevator_wave_wolf2"
Elevator.WaveEngine.Add(Elevator.Intermission.close)
Elevator.WaveEngine.Add(Elevator.Intermission.level)
require "elevator:elevator_wave_future1"
require "elevator:elevator_wave_future1a"
require "elevator:elevator_wave_future2"
Elevator.WaveEngine.Add(Elevator.Intermission.close)
Elevator.WaveEngine.Add(Elevator.Intermission.level)
require "elevator:elevator_wave_void1"
require "elevator:elevator_wave_void1a"
require "elevator:elevator_wave_void2"
Elevator.WaveEngine.Add(Elevator.Intermission.close)
require "elevator:elevator_wave_boss0a"
require "elevator:elevator_wave_boss1"

Elevator.Healing.Init()
Elevator.Beings.Init()
Elevator.Runes.Init()
Elevator.Powerups.Init()
Elevator.Items.Init()
Elevator.HUD.Init()
Elevator.Level.Init()
Elevator.SpawnEngine.Init()
Elevator.ItemEngine.Init()
Elevator.WaveEngine.Init()
Elevator.Player.Init()

player:add_property("rune", RUNE_NONE)
player:add_property("hp_last_tick", 0)
player:add_property("hp_fraction", 0.0)
player:add_property("powerup", {})
for i = 1, POWER_LIGHTAMP do player.powerup[i] = 0 end
player:add_property("drops", {})
player:add_property("deaths", 0)

--Declare our level and level hooks (the new method is convoluted but roughly analogous to a Level{} declaration
core.declare("elevator", {})
function elevator.OnMortem()
        if (player.hp > 0 and Elevator.WaveEngine.Round >= 11)                                                          then player:set_award( "elevator_module_award", 1 ) end
        if (player.hp > 0 and Elevator.WaveEngine.Round >= 11 and DIFFICULTY >= DIFF_HARD)                              then player:set_award( "elevator_module_award", 2 ) end
        if (player.hp > 0 and Elevator.WaveEngine.Round >= 11 and DIFFICULTY >= DIFF_HARD      and player.deaths < 110) then player:set_award( "elevator_module_award", 3 ) end
        if (player.hp > 0 and Elevator.WaveEngine.Round >= 11 and DIFFICULTY >= DIFF_VERYHARD  and player.deaths < 110) then player:set_award( "elevator_module_award", 4 ) end
        if (player.hp > 0 and Elevator.WaveEngine.Round >= 11 and DIFFICULTY >= DIFF_VERYHARD  and player.deaths < 11)  then player:set_award( "elevator_module_award", 5 ) end
        if (player.hp > 0 and Elevator.WaveEngine.Round >= 11 and DIFFICULTY >= DIFF_NIGHTMARE and player.deaths < 11)  then player:set_award( "elevator_module_award", 6 ) end
end
function elevator.OnMortemPrint(killedby)
    --This is the closest we have to a 'mod.shutdown' procedure.
    Elevator.HUD.Dispose()

    if player.hp > 0 and Elevator.WaveEngine.Round >= 11 then
      killedby = "Toured the world with " .. player.deaths .. " clones"
    else
      killedby = "Was left behind on round " .. Elevator.WaveEngine.Round
    end

    player:mortem_print( " "..player.name..", level "..player.explevel.." "..klasses[player.klass].name)
    player:mortem_print( " " .. killedby .. " in the Elevator of Dimensions.")
end
function elevator.OnEnter()

    FixAllSounds()
  --These are at 50% exp gain
  --player.exp = 4600 --wave1
  --player.exp = 10100 --wave2
  --player.exp = 21000 --wave3
  --player.exp = 38100 --wave4
  --player.exp = 40700 --wave5
  --player.exp = 44200 --wave6
  --player.exp = 65300 --wave8
  --player.exp = 90000 --wave9
  --player.vision = player.vision + 8
    player.inv:clear()
    player.eq:clear()
    player.eq.weapon = item.new("shotgun")
    player.eq.armor  = item.new("garmor")
    player.inv:add(item.new("knife"))
    player.inv:add(item.new("pistol"))
    player.inv:add(item.new("ammo"), { ammo = 100 })
    player.inv:add(item.new("shell"), { ammo = 50 })

    Elevator.WaveEngine.Next()
end
function elevator.OnExit()
    Elevator.HUD.Dispose()
end
function elevator.OnTick()

    --calc HUD stuff
    Elevator.HUD.Redraw()

    --run OnTick methods
    Elevator.Runes.RunTickRunes()
    Elevator.Powerups.RunTickPowerups()
    EventQueue.RunTick()
    Elevator.SpawnEngine.OnTick()
    Elevator.ItemEngine.OnTick()
    Elevator.WaveEngine.OnTick()
end
function elevator.OnKill(being)
    Elevator.WaveEngine.OnKill(being)
end
function elevator.OnKillAll(being)
    Elevator.WaveEngine.OnKillAll(being)
end

function elevator.run()

    level.name = "Elevator"
    level.name_number = 0
    generator.fill("void", area.FULL)
    level:player(40,18)
    level.flags[ LF_NORESPAWN ] = true

    beings["soldier"].OnDieCheck = Elevator.Player.OnDieCheck
end
