--[[
Skulltag's modules all exist in the Skulltag namespace.
Individual modules are analogous to classes.  They have methods and
(often private) variables.  For states that directly apply to the
player I tend to use custom properties.  The end results aren't changed.

All of SkulltagRL's code was written many versions ago and ported over time.
Unless I was feeling really proactive and there was a really good reason to
do so I usually didn't adapt the mod to new features, so don't rely on this
mod as a how-to.
]]--
core.declare("Skulltag", {})
Skulltag.Round = 0
Skulltag.Intermission = 0
Skulltag.DangerInc = 1
Skulltag.NPCs = 0
Skulltag.TotalNPCs = 0

Skulltag.FixDamnModuleSounds = function()

  items["skchainsaw"].sound_attack = core.resolve_sound_id("chainsaw.attack")
  items["skchainsaw"].sound_pickup = core.resolve_sound_id("chainsaw.pickup")
  items["skchainsaw"].sound_reload = core.resolve_sound_id("chainsaw.reload")

  --items["skminigun"].sound_fire   = core.resolve_sound_id("dsminign.wav")
  items["skminigun"].sound_pickup = core.resolve_sound_id("uminigun.pickup")
  items["skminigun"].sound_reload = core.resolve_sound_id("uminigun.reload")

  --items["skrailgun"].sound_fire   = core.resolve_sound_id("railgf1.wav")
  items["skrailgun"].sound_pickup = core.resolve_sound_id("urailgun.pickup")
  items["skrailgun"].sound_reload = core.resolve_sound_id("urailgun.reload")

  items["skbfg9000"].sound_fire    = core.resolve_sound_id("bfg9000.fire")
  items["skbfg9000"].sound_pickup  = core.resolve_sound_id("bfg9000.pickup")
  items["skbfg9000"].sound_reload  = core.resolve_sound_id("bfg9000.reload")
  items["skbfg9000"].sound_explode = core.resolve_sound_id("bfg9000.explode")

  --items["skbfg10000"].sound_fire    = core.resolve_sound_id("ds10kidl.wav")
  --items["skbfg10000"].sound_pickup  = core.resolve_sound_id("dsbfg10k.wav")
  items["skbfg10000"].sound_explode = core.resolve_sound_id("ubfg10k.explode")


  beings["abaddon"].sound_hit = core.resolve_sound_id("cacodemon.hit")
  beings["abaddon"].sound_die = core.resolve_sound_id("cacodemon.die")
  beings["abaddon"].sound_act = core.resolve_sound_id("cacodemon.act")

  beings["cacolantern"].sound_hit = core.resolve_sound_id("cacodemon.hit")
  beings["cacolantern"].sound_die = core.resolve_sound_id("cacodemon.die")
  beings["cacolantern"].sound_act = core.resolve_sound_id("cacodemon.act")

  beings["belphegor"].sound_hit = core.resolve_sound_id("belphegor.hit")
  beings["belphegor"].sound_die = core.resolve_sound_id("knight.die")
  beings["belphegor"].sound_act = core.resolve_sound_id("knight.act")

  beings["blooddemon"].sound_hit   = core.resolve_sound_id("blooddemon.hit")
  beings["blooddemon"].sound_die   = core.resolve_sound_id("blooddemon.die")
  beings["blooddemon"].sound_act   = core.resolve_sound_id("blooddemon.act")
  beings["blooddemon"].sound_melee = core.resolve_sound_id("blooddemon.melee")

  beings["bruiserdemon"].sound_hit = core.resolve_sound_id("bruiserdemon.hit")
  beings["bruiserdemon"].sound_die = core.resolve_sound_id("bruiserdemon.die")
  beings["bruiserdemon"].sound_act = core.resolve_sound_id("bruiserdemon.act")

  beings["darkimp"].sound_die    = core.resolve_sound_id("darkimp.die")
  beings["darkimp"].sound_act    = core.resolve_sound_id("darkimp.act")
  beings["darkimp"].sound_attack = core.resolve_sound_id("darkimp.fire")

  beings["diabloist"].sound_hit = core.resolve_sound_id("diabloist.hit")
  beings["diabloist"].sound_die = core.resolve_sound_id("diabloist.die")
  beings["diabloist"].sound_act = core.resolve_sound_id("diabloist.act")

  --items["nat_sk_diabloist1"].sound_fire = core.resolve_sound_id("dsslshot.wav")
  items["nat_sk_diabloist2"].sound_fire = core.resolve_sound_id("arch.atk")

  beings["hectebus"].sound_hit = core.resolve_sound_id("mancubus.hit")
  beings["hectebus"].sound_die = core.resolve_sound_id("mancubus.die")
  beings["hectebus"].sound_act = core.resolve_sound_id("mancubus.act")

  beings["spectre"].sound_hit   = core.resolve_sound_id("demon.hit")
  beings["spectre"].sound_die   = core.resolve_sound_id("demon.die")
  beings["spectre"].sound_act   = core.resolve_sound_id("demon.act")
  beings["spectre"].sound_melee = core.resolve_sound_id("demon.melee")

  beings["suicideskull"].sound_hit   = core.resolve_sound_id("lostsoul.hit")
  beings["suicideskull"].sound_die   = core.resolve_sound_id("lostsoul.die")
  beings["suicideskull"].sound_act   = core.resolve_sound_id("lostsoul.act")
  beings["suicideskull"].sound_melee = core.resolve_sound_id("blank.wav")

  beings["major"].sound_hit   = core.resolve_sound_id("former.pain")
  beings["major"].sound_die   = core.resolve_sound_id("sergeant.die")
  beings["major"].sound_act   = core.resolve_sound_id("former.act")
  beings["major"].sound_melee = core.resolve_sound_id("soldier.melee")

  beings["rocketeer"].sound_hit   = core.resolve_sound_id("former.pain")
  beings["rocketeer"].sound_die   = core.resolve_sound_id("commando.die")
  beings["rocketeer"].sound_act   = core.resolve_sound_id("former.act")
  beings["rocketeer"].sound_melee = core.resolve_sound_id("soldier.melee")

  beings["railgunner"].sound_hit   = core.resolve_sound_id("commando.pain")
  beings["railgunner"].sound_die   = core.resolve_sound_id("former.die")
  beings["railgunner"].sound_act   = core.resolve_sound_id("sergeant.act")
  beings["railgunner"].sound_melee = core.resolve_sound_id("soldier.melee")

  beings["bfgmarine"].sound_hit   = core.resolve_sound_id("sergeant.pain")
  beings["bfgmarine"].sound_die   = core.resolve_sound_id("commando.die")
  beings["bfgmarine"].sound_act   = core.resolve_sound_id("commando.act")
  beings["bfgmarine"].sound_melee = core.resolve_sound_id("soldier.melee")
