core.register_blueprint "requirement"
{
	id             = { true,  core.TSTRING },
	progress       = { false, core.TFUNC },
	description    = { false, core.TFUNC },
}

core.register_blueprint "rank_req"
{
	req    = { true, core.TIDIN("requirements") },
	amount = { false, core.TNUMBER, 1 }, 
	param  = { false, core.TANY },
}

core.register_blueprint "rank"
{
	name           = { true, core.TSTRING },
	reqs           = { true, core.TARRAY("rank_req") },
}

core.register_blueprint "difficulty"
{
	id          = { true,  core.TSTRING },
	name        = { true,  core.TSTRING },
	description = { true,  core.TSTRING },
	code        = { true,  core.TSTRING },
	tohitbonus  = { false, core.TNUMBER, 0 },
	expfactor   = { false, core.TNUMBER, 1 },
	scorefactor = { false, core.TNUMBER, 1 },
	ammofactor  = { false, core.TNUMBER, 1 },
	powerfactor = { false, core.TNUMBER, 1 },
	powerbonus  = { false, core.TNUMBER, 1.5 },
	respawn     = { false, core.TBOOL,   false },
	challenge   = { false, core.TBOOL,   true },
	req_skill   = { false, core.TNUMBER, 0 },
	req_exp     = { false, core.TNUMBER, 0 },
	speed       = { false, core.TNUMBER, 1 },
}

core.register_blueprint "trait"
{
	id             = { true,  core.TSTRING },
	name           = { true,  core.TSTRING },
	desc           = { false, core.TSTRING, "" },
	quote          = { false, core.TSTRING, "" },
	full           = { false, core.TSTRING, "" },
	author         = { false, core.TSTRING },
	master         = { false, core.TBOOL,   false },
	abbr           = { true,  core.TSTRING },

	OnPick         = { true,  core.TFUNC },
}

core.register_blueprint "klass_trait"
{
	id         = { true,  core.TIDIN("traits") },
	max        = { false, core.TNUMBER, 1 },
	max_12     = { false, core.TNUMBER },
	reqlevel   = { false, core.TNUMBER, 0 },
	master     = { false, core.TBOOL,   false },
	requires   = { false, core.TARRAY( core.TTABLE ) },
	blocks     = { false, core.TARRAY( core.TIDIN("traits") ) }
}


core.register_blueprint "klass"
{
	id         = { true,  core.TSTRING },
	name       = { true,  core.TSTRING },
	char       = { true,  core.TSTRING },
	desc       = { true,  core.TSTRING },
	hidden     = { false, core.TBOOL, false },
	traits     = { true,  core.TARRAY("klass_trait") },

	OnPick     = { true,  core.TFUNC },
}

core.register_blueprint "medal"
{
	id        = { true,  core.TSTRING },
	name      = { true,  core.TSTRING },
	desc      = { true,  core.TSTRING },
	winonly   = { false, core.TBOOL,   false },
	hidden    = { false, core.TBOOL,   false },
	removes   = { false, core.TARRAY( core.TIDIN("medals") ) },
	condition = { false, core.TFUNC },
}

core.register_blueprint "badge"
{
	id        = { true,  core.TSTRING },
	name      = { true,  core.TSTRING },
	desc      = { true,  core.TSTRING },
	level     = { true,  core.TNUMBER },
}

core.register_blueprint "award_level"
{
	name      = { true, core.TSTRING },
	desc      = { true, core.TSTRING },
}

core.register_blueprint "award"
{
	id        = { true,  core.TSTRING },
	name      = { true,  core.TSTRING },
	module    = { true,  core.TSTRING },
	mname     = { true,  core.TSTRING },
	levels    = { true,  core.TARRAY("award_level") },
}

core.register_blueprint "affect"
{
	id             = { true,  core.TSTRING },
	name           = { true,  core.TSTRING },
	color          = { true,  core.TNUMBER },
	color_expire   = { true,  core.TNUMBER },
	message_init   = { false, core.TSTRING },
	message_ending = { false, core.TSTRING },
	message_done   = { false, core.TSTRING },
	status_effect  = { false, core.TNUMBER },
	status_strength= { false, core.TNUMBER },

	OnAdd          = { false, core.TFUNC },
	OnTick         = { false, core.TFUNC },
	OnRemove       = { false, core.TFUNC },
}

