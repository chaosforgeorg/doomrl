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
require( "doomrl:mod_arrays" )
require( "doomrl:klass" )

require( "doomrl:items/items" )
require( "doomrl:items/eitems" )
require( "doomrl:items/uitems" )

require( "doomrl:levels/boss" )
require( "doomrl:levels/arena" )
require( "doomrl:levels/phoboslab" )
require( "doomrl:levels/fortress" )
require( "doomrl:levels/intro" )
require( "doomrl:levels/chained" )
require( "doomrl:levels/carnage" )
require( "doomrl:levels/milibase" )
require( "doomrl:levels/deimoslab" )
require( "doomrl:levels/armory" )
require( "doomrl:levels/skulls" )
require( "doomrl:levels/abyssal" )
require( "doomrl:levels/wall" )
require( "doomrl:levels/spider" )
require( "doomrl:levels/vaults" )
require( "doomrl:levels/house" )
require( "doomrl:levels/limbo" )
require( "doomrl:levels/mortuary" )
require( "doomrl:levels/mterebus" )
require( "doomrl:levels/lavapits" )
require( "doomrl:levels/asmosden" )
require( "doomrl:levels/containment" )

-- main DoomRL lua script file --

function DoomRL.OnLoaded()
	ui.msg('Welcome to the @RDoom@> Roguelike...')
end

function DoomRL.OnLoadBase()
	DoomRL.load_difficulty()
	DoomRL.loadbasedata()
	DoomRL.loadaffects()
	DoomRL.loadmissiles()
	DoomRL.loadcells()
	DoomRL.loaditems()
	DoomRL.loadexoticitems()
	DoomRL.loaduniqueitems()
	DoomRL.loadnpcs()
	DoomRL.load_ranks()
	DoomRL.load_traits()
	DoomRL.loadmedals()
	DoomRL.load_mod_arrays()
	DoomRL.loadchallenges()
	DoomRL.load_klasses()

	DoomRL.load_generators()
	DoomRL.load_events()
	DoomRL.load_rooms()

	generator.styles = {
		{ floor = "floor",  wall = "wall",  door="door",  odoor = "odoor"  },
		{ floor = "floor",  wall = "dwall", door="door",  odoor = "odoor"  },
		{ floor = "floorb", wall = "rwall", door="doorb", odoor = "odoorb" },
		{ floor = "floor",  wall = "rwall", door="door",  odoor = "odoor"  },
		-- caves
		{ floor = "floor",   wall = "cwall1", door="door",  odoor = "odoor"  },
		{ floor = "floorc",  wall = "cwall2", door="door",  odoor = "odoor"  },
		{ floor = "floorb",  wall = "cwall3", door="door",  odoor = "odoor"  },
	}
end

function DoomRL.OnLoad()
	DoomRL.registerlevels()
	DoomRL.load_doom_unique_items()
	DoomRL.load_doom_npcs()
end

function DoomRL.OnDisassemble( it )
	local modlist = {"mod_agility","mod_bulk","mod_tech","mod_power"}
	if it.__proto.scavenge then
		modlist = it.__proto.scavenge
	elseif it.flags[IF_EXOTIC] then
		modlist = {"mod_agility","mod_bulk","mod_tech","mod_power","umod_firestorm","umod_sniper"}
	elseif it.flags[IF_UNIQUE] then
		modlist = {"umod_firestorm","umod_firestorm","umod_sniper","umod_sniper","umod_onyx","umod_nano"}
	else
		local mods = it:get_mod_ids()
		if #mods > 0 then
			modlist = mods 
		end
	end
	return table.random_pick( modlist )
end

