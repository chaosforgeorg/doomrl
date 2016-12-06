--Runes.  Only one rune can be active at a time.  Runes do not time out.
--[[ Runes:
    227 ã Strength     -- Meant to be a good all rounder.  Acts like SoaB.
    229 å Resistance   -- Meant to be a good all rounder.  Acts like TaN.
    230 æ Prosperity   -- Meant to be a weak early game rune.  'Changes' being.maxHP.
    231 ç Rage         -- Meant to be a good offensive rune.  2/3rds firetime and reload time
    224 à Spread       -- unimplemented, would like to use IF_SPREAD but that does not work correctly on most weapons
    226 â Regeneration -- Meant to be a good defensive rune and possibly highly coveted.  Regenerates HP.  Regenerates more when wounded.
    234 ê Reflection   -- Meant to be an oddity really.  Redirects damage onto a nearby enemy, not necessarily the one dealing it, and doesn't protect player
    225 á Drain        -- Meant to be a more offensive regeneration rune.  Heals portion of being hpmax on enemy death.  Would like to heal on enemy harm but doesn't seem doable.
    239 ï Highjump     -- unimplemented, no idea what to do
    235 ë Haste        -- Meant to be a highly coveted rune.  Acts like HellRunner AND you never get tired
--]]

core.declare("RUNE_NONE",         1)
core.declare("RUNE_STRENGTH",     2)
core.declare("RUNE_RESISTANCE",   3)
core.declare("RUNE_PROSPERITY",   4)
core.declare("RUNE_RAGE",         5)
core.declare("RUNE_SPREAD",       6)
core.declare("RUNE_REGENERATION", 7)
core.declare("RUNE_REFLECTION",   8)
core.declare("RUNE_DRAIN",        9)
core.declare("RUNE_HIGHJUMP",    10)
core.declare("RUNE_HASTE",       11)

--This is the exposed interface
Skulltag.Runes = {}
Skulltag.Runes.Init = nil
Skulltag.Runes.PickupRune     = nil
Skulltag.Runes.RunTickRunes   = nil
Skulltag.Runes.RunOnKillRunes = nil
--Skulltag.Runes.Ascii = { " ", "@gã", "@gå", "@Gæ", "@rç", "@Rà", "@Râ", "@Vê", "@rá", "@Gï", "@Yë", }
Skulltag.Runes.Ascii = { " ", "ã", "å", "æ", "ç", "à", "â", "ê", "á", "ï", "ë", }

--everything else is encapsulated.  'Being' is always the player.
local RuneWeight = 50
local MaxRegenerationPerTick = .05
local RateReflected = 1.5
local RateDrained = .1
local StrengthBonus = 1
local ResistanceBonus = 1
local RageBonus = .65
local HasteBonus = .85

local ActivateRuneNone   = function (being)
end
local ReactivateRuneNone = function (being)
end
local NewBeingRuneNone   = function (being)
end
local OnTickRuneNone     = function (being)
end
local OnKillRuneNone     = function (being, being_dead)
end
local DeactivateRuneNone = function (being)
end
local ActivateRuneStrength   = function (being)
  being:msg("You feel stronger.")
  Skulltag.AnnouncerPlaySound("strength")
  being.todamall = being.todamall + StrengthBonus
end
local ReactivateRuneStrength = function (being)
end
local NewBeingRuneStrength   = function (being)
end
local OnTickRuneStrength     = function (being)
end
local OnKillRuneStrength     = function (being, being_dead)
end
local DeactivateRuneStrength = function (being)
  being.todamall = being.todamall - StrengthBonus
end
local ActivateRuneResistance   = function (being)
  being:msg("You feel protected.")
  Skulltag.AnnouncerPlaySound("resistance")
  being.armor = being.armor + ResistanceBonus
end
local ReactivateRuneResistance = function (being)
end
local NewBeingRuneResistance   = function (being)
end
local OnTickRuneResistance     = function (being)
end
local OnKillRuneResistance     = function (being, being_dead)
end
local DeactivateRuneResistance = function (being)
  being.armor = being.armor - ResistanceBonus
