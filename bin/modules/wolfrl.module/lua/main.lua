core.declare( "DoomRL", {} )

require( "doomrl:generator" )
require( "doomrl:generators" )
require( "doomrl:rooms" )
require( "doomrl:events" )
require( "doomrl:sprites" )
require( "doomrl:difficulty" )
require( "doomrl:affects" )
require( "doomrl:medals" )
require( "doomrl:missiles" )
require( "doomrl:cells" )
require( "doomrl:traits" )
require( "doomrl:ai" )
require( "doomrl:beings" )
require( "doomrl:ranks" )
require( "doomrl:plot" )
require( "doomrl:challenge" )
require( "doomrl:score" )
require( "doomrl:mod_arrays" )
require( "doomrl:klass" )

require( "doomrl:items/items" )
require( "doomrl:items/ammo" )
require( "doomrl:items/weapons" )

require( "doomrl:levels/ep1_main" )
require( "doomrl:levels/ep2_main" )
require( "doomrl:levels/ep3_main" )
require( "doomrl:levels/ep4_main" )
require( "doomrl:levels/ep5_main" )
require( "doomrl:levels/ep6_main" )
require( "doomrl:levels/ep7_main" )


-- main DoomRL lua script file --
core.declare( "STYLE_WHITE"  , 1);
core.declare( "STYLE_RED"    , 2);
core.declare( "STYLE_BLUE"   , 3);
core.declare( "STYLE_GREEN"  , 4);
core.declare( "STYLE_PURPLE" , 5);
core.declare( "STYLE_BROWN"  , 6);
core.declare( "STYLE_CYAN"   , 7);
core.declare( "STYLE_DARK"   , 8);
core.declare( "STYLE_HELL"   , 9);
core.declare( "STYLE_BLAKE"  , 10);


function DoomRL.OnLoaded()
	ui.msg('Welcome to the @YWolfenstein@> the Roguelike...')
end

function DoomRL.OnLoadBase()
	DoomRL.load_difficulty()
	DoomRL.loadbasedata()
	DoomRL.loadaffects()
	DoomRL.loadmissiles()
	DoomRL.loadcells()
	DoomRL.loadammo()
	DoomRL.loadweapons()
	DoomRL.loaditems()
	DoomRL.loadnpcs()
	DoomRL.load_ranks()
	DoomRL.load_traits()
	DoomRL.loadmedals()
	DoomRL.load_mod_arrays()
	DoomRL.loadepisode1()
	DoomRL.loadepisode2()
	DoomRL.loadepisode3()
	DoomRL.loadepisode4()
	DoomRL.loadepisode5()
	DoomRL.loadepisode6()
	DoomRL.loadchallenges()
	DoomRL.load_klasses()

	DoomRL.load_generators()
	DoomRL.load_events()
	DoomRL.load_rooms()

	generator.styles = {
		{ floor = "floor", wall = "wolf_whwall", flairdoor = { "wolf_flrflag1"                        }, flaircorner = { "wolf_flrflag1"                  }, flairwall = { "wolf_flrpicture1"                     }, door = "door",   odoor = "odoor"   }, --STYLE_WHITE
		{ floor = "floor", wall = "wolf_rewall", flairdoor = { "wolf_flrwreath"                       }, flaircorner = { "wolf_flrtapestry"               }, flairwall = { "wolf_flrpicture1", "wolf_flrpicture2" }, door = "door",   odoor = "odoor"   }, --STYLE_RED
		{ floor = "floor", wall = "wolf_blwall", flairdoor = { "wolf_flrsign1", "wolf_flrsign2"       }, flaircorner = { },                                  flairwall = { "wolf_flrcell1", "wolf_flrcell2"       }, door = "door",   odoor = "odoor"   }, --STYLE_BLUE
		{ floor = "floor", wall = "wolf_grwall", flairdoor = { "wolf_flrflag2"                        }, flaircorner = { },                                  flairwall = { "wolf_flrivy"                          }, door = "door",   odoor = "odoor"   }, --STYLE_GREEN
		{ floor = "floor", wall = "wolf_puwall", flairdoor = { },                                        flaircorner = { },                                  flairwall = { "blood"                                }, door = "mdoor2", odoor = "omdoor2" }, --STYLE_PURPLE (perm doors no flair)
		{ floor = "floor", wall = "wolf_brwall", flairdoor = { "wolf_flrpicture1", "wolf_flrpicture2" }, flaircorner = { "wolf_flrflag1", "wolf_flrcross" }, flairwall = { "wolf_flrglass"                        }, door = "door",   odoor = "odoor"   }, --STYLE_BROWN
		{ floor = "floor", wall = "wolf_cywall", flairdoor = { "wolf_flrsign1", "wolf_flrsign2"       }, flaircorner = { },                                  flairwall = { }                                       , door = "mdoor1", odoor = "omdoor1" }, --STYLE_CYAN (perm doors)
		{ floor = "floor", wall = "wolf_dkwall", flairdoor = { "wolf_flrtapestry", "wolf_flrwreath"   }, flaircorner = { "wolf_flrflag2",                 }, flairwall = { }                                       , door = "mdoor1", odoor = "omdoor1" }, --STYLE_DARK
		{ floor = "floor", wall = "wolf_bdwall", flairdoor = { "wolf_flrsign1", "wolf_flrsign2"       }, flaircorner = { },                                  flairwall = { "blood"                                }, door = "mdoor1", odoor = "omdoor1" }, --STYLE_HELL (last level only no flair)
		{ floor = "floor", wall = "wolf_otwall", flairdoor = { "wolf_flrsign1", "wolf_flrsign2"       }, flaircorner = { },                                  flairwall = { }                                       , door = "mdoor1", odoor = "omdoor1" }, --STYLE_BLAKE (one special level only no flair)
	}
