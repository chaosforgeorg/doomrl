--[[Mod assemblies are hard to make plausible in normal gameplay.  They're virtually
    impossible to do so in WolfRL.  For that reason I am grading on a curve, but if
    an assembly falls below a certain bare minimum threshold for believability it
    goes pronto.

    In earlier versions of DoomRL mod order actually affected the result.  This was
    intentional at the time but met with some backlash and all assemblies were recoded
    to result in the same property values regardless of mod order.  Booo-ring.
    I am sticking with the old way, at least in some circumstances, because I think
    it is more fun.
--]]
function DoomRL.load_mod_arrays()

-- Basic assemblies --
	register_mod_array "pblade" {
		name  = "piercing blade",
		mods  = { P = 1, A = 1 },
		request_type = ITEMTYPE_MELEE,

		OnApply = function (item)
			item.name         = "piercing "..item.name
			item.damagetype   = DAMAGE_IGNOREARMOR
		end,
	}
	register_mod_array "speedloader" {
		name  = "speedloader pistol",
		mods  = { A = 1, T = 1 },
		desc  = "any pistol",

		Match = function (item)
			return item.flags[IF_PISTOL] and not item.flags[IF_UNIQUE]
		end,

		OnApply = function (item)
			item.name       = "speedloader " .. item.name
			item.reloadtime = item.reloadtime / 2
		end,
	}
	register_mod_array "micro" {
		name  = "micro launcher",
		mods  = { T = 2 },
		request_id = "wolf_bazooka",

		OnApply = function (item)
			item.name         = "micro launcher"
			item.reloadtime   = 8
			item.usetime      = 8
			item.damage_dice  = 5
			item.damage_sides = 5
			item.acc          = 7
			item.blastradius  = 3
		end,
	}
	register_mod_array "tarmor" {
		name  = "tactical armor",
		mods  = { A = 2 },
		request_id = "wolf_armor1",

		OnApply = function (item)
			item.name         = "tactical armor"
			item.movemod      = 15
			item.dodgemod     = 10
			item.armor        = 0
			item.resist.shrapnel = 0
			item.resist.bullet   = 0

			item.flags[ IF_RECHARGE ] = true
			item.rechargeamount       = 2
			item.rechargedelay        = 10

		end,
	}
	register_mod_array "tboots" {
		name  = "tactical boots",
		mods  = { A = 2 },
		request_id = "wolf_boots1",

		OnApply = function (item)
			item.name      = "tactical boots"
			item.movemod   = 15
			item.dodgemod  = 0
			item.knockmod  = 0
			item.armor     = 0

			item.flags[ IF_RECHARGE ] = true
			item.rechargeamount       = 2
			item.rechargedelay        = 10

		end,
	}
	register_mod_array "nanofiber" {
		name  = "nanofiber armor",
		mods  = { P = 1, B = 1 },
		request_type = ITEMTYPE_ARMOR,

		OnApply = function (item)
			item.name    = "nanofiber "..item.name
			item.movemod = item.__proto.movemod
			item.armor   = math.ceil(item.__proto.armor / 2)
			item.resist.bullet = math.ceil((item.__proto.resist.bullet or 0) / 2)
			item.resist.shrapnel = math.ceil((item.__proto.resist.shrapnel or 0) / 2)
			item.resist.melee = math.ceil((item.__proto.resist.melee or 0) / 2)
			item.resist.fire = math.ceil((item.__proto.resist.fire or 0) / 2)
			item.resist.acid = math.ceil((item.__proto.resist.acid or 0) / 2)
			item.resist.plasma = math.ceil((item.__proto.resist.plasma or 0) / 2)
			item.flags[ IF_NODURABILITY ] = true
		end,
	}
	register_mod_array "high" {
		name  = "high power weapon",
		mods  = { P = 1, B = 1 },
		desc  = "magazine > 5, non-shotgun",
		request_type = ITEMTYPE_RANGED,

		Match = function (item)
			return item.ammomax > 5 and (not item.flags[ IF_SHOTGUN ] )
		end,

		OnApply = function (item)
			item.name = "high power "..item.name
			item.ammomax = item.ammomax * 0.65
			item.ammo = math.min( item.ammo, item.ammomax )
			if item.__proto.damage_sides >= item.__proto.damage_dice then
				item.damage_sides = item.__proto.damage_sides + 2
			else
				item.damage_dice  = item.__proto.damage_dice + 2
			end
		end,
	}
	register_mod_array "tshotgun" {
		name  = "tactical shotgun",
		mods  = { P = 1, T = 1 },
		request_id = "wolf_shotgun",

		OnApply = function (item)
			item.name    = "tactical shotgun"
			item.ammomax = item.__proto.ammomax - 1
			item.flags[ IF_PUMPACTION ] = false
			item.flags[ IF_CHAMBEREMPTY ] = false
		end,
	}
	register_mod_array "tower" {
		name  = "tower shield",
		mods  = { P = 1, O = 1 },
		id = "plate",
		request_id = "wolf_armor3",

		OnApply = function (item)
			item.name           = "tower shield"
			item.armor          = 12
			item.durability     = 150
			item.maxdurability  = 150
			item.movemod        = -50
			item.knockmod       = -90
			item.resist.fire       = 0
			item.flags[ IF_NOREPAIR ] = true
			item.flags[ IF_NONMODABLE ] = true
			item.flags[ IF_NODEGRADE ] = true
			item.flags[ IF_NODURABILITY ] = false
		end,
	}
	register_mod_array "fparmor" {
		name  = "fireproof armor",
		mods  = { B = 1, T = 1 },
		request_type = ITEMTYPE_ARMOR,

		OnApply = function (item)
			item.name          = "fireproof "..item.name
			item.durability    = item.maxdurability
			item.resist.melee     = (item.resist.melee or 0) - 30
			item.resist.fire      =  math.min( (item.resist.fire or 0) + 30, 95 )
		end,
	}
	register_mod_array "fpboots" {
		name  = "fireproof boots",
		mods  = { B = 1, T = 1 },
		request_type = ITEMTYPE_BOOTS,

		OnApply = function (item)
			item.name          = "fireproof "..item.name
			item.durability    = item.maxdurability
			item.resist.fire      =  math.min( (item.resist.fire or 0) + 30, 95 )
		end,
	}
	register_mod_array "balarmor" {
		name  = "ballistic armor",
		mods  = { A = 1, T = 1 },
		request_type = ITEMTYPE_ARMOR,

		OnApply = function (item)
			item.name          = "ballistic "..item.name
			item.resist.melee     = math.min( (item.resist.melee or 0) + 30, 95 )
			item.resist.bullet    = math.min( (item.resist.bullet or 0) + 30, 95 )
			item.resist.shrapnel  = math.min( (item.resist.shrapnel or 0) + 30, 95 )
			item.resist.fire      = (item.resist.fire or 0) - 30
			item.resist.plasma    = 0
			item.resist.acid      = 0
		end,
	}
	register_mod_array "gboots" {
		name  = "grappling boots",
		mods  = { T = 2 },
		request_type = ITEMTYPE_BOOTS,

		OnApply = function (item)
			item.name      = "grappling "..item.name
			item.movemod   = item.__proto.movemod - 10
			item.armor     = item.armor + 1
			item.knockmod  = math.max( -90, item.__proto.knockmod - 50 )
		end,
	}
	register_mod_array "lavboots" {
		name  = "lava boots",
		mods  = { T = 1, O = 1 },
		request_type = ITEMTYPE_BOOTS,

		OnApply = function (item)
			item.name          = "lava "..item.name
			item.movemod       = -30
			item.knockmod      = -30
			item.resist.fire      = 100
			item.flags[ IF_NODURABILITY ] = true
		end,
	}

