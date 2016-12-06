function DoomRL.load_difficulty()

	register_difficulty	"ITYTD" 
	{
		name        = "I'm Too Young To Die!",
		description = "He was too young to die!",
		code        = "@GE",
		tohitbonus  = -1,
		expfactor   = 1.4,
		scorefactor = 0.5,
		ammofactor  = 2,
		powerfactor = 2,
		challenge   = false,
	}

	register_difficulty	"HNTR" 
	{
		name        = "Hey, Not Too Rough",
		id          = "HNTR",
		description = "He didn't like it too rough.",
		code        = "@BM",
		expfactor   = 1.2,
	}

	register_difficulty	"HMP" 
	{
		name        = "Hurt Me Plenty",
		description = "He wasn't afraid to be hurt plenty.",
		code        = "@RH",
		scorefactor = 1.5,
		ammofactor  = 1.25,
	}

	register_difficulty	"UV" 
	{
		name        = "Ultra-Violence",
		description = "He was a man of Ultra-Violence!",
		code        = "@yU",
		tohitbonus  = 2,
		scorefactor = 2,
		ammofactor  = 1.5,
		req_skill   = 2,
	}

	register_difficulty	"N!" 
	{
		name        = "Nightmare!",
		description = "He opposed the Nightmare!",
		code        = "@rN",
		tohitbonus  = 2,
		expfactor   = 1.2,
		scorefactor = 4,
		ammofactor  = 2,
		powerfactor = 2,
		powerbonus  = 1.25,
		respawn     = true,
		req_skill   = 4,
		speed       = 1.5,
	}

end