core.register_blueprint "missile"
{
	id          = { true,  core.TSTRING },
	sound_id    = { false, core.TSTRING },
	ascii       = { false, core.TSTRING, "-" },
	color       = { true,  core.TNUMBER },
	coscolor    = { false, core.TTABLE },
	sprite      = { true,  core.TNUMBER },
	delay       = { true,  core.TNUMBER },
	miss_base   = { true,  core.TNUMBER },
	miss_dist   = { true,  core.TNUMBER },
	firedesc    = { false, core.TSTRING, "" },
	hitdesc     = { false, core.TSTRING, "" },
	maxrange    = { false, core.TNUMBER, 30 },
	flags       = { false, core.TFLAGS,  {} },
	range       = { false, core.TNUMBER, 0 },
	expl_delay  = { false, core.TNUMBER, 40 },
	expl_color  = { false, core.TNUMBER, RED },
	expl_flags  = { false, core.TFLAGS,  {} },
	ray_delay   = { false, core.TNUMBER, 0 },
	content     = { false, core.TIDIN("cells"), 0 },
}

core.register_blueprint "shotgun"
{
	id          = { true,  core.TSTRING },
	maxrange    = { true,  core.TNUMBER },
	range       = { false, core.TNUMBER, 0 },
	spread      = { true,  core.TNUMBER },
	reduce      = { true,  core.TNUMBER },
	damage      = { false, core.TNUMBER, 0 },
}


core.register_blueprint "ai"
{
	id          = { true,  core.TSTRING },
	states      = { true,  core.TMAP( core.TSTRING, core.TFUNC ) },

	OnCreate    = { true,  core.TFUNC },
	OnAttacked  = { true,  core.TFUNC },
}

core.register_blueprint "being"
{
	name        = { true,  core.TSTRING },
	name_plural = { false, core.TSTRING },
	id          = { false, core.TSTRING },
	sound_id    = { false, core.TIDIN("beings") },
	ascii       = { true,  core.TSTRING },
	color       = { true,  core.TNUMBER },
	sprite      = { true,  core.TNUMBER  },
	coscolor    = { false, core.TTABLE },
	glow        = { false, core.TTABLE },
	overlay     = { false, core.TTABLE },
	hp          = { false, core.TNUMBER , 10 },
	armor       = { false, core.TNUMBER , 0 },
	attackchance= { false, core.TNUMBER , 75 },
	todam       = { false, core.TNUMBER , 0 },
	tohit       = { false, core.TNUMBER , 0 },
	tohitmelee  = { false, core.TNUMBER , 0 },
	speed       = { false, core.TNUMBER , 100 },
	vision      = { false, core.TNUMBER , 0 },
	min_lev     = { true,  core.TNUMBER },
	max_lev     = { false, core.TNUMBER , 10000 },
	corpse      = { false, core.TANY, 0 },
	danger      = { true,  core.TNUMBER },
	weight      = { true,  core.TNUMBER },
	xp          = { false, core.TNUMBER },
	bulk        = { false, core.TNUMBER , 100 },
	flags       = { false, core.TFLAGS, {} },
	ai_type     = { true,  core.TSTRING }, -- TIDIN("ais")
	is_group    = false,
	resist      = { false, core.TTABLE },

	desc            = { true,  core.TSTRING },
	kill_desc       = { false, core.TSTRING },
	kill_desc_melee = { false, core.TSTRING },

	weapon = { false, core.TANY },

	OnCreate     = { false, core.TFUNC },
	OnAction     = { false, core.TFUNC },
	OnAttacked   = { false, core.TFUNC },
	OnDie        = { false, core.TFUNC },
	OnDieCheck   = { false, core.TFUNC },
	OnPickupItem = { false, core.TFUNC },
}

core.register_blueprint "being_group_entry"
{
	being  = { true,  core.TIDIN("beings") },
	amount = { false, core.TANY },
}

core.register_blueprint "being_group"
{
	min_lev  = { false, core.TNUMBER, 0 },
	max_lev  = { false, core.TNUMBER, 10000 },
	weight   = { true,  core.TNUMBER },
	beings   = { true,  core.TARRAY("being_group_entry") },
	is_group = true,
}

