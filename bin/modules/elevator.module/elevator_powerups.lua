--Powerups.  Unlike runes multiple powerups can be active at once.  But they time out.

core.declare("POWER_BERSERK",      1)
core.declare("POWER_INVINCIBLE",   2)
core.declare("POWER_DOOMSPHERE",   3)
core.declare("POWER_TURBOSPHERE",  4)
core.declare("POWER_TIMEFREEZE",   5)
core.declare("POWER_PARTIALINVIS", 6)
core.declare("POWER_TOTALINVIS",   7)
core.declare("POWER_GUARDSPHERE",  8)
core.declare("POWER_LIGHTAMP",     9)

--This is the exposed interface
Elevator.Powerups = {}
Elevator.Powerups.Init = nil
Elevator.Powerups.PickupPowerup     = nil
Elevator.Powerups.RunTickPowerups   = nil
Elevator.Powerups.NewBeingPowerups  = nil
--Elevator.Powerups.Ascii = { "@RB", "@LV", "@RD", "@YT", "@CF", "@BP", "@bI", "@NG", "@LA", }
Elevator.Powerups.Ascii = { "B", "V", "D", "T", "F", "P", "I", "G", "A", }

--constants for easy tweaking
local PowerupWeight = 50
local AttackBonus = 4
local DefenseBonus = 4
local SpeedBonus = 0.5
local FreezeBonus = 0.035
local FreezeThawBonus = 0.105
local PartialInvisBonus = 2
local TotalInvisBonus = 4
local VisionBonus = 1
local PowerupDurations = { 1000, 1000, 1000, 1000, 60, 1000, 1000, 1000, 1000, }

--All of the actionable materials
local ActivatePowerupBerserk   = function (being)
  being:msg("You feel like a killing machine!")
  Elevator.AnnouncerPlaySound("berserk")
  being.flags[ BF_BERSERK ] = true
end
local ReactivatePowerupBerserk = function (being)
end
local NewBeingPowerupBerserk   = function (being)
end
local OnTickPowerupBerserk     = function (being)
  if(player.powerup[POWER_BERSERK] == 50) then
    being:msg("You feel your anger slowly wearing off...")
  end
end
local OnKillPowerupBerserk     = function (being, being_dead)
end
local DeactivatePowerupBerserk = function (being)
  being:msg("You feel more calm.")
  being.flags[ BF_BERSERK ] = false
end
local ActivatePowerupInvincible   = function (being)
  being:msg("You feel invincible!")
  Elevator.AnnouncerPlaySound("invincible")
  being.flags[ BF_INV ] = true
end
local ReactivatePowerupInvincible = function (being)
end
local NewBeingPowerupInvincible   = function (being)
end
local OnTickPowerupInvincible     = function (being)
  if(player.powerup[POWER_INVINCIBLE] == 50) then
    being:msg("You feel your invincibility fading...")
  end
end
local OnKillPowerupInvincible     = function (being, being_dead)
end
local DeactivatePowerupInvincible = function (being)
  being:msg("You feel vulnerable again.")
  being.flags[ BF_INV ] = false
end
local ActivatePowerupDoomsphere   = function (being)
  being:msg("You feel much stronger.")
  Elevator.AnnouncerPlaySound("doomsphere")
  being.todamall =  being.todamall + AttackBonus
end
local ReactivatePowerupDoomsphere = function (being)
end
local NewBeingPowerupDoomsphere   = function (being)
end
local OnTickPowerupDoomsphere     = function (being)
  if(player.powerup[POWER_DOOMSPHERE] == 50) then
    being:msg("You feel your strength being sapped away...")
  end
end
local OnKillPowerupDoomsphere     = function (being, being_dead)
end
local DeactivatePowerupDoomsphere = function (being)
  being:msg("You feel weaker.")
  being.todamall = being.todamall - AttackBonus
end
local ActivatePowerupTurbosphere   = function (being)
  being:msg("You feel much faster.")
  Elevator.AnnouncerPlaySound("turbosphere")
  being.movetime = being.movetime * SpeedBonus
end
local ReactivatePowerupTurbosphere = function (being)
end
local NewBeingPowerupTurbosphere   = function (being)
end
local OnTickPowerupTurbosphere     = function (being)
  if(player.powerup[POWER_TURBOSPHERE] == 50) then
    being:msg("You feel yourself slowing down...")
  end
end
local OnKillPowerupTurbosphere     = function (being, being_dead)
end
local DeactivatePowerupTurbosphere = function (being)
  being:msg("You feel painfully slow.")
  being.movetime = being.movetime / SpeedBonus
end
local ActivatePowerupTimefreeze   = function (being)
  being:msg("Everything stops for a moment!")
  Elevator.AnnouncerPlaySound("timefreeze")

  being.scount = math.min(being.scount + 15000, 60000) --Roughly 15 free moves