end

function DoomRL.OnLoad()
	DoomRL.registerlevels()
end

function DoomRL.OnDisassemble( it )
	local modlist = {"wolf_mod_agility","wolf_mod_bulk","wolf_mod_tech","wolf_mod_power"}
	if it.__proto.scavenge then
		modlist = it.__proto.scavenge
	elseif it.flags[IF_EXOTIC] then
		modlist = {"wolf_mod_agility","wolf_mod_bulk","wolf_mod_tech","wolf_mod_power","wolf_umod_firestorm","wolf_umod_sniper"}
	elseif it.flags[IF_UNIQUE] then
		modlist = {"wolf_umod_firestorm","wolf_umod_firestorm","wolf_umod_sniper","wolf_umod_sniper","wolf_umod_onyx","wolf_umod_nano"}
	else
		local mods = it:get_mod_ids()
		if #mods > 0 then
			modlist = mods 
		end
	end
	return table.random_pick( modlist )
end

function DoomRL.a_an( v )
	if string.find(v, '^[aeiou]') then return 'an' else return 'a' end
end

function DoomRL.get_result_id()
	local result    = "unknown"
	local dead      = player.hp <= 0
	local won       = player:has_won()
	local nuked     = level.flags[ LF_NUKED ]
	local beatangel = won and kills.get("wolf_bossangel") > 0 and not dead

	if won then
		if beatangel and not dead then
			result = "final"
		elseif nuked then
			result = "sacrifice"
		else
			result = "win"
		end
	elseif nuked then
		result = "nuke"
	elseif player.killedby == player.id then
		result = "suicide"
	elseif beings[ player.killedby ] then
		result = "killed"
	end
	return result
end

function DoomRL.get_short_result_id( result, depth )
	if result == "win" or result == "final" or result == "sacrifice" then return result end
	return "level:"..depth
end

function DoomRL.get_result_description( result, highscore )
	local killed_by = "was killed by something"

	    if result == "win"   then killed_by = "captured the Spear"
	elseif result == "final" then killed_by = "captured and returned the Spear"
	elseif result == "nuke"  then killed_by = "blew himself up"
	elseif result == "sacrifice" then
		if highscore then killed_by = "won by sacrifice" else killed_by = "collapsed the castle on top of the Spear" end
	elseif result == "suicide" then
		if highscore then killed_by = "committed suicide" else killed_by = "foolishly killed himself" end
	elseif result == "killed" then
		local killer = beings[ player.killedby ]
		if killer then
			if not highscore then
				if player.killedmelee then
					killed_by = killer.kill_desc_melee 
				else
					killed_by = killer.kill_desc
				end
			end
			if highscore or not killed_by then
				killed_by = 'killed by '.. DoomRL.a_an(killer.name)..' '..killer.name
			end
		end
	end

	if player:has_won() then
		local chal_idx  = "win_mortem"
		if highscore then chal_idx = "win_highscore" end
		if SCHALLENGE ~= '' and chal[ SCHALLENGE ][ chal_idx ] then
			killed_by = chal[ SCHALLENGE ][ chal_idx ]
		elseif CHALLENGE ~= '' and chal[ CHALLENGE ][ chal_idx ] then
			killed_by = chal[ CHALLENGE ][ chal_idx ]
		end
	end

	return killed_by
end