end
local ActivateRuneProsperity   = function (being)
  --equiv to badass as well as some healing item magic
  --Decay still occurs, rather not apply the bodybonus
  --just for the decay
  being:msg("You feel your limits increase.")
  Skulltag.AnnouncerPlaySound("prosperity")
end
local ReactivateRuneProsperity = function (being)
end
local NewBeingRuneProsperity   = function (being)
end
local OnTickRuneProsperity     = function (being)
end
local OnKillRuneProsperity     = function (being, being_dead)
end
local DeactivateRuneProsperity = function (being)
end
local ActivateRuneRage    = function (being)
  being:msg("You launch into a frenzy!")
  Skulltag.AnnouncerPlaySound("rage")

  being.firetime   = being.firetime   * RageBonus
  being.reloadtime = being.reloadtime * RageBonus
end
local ReactivateRuneRage  = function (being)
end
local NewBeingRuneRage    = function (being)
end
local OnTickRuneRage      = function (being)
end
local OnKillRuneRage      = function (being, being_dead)
end
local DeactivateRuneRage  = function (being)
  being.firetime   = being.firetime   / RageBonus
  being.reloadtime = being.reloadtime / RageBonus
end
local ActivateRuneSpread   = function (being)
  being:msg("You feel multiplied!")
  Skulltag.AnnouncerPlaySound("spread")
end
local ReactivateRuneSpread = function (being)
end
local NewBeingRuneSpread   = function (being)
end
local OnTickRuneSpread     = function (being)
end
local OnKillRuneSpread     = function (being, being_dead)
end
local DeactivateRuneSpread = function (being)
end
local ActivateRuneRegeneration   = function (being)
  being:msg("You feel healthy.")
  Skulltag.AnnouncerPlaySound("regeneration")
end
local ReactivateRuneRegeneration = function (being)
end
local NewBeingRuneRegeneration   = function (being)
end
local OnTickRuneRegeneration     = function (being)
  --regenerate faster when wounded
  being.hp_fraction = being.hp_fraction + ((being.hpmax - being.hp) / being.hpmax) * MaxRegenerationPerTick

  local heal = math.floor(being.hp_fraction)
  if(heal >= 1) then
    being.hp_fraction = being.hp_fraction - heal
    Skulltag.Healing.AddBeingHP(being, heal, false)
  end
end
local OnKillRuneRegeneration     = function (being, being_dead)
end
local DeactivateRuneRegeneration = function (being)
end
local ActivateRuneReflection   = function (being)
  being:msg("You feel like rubber.")
  Skulltag.AnnouncerPlaySound("reflection")
  being.hp_last_tick = being.hp
end
local ReactivateRuneReflection = function (being)
end
local NewBeingRuneReflection   = function (being)
end
local OnTickRuneReflection     = function (being)
  if(being.hp_last_tick > being.hp) then
    --In Doom the player has a lot of health and enemies often have less.  In DoomRL the opposite is true.
    --Therefore reflection bounces back more than half damage.
    local damage = being.hp_last_tick - being.hp
    being.hp_last_tick = being.hp

    if(damage > 1) then --Fairest way to bypass health decay
      damage = math.floor((damage) * RateReflected)
      local victim = nil
      local distance1 = 99

      for b in level:beings() do --get closest being
        if(b:is_player() == false and b.__ptr) then
          local distance2 = coord.distance(b.position, being.position)
          if(distance2 < distance1) then
            distance1 = distance2
            victim = b
          end
        end
      end

      if(victim) then --Cause him hurt
         victim.hp = victim.hp - damage
         if(victim.hp <= 0) then --Kill 'em
           victim:kill()
         else --Make him wail in pain
           victim:play_sound(victim.SoundHit)
         end
      end

    end
  end