core.register_blueprint "cell"
{
	name       = { true,  core.TSTRING },
	blname     = { false, core.TSTRING, "" },
	id         = { false, core.TSTRING },
	ascii      = { true,  core.TSTRING },
	asciilow   = { false, core.TSTRING },
	sprite     = { true,  core.TNUMBER },
	blsprite   = { false, core.TNUMBER },
	color      = { false, core.TNUMBER, LIGHTGRAY },
	coscolor   = { false, core.TTABLE },
	color_dark = { false, core.TNUMBER, DARKGRAY },
	color_id   = { false, core.TIDIN("cells") },
	blcolor    = { false, core.TNUMBER, 0 },
	armor      = { false, core.TNUMBER, 0 },
	flags      = { false, core.TFLAGS, {} },
	bloodto    = { false, core.TIDIN("cells"), "" },
	destroyto  = { false, core.TIDIN("cells"), "" },
	raiseto    = { false, core.TIDIN("beings"), "" },
	hp         = { false, core.TNUMBER },
	set        = { false, core.TNUMBER },

	OnEnter    = { false, core.TFUNC },
	OnExit     = { false, core.TFUNC },
	OnAct      = { false, core.TFUNC },
	OnDescribe = { false, core.TFUNC },
	OnDestroy  = { false, core.TFUNC },
}

core.register_blueprint "challenge"
{
	id            = { true,  core.TSTRING },
	name          = { true,  core.TSTRING },
	entryitem     = { false, core.TIDIN("items") },
	description   = { true,  core.TSTRING },
	rating        = { true,  core.TSTRING },
	rank          = { true,  core.TNUMBER },
	abbr          = { true,  core.TSTRING },
	let           = { true,  core.TSTRING },
	removemedals  = { false, core.TARRAY( core.TIDIN("medals") ) },
	win_mortem    = { false, core.TSTRING },
	win_highscore = { false, core.TSTRING },

	secondary        = { false, core.TTABLE },
	arch_name        = { false, core.TSTRING },
	arch_description = { false, core.TSTRING },
	arch_rating      = { false, core.TSTRING },
	arch_rank        = { false, core.TNUMBER },

	OnCreate         = { false, core.TFUNC },
	OnDie            = { false, core.TFUNC },
	OnDieCheck       = { false, core.TFUNC },
	OnPickup         = { false, core.TFUNC },
	OnPickupCheck    = { false, core.TFUNC },
	OnUse            = { false, core.TFUNC },
	OnUseCheck       = { false, core.TFUNC },
	OnKill           = { false, core.TFUNC },
	OnKillAll        = { false, core.TFUNC },
	OnEnter          = { false, core.TFUNC },
	OnFire           = { false, core.TFUNC },
	OnFired          = { false, core.TFUNC },
	OnExit           = { false, core.TFUNC },
	OnTick           = { false, core.TFUNC },
	OnCompletedCheck = { false, core.TFUNC },
	OnLoad           = { false, core.TFUNC },
	OnLoaded         = { false, core.TFUNC },
	OnUnLoad         = { false, core.TFUNC },
	OnCreatePlayer   = { false, core.TFUNC },
	OnLevelUp        = { false, core.TFUNC },
	OnPreLevelUp     = { false, core.TFUNC },
	OnWinGame        = { false, core.TFUNC },
	OnMortem         = { false, core.TFUNC },
	OnMortemPrint    = { false, core.TFUNC },
	OnCreateEpisode  = { false, core.TFUNC },
	OnLoadBase       = { false, core.TFUNC },
	OnIntro          = { false, core.TFUNC },
	OnGenerate       = { false, core.TFUNC },
}

core.register_blueprint "mod_array"
{
	id           = { true,  core.TSTRING },
	name         = { true,  core.TSTRING },
	mods         = { true,  core.TTABLE},
	desc         = { false, core.TSTRING },
	request_id   = { false, core.TIDIN("items") },
	request_type = { false, core.TNUMBER },
	level        = { false, core.TNUMBER, 0 },

	OnApply      = { true,  core.TFUNC },
	Match        = { false,  core.TFUNC },
}