function DoomRL.print_mortem()
	local result_id    = DoomRL.get_result_id()
	local death_reason = DoomRL.get_result_description( result_id, false )
	local function version_string( v )
		local result = v[1].."."..v[2].."."..v[3]
		if v[4] then result = result.."."..v[4] end
		return result
	end

	local game_type      = core.game_type()
	local game_module    = nil


	player:mortem_print( "--------------------------------------------------------------" )
	player:mortem_print( " WolfRL ("..VERSION_STRING..") roguelike post-mortem character dump")
	if game_type ~= GAMESTANDARD then
		player:mortem_print( " Module : "..module.name.." ("..version_string(module.version)..")")
		game_module = _G[module.id]
	end
	player:mortem_print( "--------------------------------------------------------------" )
	player:mortem_print()

	if game_module and game_module.print_mortem then
		game_module.print_mortem()
		return
	end

	if game_type == GAMESTANDARD then
		local player_description = "level "..player.explevel.." "
			..exp_ranks[player.exprank + 1].name.." "..skill_ranks[player.skillrank + 1].name
			.." "..klasses[player.klass].name..","
		if string.len(player.name) <= 12 then
			player:mortem_print(" "..player.name..", "..player_description)
		else
			player:mortem_print(" "..player.name..",")
			player:mortem_print(" "..player_description)
		end
		local epi_name = player.episode[player.depth].deathname or player.episode[player.depth].name or "a Unknown Location"
		local depth    = player.episode[player.depth].number or 0
		if depth ~= 0 then
			player:mortem_print( " "..death_reason.." on level "..depth.." of "..epi_name.."." )
		else
			player:mortem_print( " "..death_reason.." at "..epi_name.."." )
		end
	else
		if game_module.OnMortemPrint then
			game_module.OnMortemPrint(death_reason)
		else
			player:mortem_print( " "..player.name..", level "..player.explevel.." "
		.." "..klasses[player.klass].name..", "..death_reason )
			player:mortem_print(" in a custom location...")
		end
	end

	player:mortem_print( " He survived "..statistics.game_time.." turns and scored "..player.score.." points. ")
	player:mortem_print( " He played for "..seconds_to_string(math.floor(statistics.real_time))..". ")
	player:mortem_print( " "..diff[DIFFICULTY].description)
	player:mortem_print()

	local ratio = statistics.kills / statistics.max_kills

	player:mortem_print( " He killed "..statistics.kills.." out of "..statistics.max_kills.." enemies. ("..math.floor(ratio*100).."%)" )

	    if statistics.kills == statistics.max_kills then
		player:mortem_print( " This ass-kicking soldier killed all of them!" )
	elseif statistics.kills == 0 and player:has_won() then
		player:mortem_print( " How did a pacifist win without a single kill?" )
	elseif statistics.kills == 0 then
		player:mortem_print( " Poor pacifist, didn't even get a single kill..." )
	elseif ratio < 0.1    then
		player:mortem_print( " My, was he a wimpy chump." )
	elseif ratio < 0.3    then
		player:mortem_print( " Who put him on the front lines anyway?" )
	elseif ratio > 0.999  then
		player:mortem_print( " A natural born killer!" )
	elseif ratio > 0.99   then
		player:mortem_print( " He was a real killing machine..." )
	elseif ratio > 0.9    then
		player:mortem_print( " He held his right to remain violent." )
	end

	--This is tricky; we don't actually count the episodes as challenges which affects our grammar
	local challenge1
	local challenge2
	if DoomRL.isepisode() then
		challenge1 = SCHALLENGE
		challenge2 = ""
	else
		challenge1 = CHALLENGE
		challenge2 = SCHALLENGE
	end

	if ARCHANGEL then
		player:mortem_print( " He was " .. DoomRL.a_an(chal[challenge1].arch_name) .. " " ..chal[challenge1].arch_name.."!")
	elseif challenge1 ~= "" then
		player:mortem_print( " He was " .. DoomRL.a_an(chal[challenge1].name) .. " "..chal[challenge1].name.."!")
	end
	if challenge2 ~= "" then
		player:mortem_print( " He was also " .. DoomRL.a_an(chal[challenge2].name) .. " "..chal[challenge2].name.."!")
	end

	local function times( n )
		if n <= 1 then return "once" else return n.." times" end
	end

	if statistics.save_count > 0 or statistics.crash_count > 0 then
		player:mortem_print()
		if statistics.crash_count > 0 then
			player:mortem_print(" The world crashed on him "..times( statistics.crash_count ).."." )
		end
		if statistics.save_count > 0 then
			player:mortem_print(" He saved himself "..times( statistics.save_count )..".")
		end
	end
	player:mortem_print()

	if game_type == GAMESTANDARD then
		player:mortem_print("-- Special levels --------------------------------------------")
		player:mortem_print()
		player:mortem_print("  Levels generated : "..statistics.bonus_levels_count )
		player:mortem_print("  Levels visited   : "..statistics.bonus_levels_visited )
		player:mortem_print("  Levels completed : "..statistics.bonus_levels_completed )
		player:mortem_print()
	end

	-- TODO Is it possible to identify all awards this run would have returned and mark those that *were* given?
	local awarded = false
	local new_awarded = false
	player:mortem_print("-- Awards ----------------------------------------------------")
	player:mortem_print()

	if game_type == GAMESTANDARD then
		for k,v in ipairs( medals ) do
			if player:has_medal( v.id ) then
				player:mortem_print( "  "..v.name )
				awarded = true
			end
		end

		for k,v in ipairs( badges ) do
			if player:has_badge( v.id ) then
				player:mortem_print( "  "..v.name )
				awarded = true
			end
		end

		if not awarded then
			player:mortem_print("  None")
		end
		player:mortem_print()
	end

	local function get_pic( c )
		local being = level:get_being( c )
		if being then
			if being:is_player() then return 'X' end
			return string.char(being.picture)
		end
		local item = level:get_item( c )
		if item then
			return string.char(item.picture)
		end
		local cell = generator.get_cell( c )
		return cells[ cell ].asciilow
	end

	player:mortem_print( "-- Graveyard -------------------------------------------------")
	player:mortem_print()
	for vy = 1,MAXY do
		local line = "  "
		for vx = math.min( 20, math.max( 1,player.x - 30 ) ), math.min( 20, math.max(1,player.x - 30 ) ) + MAXX - 20 do
			line = line..get_pic( coord.new( vx, vy ) )
		end
		player:mortem_print( line )
	end
	player:mortem_print()

	local function bonus( val ) if val < 0 then return ""..val else return "+"..val end end

	player:mortem_print( "-- Statistics ------------------------------------------------" )
	player:mortem_print()
	player:mortem_print( "  Health "..player.hp.."/"..player.hpmax.."   Experience "..player.exp.."/"..player.explevel )
	player:mortem_print("  ToHit Ranged "..bonus( player.tohit )..
						"  ToHit Melee "..bonus( player.tohitmelee + player.tohit )..
						"  ToDmg Ranged "..bonus( player.todamall )..
						"  ToDmg Melee "..bonus( player.todamall + player.todam ) )
	player:mortem_print()
	player:mortem_print( "-- Traits ----------------------------------------------------" )
	player:mortem_print()
	player:mortem_print( "  Class : "..klasses[player.klass].name )
	player:mortem_print()

	local function padded( str, size )
		return str..string.rep(" ",math.max(0,size - string.len(str)) )
	end

	for i = 1,traits.__counter do
		local value = player:get_trait(i)
		if value > 0 then
			player:mortem_print( "    "..padded(traits[i].name,16).." (Level "..value..")" )
		end
	end

	if player.explevel > 1 then
		player:mortem_print()
		player:mortem_print("  "..player:get_trait_hist() )
	end
	player:mortem_print()

	local function letter( n ) return string.char(string.byte("a")+n) end

	player:mortem_print( "-- Equipment -------------------------------------------------" )
	player:mortem_print()

	local slot_name = { "[ Armor      ]", "[ Weapon     ]", "[ Boots      ]", "[ Prepared   ]" }

	for i = 0,MAX_EQ_SIZE-1 do
		local it = player.eq[i]
		if it then
			player:mortem_print( "    ["..letter(i).."] "..slot_name[i+1].."   "..it.desc )
		else
			player:mortem_print( "    ["..letter(i).."] "..slot_name[i+1].."   nothing" )
		end
	end

	player:mortem_print()
	player:mortem_print( "-- Inventory -------------------------------------------------" )
	player:mortem_print()

	local items = {}

	for it in player.inv:items() do
		table.insert( items, { itype = it.itype, nid = it.__proto.nid, desc = it.desc } )
	end

	table.sort( items, function(a,b) if (a.itype ~= b.itype) then return a.itype < b.itype else return a.nid < b.nid end end )

	for k,v in ipairs(items) do
		player:mortem_print( "    ["..letter(k-1).."] "..v.desc )
	end

	local resistance_present = false
	local function print_resistance( name )
		local internal = player.resist[name] or 0
		local torso    = player:get_total_resistance(name, TARGET_TORSO)
		local feet     = player:get_total_resistance(name, TARGET_FEET)
		if internal == 0 and torso == 0 and feet == 0 then return end
		player:mortem_print( "    "..padded( name, 10 ).." - "..
		"internal "..padded( internal.."%", 5 ).." "..
		"torso "..padded( torso.."%", 5 ).." "..
		"feet "..padded( feet.."%", 5 )
		)
		resistance_present = true
	end

	player:mortem_print()
	player:mortem_print( "-- Resistances -----------------------------------------------" )
	player:mortem_print()
	print_resistance( "bullet" )
	print_resistance( "melee" )
	print_resistance( "shrapnel" )
	print_resistance( "acid" )
	print_resistance( "fire" )
	print_resistance( "plasma" )
	if not resistance_present then
		player:mortem_print("    None")
	end

	player:mortem_print()
	player:mortem_print( "-- Kills -----------------------------------------------------" )
	player:mortem_print()
	for _,b in ipairs( beings ) do
		local kills = kills.get(b.id)
		if kills > 0 then
			if kills == 1 then
				player:mortem_print( "    1 "..b.name )
			else
				player:mortem_print( "    "..kills.." "..b.name_plural )
			end
		end
	end
	player:mortem_print()

	player:mortem_print( "-- History ---------------------------------------------------" )
	player:mortem_print()
	for _,v in pairs( player.__props.history ) do
		player:mortem_print( "  "..v )
	end
	if game_type == GAMESTANDARD and not player:has_won() then
		player:mortem_print( "  On level "..player.depth.." he "..death_reason..".")
	end
	player:mortem_print()

	player:mortem_print( "-- Messages -------------------------------------------------- " )
	player:mortem_print()

	for i = 15,0,-1 do
		local msg = ui.msg_history(i)
		if msg then player:mortem_print( " ".. msg ) end
	end

	player:mortem_print()

	if game_type == GAMESTANDARD then
		--I do not have access to individual challenge deaths therefore this is a unified mortem for all episodes
		player:mortem_print( "-- General --------------------------------------------------- " )
		player:mortem_print()

		local deaths = player_data.count('player/deaths')
		if deaths > 1 then
			local function reason( id, desc )
				local count = player_data.count('player/deaths/death[@id="'..id..'"]')
				if count == 0 then return end
				if count > 1 then
					desc = desc:gsub( "@was", "were" )
				else
					desc = desc:gsub( "@was", "was" )
				end
				player:mortem_print( desc:gsub( "@1", count.."" ) )
			end
			player:mortem_print( " "..deaths.." brave souls have fought the German war machine:" )
			reason( "killed" ," @1 of those @was killed.")
			reason( "unknown"," @1 of those @was killed by something unknown." )
			reason( "nuke"   ," @1 didn't know that bombs explode." )
			reason( "suicide"," And @1 died from their own carelessness." )

			local types = { "Ep1","Ep2","Ep3","Ep4","Ep5","Ep6" }

			local sacrifice = {}
			local win       = {}
			local fullwin   = {}
			local wins      = 0
	
			sacrifice[7] = player_data.count('player/games/win[@id="sacrifice"]')
			win[7]       = player_data.count('player/games/win[@id="win"]')
			fullwin[7]   = player_data.count('player/games/win[@id="final"]')
			wins = wins + sacrifice[7] + win[7] + fullwin[7]
			for i=1,#types do
				sacrifice[i] = player_data.count('player/challenges/challenge[@id="'.. types[i] .. '"]/win[@id="sacrifice"]')
				win[i]       = player_data.count('player/challenges/challenge[@id="'.. types[i] .. '"]/win[@id="win"]')
				fullwin[i]   = player_data.count('player/challenges/challenge[@id="'.. types[i] .. '"]/win[@id="final"]')
				sacrifice[7] = sacrifice[7] - sacrifice[i]
				win[7]       = win[7]       - win[i]
				fullwin[7]   = fullwin[7]   - fullwin[i]
			end

			if wins > 0 then
				player:mortem_print()
				player:mortem_print(" "..wins.." souls completed their missions...")
				if sacrifice[1] > 0 then player:mortem_print(" "..sacrifice[1].." Ep1 suicide (should not be possible)" ) end
				if win[1]       > 0 then player:mortem_print(" "..win[1]..      " escaped from Castle Wolfenstein." ) end
				if fullwin[1]   > 0 then player:mortem_print(" "..fullwin[1]..  " Ep1 full win (should not be possible)" ) end
				if sacrifice[2] > 0 then player:mortem_print(" "..sacrifice[2].." Ep2 suicide (should not be possible)" ) end
				if win[2]       > 0 then player:mortem_print(" "..win[2]..      " defeated Dr. Schabbs." ) end
				if fullwin[2]   > 0 then player:mortem_print(" "..fullwin[2]..  " Ep2 full win (should not be possible)" ) end
				if sacrifice[3] > 0 then player:mortem_print(" "..sacrifice[3].." Ep3 suicide (should not be possible)" ) end
				if win[3]       > 0 then player:mortem_print(" "..win[3]..      " toppled Hitler's last stand." ) end
				if fullwin[3]   > 0 then player:mortem_print(" "..fullwin[3]..  " Ep3 full win (should not be possible)" ) end
				if sacrifice[4] > 0 then player:mortem_print(" "..sacrifice[4].." Ep4 suicide (should not be possible)" ) end
				if win[4]       > 0 then player:mortem_print(" "..win[4]..      " defeated Otto Giftmacher." ) end
				if fullwin[4]   > 0 then player:mortem_print(" "..fullwin[4]..  " Ep4 full win (should not be possible)" ) end
				if sacrifice[5] > 0 then player:mortem_print(" "..sacrifice[5].." Ep5 suicide (should not be possible)" ) end
				if win[5]       > 0 then player:mortem_print(" "..win[5]..      " infiltrated Castle Erlangen" ) end
				if fullwin[5]   > 0 then player:mortem_print(" "..fullwin[5]..  " Ep5 full win (should not be possible)" ) end
				if sacrifice[6] > 0 then player:mortem_print(" "..sacrifice[6].." Ep6 suicide (should not be possible)" ) end
				if win[6]       > 0 then player:mortem_print(" "..win[6]..      " defeated General Fettgesicht." ) end
				if fullwin[6]   > 0 then player:mortem_print(" "..fullwin[6]..  " Ep6 full win (should not be possible)" ) end
				if sacrifice[7] > 0 then player:mortem_print(" "..sacrifice[7].." buried the spear beneath a castle of rubble." ) end
				if win[7]       > 0 then player:mortem_print(" "..win[7]..      " reached the spear intact." ) end
				if fullwin[7]   > 0 then player:mortem_print(" "..fullwin[7]..  " escaped with the spear alive." ) end
			end
		else
			player:mortem_print("  He's the first soul to brave the front lines...")
		end
		player:mortem_print()
	end
	player:mortem_print( "-------------------------------------------------------------- " )
