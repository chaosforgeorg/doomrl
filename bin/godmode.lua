-- ----------------------------------------------------------------------
--  This is the DoomRL initialization file. Modify at your own risk :). 
--  If you mess up something overwrite with a new godmode.lua.
-- ----------------------------------------------------------------------

dofile "core/commands.lua"
dofile "colors.lua"

-- pick here what music set to use (see music.lua and musicmp3.lua)
dofile "musichq.lua" 
dofile "soundhq.lua"

dofile "keybindings.lua"

-- Temporary
StartFullscreen  = false
FullscreenQuery  = false

SoundEngine = "DEFAULT"

-- SDL sound only options. See SDL_mixer manual on what to put here if
-- defaults don't get you working audio. Format needs to be decoded because
-- Lua doesn't support hex notation.
SDLMixerFreq      = 44100
SDLMixerFormat    = 32784
SDLMixerChunkSize = 1024

-- Windowed sizes
WindowedWidth    = 800
WindowedHeight   = 600
-- Multiplication values of font and tile display - use at most 2
WindowedFontMult = 1
WindowedTileMult = 1

-- Fullscreen resolution sizes
-- -1 means auto-detection of screen size, and fontmult and tilemult based on it
FullscreenWidth    = -1
FullscreenHeight   = -1
FullscreenFontMult = -1
FullscreenTileMult = -1

-- Whether to allow high-ASCII signs. Set to false if you see weird signs 
-- on the screen.
AllowHighAscii   = false

-- Setting to false will skip name entry procedure and choose a random name
-- instead
AlwaysRandomName = false

-- Specifies wether items in inventory and equipment should be colored
ColoredInventory = true

-- Setting this to anything except "" will always use that as the name.
-- Warning - no error checking, so don't use too long names, or especially
-- the "@" sign (it's a control char). This setting overrides the one above!
AlwaysName       = ""

-- Setting to false will skip the intro
SkipIntro        = true

-- Setting to false will remove the bloodslide effect
NoBloodSlides    = true

-- Setting to false will remove the flashing effect
NoFlashing       = false

-- Setting to false will make the run command not stop on items
RunOverItems     = false

-- Setting to false will turn off music during gameplay
GameMusic        = true

-- Setting to false will turn off sounds during gameplay
GameSound        = true

-- Setting to false will turn off Menu change/select sound
MenuSound        = true

-- Setting to false will turn on enhancements for blind people playing
-- DoomRL using a screen reader. Yes, some do.
BlindMode        = false

-- Setting to false will turn on enhancements for colorblind people.
ColorBlindMode   = false

-- Setting to true will make old messages disappear from the screen 
-- (useful in BlindMode)
ClearMessages    = false

-- Setting to true will prevent DoomRL from waiting for confirmation
-- when too many messages are printed in a turn. Usefull for Speedrunning.
MorePrompt       = true

-- Setting to false will make the game wait for an enter/space key if
-- trying to fire an empty weapon.
EmptyConfirm     = true

-- If set to false, pickup sound will be used for quickkeys and weapon
-- swapping.
SoundEquipPickup = false

-- Sets the delay value when running. Value is in milliseconds. Set to 0 for no delay.
RunDelay         = 20

-- Music volume in the range of 0..25
MusicVolume      = 12

-- Sound volume in the range of 0..25
SoundVolume      = 20

-- Handles what should be done in case of trying to unwield an item when inventory
-- is full : if set to false will ask the player if he wants to drop it. If set
-- to false will drop it without questions.
InvFullDrop      = false

-- Messages held in the message buffer.
MessageBuffer    = 100

-- Sets wether message coloring will be enabled. Needs [messages] section.
MessageColoring  = true

-- If set to false will archive EVERY mortem.txt produced in the mortem subfolder.
-- The amount of files can get big after a while :)
MortemArchive    = false

-- Sets the amount of player.wad backups. Set 0 to turn off. At most one backup
-- is held for a given day.
PlayerBackups    = 7

-- Sets the amount of score.wad backups. Set 0 to turn off.  At most one backup
-- is held for a given day.
ScoreBackups     = 7

-- If set to false DoomRL will quit on death and quitting. Normally it will go back
-- to the main menu.
MenuReturn       = true

-- Defines the maximum repeat for the run command. Setting it to larger than 80
-- basically means no limit.
MaxRun           = 100

-- Defines the maximum repeat for the run command when waiting.
MaxWait          = 20

-- Disables Ctrl-C/Ctrl-Break closing of program. false by default.
LockBreak        = false

-- Disables closing of DoomRL by console close button. false by default.
LockClose        = false

-- Sets the color of intuition effect for beings
IntuitionColor   = RED

