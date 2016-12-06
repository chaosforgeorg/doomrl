function DoomRL.loadnpcs()

	--Standard enemies
	register_being "wolf_guard1" { --Roughly equivalent to a former human
		name         = "guard",
		ascii        = "h",
		color        = BROWN,
		sprite       = SPRITE_WOLF_GUARD1,
		hp           = 10,
		armor        = 0,
		speed        = 90,
		todam        = -1,
		tohit        = -4,
		min_lev      = 0,
		max_lev      = 15,
		corpse       = true,
		danger       = 1,
		weight       = 20,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc            = "A guard. Poorly trained and poorly equipped, guards are only a threat in large numbers.",
		kill_desc       = "killed by a guard",
		kill_desc_melee = "beaten by a guard",

		OnCreate = function (self)

			--Tinker with health and accuracy slightly
			local weapon = "wolf_pistol1"
			local ammo   = "wolf_9mm"
			local armor  = nil

			if(level.danger_level > 5) then
				if(level.danger_level > 12) then
					if(math.random(10) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 2 end
					if(math.random(15) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 2 end
				end
				if(math.random(10)  == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 2 end
				if(math.random(20)  == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 2 end
				if(math.random(100) == 1) then weapon = "wolf_pistol2"                                        self.expvalue = self.expvalue + 2 end
				if(math.random(75)  == 1) then armor = "wolf_armor1"                                          self.expvalue = self.expvalue + 2 end
			end

			--Weaker guard (must have stubbed a toe)
			if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 2 end

			--Generate weapon
			if(weapon) then self.eq.weapon = item.new(weapon) end
			if(armor)  then self.eq.armor  = item.new(armor)  end
			if(ammo)   then self.inv:add(item.new(ammo))      end
		end,
		OnDie = function (self)
			--This lets us randomly choose a death cry.
			local s = self.id .. ".die" .. math.random(7)
			self:play_sound( { s } )
		end,
	}
	register_being "wolf_guard2" { --A little bit faster but even less accurate.
		name         = "submarine guard",
		ascii        = "h",
		color        = GREEN,
		sprite       = SPRITE_WOLF_GUARD2,
		hp           = 10,
		armor        = 0,
		speed        = 110,
		todam        = -1,
		tohit        = -5,
		min_lev      = 0,
		max_lev      = 15,
		corpse       = true,
		danger       = 1,
		weight       = 0,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc            = "One of Submarine Willie's off kilter troops. A bit off but no more dangerous than a regular guard.",
		kill_desc       = "killed by Willie's guard",
		kill_desc_melee = "beaten by Willie's guard",

		OnCreate = function (self)

			--Tinker with health and accuracy slightly
			local weapon = "wolf_pistol1"
			local ammo   = "wolf_9mm"
			local armor  = nil

			if(level.danger_level > 5) then
				if(level.danger_level > 12) then
					if(math.random(10) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 2 end
					if(math.random(15) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 2 end
				end
				if(math.random(10)  == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 2 end
				if(math.random(20)  == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 2 end
				if(math.random(100) == 1) then weapon = "wolf_pistol2"                                        self.expvalue = self.expvalue + 2 end
				if(math.random(75)  == 1) then armor = "wolf_armor1"                                          self.expvalue = self.expvalue + 2 end
			end

			--Weaker guard (must have stubbed a toe)
			if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 2 end

			--Generate weapon
			if(weapon) then self.eq.weapon = item.new(weapon) end
			if(armor)  then self.eq.armor  = item.new(armor)  end
			if(ammo)   then self.inv:add(item.new(ammo))      end
		end,
		OnDie = function (self)
			--This lets us randomly choose a death cry.
			local s = self.id .. ".die" .. math.random(7)
			self:play_sound( { s } )
		end,
	}

	register_being "wolf_ss1" { --Roughly equivalent to a former captain although the weapons are quite different
		name         = "schutzstaffel",
		ascii        = "h",
		color        = LIGHTBLUE,
		sprite       = SPRITE_WOLF_SS1,
		hp           = 10,
		armor        = 1,
		speed        = 70,
		todam        = -1,
		tohit        = -2,
		min_lev      = 5,
		max_lev      = 16,
		corpse       = true,
		danger       = 3,
		weight       = 10,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc            = "SS troops have MP-40s and poor dispositions. Take them out and, hey, free automatic.",
		kill_desc       = "killed by an SS nazi",
		kill_desc_melee = "beaten by an SS nazi",

		OnCreate = function (self)

			--Tinker
			local armor = 0

			if(level.danger_level > 5) then
				if(level.danger_level > 14) then
					if(math.random(10) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 4 end
					if(math.random(15) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 4 end
					if(math.random(20) == 1) then armor = armor + 1                                              self.expvalue = self.expvalue + 4 end
				end
				if(math.random(15) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 4 end
				if(math.random(20) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 4 end
				if(math.random(30) == 1) then armor = armor + 1                                              self.expvalue = self.expvalue + 4 end
			end

			if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 4 end

			self.eq.weapon = item.new("wolf_sub1")
			if(armor > 0) then self.eq.armor  = item.new("wolf_armor" .. armor) end
			self.inv:add(item.new("wolf_9mm", { ammo = 32 }))
		end,
	}
	register_being "wolf_ss2"{ --A tougher ss, faster and much more likely to have armor.  Rarer because I don't like TLL enemies as much.
		name         = "schutzstaffel leader",
		ascii        = "h",
		color        = LIGHTGRAY,
		sprite       = SPRITE_WOLF_SS2,
		hp           = 10,
		armor        = 1,
		speed        = 90,
		todam        = -1,
		tohit        = -1,
		min_lev      = 6,
		max_lev      = 16,
		corpse       = true,
		danger       = 4,
		weight       = 2,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc            = "SS troops have MP-40s and poor dispositions. SS leaders tend to be better armored too.",
		kill_desc       = "killed by an SS section leader",
		kill_desc_melee = "beaten by an SS section leader",

		OnCreate = function (self)

			--Tinker
			local armor = 0

			if(level.danger_level > 5) then
				if(level.danger_level > 14) then
					if(math.random(10) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 4 end
					if(math.random(15) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 4 end
					if(math.random(5)  == 1) then armor = armor + 1                                              self.expvalue = self.expvalue + 4 end
				end
				if(math.random(15) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 4 end
				if(math.random(20) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 4 end
				if(math.random(5)  == 1) then armor = armor + 1                                              self.expvalue = self.expvalue + 4 end
			end

			if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 4 end

			self.eq.weapon = item.new("wolf_sub1")
			if(armor > 0) then self.eq.armor  = item.new("wolf_armor" .. armor) end
			self.inv:add("wolf_9mm", { ammo = 32 })
		end,
	}

	register_being "wolf_officer1" { --Officers are fast and accurate but still only have pistols.  Officers with armor are common but it is never anything but light armor.
		name         = "officer",
		ascii        = "h",
		color        = WHITE,
		sprite       = SPRITE_WOLF_OFFICER1,
		hp           = 15,
		armor        = 1,
		speed        = 130,
		todam        = 1,
		tohit        = -1,
		min_lev      = 7,
		max_lev      = 20,
		corpse       = true,
		danger       = 4,
		weight       = 10,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc            = "Officers are better equipped than guards but their real strength lies in their training. Hit them hard before they hit you.",
		kill_desc       = "killed by an officer",
		kill_desc_melee = "beaten by an officer",

		OnCreate = function (self)

			--Tinker
			local armor = 0

			if(level.danger_level > 5) then
				if(level.danger_level > 16) then
					if(math.random(10) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 4 end
					if(math.random(15) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 4 end
					if(math.random(4) == 1)  then armor = 1                                                      self.expvalue = self.expvalue + 4 end
				end
				if(math.random(15) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 4 end
				if(math.random(20) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 4 end
				if(math.random(4) == 1)  then armor = 1                                                      self.expvalue = self.expvalue + 4 end
			end

			if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 4 end

			self.eq.weapon = item.new("wolf_pistol3")
			if(armor > 0) then self.eq.armor  = item.new("wolf_armor1") end
			self.inv:add(item.new("wolf_9mm"))
		end,
	}
	register_being "wolf_officer2" { --An alternate officer.  More accurate, more cowardly.
		name         = "commander",
		ascii        = "h",
		color        = WHITE,
		sprite       = SPRITE_WOLF_OFFICER2,
		hp           = 15,
		armor        = 1,
		speed        = 130,
		todam        = 1,
		tohit        = 0,
		min_lev      = 7,
		max_lev      = 20,
		corpse       = true,
		danger       = 4,
		weight       = 2,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "flee_former_ai",

		desc            = "Officers are better equipped than guards but their real strength lies in their training. Of course not all officers excel in direct combat.",
		kill_desc       = "killed by a commander",
		kill_desc_melee = "beaten by a commander",

		OnCreate = function (self)

			--Tinker
			local armor = 0

			if(level.danger_level > 5) then
				if(level.danger_level > 16) then
					if(math.random(10) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 4 end
					if(math.random(15) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 4 end
					if(math.random(4) == 1)  then armor = 1                                                      self.expvalue = self.expvalue + 4 end
				end
				if(math.random(15) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 4 end
				if(math.random(20) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 4 end
				if(math.random(4) == 1)  then armor = 1                                                      self.expvalue = self.expvalue + 4 end
			end

			if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 4 end

			self.eq.weapon = item.new("wolf_pistol3")
			if(armor > 0) then self.eq.armor  = item.new("wolf_armor1") end
			self.inv:add(item.new("wolf_9mm"))
		end,
	}

	register_being "wolf_dog1" { --Dogs should die in one hit but I cannot figure out a way to do that short of reducing HP to instagib levels.
		name         = "dog",
		ascii        = "d",
		color        = BROWN,
		sprite       = SPRITE_WOLF_DOG1,
		hp           = 5,
		armor        = 0,
		todam        = 4,
		tohit        = 2,
		speed        = 150,
		vision       = 1,
		min_lev      = 0,
		max_lev      = 10,
		corpse       = true,
		danger       = 1,
		weight       = 5,
		bulk         = 100,
		flags        = { BF_CHARGE },
		ai_type      = "melee_seek_ai",

		desc            = "A German Shepherd. It's either him or you; you'll have to put it down.",
		kill_desc_melee = "chewed on by a German Shepherd",

		OnCreate = function (self)

			--Tinker

			if(level.danger_level > 5) then
				if(level.danger_level > 15) then
					if(math.random(10) == 1) then self.speed = self.speed + 10 self.expvalue = self.expvalue + 1 end
					if(math.random(15) == 1) then self.todam = self.todam + 1  self.expvalue = self.expvalue + 1 end
				end
				if(math.random(10) == 1) then self.speed = self.speed + 10 self.expvalue = self.expvalue + 1 end
				if(math.random(15) == 1) then self.todam = self.todam + 1  self.expvalue = self.expvalue + 1 end
			end

			if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) end
		end,
	}
	register_being "wolf_dog2" { --Dobermans die normally.  I'd like to make these guys one shotters that are very dodge heavy but that is not possible outside of messing with speed.
		name         = "dog",
		ascii        = "d",
		color        = DARKGRAY,
		sprite       = SPRITE_WOLF_DOG2,
		hp           = 6,
		armor        = 0,
		todam        = 5,
		tohit        = 3,
		speed        = 170,
		vision       = 1,
		min_lev      = 0,
		max_lev      = 10,
		corpse       = true,
		danger       = 2,
		weight       = 2,
		bulk         = 100,
		flags        = { BF_CHARGE },
		ai_type      = "melee_seek_ai",

		desc            = "A Doberman. Hesitate and it will be on you before you know what happened.",
		kill_desc_melee = "chewed on by a Doberman",

		OnCreate = function (self)

			--Tinker

			if(level.danger_level > 5) then
				if(level.danger_level > 15) then
					if(math.random(10) == 1) then self.speed = self.speed + 10 self.expvalue = self.expvalue + 1 end
					if(math.random(15) == 1) then self.todam = self.todam + 1  self.expvalue = self.expvalue + 1 end
				end
				if(math.random(10) == 1) then self.speed = self.speed + 10 self.expvalue = self.expvalue + 1 end
				if(math.random(15) == 1) then self.todam = self.todam + 1  self.expvalue = self.expvalue + 1 end
			end

			if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 1 end
		end,
	}

	register_being "wolf_mutant1" { --Zombies and mutants are two sides of the same enemy.  Zombies are faster and tougher.  USUALLY zombies are unarmed.  Oh, and bats are stupid.  No way.
		name         = "zombie",
		ascii        = "Z",
		color        = GREEN,
		sprite       = SPRITE_WOLF_MUTANT1,
		hp           = 30,
		armor        = 0,
		todam        = 4,
		tohit        = -2,
		tohitmelee   = 5,
		speed        = 100,
		vision       = -1,
		min_lev      = 4,
		max_lev      = 20,
		corpse       = true,
		danger       = 3,
		weight       = 10,
		bulk         = 100,
		ai_type      = "melee_ranged_ai",

		desc            = "These horrible zombies are courtesy of Dr. Schabbs. They are tough and ugly, but they still bleed",
		kill_desc       = "killed by a zombie",
		kill_desc_melee = "eaten by a zombie",

		OnCreate = function (self)

			--Tinker

			if(level.danger_level > 5) then
				if(level.danger_level > 15) then
					if(math.random(10) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 4 end
					if(math.random(15) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 4 end
				end
				if(math.random(15) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 4 end
				if(math.random(20) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 4 end
			end

			if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 4 end

			if(math.random(10) == 1) then
				self.eq.weapon = item.new("wolf_pistol1")
				self.inv:add(item.new("wolf_9mm"))
				self.eq.weapon.flags[IF_NODROP] = true
			end
		end,
	}
	register_being "wolf_mutant2" { --Zombies and mutants are two sides of the same enemy.  Mutants are slower and weaker.  USUALLY mutants are armed.
		name         = "mutant",
		ascii        = "Z",
		color        = MAGENTA,
		sprite       = SPRITE_WOLF_MUTANT2,
		hp           = 25,
		armor        = 0,
		todam        = 2,
		tohit        = -1,
		tohitmelee   = 4,
		speed        = 80,
		vision       = -1,
		min_lev      = 4,
		max_lev      = 20,
		corpse       = true,
		danger       = 3,
		weight       = 10,
		bulk         = 100,
		ai_type      = "melee_ranged_ai",

		desc            = "These horrible mutants are courtesy of Dr. Schabbs. Armed with chest mounted weapons these things will give you some extra holes if you're not careful.",
		kill_desc       = "killed by a mutant",
		kill_desc_melee = "eaten by a mutant",

		OnCreate = function (self)

			--Tinker

			if(level.danger_level > 5) then
				if(level.danger_level > 15) then
					if(math.random(10) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 4 end
					if(math.random(15) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 4 end
				end
				if(math.random(15) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 4 end
				if(math.random(20) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 4 end
			end

			if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 4 end

			if(math.random(10) ~= 1) then
				self.eq.weapon = item.new("wolf_pistol1")
				self.inv:add(item.new("wolf_9mm"))
				self.eq.weapon.flags[IF_NODROP] = true
			end
		end,
	}

	register_being "wolf_fakehitler" { --Fake Hitler is normally constrained to ep3, but he's too fun to leave there (plus he is one of very few enemies we can give a natural wall destroying attack)
		name         = "Hitler's Ghost",
		ascii        = "@",
		color        = DARKGRAY,
		sprite       = SPRITE_WOLF_FAKEHITLER,
		hp           = 40,
		armor        = 1,
		todam        = 2,
		tohit        = 3,
		min_lev      = 12,
		max_lev      = 50,
		corpse       = false,
		danger       = 7,
		weight       = 5,
		flags        = { BF_OPENDOORS, BF_ENVIROSAFE, BF_UNIQUENAME },
		bulk         = 100,
		ai_type      = "ranged_ai",

		resist = { melee = 20, acid = 20, fire = 50 },

		desc            = "It's Hitler! Well maybe not. You must be getting close though for something like THIS to come after you.",
		kill_desc       = "killed by Hitler's Ghost",
		kill_desc_melee = "spooked by Hitler's Ghost",

		weapon = {
			damage     = "3d5",
			damagetype = DAMAGE_FIRE,
			radius     = 1,
			missile = {
				sound_id   = "wolf_fakehitler",
				ascii      = "*",
				color      = LIGHTRED,
				sprite     = SPRITE_PLASMABALL,
				delay      = 30,
				miss_base  = 50,
				miss_dist  = 5,
				expl_delay = 40,
				expl_color = RED,
			},
		},
	}

	register_being "wolf_soldier1" { --Marksmen have Kars
		name         = "marksman",
		ascii        = "R",
		color        = BROWN,
		sprite       = SPRITE_WOLF_SOLDIER1,
		hp           = 25,
		armor        = 1,
		speed        = 120,
		todam        = 2,
		tohit        = 0,
		tohitmelee   = 2,
		min_lev      = 10,
		max_lev      = 25,
		corpse       = true,
		danger       = 7,
		weight       = 6,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc            = "Riflemen are the bread and butter of any army, and these marksmen are no exception. Wielding bolt action Karabiners they can put a very large hole in you if you stand still too long.",
		kill_desc       = "killed by a marksman",
		kill_desc_melee = "beaten by a marksman",

		OnCreate = function (self)

			--Tinker
			local armor = 0

			if(level.danger_level > 5) then
				if(level.danger_level > 16) then
					if(math.random(10) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 6 end
					if(math.random(15) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 6 end
					if(math.random(75) == 1) then armor = 1                                                      self.expvalue = self.expvalue + 6 end
				end
				if(math.random(15) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 6 end
				if(math.random(20) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 6 end
				if(math.random(75) == 1) then armor = 1                                                      self.expvalue = self.expvalue + 6 end
			end

			if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 6 end

			self.eq.weapon = item.new("wolf_bolt1")
			if(armor > 0) then self.eq.armor  = item.new("wolf_armor" .. armor) end
			self.inv:add(item.new("wolf_8mm"))
		end,
	}
	register_being "wolf_soldier2" { --Riflemen have Gewehrs
		name         = "rifleman",
		ascii        = "R",
		color        = GREEN,
		sprite       = SPRITE_WOLF_SOLDIER2,
		hp           = 30,
		armor        = 1,
		speed        = 120,
		todam        = 2,
		tohit        = 0,
		tohitmelee   = 2,
		min_lev      = 13,
		max_lev      = 28,
		corpse       = true,
		danger       = 8,
		weight       = 6,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc            = "Rifleman aren't stuck with just the standard bolt acton rifle. Some are issued the Gewehr 43, the Axis answer to the M1.",
		kill_desc       = "killed by a rifleman",
		kill_desc_melee = "beaten by a rifleman",

		OnCreate = function (self)

			--Tinker
			local armor = 0

			if(level.danger_level > 5) then
				if(level.danger_level > 16) then
					if(math.random(10) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 6 end
					if(math.random(15) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 6 end
					if(math.random(75) == 1) then armor = 1                                                      self.expvalue = self.expvalue + 6 end
				end
				if(math.random(15) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 6 end
				if(math.random(20) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 6 end
				if(math.random(75) == 1) then armor = 1                                                      self.expvalue = self.expvalue + 6 end
			end

			if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 6 end

			self.eq.weapon = item.new("wolf_semi1")
			if(armor > 0) then self.eq.armor  = item.new("wolf_armor" .. armor) end
			self.inv:add("wolf_8mm", { ammo = 24 })
		end,
	}
	register_being "wolf_soldier3" { --and Paratroopers have FG42s
		name         = "paratrooper",
		ascii        = "R",
		color        = RED,
		sprite       = SPRITE_WOLF_SOLDIER3,
		hp           = 35,
		armor        = 1,
		speed        = 120,
		todam        = 2,
		tohit        = 0,
		tohitmelee   = 2,
		min_lev      = 16,
		max_lev      = 31,
		corpse       = true,
		danger       = 9,
		weight       = 6,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc            = "The airborne infantry is fast and effective. They will ventilate you with their specialized FG42s if you are not careful.",
		kill_desc       = "killed by a paratrooper",
		kill_desc_melee = "beaten by a paratrooper",

		OnCreate = function (self)

			--Tinker
			local armor = 0

			if(level.danger_level > 5) then
				if(level.danger_level > 16) then
					if(math.random(10) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 6 end
					if(math.random(15) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 6 end
					if(math.random(75) == 1) then armor = 1                                                      self.expvalue = self.expvalue + 6 end
				end
				if(math.random(15) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 6 end
				if(math.random(20) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 6 end
				if(math.random(75) == 1) then armor = 1                                                      self.expvalue = self.expvalue + 6 end
			end

			if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 6 end

			self.eq.weapon = item.new("wolf_auto1")
			if(armor > 0) then self.eq.armor  = item.new("wolf_armor" .. armor) end
			self.inv:add("wolf_8mm", { ammo = 20 })
			self.inv:add("wolf_8mm", { ammo = 20 })
		end,
	}

	register_being "wolf_trooper1" { --Flame troopers have flamethrowers
		name         = "flame trooper",
		ascii        = "V",
		color        = LIGHTRED,
		sprite       = SPRITE_WOLF_TROOPER1,
		hp           = 40,
		armor        = 1,
		speed        = 110,
		todam        = 3,
		tohit        = 0,
		tohitmelee   = 3,
		min_lev      = 20,
		corpse       = true,
		danger       = 8,
		weight       = 6,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		resist = { melee = 10, fire = 50 },

		desc            = "Your average Flame Trooper would like nothing more than to turn you into a crispy critter. Sadly they take precautions against extreme heat so you can't turn the tables as easily.",
		kill_desc       = "killed by a flame trooper",
		kill_desc_melee = "beaten by a flame trooper",

		OnCreate = function (self)

			--Tinker
			local armor = 0

			if(level.danger_level > 5) then
				if(level.danger_level > 16) then
					if(math.random(10) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 6 end
					if(math.random(15) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 6 end
					if(math.random(75) == 1) then armor = 1                                                      self.expvalue = self.expvalue + 6 end
				end
				if(math.random(15) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 6 end
				if(math.random(20) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 6 end
				if(math.random(75) == 1) then armor = 1                                                      self.expvalue = self.expvalue + 6 end
			end

			if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 6 end

			self.eq.weapon = item.new("wolf_flamethrower")
			if(armor > 0) then self.eq.armor  = item.new("wolf_armor" .. armor) end
			self.inv:add(item.new("wolf_fuel"))
		end,
	}
	register_being "wolf_trooper2" { --Assault troopers have STGs
		name         = "assault trooper",
		ascii        = "V",
		color        = LIGHTCYAN,
		sprite       = SPRITE_WOLF_TROOPER2,
		hp           = 45,
		armor        = 1,
		speed        = 130,
		todam        = 3,
		tohit        = 0,
		tohitmelee   = 3,
		min_lev      = 20,
		corpse       = true,
		danger       = 9,
		weight       = 6,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		resist = { melee = 20 },

		desc            = "Watch out! Shock troopers are fast and agile and they excel on the rapidly changing battlefield.",
		kill_desc       = "killed by an assault trooper",
		kill_desc_melee = "beaten by an assault trooper",

		OnCreate = function (self)

			--Tinker
			local armor = 0

			if(level.danger_level > 5) then
				if(level.danger_level > 16) then
					if(math.random(10) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 6 end
					if(math.random(15) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 6 end
					if(math.random(75) == 1) then armor = 1                                                      self.expvalue = self.expvalue + 6 end
				end
				if(math.random(15) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 6 end
				if(math.random(20) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 6 end
				if(math.random(75) == 1) then armor = 1                                                      self.expvalue = self.expvalue + 6 end
			end

			if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 6 end

			self.eq.weapon = item.new("wolf_assault1")
			if(armor > 0) then self.eq.armor  = item.new("wolf_armor" .. armor) end
			self.inv:add("wolf_kurz", { ammo = 30 })
		end,
	}
	register_being "wolf_trooper3" { --and Heavy troopers have chainguns (may change to something else)
		name         = "chain trooper",
		ascii        = "V",
		color        = DARKGRAY,
		sprite       = SPRITE_WOLF_TROOPER3,
		hp           = 50,
		armor        = 1,
		speed        = 110,
		todam        = 3,
		tohit        = 0,
		tohitmelee   = 3,
		min_lev      = 20,
		corpse       = true,
		danger       = 10,
		weight       = 6,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "melee_ranged_ai",

		resist = { melee = 20 },

		desc            = "Chain troopers carry the big guns. Best to reply in kind.",
		kill_desc       = "killed by a chain trooper",
		kill_desc_melee = "beaten by a chain trooper",

		OnCreate = function (self)

			--Tinker
			local armor = 0

			if(level.danger_level > 5) then
				if(level.danger_level > 16) then
					if(math.random(10) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 6 end
					if(math.random(15) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 6 end
					if(math.random(75) == 1) then armor = 1                                                      self.expvalue = self.expvalue + 6 end
				end
				if(math.random(15) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 6 end
				if(math.random(20) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 6 end
				if(math.random(75) == 1) then armor = 1                                                      self.expvalue = self.expvalue + 6 end
			end

			if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 6 end

			self.eq.weapon = item.new("wolf_assault2")
			self.eq.weapon.shots = self.eq.weapon.shots - 1
			self.eq.weapon.acc = self.eq.weapon.acc + 1
			self.eq.weapon.usetime = 10
			self.eq.weapon.ammo = 40
			self.eq.weapon.ammomax = 40
			if(armor > 0) then self.eq.armor  = item.new("wolf_armor" .. armor) end
			self.inv:add("wolf_kurz", { ammo = 40 })
		end,
		OnDieCheck = function (self, overkill)
			--re-adjust weapon properties
			local weapon = self.eq.weapon

			weapon.shots = items[ weapon.id ].shots
			weapon.acc = items[ weapon.id ].acc
			weapon.usetime = items[ weapon.id ].fire
			weapon.ammo = math.ceil(weapon.ammo * items[ weapon.id ].ammomax / weapon.ammomax)
			weapon.ammomax = items[ weapon.id ].ammomax

			return true
		end,

	}

	register_being "wolf_super" { --Super soldiers have rocket launchers and lots of armor
		name         = "super soldier",
		ascii        = "H",
		color        = BROWN,
		sprite       = SPRITE_WOLF_SUPER,
		hp           = 60,
		armor        = 3,
		attackchance = 50,
		speed        = 80,
		todam        = 8,
		tohit        = 3,
		min_lev      = 20,
		corpse       = true,
		danger       = 12,
		weight       = 2,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "ranged_ai",

		resist = { fire = 50 },

		desc            = "Super soldiers are decked in armor and can stomp you flat. Dodge their rockets if you want to live to see another day.",
		kill_desc       = "killed by a super soldier",
		kill_desc_melee = "crushed by a super soldier",

		OnCreate = function (self)

			--Tinker
			local armor = 0

			if(level.danger_level > 5) then
				if(level.danger_level > 16) then
					if(math.random(10) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 6 end
					if(math.random(15) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 6 end
					if(math.random(75) == 1) then armor = 1                                                      self.expvalue = self.expvalue + 6 end
				end
				if(math.random(15) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 6 end
				if(math.random(20) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 6 end
			end

			if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 6 end

			self.eq.weapon = item.new("wolf_bazooka")
			if(armor > 0) then
				self.armor = 0
				self.eq.armor  = item.new("wolf_armor3")
			end
			self.inv:add("wolf_rocket", { ammo = 5 })
		end,
	}


	--Nightmare enemies (min_lev must be 35 to prevent appearance in main campaign)
	register_being "wolf_nguard1" {
		name         = "nightmare guard",
		sound_id     = "wolf_guard1",
		ascii        = "h",
		color        = BROWN + (RED * 16),
		sprite       = SPRITE_WOLF_GUARD1,
		coscolor     = { 1.0, 0.2, 0.0, 1.0 },
		--overlay      = { 0.8, 0.2, 0.0, 1.0 },
		glow         = { 1.0, 0.1, 0.1, 1.0 },
		hp           = 30,
		armor        = 1,
		speed        = 115,
		todam        = 1,
		tohit        = 0,
		min_lev      = 35,
		max_lev      = 60,
		corpse       = true,
		danger       = 6,
		weight       = 100,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		resist = { fire = 50 },

		desc            = "War takes both good men and bad men. Judging by the crimson aura, this was not one of the good men.",
		kill_desc       = "killed by a nightmare guard",
		kill_desc_melee = "beaten by a nightmare guard",

		OnCreate = function (self)

			--Hellion bonus
			self.todamall = self.todamall + 1

			--Tinker with health and accuracy slightly
			local weapon = "wolf_pistol1"
			local ammo   = "wolf_9mm"
			local armor  = nil

			if(level.danger_level > 5) then
				if(level.danger_level > 12) then
					if(math.random(10) == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 2 end
					if(math.random(15) == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 2 end
				end
				if(math.random(10)  == 1) then self.tohit = self.tohit + 1                                    self.expvalue = self.expvalue + 2 end
				if(math.random(20)  == 1) then self.hpmax = math.floor(self.hpmax * 1.2) self.hp = self.hpmax self.expvalue = self.expvalue + 2 end
				if(math.random(100) == 1) then weapon = "wolf_pistol2"                                        self.expvalue = self.expvalue + 2 end
				if(math.random(75)  == 1) then armor = "wolf_armor1"                                          self.expvalue = self.expvalue + 2 end
			end

			--Weaker guard (must have stubbed a toe)
			if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) self.expvalue = self.expvalue - 2 end

			--Generate weapon
			if(weapon) then self.eq.weapon = item.new(weapon) end
			if(armor)  then self.eq.armor  = item.new(armor)  end
			if(ammo)   then self.inv:add(item.new(ammo))      end
		end,
		OnDie = function (self)
			--This lets us randomly choose a death cry.
			local s = self.__proto.sound_id .. ".die" .. math.random(7)
			self:play_sound( { s } )
		end,
	}


	--Special enemies (exclusive to special levels obviously)
	register_being "wolf_rat" { --Meant to be annoying and hard to hit
		name         = "rat",
		ascii        = "r",
		color        = BROWN,
		sprite       = SPRITE_WOLF_RAT,
		hp           = 5,
		armor        = 0,
		todam        = 2,
		tohit        = 2,
		speed        = 140,
		vision       = 1,
		min_lev      = 0,
		max_lev      = 10,
		corpse       = true,
		danger       = 2,
		weight       = 0,
		bulk         = 100,
		flags        = { BF_CHARGE },
		ai_type      = "melee_seek_ai",

		desc            = "Looks like some rats escaped from the lab. That's okay. They don't look too tough.",
		kill_desc_melee = "gnawed on by a Mutant Rat",

		OnCreate = function (self)

			--Tinker
			self.dodgebonus = self.dodgebonus + 100
			if(level.danger_level > 5) then
				if(level.danger_level > 15) then
					if(math.random(10) == 1) then self.speed = self.speed + 10 self.expvalue = self.expvalue + 1 end
					if(math.random(15) == 1) then self.todam = self.todam + 1  self.expvalue = self.expvalue + 1 end
				end
				if(math.random(10) == 1) then self.speed = self.speed + 10 self.expvalue = self.expvalue + 1 end
				if(math.random(15) == 1) then self.todam = self.todam + 1  self.expvalue = self.expvalue + 1 end
			end

			if(math.random(30) == 1) then self.hp = math.floor(self.hpmax * math.random(70,90) / 100) end
		end,

		OnAttacked = function( self, source )
			if (source ~= nil and source:is_player() and self:distance_to( source ) <= 1 and math.random(3) == 1) then
				--Change Places!
				self:msg("",self:get_name(false,false) .. " slips around you.")
				local tmp = self.position
				self:displace(source.position)
				source:displace(tmp)
			end
		end,
	}
	register_being "wolf_spirit" {
		name         = "spirit",
		ascii        = "°",
		--asciilow     = "#",
		color        = WHITE,
		sprite       = SPRITE_WOLF_SPIRIT,
		coscolor     = { 0.8, 0.8, 0.8, 1.0 },
		hp           = 1,
		armor        = 0,
		todam        = 1,
		tohit        = 3,
		speed        = 250,
		vision       = -2,
		min_lev      = 200,
		corpse       = false,
		danger       = 1,
		weight       = 0,
		bulk         = 100,
		flags        = { BF_CHARGE },
		ai_type      = "melee_seek_ai",

		desc            = "A restless spirit, spiteful and envious of life. You can't kill what's already dead but you can probably scare them off for a bit.",
		kill_desc_melee = "haunted by a spirit",
	}
	register_being "pac_blinky" {
		name         = "Blinky",
		ascii        = "B",
		color        = LIGHTRED,
		sprite       = SPRITE_WOLF_PACGHOST,
		coscolor     = { 1.0, 0.0, 0.0, 1.0 },
		hp           = 9000,
		armor        = 100,
		todam        = 10,
		tohitmelee   = 10,
		speed        = 90,
		min_lev      = 200,
		corpse       = false,
		danger       = 10,
		weight       = 0,
		xp           = 0,
		bulk         = 100,
		flags        = { BF_UNIQUENAME },
		ai_type      = "pac_blinky_ai",

		desc            = "Shadow",
		kill_desc_melee = "chased down by Blinky",
	}
	register_being "pac_pinky" {
		name         = "Pinky",
		ascii        = "P",
		color        = LIGHTMAGENTA,
		sprite       = SPRITE_WOLF_PACGHOST,
		coscolor     = { 1.0, 0.7, 0.85, 1.0 },
		hp           = 9000,
		armor        = 100,
		todam        = 10,
		tohitmelee   = 10,
		speed        = 100,
		min_lev      = 200,
		corpse       = false,
		danger       = 10,
		weight       = 0,
		xp           = 0,
		bulk         = 100,
		flags        = { BF_UNIQUENAME },
		ai_type      = "pac_pinky_ai",

		desc            = "Speedy",
		kill_desc_melee = "ambushed by Pinky",
	}
	register_being "pac_inky" {
		name         = "Inky",
		ascii        = "I",
		color        = LIGHTCYAN,
		sprite       = SPRITE_WOLF_PACGHOST,
		coscolor     = { 0.0, 1.0, 1.0, 1.0 },
		hp           = 9000,
		armor        = 100,
		todam        = 10,
		tohitmelee   = 10,
		speed        = 90,
		min_lev      = 200,
		corpse       = false,
		danger       = 10,
		weight       = 0,
		xp           = 0,
		bulk         = 100,
		flags        = { BF_UNIQUENAME },
		ai_type      = "pac_inky_ai",

		desc            = "Bashful",
		kill_desc_melee = "hounded by Inky",
	}
	register_being "pac_clyde" {
		name         = "Clyde",
		ascii        = "C",
		color        = BROWN,
		sprite       = SPRITE_WOLF_PACGHOST,
		coscolor     = { 1.0, 0.7, 0.25, 1.0 },
		hp           = 9000,
		armor        = 100,
		todam        = 10,
		tohitmelee   = 10,
		speed        = 80,
		min_lev      = 200,
		corpse       = false,
		danger       = 10,
		weight       = 0,
		xp           = 0,
		bulk         = 100,
		flags        = { BF_UNIQUENAME },
		ai_type      = "pac_clyde_ai",

		desc            = "Pokey",
		kill_desc_melee = "surprised by Clyde",
	}

	register_being "blake_informant" {
		name         = "technician",
		ascii        = "h",
		color        = WHITE,
		sprite       = SPRITE_WOLF_GUARD2,
		hp           = 5,
		armor        = 0,
		speed        = 100,
		todam        = -1,
		tohit        = -4,
		min_lev      = 200,
		corpse       = true,
		danger       = 0,
		weight       = 0,
		xp           = 0,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc            = "A bio-tech. Some of these guys are here against their will; don't shoot them and they may reward you.",
		kill_desc       = "killed by a bio-tech",
		kill_desc_melee = "beaten by a bio-tech",

		OnCreate = function (self)
			self.inv:add("wolf_cell", { ammo = (math.random(6) * 6) })
		end,
		OnDie = function (self)
			--This lets us randomly choose a death cry.
			local s = self.id .. ".die" .. math.random(3)
			self:play_sound( { s } )
		end,
	}
	register_being "blake_tech" {
		name         = "technician",
		ascii        = "h",
		color        = WHITE,
		sprite       = SPRITE_WOLF_GUARD2,
		hp           = 10,
		armor        = 0,
		speed        = 100,
		todam        = -1,
		tohit        = -4,
		min_lev      = 200,
		corpse       = true,
		danger       = 1,
		weight       = 0,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc            = "A bio-tech. Some of these guys are here against their will; don't shoot them and they may reward you.",
		kill_desc       = "killed by a bio-tech",
		kill_desc_melee = "beaten by a bio-tech",

		OnCreate = function (self)
			self.eq.weapon = item.new("blake_pistol2")
			self.inv:add("wolf_cell", { ammo = (math.random(6) * 6) })
		end,
		OnDie = function (self)
			--This lets us randomly choose a death cry.
			local s = self.id .. ".die" .. math.random(2)
			self:play_sound( { s } )
		end,
	}
	register_being "blake_patrol" {
		name         = "guard",
		ascii        = "h",
		color        = BLUE,
		sprite       = SPRITE_WOLF_GUARD2,
		hp           = 10,
		armor        = 0,
		speed        = 100,
		todam        = 0,
		tohit        = -2,
		min_lev      = 200,
		corpse       = true,
		danger       = 1,
		weight       = 20,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc            = "Local sector patrol. Usually has a blaster, rarely has combat experience. Only dangerous in groups.",
		kill_desc       = "killed by a guard",
		kill_desc_melee = "beaten by a guard",

		OnCreate = function (self)
			self.eq.weapon = item.new("blake_pistol2")
			self.inv:add("wolf_cell", { ammo = 60 })
		end,
		OnDie = function (self)
			--This lets us randomly choose a death cry.
			local s = self.id .. ".die" .. math.random(2)
			self:play_sound( { s } )
		end,
	}
	register_being "blake_sentinel" {
		name         = "sentinel",
		ascii        = "h",
		color        = MAGENTA,
		sprite       = SPRITE_WOLF_GUARD2,
		hp           = 20,
		armor        = 0,
		speed        = 100,
		todam        = 0,
		tohit        = -1,
		min_lev      = 200,
		corpse       = true,
		danger       = 4,
		weight       = 20,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc            = "STAR sentinels are security guards with at least some decent training and automatic weapons.",
		kill_desc       = "killed by a sentinel",
		kill_desc_melee = "beaten by a sentinel",

		OnCreate = function (self)
			self.eq.weapon = item.new("blake_rifle1")
			self.inv:add("wolf_cell", { ammo = 90 })
		end,
	}
	register_being "blake_trooper" {
		name         = "trooper",
		ascii        = "h",
		color        = GREEN,
		sprite       = SPRITE_WOLF_GUARD2,
		hp           = 40,
		armor        = 1,
		speed        = 110,
		todam        = 0,
		tohit        = 0,
		min_lev      = 200,
		corpse       = true,
		danger       = 6,
		weight       = 20,
		bulk         = 100,
		flags        = { BF_OPENDOORS },
		ai_type      = "former_ai",

		desc            = "STAR troopers are by far the most experienced guards in the facility, and the only ones with good uniforms to boot.",
		kill_desc       = "killed by a trooper",
		kill_desc_melee = "beaten by a trooper",

		OnCreate = function (self)
			self.eq.weapon = item.new("blake_rifle1")
			self.inv:add("wolf_cell", { ammo = 150 })
		end,
	}

	register_being "blake_genalien" {
		name         = "genetic alien",
		ascii        = "g",
		color        = BROWN,
		sprite       = SPRITE_WOLF_FAKEHITLER,
		hp           = 15,
		armor        = 0,
		speed        = 100,
		todam        = 0,
		tohit        = -1,
		min_lev      = 200,
		corpse       = true,
		danger       = 3,
		weight       = 20,
		flags        = {},
		bulk         = 100,
		ai_type      = "melee_ranged_ai",

		resist = { acid = 20 },

		desc            = "This stocky creaturs is most likely the result of some horrible genetic experiment. It doesn't seem intelligent enough to do much more than spit acid at you.",
		kill_desc       = "killed by a genetic alien",
		kill_desc_melee = "clawed by a genetic alien",

		weapon = {
			damage     = "2d5",
			damagetype = DAMAGE_ACID,
			radius     = 0,
			missile = {
				sound_id   = "blake_genalien",
				ascii      = "*",
				color      = GREEN,
				sprite     = SPRITE_PLASMABALL,
				coscolor   = { 0.0, 0.75, 0.0, 1.0 },
				delay      = 30,
				miss_base  = 50,
				miss_dist  = 4,
				expl_delay = 40,
				expl_color = GREEN,
			},
		},
	}
	register_being "blake_genguard" {
		name         = "genetic guard",
		ascii        = "H",
		color        = GREEN,
		sprite       = SPRITE_WOLF_FAKEHITLER,
		hp           = 30,
		armor        = 0,
		speed        = 100,
		todam        = 4,
		tohit        = -1,
		min_lev      = 200,
		corpse       = true,
		danger       = 3,
		weight       = 20,
		flags        = {},
		bulk         = 100,
		ai_type      = "melee_ranged_ai",

		resist = { acid = 20 },

		desc            = "Another horrible monster created by some Frankenstein-esque mad scientist. It can talk somewhat and it can use weapons. And it prefers weapons to talking.",
		kill_desc       = "killed by a genetic guard",
		kill_desc_melee = "pounded by a genetic guard",

		OnCreate = function (self)
			self.eq.weapon = item.new("blake_pistol2")
			self.inv:add("wolf_cell", { ammo = 60 })
		end,
	}
	register_being "blake_esphere" {
		name         = "electro sphere",
		ascii        = "*",
		color        = LIGHTBLUE,
		sprite       = SPRITE_WOLF_FAKEHITLER,
		hp           = 10,
		armor        = 0,
		speed        = 220,
		todam        = 6,
		tohit        = 5,
		min_lev      = 200,
		corpse       = false,
		danger       = 3,
		weight       = 20,
		flags        = {},
		bulk         = 100,
		ai_type      = "demon_ai",

		resist = { sharpnel = 20, melee = 30, acid = 10, fire = 10, plasma = 60, bullet = 30 },

		desc            = "A being of pure energy. The electro sphere burns everything in its path.",
		kill_desc       = "killed by an electro sphere",
		kill_desc_melee = "vaporized by an electro sphere",
	}
	register_being "blake_plasalien" {
		name         = "plasma alien",
		ascii        = "y",
		color        = LIGHTBLUE,
		sprite       = SPRITE_WOLF_FAKEHITLER,
		hp           = 40,
		armor        = 0,
		attackchance = 40,
		speed        = 100,
		todam        = 2,
		tohit        = -1,
		min_lev      = 200,
		corpse       = false,
		danger       = 4,
		weight       = 20,
		flags        = {},
		bulk         = 100,
		ai_type      = "melee_ranged_ai",

		resist = { acid = 20, },

		desc            = "A being of pure energy. The plasma alien burns everything in its path and can launch particles from itself at you when nearby.",
		kill_desc       = "killed by a plasma alien",
		kill_desc_melee = "vaporized by a plasma alien",

		weapon = {
			shots      = 8,
			damage     = "1d3",
			damagetype = DAMAGE_PLASMA,
			flags      = { IF_SCATTER, },
			missile = {
				sound_id   = "blake_plasalien",
				ascii      = "*",
				color      = BLUE,
				sprite     = SPRITE_PLASMABALL,
				coscolor   = { 0.0, 0.0, 1.0, 1.0 },
				delay      = 15,
				miss_base  = 50,
				miss_dist  = 4,
				range      = 5,
				maxrange   = 5,
			},
		},
	}
	register_being "blake_podalien" {
		name         = "pod alien",
		ascii        = "G",
		color        = GREEN,
		sprite       = SPRITE_WOLF_FAKEHITLER,
		hp           = 20,
		armor        = 0,
		attackchance = 40,
		speed        = 120,
		todam        = 4,
		tohit        = -1,
		min_lev      = 200,
		corpse       = true,
		danger       = 3,
		weight       = 20,
		flags        = {},
		bulk         = 100,
		ai_type      = "melee_ranged_ai",

		resist = { acid = 20 },

		desc            = "Pod aliens may look big and intimidating but in reality their soft bodies can't tolerate very many extra holes.  Keep out of range of their claws and they shouldn't be a problem.",
		kill_desc       = "killed by a pod alien",
		kill_desc_melee = "clawed by a pod alien",

		weapon = {
			damage     = "2d4",
			damagetype = DAMAGE_ACID,
			missile = {
				sound_id   = "blake_podalien",
				ascii      = "*",
				color      = LIGHTGREEN,
				sprite     = SPRITE_PLASMABALL,
				coscolor   = { 0.0, 1.0, 0.0, 1.0 },
				delay      = 30,
				miss_base  = 50,
				miss_dist  = 4,
			},
		},
	}
	register_being "blake_mech" {
		name         = "robot sentinel",
		ascii        = "H",
		color        = LIGHTCYAN,
		sprite       = SPRITE_WOLF_FAKEHITLER,
		hp           = 40,
		armor        = 2,
		speed        = 70,
		todam        = 2,
		tohit        = 0,
		min_lev      = 200,
		corpse       = true,
		danger       = 5,
		weight       = 20,
		flags        = {},
		bulk         = 100,
		ai_type      = "melee_ranged_ai",

		resist = { acid = 20, },

		desc            = "Robot guards are always harder to kill than their flesh and blood counterparts.",
		kill_desc       = "killed by a robot sentinel",
		kill_desc_melee = "crushed by a robot sentinel",

		weapon = {
			shots      = 2,
			damage     = "2d5",
			damagetype = DAMAGE_BULLET,
			fire       = 5,
			missile = {
				sound_id   = "blake_mech",
				ascii      = "-",
				color      = LIGHTGREEN,
				sprite     = SPRITE_SHOT,
				delay      = 30,
				miss_base  = 50,
				miss_dist  = 4,
			},
		},
	}


	--Bosses (exclusive to special levels obviously)
	--[[ original wolf boss stats--TLL bosses mimic their SOD counterparts:
	Hans    HP  850 (skill 1),  950 (skill 2), 1050 (skill 3), 1200 (skill 4) Speed    1536
	Schabbs HP  850 (skill 1),  950 (skill 2), 1550 (skill 3), 2400 (skill 4) Speed    1536
	Hitler1 HP  800 (skill 1),  950 (skill 2), 1050 (skill 3), 1200 (skill 4) Speed    1536
	Hitler2 HP  500 (skill 1),  700 (skill 2),  800 (skill 3),  900 (skill 4) Speed    2560
	Otto    HP  850 (skill 1),  950 (skill 2), 1050 (skill 3), 1200 (skill 4) Speed    1536
	Gretel  HP  850 (skill 1),  950 (skill 2), 1050 (skill 3), 1200 (skill 4) Speed    1536
	Fett    HP  850 (skill 1),  950 (skill 2), 1050 (skill 3), 1200 (skill 4) Speed    1536
	Trans   HP  850 (skill 1),  950 (skill 2), 1050 (skill 3), 1200 (skill 4) Speed    1536
	Barney  HP  950 (skill 1), 1050 (skill 2), 1150 (skill 3), 1300 (skill 4) Speed    2048
	Uber    HP 1050 (skill 1), 1150 (skill 2), 1250 (skill 3), 1400 (skill 4) Speed    3000
	Knight  HP 1250 (skill 1), 1350 (skill 2), 1450 (skill 3), 1600 (skill 4) Speed    2048
	Angel   HP 1450 (Skill 1), 1550 (Skill 2), 1650 (Skill 3), 2000 (Skill 4) 
	--]]
	register_being "wolf_bosshans" {
		name         = "Hans Grosse",
		ascii        = "@",
		color        = BLUE,
		sprite       = SPRITE_WOLF_HANS,
		hp           = 60,
		speed        = 100,
		armor        = 2,
		todam        = 4,
		tohit        = -1,
		tohitmelee   = 4,
		min_lev      = 200,
		corpse       = true,
		danger       = 14,
		weight       = 0,
		xp           = 1000,
		flags        = { BF_OPENDOORS, BF_HUNTING, BF_UNIQUENAME },
		bulk         = 100,
		ai_type      = "ranged_ai",

		desc            = "Hauptsturmfuhrer Hans Grosse guards the exit of Castle Wolfenstein. If you want out you will have to go through him.",
		kill_desc       = "killed by Hans Grosse",
		kill_desc_melee = "crushed by Hans Grosse",

		OnCreate = function (self)
			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 2.5
			self.hp = self.hpmax

			local weapon = item.new("wolf_assault2")
			weapon.shots = weapon.shots - 1
			weapon.acc = weapon.acc + 1
			weapon.usetime = 10
			weapon.ammo = 40
			weapon.ammomax = 40

			self.eq.weapon = weapon
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
		end,
		OnDieCheck = function (self, overkill)
			--re-adjust weapon properties
			local weapon = self.eq.weapon

			weapon.shots = items[ weapon.id ].shots
			weapon.acc = items[ weapon.id ].acc
			weapon.usetime = items[ weapon.id ].fire
			weapon.ammo = math.ceil(weapon.ammo * items[ weapon.id ].ammomax / weapon.ammomax)
			weapon.ammomax = items[ weapon.id ].ammomax

			return true
		end,
	}
	register_being "wolf_bossschabbs" {
		name         = "Dr. Schabbs",
		ascii        = "@",
		color        = WHITE,
		sprite       = SPRITE_WOLF_SCHABBS,
		hp           = 80,
		speed        = 110,
		armor        = 0,
		todam        = 2,
		tohit        = 0,
		tohitmelee   = 4,
		min_lev      = 200,
		corpse       = true,
		danger       = 14,
		weight       = 0,
		xp           = 1000,
		flags        = { BF_OPENDOORS, BF_UNIQUENAME },
		bulk         = 100,
		ai_type      = "flee_ranged_ai",

		desc            = "Dr. Schabbs is responsible for the mutant plague that's poised to sweep the land. Stop him at all costs.",
		kill_desc       = "killed by Dr. Schabbs",
		kill_desc_melee = "experimented on by Dr. Schabbs",


		weapon = {
			damage     = "1d10",
			damagetype = DAMAGE_SHARPNEL,
			--radius     = 1,
			acc        = 4,
			fire       = 12,
			missile = {
				sound_id   = "wolf_bossschabbs",
				ascii      = "`",
				color      = LIGHTGRAY,
				sprite     = SPRITE_ACIDSHOT,
				delay      = 30,
				miss_base  = 30,
				miss_dist  = 5,
				expl_delay = 8,
				expl_color = GREEN,
			},

			OnHitBeing = function(self,being,target)
				if target:is_player() and not target.flags[ BF_INV ] then --affects cannot be applied to enemies sadly
					target:set_affect("poison", 10)
				end

				return true
			end,
		},

		OnCreate = function (self)
			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 3
			self.hp = self.hpmax
		end,
	}
	register_being "wolf_bosshitler1" {
		name         = "Mecha Hitler",
		ascii        = "@",
		color        = CYAN,
		sprite       = SPRITE_WOLF_MHITLER,
		hp           = 120,
		speed        = 90,
		armor        = 3,
		todam        = 8, --Cyberarmor == hurt
		tohit        = -1,
		tohitmelee   = 4,
		min_lev      = 200,
		corpse       = true,
		danger       = 20,
		weight       = 0,
		xp           = 1000,
		flags        = { BF_OPENDOORS, BF_HUNTING, BF_UNIQUENAME },
		bulk         = 100,
		ai_type      = "melee_ranged_ai",

		desc            = "Hitler is bad enough on his own. Power armor just takes it up to 11.",
		kill_desc       = "killed by Mecha Hitler",
		kill_desc_melee = "crushed by Mecha Hitler",

		OnCreate = function (self)
			self:add_property( "ammo_regen", false )

			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 2.5
			self.hp = self.hpmax

			local weapon = item.new("wolf_assault2")
			weapon.name = "chainguns"
			weapon.shots = weapon.shots + 1
			weapon.acc = weapon.acc + 1
			weapon.usetime = 10
			weapon.ammo = 80
			weapon.ammomax = 80
			self.eq.weapon = weapon

			for i = 1, 6 do
				local ammo = item.new("wolf_kurz", { ammo = 50 })
				ammo.flags[IF_NODROP] = true
				self.inv:add(ammo)
			end
		end,
		OnAction = function (self)
			--Hitler has infinite ammo to keep things interesting, but if you take too long
			--to beat him the ammo dropped will be limited.
			local ammo_total = 0
			for x in self.inv:items() do
				if x.id == "wolf_kurz" then
					ammo_total = ammo_total + x.ammo
				end 
			end

			if ammo_total < 150 then
				local ammo = item.new("wolf_kurz", { ammo = 50 })
				ammo.flags[IF_NODROP] = true
				self.inv:add(ammo)
				self.ammo_regen = true
			end
		end,
		OnDieCheck = function (self, overkill)
			--re-adjust weapon properties.  This simulates dropping ONE but not BOTH chainguns.
			local weapon = self.eq.weapon

			weapon.name = items[ weapon.id ].name
			weapon.shots = items[ weapon.id ].shots
			weapon.acc = items[ weapon.id ].acc
			weapon.usetime = items[ weapon.id ].fire
			weapon.ammo = math.ceil(weapon.ammo * items[ weapon.id ].ammomax / weapon.ammomax)
			weapon.ammomax = items[ weapon.id ].ammomax

			--Only HALF the ammo is dropped.  Only a THIRD is dropped if you flipped ammo_regen
			local ammo_total = 0
			for x in self.inv:items() do
				if x.id == "wolf_kurz" then
					ammo_total = ammo_total + x.ammo
				end
			end

			if (self.ammo_regen) then ammo_total = math.floor(ammo_total / 3)
			else ammo_total = math.floor(ammo_total / 2)
			end

			while ammo_total > 0 do
				self.inv:add( "wolf_kurz", { ammo = math.min(ammo_total, items["wolf_kurz"].ammomax) } )
				ammo_total = ammo_total - items["wolf_kurz"].ammomax
			end

			return true
		end,
		OnDie = function (self, overkill)
			self:spawn("wolf_bosshitler2")
		
		end,
	}
	register_being "wolf_bosshitler2" {
		name         = "Hitler",
		ascii        = "@",
		color        = BROWN,
		sprite       = SPRITE_WOLF_HITLER,
		hp           = 80,
		speed        = 120,
		armor        = 3,
		todam        = 3,
		tohit        = -1,
		tohitmelee   = 4,
		min_lev      = 200,
		corpse       = true,
		danger       = 15,
		weight       = 0,
		xp           = 1000,
		flags        = { BF_OPENDOORS, BF_HUNTING, BF_UNIQUENAME },
		bulk         = 100,
		ai_type      = "ranged_ai",

		desc            = "It's almost over!  Finish the job and the West has won.",
		kill_desc       = "killed by Hitler",
		kill_desc_melee = "crushed by Hitler",

		OnCreate = function (self)
			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 3
			self.hp = self.hpmax

			local weapon = item.new("wolf_assault2")
			weapon.shots = weapon.shots - 1
			weapon.acc = weapon.acc + 1
			weapon.usetime = 10
			weapon.ammo = 40
			weapon.ammomax = 40
			self.eq.weapon = weapon

			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
		end,
		OnDieCheck = function (self, overkill)
			--re-adjust weapon properties
			local weapon = self.eq.weapon

			weapon.shots = items[ weapon.id ].shots
			weapon.acc = items[ weapon.id ].acc
			weapon.usetime = items[ weapon.id ].fire
			weapon.ammo = math.ceil(weapon.ammo * items[ weapon.id ].ammomax / weapon.ammomax)
			weapon.ammomax = items[ weapon.id ].ammomax

			return true
		end,
	}
	register_being "wolf_bossgift" {
		name         = "Otto Giftmacher",
		ascii        = "@",
		color        = WHITE,
		sprite       = SPRITE_WOLF_GIFT,
		hp           = 80,
		speed        = 120,
		armor        = 0,
		todam        = 2,
		tohit        = 0,
		tohitmelee   = 4,
		min_lev      = 200,
		corpse       = true,
		danger       = 14,
		weight       = 0,
		xp           = 1000,
		flags        = { BF_OPENDOORS, BF_UNIQUENAME },
		bulk         = 100,
		ai_type      = "flee_ranged_ai",

		desc            = "Otto Giftmacher created the chemical weapons that will be used in Operation Giftkrieg.",
		kill_desc       = "killed by Otto Giftmacher",
		kill_desc_melee = "experimented on by Otto Giftmacher",

		OnCreate = function (self)
			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 3
			self.hp = self.hpmax

			self.eq.weapon = item.new("wolf_bazooka")
			self.inv:add("wolf_rocket", { ammo = 10 })
			self.inv:add("wolf_rocket", { ammo = 10 })
			self.inv:add("wolf_rocket", { ammo = 5 })
		end,
	}
	register_being "wolf_bossgretel" {
		name         = "Gretel Grosse",
		ascii        = "@",
		color        = LIGHTRED,
		sprite       = SPRITE_WOLF_GRETEL,
		hp           = 60,
		speed        = 110,
		armor        = 2,
		todam        = 5,
		tohit        = -1,
		tohitmelee   = 2,
		min_lev      = 200,
		corpse       = true,
		danger       = 14,
		weight       = 0,
		xp           = 1000,
		flags        = { BF_OPENDOORS, BF_HUNTING, BF_UNIQUENAME },
		bulk         = 100,
		ai_type      = "ranged_ai",

		desc            = "Gretel Grosse, the 'Giantess Guardian', is acting as the bodyguard for one of the higher ups here for the meeting.",
		kill_desc       = "killed by Gretel Grosse",
		kill_desc_melee = "crushed by Gretel Grosse",

		OnCreate = function (self)
			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 3
			self.hp = self.hpmax

			local weapon = item.new("wolf_assault2")
			weapon.shots = weapon.shots - 1
			weapon.acc = weapon.acc + 1
			weapon.usetime = 10
			weapon.ammo = 40
			weapon.ammomax = 40

			self.eq.weapon = weapon
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
		end,
		OnDieCheck = function (self, overkill)
			--re-adjust weapon properties
			local weapon = self.eq.weapon

			weapon.shots = items[ weapon.id ].shots
			weapon.acc = items[ weapon.id ].acc
			weapon.usetime = items[ weapon.id ].fire
			weapon.ammo = math.ceil(weapon.ammo * items[ weapon.id ].ammomax / weapon.ammomax)
			weapon.ammomax = items[ weapon.id ].ammomax

			return true
		end,
	}
	register_being "wolf_bossfett" {
		name         = "General Fettgesicht",
		ascii        = "@",
		color        = BROWN,
		sprite       = SPRITE_WOLF_FETT,
		hp           = 150,
		speed        = 100,
		todam        = 2,
		tohit        = -1,
		tohitmelee   = 2,
		min_lev      = 200,
		corpse       = true,
		danger       = 16,
		weight       = 0,
		xp           = 1000,
		flags        = { BF_OPENDOORS, BF_HUNTING, BF_UNIQUENAME },
		bulk         = 100,
		ai_type      = "ranged_ai",

		desc            = "General Fettgesicht is the mastermind behind Operation Giftkrieg. Eliminate him.",
		kill_desc       = "killed by General Fettgesicht",
		kill_desc_melee = "crushed by General Fettgesicht",

		OnCreate = function (self)
			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 2
			self.hp = self.hpmax

			local weapon = item.new("wolf_assault2")
			weapon.shots = weapon.shots - 1
			weapon.acc = weapon.acc + 1
			weapon.usetime = 10
			weapon.ammo = 40
			weapon.ammomax = 40

			self.eq.weapon = weapon
			self.eq.prepared = item.new("wolf_bazooka")
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_rocket", { ammo = 10 })
		end,
		OnAction = function (self)
			--AI fakeout: swap between equipped and prepared if the player is within a certain range
			local switchWeapon

			--Check ammo capabilities.  If one or both weapons are empty there is no need to analyze further.
			local eqEmpty = (self.eq.weapon.ammo < math.max( self.eq.weapon.shotcost, 1 ) and not self.inv[items[self.eq.weapon.ammoid].id])
			local prEmpty = (self.eq.prepared.ammo < math.max( self.eq.prepared.shotcost, 1 ) and not self.inv[items[self.eq.prepared.ammoid].id])

			if (eqEmpty and not prEmpty) then switchWeapon = true
			elseif (prEmpty) then switchWeapon = false
			elseif (self.eq.weapon.id == "wolf_assault2" and self:distance_to( player ) >= 7 and math.random(3) ~= 1) then switchWeapon = true
			elseif (self.eq.weapon.id == "wolf_bazooka" and self:distance_to( player ) <= 5 and self:is_visible() and math.random(3) ~= 1) then switchWeapon = true
			else switchWeapon = false
			end

			if (switchWeapon) then 
				self:quick_swap()
				self:msg("",self:get_name(true,true) .. " readies his " .. self.eq.weapon.name .. ".")
			end
		end,
		OnDieCheck = function (self, overkill)
			--re-adjust weapon properties
			local weapon = self.eq.weapon
			if weapon.id ~= "wolf_assault2" then weapon = self.eq.prepared end

			weapon.shots = items[ weapon.id ].shots
			weapon.acc = items[ weapon.id ].acc
			weapon.usetime = items[ weapon.id ].fire
			weapon.ammo = math.ceil(weapon.ammo * items[ weapon.id ].ammomax / weapon.ammomax)
			weapon.ammomax = items[ weapon.id ].ammomax

			return true
		end,
	}

	register_being "wolf_bosstrans" {
		name         = "Trans Grosse",
		ascii        = "@",
		color        = GREEN,
		sprite       = SPRITE_WOLF_TRANS,
		hp           = 70,
		speed        = 90,
		armor        = 1,
		todam        = 4,
		tohit        = -1,
		tohitmelee   = 2,
		min_lev      = 200,
		corpse       = true,
		danger       = 14,
		weight       = 0,
		xp           = 1000,
		flags        = { BF_OPENDOORS, BF_HUNTING, BF_UNIQUENAME },
		bulk         = 100,
		ai_type      = "ranged_ai",

		desc            = "A cousin of the Grosse family! Trans posesses both the family passion for chainguns and the overactive pituitary gland.",
		kill_desc       = "killed by Trans Grosse",
		kill_desc_melee = "crushed by Trans Grosse",

		OnCreate = function (self)
			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 1
			self.hp = self.hpmax

			local weapon = item.new("wolf_assault2")
			weapon.shots = weapon.shots - 1
			weapon.acc = weapon.acc + 1
			weapon.usetime = 10
			weapon.ammo = 40
			weapon.ammomax = 40

			self.eq.weapon = weapon
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
		end,
		OnDieCheck = function (self, overkill)
			--re-adjust weapon properties
			local weapon = self.eq.weapon

			weapon.shots = items[ weapon.id ].shots
			weapon.acc = items[ weapon.id ].acc
			weapon.usetime = items[ weapon.id ].fire
			weapon.ammo = math.ceil(weapon.ammo * items[ weapon.id ].ammomax / weapon.ammomax)
			weapon.ammomax = items[ weapon.id ].ammomax

			return true
		end,
	}
	register_being "wolf_bossbarney" {
		name         = "Barnacle Wilhelm",
		ascii        = "@",
		color        = LIGHTBLUE,
		sprite       = SPRITE_WOLF_BARNEY,
		hp           = 110,
		speed        = 100,
		armor        = 1,
		todam        = 2,
		tohit        = -1,
		tohitmelee   = 2,
		min_lev      = 200,
		corpse       = true,
		danger       = 16,
		weight       = 0,
		xp           = 1000,
		flags        = { BF_OPENDOORS, BF_HUNTING, BF_UNIQUENAME },
		bulk         = 100,
		ai_type      = "ranged_ai",

		desc            = "No one in intelligence is quite sure what Wilhelm's position is in the German army, but then again, it's not like they can just go up to him and ask...",
		kill_desc       = "killed by Barnacle Wilhelm",
		kill_desc_melee = "crushed by Barnacle Wilhelm",

		OnCreate = function (self)
			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 2
			self.hp = self.hpmax

			local weapon = item.new("wolf_assault2")
			weapon.shots = weapon.shots - 1
			weapon.acc = weapon.acc + 1
			weapon.usetime = 10
			weapon.ammo = 40
			weapon.ammomax = 40

			self.eq.weapon = weapon
			self.eq.prepared = item.new("wolf_bazooka")
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_rocket", { ammo = 10 })
			self.inv:add( "wolf_rocket", { ammo = 5 })
		end,
		OnAction = function (self)
			--AI fakeout: swap between equipped and prepared if the player is within a certain range
			local switchWeapon

			--Check ammo capabilities.  If one or both weapons are empty there is no need to analyze further.
			local eqEmpty = (self.eq.weapon.ammo < math.max( self.eq.weapon.shotcost, 1 ) and not self.inv[items[self.eq.weapon.ammoid].id])
			local prEmpty = (self.eq.prepared.ammo < math.max( self.eq.prepared.shotcost, 1 ) and not self.inv[items[self.eq.prepared.ammoid].id])

			if (eqEmpty and not prEmpty) then switchWeapon = true
			elseif (prEmpty) then switchWeapon = false
			elseif (self.eq.weapon.id == "wolf_assault2" and self:distance_to( player ) >= 6 and math.random(3) ~= 1) then switchWeapon = true
			elseif (self.eq.weapon.id == "wolf_bazooka" and self:distance_to( player ) <= 3 and self:is_visible() and math.random(3) ~= 1) then switchWeapon = true
			else switchWeapon = false
			end

			if (switchWeapon) then 
				self:quick_swap()
				self:msg("",self:get_name(true,true) .. " readies his " .. self.eq.weapon.name .. ".")
			end
		end,
		OnDieCheck = function (self, overkill)
			--re-adjust weapon properties
			local weapon = self.eq.weapon
			if weapon.id ~= "wolf_assault2" then weapon = self.eq.prepared end

			weapon.shots = items[ weapon.id ].shots
			weapon.acc = items[ weapon.id ].acc
			weapon.usetime = items[ weapon.id ].fire
			weapon.ammo = math.ceil(weapon.ammo * items[ weapon.id ].ammomax / weapon.ammomax)
			weapon.ammomax = items[ weapon.id ].ammomax

			return true
		end,
	}
	register_being "wolf_bossuber" {
		name         = "Ubermutant",
		ascii        = "@",
		color        = MAGENTA,
		sprite       = SPRITE_WOLF_UBERMUTANT,
		hp           = 200,
		speed        = 130,
		todam        = 8,
		tohit        = -1,
		tohitmelee   = 8,
		min_lev      = 200,
		corpse       = true,
		danger       = 18,
		weight       = 0,
		xp           = 1000,
		flags        = { BF_OPENDOORS, BF_HUNTING, BF_UNIQUENAME },
		bulk         = 100,
		ai_type      = "melee_ranged_ai",

		desc            = "This... thing has four arms, four cleavers, and a chest mounted chaingun. It's a sin against nature. You'll need to make it history.",
		kill_desc       = "ventilated by the Ubermutant",
		kill_desc_melee = "hacked into pieces by the Ubermutant",

		OnCreate = function (self)
			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 3
			self.hp = self.hpmax

			local weapon = item.new("wolf_assault2")
			weapon.shots = weapon.shots - 1
			weapon.acc = weapon.acc + 1
			weapon.usetime = 10
			weapon.flags[IF_NOAMMO] = true
			weapon.flags[IF_NODROP] = true

			self.eq.weapon = weapon
		end,
	}
	register_being "wolf_bossknight" {
		name         = "Death Knight",
		ascii        = "@",
		color        = DARKGRAY,
		sprite       = SPRITE_WOLF_KNIGHT,
		hp           = 150,
		armor        = 4,
		speed        = 90,
		todam        = 6,
		tohit        = -1,
		tohitmelee   = 6,
		min_lev      = 200,
		corpse       = true,
		danger       = 20,
		weight       = 0,
		xp           = 1000,
		flags        = { BF_OPENDOORS, BF_HUNTING, BF_UNIQUENAME },
		bulk         = 100,
		ai_type      = "melee_ranged_ai",

		desc            = "The only thing left between you and the Spear is the most monsterous Nazi you've ever seen.",
		kill_desc       = "obliterated by the Death Knight",
		kill_desc_melee = "flattened by the Death Knight",

		OnCreate = function (self)
			self:add_property("missile_countdown", 10)

			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 4
			self.hp = self.hpmax

			local weapon

			weapon = item.new("wolf_assault2")
			weapon.name = "chainguns"
			weapon.shots = weapon.shots + 1
			weapon.acc = weapon.acc + 1
			weapon.usetime = 10
			weapon.flags[IF_NOAMMO] = true
			weapon.flags[IF_NODROP] = true
			self.eq.weapon = weapon

			weapon = item.new("wolf_bazooka")
			weapon.name = "panzerschrecks"
			weapon.ammo = 2
			weapon.ammomax = 2
			weapon.flags[IF_NODROP] = true
			self.eq.prepared = weapon

			--Inventory drops
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_rocket", { ammo = 3 } )
		end,
		OnAction = function (self)
			--DK doesn't reload his weapons because they are part of his battle suit and automatically reloaded for him.
			--To ensure there's no cheesing the final boss's ammo supply away from him the ammo is infinite.
			local switchWeapon
			local bazooka = self.eq.weapon
			if (bazooka ~= nil and bazooka.id ~= "wolf_bazooka") then bazooka = self.eq.prepared end

			--Check bazooka ammo.  If it's not maxed out handle the missile reload counter.
			if (bazooka ~= nil and bazooka.ammo < bazooka.ammomax) then
				self.missile_countdown = self.missile_countdown - 1
				if (self.missile_countdown <= 0) then
					bazooka.ammo = bazooka.ammo + 1
					self.missile_countdown = 10
				end
			end

			local eqEmpty = ((self.eq.weapon == nil) or self.eq.weapon.ammo < math.max( self.eq.weapon.shotcost, 1 ) and not self.eq.weapon.flags[IF_NOAMMO])
			local prEmpty = ((self.eq.prepared == nil) or self.eq.prepared.ammo < math.max( self.eq.prepared.shotcost, 1 ) and not self.eq.prepared.flags[IF_NOAMMO])

			--DK prefers the bazooka but prefers not to switch to it until it's fully loaded.
			if (self.eq.weapon == nil) then switchWeapon = true
			elseif (self.eq.prepared == nil) then switchWeapon = false
			elseif (eqEmpty and not prEmpty) then switchWeapon = true
			elseif (self.eq.weapon.id == "wolf_assault2" and self:distance_to( player ) >= 4 and math.random(10) <= self.eq.prepared.ammo) then switchWeapon = true
			elseif (self.eq.weapon.id == "wolf_bazooka"  and self:distance_to( player ) <= 3 and self:is_visible() and math.random(3) ~= 1) then switchWeapon = true
			else switchWeapon = false
			end

			if (switchWeapon) then
				self:quick_swap()
				self:msg("",self:get_name(true,true) .. " readies its " .. self.eq.weapon.name .. ".")
			end
		end,
	}
	register_being "wolf_bossangel" {
		name         = "Angel of Death",
		name_plural  = "Angels of Death",
		ascii        = "A",
		color        = RED,
		sprite       = SPRITE_WOLF_AOD,
		hp           = 250,
		armor        = 10,
		todam        = 15,
		tohit        = 8,
		speed        = 150,
		min_lev      = 200,
		danger       = 40,
		weight       = 0,
		xp           = 0,
		bulk         = 100,
		flags        = { BF_CHARGE, BF_ENVIROSAFE ,BF_HUNTING, BF_UNIQUENAME },
		ai_type      = "melee_ranged_ai",

		desc            = "The Angel of Death's presence is strangely comforting. The spear means something after all. And the angel is at least offering you a chance, something most mortals never get.",
		kill_desc       = "witnessed the power of death",
		kill_desc_melee = "awe struck by the thought of death",

		weapon = {
			damage     = "8d8",
			damagetype = DAMAGE_ACID,
			radius     = 1,
			missile = {
				sound_id   = "wolf_bossangel",
				ascii      = "*",
				color      = LIGHTRED,
				sprite     = SPRITE_ACIDSHOT,
				delay      = 30,
				miss_base  = 50,
				miss_dist  = 5,
				expl_delay = 40,
				expl_color = GREEN,
				expl_flags = { EFHALFKNOCK },
			},
		},

		OnCreate = function (self)
			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 5
			self.hp = self.hpmax
		end,
	}

	register_being "wolf_bosswillie" {
		name         = "Submarine Willie",
		ascii        = "@",
		color        = LIGHTBLUE,
		sprite       = SPRITE_WOLF_WILLIE,
		hp           = 70,
		speed        = 130,
		armor        = 0,
		todam        = 4,
		tohit        = -2,
		tohitmelee   = 2,
		min_lev      = 200,
		corpse       = true,
		danger       = 9,
		weight       = 0,
		xp           = 500,
		flags        = { BF_OPENDOORS, BF_HUNTING, BF_UNIQUENAME },
		bulk         = 100,
		ai_type      = "ranged_ai",

		desc            = "Never the brightest of minions Submarine Willie is nonetheless feared by ally and enemy alike. The lobotomy his unstable temperament earned him has helped reduce his own side's casualties but the other guards are still keen to avoid his fits of rage.",
		kill_desc       = "killed by Submarine Willie",
		kill_desc_melee = "crushed by Submarine Willie",

		OnCreate = function (self)
			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 1
			self.hp = self.hpmax

			self.eq.weapon = item.new("wolf_sub2") --Your reward for beating him, and also because he's an odd goose.
			self.inv:add("wolf_9mm", { ammo = 32 })
			self.inv:add("wolf_9mm", { ammo = 32 })
			self.inv:add("wolf_9mm", { ammo = 32 })
			self.inv:add("wolf_9mm", { ammo = 32 })
		end,
	}
	register_being "wolf_bossquark" {
		name         = "Professor Quarkblitz",
		ascii        = "@",
		color        = WHITE,
		sprite       = SPRITE_WOLF_QUARK,
		hp           = 110,
		speed        = 100,
		armor        = 2,
		todam        = 1,
		tohit        = -1,
		tohitmelee   = 3,
		min_lev      = 200,
		corpse       = true,
		danger       = 13,
		weight       = 0,
		xp           = 1000,
		flags        = { BF_OPENDOORS, BF_HUNTING, BF_UNIQUENAME },
		bulk         = 100,
		ai_type      = "flee_ranged_ai",

		desc            = "Professor Quarkblitz thinks of himself as a brilliant scientist, completely unappreciated as he works tirelessly in the shadow of the insufferable Doctor Schabbs. In truth he is nothing but a madman whose experiments are rarely successful and always abominations.",
		kill_desc       = "killed by Professor Quarkblitz",
		kill_desc_melee = "crushed by Professor Quarkblitz",

		OnCreate = function (self)
			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 2
			self.hp = self.hpmax

			--A micro launcher
			local weapon = item.new("wolf_bazooka")
			local blueprints = mod_arrays["micro"]
			blueprints.OnApply(weapon)
			weapon.color = LIGHTCYAN
			weapon.flags[ IF_NONMODABLE ] = true --QB isn't a whizkid so his weapon is not moddable :)
			weapon.flags[ IF_MODIFIED ] = false
			weapon.flags[ IF_ASSEMBLED ] = true
			weapon:clear_mods()

			self.eq.weapon = weapon
			self.eq.prepared = item.new("wolf_pistol3")
			self.inv:add(item.new("wolf_9mm"))
			self.inv:add(item.new("wolf_9mm"))
			self.inv:add(item.new("wolf_9mm"))
			self.inv:add( "wolf_rocket", { ammo = 6 })
		end,
		OnAction = function (self)
			--AI fakeout: swap between equipped and prepared if the RL is out of ammo
			local switchWeapon

			--Check ammo capabilities.
			local eqEmpty = (self.eq.weapon.ammo < math.max( self.eq.weapon.shotcost, 1 ) and not self.inv[items[self.eq.weapon.ammoid].id])
			local prEmpty = (self.eq.prepared.ammo < math.max( self.eq.prepared.shotcost, 1 ) and not self.inv[items[self.eq.prepared.ammoid].id])

			if (eqEmpty and not prEmpty) then
				self:quick_swap()
				self:msg("",self:get_name(true,true) .. " readies his " .. self.eq.weapon.name .. ".")
			end
		end,
	}
	register_being "wolf_bossaxe" {
		name         = "The Axe",
		ascii        = "@",
		color        = LIGHTCYAN,
		sprite       = SPRITE_WOLF_AXE,
		hp           = 100,
		speed        = 130,
		armor        = 4,
		attackchance = 30,
		todam        = 3,
		tohit        = -1,
		tohitmelee   = 8,
		min_lev      = 200,
		corpse       = true,
		danger       = 18,
		weight       = 0,
		xp           = 1000,
		flags        = { BF_QUICKSWAP, BF_OPENDOORS, BF_HUNTING, BF_UNIQUENAME },
		bulk         = 100,
		ai_type      = "melee_ranged_ai",

		desc            = "The Axe, believed named Hans Von Schlieffen before service, was once an unassuming major. Now it is unclear if the Axe is even human. Believed responsible for originally capturing the Spear for the Axis powers, he follows orders with brutal efficiency and without question.",
		kill_desc       = "ventilated by the Axe",
		kill_desc_melee = "hacked into pieces by the Axe",

		OnCreate = function (self)
			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 3
			self.hp = self.hpmax

			local weapon = item.new("wolf_assault2")
			weapon.shots = weapon.shots - 1
			weapon.acc = weapon.acc + 1
			weapon.usetime = 10
			weapon.ammo = 40
			weapon.ammomax = 40

			self.eq.weapon = weapon
			self.eq.prepared = item.new("wolf_axe")
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
		end,
		OnDieCheck = function (self, overkill)
			--re-adjust weapon properties
			local weapon = self.eq.weapon

			weapon.shots = items[ weapon.id ].shots
			weapon.acc = items[ weapon.id ].acc
			weapon.usetime = items[ weapon.id ].fire
			weapon.ammo = math.ceil(weapon.ammo * items[ weapon.id ].ammomax / weapon.ammomax)
			weapon.ammomax = items[ weapon.id ].ammomax

			return true
		end,
	}
	register_being "wolf_bossrobot" {
		name         = "The Robot",
		ascii        = "@",
		color        = LIGHTRED,
		sprite       = SPRITE_WOLF_ROBOT,
		hp           = 200,
		armor        = 2,
		speed        = 110,
		todam        = 6,
		tohit        = -1,
		tohitmelee   = 6,
		min_lev      = 200,
		corpse       = true,
		danger       = 20,
		weight       = 0,
		xp           = 1000,
		flags        = { BF_HUNTING, BF_UNIQUENAME },
		bulk         = 100,
		ai_type      = "wolf_robot_ai",

		desc            = "The robot that stands before you is one of Professor Quarkblitz's successful (relatively speaking) inventions. It feels no pain and shows no mercy, but with enough bullets in the chassie it will go down.",
		kill_desc       = "obliterated by the Robot",
		kill_desc_melee = "flattened by the Robot",

		OnCreate = function (self)
			self:add_property("missile_countdown", 10)
			self:add_property("bazooka_damage", 0)
			self:add_property("chaingun_damage", 0)

			self.hpmax = self.hpmax + DIFFICULTY * DIFFICULTY * 4
			self.hp = self.hpmax

			local weapon

			weapon = item.new("wolf_assault2")
			weapon.name = "chainguns"
			weapon.shots = weapon.shots + 1
			weapon.acc = weapon.acc + 1
			weapon.usetime = 10
			weapon.flags[IF_NOAMMO] = true
			weapon.flags[IF_NODROP] = true
			self.eq.weapon = weapon

			weapon = item.new("wolf_bazooka")
			weapon.name = "panzerschrecks"
			weapon.ammo = 2
			weapon.ammomax = 2
			weapon.flags[IF_NODROP] = true
			self.eq.prepared = weapon
		end,
		OnAction = function (self)
			local function DamageWeapon()
				if (self.eq.weapon == nil) then return end --Should never happen, nor should a non-bazooka/chaingun base
				if (self.eq.weapon.id == "wolf_bazooka") then
					self.bazooka_damage = self.bazooka_damage + 1
					if (self.bazooka_damage >= 2) then
						self.eq.weapon = nil
						self:msg("Your rocket launcher is completely destroyed!", self:get_name(true,true).."'s rocket launcher explodes!")
					else
						self.eq.weapon.ammomax = math.floor(self.eq.weapon.ammomax / 2)
						self.eq.weapon.ammo = math.min(self.eq.weapon.ammo, self.eq.weapon.ammomax)
						self.eq.weapon.damage_add = self.eq.weapon.damage_add  - 1
						self:msg("Your rocket launcher is damaged!", self:get_name(true,true).."'s rocket launcher starts sparking!")
					end
				elseif(self.eq.weapon.id == "wolf_assault2") then
					self.chaingun_damage = self.chaingun_damage + 1
					if (self.chaingun_damage >= 2) then
						self.eq.weapon = nil
						self:msg("Your chainguns are completely destroyed!", self:get_name(true,true).."'s chainguns collapse!")
					else
						self.eq.weapon.shots = math.floor(self.eq.weapon.shots / 2)
						self.eq.weapon.damage_add = self.eq.weapon.damage_add  - 1
						self:msg("Your chaingun is damaged!", self:get_name(true,true).."'s chaingun starts grinding!")
					end
				end
			end

			local switchWeapon
			local bazooka = self.eq.weapon
			if (bazooka ~= nil and bazooka.id ~= "wolf_bazooka") then bazooka = self.eq.prepared end

			--The Robot's weapons aren't reloaded normally and they break down as damage is sustained.
			    if (self.damage_level <= 0 and self.hp / self.hpmax < .75) then
				self.damage_level = self.damage_level + 1
				DamageWeapon()
			elseif (self.damage_level <= 1 and self.hp / self.hpmax < .50) then
				self.damage_level = self.damage_level + 1
				DamageWeapon()
			elseif (self.damage_level <= 2 and self.hp / self.hpmax < .30) then
				self.damage_level = self.damage_level + 1
				self:msg("Your treads have been badly damaged!",self:get_name(true,true).."'s treads have been thrown!")
			end


			--Check bazooka ammo.  If it's not maxed out handle the missile reload counter.
			if (bazooka ~= nil and bazooka.ammo < bazooka.ammomax) then
				self.missile_countdown = self.missile_countdown - 1
				if (self.missile_countdown <= 0) then
					bazooka.ammo = bazooka.ammo + 1
					if (self.bazooka_damage >= 1) then self.missile_countdown = 20 else self.missile_countdown = 10 end
				end
			end

			local eqEmpty = ((self.eq.weapon == nil) or self.eq.weapon.ammo < math.max( self.eq.weapon.shotcost, 1 ) and not self.eq.weapon.flags[IF_NOAMMO])
			local prEmpty = ((self.eq.prepared == nil) or self.eq.prepared.ammo < math.max( self.eq.prepared.shotcost, 1 ) and not self.eq.prepared.flags[IF_NOAMMO])

			if (self.eq.weapon == nil) then switchWeapon = true
			elseif (self.eq.prepared == nil) then switchWeapon = false
			elseif (eqEmpty and not prEmpty) then switchWeapon = true
			elseif (self.eq.weapon.id == "wolf_assault2" and self:distance_to( player ) >= 4 and math.random(10) <= self.eq.prepared.ammo) then switchWeapon = true
			elseif (self.eq.weapon.id == "wolf_bazooka"  and self:distance_to( player ) <= 3 and self:is_visible() and math.random(3) ~= 1) then switchWeapon = true
			else switchWeapon = false
			end

			if (switchWeapon) then
				self:quick_swap()
				self:msg("",self:get_name(true,true) .. " readies its " .. self.eq.weapon.name .. ".")
			end
		end,
		OnDie = function (self)
			--Inventory drops which can't be added directly lest the AI try to reload
			level:drop_item_ext( { "wolf_kurz",   ammo = 50 }, self.position )
			level:drop_item_ext( { "wolf_rocket", ammo = 3  }, self.position )
		end,
	}

	--To Consider: make the below the standard definitions and adjust on special levels for bosses
	register_being "wolf_minihans" { --Hans is also usually constrained to the end of an episode, but he tends to show up in special levels a lot too.  Run with it.
		name         = "Hans Grosse",
		sound_id     = "wolf_bosshans",
		ascii        = "@",
		color        = BLUE,
		sprite       = SPRITE_WOLF_HANS,
		hp           = 40,
		speed        = 100,
		armor        = 1,
		todam        = 4,
		tohit        = -1,
		tohitmelee   = 2,
		min_lev      = 200,
		corpse       = true,
		danger       = 10,
		weight       = 0,
		flags        = { BF_OPENDOORS, BF_UNIQUENAME },
		bulk         = 100,
		ai_type      = "former_ai",

		desc            = "Hauptsturmfuhrer Hans Grosse. Hans may not be a smart man or a wise man, but he is a very big man.",
		kill_desc       = "killed by Hans Grosse",
		kill_desc_melee = "crushed by Hans Grosse",

		OnCreate = function (self)
			local weapon = item.new("wolf_assault2")
			weapon.shots = weapon.shots - 1
			weapon.acc = weapon.acc + 1
			weapon.usetime = 10
			weapon.ammo = 40
			weapon.ammomax = 40

			self.eq.weapon = weapon
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
		end,

		OnDieCheck = function (self, overkill)
			--re-adjust weapon properties
			local weapon = self.eq.weapon

			weapon.shots = items[ weapon.id ].shots
			weapon.acc = items[ weapon.id ].acc
			weapon.usetime = items[ weapon.id ].fire
			weapon.ammo = math.ceil(weapon.ammo * items[ weapon.id ].ammomax / weapon.ammomax)
			weapon.ammomax = items[ weapon.id ].ammomax

			return true
		end,
	}
	register_being "wolf_minitrans" { --Same as above
		name         = "Trans Grosse",
		sound_id     = "wolf_bosstrans",
		ascii        = "@",
		color        = GREEN,
		sprite       = SPRITE_WOLF_TRANS,
		hp           = 50,
		speed        = 90,
		armor        = 1,
		todam        = 4,
		tohit        = -1,
		tohitmelee   = 1,
		min_lev      = 200,
		corpse       = true,
		danger       = 10,
		weight       = 0,
		flags        = { BF_OPENDOORS, BF_UNIQUENAME },
		bulk         = 100,
		ai_type      = "former_ai",

		desc            = "A cousin of the Grosse family! Trans posesses both the family passion for chainguns and the overactive pituitary gland.",
		kill_desc       = "killed by Trans Grosse",
		kill_desc_melee = "crushed by Trans Grosse",

		OnCreate = function (self)
			local weapon = item.new("wolf_assault2")
			weapon.shots = weapon.shots - 1
			weapon.acc = weapon.acc + 1
			weapon.usetime = 10
			weapon.ammo = 40
			weapon.ammomax = 40

			self.eq.weapon = weapon
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
		end,

		OnDieCheck = function (self, overkill)
			--re-adjust weapon properties
			local weapon = self.eq.weapon

			weapon.shots = items[ weapon.id ].shots
			weapon.acc = items[ weapon.id ].acc
			weapon.usetime = items[ weapon.id ].fire
			weapon.ammo = math.ceil(weapon.ammo * items[ weapon.id ].ammomax / weapon.ammomax)
			weapon.ammomax = items[ weapon.id ].ammomax

			return true
		end,
	}
	register_being "wolf_minigretel" { --Same as above
		name         = "Gretel Grosse",
		sound_id     = "wolf_bossgretel",
		ascii        = "@",
		color        = LIGHTRED,
		sprite       = SPRITE_WOLF_GRETEL,
		hp           = 40,
		speed        = 110,
		armor        = 1,
		todam        = 5,
		tohit        = -1,
		tohitmelee   = 1,
		min_lev      = 200,
		corpse       = true,
		danger       = 10,
		weight       = 0,
		flags        = { BF_OPENDOORS, BF_UNIQUENAME },
		bulk         = 100,
		ai_type      = "former_ai",

		desc            = "Gretel Grosse, the 'Giantess Guardian', is acting as the bodyguard for one of the higher ups here for the meeting.",
		kill_desc       = "killed by Gretel Grosse",
		kill_desc_melee = "crushed by Gretel Grosse",

		OnCreate = function (self)
			local weapon = item.new("wolf_assault2")
			weapon.shots = weapon.shots - 1
			weapon.acc = weapon.acc + 1
			weapon.usetime = 10
			weapon.ammo = 40
			weapon.ammomax = 40

			self.eq.weapon = weapon
			self.inv:add( "wolf_kurz", { ammo = 50 } )
			self.inv:add( "wolf_kurz", { ammo = 50 } )
		end,

		OnDieCheck = function (self, overkill)
			--re-adjust weapon properties
			local weapon = self.eq.weapon

			weapon.shots = items[ weapon.id ].shots
			weapon.acc = items[ weapon.id ].acc
			weapon.usetime = items[ weapon.id ].fire
			weapon.ammo = math.ceil(weapon.ammo * items[ weapon.id ].ammomax / weapon.ammomax)
			weapon.ammomax = items[ weapon.id ].ammomax

			return true
		end,
	}

	--Groups (I've only made one because otherwise things will break and I'm not ready to balance these)
	register_being_group {
		min_lev = 7,
		max_lev = 16,
		weight  = 10,
		beings = {
			{ being = "wolf_guard2" },
			{ being = "wolf_guard1", amount = {2,6} }
		}
	}

end