end

function DoomRL.registerlevels()
	for _,level_proto in ipairs(levels) do
		if level_proto.OnRegister then level_proto.OnRegister() end
	end
end

function DoomRL.loadbasedata()

	register_cell "bloodpool" {
		name = "pool of blood";
		ascii = "";
		asciilow = '.';
		color = RED;
		set = CELLSET_FLOORS;
		sprite = SPRITE_BLOODPOOL;
		flags = {CF_OVERLAY, CF_VBLOODY};
	}
	register_cell "corpse" {
		name = "bloody corpse";
		ascii = "%";
		color = RED;
		set = CELLSET_FLOORS;
		flags = {CF_OVERLAY, CF_NOCHANGE, CF_VBLOODY};
		destroyto = "bloodpool",
		sprite = SPRITE_CORPSE,
	}
	register_item "stubitem" {
		name     = "stubitem",
		color    = RED,
		sprite   = SPRITE_TELEPORT,
		weight   = 0,

		type = ITEMTYPE_TELE,

		OnEnter = function() end,
	}
	register_item "teleport" {
		name     = "teleport",
		color    = LIGHTCYAN,
		sprite   = SPRITE_TELEPORT,
		weight   = 0,
		flags    = { IF_NODESTROY, IF_NUKERESIST },

		type = ITEMTYPE_TELE,

		OnCreate = function( self )
			self:add_property( "target", false )
		end,

		OnEnter = function( self, being )
			if not self.target then
				self.target = generator.random_empty_coord{ EF_NOBEINGS, EF_NOITEMS, EF_NOSTAIRS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }
			end
			-- Explosions can have sounds, but by the time the sound plays, the player has already moved
			level:play_sound( core.resolve_sound_id( "teleport.use", "use" ), being.position )
			level:explosion( being.position, 4, 50, 0, 0, GREEN, 0 )
			being:msg( "You feel yanked away!", being:get_name(true,true).." suddenly disappears!" )
			local target = self.target
			local empty = { EF_NOBEINGS, EF_NOITEMS, EF_NOSTAIRS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }
			if cells[ level.map[ target ] ].flags[ CF_BLOCKMOVE ] then
				being:msg("You feel out of place!")
				being:apply_damage(15, TARGET_INTERNAL, DAMAGE_FIRE )
				target = generator.random_empty_coord( empty )
			end
			if level:get_being( target ) then
				local tgt = level:get_being( target )
				being:msg("Suddenly you feel weird!")
				tgt:msg("Argh! You feel like someone is trying to implode you!")
				if tgt:is_player() then 
					tgt:apply_damage(15, TARGET_INTERNAL, DAMAGE_FIRE )
					target = generator.random_empty_coord( empty )
				else
					tgt:kill() --I want a telefrag dammit.
				end
			end
			if being.__ptr then
				being:relocate( target )
				being:msg(nil,"Suddenly "..being:get_name(false,false).." appears out of nowhere!")
				being.scount = being.scount - 1000
			end
		end,
	}

	register_being "soldier" {
		name         = "soldier",
		ascii        = "@" ,
		color        = LIGHTGRAY,
		sprite       = SPRITE_PLAYER,
		min_lev      = 200,
		corpse       = "corpse",
		danger       = 0,
		weight       = 0,
		xp           = 0,
		flags        = { BF_OPENDOORS, BF_UNIQUENAME },
		desc         = "God made you in his image. The resemblance is uncanny.",
		ai_type      = "",

		OnCreate = function(self)
			self:add_property( "wolf_lives",  3 )
			self:add_property( "wolf_deaths", 0 )
			self:add_property( "wolf_score",  0 )
			self:add_property( "wolf_score_next", 10000 )
			self:add_property( "wolf_treasure1", 0 )
			self:add_property( "wolf_treasure2", 0 )
			self:add_property( "wolf_treasure3", 0 )
			self:add_property( "wolf_treasure4", 0 )
			self:add_property( "wolf_drankblood", false )

			self:add_property( "medals", {} )
			self:add_property( "badges", {} )
			self:add_property( "awards", {} )
			self:add_property( "assemblies", {} )
			self:add_property( "items_found", {} )
			self:add_property( "history", {} )
			self:add_property( "episode", {} )

			if rawget(_G,"DIFFICULTY") then
				self.hp    = 50
				self.hpmax = self.hp
				self.hpnom = self.hp
				self.scount = 4000 --Removes player's start delay on level 1
				self.expfactor = diff[DIFFICULTY].expfactor
			end
		end,

		--These stubs exist so that modders can hijack them properly
		OnAction   = function(self) return end,
		OnAttacked = function(self) return end,
		OnDie      = function(self, overkill) return end,
		OnDieCheck = function(self, overkill) return true end,

		OnPickupItem = function(self,i)
			if not self:has_found_item( i.id ) then
				if i.flags[ IF_UNIQUE ] then
					statistics.uniques_found = statistics.uniques_found + 1
					self:add_history( 'On level @1 he found the '..i.name..'!' )
					ui.blink( LIGHTGREEN, 20 )
				end
				if items[ i.id ].OnFirstPickup then
					items[ i.id ].OnFirstPickup( i, self )
				end
				self:add_found_item( i.id )
			end
		end,
	}
