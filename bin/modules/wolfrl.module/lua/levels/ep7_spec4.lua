--[[ The artillery range.  Artillery is fired much like the explosion_event except
     that the rate of fire is once every 2 seconds and there is a distinct pattern
     to the fire.  There should be few if any enemies on this level and there should
     be scattered items and targets in the field to both encourage you to rush in and
     give the level something to blow up.  Graphically this level--if we have the
     sprites to do dirt and to torch grass--could be very interesting.

     An alternate level mode that can occur based on previous player actions is a single
     erratic mortar being fired.  Less damage potential, but far harder to predict.
--]]

register_level "range" {
	name  = "The Artillery Range",
	entry = "On level @1 he stumbled onto an artillery range.",
	welcome = "You hear artillery being fired!",
	level = {15,16},

	canGenerate = function ()
		return not DoomRL.isepisode()
	end,

	OnCompletedCheck = function ()
		return level.status == 3 or level.status == 4
	end,

	OnRegister = function ()

	end,

	Create = function ()
		level.name = "Thunder In The Sky"
		--level.name = "Death From Above"
		--level.name = "Shell Shock"
		generator.fill( "void", area.FULL )

		local basetranslation = {
			['.'] = "floor",
			[','] = "grass1",

			["`"] = "void",
			[">"] = "stairs",
			['#'] = "wolf_whwall",
			['&'] = "wolf_whwall",
			['%'] = "wolf_rfwall",

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },
		}
		local gametranslation = {
			['.'] = "floor",
			[','] = "grass1",

			["`"] = "void",
			[">"] = "stairs",
			['#'] = "wolf_whwall",
			['&'] = "wolf_flrsign1",
			['%'] = "wolf_rfwall",

			["+"] = "door",
			["="] = { "lmdoor1", flags = { LFPERMANENT } },
			["-"] = { "lmdoor2", flags = { LFPERMANENT } },
		}


		local map = [[
,,,,,,,,,,,,%%%,,,,,,,,,,,,,,,,,,,,,,,,.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,##,#...
,,,,,,,,,,,%%%,,,,,,,,#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,##,,,,,,,,,,,,,,,,##,#.>.
,,,##+##,,%%%,,,,##,,,,,,,,,,,,#####,,,,,,,,,,,,,,,,#,,,,,,,,,,,,####,##,#...
,,,#...#,,%%%%,,,##,,,,,,,,,,,,,...,,,,,,,,,,,,,,,#,,,,,,,,,,,,,,,..#,##,#...
,,,#...#,,,%%%,,,,,,,,,,,,,,,,,,,#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,.#,##,#...
,,,#####,,%%%,,,,,.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#,##,#...
,,,,,,,,,&,%%,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,##,##+#
.................,,,,,,,#,,,,,,,.,,,,,,,,,#,,,,,,,,,,,,,,,#,,,,,,,,,,,##,,,,,
,,,,,,,,,&,%%,,,,,,,,,,,#.,,,,,,,,,,,,,,,...,,,,,,,,,,,,,..#,,,,,,,,,,##,,,,,
,,,#####,,,%%%,,,,,,,,,,##,,,,,,,,,,,,,,.,,,#,,,,,,,,,,,...#,,,,,,,,,,##,&,,,
,,,+...#,,%%%%,,,,,,,,,,,,,,,,,,,,,,,,,..,,,,,,,,,,,,,,,,###,,,,,...,........
,,,#...#,,,%%%,,,,,,,,,,##,,,,,,,,,,,,,,##,,,,,,,,,,,,,,,,,,,,,,,,,,,,##,&,,,
#,,#####,,,,%%,,,,,,,,,,,,,,,,,,,,,,,,,,,#,,,,,,,,,,,,,,,,,,,,,,,,,,,,##,,,,,
#,,,,,,,,,,,,%%,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#,,,,,,,,##,,,,,
#,,,,,,,,,,,%%%%,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,##,##+#
#,,,,#####,,,%%,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#,##,#...
#,,,,+...#,,%%,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,##,#...
#,,,,#...#,,%%,,,,,#,,,,,,,,,,,,...,,,,,,,,,,,,,#,,,,,,,,,,,,,,,,,##,,##,#...
#,,,,#####,%%%%,,,,##,,,,,,,,,,#####,,,,,,,,,,,##,,,,,,,,,,,,,,,,..#,,##,#.>.
#,,,,,,,,,,,%%%%,,,,,,,,,,,,.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,########,,##,#...
]]
		generator.place_tile( basetranslation, map, 1, 1 )
		generator.place_tile( gametranslation, map, 1, 1 )

		level:player(2, 8)
	end,

	OnEnter = function ()
		level.status = math.random(2) --Todo: make this dependant on previous level conditions

		level.data.target_area = area.new(19,2,68,19)
		level.data.units = {}
		if (level.status == 1) then
			--Normal operation, two crossing artillery paths
			level.data.units[1] = { fire_next = 20, fire_delay = 20, fire_random = 0,  fire_pos = coord.new(58,5),  fire_step = coord.new(-2,2),  fire_shift = 0 }
			level.data.units[2] = { fire_next = 20, fire_delay = 20, fire_random = 0,  fire_pos = coord.new(58,15), fire_step = coord.new(-2,-2), fire_shift = 0 }
		else
			--Damaged operation, half capacity with erratic aim
			level.data.units[1] = { fire_next = 30, fire_delay = 30, fire_random = 20, fire_pos = coord.new(58,10), fire_step = coord.new(-4,0),  fire_shift = 3 }
		end
	end,

	OnTick = function ()
		local playedSound = false
		for _,unit in ipairs(level.data.units) do
			unit.fire_next = unit.fire_next - 1
			if (unit.fire_next == math.ceil(unit.fire_delay/2) and playedSound == false) then
				playedSound = true
				--player:play_sound("artillery")
			elseif unit.fire_next <= 0 then
				--Fire in the hole!
				unit.fire_next = unit.fire_delay
				if (unit.fire_random >= 1) then unit.fire_next = unit.fire_next + math.random(unit.fire_random) end

				--Create the new position.  We BOUNCE it off the area borders, not clamp it.
				local new_coord = area.around( unit.fire_pos + unit.fire_step, unit.fire_shift ):random_coord()
				local new_clamped_coord = coord.clone( new_coord )
				level.data.target_area:clamp_coord(new_clamped_coord)
				unit.fire_pos = new_clamped_coord - (new_coord - new_clamped_coord)

				--Boing!
				if (new_coord.x ~= new_clamped_coord.x) then
					unit.fire_step = coord.new(-unit.fire_step.x, unit.fire_step.y)
				elseif (new_coord.y ~= new_clamped_coord.y) then
					unit.fire_step = coord.new(unit.fire_step.x, -unit.fire_step.y)
				end

				level:explosion( unit.fire_pos, 2, 50, 6, 6, LIGHTRED, "barrel.explode", DAMAGE_FIRE)
			end
		end
	end,

	OnExit = function (being)
		if statistics.damage_on_level == 0 then
			player:add_history("He marched through it flawlessly.")
		else
			player:add_history("He passed through it in one piece.")
		end

		level.status = level.status + 2
	end,
}
