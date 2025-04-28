-- ----------------------------------------------------------------------
--  This is the DoomRL initialization file. Modify at your own risk :). 
--  If you mess up something overwrite with a new godmode.lua.
-- ----------------------------------------------------------------------

dofile "config.lua"

SoundEngine = "DEFAULT"

LockBreak        = false
LockClose        = false
SaveOnCrash      = false
ForceRaw         = true

Keytable = {}

-- God commands
Keytable["BACKSPACE"] = function() 
	ui.msg('Heal!')
	player.hp = player.hpmax 
end
Keytable["F2"] = function() 
	ui.msg('Regenerate!')
	generator.regenerate( true )
end
Keytable["F3"] = function() 
	ui.msg('Home!')
	player:phase("stairs")
end
Keytable["F4"] = function() 
	ui.msg('Next level!')
	player:exit()
end
Keytable["F5"] = function() 
	ui.msg('Visibility! '..player.x..'x'..player.y)
	for c in area.FULL() do
		local cell = cells[ level.map[ c ] ]
		if cell.flags[ CF_BLOCKMOVE ] or cell.flags[ CF_NOCHANGE ] then
			level.light[ c ][LFEXPLORED] = true
		end
	end
	level.flags[ LF_BEINGSVISIBLE ] = not level.flags[ LF_BEINGSVISIBLE ]
	level.flags[ LF_ITEMSVISIBLE  ] = not level.flags[ LF_ITEMSVISIBLE  ]
end
Keytable["F6"]        = function() 
	player.inv:clear()
	ui.msg('idkfa!')
	if rawget(_G,"jhc") then
		player.inv:add( 'ashotgun' )
		player.inv:add( 'prifle')
		player.inv:add( 'glauncher')
		player.inv:add( 'launcher')
		player.inv:add( 'utrigun')
		player.inv:add( 'usjack')
		for i = 1,3 do
			player.inv:add( 'rocket', { ammo = 10 } )
		end
		for i = 1,3 do
			player.inv:add( 'ammo_40', { ammo = 15 } )
		end
	else
		player.inv:add( 'ashotgun' )
		player.inv:add( 'unbfg9000')
		player.inv:add( 'uberetta')
		player.inv:add( 'uberarmor')
		player.inv:add( 'utrigun')
		player.inv:add( 'urailgun')
		player.inv:add( 'udragon')
		player.inv:add( 'nuke' )
	end
	for i = 1,3 do
		player.inv:add( 'cell', { ammo = 50 } )
	end
	for i = 1,2 do
		player.inv:add( 'shell', { ammo = 50 } )
	end
end
Keytable["F7"] = function() 
	ui.msg('Teleport!')
	player:phase()
end

Keytable["F8"] = function() 
	ui.msg('+500 Experience!')
	player:add_exp(500)
end
Keytable["SHIFT+F8"] = function() 
	ui.msg('ARMAGEDDON!')
	for b in level:beings() do
		if not b:is_player() then
			b:kill()
		end
	end
end 
--[[
Keytable["F4"] = function() 
	ui.msg('Endgame!')
	player:exit(table.getn(player.episode))
end
--]]
