function DoomRL.load_ranks()

	register_requirement "kill_total"
	{
		progress = function( param ) 
			if param and param ~= "" then
				return player_data.count('player/kills/killbeing[@id="'..param..'"]')
			else
				return player_data.count('player/kills')
			end
		end,
		description = function( amount, param ) 
			if param and param ~= "" then
				return "kill @y"..amount.."@r "..core.being_plural( param, amount )
			else
				return "kill @y"..amount.."@r enemies"
			end
		end,
	}

	register_requirement "kill_melee"
	{
		progress = function( param ) 
			if param and param ~= "" then
				return player_data.count('player/kills/killbeing[@id="'..param..'"]/killtype[@id="weapon-melee"]')
			else
				return player_data.count('player/kills/killtype[@id="weapon-melee"]')
			end
		end,
		description = function( amount, param ) 
			if param and param ~= "" then
				return "kill @y"..amount.."@r "..core.being_plural( param, amount ).." in melee"
			else
				return "kill @y"..amount.."@r enemies in melee"
			end
		end,
	}

	register_requirement "kill_pistol"
	{
		progress = function( param ) 
			if param and param ~= "" then
				return player_data.count('player/kills/killbeing[@id="'..param..'"]/killtype[@id="weapon-pistol"]')
			else
				return player_data.count('player/kills/killtype[@id="weapon-pistol"]')
			end
		end,
		description = function( amount, param ) 
			if param and param ~= "" then
				return "kill @y"..amount.."@r "..core.being_plural( param, amount ).." with a pistol"
			else
				return "kill @y"..amount.."@r enemies with a pistol"
			end
		end,
	}

	register_requirement "aquire_badges"
	{
		progress = function( param ) 
			local result = 0
			for k,v in ipairs( badges ) do
				if v.level == param and player_data.get_counted( 'badges', 'badge', v.id ) > 0 then
					result = result + 1
				end
			end
			return result
		end,
		description = function( amount, param )
			local names = { 'Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond', 'Angelic' }
			if amount == 1 then
				return "acquire @yone@r "..names[param].." badge"
			else
				return "acquire a total of @y"..amount.."@r "..names[param].." badges"
			end
		end,
	}

	-- Experience ranks ----------------------------------------------------

	register_exp_rank
	{
		name = "Human",
		reqs = {}
	}

	register_exp_rank
	{
		name = "Former Human",
		reqs = { { req = "kill_total", amount = 50, param = "former" } },
	}

	register_exp_rank
	{
		name = "Imp",
		reqs = {
			{ req = "kill_total", amount = 100, param = "imp" },
			{ req = "kill_melee", amount = 10 }
		}
	}

	register_exp_rank
	{
		name = "Demon",
		reqs = {
			{ req = "kill_total", amount = 100, param = "demon" },
			{ req = "kill_melee", amount = 100 },
			{ req = "kill_melee", amount = 10 , param = "demon" }
		}
	}

	register_exp_rank
	{
		name = "Cacodemon",
		reqs = {
			{ req = "kill_total",  amount = 100, param = "cacodemon" },
			{ req = "kill_pistol", amount = 10,  param = "cacodemon" },
			{ req = "kill_total",  amount = 2500 }
		}
	}

	register_exp_rank
	{
		name = "Mancubus",
		reqs = {
			{ req = "kill_total",  amount = 20, param = "mancubus" },
			{ req = "kill_pistol", amount = 5,  param = "mancubus" },
			{ req = "kill_melee",  amount = 5,  param = "mancubus" }
		}
	}

	register_exp_rank
	{
		name = "Hell Knight",
		reqs = {
			{ req = "kill_total",  amount = 200, param = "knight" },
			{ req = "kill_melee",  amount = 20,  param = "knight" },
			{ req = "kill_pistol", amount = 50,  param = "knight" }
		}
	}

	register_exp_rank
	{
		name = "Hell Baron",
		reqs = {
			{ req = "kill_total", amount = 500,  param = "baron" },
			{ req = "kill_melee", amount = 1000 },
			{ req = "kill_total", amount = 10000 },
		}
	}

	register_exp_rank
	{
		name = "Arch-Vile",
		reqs = {
			{ req = "kill_total", amount = 500, param = "arch" },
			{ req = "kill_melee", amount = 2000 },
			{ req = "kill_total", amount = 25000 }
		}
	}

	register_exp_rank
	{
		name = "Cyberdemon",
		reqs = {
			{ req = "kill_total", amount = 100,  param = "cyberdemon" },
			{ req = "kill_total", amount = 50000 }
		}
	}

	register_exp_rank
	{
		name = "Apostle",
		reqs = {
			{ req = "kill_total", amount = 50,  param = "jc" },
		}
	}

	-- Skill ranks ---------------------------------------------------------


	register_skill_rank
	{
		name = "Private",
		reqs = {}
	}

	register_skill_rank
	{
		name = "Private FC",
		reqs = { { req = "aquire_badges", param = 1, amount = 1 } }
	}

	register_skill_rank
	{
		name = "Lance Corporal",
		reqs = {
			{ req = "aquire_badges", param = 1, amount = 3 }
		}
	}

	register_skill_rank
	{
		name = "Corporal",
		reqs = {
			{ req = "aquire_badges", param = 1, amount = 6 }
		}
	}

	register_skill_rank
	{
		name = "Sergeant",
		reqs = {
			{ req = "aquire_badges", param = 1, amount = 9 },
			{ req = "aquire_badges", param = 2, amount = 1 }
		}
	}

	register_skill_rank
	{
		name = "Sergeant Major",
		reqs = {
			{ req = "aquire_badges", param = 1, amount = 12 },
			{ req = "aquire_badges", param = 2, amount = 3 },
		}
	}

	register_skill_rank
	{
		name = "Warrant Officer",
		reqs = {
			{ req = "aquire_badges", param = 1, amount = 15 },
			{ req = "aquire_badges", param = 2, amount = 6 }
		}
	}

	register_skill_rank
	{
		name = "2nd Lieutenant",
		reqs = {
			{ req = "aquire_badges", param = 2, amount = 9 },
			{ req = "aquire_badges", param = 3, amount = 1 }
		}
	}

	register_skill_rank
	{
		name = "1st Lieutenant",
		reqs = {
			{ req = "aquire_badges", param = 2, amount = 12 },
			{ req = "aquire_badges", param = 3, amount = 3 }
		}
	}

	register_skill_rank
	{
		name = "Captain",
		reqs = {
			{ req = "aquire_badges", param = 2, amount = 15 },
			{ req = "aquire_badges", param = 3, amount = 6 }
		}
	}

	register_skill_rank
	{
		name = "Major",
		reqs = {
			{ req = "aquire_badges", param = 3, amount = 9 },
			{ req = "aquire_badges", param = 4, amount = 1 }
		}
	}

	register_skill_rank
	{
		name = "Lt. Colonel",
		reqs = {
			{ req = "aquire_badges", param = 3, amount = 12 },
			{ req = "aquire_badges", param = 4, amount = 2 }
		}
	}

	register_skill_rank
	{
		name = "Colonel",
		reqs = {
			{ req = "aquire_badges", param = 3, amount = 15 },
			{ req = "aquire_badges", param = 4, amount = 3 }
		}
	}

	register_skill_rank
	{
		name = "Br. General",
		reqs = {
			{ req = "aquire_badges", param = 4, amount = 5 },
			{ req = "aquire_badges", param = 5, amount = 1 }
		}
	}

	register_skill_rank
	{
		name = "Mjr General",
		reqs = {
			{ req = "aquire_badges", param = 4, amount = 7 },
			{ req = "aquire_badges", param = 5, amount = 2 }
		}
	}

	register_skill_rank
	{
		name = "Lt. General",
		reqs = {
			{ req = "aquire_badges", param = 4, amount = 9 },
			{ req = "aquire_badges", param = 5, amount = 3 }
		}
	}

	register_skill_rank
	{
		name = "General",
		reqs = {
			{ req = "aquire_badges", param = 4, amount = 12 },
			{ req = "aquire_badges", param = 5, amount = 5 }
		}
	}

	register_skill_rank
	{
		name = "Marshal",
		reqs = {
			{ req = "aquire_badges", param = 4, amount = 15 },
			{ req = "aquire_badges", param = 5, amount = 7 }
		}
	}

	register_skill_rank
	{
		name = "Chaos Major",
		reqs = {
			{ req = "aquire_badges", param = 5, amount = 9 }
		}
	}

	register_skill_rank
	{
		name = "Chaos Lt. Colonel",
		reqs = {
			{ req = "aquire_badges", param = 5, amount = 12 }
		}
	}

	register_skill_rank
	{
		name = "Chaos Colonel",
		reqs = {
			{ req = "aquire_badges", param = 5, amount = 15 }
		}
	}

	register_skill_rank
	{
		name = "Chaos Br. General",
		reqs = {
			{ req = "aquire_badges", param = 6, amount = 3 }
		}
	}

	register_skill_rank
	{
		name = "Chaos Mjr General",
		reqs = {
			{ req = "aquire_badges", param = 6, amount = 6 }
		}
	}

	register_skill_rank
	{
		name = "Chaos Lt. General",
		reqs = {
			{ req = "aquire_badges", param = 6, amount = 9 }
		}
	}

	register_skill_rank
	{
		name = "Chaos General",
		reqs = {
			{ req = "aquire_badges", param = 6, amount = 12 }
		}
	}

	register_skill_rank
	{
		name = "Chaos Marshal",
		reqs = {
			{ req = "aquire_badges", param = 6, amount = 15 }
		}
	}

	register_skill_rank
	{
		name = "No-Life King",
		reqs = {
			{ req = "aquire_badges", param = 6, amount = 17 }
		}
	}
end
