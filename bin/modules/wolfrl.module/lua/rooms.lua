function DoomRL.load_rooms()

	register_room "lever_room" {
		weight      = 10,
		max_size_x  = 20,
		max_size_y  = 15,

		setup       = function ( room )
			local pos = generator.random_empty_coord( { EF_NOBLOCK, EF_NOSTAIRS, EF_NOITEMS, EF_NOHARM, EF_NOSPAWN }, room )
			if not pos then return false end

			local lid = weight_table.new{
				lever_explode     = 2,
				lever_summon      = 2,
				lever_kill        = 3,
				lever_walls       = 3,
				lever_flood_water = 1,
				lever_flood_acid  = 1,
				lever_flood_lava  = 1,
				lever_repair      = 2,
				lever_medical     = 2,
			}:roll()

			local proto = items[lid]
			local lever = item.new( lid )
			if lever:has_property("target_area") then
				lever.target_area = room:clone()
			end
			level:drop_item( lever, pos )

			if proto.fullchance and math.random(100) < proto.fullchance then
				lever.target_area = area.FULL:clone()
				if proto.warning then
					ui.msg( proto.warning )
				end
			end
			return true
		end
	}
	register_room "teleport_room" {
		weight      = 5,

		setup       = function ( room )
			local floors = room:shrinked()
			local tries = 5
			local pos
			repeat
				tries = tries - 1
				if tries == 0 then return false end
				pos = floors:random_coord()
			until generator.cross_around( pos, generator.styles[ level.style ].floor ) > 2
			level:drop_item( "teleport", pos )
			return true
		end,
	}
	register_room "ammo_room" {
		weight      = 5,
		min_size    = 4,
		class       = "closed",

		setup       = function ( room )
			--If you have an exotic weapon that ammo type becomes available
			local availableAmmoHashset = {}
			availableAmmoHashset["wolf_9mm"]    = true
			availableAmmoHashset["wolf_45acp"]  = false
			availableAmmoHashset["wolf_455c"]   = false
			availableAmmoHashset["wolf_8mm"]    = true
			availableAmmoHashset["wolf_3006"]   = false
			availableAmmoHashset["wolf_303"]    = false
			availableAmmoHashset["wolf_kurz"]   = true
			availableAmmoHashset["wolf_30c"]    = false
			availableAmmoHashset["wolf_fuel"]   = false
			availableAmmoHashset["wolf_rocket"] = true
			availableAmmoHashset["wolf_cell"]   = false
			availableAmmoHashset["wolf_shell"]  = false
			if player.eq.weapon and player.eq.weapon == ITEMTYPE_RANGED and items[player.eq.weapon.ammoid] then
				availableAmmoHashset[items[player.eq.weapon.ammoid].id] = true
			end
			if player.eq.prepared and player.eq.prepared.itype == ITEMTYPE_RANGED and items[player.eq.prepared.ammoid] then
				availableAmmoHashset[items[player.eq.prepared.ammoid].id] = true
			end
			for item in player.inv:items() do
				if item and item.itype == ITEMTYPE_RANGED and items[item.ammoid] then
					availableAmmoHashset[items[item.ammoid].id] = true
				end
			end

			local aid
			local roll = math.random(3 + level.danger_level)
			    if (roll >= 15 and availableAmmoHashset["wolf_cell"])   then aid = "wolf_cell"
			elseif (roll >= 13 and availableAmmoHashset["wolf_rocket"]) then aid = "wolf_rocket"
			elseif (roll >= 12 and availableAmmoHashset["wolf_fuel"])   then aid = "wolf_fuel"
			elseif (roll >= 11 and availableAmmoHashset["wolf_kurz"])   then aid = "wolf_kurz"
			elseif (roll >= 10 and availableAmmoHashset["wolf_3006"])   then aid = "wolf_3006"
			elseif (roll >=  9 and availableAmmoHashset["wolf_30c"])    then aid = "wolf_30c"
			elseif (roll >=  8 and availableAmmoHashset["wolf_303"])    then aid = "wolf_303"
			elseif (roll >=  7 and availableAmmoHashset["wolf_8mm"])    then aid = "wolf_8mm"
			elseif (roll >=  6 and availableAmmoHashset["wolf_shell"])  then aid = "wolf_shell"
			elseif (roll >=  5 and availableAmmoHashset["wolf_455c"])   then aid = "wolf_455c"
			elseif (roll >=  4 and availableAmmoHashset["wolf_45acp"])  then aid = "wolf_45acp"
			elseif (               availableAmmoHashset["wolf_9mm"])    then aid = "wolf_9mm"
			else aid = "wolf_smed" --Should never happen!
			end

			local amount = math.random(3) + 2
			level:area_drop( room, aid, amount, true )
	
			return true
		end,
	}
	register_room "basain_room" {
		weight      = 5,
		min_size    = 4,
		max_area    = 140,
		class       = "closed",

		setup       = function ( room )
			local fill
			local roll = math.random(10) + math.floor( level.danger_level / 5 )
			if roll < 8  then fill = "water"
			elseif roll < 13 then fill = "acid"
			else fill = "lava" end
			local roll = math.random(3)
			local big  = room:dim().x >= 6 and room:dim().y >= 6 
			if roll < 3 and big then
				generator.fill( "bridge", room:shrinked() )
				generator.fill( fill, room:shrinked(2) )
			else
				generator.fill( fill, room:shrinked() )
			end
			return true
		end,
	}
	register_room "warehouse_room" {
		weight      = 20,
		min_size    = 8,
		class       = "closed",

		setup       = function ( room )
			generator.warehouse_fill( { "crate", "ycrate" }, room:shrinked(), 2, 30, 5, {"crate_armor","crate_ammo"} )
			return true
		end,
	}
	register_room "vault_room" {
		weight      = 5,
		min_size    = 8,
		max_size_x  = 26,
		max_size_x  = 14,
		no_monsters = false,

		setup       = function ( room )
			local fill, keypos
			local space = 1
			local room2 = generator.get_room(4,100,100)
			if generator.room_meta[room].dims.x > 10 and generator.room_meta[room].dims.y > 10 and math.random(2) == 1 then
				space = 2
			end
			if room2 then
				keypos = generator.random_empty_coord( { EF_NOBLOCK, EF_NOSTAIRS, EF_NOITEMS, EF_NOHARM, EF_NOSPAWN }, room2 )
			end
			local locked = (keypos ~= nil) and (math.random(25) < level.danger_level) and (math.random(4) == 1)
			if locked then
				generator.room_meta[room2].used = true
				local lever = level:drop_item( "lever_walls", keypos )
				lever.flags[ IF_NODESTROY ] = true
				lever:add_property( "target_area", room:shrinked(1) )
			end

			local vault = room:shrinked(2)

			if locked then
				generator.fill( generator.styles[ level.style ].wall, vault )
				generator.set_permanence( vault )
			else
				generator.fill( generator.styles[ level.style ].wall, vault )
				generator.set_cell( vault:random_inner_edge_coord(), generator.styles[ level.style ].door )
			end
			vault:shrink()
			generator.fill( generator.styles[ level.style ].floor, vault )

			local roll = math.max( math.random( 5 ) + level.danger_level + (DIFFICULTY-2)*3, 1 )
			local diffmod = (DIFFICULTY - 2)*2
			local exotic_mod = 1.5
			local unique_mod = 2
			if diffmod > 0 then diffmod = math.random( diffmod ) end

			if locked then
				roll = roll+5
				exotic_mod = 3
				unique_mod = 4
			end

			--Drop beings
			local config = {
				guard   = { { "wolf_guard1",   0.75, }, { "wolf_guard2",    0.25, },                               },
				ss      = { { "wolf_ss1",      0.8,  }, { "wolf_ss2",       0.2,  },                               },
				mutant  = { { "wolf_mutant1",  0.5,  }, { "wolf_mutant2",   0.5,  },                               },
				officer = { { "wolf_officer1", 0.8,  }, { "wolf_officer2",  0.8,  },                               },
				soldier = { { "wolf_soldier1", 0.5,  }, { "wolf_soldier2",  0.3,  }, { "wolf_soldier3",   0.2,  }, },
				trooper = { { "wolf_trooper1", 0.3,  }, { "wolf_trooper2",  0.6,  }, { "wolf_trooper3",   0.1,  }, },
				super   = { { "wolf_super",    1.0,  },                                                            },
				hans    = { { "wolf_minihans", 0.34, }, { "wolf_minitrans", 0.33, }, { "wolf_minigretel", 0.33, }, },
			}

			local monster
			    if roll < 4  then monster = 'guard'
			elseif roll < 8  then monster = 'ss'
			elseif roll < 12 then monster = 'officer'
			elseif roll < 15 then monster = 'mutant'
			elseif roll < 20 then monster = 'soldier'
			elseif roll < 26 then monster = 'trooper'
			elseif roll < 32 or level.danger_level < 50 then monster = 'super'
			else
				monster = 'hans'
			end

			for index,value in ipairs(config[monster]) do
				level:summon{value[1], math.max(math.floor( ((math.random(4)+2+diffmod)*value[2]) + 0.5 ),1), area = vault}
			end

			--Drop items
			local amount = math.random(3)+2
			local isAmmoCommon = { wolf_9mm = true, wolf_8mm = true, wolf_kurz = true, wolf_fuel = true, wolf_rocket = true, wolf_shell = true }
			local i = 1
			while i <= amount do
				local pos = generator.random_empty_coord( { EF_NOBLOCK, EF_NOSTAIRS, EF_NOITEMS, EF_NOHARM, EF_NOSPAWN }, vault )
				if not pos then break end
				local item = level:roll_item{ level = roll+3, type = { ITEMTYPE_ARMOR, ITEMTYPE_AMMO, ITEMTYPE_RANGED, ITEMTYPE_PACK }, unique_mod = unique_mod, exotic_mod = exotic_mod }
				level:drop_item( item, pos, true )

				--If the item is a weapon make the next drop ammo.  If the ammo type is rare give the player two more for free.
				local item_proto = items[item]
				if item_proto.type == ITEMTYPE_RANGED and item_proto.ammo_id and i < amount then
					local amount2 = 1
					local ammo = items[item_proto.ammo_id].id
					if not isAmmoCommon[ ammo ] then
						amount2 = 3
					end
					for ii=1,amount2 do
						local pos = generator.random_empty_coord( { EF_NOBLOCK, EF_NOSTAIRS, EF_NOITEMS, EF_NOHARM, EF_NOSPAWN }, vault )
						if not pos then break end
						level:drop_item( ammo, pos, true )
					end
					i = i + 1
				end
				i = i + 1
			end

			--Dress up the vault and close out
			generator.scatter_blood(vault,nil,30)
			level.light[ vault ][LFNOSPAWN] = true

			ui.msg( table.random_pick{
				"You feel excited!",
				"There's the smell of blood in the air!",
				"There's something special here..."
			})

			return true
		end,
	}

end
