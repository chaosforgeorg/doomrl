--nothing special here
--[[ New Weapons (skulltag):
     Chainsaw
     Minigun
     Grenade Launcher --not possible
     Railgun
     BFG9K
     BFG10K
--]]

Skulltag.Items = {}
Skulltag.Items.Init = nil

register_missile "mskminigun" {
  sound_id   = "skminigun",
  ascii      = "-",
  color      = WHITE,
  sprite     = SPRITE_SHOT,
  delay      = 25,
  miss_base  = 10,
  miss_dist  = 3,
}
register_missile "mskrailray" {
  sound_id   = "skrailgun",
  ascii      = "-",
  color      = LIGHTMAGENTA,
  sprite     = SPRITE_SHOT,
  delay      = 5,
  miss_base  = 3,
  miss_dist  = 10,
  maxrange   = 10,
  flags      = { MF_RAY, MF_HARD },
}
register_missile "mskbfg10k" {
  sound_id   = "skbfg10000",
  ascii      = "*",
  color      = LIGHTGREEN,
  sprite     = SPRITE_BFGSHOT,
  delay      = 40,
  miss_base  = 30,
  miss_dist  = 5,
  expl_delay = 80,
  expl_color = GREEN,
  expl_flags = { EFHALFKNOCK },
}
register_item "skchainsaw" {
  name       = "chainsaw",
  color      = RED,
  sprite     = SPRITE_CHAINSAW,
  psprite    = SPRITE_PLAYER_CHAINSAW,
  level      = 10,
  weight     = 100,
  type       = ITEMTYPE_MELEE,
  damage     = "4d6",
  damagetype = DAMAGE_MELEE,
  group      = "weapon-melee",
  desc       = "Chainsaw -- cuts through flesh like a hot knife through butter",
  OnFirstPickup = function(self,being)

    if not being:is_player() then return end

    ui.blink(LIGHTRED, 100)
    Skulltag.Powerups.PickupPowerup(being, POWER_BERSERK)
    Skulltag.Healing.AddBeingHP(being, being.hpmax, false)
    being.tired = false
    being:quick_weapon("skchainsaw")
    ui.msg("Find some meat!")
  end,
}

register_item "skminigun" {
  name       = "minigun",
  color      = MAGENTA,
  sprite     = SPRITE_CHAINGUN,
  psprite    = SPRITE_PLAYER_CHAINGUN,
  glow       = { 1.0,0.0,1.0,1.0 },
  level      = 10,
  weight     = 80,
  type       = ITEMTYPE_RANGED,
  ammo_id    = "ammo",
  ammomax    = 200,
  desc       = "Spits enough lead into air to be considered an environmental hazard",
  acc        = 2,
  damage     = "1d6",
  damagetype = DAMAGE_BULLET,
  missile    = "mskminigun",
  shots      = 8,
  reload     = 35,
  fire       = 12,
  group      = "weapon-chain",
  altfire    = ALT_CHAIN,
}
register_item "skrailgun" {
  name       = "railgun",
  color      = BLUE,
  sprite     = SPRITE_PLASMA,
  psprite    = SPRITE_PLAYER_PLASMA,
  glow       = { 1.0,0.0,1.0,1.0 },
  level      = 16,
  weight     = 60,
  type       = ITEMTYPE_RANGED,
  ammo_id    = "cell",
  ammomax    = 40,
  desc       = "You'll sleep safer with one of these by your side",
  acc        = 12,
  damage     = "8d8",
  damagetype = DAMAGE_IGNOREARMOR,
  missile    = "mskrailray",
  shotcost   = 10,
  group      = "weapon-plasma",
  reload     = 20,
  fire       = 15,
}
register_item "skbfg9000" {
  name       = "BFG 9000",
  color      = GREEN,
  sprite     = SPRITE_BFG9000,
  psprite    = SPRITE_PLAYER_BFG9000,
  glow       = { 1.0,0.0,1.0,1.0 },
  level      = 20,
  weight     = 50,
  type       = ITEMTYPE_RANGED,
  ammo_id    = "cell",
  ammomax    = 100,
  desc       = "The Big Fucking Gun. Hell wouldn't be so fun without it",
  acc        = 5,
  damage     = "10d8",
  damagetype = DAMAGE_PLASMA,
  missile    = "mbfg",
  overcharge = "mbfgover",
  radius     = 10,
  reload     = 20,
  fire       = 10,
  shotcost   = 40,
  group      = "weapon-bfg",

  altreload = RELOAD_SCRIPT,
  altreloadname = "overcharge",

  OnAltReload = items["bfg9000"].OnAltReload,
}
register_item "skbfg10000" {
  name       = "BFG 10000",
  color      = LIGHTGREEN,
  sprite     = SPRITE_BFG10K,
  psprite    = SPRITE_PLAYER_BFG9000,
  glow       = { 1.0,0.0,1.0,1.0 },
  level      = 20,
  weight     = 35,
  type       = ITEMTYPE_RANGED,
  ammo_id    = "cell",
  ammomax    = 45,
  desc       = "The Ultimate Big Fucking Gun. Redefines the word \"wallpaper\".",
  acc        = 3,
  damage     = "6d6",
  damagetype = DAMAGE_PLASMA,
  missile    = "mskbfg10k",
  radius     = 2,
  shots      = 5,
  reload     = 20,
  fire       = 10,
  shotcost   = 3,
  group      = "weapon-bfg",
  altfire    = ALT_CHAIN,
  flags      = { IF_SCATTER, IF_MODABLE, IF_SINGLEMOD }
}

--Lacking a better place, backpack goes here
register_item "skbackpack" {
  name       = "Backpack",
  ascii      = "]",
  color      = BROWN,
  sprite     = SPRITE_BACKPACK,
  type       = ITEMTYPE_POWER,
  level      = 10,
  weight     = 10,
  sprite     = 0,

  OnPickup = function(self,being)

    if(being.flags[BF_BACKPACK]) then
      ui.msg("Another backpack?")
    else
      ui.msg("Sweet! More room!")
      ui.blink(YELLOW, 50)
      being:power_backpack()
    end
  end
}

--init code.
Skulltag.Items.Init = function()

  --Early sandbox didn't have exotics so I made custom ones.
  --And I'm keeping them.  I like my exotics better.
  items["chainsaw"].weight = 0
  items["bfg9000"].weight  = 0
  items["uminigun"].weight = 0
  items["urailgun"].weight = 0
  items["ubfg10k"].weight = 0
  items["backpack"].weight = 0

  --Remap assemblies
  mod_arrays["double"].request_id   = "skchainsaw"
  mod_arrays["ripper"].request_id   = "skchainsaw"
  mod_arrays["vbfg9000"].request_id = "skbfg9000"
end