end

function DoomRL.generatePlayerInventory()
	--This may actually get called twice if two challenges are selected but that should take care of itself.
	player.inv:clear()
	player.eq:clear()

	    if (CHALLENGE == "challenge_inf" or SCHALLENGE == "challenge_inf") then
		--This has all sorts of fun divisions.
		    if (CHALLENGE == "challenge_ber" or SCHALLENGE == "challenge_ber") then
			player.eq.weapon = "wolf_knife"
			player.eq.armor = "wolf_armor2"
			player.inv:add( "wolf_lmed" )
			player.inv:add( "wolf_lmed" )
		elseif (CHALLENGE == "challenge_mark" or SCHALLENGE == "challenge_mark") then
			player.eq.weapon = "wolf_pistol4"
			player.inv:add("wolf_45acp", { ammo = 80 } )
			player.inv:add("wolf_45acp", { ammo = 80 } )
			player.inv:add("wolf_45acp", { ammo = 80 } )
			player.inv:add("wolf_lmed")
			player.inv:add("wolf_lmed")
		elseif (CHALLENGE == "challenge_shot" or SCHALLENGE == "challenge_shot") then
			player.eq.weapon = "wolf_shotgun"
			player.inv:add( "wolf_shell", { ammo = 50 } )
			player.inv:add( "wolf_lmed" )
			player.inv:add( "wolf_lmed" )
		else
			player.eq.weapon = "wolf_pistol1"
			if (player.klass == 1) then
				player.inv:add( "wolf_9mm", { ammo = 40 } )
			else
				player.inv:add( "wolf_9mm", { ammo = 20 } )
			end
			player.inv:add( "wolf_lmed" )
			player.inv:add( "wolf_lmed" )
		end
	elseif (CHALLENGE == "challenge_para" or SCHALLENGE == "challenge_para") then
		--This has all sorts of fun divisions too.
		    if (CHALLENGE == "challenge_ber" or SCHALLENGE == "challenge_ber") then
			player.eq.weapon = "wolf_knife"
			player.eq.armor = "wolf_armor2"
			player.inv:add( "wolf_knife" )
			player.inv:add( "wolf_lmed" )
			player.inv:add( "wolf_lmed" )
		elseif (CHALLENGE == "challenge_mark" or SCHALLENGE == "challenge_mark") then
			player.eq.weapon = "wolf_pistol4"
			player.eq.prepared = "wolf_pistol4"
			player.inv:add("wolf_45acp", { ammo = 80 } )
			player.inv:add("wolf_45acp", { ammo = 80 } )
			player.inv:add("wolf_45acp", { ammo = 80 } )
			player.inv:add("wolf_lmed")
			player.inv:add("wolf_lmed")
		elseif (CHALLENGE == "challenge_shot" or SCHALLENGE == "challenge_shot") then
			player.eq.weapon = "wolf_shotgun"
			player.eq.prepared = "wolf_dshotgun"
			player.inv:add( "wolf_shell", { ammo = 50 } )
			player.inv:add( "wolf_lmed" )
			player.inv:add( "wolf_lmed" )
		else
			player.eq.weapon = "wolf_semi1"
			player.eq.prepared = "wolf_pistol4"
			player.inv:add( "wolf_knife" )
			player.inv:add( "wolf_8mm", { ammo = 16 } )
			player.inv:add( "wolf_45acp", { ammo = 64 } )
			player.inv:add( "wolf_lmed" )
			player.inv:add( "wolf_lmed" )
		end
	elseif (CHALLENGE == "challenge_obj" or SCHALLENGE == "challenge_obj") then
		--Pacifism overrides everything that it can be paired with, which isn't as much as other tchallenges.
		player.eq.armor = "wolf_armor2"
		player.inv:add( "wolf_lmed" )
		player.inv:add( "wolf_lmed" )
		player.inv:add( "wolf_lmed" )
		player.inv:add( "wolf_lmed" )
	elseif (CHALLENGE == "challenge_ber" or SCHALLENGE == "challenge_ber") then
		player.eq.armor = "wolf_armor2"
		player.inv:add( "wolf_lmed" )
		player.inv:add( "wolf_lmed" )
	elseif (CHALLENGE == "challenge_mark" or SCHALLENGE == "challenge_mark") then
		player.eq.weapon = "wolf_pistol4"
		player.inv:add("wolf_45acp", { ammo = 80 } )
		player.inv:add("wolf_45acp", { ammo = 80 } )
		player.inv:add("wolf_smed")
		player.inv:add("wolf_smed")
	elseif (CHALLENGE == "challenge_shot" or SCHALLENGE == "challenge_shot") then
		player.eq.weapon = "wolf_shotgun"
		player.inv:add( "wolf_shell", { ammo = 50 } )
		player.inv:add( "wolf_smed" )
		player.inv:add( "wolf_smed" )
	else
		player.eq.weapon = "wolf_pistol1"
		if (player.klass == 1) then
			player.inv:add( "wolf_9mm", { ammo = 40 } )
		else
			player.inv:add( "wolf_9mm", { ammo = 20 } )
		end
		player.inv:add( "wolf_smed" )
		player.inv:add( "wolf_smed" )
	end

	if (CHALLENGE == "challenge_surv" or SCHALLENGE == "challenge_surv") then
		--Humanity gets both its perks AND whatever else was selected.
		player.eq.armor = "wolf_armor3"
		player.inv:add( "wolf_lmed" )
		player.inv:add( "wolf_lmed" )
		player.inv:add( "wolf_mod_agility" )
		player.inv:add( "wolf_mod_tech" )
		player.inv:add( "wolf_mod_power" )
		player.inv:add( "wolf_mod_bulk" )
	end
