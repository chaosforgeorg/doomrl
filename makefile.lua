#!/usr/bin/lua
xpcall( function() dofile( "config.lua") end, function() end )
VALKYRIE_ROOT = VALKYRIE_ROOT or os.getenv("FPCVALKYRIE_ROOT") or "../fpcvalkyrie/"
dofile (VALKYRIE_ROOT.."scripts/lua_make.lua")

makefile = {
	name = "drl",
	fpc_params = {
		"-Fu"..VALKYRIE_ROOT.."src",
		"-Fu"..VALKYRIE_ROOT.."libs",
	},
	fpc_os_params = {
		WINDOWS = {},
		LINUX = {	
			"-TLINUX",
		},
		MACOSX = {	
			"-dOSX_APP_BUNDLE",
			"-k-macosx_version_min -k10.4",
		},
	},
	pre_build = function()
		local v = make.readversion( "bin/version.txt" )
		local s = make.gitrevision()
		make.writeversion( "src/version.inc", v, s )
		--make.svncheck(s)
	end,
	post_build = function()
		os.execute_in_dir( "makewad", "bin" )
	end,
	source_files = { "drl.pas", "makewad.pas", "drlwad.pas" },
	publish = {
		lq = {
			exec = { "drl" },
			files = { "config.lua" },
			os = {
				WINDOWS = { "fmod64.dll", "lua5.1.dll", "SDL2.dll", "SDL2_image.dll", "SDL2_mixer.dll", "drl_console.bat" },
				LINUX   = { "unix_notes.txt", "drl_gnome-terminal", "drl_konsole", "drl_xterm" },
				MACOSX  = { "unix_notes.txt" },
			},
			subdirs = {
				backup     = "!readme.txt",
				mortem     = "!readme.txt",
				screenshot = "!readme.txt",
				modules    = "!readme.txt",
				wav        = "*.wav",
				music      = "*.mid",
			},
			other = { "colors.lua", "sound.lua", "music.lua", "manual.txt", "version.txt", "version_api.txt", "drl.wad", "core.wad" },
		},
		hq = {
			exec = { "drl" },
			files = { { "confighq.lua", "config.lua" } },
			os = {
				WINDOWS = { "fmod64.dll", "lua5.1.dll", "SDL2.dll", "SDL2_image.dll", "SDL2_mixer.dll", "drl_console.bat" },
				LINUX   = { "unix_notes.txt", "drl_gnome-terminal", "drl_konsole", "drl_xterm" },
				MACOSX  = { "unix_notes.txt" },
			},
			subdirs = {
				backup     = "!readme.txt",
				mortem     = "!readme.txt",
				screenshot = "!readme.txt",
				modules    = "!readme.txt",
				wavhq      = "*.wav",
				mp3        = "*.mp3",
			},
			other = { "colors.lua", "soundhq.lua", "musichq.lua", "manual.txt", "version.txt", "version_api.txt", "drl.wad", "core.wad" },
		}
	},
	commands = {
		lq = function()
			make.package( make.publish( (OS_VER_PREFIX or "")..make.version_name().."-lq", "lq" ), PUBLISH_DIR )
		end,
		hq = function()
			make.package( make.publish( (OS_VER_PREFIX or "")..make.version_name(), "hq" ), PUBLISH_DIR )
		end,
		install = function() makefile.commands.installhq() end,
		installhq = function()
			if OS == "WINDOWS" then	
				make.generate_iss( "doomrl.iss", "hq", PUBLISH_DIR ) 
			elseif OS == "MACOSX" then
				make.generate_bundle( "hq", PUBLISH_DIR ) 
			end
		end,
		installlq = function()
			if OS == "WINDOWS" then	
				make.generate_iss( "doomrl.iss", "lq", PUBLISH_DIR ) 
			elseif OS == "MACOSX" then
				make.generate_bundle( "lq", PUBLISH_DIR ) 
			end
		end,
		all = function()
			makefile.commands.lq()
			makefile.commands.hq()
			makefile.commands.install()
		end,
		alllq = function()
			makefile.commands.lq()
			makefile.commands.installlq()
		end,
	},
	install = {
		guid        = "E78C63C9-9849-45FA-8315-2AE38A293E2E",
		name        = "DRL",
		publisher   = "ChaosForge",
		license     = "install\\install_license.txt",
		info_after  = "install\\install_after.txt",
		iss_icon    = "src\\icon.ico",
		iss_image   = "install\\install.bmp",
		iss_simage  = "install\\install_small.bmp",
		iss_url     = "http://www.chaosforge.org/",
		iss_nocomp  = { "wad", "mp3" },
		iss_eicons  = {
			{ name = "DRL", exe = "drl" },
			{ name = "DRL (console mode)", exe = "drl", parameters = "-console" },
			{ name = "DRL Manual", file = "manual.txt" },
			{ name = "ChaosForge Website", url = "http://www.chaosforge.org/" },
			{ name = "DRL Website", url = "https://drl.chaosforge.org/" },
			{ name = "DRL Forum", url = "http://forum.chaosforge.org/" },
		},
		dmg_size   = 128000,
		app_icon   = "bin/iconfile.icns",
		app_bg     = "background.png",
		app_fworks = {
			"Frameworks/SDL.framework",
			"Frameworks/SDL_image.framework",
			"Frameworks/SDL_mixer.framework",
		},
		app_exefix = function( file )
			os.execute("install_name_tool -change @rpath/SDL.framework/Versions/A/SDL @executable_path/../Frameworks/SDL.framework/Versions/A/SDL "..file )
		end,

	}
}

make.compile()
make.command( arg[1] )
