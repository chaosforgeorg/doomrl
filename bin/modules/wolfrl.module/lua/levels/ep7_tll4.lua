--[[ The robot controls the laboratory which is off limits if you blew up
     the teleporter level.  If you power up the lab the robot becomes active
     and attacks you.  Additional sentries may be nice; will have to see.

     I do know that this level needs to be cramped and dangerous and that
     the switch should unlock alternate stairs and the rewards.  A homing phase
     will let you bypass the stage and grab ONE of the rewards if you broke
     the lab earlier.
--]]

register_level "tll4" {
	name  = "The Lab",
	entry = "On level @1 he detoured to meet the Robot.",
	welcome = "Electricity hums in the background.",
	level = 23,

	canGenerate = function ()
		return DIFFICULTY >= DIFF_MEDIUM and not DoomRL.isepisode()
	end,

	OnCompletedCheck = function ()
		return level.status == 7 or level.status == 8
	end,

	OnRegister = function ()
		register_item "lever_powerlab" {
			name   = "lever",
			color  = WHITE,
			sprite = SPRITE_LEVER,
			weight = 0,
			type   = ITEMTYPE_LEVER,
			flags  = { IF_NODESTROY },

			good = "dangerous",
			desc = "opens the lab",

			color_id = false,

			OnUse = function(self,being)
				if level.status == 1 or level.status == 2 then
					level.status = level.status + 2
					ui.msg("Some of the lights flicker on.")
					return true
				elseif level.status == 3 or level.status == 4 then
					level.status = level.status + 2
					ui.msg("The lab springs to life!")
					generator.transmute("wolf_rewall", "floor")
					return true
				else
					return false
				end
			end,
		}
		register_item "lever_powerlabbroken" {
			name   = "broken lever",
			color  = LIGHTGRAY,
			sprite = SPRITE_LEVER,
			weight = 0,
			type   = ITEMTYPE_LEVER,
			flags  = { IF_NODESTROY },

			good = "dangerous",
			desc = "powers the lab",

			color_id = false,

			OnUse = function(self,being)
				ui.msg("Nothing happens...")
				return false
			end,
		}
	end,

	Create = function ()
		level.name = "Metal Gods"
		generator.fill( "void", area.FULL )

		--If the teleporter lab was blown up disable a lever (todo, level status data)
		level.status = 1 --or 2 if the lab was busted
		local translation = {
			['.'] = "floor",
			['~'] = "water",
			['"'] = "bridge",
			
			["`"] = "void",
			[">"] = "stairs",
			["<"] = "ystairs",
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },
			['$'] = { "wolf_whwall", flags = { LFPERMANENT } }, --Todo: flarify special levels
			['-'] = "wolf_rewall",
			['|'] = "wolf_rewall", --flair

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			--["-"] = { "lmdoor2", flags = { LFPERMANENT } },

			["&"] = { "floor", item = "lever_powerlab" },
			["%"] = { "floor", item = "lever_powerlab" },
			["@"] = { "floor", being = "wolf_bossrobot" },
		}

		local map = [[
#######`````````````````#############
#.....#`````````````````#...........#
#..<..####################+####.....#
#.....#.#.....|.......|.....#`#.....#
#.....#.+.....|.......|..@..#`#.....#
#.....#&#.....####+####-----#`#.....#
#.....###.....#`#...#`#.....#`#.....#
#.....#`#.....#`#...#`#.....#`#.....#
#.....#`#.....#`#...#`#.....#`#.....#
#.....#`#.....#########-----#`#.....#
#.....#`#...................#`#.....#
#.....#`#...................#`#.....#
#.....####+##############+###`#...>.#
#...........#`````````#%....#`#.....#
#############`````````#######`#######
]]
		generator.place_tile( translation, map, 18, 3 )

		level:player(22, 10)
	end,

	OnEnter = function ()

	end,

	OnKill = function (being)
		if being.id == "wolf_bossrobot" then
			while level.status < 7 do
				level.status = level.status + 2
			end
		end
	end,

	OnTick = function ()
		--Cheater way to keep the robot from doing anything until the lab is activated.
		if level.status < 5 then
			for b in level:beings() do
				if (b ~= player) then
					b.scount = 0
				end
			end
		end
	end,

	OnExit = function (being)
		if level.status == 8 then
			player:add_history("He bypassed the lab and slipped away with the goodies.")
		elseif level.status == 7 then
			if statistics.damage_on_level == 0 then
				player:add_history("He ransacked the lab without damage.")
			else
				player:add_history("He ransacked the lab and escaped.")
			end
		elseif level.status == 5 or level.status == 6 then
			player:add_history("The lab's security proved ample.")
		else
			player:add_history("Not knowing what to do he left.")
		end
	end,
}
