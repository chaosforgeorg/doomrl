--[[ The final boss level isn't actually that difficult once you get past
     the initial rush.  The non-boss enemies are just fodder and the DK,
     while a powerhouse, is slow and there are plenty of corners to hide
     behind.  I'd like to change his AI to have him blindly rocket your
     direction if you're corner tricking him but ultimately this level is
     almost a breather compared to what comes next.
--]]

register_level "spear4" {
	name  = "Rampart Boss",
	entry = "Then at last he reached the Spear of Destiny.",
	welcome = "You can feel its presence! The Spear of Destiny is here!",

	Create = function ()
		generator.fill( "void", area.FULL )
		generator.fill( "floor", area.new( 17, 2, 64, 19 ) )

		local translation = {
			['.'] = "floor",
			["`"] = "void",
			['O'] = { "pillar", flags = { LFPERMANENT } },
			['#'] = { "wolf_whwall", flags = { LFPERMANENT } },
			['&'] = "wolf_whwall",
			['%'] = { "wolf_blwall", flags = { LFPERMANENT } },

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "mdoor2", flags = { LFPERMANENT } },

			['*'] = { "floor", item = "wolf_smed" },
			['!'] = { "floor", item = "wolf_lmed" },
			['|'] = { "floor", item = "wolf_8mm" },
			[':'] = { "floor", item = "wolf_rocket" },
			['/'] = { "floor", item = "wolf_spear" },

			["a"] = {"floor", being = "wolf_guard1"},
			["b"] = {"floor", being = "wolf_dog1"},
			["c"] = {"floor", being = "wolf_ss1"},
			["d"] = {"floor", being = "wolf_officer1"},
			["e"] = {"floor", being = "wolf_mutant1"},
			["f"] = {"floor", being = "wolf_mutant2"},

			["@"] = {"floor", being = "wolf_bossknight"},
			["?"] = "floor",

			["1"] = {"floor", being = core.bydiff{nil, "wolf_guard2"}},
			["2"] = {"floor", being = core.bydiff{nil, nil, "wolf_guard1"}},
			["3"] = {"floor", being = core.bydiff{nil, nil, nil, "wolf_guard1"}},
			["4"] = {"floor", being = core.bydiff{nil, "wolf_guard1", "wolf_ss2"}},
			["5"] = {"floor", being = core.bydiff{nil, nil, "wolf_ss1"}},
			["6"] = {"floor", being = core.bydiff{nil, nil, nil, "wolf_ss1"}},
			["7"] = {"floor", being = core.bydiff{nil, "wolf_guard1", "wolf_ss1", "wolf_officer2"}},
			["8"] = {"floor", being = core.bydiff{nil, nil, "wolf_ss1", "wolf_officer1"}},
			["9"] = {"floor", being = core.bydiff{nil, nil, nil, "wolf_officer1"}},
		}
		if math.random(2) == 1 then
			translation["?"] = {"floor", being = "wolf_bossknight"}
			translation["@"] = "floor"
		end


		local map = [[
#O###O###O###O###O###O###O###O###O###O###O###O#
#d...........................................c#
#.&&.......................................&&.#
#.&&...&&&.&&&&&&+&&&&&&&&&&&+&&&&&&.&&&&..&&.#
#c.....&&&&&&&......9%%%%%9......&&&&&&&.....d#
#&&&...:&&&&5....?...%%/%%...@....1&&&&:...&&&#
#&....7&&&&&&&.......%%.%%.......&&&&&&&8....&#
#*..&&&&&&f&&&.......%%=%%.......&&&e&&&&&&..*#
#9...&&&...............................&&&...9#
#9...&&&...............................&&&...9#
#*..&&&&&&e&&&...................&&&f&&&&&&..*#
#&....8&&&&&&&....&&-&&-&&-&&....&&&&&&&7....&#
#&&&...:&&&&2.....&!..|..|.:&.....4&&&&:...&&&#
#d.....&&&&&&&....&:|..|.|.!&....&&&&&&&.....c#
#.&&...&&&.&&&&&&+&&&&&&&&&&&+&&&&&&.&&&...&&.#
#.&&.......................................&&.#
#c...........................................d#
#O###O###O###O###O###O###O###O###O###O###O###O#
]]
		generator.place_tile( translation, map, 17, 2 )

		level.flags[ LF_NOHOMING ] = true
		level:player(38, 14)
	end,

	OnPickup = function (item, being)
		--The spear teleports you to the last level.
		if item and item.id == "wolf_spear" and being == player then
			player:play_sound("wolf_spear.win")
			ui.msg_enter("You did it! You got the spear!")
			player:quick_weapon(item.id)
			player:exit()
		end
	end,

	OnKill = function (being)
		if being.id == "wolf_bossknight" then
			--Drop key, which is a powerup and thus must actually be spawned here.
			local key = level:drop_item( "wolf_key1", being.position )
			if (key == nil) then
				--Emergency backup, unlock the doors manually
				items[ "wolf_key1" ].OnPickup(nil, player)
			elseif (key.position ~= being.position) then
				--This ensures the key doesn't get dropped behind a locked door
				local otherItem = level:get_item(being.position)
				if (otherItem ~= nil) then
					otherItem:displace(key.position)
				end
				key:displace(being.position)
			end
		end
	end,

	OnNuked = function()
		if player.hp <= 0 then
			player:win() --sacrifice victory
		end
	end,

	OnExit = function ()
		if statistics.damage_on_level == 0 then
			player:add_history("He liberated the spear with godlike precision.")
		else
			player:add_history("He liberated the spear.")
		end
	end,
}