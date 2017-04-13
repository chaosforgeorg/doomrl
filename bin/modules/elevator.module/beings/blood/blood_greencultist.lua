--Blood has four cultist type enemies.  BloodRL has seven in order to flesh out the weapons and mid ranges (some come from zblood).
require("elevator:ai/blood_gcultist_ai")

register_being "blood_greencultist" {
	name         = "ackolyte",
	ascii        = "h",
	color        = LIGHTGREEN,
	sprite       = 0,
	todam        = -1,
	tohit        = -4,
	speed        = 90,
	min_lev      = 0,
	max_lev      = 12,
	corpse       = true,
	danger       = 2,
	weight       = 10,
	bulk         = 100,
	flags        = { BF_OPENDOORS },
	ai_type      = "blood_gcultist_ai",

	desc            = "Cultists in training, the Cabal doesn't even give these guys guns. They're being tested to see how long they can handle dynamite without blowing themselves up.",
	kill_desc       = "blown to pieces by an ackolyte",
	kill_desc_melee = "maimed by an ackolyte",

	weapon = {
		damage     = "4d4",
		damagetype = DAMAGE_FIRE,
		radius     = 1,
		fire       = 21,
		missile = {
			sound_id   = "blood_dynamite",
			ascii      = "/",
			color      = LIGHTRED,
			sprite     = 0,
			delay      = 30,
			miss_base  = 30,
			miss_dist  = 6,
			range      = 5,
			flags = { MF_EXACT },
			expl_delay = 40,
			expl_color = YELLOW,
		},
	},
	OnAttacked = function( self )
		self:play_sound( "cultist.hit" .. math.random(4) )
	end,
	OnDie = function( self )
		self:play_sound( "cultist.die" .. math.random(4) )
	end,
}

--Fixing up sounds
local FixSounds = function()
	--beings["blood_greencultist"].sound_hit   = core.resolve_sound_id("cultist.hit1")
	--beings["blood_greencultist"].sound_die   = core.resolve_sound_id("cultist.die1")
	--beings["blood_greencultist"].sound_act   = core.resolve_sound_id("cultist2.act1")
	beings["blood_greencultist"].sound_melee = core.resolve_sound_id("blood.punch")
	items["nat_blood_greencultist"].sound_fire    = core.resolve_sound_id("blood_dynamite.fire")
	items["nat_blood_greencultist"].sound_explode = core.resolve_sound_id("blood_dynamite.explode")
end
FixAllSounds = core.create_seq_function(FixSounds, FixAllSounds)