end
local ReactivatePowerupTimefreeze = function (being)
  if(player.powerup[POWER_TIMEFREEZE] < 10) then
    being:msg("Everything slows back down!")
  end

  being.scount = math.min(being.scount + 15000, 60000) --Roughly 15 free moves
end
local NewBeingPowerupTimefreeze   = function (being)
end
local OnTickPowerupTimefreeze     = function (being)
  if(player.powerup[POWER_TIMEFREEZE] == 10) then
    being:msg("The world moves once more.")
  end

  if(player.powerup[POWER_TIMEFREEZE] <= 10) then
    being.scount = math.min(being.scount + 50, 60000) --A half-move to simulate things gradually speeding up
  else
    being.scount = math.min(being.scount + 100, 60000) --A single free move to simulate things gradually speeding up
  end
end
local OnKillPowerupTimefreeze     = function (being, being_dead)
end
local DeactivatePowerupTimefreeze = function (being)
end
local ActivatePowerupPartialinvis   = function (being)
  being:msg("You feel hidden.")
  Elevator.AnnouncerPlaySound("partialinvisibility")

  for b in level:beings() do
    if not b:is_player() then
      b.ToHit = b.ToHit - PartialInvisBonus
    end
  end
end
local ReactivatePowerupPartialinvis = function (being)
end
local NewBeingPowerupPartialinvis   = function (being)
  being.ToHit = being.ToHit - PartialInvisBonus
end
local OnTickPowerupPartialinvis     = function (being)
  if(player.powerup[POWER_TURBOSPHERE] == 50) then
    being:msg("Your cloak seems to flicker...")
  end
end
local OnKillPowerupPartialinvis     = function (being, being_dead)
end
local DeactivatePowerupPartialinvis = function (being)
  being:msg("You feel visible again.")

  for b in level:beings() do
    if not b:is_player() then
      b.ToHit = b.ToHit + PartialInvisBonus
    end
  end
end
local ActivatePowerupTotalinvis   = function (being)
  being:msg("You feel very hidden.")
  Elevator.AnnouncerPlaySound("invisibility")

  for b in level:beings() do
    if not b:is_player() then
      b.ToHit = b.ToHit - TotalInvisBonus
    end
  end
end
local NewBeingPowerupTotalinvis   = function (being)
  being.ToHit = being.ToHit - TotalInvisBonus
end
local ReactivatePowerupTotalinvis = function (being)
end
local OnTickPowerupTotalinvis     = function (being)
end
local OnKillPowerupTotalinvis     = function (being, being_dead)
end
local DeactivatePowerupTotalinvis = function (being)
  being:msg("You feel visible again.")

  for b in level:beings() do
    if not b:is_player() then
      b.ToHit = b.ToHit + TotalInvisBonus
    end
  end
end
local ActivatePowerupGuardsphere   = function (being)
  being:msg("You feel tough.")
  Elevator.AnnouncerPlaySound("guardsphere")
  being.armor = being.armor + DefenseBonus
end
local ReactivatePowerupGuardsphere = function (being)
end
local NewBeingPowerupGuardsphere   = function (being)
end
local OnTickPowerupGuardsphere     = function (being)
end
local OnKillPowerupGuardsphere     = function (being, being_dead)
end
local DeactivatePowerupGuardsphere = function (being)
  being:msg("You feel fragile.")
  being.armor = being.armor - DefenseBonus
end
local ActivatePowerupLightAmp   = function (being)
  being:msg("You eyes sharpen.")
  being.vision = being.vision + VisionBonus
end
local ReactivatePowerupLightAmp = function (being)
end
local NewBeingPowerupLightAmp   = function (being)
end
local OnTickPowerupLightAmp     = function (being)
end
local OnKillPowerupLightAmp     = function (being, being_dead)
end
local DeactivatePowerupLightAmp = function (being)
  being:msg("Your vision dims.")
  being.vision = being.vision - VisionBonus
end