end

function DoomRL.isepisode()
	return (CHALLENGE == "challenge_ep1" or
	        CHALLENGE == "challenge_ep2" or
	        CHALLENGE == "challenge_ep3" or
	        CHALLENGE == "challenge_ep4" or
	        CHALLENGE == "challenge_ep5" or
	        CHALLENGE == "challenge_ep6")
end
function DoomRL.OnCreateEpisode()
	DoomRL.ep7_OnCreateEpisode()
end

function DoomRL.logo_text()

	--Evil hack that KK won't like, but it's the only way since by default DoomRL intro music does not loop
	if math.random(10) == 1 then core.play_music("start2") else core.play_music("start1") end

	return
[[
@rFeatures :
@R * Seven episodes to stomp through
@R * Brand new items and awards
@R * Snazzy music and sound effects
@R * Enough Nazis to invade Poland


@BStop on by at #chaosforge at quakenet. It's where the cool people go.

@r                                          Press <@yEnter@r> to continue...
]]
end

function DoomRL.donator_text()
	return
[[@rSpecial Thanks go out to:
@R   ds_creamer, Madtrixr, Laptop, Simon, Sorear, Tavana, Tehtmi, Thomas, CIA-bot, Gargulec, Xander, Q, Mad, Para, Malek

@yAre you still playing your OLD DoomRL ]]..VERSION_STRING..[[? Why? @RWHAT'S WRONG WITH YOU!? @yThese people all donated so they have access to the EXCLUSIVE beta. @yThat makes them all MUCH cooler than you.

@rLatest donators: @ythelaptop, Nori, Septa, capn.lee, MaiZure, duomo, Lekon, papercuts6, drugon, tbradshaw, Handro, Game Hunter, Radiocarbon, tehtmi, danielhiryu, jonypawks, skylisdr, Blade, Shancial, Fobbah, Nightwolf, rchandra, jonypawks, Corporate Dog, Stormlock, Nachtfischer, Arenot2be, Test-0, tootboot, snids, salinger, Dimdamm, theduck101, GrimmC, Uite, Raz, alver, ehushagen, AtTheGates, okult, elswyyr, barmaley, SquidgyB, byrel, phrzn, mrblonde, Farquar, Chawlz, Kashi, MoArtis, Jouniz, VinylScratch, AlterAsc, Lprsti99, Tormuse, Dubris, phirt, stants, spacedust, Olesh, Kriminel, brokenfury8585, zakastra, MarsGuyPhil, lnxr0x, naib, michailv, xpsg, Eb, Templeton, Anacone, Althalaus, mihey1993, NamoDyn, grillkick, D1g1talDragon, jvecer and Oogle.
]]
end