end
Skulltag.SetPhasersToFun = function()

  for i=1, #items, 1 do
    if(string.sub(items[i].id, 1, 3) == "sr_" or string.sub(items[i].id, 1, 3) == "sp_") then
      items[i].weight = items[i].weight * 6
    end
  end
end

require "skulltag_arena:data_structures"
require "skulltag_arena:doomrl_mod_event_queue"
require "skulltag_arena:skulltag_arena_announcer"
require "skulltag_arena:skulltag_arena_ai"
require "skulltag_arena:skulltag_arena_runes"
require "skulltag_arena:skulltag_arena_powerups"
require "skulltag_arena:skulltag_arena_health"
require "skulltag_arena:skulltag_arena_items"
require "skulltag_arena:skulltag_arena_enemies"
require "skulltag_arena:skulltag_arena_HUD"
require "skulltag_arena:skulltag_arena_level"

Skulltag.Healing.Init()
Skulltag.Beings.Init()
Skulltag.Runes.Init()
Skulltag.Powerups.Init()
Skulltag.Items.Init()
Skulltag.HUD.Init()
Skulltag.Level.Init()

player:add_property("rune", RUNE_NONE)
player:add_property("hp_last_tick", 0)
player:add_property("hp_fraction", 0.0)
player:add_property("powerup", {})
for i = 1, POWER_LIGHTAMP do player.powerup[i] = 0 end
player:add_property("map_rounds", 0)
player:add_property("pmap_rounds", 0)