-- Sets the char of intuition effect for beings
IntuitionChar    = "."

-- Mortem timestamp format
-- Format : http://www.freepascal.org/docs-html/rtl/sysutils/formatchars.html
-- note that / and : will be converted to "-" due to filesystem issues
TimeStamp        = "yyyy/mm/dd hh:nn:ss"

-- Controls whether the game will attempt to save the game on crash, set to false
-- to turn this off
SaveOnCrash      = false

-- This is the global internet connection switch, allowing DoomRL
-- to use internet connection features. Think twice before disabling
-- it, or you'll loose the features listed below and MOTD and ModServer
-- support!
NetworkConnection = true

-- Should DoomRL check if there's a new version at runtime. If 
-- NetworkConnection is set to true this check is made regardless,
-- but there will be no alert if set to false.
VersionCheck = true

-- Should DoomRL check if there's a new BETA version at runtime. If 
-- NetworkConnection is set to true this check is made regardless,
-- but there will be no alert if set to false. BETA versions are only
-- available to Supporters, but why not hop in and join the fun?
-- By default it's set to VERSION_BETA which is true for beta releases
-- and false for stable releases. Set to true, to get notified of the
-- next BETA batch!
BetaCheck = VERSION_BETA

-- Should DoomRL check for other alerts. Sometimes we will want to
-- point you out to a major ChaosForge release or news flash. This feature
-- will not be abused, and each alert will be displayed only once, so 
-- please consider leaving this set to true! :)
AlertCheck = true

-- DoomRL by default uses it's own mod server, where we host only screened
-- mods from the DoomRL community. A day may come when there will be an
-- unofficial server, for example for mods in testing. You can specify it 
-- here. Note that this overrides the default server.
CustomModServer = ''


-- Message coloring system. Works only if MessageColoring
-- variable is set to false. Must start with a color name
-- followed by anything (config entries need to be different!).
-- As for the string, it's case sensitive, but you may use
-- the wildcard characters * and ?.

-- Unsure how these work and want to fiddle with them?
-- Head over to http://forum.chaosforge.org/ for more info.
Messages = {
	["Warning!*"] 		              = RED,
	["Your * destroyed!"]             = RED,
	["You die*"]                      = RED,
	["Your * damaged!"]               = BROWN,
	["You feel relatively safe now."] = BLUE
}

-- God commands
Keybindings["W"]        = function() 
	ui.msg('Invulnerability!')
	player:set_affect("inv",50) 
end


-- XXX Does this even work?
Keybindings["SHIFT+BACKSPACE"] = function() 
	ui.msg('Supercharge!')
	player.hp = 2 * player.hpmax 
end
Keybindings["BACKSPACE"] = function() 
	ui.msg('Heal!')
	player.hp = player.hpmax 
end
Keybindings["BQUOTE"] = function() 
	ui.msg('Home!')
	player:phase("stairs")
end
Keybindings["SHIFT+3"]        = function() 
	if player:is_affect( "inv" ) then
		player:remove_affect( "inv" )
	else
		ui.msg('Invulnerability!')
		player:set_affect("inv", 5000) 
	end
end
Keybindings["SHIFT+4"]        = function() 
	if player:is_affect( "berserk" ) then
		player:remove_affect( "berserk" )
	else
		ui.msg('Berserk!')
		player:set_affect("berserk", 5000) 
	end
end
Keybindings["SHIFT+5"]        = function() 
	if player:is_affect( "enviro" ) then
		player:remove_affect( "enviro" )
	else
		ui.msg('Enviro!')
		player:set_affect("enviro", 5000) 
	end
end


Keybindings["F3"] = function() 
	ui.msg('Next level!')
	player:exit()
end
Keybindings["F4"] = function() 
	ui.msg('Endgame!')
	-- Different ending floors for different challenges (this should be fairly independent code)
	player:exit(table.getn(player.episode))
end
Keybindings["F5"] = function() 
	ui.msg('Experience!')
	player.exp = player.exp + 300
end
Keybindings["F6"] = function() 
	ui.msg('ARMAGEDDON!')
	for b in level:beings() do
		if not b:is_player() then
			b:kill()
		end
	end
end 
Keybindings["F7"] = function() 
	ui.msg('Teleport!')
	player:phase()
end
Keybindings["F8"]        = function() 
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
Keybindings["BSLASH"] = function() 
	ui.msg('Visibility!')
	level.flags[ LF_BEINGSVISIBLE ] = not level.flags[ LF_BEINGSVISIBLE ]
	level.flags[ LF_ITEMSVISIBLE  ] = not level.flags[ LF_ITEMSVISIBLE  ]
end
