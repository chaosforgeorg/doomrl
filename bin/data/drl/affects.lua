function drl.register_affects()
	
	register_affect "tired"
	{
		name           = "tired",
		color          = DARKGRAY,
		color_expire   = DARKGRAY,
		
		OnAdd          = function(self)
			self:remove_affect( "running" )
		end,
		OnRemove       = function(self)
		end,
	}

	register_affect "running"
	{
		name           = "running",
		color          = YELLOW,
		color_expire   = BROWN,
		message_init   = "You start running!",
		message_done   = "You stop running.",

		OnAdd          = function(self)
			self:remove_affect( "tired" )
		end,
		OnRemove       = function(self)
			self:set_affect( "tired" );
		end,
		getDodgeBonus = function( self )
			return 20
		end,
		getMoveBonus = function( self )
			return 30
		end,
		getDefenceBonus = function( self, is_melee )
			return 4
		end,
		getToHitBonus = function( self, weapon, is_melee, alt )
			if not self:has_property( "NO_RUN_PENALTY" ) then
				return -2
			end
			return 0
		end,
	}

	register_affect "berserk"
	{
		name           = "berserk",
		color          = LIGHTRED,
		color_expire   = RED,
		message_init   = "You feel like a killing machine!",
		message_ending = "You feel your anger slowly wearing off...",
		message_done   = "You feel more calm.",
		status_effect  = STATUSRED,
		status_strength= 5,

		OnAdd          = function(self)
			self:remove_affect( "running", true )
			self.speed = self.speed + 50
			self.resist.bullet = (self.resist.bullet or 0) + 50
			self.resist.melee = (self.resist.melee or 0) + 50
			self.resist.shrapnel = (self.resist.shrapnel or 0) + 50
			self.resist.acid = (self.resist.acid or 0) + 50
			self.resist.fire = (self.resist.fire or 0) + 50
			self.resist.plasma = (self.resist.plasma or 0) + 50
		end,
		OnUpdate        = function(self)
			ui.msg("You need to taste blood!")
		end,
		OnRemove       = function(self)
			self.speed = self.speed - 50
			self.resist.bullet = (self.resist.bullet or 0) - 50
			self.resist.melee = (self.resist.melee or 0) - 50
			self.resist.shrapnel = (self.resist.shrapnel or 0) - 50
			self.resist.acid = (self.resist.acid or 0) - 50
			self.resist.fire = (self.resist.fire or 0) - 50
			self.resist.plasma = (self.resist.plasma or 0) - 50
		end,
		getDamageMul = function( self, weapon, is_melee, alt )
			if ( weapon and weapon.itype == ITEMTYPE_MELEE ) or is_melee then
				return 2.0
			end
			return 1.0
		end,
	}

	register_affect "inv"
	{
		name           = "invulnerable",
		color          = WHITE,
		color_expire   = DARKGRAY,
		message_init   = "You feel invincible!",
		message_ending = "You feel your invincibility fading...",
		message_done   = "You feel vulnerable again.",
		status_effect  = STATUSINVERT,
		status_strength= 10,

		OnAdd          = function(self)
			self.flags[ BF_INV ] = true
		end,
		OnUpdate       = function(self)
			if self.hp < self.hpmax and not self.flags[ BF_NOHEAL ] then
				self.hp = self.hpmax
			end
		end,
		OnRemove       = function(self)
			self.flags[ BF_INV ] = false
		end,
	}

	register_affect "enviro"
	{
		name           = "enviro",
		color          = LIGHTGREEN,
		color_expire   = GREEN,
		message_init   = "You feel protected!",
		message_ending = "You feel your protection fading...",
		message_done   = "You feel less protected.",
		status_effect  = STATUSGREEN,
		status_strength= 1,

		OnAdd          = function(self)
			self.resist.acid = (self.resist.acid or 0) + 25
			self.resist.fire = (self.resist.fire or 0) + 25
		end,

		OnRemove       = function(self)
			self.resist.acid = (self.resist.acid or 0) - 25
			self.resist.fire = (self.resist.fire or 0) - 25
		end,
	}

	register_affect "light"
	{
		name           = "light",
		color          = YELLOW,
		color_expire   = BROWN,
		message_init   = "You see further!",
		message_ending = "You feel your enhanced vision fading...",
		message_done   = "Your vision fades.",

		OnAdd          = function(self)
			self.vision = self.vision + 4
		end,

		OnRemove       = function(self)
			self.vision = self.vision - 4
		end,
	}

end