end
local OnKillRuneReflection     = function (being, being_dead)
end
local DeactivateRuneReflection = function (being)
end
local ActivateRuneDrain   = function (being)
  being:msg("You feel a desire to feed.")
  Skulltag.AnnouncerPlaySound("drain")
end
local ReactivateRuneDrain = function (being)
end
local NewBeingRuneDrain   = function (being)
end
local OnTickRuneDrain     = function (being)
end
local OnKillRuneDrain     = function (being, being_dead)

  --Would be nice if OnAttacked included damage or weapon ownership.  Would be nice if
  --OnKill offered a bit more too.  But it doesn't.  Oh well.
  being.hp_fraction = being.hp_fraction + being_dead.hpmax * RateDrained

  local heal = math.floor(being.hp_fraction)
  if(heal >= 1) then
    being.hp_fraction = being.hp_fraction - heal
    Skulltag.Healing.AddBeingHP(being, heal, false)
  end
end
local DeactivateRuneDrain = function (being)
end
local ActivateRuneHighjump   = function (being)
  being:msg("You feel like you could fly.")
  Skulltag.AnnouncerPlaySound("highjump")
end
local ReactivateRuneHighjump = function (being)
end
local NewBeingRuneHighjump   = function (being)
end
local OnTickRuneHighjump     = function (being)
    being:msg("1")
end
local OnKillRuneHighjump     = function (being, being_dead)
end
local DeactivateRuneHighjump = function (being)
end
local ActivateRuneHaste   = function (being)
  being:msg("You feel faster.")
  Skulltag.AnnouncerPlaySound("haste")

  being.movetime = being.movetime * HasteBonus
end
local ReactivateRuneHaste = function (being)
end
local NewBeingRuneHaste   = function (being)
end
local OnTickRuneHaste     = function (being)
  if(being.tired == true) then
    being.tired = false
  end
end
local OnKillRuneHaste     = function (being, being_dead)
end
local DeactivateRuneHaste = function (being)
  being.movetime = being.movetime / HasteBonus
end

--switch-like tables
local ActivateRuneTable   = {
  ActivateRuneNone,
  ActivateRuneStrength,
  ActivateRuneResistance,
  ActivateRuneProsperity,
  ActivateRuneRage,
  ActivateRuneSpread,
  ActivateRuneRegeneration,
  ActivateRuneReflection,
  ActivateRuneDrain,
  ActivateRuneHighjump,
  ActivateRuneHaste,
}
local ReactivateRuneTable = {
  ReactivateRuneNone,
  ReactivateRuneStrength,
  ReactivateRuneResistance,
  ReactivateRuneProsperity,
  ReactivateRuneRage,
  ReactivateRuneSpread,
  ReactivateRuneRegeneration,
  ReactivateRuneReflection,
  ReactivateRuneDrain,
  ReactivateRuneHighjump,
  ReactivateRuneHaste,
}
local DeactivateRuneTable = {
  DeactivateRuneNone,
  DeactivateRuneStrength,
  DeactivateRuneResistance,
  DeactivateRuneProsperity,
  DeactivateRuneRage,
  DeactivateRuneSpread,
  DeactivateRuneRegeneration,
  DeactivateRuneReflection,
  DeactivateRuneDrain,
  DeactivateRuneHighjump,
  DeactivateRuneHaste,
}
local NewBeingRuneTable   = {
  NewBeingRuneNone,
  NewBeingRuneStrength,
  NewBeingRuneResistance,
  NewBeingRuneProsperity,
  NewBeingRuneRage,
  NewBeingRuneSpread,
  NewBeingRuneRegeneration,
  NewBeingRuneReflection,
  NewBeingRuneDrain,
  NewBeingRuneHighjump,
  NewBeingRuneHaste,
}
local OnTickRuneTable     = {
  OnTickRuneNone,
  OnTickRuneStrength,
  OnTickRuneResistance,
  OnTickRuneProsperity,
  OnTickRuneRage,
  OnTickRuneSpread,
  OnTickRuneRegeneration,
  OnTickRuneReflection,
  OnTickRuneDrain,
  OnTickRuneHighjump,
  OnTickRuneHaste,
}
local OnKillRuneTable     = {
  OnKillRuneNone,
  OnKillRuneStrength,
  OnKillRuneResistance,
  OnKillRuneProsperity,
  OnKillRuneRage,
  OnKillRuneSpread,
  OnKillRuneRegeneration,
  OnKillRuneReflection,
  OnKillRuneDrain,
  OnKillRuneHighjump,
  OnKillRuneHaste,
}