function DoomRL.get_result_id()
	local result    = "unknown"
	local dead      = player.hp <= 0
	local won       = player:has_won()
	local nuked     = level.flags[ LF_NUKED ]
	local boss1dead = won
	local boss2dead = kills.get("jc") > 0 or kills.get("apostle") > 0

	if won then 
		result = "win"
		if boss2dead and not dead then
			result = "final"
		elseif boss1dead and dead then
			result = "sacrifice"
		end
	elseif not dead then 
		result = "win"
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

	    if result == "win"   then killed_by = "defeated the Mastermind"
	elseif result == "final" then killed_by = "nuked the Mastermind"
	elseif result == "nuke"  then killed_by = "nuked himself"
	elseif result == "sacrifice" then
		if highscore then killed_by = "won by sacrifice" else killed_by = "sacrificed himself to kill the Mastermind" end
	elseif result == "suicide" then
		if highscore then killed_by = "committed suicide" else killed_by = "committed a stupid suicide" end
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
				killed_by = 'killed by '..killer.name
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
	player:mortem_print( " DoomRL ("..VERSION_STRING..") roguelike post-mortem character dump")
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
		local epi_name = player.episode[player.depth].deathname or player.episode[player.depth].name or "an Unknown Location"
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

	player:mortem_print( " He killed "..statistics.kills.." out of "..statistics.max_kills.." hellspawn. ("..math.floor(ratio*100).."%)" )

		if statistics.kills == statistics.max_kills then
			player:mortem_print( " This ass-kicking marine killed all of them!" )
	elseif statistics.kills + 1 == statistics.max_kills then
			player:mortem_print (" He missed one kill to totally be ass-kicking." )
	elseif statistics.kills == 0 then
			player:mortem_print( " Poor pacifist, didn't even get a single kill..." )
	elseif statistics.kills == 1 then
			player:mortem_print( " Somehow, he managed only *one* kill." )
	elseif ratio < 0.1    then
			player:mortem_print( " My, wasn't he a wimpy chump." )
	elseif ratio < 0.3    then
			player:mortem_print( " Who gave him the ticket to Hell, anyway?" )
	elseif ratio > 0.999  then
			player:mortem_print( " A natural born killer!" )
	elseif ratio > 0.99   then
			player:mortem_print( " He was a real killing machine..." )
	elseif ratio > 0.9    then
			player:mortem_print( " He held his right to remain violent." )
	end

	if CHALLENGE ~= "" then
		if ARCHANGEL then
			player:mortem_print( " He was an "..chal[CHALLENGE].arch_name.."!")
		else
			player:mortem_print( " He was an "..chal[CHALLENGE].name.."!")
		end
		if SCHALLENGE ~= "" then
			player:mortem_print( " He was also an "..chal[SCHALLENGE].name.."!")
		end
	end

	local function padded( str, size )
		return str..string.rep(" ",math.max(0,size - string.len(str)) )
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
				player:mortem_print( "  "..padded( v.name, 26 ).." "..v.desc )
				awarded = true
			end
		end

		for k,v in ipairs( badges ) do
			if player:has_badge( v.id ) then
				-- TODO Potential marking code
				--if player:record_badge ( v.id ) then
				--	player:mortem_print( "  "..v.name )
				--else
				--	player:mortem_print( "* "..v.name )
				--	new_awarded = true
				--end
				player:mortem_print( "  "..padded( v.name, 26 ).." "..v.desc )
				awarded = true
			end
		end
	end

	for k,v in ipairs( awards ) do
		if player:has_award( v.id ) then
			player:mortem_print( "  "..v.name.." ("..v.levels[ player:get_award( v.id ) ].name..")" )
			awarded = true
		end
	end

	if not awarded then
		player:mortem_print("  None")
	end
	player:mortem_print()

	local function get_pic( c )
		local being = level:get_being( c )
		if being then
			if string.char(being.picture) == '@' then return 'X' end
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
	-- TODO This would be a good place to use utf-8 expansions for the high-ascii text.
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
	if game_type == GAMESTANDARD then
		if kills.get("jc") > 0 then
			player:mortem_print( "  Then finally in Hell itself, he killed the final EVIL." )
		else
			player:mortem_print( "  On level "..player.depth.." he finally "..death_reason..".")
		end
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
			player:mortem_print( " "..deaths.." brave souls have ventured into Phobos:" )
			reason( "killed" ," @1 of those @was killed.")
			reason( "unknown"," @1 of those @was killed by something unknown." )
			reason( "nuke"   ," @1 didn't read the thermonuclear bomb manual." )
			reason( "suicide"," And @1 couldn't handle the stress and committed a stupid suicide." )

			local sacrifice = player_data.count('player/games/win[@id="sacrifice"]')
			local win       = player_data.count('player/games/win[@id="win"]')
			local fullwin   = player_data.count('player/games/win[@id="final"]')
			local wins      = sacrifice + win + fullwin

			if wins > 0 then
				player:mortem_print()
				player:mortem_print(" "..wins.." souls destroyed the Mastermind...")
				if sacrifice > 0 then player:mortem_print(" "..sacrifice.." sacrificed itself for the good of mankind." ) end
				if win       > 0 then player:mortem_print(" "..win.." killed the bitch and survived." ) end
				if fullwin   > 0 then player:mortem_print(" "..fullwin.." showed that it can outsmart Hell itself." ) end
			end
		else
			player:mortem_print("  He's the first brave soul to have ventured into Hell...")
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

	register_cell "bloodpool"
	{
		name = "pool of blood";
		ascii = "";
		asciilow = '.';
		color = RED;
		set = CELLSET_FLOORS;
		sprite = SPRITE_BLOODPOOL;
		flags = {CF_OVERLAY, CF_VBLOODY};
	}

	register_cell "corpse"
	{
		name = "bloody corpse";
		ascii = "%";
		color = RED;
		set = CELLSET_FLOORS;
		flags = {CF_OVERLAY, CF_NOCHANGE, CF_VBLOODY};
		destroyto = "bloodpool",
		sprite = SPRITE_CORPSE,
	}

	register_item "stubitem"
	{
		name     = "stubitem",
		color    = RED,
		sprite   = SPRITE_TELEPORT,
		weight   = 0,

		type = ITEMTYPE_TELE,

		OnEnter = function() end,
	}

	register_item "teleport"
	{
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
				tgt:apply_damage(15, TARGET_INTERNAL, DAMAGE_FIRE )
				target = generator.random_empty_coord( empty )
			end
			if being.__ptr then
				being:relocate( target )
				being:msg(nil,"Suddenly "..being:get_name(false,false).." appears out of nowhere!")
				being.scount = being.scount - 1000
			end
		end,
	}

	register_being "soldier"
	{
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
		desc         = "You're a soldier. One of the best that the world could set against the demonic invasion.",
		ai_type      = "",

		OnCreate = function(self)
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

function DoomRL.OnCreateEpisode()
	local BOSS_LEVEL = 24
	player.episode = {}
	local paired = {
		{"hells_arena"}, -- 2
		{"the_chained_court"}, -- 5
		{"military_base","phobos_lab"}, -- 7
		{"hells_armory", "deimos_lab"}, -- 9/1
		{"the_wall","containment_area"}, -- 11/3
		{"city_of_skulls","abyssal_plains"}, -- 12/4
		{"halls_of_carnage","spiders_lair"}, -- 14/6
		{"unholy_cathedral"}, -- 17/1
		{"the_vaults"},--,"house_of_pain"}, -- 19/3
		{"the_mortuary","limbo"},-- 20/4
		{"the_lava_pits","mt_erebus"},-- 22/6
	}

	player.episode[1]   = { script = "intro", style = 1, deathname = "the Phobos base" }
	for i=2,8 do
		player.episode[i] = { style = 1, number = i, name = "Phobos", danger = i, deathname = "the Phobos base" }
	end
	for i=9,16 do
		player.episode[i] = { style = 2, number = i-8, name = "Deimos", danger = i, deathname = "the Deimos base" }
	end
	for i=17,BOSS_LEVEL-1 do
		player.episode[i] = { style = 3, number = i-16, name = "Hell", danger = i }
	end
	player.episode[8]            = { script = "hellgate", style = 4, deathname = "the Hellgate" }
	player.episode[16]           = { script = "tower_of_babel", style = 4, deathname = "the Tower of Babel" }
	player.episode[BOSS_LEVEL]   = { script = "dis", style = 4, deathname = "the City of Dis" }
	player.episode[BOSS_LEVEL+1] = { script = "hell_fortress", style = 4, deathname = "the Hell Fortress" }

	for _,pairing in ipairs(paired) do
		local level_proto = levels[table.random_pick(pairing)]
		if (not level_proto.canGenerate) or level_proto.canGenerate() then
			player.episode[resolverange(level_proto.level)].special = level_proto.id
		end
	end
	local SpecLevCount = 0
	for i=2,BOSS_LEVEL-1 do
		if player.episode[i].special then
			SpecLevCount = SpecLevCount + 1
		end
	end
	statistics.bonus_levels_count = SpecLevCount