--switch-like tables
local ActivatePowerupTable   = {
  ActivatePowerupBerserk,
  ActivatePowerupInvincible,
  ActivatePowerupDoomsphere,
  ActivatePowerupTurbosphere,
  ActivatePowerupTimefreeze,
  ActivatePowerupPartialinvis,
  ActivatePowerupTotalinvis,
  ActivatePowerupGuardsphere,
  ActivatePowerupLightAmp,
}
local ReactivatePowerupTable = {
  ReactivatePowerupBerserk,
  ReactivatePowerupInvincible,
  ReactivatePowerupDoomsphere,
  ReactivatePowerupTurbosphere,
  ReactivatePowerupTimefreeze,
  ReactivatePowerupPartialinvis,
  ReactivatePowerupTotalinvis,
  ReactivatePowerupGuardsphere,
  ReactivatePowerupLightAmp,
}
local DeactivatePowerupTable = {
  DeactivatePowerupBerserk,
  DeactivatePowerupInvincible,
  DeactivatePowerupDoomsphere,
  DeactivatePowerupTurbosphere,
  DeactivatePowerupTimefreeze,
  DeactivatePowerupPartialinvis,
  DeactivatePowerupTotalinvis,
  DeactivatePowerupGuardsphere,
  DeactivatePowerupLightAmp,
}
local NewBeingPowerupTable   = {
  NewBeingPowerupBerserk,
  NewBeingPowerupInvincible,
  NewBeingPowerupDoomsphere,
  NewBeingPowerupTurbosphere,
  NewBeingPowerupTimefreeze,
  NewBeingPowerupPartialinvis,
  NewBeingPowerupTotalinvis,
  NewBeingPowerupGuardsphere,
  NewBeingPowerupLightAmp,
}
local OnTickPowerupTable     = {
  OnTickPowerupBerserk,
  OnTickPowerupInvincible,
  OnTickPowerupDoomsphere,
  OnTickPowerupTurbosphere,
  OnTickPowerupTimefreeze,
  OnTickPowerupPartialinvis,
  OnTickPowerupTotalinvis,
  OnTickPowerupGuardsphere,
  OnTickPowerupLightAmp,
}
local OnKillPowerupTable     = {
  OnKillPowerupBerserk,
  OnKillPowerupInvincible,
  OnKillPowerupDoomsphere,
  OnKillPowerupTurbosphere,
  OnKillPowerupTimefreeze,
  OnKillPowerupPartialinvis,
  OnKillPowerupTotalinvis,
  OnKillPowerupGuardsphere,
  OnKillPowerupLightAmp,
}

local ActivatePowerup    = function (arg_powerup, arg_being)
  assert(type(ActivatePowerupTable[arg_powerup]) == "function")
  ActivatePowerupTable[arg_powerup](arg_being)
  Elevator.HUD.MarkDirty()
  Elevator.HUD.Redraw()
end
local ReactivatePowerup  = function (arg_powerup, arg_being)
  assert(type(ReactivatePowerupTable[arg_powerup]) == "function")
  ReactivatePowerupTable[arg_powerup](arg_being)
end
local NewBeingPowerup    = function (arg_powerup, arg_being)
  assert(type(NewBeingPowerupTable[arg_powerup]) == "function")
  NewBeingPowerupTable[arg_powerup](arg_being)
end
local OnTickPowerup      = function (arg_powerup, arg_being)
  assert(type(OnTickPowerupTable[arg_powerup]) == "function")
  OnTickPowerupTable[arg_powerup](arg_being)
end
local OnKillPowerup      = function (arg_powerup, arg_being, arg_being_dead)
  assert(type(OnKillPowerupTable[arg_powerup]) == "function")
  OnKillPowerupTable[arg_powerup](arg_being, arg_being_dead)
end
local DeactivatePowerup  = function (arg_powerup, arg_being)
  assert(type(DeactivatePowerupTable[arg_powerup]) == "function")
  Elevator.HUD.Redraw()
  DeactivatePowerupTable[arg_powerup](arg_being)
  Elevator.HUD.MarkDirty()
  Elevator.HUD.Redraw()
end


--Exposed interface implementation
Elevator.Powerups.PickupPowerup       = function (arg_being, arg_powerup, arg_timeout)
  arg_timeout = arg_timeout or PowerupDurations[arg_powerup]

  if(player.powerup[arg_powerup] > 0) then
    --Picking up something already active.
    ReactivatePowerup(arg_powerup, arg_being)
    player.powerup[arg_powerup] = player.powerup[arg_powerup] + arg_timeout
    return
  end

  player.powerup[arg_powerup] = arg_timeout
  ActivatePowerup(arg_powerup, arg_being)
end
Elevator.Powerups.RunNewBeingPowerups = function (arg_being)
  for i = 1, POWER_LIGHTAMP do
    if(player.powerup[i] > 0) then
      --powerup is active
      NewBeingPowerup(i, arg_being)
    end
  end
end
Elevator.Powerups.RunTickPowerups     = function ()
  for i = 1, POWER_LIGHTAMP do
    if(player.powerup[i] > 0) then
      --powerup is active
      OnTickPowerup(i, player)

      player.powerup[i] = player.powerup[i] - 1
      if(player.powerup[i] <= 0) then
        --powerup just expired
        DeactivatePowerup(i, player)
      end
    end
  end
end
Elevator.Powerups.RunOnKillPowerups   = function (arg_being)
  for i = 1, POWER_LIGHTAMP do
    if(player.powerup[i] > 0) then
      --powerup is active
      OnKillPowerup(i, player, arg_being)
    end
  end
end