function DoomRL.OnWinGame()
	return DoomRL.ep7_OnWinGame()
end

function DoomRL.first_text()
	return
[[@yWelcome to Doom the Roguelike!

You are running DoomRL for the first time. I hope you will find this roguelike game as enjoyable as it was for me to write it.

This game is in active development, and as such please be always sure that you have the most recent version, for bugs are fixed, new features appear, and the game becomes better at every iteration. You can find the lastest version on DoomRL website:

@Bhttp://doom.chaosforge.org/@y

Also, if you enjoy this game, join the forums:

@Bhttp://forum.chaosforge.org/@y

Also on Facebook (@BChaosForge@y), and on Twitter (@B@@chaosforge_org@y).

But most importantly, if you find yourself enjoying the game, drop by ChaosForge and donate - it's these donations that keep DoomRL (and other CF roguelikes) in active development. You can make a difference.

Press @<Enter@y to continue...
]]
end

--Altered this function to give a little more variety in names.
--I may replace the names later.
function DoomRL.random_name()
	--max length of 26!
	local firstnames = {"", "John", "Adrian", "Sandy", "Bobby", "Joseph", "Ilya", "Timo", "Adam", "Derek", "Igor", "Thomas", "Stephen", "Ashannar", "Ian", "Nils", "Jacob", "Rahul"}
	local lastnames = {"", "Romero", "Carmack", "Peterson", "Prince", "Hewitt", "Bely", "Viitanen", "Ring", "Yu", "Savin", "Charchian", "Grey", "Chandra", "McTaggart", "Orine", "Parasiuk", "Ward", "Zalminen"}
	local name

	repeat
		name = string.match(string.match(firstnames[math.random(#firstnames)] .. " " .. lastnames[math.random(#lastnames)], "%S.*") or "", ".*%S") or ""
	until #name > 0 and #name <= 26

	return name
end

function DoomRL.quit_message()

	local messages

	if (DoomRL.isepisode()) then
		messages = {
			"Dost thou wish to leave with such hasty abandon?",
			"Chickening out... already?",
			"Press N for more carnage. Press Y to be a weenie.",
			"So, you think you can quit this easily, huh?",
			"Press N to save the world. Press Y to abandon it in its hour of need.",
			"Press N if you are brave. Press Y to cower in shame. ",
			"Heroes, press N. Wimps, press Y.",
			"You are at an intersection. A sign says, 'Press Y to quit.' >",
			"For guns and glory, press N. For work and worry, press Y.",
		}
	else
		messages = {
			"Heroes don't quit, but go ahead and press Y if you aren't one.",
			"Press Y to quit,  or press N to enjoy  more violent diversion.",
			"Depressing the Y key means you must return to the humdrum workday world.",
			"Hey, quit or play, Y or N: it's your choice.",
			"Sure you don't want to waste a few more productive hours?",
			"I think you had better play some more. Please press N...please?",
			"If you are tough, press N. If not, press Y daintily.",
			"I'm thinkin' that you might wanna press N to play more. You do it.",
			"Sure. Fine. Quit. See if we care. Get it over with. Press Y.",
		}
	end

	return messages[math.random(#(messages))]
end


function DoomRL.OnGenerate()
	DoomRL.ep7_OnGenerate()
end