end

function DoomRL.logo_text()
	return
[[@rAdd. coding : @ytehtmi@r, @yGame Hunter@r, @yshark20061@r and @yadd
@rMusic tracks: @ySonic Clang@r (remixes), @ySimon Volpert@r (special levels)
@rDoom HQ SFX : @yPer Kristian Risvik

@rMajor changes since last version (see @yversion.txt@r for full list)
@R  * mod-server! Dual-Angel, Archangel and Custom Challenges!
@R  * new special levels paired with old ones, and new level generators!
@R  * several minor features, bugfixes and balance changes

@B facebook.com/ChaosForge   twitter.com/chaosforge_org   gplus.to/ChaosForge
@r                                          Press <@yEnter@r> to continue...
]]
end

function DoomRL.donator_text()
	return
[[@rIf you enjoy this game, please consider making a @Ldonation@r! Latest donators: @y 2DeviationsOut, AcidLead, adhominem, ahoge, Akisu, Alesak, AlterAsc, Ander Hammer, appuru, Ashannar, AtTheGates, AukonDK, awebster, Azirel, Blade, Blood, briareoh, ceb, Cheesybox, Cocodor, Cotonou, Darren Grey, DeathDealer, doshu, dtsund, ecmwie, EfronLicht, Essegi, Estwald, fallout, fidsah, fire_and_ice, Flame_US3r, fooziex, fwoop, Game Hunter, Gamera, GermanJoey, gilgatex, Goatmeat, GrAVit, gunthos, Hamster, Igor Savin, IronBeer, KhaaL, Klear, Kolya, konijn, Lagonazer, LinuxIsFinanciallyViable, LordSloth, LuckyDee, MaiZure, mcz117chief, MICu, Mogul, Moog, Napsterbater, neadlak, Neolander, NullPointer, Omega Tyrant, Peter5930, ppiixx, Q2ZOv, Reef Blastbody, repvblic, saltylicorice, Seacow, Seven Deadly Sins, Shadow Fox, shark20061, Shroomsy, Skiv, slartie, spiderwebby, spillblood, stargazer-3, Steve, SuperVGA, Tavana, tehtmi, Templeton, Thann, thelaptop, Thexare, Thomas, Tormuse, Tuor Huorson, UAC421, UnderAPaleGreySky, Uranium, VANDAM, vurt, White Rider, WorthlessBums, Xi over Xi-bar, zakastra, Zalminen, Zeb, zeroDi and ZicherCZ ]]
end