--Declare powerups
register_item "sp_berserk" {
  name       = "Berserk Pack",
  color      = RED,
  sprite     = SPRITE_BERSERK,
  ascii      = "^",
  level      = 1,
  weight     = PowerupWeight,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Elevator.Powerups.PickupPowerup(being, POWER_BERSERK)
    Elevator.Healing.AddBeingHP(being, being.hpmax, false)
  end
}
register_item "sp_invincible" {
  name       = "Invulnerability Globe",
  color      = WHITE,
  sprite     = SPRITE_INV,
  ascii      = "^",
  level      = 7,
  weight     = PowerupWeight,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Elevator.Powerups.PickupPowerup(being, POWER_INVINCIBLE)
    Elevator.Healing.AddBeingHP(being, being.hpmax, false)
  end
}
register_item "sp_doomsphere" {
  name       = "Doom Sphere",
  color      = LIGHTRED,
  sprite     = SPRITE_MEGASPHERE,
  overlay    = { 1.0,0.1,0.2,1.0 },
  ascii      = "^",
  level      = 4,
  weight     = PowerupWeight,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Elevator.Powerups.PickupPowerup(being, POWER_DOOMSPHERE)
  end
}
register_item "sp_turbosphere" {
  name       = "Turbo Sphere",
  color      = YELLOW,
  sprite     = SPRITE_MEGASPHERE,
  overlay    = { 0.9,1.0,0.1,1.0 },
  ascii      = "^",
  level      = 5,
  weight     = PowerupWeight,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Elevator.Powerups.PickupPowerup(being, POWER_TURBOSPHERE)
  end
}
register_item "sp_timefreeze" {
  name       = "Time Freeze",
  color      = LIGHTCYAN,
  sprite     = SPRITE_MEGASPHERE,
  overlay    = { 0.1,1.0,1.0,1.0 },
  ascii      = "^",
  level      = 10,
  weight     = PowerupWeight,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Elevator.Powerups.PickupPowerup(being, POWER_TIMEFREEZE)
  end
}
register_item "sp_partialinvis" {
  name       = "Partial Invisibility Globe",
  color      = CYAN,
  sprite     = SPRITE_MEGASPHERE,
  overlay    = { 0.6,0.5,0.75,1.0 },
  ascii      = "^",
  level      = 6,
  weight     = PowerupWeight,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Elevator.Powerups.PickupPowerup(being, POWER_PARTIALINVIS)
  end
}
register_item "sp_totalinvis" {
  name       = "Total Invisibility Globe",
  color      = BLUE,
  sprite     = SPRITE_MEGASPHERE,
  overlay    = { 0.5,0.5,1.0,1.0 },
  ascii      = "^",
  level      = 7,
  weight     = PowerupWeight,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Elevator.Powerups.PickupPowerup(being, POWER_TOTALINVIS)
  end
}
register_item "sp_guardsphere" {
  name       = "Guard Sphere",
  color      = BROWN,
  sprite     = SPRITE_MEGASPHERE,
  overlay    = { 1.0,0.6,0.2,1.0 },
  ascii      = "^",
  level      = 4,
  weight     = PowerupWeight,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Elevator.Powerups.PickupPowerup(being, POWER_GUARDSPHERE)
  end
}
register_item "sp_lightamp" {
  name       = "Light Amp Visor",
  color      = BLUE,
  sprite     = SPRITE_LIGHTAMP,
  ascii      = "^",
  level      = 5,
  weight     = PowerupWeight * 0.6,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Elevator.Powerups.PickupPowerup(being, POWER_LIGHTAMP)
  end
}
register_item "sp_random" {
  name       = "Shifting Powerup",
  color      = LIGHTGRAY,
  sprite     = SPRITE_MEGASPHERE,
  overlay    = { 0.5,0.7,1.0,1.0 },
  ascii      = "^",
  level      = 5,
  weight     = PowerupWeight * 0.2,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Elevator.Powerups.PickupPowerup(being, math.random(POWER_LIGHTAMP))
  end
}


--init code.
Elevator.Powerups.Init = function ()

  --affects are completely replaced
  items["bpack"].weight    = 0
  items["iglobe"].weight   = 0
  items["epack"].weight    = 0
  items["gpack"].weight    = 0

  --Embed our spiny tentacles into every being's OnCreate hook.
  for i=2, #beings, 1 do
    beings[i].OnCreate = core.create_seq_function(beings[i].OnCreate,
    function(self)
      Elevator.Powerups.RunNewBeingPowerups(self)
    end)
  end

  -- We have no custom onkill powerups but some day we might
  for i=2, #beings, 1 do
    beings[i].OnDie = core.create_seq_function(beings[i].OnDie,
    function(self)
      Elevator.Powerups.RunOnKillPowerups(self)
    end)
  end
end