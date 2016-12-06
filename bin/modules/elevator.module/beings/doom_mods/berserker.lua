--The berserker is part of the logical progression involving former humans.  They also show up in KDIZD and others.
require("elevator:ai/zerker_ai")

register_item "nat_zerker" {
  name       = "chainsaw",
  color      = RED,
  level      = 10,
  weight     = 100,
  type       = ITEMTYPE_MELEE,
  damage     = "4d6",
  damagetype = DAMAGE_MELEE,
  group      = "weapon-chain",
  desc       = "Chainsaw -- cuts through flesh like a hot knife through butter",
  psprite    = 0,
  sprite     = 0,
  flags      = { IF_NODROP },
}

register_being "zerker" {
	name         = "berserker",
	ascii        = "h",
	color        = YELLOW,
	sprite       = 0,
	hp           = 15,
	armor        = 0,
	speed        = 100,
	todam        = 4,
	tohit        = 1,
	min_lev      = 4,
	max_lev      = 14,
	corpse       = true,
	danger       = 2,
	weight       = 2,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "zerker_ai",

	resist = { melee = 20 },

	desc            = "Berserkers are hopped up on the best drugs the UAC can buy. Go shoot them.",
	kill_desc_melee = "sliced by a madman with a chainsaw",

	OnCreate = function(self)
		self.eq.weapon = item.new("nat_zerker")
		self.inv:add( item.new("skchainsaw") )
	end,
}

--Fixing up sounds
local FixSounds = function()
	beings["zerker"].sound_hit   = core.resolve_sound_id("former.pain")
	beings["zerker"].sound_die   = core.resolve_sound_id("soldier.die")
	beings["zerker"].sound_act   = core.resolve_sound_id("zerker.act")
	beings["zerker"].sound_melee = core.resolve_sound_id("soldier.melee")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)