core.register_blueprint "item"
{
	id             = { false, core.TSTRING },
	name           = { true, core.TSTRING },
	overlay        = { false, core.TTABLE },
	color          = { false, core.TNUMBER, LIGHTGRAY },
	color_id       = { false, core.TANY },
	sprite         = { true, core.TNUMBER },
	coscolor       = { false, core.TTABLE },
	glow           = { false, core.TTABLE },
	level          = { false, core.TNUMBER, 0 },
	weight         = { true, core.TNUMBER },
	set            = { false, core.TIDIN("itemsets") },
	flags          = { false, core.TFLAGS, {} },
	rechargeamount = { false, core.TNUMBER, 1 },
	rechargedelay  = { false, core.TNUMBER, 5 },
	rechargelimit  = { false, core.TNUMBER, 0 },
	firstmsg       = { false, core.TSTRING },
	resist         = { false, core.TTABLE },

	type        = {{
		[ITEMTYPE_ARMOR] = {
			ascii      = { false, core.TSTRING, "[" },
			desc       = { true,  core.TSTRING },
			armor      = { true,  core.TNUMBER },
			durability = { false, core.TNUMBER, 100 },
			movemod    = { false, core.TNUMBER, 0 },
			dodgemod   = { false, core.TNUMBER, 0 },
			knockmod   = { false, core.TNUMBER, 0 },
		},
		[ITEMTYPE_BOOTS] = {
			ascii      = { false, core.TSTRING, ";" },
			desc       = { true,  core.TSTRING },
			armor      = { true,  core.TNUMBER },
			durability = { false, core.TNUMBER, 100 },
			movemod    = { false, core.TNUMBER, 0 },
			dodgemod   = { false, core.TNUMBER, 0 },
			knockmod   = { false, core.TNUMBER, 0 },
		},
		[ITEMTYPE_PACK]   = {
			ascii      = { false, core.TSTRING, "+" },
			desc       = { true,  core.TSTRING },
			mod_letter = { false, core.TSTRING },
			dis_exotic = { false, core.TBOOLEAN, false },
			dis_unique = { false, core.TBOOLEAN, false },
			dis_other  = { false, core.TBOOLEAN, false },
			OnUse      = { true,  core.TFUNC },
		},
		[ITEMTYPE_POWER]   = {
			ascii    = { false, core.TSTRING, "^" },
			slevel   = { false, core.TNUMBER },
			OnPickup = { true, core.TFUNC },
		},
		[ITEMTYPE_AMMO]   = {
			ascii   = { false, core.TSTRING, "|" },
			desc    = { true, core.TSTRING },
			ammo    = { true, core.TNUMBER },
			ammomax = { true, core.TNUMBER  },
		},
		[ITEMTYPE_AMMOPACK] = {
			ascii   = { false, core.TSTRING, "!" },
			desc    = { true, core.TSTRING },
			ammo    = { true, core.TNUMBER  },
			ammomax = { true, core.TNUMBER  },
			ammo_id = { true, core.TSTRING  },
		},
		[ITEMTYPE_RANGED] = {
			ascii         = { false, core.TSTRING, "}" },
			sound_id      = { false, core.TID },
			psprite       = { true, core.TNUMBER },
			desc          = { true, core.TSTRING },
			group         = { true, core.TSTRING },
			ammomax       = { true, core.TNUMBER },
			ammo_id       = { true, core.TIDIN("items") },
			damage        = { true, core.TSTRING },
			damagetype    = { true, core.TNUMBER },
			acc           = { false, core.TNUMBER, 0 },
			fire          = { false, core.TNUMBER, 10 },
			radius        = { false, core.TNUMBER, 0 },
			reload        = { false, core.TNUMBER, 10 },
			shots         = { false, core.TNUMBER, 0 },
			shotcost      = { false, core.TNUMBER, 0 },
			altfire       = { false, core.TNUMBER, 0 },
			altreload     = { false, core.TNUMBER, 0 },
			altfirename   = { false, core.TSTRING },
			altreloadname = { false, core.TSTRING },
			overcharge    = { false, core.TIDIN("missiles") },
			scavenge      = { false, core.TARRAY(core.TIDIN("items")) },
			missile       = { true, core.TANY }, -- TODO core.TMISSILE
		},
		[ITEMTYPE_NRANGED] = {
			ascii      = { false, core.TSTRING, "?" },
			sound_id   = { false, core.TID },
			group      = { false, core.TSTRING },
			damage     = { true, core.TSTRING },
			damagetype = { true, core.TNUMBER },
			acc        = { false, core.TNUMBER, 0 },
			fire       = { false, core.TNUMBER, 10 },
			radius     = { false, core.TNUMBER, 0 },
			shots      = { false, core.TNUMBER, 0 },
			missile    = { true, core.TANY }, 
		},
		[ITEMTYPE_MELEE]  = {
			ascii       = { false, core.TSTRING, "\\" },
			sound_id    = { false, core.TSTRING },
			psprite     = { true, core.TNUMBER },
			group       = { true, core.TSTRING },
			desc        = { true, core.TSTRING },
			damage      = { true, core.TSTRING },
			damagetype  = { true, core.TNUMBER },
			acc         = { false, core.TNUMBER, 0 },
			fire        = { false, core.TNUMBER, 10 },
			altfire     = { false, core.TNUMBER, 0 },
			altfirename = { false, core.TSTRING },
			missile     = { false, core.TANY, 0 }, 
			throw_id    = { false, core.TIDIN("missiles") },
		},
		[ITEMTYPE_LEVER] = {
			ascii      = { false, core.TSTRING, "&" },
			sound_id   = { false, core.TSTRING, core.TIDIN("items") },
			color_id   = { true,  core.TANY },
			good       = { true,  core.TSTRING },
			desc       = { true,  core.TSTRING },
			warning    = { false, core.TSTRING },
			fullchance = { false, core.TNUMBER },
		},
		[ITEMTYPE_TELE] = {
			ascii   = { false, core.TSTRING, "*" },
			OnEnter = { true, core.TFUNC },
		},
	}},

	OnCreate      = { false, core.TFUNC },
	OnPickup      = { false, core.TFUNC },
	OnFirstPickup = { false, core.TFUNC },
	OnPickupCheck = { false, core.TFUNC },
	OnUse         = { false, core.TFUNC },
	OnUseCheck    = { false, core.TFUNC },
	OnReload      = { false, core.TFUNC },
	OnAltFire     = { false, core.TFUNC },
	OnAltReload   = { false, core.TFUNC },
	OnEquip       = { false, core.TFUNC },
	OnEquipTick   = { false, core.TFUNC },
	OnEquipCheck  = { false, core.TFUNC },
	OnRemove      = { false, core.TFUNC },
	OnKill        = { false, core.TFUNC },
	OnHitBeing    = { false, core.TFUNC },
	OnEnter       = { false, core.TFUNC },
	OnFired       = { false, core.TFUNC },
	OnFire        = { false, core.TFUNC },

}

