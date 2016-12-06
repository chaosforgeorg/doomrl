--TODO: Modify these requirements so that we can count multiple enemies against the kill counter.
function DoomRL.load_ranks()

	register_requirement "kill_total" {
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
	register_requirement "kill_melee" {
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
	register_requirement "kill_pistol" {
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
	register_requirement "aquire_badges" {
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


	--Experience rankings work according to the old adage: kill one person and you're a murder, kill everyone and you're a god
	register_exp_rank {
		name = "Thug",
		reqs = {}
	}
	register_exp_rank {
		name = "Killer",
		reqs = { { req = "kill_total", amount = 50, param = "wolf_guard1" } },
	}
	register_exp_rank {
		name = "Conscript",
		reqs = {
			{ req = "kill_total", amount = 100, param = "wolf_ss1" },
			{ req = "kill_melee", amount = 10 }
		}
	}
	register_exp_rank {
		name = "Combatant",
		reqs = {
			{ req = "kill_total", amount = 100, param = "wolf_officer1" },
			{ req = "kill_melee", amount = 100 },
			{ req = "kill_melee", amount = 10 , param = "wolf_officer1" }
		}
	}
	register_exp_rank {
		name = "Fighter",
		reqs = {
			{ req = "kill_total",  amount = 100, param = "wolf_mutant1" },
			{ req = "kill_total",  amount = 100, param = "wolf_mutant2" },
			{ req = "kill_total",  amount = 2500 }
		}
	}
	register_exp_rank {
		name = "Soldier",
		reqs = {
			{ req = "kill_total",  amount = 20, param = "wolf_fakehitler" },
			{ req = "kill_pistol", amount = 5,  param = "wolf_mutant2" },
			{ req = "kill_melee",  amount = 5,  param = "wolf_mutant1" }
		}
	}
	register_exp_rank {
		name = "Trooper",
		reqs = {
			{ req = "kill_total", amount = 500,  param = "wolf_soldier1" },
			{ req = "kill_melee", amount = 1000 },
			{ req = "kill_total", amount = 10000 },
		}
	}
	register_exp_rank {
		name = "Warrior",
		reqs = {
			{ req = "kill_total",  amount = 200, param = "wolf_trooper2" },
			{ req = "kill_melee",  amount = 20,  param = "wolf_trooper1" },
			{ req = "kill_pistol", amount = 50,  param = "wolf_trooper3" }
		}
	}
	register_exp_rank {
		name = "Subjugator",
		reqs = {
			{ req = "kill_total", amount = 500, param = "wolf_super" },
			{ req = "kill_melee", amount = 2000 },
			{ req = "kill_total", amount = 25000 }
		}
	}
	register_exp_rank {
		name = "Champion",
		reqs = {
			{ req = "kill_total", amount = 100,  param = "wolf_bossknight" },
			{ req = "kill_total", amount = 50000 }
		}
	}
	register_exp_rank {
		name = "Conqueror",
		reqs = {
			{ req = "kill_total", amount = 50,  param = "wolf_bossangel" },
		}
	}
	register_exp_rank {
		name = "God",
		reqs = {
			{ req = "kill_total", amount = 1000000 },
		}
	}

	register_skill_rank {
		name = "Private",
		reqs = {}
	}
	register_skill_rank {
		name = "Private First Class",
		reqs = { { req = "aquire_badges", param = 1, amount = 1 } }
	}
	register_skill_rank {
		name = "Corporal",
		reqs = {
			{ req = "aquire_badges", param = 1, amount = 3 }
		}
	}
	register_skill_rank {
		name = "Sergeant",
		reqs = {
			{ req = "aquire_badges", param = 1, amount = 6 }
		}
	}
	register_skill_rank {
		name = "Staff Sergeant",
		reqs = {
			{ req = "aquire_badges", param = 1, amount = 9 },
			{ req = "aquire_badges", param = 2, amount = 1 }
		}
	}
	register_skill_rank {
		name = "First Sergeant",
		reqs = {
			{ req = "aquire_badges", param = 1, amount = 12 },
			{ req = "aquire_badges", param = 2, amount = 3 },
		}
	}
	register_skill_rank {
		name = "Master Sergeant",
		reqs = {
			{ req = "aquire_badges", param = 1, amount = 15 },
			{ req = "aquire_badges", param = 2, amount = 6 }
		}
	}
	register_skill_rank { --First officer rank
		name = "Second Lieutenant",
		reqs = {
			{ req = "aquire_badges", param = 2, amount = 9 },
			{ req = "aquire_badges", param = 3, amount = 1 }
		}
	}
	register_skill_rank { --all1
		name = "First Lieutenant",
		reqs = {
			{ req = "aquire_badges", param = 1, amount = 99 },
			{ req = "aquire_badges", param = 2, amount = 13 },
			{ req = "aquire_badges", param = 3, amount = 4 }
		}
	}
	register_skill_rank {
		name = "Captain",
		reqs = {
			{ req = "aquire_badges", param = 3, amount = 9 },
			{ req = "aquire_badges", param = 4, amount = 1 }
		}
	}
	register_skill_rank {
		name = "Major",
		reqs = {
			{ req = "aquire_badges", param = 3, amount = 13 },
			{ req = "aquire_badges", param = 4, amount = 3 }
		}
	}
	register_skill_rank { --all 2
		name = "Lieutenant Colonel",
		reqs = {
			{ req = "aquire_badges", param = 2, amount = 99 },
			{ req = "aquire_badges", param = 4, amount = 6 },
			{ req = "aquire_badges", param = 5, amount = 1 }
		}
	}
	register_skill_rank {
		name = "Colonel",
		reqs = {
			{ req = "aquire_badges", param = 4, amount = 9 },
			{ req = "aquire_badges", param = 5, amount = 3 }
		}
	}
	register_skill_rank { --all 3
		name = "Brigadier General",
		reqs = {
			{ req = "aquire_badges", param = 3, amount = 99 },
			{ req = "aquire_badges", param = 4, amount = 13 },
			{ req = "aquire_badges", param = 5, amount = 7 }
		}
	}
	register_skill_rank { --all 4
		name = "Major General",
		reqs = {
			{ req = "aquire_badges", param = 4, amount = 99 },
			{ req = "aquire_badges", param = 5, amount = 11 },
			{ req = "aquire_badges", param = 6, amount = 1 }
		}
	}
	register_skill_rank { --all 5
		name = "Lieutenant General",
		reqs = {
			{ req = "aquire_badges", param = 5, amount = 99 },
			{ req = "aquire_badges", param = 6, amount = 3 }
		}
	}
	register_skill_rank { --all 6
		name = "General",
		reqs = {
			{ req = "aquire_badges", param = 6, amount = 99 }
		}
	}

end