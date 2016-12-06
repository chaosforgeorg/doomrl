function DoomRL.loadaffects()
	
	register_affect "berserk"
	{
		name           = "brk",
		color          = LIGHTRED,
		color_expire   = RED,
		message_init   = "You feel like a killing machine!",
		message_ending = "You feel your anger slowly wearing off...",
		message_done   = "You feel more calm.",
		status_effect  = STATUSRED,
		status_strength= 5,

		OnAdd          = function(being)
			being.flags[ BF_BERSERK ] = true
			being.speed = being.speed + 50
			being.resist.bullet = (being.resist.bullet or 0) + 60
			being.resist.melee = (being.resist.melee or 0) + 60
			being.resist.shrapnel = (being.resist.shrapnel or 0) + 60
			being.resist.acid = (being.resist.acid or 0) + 60
			being.resist.fire = (being.resist.fire or 0) + 60
			being.resist.plasma = (being.resist.plasma or 0) + 60
		end,
		OnTick         = function(being)
			ui.msg("You need to taste blood!")
		end,
		OnRemove       = function(being)
			being.flags[ BF_BERSERK ] = false
			being.speed = being.speed - 50
			being.resist.bullet = (being.resist.bullet or 0) - 60
			being.resist.melee = (being.resist.melee or 0) - 60
			being.resist.shrapnel = (being.resist.shrapnel or 0) - 60
			being.resist.acid = (being.resist.acid or 0) - 60
			being.resist.fire = (being.resist.fire or 0) - 60
			being.resist.plasma = (being.resist.plasma or 0) - 60
		end,
	}

	register_affect "inv"
	{
		name           = "inv",
		color          = WHITE,
		color_expire   = DARKGRAY,
		message_init   = "You feel invincible!",
		message_ending = "You feel your invincibility fading...",
		message_done   = "You feel vulnerable again.",
		status_effect  = STATUSINVERT,
		status_strength= 10,

		OnAdd          = function(being)
			being.flags[ BF_INV ] = true
		end,
		OnTick         = function(being)
			if being.hp < being.hpmax and not being.flags[ BF_NOHEAL ] then
				being.hp = being.hpmax
			end
		end,
		OnRemove       = function(being)
			being.flags[ BF_INV ] = false
		end,
	}

	register_affect "enviro"
	{
		name           = "env",
		color          = LIGHTGREEN,
		color_expire   = GREEN,
		message_init   = "You feel protected!",
		message_ending = "You feel your protection fading...",
		message_done   = "You feel less protected.",
		status_effect  = STATUSGREEN,
		status_strength= 1,

		OnAdd          = function(being)
			being.resist.acid = (being.resist.acid or 0) + 25
			being.resist.fire = (being.resist.fire or 0) + 25
		end,

		OnRemove       = function(being)
			being.resist.acid = (being.resist.acid or 0) - 25
			being.resist.fire = (being.resist.fire or 0) - 25
		end,
	}

	register_affect "light"
	{
		name           = "lit",
		color          = YELLOW,
		color_expire   = BROWN,
		message_init   = "You see further!",
		message_ending = "You feel your enhanced vision fading...",
		message_done   = "Your vision fades.",

		OnAdd          = function(being)
			being.vision = being.vision + 4
		end,

		OnRemove       = function(being)
			being.vision = being.vision - 4
		end,
	}

end