core.register_blueprint "itemset"
{
	id        = { true,  core.TSTRING },
	name      = { true,  core.TSTRING },
	trigger   = { true,  core.TNUMBER },

	OnEquip   = { true,  core.TFUNC },
	OnRemove  = { true,  core.TFUNC },
}

core.register_blueprint "level"
{
	id            = { true,  core.TSTRING },
	name          = { true,  core.TSTRING },
	entry         = { false, core.TSTRING },
	welcome       = { false, core.TSTRING },
	level         = { false, core.TANY },

	Create           = { true,  core.TFUNC },
	canGenerate      = { false, core.TFUNC },
	OnRegister       = { false, core.TFUNC },

	OnCreate         = { false, core.TFUNC },
	OnDie            = { false, core.TFUNC },
	OnDieCheck       = { false, core.TFUNC },
	OnPickup         = { false, core.TFUNC },
	OnPickupCheck    = { false, core.TFUNC },
	OnUse            = { false, core.TFUNC },
	OnUseCheck       = { false, core.TFUNC },
	OnKill           = { false, core.TFUNC },
	OnKillAll        = { false, core.TFUNC },
	OnEnter          = { false, core.TFUNC },
	OnFire           = { false, core.TFUNC },
	OnFired          = { false, core.TFUNC },
	OnExit           = { false, core.TFUNC },
	OnTick           = { false, core.TFUNC },
	OnCompletedCheck = { false, core.TFUNC },
	OnNuked          = { false, core.TFUNC },
}

core.register_blueprint "event"
{
	id         = { true,  core.TSTRING },
	min_dlevel = { false, core.TNUMBER, 0 },
	weight     = { true,  core.TNUMBER },
	min_diff   = { false, core.TNUMBER, 0 },
	history    = { false, core.TSTRING },
	message    = { false, core.TSTRING },
	setup      = { true,  core.TFUNC },
}

core.register_blueprint "room"
{
	id          = { true,  core.TSTRING },
	weight      = { true,  core.TNUMBER },
	min_size    = { false, core.TNUMBER, 4 },
	max_size_x  = { false, core.TNUMBER, 100 },
	max_size_y  = { false, core.TNUMBER, 100 },
	max_area    = { false, core.TNUMBER },
	no_monsters = { false, core.TBOOL, true },
	class       = { false, core.TSTRING, "any" },
	setup       = { true,  core.TFUNC },
}

