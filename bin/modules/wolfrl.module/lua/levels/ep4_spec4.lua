--[[ Blake Stone, the ill fated continuation of the Wolf3D engine that couldn't
     hold a candle to Doom.  This is our one and only whole level reference
     (Pac-Man doesn't count since it's in the original Wolf3D) and I intend
     to go all out with it.

     Having a red teleporter instead of red stairs would be nice but it would also be hacky.
--]]

register_level "spec4" {
	name  = "STAR Labs",
	entry = "On level @1 he wandered into an unfamiliar realm.",
	welcome = "This place is futuristic!",
	level = {7,8},

	canGenerate = function ()
		return CHALLENGE == "challenge_ep4"
	end,

	OnCompletedCheck = function ()
		return level.status >= 4
	end,

	OnRegister = function ()
		register_medal "star1" {
			name  = "Red Keycard",
			desc  = "Awarded for sparing informants.",
			hidden  = true,
		}
		register_medal "star2" {
			name  = "Gold Keycard",
			desc  = "Awarded for stealthily clearing the level.",
			hidden  = true,
		}

		register_item "blake_lever" {
			name     = "lever",
			sound_id = "blake_lever",
			color_id = "blake_lever",
			ascii    = "&",
			color    = LIGHTGRAY,
			sprite   = SPRITE_LEVER,
			weight   = 0,
			type     = ITEMTYPE_LEVER,
			flags    = { IF_NODESTROY },

			good = "neutral",
			desc = "toggle barriers",

			OnCreate = function(self)
				self:add_property( "cell_on", nil )
				self:add_property( "cell_off", nil )
				self:add_property( "toggle_on", nil )
				self:add_property( "target_area", nil )
			end,

			OnUse = function(self, being)
				local cell_from = self.cell_on
				local cell_to = self.cell_off
				if (self.toggle_on) then cell_from, cell_to = cell_to, cell_from end

				local gotCell = false
				for _,v in ipairs(self.target_area) do
					local room = v:clamped( area.FULL_SHRINKED )
					for c in room() do
						local tile = level.map[ c ]
						if tile == cell_from then
							gotCell = true
							level.map[ c ] = cell_to
						end
					end
				end

				if gotCell then
					if (self.toggle_on) then
						self.toggle_on = false
						ui.msg("Activating barrier on floor " .. level.name_number)
					else
						self.toggle_on = true
						ui.msg("Deactivating barrier on floor " .. level.name_number)
					end
				else
					ui.msg("Nothing happens.")
				end

				return false --This can be toggled multiple times so never destroy it
			end,
		}

	end,

	Create = function ()
		generator.fill( "void", area.FULL )

		local informants = table.shuffle{ "blake_informant", core.bydiff{"blake_informant", "blake_informant", "blake_informant", "blake_tech"}, core.bydiff{"blake_informant", "blake_informant", "blake_tech", "blake_tech"}, core.bydiff{"blake_informant", "blake_tech", "blake_tech", "blake_tech"}, "blake_tech"}
		local gametranslation = {
			['.'] = "floor",
			[','] = { "floor", flags = { LFBLOOD } },
			["`"] = "void",
			['#'] = { "blake_cywall", flags = { LFPERMANENT } },
			['X'] = { "blake_brwall", flags = { LFPERMANENT } },
			['Y'] = { "blake_whwall", flags = { LFPERMANENT } },
			['Z'] = { "blake_blwall", flags = { LFPERMANENT } },
			['$'] = { "blake_whwall", flags = { LFPERMANENT } },
			['%'] = { "blake_elevatorwall", flags = { LFPERMANENT } },
			['^'] = { "blake_pushwall", flags = { LFPERMANENT } },
			['Q'] = "crate",
			['~'] = { "blake_ebarrier", flags = { LFPERMANENT } },
			['o'] = { "blake_barrier", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "mdoor1", flags = { LFPERMANENT } },
			["-"] = { "mdoor2", flags = { LFPERMANENT } },

			['&'] = { "floor", item = { "blake_lever", cell_on = "blake_ebarrier", cell_off = "floor", toggle_on = false, target_area = { area.new(22,4,34,4), area.new(24,3,29,3) } } },
			['@'] = { "floor", item = { "blake_lever", cell_on = "blake_ebarrier", cell_off = "floor", toggle_on = false, target_area = { area.new(68,2,68,3), area.new(69,4,72,4) } } },
			['w'] = { "floor", item = "blake_pistol2" },
			['x'] = { "floor", item = "blake_rifle1" },
			['y'] = { "floor", item = "blake_rifle2" },
			['z'] = { "floor", item = "blake_bazooka" },

			["1"] = { "floor", being = "blake_patrol" },
			["2"] = { "floor", being = "blake_sentinel" },
			["3"] = { "floor", being = "blake_trooper" },
			["4"] = { "floor", being = "blake_genalien" },
			["5"] = { "floor", being = "blake_genguard" },
			["6"] = { "floor", being = "blake_esphere" },
			["7"] = { "floor", being = "blake_plasalien" },
			["8"] = { "floor", being = "blake_podalien" },
			["9"] = { "floor", being = "blake_mech" },

			["a"] = { "floor", being = informants[1] },
			["b"] = { "floor", being = informants[2] },
			["c"] = { "floor", being = informants[3] },
			["d"] = { "floor", being = informants[4] },
			["e"] = { "floor", being = informants[5] },
		}

		local map = [[
```````ZZZZZZZZZZZZZZZZZZZZZZZZ````````````````````ZZZZZZZZZZZZZZZZZ```
```````Z.......ZZZ$ZZZZZ.Q..Q.Z````````````````````Z&5.........~...ZZ``
```````Z...........~~~~~~..4.QZ````````````````````Z5..........~....Z``
```````Z...ZZZZZZ~~~ZZZZ~~~~~~ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ~~~~Z``
```````Z...ZZ..................#...................#................Z``
```````Z...ZZ..................+.........1.........+...............ZZ``
XXXXXXXZZ+ZZZ########+###############################+#######+#######``
Xd.........XX##................................1........###........##YY
XX..........X#...##############.a..#####%%%%%%....#########1........+.Y
XX...XXX....X#...+............+....#####%....%...####################.Y
XXX...3XX...X#...#...######...#....#####%....=...###YYYYYYYYYYYYYY..+.Y
XXX...XXX.7.X#...###$######$###....#####%%%%%%..b##YYe.........1YY..YYY
XXX...2XX...X#...#..1######...#....o,4.,,...xo...##Y...8YYYYY....Y...YY
XX...XXX....X#...+............+....o.......,,o...##Y...YYz..YY...Y...YY
XX..........X#...##############....########^##...##Y9............+...YY
Xy.........XX##.................c.......1.......###Y...YY...YY...Y...YY
XXXXXXXXXXXXX###^###########^###########+##########Y...8YYYYY....YYYYYY
`````````````#.....6.....6.....#####........@#`````YY..........1YY`````
`````````````#........6........#####.w.......#``````YYYYYYYYYYYYY``````
`````````````#################################`````````````````````````
]]

		generator.place_tile( gametranslation, map, 5, 1)
		level:player(23, 8)
	end,

	OnEnter = function ()
		level.status = 0
		level.data.noise = 0
		level.data.informants = 0
		for b in level:beings() do
			if (b.id == "blake_informant") then
				level.data.informants = level.data.informants + 1
			end
		end

		player.inv:add(item.new("blake_pistol1"))
		player:quick_weapon("blake_pistol1")
	end,

	OnExit = function (being)
		local enemies_alive = 0
		local informants_alive = 0
		for b in level:beings() do
			if (b.id == "blake_informant") then
				informants_alive = informants_alive + 1
			else
				enemies_alive = enemies_alive + 1
			end
		end
		statistics.max_kills = statistics.max_kills - informants_alive

		--Print a message based on if we cleared out all enemies, killed informants, or stealthed everyone
		--todo
	end,
}