-- Advanced assemblies
	register_mod_array "tacticalrl" {
		name  = "tactical rocket launcher",
		mods  = { B = 3 },
		level = 1,
		request_id = "wolf_bazooka",

		OnApply = function (item)
			item.name        = "tactical " .. item.name
			item.ammomax     = 5
			item.blastradius = 2
			item.flags[ IF_AUTOHIT ] = true
		end,
	}
	register_mod_array "bolter" {
		name  = "bolter pistol",
		mods  = { B = 2, T = 1 },
		level = 1,
		desc = "any pistol",

		Match = function (item)
			return item.flags[IF_PISTOL] and not item.flags[IF_UNIQUE]
		end,

		OnApply = function (item)
			item.name           = "bolter " .. item.name
			item.acc            = item.__proto.acc - 2
			item.usetime        = item.__proto.fire * 0.85
			item.damage_dice    = 1
			item.damage_sides   = item.__proto.damage_dice * item.__proto.damage_sides
			item.shots          = 2
			item.ammomax        = math.floor(item.__proto.ammomax * 1.5)
			item.ammo           = math.min(item.ammo, item.ammomax)
			item.reloadtime     = item.__proto.reload
		end,
	}
	register_mod_array "rifle" {
		name  = "assault machinepistol",
		mods  = { A = 3 },
		level = 1,
		desc = "any sub",

		Match = function (item)
			return (item.itype == ITEMTYPE_RANGED) and item.__proto.group == "weapon-sub" and item.flags[IF_UNIQUE] == false
		end,

		OnApply = function (item)
			item.name         = "assault "..item.name
			item.acc          = item.__proto.acc + 2
			item.ammomax      = math.floor(item.__proto.ammomax / 2)
			item.reloadtime   = item.__proto.reload / 2
			item.damage_dice  = item.__proto.damage_dice + 1
			item.damage_sides = item.__proto.damage_sides - 1
		end,
	}
	register_mod_array "assault" {
		name  = "burst cannon",
		mods  = { P = 1, B = 2 },
		level = 1,
		desc = "any rapid-fire",

		Match = function(item)
			return (item.itype == ITEMTYPE_RANGED) and (item.__proto.group == "weapon-sub" or item.__proto.group == "weapon-auto"or item.__proto.group == "weapon-assault") and item.flags[IF_UNIQUE] == false
		end,

		OnApply = function (item)
			item.name           = "burst "..item.name
			item.acc            = item.acc - 2
			item.damage_dice    = 1
			item.damage_sides   = item.damage_sides + 1
			item.shots          = item.shots + 2
			item.reloadtime     = item.reloadtime * 1.5
		end,
	}
	register_mod_array "envboots" {
		name  = "enviromental boots",
		level = 1,
		mods  = { P = 1, B = 1, T = 1 },
		request_type = ITEMTYPE_BOOTS,

		OnApply = function (item)
			item.name          = "enviromental "..item.name
			item.durability    = item.maxdurability
			item.resist.fire      = math.min( (item.__proto.resist.fire or 0) + 75, 90 )
			item.resist.acid      = math.min( (item.__proto.resist.acid or 0) + 75, 90 )
		end,
	}
	register_mod_array "fireshield" {
		name  = "fire shield",
		mods  = { B = 1, T = 1, O = 1 },
		level = 1,
		request_id = "wolf_armor3",

		OnApply = function (item)
			item.name          = "fire shield"
			item.movemod       = -20
			item.knockmod      = 0
			item.resist.fire      = 95
			item.maxdurability = 200
			item.durability    = item.maxdurability
			item.flags[ IF_NOREPAIR ] = true
			item.flags[ IF_NONMODABLE ] = true
			item.flags[ IF_NODEGRADE ] = true
			item.flags[ IF_NODURABILITY ] = false
		end,
	}