local ActivateRune    = function (arg_rune, arg_being)
  assert(type(ActivateRuneTable[arg_rune]) == "function")
  ActivateRuneTable[arg_rune](arg_being)
  Skulltag.HUD.MarkDirty()
  Skulltag.HUD.Redraw()
end
local ReactivateRune  = function (arg_rune, arg_being)
  assert(type(ReactivateRuneTable[arg_rune]) == "function")
  ReactivateRuneTable[arg_rune](arg_being)
end
local NewBeingRune    = function (arg_rune, arg_being)
  assert(type(NewBeingRuneTable[arg_rune]) == "function")
  NewBeingRuneTable[arg_rune](arg_being)
end
local OnTickRune      = function (arg_rune, arg_being)
  assert(type(OnTickRuneTable[arg_rune]) == "function")
  OnTickRuneTable[arg_rune](arg_being)
end
local OnKillRune      = function (arg_rune, arg_being, arg_being_dead)
  assert(type(OnKillRuneTable[arg_rune]) == "function")
  OnKillRuneTable[arg_rune](arg_being, arg_being_dead)
end
local DeactivateRune  = function (arg_rune, arg_being)
  assert(type(DeactivateRuneTable[arg_rune]) == "function")
  DeactivateRuneTable[arg_rune](arg_being)
  Skulltag.HUD.MarkDirty()
  Skulltag.HUD.Redraw()
end

--exposed interface implementation
Skulltag.Runes.PickupRune     = function(arg_being, arg_rune)
  DeactivateRune(player.rune, arg_being)
  player.rune = arg_rune
  ActivateRune(arg_rune, arg_being)
end
Skulltag.Runes.RunNewBeingRunes = function (arg_being)
  NewBeingRune(player.rune, player, arg_being)
end
Skulltag.Runes.RunTickRunes   = function()
  OnTickRune(player.rune, player)
end
Skulltag.Runes.RunOnKillRunes = function(arg_being)
  OnKillRune(player.rune, player, arg_being)
end

