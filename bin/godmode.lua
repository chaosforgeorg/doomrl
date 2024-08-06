-- ----------------------------------------------------------------------
--  This is the DoomRL initialization file. Modify at your own risk :). 
--  If you mess up something overwrite with a new godmode.lua.
-- ----------------------------------------------------------------------

dofile "confighq.lua"

SoundEngine = "DEFAULT"

LockBreak        = false
LockClose        = false
SaveOnCrash      = false

Keytable = {}

-- God commands
Keytable["W"]        = function() 
	ui.msg('Invulnerability!')
	player:set_affect("inv",50) 
end

-- XXX Does this even work?
Keytable["SHIFT+BACKSPACE"] = function() 
	ui.msg('Supercharge!')
	player.hp = 2 * player.hpmax 
end
Keytable["BACKSPACE"] = function() 
	ui.msg('Heal!')
	player.hp = player.hpmax 
end
Keytable["BQUOTE"] = function() 
	ui.msg('Home!')
	player:phase("stairs")
end
Keytable["SHIFT+3"]        = function() 
	if player:is_affect( "inv" ) then
		player:remove_affect( "inv" )
	else
		ui.msg('Invulnerability!')
		player:set_affect("inv", 5000) 
	end
end
Keytable["SHIFT+4"]        = function() 
	if player:is_affect( "berserk" ) then
		player:remove_affect( "berserk" )
	else
		ui.msg('Berserk!')
		player:set_affect("berserk", 5000) 
	end
end
Keytable["SHIFT+5"]        = function() 
	if player:is_affect( "enviro" ) then
		player:remove_affect( "enviro" )
	else
		ui.msg('Enviro!')
		player:set_affect("enviro", 5000) 
	end
end

Keytable["F3"] = function() 
	ui.msg('Next level!')
	player:exit()
end
Keytable["F4"] = function() 
	ui.msg('Endgame!')
	-- Different ending floors for different challenges (this should be fairly independent code)
	player:exit(table.getn(player.episode))
end
Keytable["F5"] = function() 
	ui.msg('+500 Experience!')
	player:add_exp(500)
end
Keytable["F6"] = function() 
	ui.msg('ARMAGEDDON!')
	for b in level:beings() do
		if not b:is_player() then
			b:kill()
		end
	end
end 
Keytable["F7"] = function() 
	ui.msg('Teleport!')
	player:phase()
end
Keytable["F8"]        = function() 
	player.inv:clear()
	ui.msg('idkfa!')
	player.inv:add( 'ashotgun' )
	player.inv:add( 'unbfg9000')
 	player.inv:add( 'uberetta')
 	player.inv:add( 'uberarmor')
	player.inv:add( 'utrigun')
	player.inv:add( 'urailgun')
	player.inv:add( 'udragon')
	for i = 1,5 do
		player.inv:add( 'cell', { ammo = 50 } )
	end
	for i = 1,4 do
		player.inv:add( 'shell', { ammo = 50 } )
	end
end
Keytable["BSLASH"] = function() 
	ui.msg('Visibility!')
	level.flags[ LF_BEINGSVISIBLE ] = not level.flags[ LF_BEINGSVISIBLE ]
	level.flags[ LF_ITEMSVISIBLE  ] = not level.flags[ LF_ITEMSVISIBLE  ]
end