function DoomRL.OnWinGame()
	if kills.get("jc") > 0 then
		DoomRL.plot_outro_final()
	elseif player.depth >= 24 then
		if player.hp > 0 or player.depth > 24 then
			DoomRL.plot_outro_3()
		else
			DoomRL.plot_outro_partial()
		end
	else
		return false
	end
	ui.plot_screen([[




             Doom, the Roguelike ]]..VERSION_STRING..[[

                   Congratulations!
           Look further for the next release
            on https://drl.chaosforge.org/]])
	ui.blood_slide()
	return true
end

function DoomRL.first_text()
	return
[[@yWelcome to Doom the Roguelike!

You are running DoomRL for the first time. I hope you will find this roguelike game as enjoyable as it was for me to write it.

This game is in active development, and as such please be always sure that you have the most recent version, for bugs are fixed, new features appear, and the game becomes better at every iteration. You can find the lastest version on DoomRL website:

@Bhttps://drl.chaosforge.org/@y

Also, if you enjoy this game, join the forums:

@Bhttp://forum.chaosforge.org/@y

Also on Facebook (@BChaosForge@y), and on Twitter (@B@@chaosforge_org@y).

But most importantly, if you find yourself enjoying the game, drop by ChaosForge and donate - it's these donations that keep DoomRL (and other CF roguelikes) in active development. You can make a difference.

Press @<Enter@y to continue...
]]
end

function DoomRL.random_name()
	-- TODO Add more names
	local names =
	{
		"John Romero",
		"Adrian Carmack",
		"Sandy Peterson",
		"Bobby Prince",
		"Joseph Hewitt",
		"Ilya Bely",
		"Timo Viitanen",
		"Adam Ring",
		"Derek Yu",
		"Igor Savin",
		"Ian McTaggart",
		"Charchian",
		"Phwop",
		"Rahul Chandra",
		"Material Defender",
		"Linuxusers Buy Games",
		"Grey",
		"Jacob Orine",
		"Zalminen",
		"Ashannar",
		"Stephen Ward",
		"Nils Bloodaxe",
		"Thomas Parasiuk",
		"Moog",
		"Total Biscuit",
		"Eol Armok",
		"Derrick Sund",
	}

	return names[math.random(#(names))]
end

function DoomRL.get_special_item( pname )
	if DIFFICULTY > 3 then return nil end
	local name = string.gsub( string.lower( pname or "" ), " ", "_" )
	local matches = 
	{
		malek             = "umarmor",
		malek_deneith     = "umarmor",
		thelaptop         = "unboots",
		ian_mctaggart     = "unboots",
		sam_charchian     = "unullpointer",
		charchian         = "unullpointer",
		nullpointer       = "unullpointer",
		deathdealer       = "usubtle",
		phwop             = "usubtle",
		rchandra          = "umega",
		rahul_chandra     = "umega",
		material_defender = "umjoll",
		flame_us3r        = "umjoll",
		derrick_sund      = "ufshotgun",
		dtsund            = "ufshotgun",
	}
	if matches[ name ] or DIFFICULTY > 2 then
		return matches[ name ]
	end
	matches = 
	{
		alan_shaefer      = "uminigun",
		diablo            = "ubutcher",
		butcher           = "ubutcher",
		vash              = "utrigun",
		vash_stampede     = "utrigun",
		vash_the_stampede = "utrigun",
		alucard           = "ujackal",
		hellsing          = "ujackal",
		preston           = "uberetta",
		john_preston      = "uberetta",
		revenant          = "urbazooka",
		-- XXX What about "Gutts"?
	}
	return matches[ name ]
end

function DoomRL.quit_message()
	-- TODO O/S specific messages (i.e. OSX, Linux etc)
	local messages = {
		"Don't leave -- there's a demon behind that corner!",
		"Your system will get overrun by imps!",
		"If I were your boss I'd deathmatch you in a minute!",
		"Let's beat it -- it's turning into a bloodbath!",
		"You're trying to say you like Windows better then me, eh?",
		"Please don't leave -- there're more demons to roast!",
		"I wouldn't leave if I were you. Windows is much worse!",
		"Get outta here and go back to your boring programs...!",
		"Go ahead and leave. See if I care.",
		"Ya know. Next time ya gonna come here, I'm gonna toast ya."
	}
	return messages[math.random(#(messages))]
end

function DoomRL.OnGenerate()
	core.log("DoomRL.OnGenerate()")

	local dlevel = level.danger_level
	local choice = weight_table.new()
	for _,g in ipairs(generators) do
		if dlevel >= g.min_dlevel and DIFFICULTY >= g.min_diff then
			local weight = core.ranged_table( g.weight, dlevel ) 
			choice:add( g, weight )
		end
	end
	if choice:size() == 0 then error("NO GENERATOR AVAILABLE!") end
	local gen = choice:roll()
	generator.run( gen )
end

