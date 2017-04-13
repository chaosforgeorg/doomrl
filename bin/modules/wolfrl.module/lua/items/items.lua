function DoomRL.loaditems()

	-- Armors --
	register_item "wolf_armor1" {
		name     = "light armor",
		color    = WHITE,
		sprite   = SPRITE_ARMOR,
		coscolor = { 1.0,1.0,1.0,1.0 },
		level    = 1,
		weight   = 200,
		desc     = "This armor is flexible and lightweight and still helps protect against light arms fire.",

		type       = ITEMTYPE_ARMOR,
		armor      = 1,
		movemod    = 0,
	}
	register_item "wolf_armor2" {
		name     = "medium armor",
		color    = BLUE,
		sprite   = SPRITE_ARMOR,
		coscolor = { 0.0,0.0,1.0,1.0 },
		level    = 4,
		weight   = 150,
		desc     = "This armor boasts decent protection without too much bulk.",

		type       = ITEMTYPE_ARMOR,
		armor      = 2,
		movemod    = -10,
	}
	register_item "wolf_armor3" {
		name     = "heavy armor",
		color    = DARKGRAY,
		sprite   = SPRITE_ARMOR,
		coscolor = { 0.3,0.3,0.3,1.0 },
		level    = 9,
		weight   = 150,
		desc     = "This armor is slow, heavy, and able to deflect artillery. The perfect thing for a walking tank like you.",

		resist = { bullet = 10, shrapnel = 10, fire = 10 },

		type       = ITEMTYPE_ARMOR,
		armor      = 4,
		movemod    = -20,
	}

	register_item "wolf_boots1" {
		name     = "boots",
		color    = BROWN,
		sprite   = SPRITE_SBOOTS,
		coscolor = { 0.5,0.5,0.3,1.0 },
		level    = 4,
		weight   = 100,
		flags    = { IF_PLURALNAME },
		desc     = "These boots will keep your feet warm.",

		type       = ITEMTYPE_BOOTS,
		armor      = 1,
		knockmod   = -10,
	}
	register_item "wolf_boots2" {
		name     = "combat boots",
		color    = LIGHTGRAY,
		sprite   = SPRITE_BOOTS,
		coscolor = { 0.7,0.7,0.7,1.0 },
		level    = 7,
		weight   = 80,
		flags    = { IF_PLURALNAME },
		desc     = "These boots are made for walking.",

		resist = { acid = 25 },

		type       = ITEMTYPE_BOOTS,
		armor      = 2,
		knockmod   = -20,
	}
	register_item "wolf_boots3" {
		name     = "heavy boots",
		color    = DARKGRAY,
		sprite   = SPRITE_BOOTS,
		coscolor = { 0.3,0.3,0.3,1.0 },
		level    = 11,
		weight   = 60,
		flags    = { IF_PLURALNAME },
		desc     = "If the shoes make the man these shoes make you invincible.",

		resist = { acid = 50, fire = 25 },

		type       = ITEMTYPE_BOOTS,
		armor      = 4,
		knockmod   = -50,
	}


	-- Powerups --
	register_item "wolf_food1" {
		name     = "dog food bowl",
		ascii    = "%",
		color    = BROWN,
		sprite   = SPRITE_FOOD1,
		level    = 1,
		weight   = 500,
		flags    = { IF_GLOBE },

		type    = ITEMTYPE_POWER,

		OnPickupCheck = function(self, being)
			if (being.hp >= being.hpmax) then
				being:msg("You're not hungry.")
				return false
			elseif (being.hp >= being.hpmax / 2) then
				being:msg("You're not *that* hungry.")
				return false
			else
				return true
			end
		end,
		OnPickup = function(self, being)
			if being.flags[ BF_NOHEAL ] then
				being:msg("Nothing happens.")
			else
				being:msg(table.random_pick( { "Yeech.", "Not bad.", "Needs salt.", "You feel slightly better." } ))
				being.hp = math.min( being.hp + 2 * diff[DIFFICULTY].powerfactor, being.hpmax / 2)
			end
		end,
	}
	register_item "wolf_food2" {
		name     = "food platter",
		ascii    = "%",
		color    = YELLOW,
		sprite   = SPRITE_FOOD2,
		level    = 1,
		weight   = 750,
		flags    = { IF_GLOBE },

		type    = ITEMTYPE_POWER,

		OnPickupCheck = function(self, being)
			if (being.hp >= being.hpmax and being.tired == false) then
				being:msg("You're not hungry.")
				return false
			else
				return true
			end
		end,
		OnPickup = function(self, being)
			if ((being.flags[ BF_NOHEAL ] or being.hp >= being.hpmax) and being.tired == false) then
				being:msg("Nothing happens.")
			elseif ((being.flags[ BF_NOHEAL ] or being.hp >= being.hpmax) and being.tired ~= false) then
				being:msg("You feel refreshed.")
				being.tired = false
			else
				being:msg(table.random_pick( { "Turkey!", "Delicious.", "Yummy.", "You feel better." } ))
				being.hp = math.min( being.hp + 10 * diff[DIFFICULTY].powerfactor, being.hpmax )
				being.tired = false
			end
		end,
	}
	register_item "wolf_repair" {
		name     = "armor repair kit",
		color    = YELLOW,
		sprite   = SPRITE_AREPAIR,
		level    = 5,
		weight   = 700,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self, being)
			local armor = being.eq.armor
			local boots = being.eq.boots
			if not armor and not boots then
				being:msg( "You have no armor to fix! Nothing happens." )
				return
			end
			local damaged_armor = armor and armor:is_damaged()
			local damaged_boots = boots and boots:is_damaged()
			if not damaged_armor and not damaged_boots then
				being:msg( "You have no armor that needs fixing! Nothing happens." )
				return
			end
			ui.blink( YELLOW, 20 )
			if damaged_armor then
				if armor:fix(25*diff[DIFFICULTY].powerfactor) then
					being:msg( "Your armor looks like new!" )
				else
					being:msg( "Your armor looks better!" )
				end
			end
			if damaged_boots then
				if boots:fix(10*diff[DIFFICULTY].powerfactor) then
					being:msg( "Your boots look like new!" )
				else
					being:msg( "Your boots look better!" )
				end
			end
		end,
	}
	register_item "wolf_oneup" {
		name     = "1up",
		ascii    = "^",
		color    = LIGHTCYAN,
		sprite   = SPRITE_1UP,
		level    = 5,
		weight   = 50,
		flags    = { IF_GLOBE },

		type    = ITEMTYPE_POWER,

		OnPickup = function(self, being)
			if (being:is_player()) then
				being.wolf_lives = math.min( being.wolf_lives + 1, 9)
			end

			ui.blink(LIGHTBLUE,100)
			if being.eq.armor then being.eq.armor:fix() end
			if being.eq.boots then being.eq.boots:fix() end
			if being.flags[ BF_NOHEAL ] then
				being:msg("Yeah.")
			else
				being:msg("Yeah!")
				being.hp = math.max(being.hp, being.hpmax)
			end
			being.tired = false
		end,
	}
	register_item "wolf_berserk" {
		name     = "adrenaline pack",
		ascii    = "^",
		color    = LIGHTGREEN,
		sprite   = SPRITE_BERSERK,
		level    = 2,
		weight   = 150,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self, being)
			being:set_affect("berserk",core.power_duration(40))
			if (not being.flags[ BF_NOHEAL ]) then
				being.hp = math.max(being.hp, being.hpmax)
			end
			being.tired = false
		end,
	}
	register_item "wolf_inv" {
		name     = "super serum",
		ascii    = "^",
		color    = WHITE,
		sprite   = SPRITE_INV,
		level    = 7,
		weight   = 100,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self, being)
			being:set_affect("inv",core.power_duration(50))
			being.tired = false
		end,
	}

	register_item "wolf_map" {
		name     = "map",
		ascii    = "?",
		color    = WHITE,
		sprite   = SPRITE_MAP,
		level    = 1,
		weight   = 180,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self, being)
			being:msg( "Someone dropped a map of this place." )
			ui.blink(WHITE,50)
			for c in area.FULL() do
				local cell = cells[ level.map[ c ] ]
				if cell.flags[ CF_BLOCKMOVE ] or cell.flags[ CF_NOCHANGE ] then
					level.light[ c ][LFEXPLORED] = true
				end
			end
			level.flags[ LF_ITEMSVISIBLE ] = true
			if being.flags[BF_MAPEXPERT] then
				being:msg( "Using your great experience you devise the most likely patrol routes." )
				level.flags[ LF_BEINGSVISIBLE ] = true
			end
		end,
	}
	register_item "wolf_pmap" {
		name     = "patrol map",
		ascii    = "?",
		color    = LIGHTGREEN,
		sprite   = SPRITE_TMAP,
		level    = 1,
		weight   = 80,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self, being)
			being:msg( "You found a list of assigned patrols." )
			ui.blink(LIGHTGREEN,50)
			for c in area.FULL() do
				local cell = cells[ level.map[ c ] ]
				if cell.flags[ CF_BLOCKMOVE ] or cell.flags[ CF_NOCHANGE ] then
					level.light[ c ][LFEXPLORED] = true
				end
			end
			level.flags[ LF_ITEMSVISIBLE ] = true
			level.flags[ LF_BEINGSVISIBLE ] = true
		end,
	}
	register_item "wolf_goggles" {
		name     = "Goggles",
		ascii    = "^",
		color    = LIGHTMAGENTA,
		sprite   = SPRITE_LIGHTAMP,
		level    = 1,
		weight   = 80,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self, being)
			being:set_affect("light",core.power_duration(60))
		end,
	}
	register_item "wolf_backpack" {
		name     = "backpack",
		ascii    = '"',
		color    = BROWN,
		sprite   = SPRITE_BACKPACK,
		glow     = { 1.0,1.0,0.0,1.0 },
		level    = 10,
		weight   = 100,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self, being)
			if being.flags[ BF_BACKPACK ] then
				ui.msg("Another backpack.")
				return
			end
			ui.msg("BackPack!")
			ui.blink(YELLOW,50)
			being:power_backpack()
		end,
	}

	-- Treasure --
	register_item "wolf_cross" {
		name     = "cross",
		ascii    = "ñ",
		--asciilow = '`';
		color    = MAGENTA,
		sprite   = SPRITE_TREASURE1,
		level    = 1,
		weight   = 0,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self, being)
			if (being:is_player()) then
				being:msg( "Treasure." )
				being.wolf_treasure1 = being.wolf_treasure1 + 1
				DoomRL.addscore(100)
			end
		end,
	}
	register_item "wolf_chalice" {
		name     = "chalice",
		ascii    = "*",
		color    = YELLOW,
		sprite   = SPRITE_TREASURE2,
		level    = 2,
		weight   = 0,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self, being)
			if (being:is_player()) then
				being:msg( "Treasure~" )
				being.wolf_treasure2 = being.wolf_treasure2 + 1
				DoomRL.addscore(500)
			end
		end,
	}
	register_item "wolf_chest" {
		name     = "chest",
		ascii    = "$",
		color    = YELLOW,
		sprite   = SPRITE_TREASURE3,
		level    = 4,
		weight   = 0,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self, being)
			if (being:is_player()) then
				being:msg( "Treasure!" )
				ui.blink(YELLOW,20)
				being.wolf_treasure3 = being.wolf_treasure3 + 1
				DoomRL.addscore(1000)
			end
		end,
	}
	register_item "wolf_crown" {
		name     = "crown",
		ascii    = ":",
		color    = LIGHTMAGENTA,
		sprite   = SPRITE_TREASURE4,
		level    = 7,
		weight   = 0,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self, being)
			if (being:is_player()) then
				being:msg( "Treasure!" )
				ui.blink(LIGHTMAGENTA,50)
				being.wolf_treasure4 = being.wolf_treasure4 + 1
				DoomRL.addscore(5000)
			end
		end,
	}

	register_item "blake_money" {
		name     = "bag of money",
		ascii    = "å",
		--asciilow = '$',
		color    = LIGHTGREEN,
		sprite   = SPRITE_TREASURE1,
		level    = 2,
		weight   = 0,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self, being)
			if (being:is_player()) then
				being:msg( "Treasure." )
				being.wolf_treasure1 = being.wolf_treasure1 + 1
				DoomRL.addscore(100)
			end
		end,
	}
	register_item "blake_loot" {
		name     = "loot",
		ascii    = "÷",
		--asciilow = '=',
		color    = LIGHTRED,
		sprite   = SPRITE_TREASURE2,
		level    = 200,
		weight   = 0,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self, being)
			if (being:is_player()) then
				being:msg( "Treasure~" )
				being.wolf_treasure2 = being.wolf_treasure2 + 1
				DoomRL.addscore(500)
			end
		end,
	}
	register_item "blake_gold" {
		name     = "stack of gold bars",
		ascii    = "ð",
		--asciilow = '_'
		color    = YELLOW,
		sprite   = SPRITE_TREASURE3,
		level    = 200,
		weight   = 0,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self, being)
			if (being:is_player()) then
				being:msg( "Treasure!" )
				ui.blink(YELLOW,20)
				being.wolf_treasure3 = being.wolf_treasure3 + 1
				DoomRL.addscore(1000)
			end
		end,
	}
	register_item "blake_orb" {
		name     = "xylan orb",
		ascii    = "§",
		--asciilow = '*',
		color    = LIGHTBLUE,
		sprite   = SPRITE_TREASURE4,
		level    = 200,
		weight   = 0,

		type    = ITEMTYPE_POWER,

		OnPickup = function(self, being)
			if (being:is_player()) then
				being:msg( "Treasure!" )
				ui.blink(LIGHTMAGENTA,50)
				being.wolf_treasure4 = being.wolf_treasure4 + 1
				DoomRL.addscore(5000)
			end
		end,
	}

	-- Packs --
	register_item "wolf_smed" {
		name     = "small med-pack",
		ascii    = "+",
		color    = LIGHTRED,
		sprite   = SPRITE_MEDPACK,
		level    = 1,
		weight   = 600,
		desc     = "This can treat a few scratches but for serious injuries you'll need its larger cousin.",
		flags    = { IF_AIHEALPACK },

		type       = ITEMTYPE_PACK,

		OnUse = function(self, being)
			local isPlayer = being:is_player()
			if being.flags[ BF_NOHEAL ] then
				--Cannot use
				being:msg("Nothing happens.")
			elseif (being.hp >= being.hpmax * 2 or ( not being.flags[ BF_MEDPLUS ] and being.hp >= being.hpmax)) then
				--Not in need of healing
				if (isPlayer and being.tired ~= false) then
					being.tired = false
					being:msg("You feel refreshed.")
				else
					being:msg("Nothing happens.")
				end
			else
				if isPlayer then being.tired = false end
				local heal = (being.hpmax * diff[DIFFICULTY].powerfactor) / 4 + 2
				being.hp = math.min( being.hp + heal, being.hpmax * 2 )
				if not being.flags[ BF_MEDPLUS ] then being.hp = math.min( being.hp, being.hpmax ) end
				being:msg("You feel healed.",being:get_name(true,true).." looks healthier!")
			end

			if (isPlayer) then
				being:play_sound(self.id .. ".use1")
			end

			return true
		end,
	}
	register_item "wolf_lmed" {
		name     = "large med-pack",
		ascii    = "+",
		color    = RED,
		sprite   = SPRITE_LMEDPACK,
		level    = 5,
		weight   = 400,
		desc     = "Your best friend in times of need.",
		flags    = { IF_AIHEALPACK },

		type       = ITEMTYPE_PACK,

		OnUse = function(self, being)
			local isPlayer = being:is_player()
			if being.flags[ BF_NOHEAL ] then
				--Cannot use
				being:msg("Nothing happens.")
			elseif (being.hp >= being.hpmax * 2 or ( not being.flags[ BF_MEDPLUS ] and being.hp >= being.hpmax)) then
				--Not in need of healing
				if (isPlayer and being.tired ~= false) then
					being.tired = false
					being:msg("You feel refreshed.")
				else
					being:msg("Nothing happens.")
				end
			else
				if isPlayer then being.tired = false end
				being.hp = math.min( being.hp + (being.hpmax * diff[DIFFICULTY].powerfactor) / 2 + 2, being.hpmax * 2)
				being.hp = math.max( being.hp, being.hpmax )
				if not being.flags[ BF_MEDPLUS ] then being.hp = math.min( being.hp, being.hpmax ) end
				being:msg("You feel fully healed.",being:get_name(true,true).." looks a lot healthier!")
			end

			if (isPlayer) then
				being:play_sound(self.id .. ".use1")
			end

			return true
		end,
	}
	register_item "wolf_phase" {
		name     = "phase device",
		ascii    = "+",
		color    = BLUE,
		sprite   = SPRITE_PHASE,
		coscolor = { 0.0,0.0,0.7,1.0 },
		level    = 5,
		weight   = 0,
		desc     = "Either German engineering or the German occult has come a long way. Somehow this teleports you away from the enemy!",
		flags    = { IF_AIHEALPACK },

		type       = ITEMTYPE_PACK,

		OnUse = function(self, being)
			being:play_sound("soldier.phase")
			being:msg("You feel yanked in an non-existing direction!","Suddenly "..being:get_name(true,false).." blinks away!")
			level:explosion( being.position, 2, 50, 0, 0, LIGHTBLUE )
			being:phase()
			level:explosion( being.position, 1, 50, 0, 0, LIGHTBLUE )
			being:msg(nil,"Suddenly "..being:get_name(false,false).." appears out of nowhere!")
			return true
		end,
	}
	register_item "wolf_hphase" {
		name     = "homing phase device",
		ascii    = "+",
		color    = LIGHTBLUE,
		level    = 7,
		weight   = 0,
		sprite   = SPRITE_PHASE,
		coscolor = { 0.3,0.3,1.0,1.0 },
		desc     = "As if regular phases weren't incredible enough, this version gives you just enough control to reach the exit!",
		flags    = { IF_AIHEALPACK },

		type       = ITEMTYPE_PACK,

		OnUse = function(self, being)
			being:play_sound("soldier.phase")
			being:msg("You feel yanked in an non-existing direction!","Suddenly "..being:get_name(true,false).." blinks away!")
			level:explosion( being.position, 2, 50, 0, 0, GREEN )
			if level.flags[ LF_NOHOMING ] then
				being:phase()
			else
				being:phase( "stairs" )
			end
			level:explosion( being.position, 1, 50, 0, 0, GREEN )
			being:msg(nil,"Suddenly "..being:get_name(false,false).." appears out of nowhere!")
			return true
		end,
	}
	register_item "wolf_epack" {
		name     = "protective suit",
		ascii    = "+",
		color    = GREEN,
		sprite   = SPRITE_ENVIRO,
		level    = 5,
		weight   = 100,
		desc     = "Those wacky Nazis dump toxic chemicals in your way? Use this.",

		type = ITEMTYPE_PACK,

		OnUse = function(self, being)
			if being:is_player() then
				being:set_affect("enviro",core.power_duration(70))
			end
			return true
		end,
	}

	-- Mods --
	register_item "wolf_mod_power" {
		name     = "power mod pack",
		ascii    = "\"",
		color    = LIGHTRED,
		sprite   = SPRITE_MOD,
		coscolor = { 1.0,0.0,0.0,1.0 },
		level    = 7,
		weight   = 100,
		desc     = "Power modification kit -- increases weapon damage or armor protection.",

		type       = ITEMTYPE_PACK,
		mod_letter = "P",

		OnUseCheck = function(self,being)
			local item, result = being:pick_mod_item('P',being.techbonus)
			if not result then return false end
			if item ~= nil then self:add_property("chosen_item", item) end
			return true
		end,

		OnUse = function(self,being)
			if not self:has_property("chosen_item") then return true end
			local item = self.chosen_item
			if item.itype == ITEMTYPE_MELEE then
				item.damage_sides = item.damage_sides + 1
			elseif item.itype == ITEMTYPE_RANGED then
				if item.damage_sides >= item.damage_dice then
					item.damage_sides = item.damage_sides + 1
				else
					item.damage_dice = item.damage_dice + 1
				end
			elseif item.itype == ITEMTYPE_ARMOR then
				item.armor = item.armor + 2
			elseif item.itype == ITEMTYPE_BOOTS then
				item.armor = item.armor * 2
			end
			item:add_mod('P')
			return true
		end,
	}
	register_item "wolf_mod_tech" {
		name     = "technical mod pack",
		ascii    = "\"",
		color    = YELLOW,
		sprite   = SPRITE_MOD,
		coscolor = { 1.0,1.0,0.0,1.0 },
		level    = 5,
		weight   = 100,
		desc     = "Technical modification kit -- decreases fire time for weapons, or increases armor knockback resistance.",

		type       = ITEMTYPE_PACK,
		mod_letter = "T",

		OnUseCheck = function(self,being)
			local item, result = being:pick_mod_item('T',being.techbonus)
			if not result then return false end
			if item ~= nil then self:add_property("chosen_item", item) end
			return true
		end,

		OnUse = function(self,being)
			if not self:has_property("chosen_item") then return true end
			local item = self.chosen_item
			if (item.itype == ITEMTYPE_RANGED) or (item.itype == ITEMTYPE_MELEE) then
				item.usetime = item.usetime * 0.85
			elseif item.itype == ITEMTYPE_ARMOR or item.itype == ITEMTYPE_BOOTS then
				item.knockmod = item.knockmod - 25
			end
			item:add_mod('T')
			return true
		end,
	}
	register_item "wolf_mod_agility" {
		name     = "agility mod pack",
		ascii    = "\"",
		color    = LIGHTCYAN,
		weight   = 120,
		coscolor = { 0.0,1.0,1.0,1.0 },
		level    = 6,
		sprite   = SPRITE_MOD,
		desc     = "Agility modification kit -- increases weapon accuracy or reduces/increases armor move speed modifier.",

		type       = ITEMTYPE_PACK,
		mod_letter = "A",

		OnUseCheck = function(self,being)
			local item, result = being:pick_mod_item('A',being.techbonus)
			if not result then return false end
			if item ~= nil then self:add_property("chosen_item", item) end
			return true
		end,

		OnUse = function(self,being)
			if not self:has_property("chosen_item") then return true end
			local item = self.chosen_item
			if item.itype == ITEMTYPE_MELEE or item.itype == ITEMTYPE_RANGED then
				item.acc = item.acc + 1
			elseif item.itype == ITEMTYPE_ARMOR then
				item.movemod = item.movemod + 15
			elseif item.itype == ITEMTYPE_BOOTS then
				item.movemod = item.movemod + 10
			end
			item:add_mod('A')
			return true
		end,
	}
	register_item "wolf_mod_bulk" {
		name     = "bulk mod pack",
		ascii    = "\"",
		color    = LIGHTBLUE,
		sprite   = SPRITE_MOD,
		coscolor = { 0.0,0.0,1.0,1.0 },
		level    = 6,
		weight   = 120,
		desc     = "Bulk modification kit -- increases weapon magazine for magazine weapons, decreases reload time for single-shot weapons, or increases armor durability. For melee weapons it increases the damage done.",

		type       = ITEMTYPE_PACK,
		mod_letter = "B",

		OnUseCheck = function(self,being)
			local item, result = being:pick_mod_item('B',being.techbonus)
			if not result then return false end
			if item ~= nil then self:add_property("chosen_item", item) end
			return true
		end,

		OnUse = function(self,being)
			if not self:has_property("chosen_item") then return true end
			local item = self.chosen_item
			if item.itype == ITEMTYPE_MELEE then
				item.damage_dice = item.damage_dice + 1
			elseif item.itype == ITEMTYPE_RANGED then
				if item.ammomax < 3 then
					item.reloadtime = item.reloadtime * 0.75
				else
					item.ammomax = item.ammomax * 1.3
				end
			elseif item.itype == ITEMTYPE_ARMOR or item.itype == ITEMTYPE_BOOTS then
				item.durability    = item.durability + 100
				item.maxdurability = item.maxdurability + 100
				item.movemod = item.movemod - 10
			end
			item:add_mod('B')
			return true
		end,
	}

	register_item "wolf_umod_firestorm" {
		name     = "firestorm weapon pack",
		ascii    = "\"",
		color    = RED,
		sprite   = SPRITE_MOD,
		coscolor = { 1.0,0.2,0.8,1.0 },
		level    = 10,
		weight   = 4,
		desc     = "A modification for rapid or explosive weapons -- increases shots by 2 for rapid, and blast radius by 2 for explosive weapons.",
		flags    = { IF_EXOTIC },

		type       = ITEMTYPE_PACK,
		mod_letter = "F",

		OnUseCheck = function(self,being)
			if not being:is_player() then return false end
			local item = being.eq.weapon
			if not item then
				ui.msg( "Nothing to modify!" )
				return false
			end
			if item:check_mod_array( 'F', being.techbonus ) then
				self:add_property( "assembled" )
				return true
			end
			if not item:can_mod( 'F' ) then
				ui.msg( "This weapon can't be modded any more!" )
				return false
			end
			if item.itype ~= ITEMTYPE_RANGED then
				ui.msg( "This weapon can't be modified!" )
				return false
			end
			return true
		end,

		OnUse = function(self,being)
			if self:has_property( "assembled" ) then return true end
			local item = being.eq.weapon
			if item.shots >= 3 then
				item.shots = item.shots + 2
			elseif item.blastradius >= 3 then
				item.blastradius = item.blastradius + 2
			else
				ui.msg( "Only a rapid-fire or explosive weapon can be modded!" )
				return false
			end
			ui.msg( "You upgrade your weapon!" )
			item:add_mod( 'F' )
			return true
		end,
	}
	register_item "wolf_umod_sniper" {
		name     = "sniper weapon pack",
		ascii    = "\"",
		color    = MAGENTA,
		sprite   = SPRITE_MOD,
		coscolor = { 0.8,0.2,1.0,1.0 },
		level    = 10,
		weight   = 4,
		desc     = "A high-tech modification for ranged weapons -- implements an advanced auto-hit mechanism.",
		flags    = { IF_EXOTIC },

		type       = ITEMTYPE_PACK,
		mod_letter = "S",

		OnUseCheck = function(self,being)
			if not being:is_player() then return false end
			local item = being.eq.weapon
			if not item then
				ui.msg( "Nothing to modify!" )
				return false
			end
			if item:check_mod_array( 'S', being.techbonus ) then
				self:add_property( "assembled" )
				return true
			end
			--[[
			if item.flags[ IF_SHOTGUN ] or item.itype ~= ITEMTYPE_RANGED then
				ui.msg( "This weapon can't be modified!" )
				return false
			end
			--]]
			if not item:can_mod( 'S' ) then
				ui.msg( "This weapon can't be modded any more!" )
				return false
			end
			return true
		end,

		OnUse = function(self,being)
			if self:has_property( "assembled" ) then return true end
			local item = being.eq.weapon
			if item.flags[IF_FARHIT] == true then
				item.flags[IF_UNSEENHIT] = true
			else
				item.flags[IF_FARHIT] = true
			end
			ui.msg( "You upgrade your weapon!" )
			item:add_mod( 'S' )
			return true
		end,
	}
	register_item "wolf_umod_nano" {
		name     = "nano pack",
		ascii    = "\"",
		color    = GREEN,
		sprite   = SPRITE_MOD,
		coscolor = { 0.5,0.5,1.0,1.0 },
		level    = 15,
		weight   = 2,
		desc     = "Futuristic technology that can be used to ensure your weapon's hammers never fall on empty chambers.",
		flags    = { IF_EXOTIC },

		type       = ITEMTYPE_PACK,
		mod_letter = "N",

		OnUseCheck = function(self,being)
			if not being:is_player() then return false end
			local item, result = being:pick_mod_item('N', being.techbonus )
			if not result then return false end
			if item and item.itype == ITEMTYPE_MELEE then
				ui.msg( "Nanotechnology doesn't work on melee weapons!" )
				return false
			end
			if item ~= nil then self:add_property( "chosen_item", item ) end
			return true
		end,

		OnUse = function(self,being)
			if not self:has_property( "chosen_item" ) then return true end
			local item = self.chosen_item
			ui.msg( "You upgrade your gear!" )
			item:add_mod( 'N' )
			if item.flags[ IF_RECHARGE ] then
				if item.rechargedelay == 0 then
					item.rechargeamount = item.rechargeamount + 1
				else
					item.rechargedelay = math.max(0, item.rechargedelay - 5)
				end
			else
				item.flags[ IF_RECHARGE ] = true
				item.rechargedelay = 5
				if item.itype == ITEMTYPE_ARMOR or item.itype == ITEMTYPE_BOOTS then
					item.rechargeamount = 2
				elseif item.itype == ITEMTYPE_RANGED then
					item.rechargeamount = 1
				end
			end
			return true
		end,
	}
	register_item "wolf_umod_onyx" {
		name     = "onyx armor pack",
		ascii    = "\"",
		color    = LIGHTGRAY,
		sprite   = SPRITE_MOD,
		coscolor = { 0.0,0.0,0.0,1.0 },
		level    = 10,
		weight   = 4,
		desc     = "A modification for boots and armors -- makes them indestructible.",
		flags    = { IF_EXOTIC },

		type       = ITEMTYPE_PACK,
		mod_letter = "O",

		OnUseCheck = function(self,being)
			if not being:is_player() then return false end
			local item, result = being:pick_mod_item('O', being.techbonus )
			if not result then return false end
			if item and not ( item.itype == ITEMTYPE_ARMOR or item.itype == ITEMTYPE_BOOTS ) then
				ui.msg( "Only boots or armor can be modded with this mod!" )
				return false
			end
			if item ~= nil then self:add_property( "chosen_item", item ) end
			return true
		end,

		OnUse = function(self,being)
			if not self:has_property( "chosen_item" ) then return true end
			local item = self.chosen_item
			ui.msg( "You upgrade your gear!" )
			item.durability = 100
			item.flags[ IF_NODURABILITY ] = true
			item:add_mod( 'O' )
			return true
		end,
	}

	-- Levers --
	register_item "lever_flood_water" {
		name     = "lever",
		color_id = "lever",
		color    = WHITE,
		sprite   = SPRITE_LEVER,
		weight   = 0,

		type       = ITEMTYPE_LEVER,
		good       = "neutral",
		desc       = "floods with water",
		warning    = "The castle is really damp here...",
		fullchance = 50,

		OnCreate = function(self)
			self:add_property( "target_area", area.FULL_SHRINKED:clone() )
		end,

		OnUse = function(self, being)
			ui.msg("Suddenly water starts gushing from the ground!")
			level:flood( "water", self.target_area )
			self:destroy()
			return true
		end,
	}
	register_item "lever_flood_acid" {
		name     = "lever",
		color_id = "lever",
		color    = WHITE,
		sprite   = SPRITE_LEVER,
		weight   = 0,

		type       = ITEMTYPE_LEVER,
		good       = "dangerous",
		desc       = "floods with acid",
		warning    = "The air feels really dry here...",
		fullchance = 10,

		OnCreate = function(self)
			self:add_property( "target_area", area.FULL_SHRINKED:clone() )
		end,

		OnUse = function(self, being)
			if self.target_area:size() >= area.FULL_SHRINKED:size() then
				ui.msg("Whoops! Acid splashes everywhere!")
				being:add_history("He flooded the entire level @1 with acid!")
			else
				ui.msg("Green acid covers the floor!")
			end
			level:flood( "acid", self.target_area )
			return true
		end,
	}
	register_item "lever_flood_lava" {
		name     = "lever",
		color    = WHITE,
		sprite   = SPRITE_LEVER,
		weight   = 0,
		color_id = "lever",

		type       = ITEMTYPE_LEVER,
		good       = "dangerous",
		desc       = "floods with lava",
		warning    = "This whole floor smells like petrol.",
		fullchance = 10,

		OnCreate = function(self)
			self:add_property( "target_area", area.FULL_SHRINKED:clone() )
		end,

		OnUse = function(self, being)
			if self.target_area:size() >= area.FULL_SHRINKED:size() then
				ui.msg("Looks like you've overstayed your welcome.")
				being:add_history("He flooded the entire level @1 with lava!")
			else
				ui.msg("The ground explodes in flames!")
			end
			level:flood( "lava", self.target_area )
			return true
		end,
	}
	register_item "lever_kill" {
		name     = "lever",
		color    = WHITE,
		sprite   = SPRITE_LEVER,
		weight   = 0,
		color_id = "lever",

		type       = ITEMTYPE_LEVER,
		good       = "beneficial",
		desc       = "harms creatures",
		warning    = "This floor somehow feels sharper.",
		fullchance = 33,

		OnCreate = function(self)
			self:add_property( "target_area", area.FULL_SHRINKED:clone() )
		end,

		OnUse = function(self, being)
			local gotSomeone = false
			for c in self.target_area() do
				local target = level:get_being(c)
				if target and not target:is_player() then
					gotSomeone = true
					target:apply_damage( 20, TARGET_INTERNAL, DAMAGE_FIRE )
				end
			end

			if gotSomeone then
				ui.msg("The smell of blood surrounds you!")
				self:destroy()
			else
				ui.msg("Nothing happens. That you know of.")
			end

			return true
		end,
	}
	register_item "lever_explode" {
		name     = "lever",
		color    = WHITE,
		sprite   = SPRITE_LEVER,
		weight   = 0,
		color_id = "lever",

		type       = ITEMTYPE_LEVER,
		good       = "neutral",
		desc       = "forces explosions",
		fullchance = 100,

		OnCreate = function(self)
			self:add_property( "target_area", area.FULL_SHRINKED:clone() )
		end,

		OnUse = function(self, being)
			local position = self.position
			for c in self.target_area() do
				local tile = cells[ level.map[ c ] ]
				local is_barrel = tile.id == "barrel" or tile.id == "barrela" or tile.id == "barreln"
				if is_barrel and tile.OnDestroy then
					level.map[ c ] = "floor"
					tile.OnDestroy(c)
				end
			end
			return true
		end,
	}
	register_item "lever_walls" {
		name     = "lever",
		color    = WHITE,
		sprite   = SPRITE_LEVER,
		weight   = 0,
		color_id = "lever",

		type       = ITEMTYPE_LEVER,
		good       = "dangerous",
		desc       = "destroys walls",
		warning    = "The walls here look unstable.",
		fullchance = 33,

		OnCreate = function(self)
			self:add_property( "target_area", area.FULL_SHRINKED:clone() )
		end,

		OnUse = function(self, being)
			local gotCell = false
			local room = self.target_area:clamped( area.FULL_SHRINKED )
			for c in room() do
				local tile = cells[ level.map[ c ] ]
				if tile.set == CELLSET_WALLS then
					gotCell = true
					level.map[ c ] = generator.styles[ level.style ].floor
					level.light[c][LFPERMANENT] = false
				end
			end

			if gotCell then
				ui.msg("The walls explode!")
				self:destroy()
			else
				ui.msg("Nothing happens. That you know of.")
			end

			return true
		end,
	}
	register_item "lever_summon" {
		name     = "lever",
		color    = WHITE,
		sprite   = SPRITE_LEVER,
		weight   = 0,
		color_id = "lever",

		type       = ITEMTYPE_LEVER,
		good       = "dangerous",
		desc       = "summons enemies",

		OnCreate = function(self)
			self:add_property( "charges", math.random(3) )
			self:add_property( "target_area", area.FULL_SHRINKED:clone() )
		end,

		OnUseCheck = function( self )
			if self.charges == 0 then
				ui.msg("Nothing happens.")
				return false
			end
			return true
		end,

		OnUse = function(self, being)
			local amount = math.random(4)+1
			local list   = level:get_being_table( level.danger_level, nil, { is_group = false } )
			for c = 1,amount do
				being:spawn( list:roll().id )
			end
			self.charges = self.charges - 1
			return self.charges == 0
		end,
	}
	register_item "lever_repair" {
		name     = "lever",
		color    = WHITE,
		sprite   = SPRITE_LEVER,
		weight   = 0,
		color_id = "lever",

		type       = ITEMTYPE_LEVER,
		good       = "beneficial",
		desc       = "Armor depot",

		OnCreate = function(self)
			self:add_property( "charges", math.random(3) )
		end,

		OnUseCheck = function(self, being)
			if self.charges == 0 then
				ui.msg("Repair supplies depleted.")
				return false
			end
			ui.msg("Armor depot. Proceeding with repair of used armor...")
			local armor = being.eq.armor
			local boots = being.eq.boots
			if not armor and not boots then
				ui.msg( "You have no armor to fix! Nothing happens." )
				return false
			end
			local damaged_armor = armor and armor:is_damaged()
			local damaged_boots = boots and boots:is_damaged()
			if not damaged_armor and not damaged_boots then
				ui.msg( "You have no armor that needs fixing! Nothing happens." )
				return false
			end
			return true
		end,

		OnUse = function(self, being)
			local armor = being.eq.armor
			local boots = being.eq.boots
			local damaged_armor = armor and armor:is_damaged()
			local damaged_boots = boots and boots:is_damaged()
			self.charges = self.charges - 1
			ui.blink( YELLOW, 20 )
			if damaged_armor then
				if armor:fix(25) then
					ui.msg( "Your armor looks like new!" )
				else
					ui.msg( "Your armor looks better!" )
				end
			end
			if damaged_boots then
				if boots:fix(25) then
					ui.msg( "Your boots look like new!" )
				else
					ui.msg( "Your boots look better!" )
				end
			end
			return self.charges == 0
		end,
	}
	register_item "lever_medical" {
		name     = "lever",
		color    = WHITE,
		sprite   = SPRITE_LEVER,
		weight   = 0,
		color_id = "lever",

		type       = ITEMTYPE_LEVER,
		good       = "beneficial",
		desc       = "MediTech depot",

		OnCreate = function( self )
			self:add_property( "charges", math.random(3) )
		end,

		OnUseCheck = function(self, being)
			if self.charges == 0 then
				ui.msg("Medical supplies depleted.")
				return false
			end
			if being.flags[ BF_NOHEAL] then
				ui.msg("Nothing happens.")
				return false
			end
			if being.hp >= being.hpmax then
				ui.msg("MediTech depot. Proceeding with treatment...")
				ui.msg("You are at full health. Nothing happens.")
				return false
			end
			return true
		end,

		OnUse = function(self, being)
			ui.msg("MediTech depot. Proceeding with treatment...")
			being.tired = false
			self.charges = self.charges - 1
			local heal = (being.hpmax * diff[DIFFICULTY].powerfactor) / 4 + 2
			being.hp = math.min( being.hp + heal,being.hpmax )
			ui.msg("You feel healed.")
			return self.charges == 0
		end,
	}

	-- Keys --
	register_item "wolf_key1" {
		name     = "gold key",
		ascii    = "(",
		color    = YELLOW,
		sprite   = SPRITE_KEY1,
		weight   = 0,

		type    = ITEMTYPE_POWER,

		flags = { IF_NODESTROY, IF_NUKERESIST },
		OnPickup = function(self, being)
			being:msg( "Light doors unlocked!" )
			generator.transmute("lmdoor1", "mdoor1")
			if (self) then
				self.flags[IF_NODESTROY] = false --We cannot destroy this object yet or other OnPickup hooks may crash.  Doing this gets us the effect we want--an indestructible powerup that is still consumed on pickup
			end
		end,
	}
	register_item "wolf_key2" {
		name     = "iron key",
		ascii    = "(",
		color    = CYAN,
		sprite   = SPRITE_KEY2,
		weight   = 0,

		type = ITEMTYPE_POWER,
		ascii = "(",

		flags = { IF_NODESTROY, IF_NUKERESIST },
		OnPickup = function(self, being)
			being:msg( "Heavy doors unlocked!" )
			generator.transmute("lmdoor2", "mdoor2")
			if (self) then
				self.flags[IF_NODESTROY] = false
			end
		end,
	}

	-- Crystals --
	-- (from the 2009 Wolfenstein, exotic) --
	register_item "wolf_upowerc" {
		name     = "empower crystal",
		ascii    = "~",
		color    = LIGHTRED,
		sprite   = SPRITE_CRYSTAL,
		coscolor = { 1.0,0.0,0.0,0.9 },
		level    = 2,
		weight   = 8,
		desc     = "A mysterious crystal that imbues the user with incredible power.",
		flags    = { IF_EXOTIC },

		type    = ITEMTYPE_PACK,

		OnUse = function(self, being)
			being:set_affect("power",core.power_duration(20))
			return true
		end,
	}
	register_item "wolf_ushieldc" {
		name     = "shield crystal",
		ascii    = "~",
		color    = LIGHTBLUE,
		sprite   = SPRITE_CRYSTAL,
		coscolor = { 0.0,0.0,1.0,0.9 },
		level    = 2,
		weight   = 12,
		desc     = "A mysterious crystal that creates a nearly impenetrable barrier around the user.",
		flags    = { IF_EXOTIC },

		type    = ITEMTYPE_PACK,

		OnUse = function(self, being)
			being:set_affect("shield",core.power_duration(20))
			return true
		end,
	}
	register_item "wolf_umirec" {
		name     = "mire crystal",
		ascii    = "~",
		color    = YELLOW,
		sprite   = SPRITE_CRYSTAL,
		coscolor = { 1.0,1.0,0.0,0.9 },
		level    = 2,
		weight   = 10,
		desc     = "A mysterious crystal that speeds the user up immensely.",
		flags    = { IF_EXOTIC },

		type    = ITEMTYPE_PACK,

		OnUse = function(self, being)
			being:set_affect("mire",core.power_duration(1))
			return true
		end,
	}

end