-- Master assemblies
	register_mod_array "demolition" {
		name  = "demolition ammo",
		mods  = { P = 1, T = 2, F = 1 },
		level = 2,
		desc  = "pistol cartridge weapon",

		Match = function (item)
			return item.itype == ITEMTYPE_RANGED and (item.ammoid == "wolf_9mm" or item.ammoid == "wolf_45acp")
		end,

		OnApply = function (item)
			item.name            = "demolition " .. item.name
			item.damage_dice     = math.ceil( item.__proto.damage_dice * item.__proto.damage_sides / 2 )
			item.blastradius     = 1
			item.damagetype      = DAMAGE_FIRE
		end,
	}
	register_mod_array "ripper" {
		name  = "ripper",
		mods  = {P = 2, B = 1, T = 1},
		level = 2,
		request_id = "wolf_knife",

		OnApply = function (item)
			item.name         = "ripper"
			item.damage_dice  = 6
			item.damage_sides = 6
			item.usetime      = 5
			item.acc          = -4
		end,
	}
	register_mod_array "cerboots" {
		name  = "cerberus boots",
		mods  = { P = 2, T = 1, A = 1 },
		level = 2,
		request_type = ITEMTYPE_BOOTS,

		OnApply = function (item)
			item.name     = "cerberus "..item.name
			item.armor    = 0
			item.movemod  = -30
			item.knockmod = -30
			item.resist.fire = 100
			item.resist.acid = 100
		end,
	}
	register_mod_array "cerarmor" {
		name  = "cerberus armor",
		mods  = { P = 2, T = 1, A = 1 },
		level = 2,
		request_type = ITEMTYPE_ARMOR,

		OnApply = function (item)
			item.name       = "cerberus "..item.name
			item.armor      = 0
			item.movemod    = -30
			item.knockmod   = -30
			item.resist.fire   = 70
			item.resist.acid   = 70
			item.resist.plasma = 50
		end,
	}

end