--Actual rune declarations
register_item "sr_strength" {
  name       = "Strength Rune",
  color      = GREEN,
  sprite     = SPRITE_SKULL,
  coscolor   = { 0.1,0.8,0.1,1.0 },
  glow       = { 0.0,0.5,0.0,1.0 },
  ascii      = "ã",
  --asciilow   = "*",
  level      = 5,
  weight     = RuneWeight,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Skulltag.Runes.PickupRune(being, RUNE_STRENGTH)
  end
}
register_item "sr_resistance" {
  name       = "Resistance Rune",
  color      = GREEN,
  sprite     = SPRITE_SKULL,
  coscolor   = { 0.1,0.8,0.8,1.0 },
  glow       = { 0.0,0.5,0.5,1.0 },
  ascii      = "å",
  --asciilow   = "*",
  level      = 6,
  weight     = RuneWeight,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Skulltag.Runes.PickupRune(being, RUNE_RESISTANCE)
  end
}
register_item "sr_prosperity" {
  name       = "Prosperity Rune",
  color      = LIGHTGREEN,
  sprite     = SPRITE_SKULL,
  coscolor   = { 0.1,1.0,0.1,1.0 },
  glow       = { 0.0,1.0,0.0,1.0 },
  ascii      = "æ",
  --asciilow   = "*",
  level      = 4,
  weight     = RuneWeight,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Skulltag.Runes.PickupRune(being, RUNE_PROSPERITY)
  end
}
register_item "sr_rage" {
  name       = "Rage Rune",
  color      = RED,
  sprite     = SPRITE_SKULL,
  coscolor   = { 1.0,0.5,0.1,1.0 },
  glow       = { 1.0,0.5,0.0,1.0 },
  ascii      = "ç",
  --asciilow   = "*",
  level      = 6,
  weight     = RuneWeight,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Skulltag.Runes.PickupRune(being, RUNE_RAGE)
  end
}
--[[register_item "sr_spread" {
  name       = "Spread Rune",
  color      = LIGHTRED,
  sprite     = SPRITE_SKULL,
  coscolor   = { 1.0,0.1,0.5,1.0 },
  glow       = { 1.0,0.0,0.5,1.0 },
  ascii      = "à",
  --asciilow   = "*",
  level      = 0,
  weight     = RuneWeight,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Skulltag.Runes.PickupRune(being, RUNE_SPREAD)
  end
}--]]
register_item "sr_regeneration" {
  name       = "Regeneration Rune",
  color      = LIGHTRED,
  sprite     = SPRITE_SKULL,
  coscolor   = { 1.0,0.1,0.1,1.0 },
  glow       = { 1.0,0.0,0.0,1.0 },
  ascii      = "â",
  --asciilow   = "*",
  level      = 9,
  weight     = RuneWeight,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Skulltag.Runes.PickupRune(being, RUNE_REGENERATION)
  end
}
register_item "sr_reflection" {
  name       = "Reflection Rune",
  color      = LIGHTMAGENTA,
  sprite     = SPRITE_SKULL,
  coscolor   = { 1.0,0.1,1.0,1.0 },
  glow       = { 1.0,0.0,1.0,1.0 },
  ascii      = "ê",
  --asciilow   = "*",
  level      = 8,
  weight     = RuneWeight,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Skulltag.Runes.PickupRune(being, RUNE_REFLECTION)
  end
}
register_item "sr_drain" {
  name       = "Drain Rune",
  color      = RED,
  sprite     = SPRITE_SKULL,
  coscolor   = { 0.8,0.1,0.1,1.0 },
  glow       = { 0.5,0.0,0.0,1.0 },
  ascii      = "á",
  --asciilow   = "*",
  level      = 7,
  weight     = RuneWeight,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Skulltag.Runes.PickupRune(being, RUNE_DRAIN)
  end
}
--[[register_item "sr_highjump" {
  name       = "Highjump Rune",
  color      = LIGHTGREEN,
  sprite     = SPRITE_SKULL,
  coscolor   = { 0.5,1.0,0.1,1.0 },
  glow       = { 0.5,1.0,0.0,1.0 },
  ascii      = "ï",
  --asciilow   = "*",
  level      = 0,
  weight     = RuneWeight,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Skulltag.Runes.PickupRune(being, RUNE_HIGHJUMP)
  end
}--]]
register_item "sr_haste" {
  name       = "Haste Rune",
  color      = YELLOW,
  sprite     = SPRITE_SKULL,
  coscolor   = { 1.0,1.0,0.1,1.0 },
  glow       = { 1.0,1.0,0.0,1.0 },
  ascii      = "ë",
  --asciilow   = "*",
  level      = 10,
  weight     = RuneWeight,
  type       = ITEMTYPE_POWER,
  flags      = { IF_GLOBE },
  OnPickup   = function(self,being)
    Skulltag.Runes.PickupRune(being, RUNE_HASTE)
  end
}


--init code.
Skulltag.Runes.Init = function ()
  --unused
  for i=2, #beings, 1 do
    beings[i].OnCreate = core.create_seq_function(beings[i].OnCreate,
    function(self)
      Skulltag.Runes.RunNewBeingRunes(self)
    end)
  end

  for i=2, #beings, 1 do
    beings[i].OnDie = core.create_seq_function(beings[i].OnDie,
    function(self)
      Skulltag.Runes.RunOnKillRunes(self)
    end)
  end
end