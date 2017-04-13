--[[ If you've gotten to this level you've won.  The AoD is optional;
     in this fight I want you dead.  There's no fair play here--the AoD is
     tough as nails and can one-shot you.  The only people I want winning
     this fight are hard-asses who have planned for it, and if a cheap
     trick that works for everyone is discovered I will change the AI to
     prevent it.

     Earn your happy ending.
--]]

register_level "spear5" {
	name  = "Hell",
	welcome = "Hey! Where's my fat reward and ticket home!?",

	Create = function ()
		generator.fill( "floor", area.FULL )
		generator.scatter_blood(area.FULL_SHRINKED,"floor",math.random(20)+70)

		local basetranslation = {
			['.'] = "floor",
			['&'] = "wolf_bdwall",
			['%'] = { "wolf_blwall", flags = { LFPERMANENT } },
			['='] = "floor",
		}
		local gametranslation = {
			['.'] = "floor",
			['&'] = "wolf_bdwall",
			['%'] = { "wolf_blwall", flags = { LFPERMANENT } },
			['='] = { "mdoor2", flags = { LFPERMANENT } },
		}
		local map = [[
....&&&&&&............&&&&&.....&&&&&......&&&&......................&&&&&&&&&
&......&&.....&&.....&&&&.......&&....................&&&&&&&&&...........&&&&
&............&&&....&&&&..............&&&&...&&&&&...&&&&&&&&&&.............&&
&....&&&....&&&....&&&&....&&&&...&&&&&&......&&&..&&&&..&.&&......&&&.......&
&&..&&&&&...&&&....&&&...&&&&&...&&&.......&&......&&&&&...&&&...&&&&&&&.....&
&&..&&&&....&&......&...&&&&&...&&&..%%%%%..&&.......&&&...&&&...&&&&&&&......
&&...&&....&&&..........&&&.....&&...%%.%%..&&&..........&&&&&&..&&&&&&&&.....
&&&.......&&&..........&&&&&&........%%.%%..&&&....&&....&&&&&&&...&&&&&&&&...
&&&.....&&&&...........&&&.&&...&&&..%%=%%..&&....&&&&....&&&&&&......&&&&...&
&&&....&&&&........&&...&&......&&&.........&&....&&&&....&&&&&&............&&
&&....&&&&...&&&..&&&...&&&&.....&&&&&&...&&&&...&&&&&....&&&&&.............&&
&&.....&&...&&&&..&&&.....&&&.....&&&&...&&&.....&&&&....&&.................&&
&..........&&&&...&&&&.............&&..........&&&&&............&&&&&&&&.....&
..........&&&&&...&&&&......&&&.............&&&&&&.............&&&&&&&&&&....&
..........&&&&&&....&&&&...&&&&&&...........&&&&&&...&&...&&&....&&&...&&&....
....&&&.&&&&&&&&&....&&&.....&&&&&&..&.......&&&....&&&&..&&&&.......&&&&.....
...&&.&&&&&&&&&&&.....&&........&&&&&&&.&..&........&&&&..&&&&...............&
...&&..&&&&&&&&......&&&..&&.......&&&&&&&&&&&.......&&&.&&&&&.............&&&
....&&.&&&&..........&&...&&&&..........&&&&&&......&&&&&&&&&.........&&&&&.&&
&...............&&.......&&&&&&&..................&&&&&&&&&.......&&&&&&&&&&&&
]]
		generator.place_tile( basetranslation, map, 1, 1 )
		generator.place_tile( gametranslation, map, 1, 1 )
		generator.scatter( area.FULL,"floor","bloodpool", math.random(20))
		generator.scatter( area.FULL,"floor","bones1", math.random(20))
		generator.scatter( area.FULL,"floor","bones2", math.random(20))

		level.flags[ LF_NONUKE ] = true
		level.flags[ LF_NOHOMING ] = true
		level:player(40,7)
	end,

	OnEnter = function ()
		local boss = level:drop_being("wolf_bossangel",coord.new(48,2))
		boss.flags[ BF_BOSS ] = true

		player:win()
		player:continue_game()
		for c in area.coords(area.new( 38, 6, 42, 10 )) do
			level.light[ c ][LFEXPLORED] = true
		end

		player:add_property( "wolf_ghosttable", {ghosts = 0, maxghosts = DIFFICULTY * 4, timeout = 0} )
	end,

	OnFire = function(item,being)
		--Gunplay is not allowed unless you brought along an otherwise worthless trinket from an as of yet undefined special level.
		if being:is_player() and item.itype == ITEMTYPE_RANGED then
			ui.msg("You pull the trigger... nothing happens!")
			return false
		end
		return true
	end,

	OnUse = function (item, being)
		--Crystals are not usable on this level.  Should've used them against DK.
		if item.id == "wolf_upowerc" or item.id == "wolf_ushieldc" or item.id == "wolf_umirec" then
			being:msg("The crystal has no power over Hell!")
			return false
		end
	end,

	OnTick = function ()
		--ghosts never die but they do run off.  The more ghosts the larger the timeout.
		local timeout = ((player.wolf_ghosttable.ghosts + 1) ^ 0.6) * 5
		if player.wolf_ghosttable.timeout > timeout then
			player.wolf_ghosttable.timeout = timeout
		elseif player.wolf_ghosttable.timeout <= 0 then
			if player.wolf_ghosttable.ghosts < player.wolf_ghosttable.maxghosts then
				player.wolf_ghosttable.timeout = timeout
				player.wolf_ghosttable.ghosts = player.wolf_ghosttable.ghosts + 1
				local ghost = level:drop_being("wolf_spirit", generator.random_empty_coord{ EF_NOBEINGS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN })
				ghost.flags[ BF_HUNTING ] = true
				ghost:play_sound("wolf_spirit.spawn")
			end
		else
			player.wolf_ghosttable.timeout = player.wolf_ghosttable.timeout - 0.1
		end
	end,

	OnKill = function (being)
		if being.id == "wolf_bossangel" and player.hp > 0 then
			--You won unless you died too.  AOD doesn't respect you dying.
			being:play_sound("wolf_bossangel.win")
			for b in level:beings() do
				if (not b:is_player() and not being.id == "wolf_bossangel") then
					b:kill()
				end
			end

			if statistics.damage_on_level == 0 then
				player:add_history("He managed to cheat his way out of Hell.")
			else
				player:add_history("He proved his worth in Hell.")
			end
			ui.msg_enter("Congratulations! You defeated the Angel of Death!")
		elseif being.id == "wolf_spirit" then
			player.wolf_ghosttable.ghosts = player.wolf_ghosttable.ghosts - 1
		end
	end,

	OnExit = function ()
		player:remove_property( "wolf_ghosttable" )
	end,
}