--Declare our level and level hooks(the new method is convoluted but roughly analogous to a Level{} declaration
core.declare("skulltag_arena", {})
function skulltag_arena.OnMortem()
        if (level.danger_level >= 15)                                then player:set_award( "skulltag_arena_module_award", 1 ) end
        if (kills.get("sk_jc") > 0)                                  then player:set_award( "skulltag_arena_module_award", 2 ) end
        if (kills.get("sk_jc") > 0 and DIFFICULTY >= DIFF_MEDIUM)    then player:set_award( "skulltag_arena_module_award", 3 ) end
        if (kills.get("sk_jc") > 0 and DIFFICULTY >= DIFF_HARD)      then player:set_award( "skulltag_arena_module_award", 4 ) end
        if (kills.get("sk_jc") > 0 and DIFFICULTY >= DIFF_VERYHARD)  then player:set_award( "skulltag_arena_module_award", 5 ) end
        if (kills.get("sk_jc") > 0 and DIFFICULTY >= DIFF_NIGHTMARE) then player:set_award( "skulltag_arena_module_award", 6 ) end
end
function skulltag_arena.OnMortemPrint(killedby)
    --This is the closest we have to a 'mod.shutdown' procedure.
    Skulltag.HUD.Dispose()

    if player.hp > 0 then
      if (kills.get("sk_jc") > 0) then
        killedby = "killed Uber Karmak on round " .. Skulltag.Round
      elseif Skulltag.NPCs > 0 then
        killedby = "fled on round " .. Skulltag.Round
      else
        killedby = "completed " .. Skulltag.Round .. " rounds"
      end
    else
      killedby = killedby .. " on round " .. Skulltag.Round
    end

    player:mortem_print( " "..player.name..", level "..player.explevel.." "..klasses[player.klass].name )
    player:mortem_print( killedby .. " at the Skulltag Arena..." )
end
function skulltag_arena.OnEnter()

    Skulltag.FixDamnModuleSounds()
    core.play_music()

    player.inv:clear()
    player.eq:clear()
    player.eq.weapon = item.new("knife")
    player.eq.armor  = item.new("garmor")

    if(ui.msg_confirm("Activate fun mode?")) then
      player:add_history("He enjoyed party favors.")
      Skulltag.SetPhasersToFun()
    end

    Skulltag.AnnouncerIntro()
    Skulltag.AnnouncerPlaySound("preparetofight")
    Skulltag.Intermission = 250
end
function skulltag_arena.OnTick()

    --calc HUD stuff
    Skulltag.HUD.Redraw()

    --run OnTick methods
    Skulltag.Runes.RunTickRunes()
    Skulltag.Powerups.RunTickPowerups()
    EventQueue.RunTick()

    player.hp_last_tick = player.hp

    --If this is an intermission run the intermission code.  The intermission code will spawn new waves if needed.
    if(Skulltag.Intermission > 0) then
      Skulltag.Intermission = Skulltag.Intermission - 1
      if    (Skulltag.Intermission == 80) then Skulltag.AnnouncerPlaySound("three")
      elseif(Skulltag.Intermission == 50) then Skulltag.AnnouncerPlaySound("two")
      elseif(Skulltag.Intermission == 20) then Skulltag.AnnouncerPlaySound("one")
      elseif(Skulltag.Intermission == 0)  then

        --Start a new round!
        Skulltag.AnnouncerPlaySound("fight")
        Skulltag.Round = Skulltag.Round + 1
        level.danger_level = math.max(math.min(math.floor(Skulltag.Round * Skulltag.DangerInc), 250), 1)
        Skulltag.Level.ClearCorpses()
        if(math.random(4) == 1) then Skulltag.Level.ClearHazards() end
        if(math.random(5) == 1) then Skulltag.Level.DropBarrels() end
        Skulltag.Level.DropWave()

        --Level specific changes
        if(Skulltag.Round % 5 == 0) then
          core.play_music()
        end

        if(level.danger_level >= 25 and Skulltag.Round % 5 == 0) then
          if(ui.msg_confirm("Ready for the final round?") == true) then
            local boss = level:drop_being("sk_jc", generator.standard_empty_coord())
            boss.flags[ BF_BOSS ] = true
          else
            ui.msg("Then fight some more!")
          end
        end
      end
    end

end
function skulltag_arena.OnKillAll()
    --JC's death is the win condition.  Don't run this if JC dies.
    if (kills.get("sk_jc")) > 0 then return end

    --Print some announcer blathering
    Skulltag.AnnouncerContinueAsk()

    --So, do we continue?
    local choice = ui.msg_confirm("Round " .. Skulltag.Round + 1 .. " awaits.  Do you want to continue the fight?")
    if(choice == true) then --continuing
      Skulltag.AnnouncerContinue()
      Skulltag.Level.ClearMemory()
      Skulltag.Level.DropItems()
      Skulltag.AnnouncerPlaySound("preparetofight")
      Skulltag.Intermission = 250
    else --quitting
      Skulltag.AnnouncerQuit()
      Skulltag.Level.DropItems() --rewards :)
    end
end
function skulltag_arena.OnExit()
    Skulltag.AnnouncerLeave()
end

function skulltag_arena.run()

	level.name = "Skulltag Arena"
	level.name_number = 0
	generator.fill( "rwall", area.FULL )
	local translation = {
		['.'] = "floor",
		[','] = { "water", flags = { LFBLOOD } },
		['#'] = "rwall",
		['>'] = "stairs"
	}

	local map = [[
#######################.............................########################
###########.....................................................############
#####..................................................................#####
##........................................................................##
#..........................................................................#
............................................................................
..................................,,,,,,....................................
..,,,.............................,,,,,,,...................................
..,>,............................,,,,,,,,,..................................
..,,,............................,,,,,,,,...................................
..................................,,,,,,....................................
............................................................................
............................................................................
#..........................................................................#
##........................................................................##
#####..................................................................#####
###########.....................................................############
#######################.............................########################
]]
	local column = [[
,..,.,
,####.
.####,
.####.
,..,.,
]]

	generator.place_tile( translation, map, 2, 2 )
	generator.scatter_put( area.new(5,3,68,15), translation, column, "floor",9+math.random(8))
	generator.transmute( "water", "floor" )
	generator.scatter_blood( area.FULL_SHRINKED, "floor", 100 )
	level:player(38,10)
end
