# doomrl

DRL a.k.a. doomrl, a.k.a, D**m, the Roguelike, version 0.9.9.8
http://drl.chaosforge.org/

## Foreword
This release is dedicated to Jupiter Hell Classic, the newly announced commercial remake/expansion to DRL:

https://store.steampowered.com/app/3126530/Jupiter_Hell_Classic/

If you enjoy this Open Source release, please consider wishlisting and later buying Jupiter Hell Classic! Also, you might be interested in DRL's modern 3D spiritual successor, Jupiter Hell (yes, it's still turn-based :P):

https://store.steampowered.com/app/811320/Jupiter_Hell/

Parts of this codebase date back to 2002, please do not judge! :P

## Source

This FreePascal source code release is provided as is. You can try compiling it using the latest version of Lazarus ( http://www.lazarus-ide.org/ ). You will also need the FPC Valkyrie library ( https://github.com/ChaosForge/fpcvalkyrie/ ), version 0.9.0. You will also probably need the binary files of the full game downloadable from http://drl.chaosforge.org/ (in particular the sound, soundhq, music and mp3 folder contents, and the premade drl.wad and core.wad if you don't want to create it yourself).

There are two IDEs available: Visual Studio Code and Lazarus. You should only need one of them.

### Components
1. Fpcvalkyrie: is the low level engine that manages the core functions of the game world
2. Makewad.exe assembles the wad files, which contain the digital assets (sounds) and rules (lua)
3. drl.exe is the drl-specific game engine, which references the wads (drl.wad and core.wad)

### Setting up the source folders:
1. Download DRL source from http://drl.chaosforge.org/
2. Download the DRL binaries (if you haven't already)
3. Copy the following DLLs from the DRL binaries into bin:
  * SDL2.dll (true source: https://github.com/libsdl-org/SDL/releases/tag/release-2.32.0)
  * SDL_mixer.dll (true source: https://github.com/libsdl-org/SDL_mixer/releases/tag/release-2.6.3)
  * SDL_image.dll (true source: https://github.com/libsdl-org/SDL_image/releases/tag/release-2.8.5)
  * fmod64.dll (true source: www.fmod.com/download)
  * (if referencing v0.9.9.8 or less) mp3\\* to (bin\\)data\\drlhq\\music
  * (if referencing v0.9.9.8 or less) wavhq\\* to (bin\\)data\\drlhq\\sounds
  * (if referencing v0.9.9.9 or higher) data\\drlhq\music\\* to (bin\\)data\\drlhq\\music
  * (if referencing v0.9.9.9 or higher) data\\drlhq\sounds\\* to (bin\\)data\\drlhq\\sounds
4. Download fpcvalkyrie from https://github.com/ChaosForge/fpcvalkyrie/ to a folder at the same level as the DRL source
5. Ensure doomrl and fpcvalkyrie are on the same release branch (e.g. master or development)
6. Download lua 5.1 (e.g. 5.1.5) from https://sourceforge.net/projects/luabinaries/files/5.1.5/Tools%20Executables/. Unzip it
7. Add lua5.1 in your path (the location will be referred to as %lua%)
8. Download and install Lazarus 64-bit (the location will be referred to as %lazarus%)
9. Add %lazarus%\\fpc\\3.2.2\\bin\\x86_64-win64 to your path (to support the release package build)

#### Lua5.1 notes
v5.1 is compulsory. DoomRL references the dll by name, and the dynamic headers are written against 5.1. I don't even think it will work due to the changes in env-tables. DRL uses a few sophisticated Lua tricks. Initially the reason to keep being 5.1 compatible for both DRL and JH was due to LuaJIT compatibility, but I guess that point is moot now.

### Visual Studio Code IDE
#### Configuration
[Instructions appropriated from https://stephan-bester.medium.com/free-pascal-in-visual-studio-code-e1e0a240a430]
1. Add %lazarus%\\mingw\\x86_64-win64\\bin to your path (required for gdb, integrated via the Native Debug extension)
2. Install Visual Studio Code
3. Open drl.code-workspace
4. Install the lua extension (by sumneko)
5. Install the OmniPascal - Open Preview (by Wosi)
6. Install the Native Debug extension (from WebFreak)
7. Manage (the cog)/Settings/User/Extensions/OmniPascal configuration
* Default Development Environment: FreePascal
* Free Pascal Source Path: %lazarus%\fpc\3.2.2
* Lazbuild path: %lazarus%
8. In the 'drl' (source) folder, open .vscode/settings.json and update the folders to your locations
9. In the status bar you'll see "OmniPascal: Select project". Click and choose drl.lpi (appears to improve the linking experience, although you'll need to do this each time you load the workspace)

#### Build
0. Open drl.code-workspace
1. Terminal/Run Task/Build makewad.exe (debug)
2. Terminal/Run Task/Build drl.wad, core.wad
3. Terminal/Run Task/Build drl.exe (debug)
4. To debug, Run/Start Debugging. For example, open drl.pas, press F9 at the first line of code, and then start debugging.
5. Terminal/Run Task/Build the release package (all). This won't work on a windows machine without some adjustments to the build script.
You can test all these steps with Terminal/Run Task/Unit test build scripts (noting the release build step may fail).

#### Lazarus notes
The Lazarus installation is preferred to the simpler fpc installation because using fpc triggers an error when the debugger is used.

### The Lazarus IDE
#### Configuration
Nothing further to do!

#### Build
1. Open src/makewad.lpi (with Lazarus). Build. You should receive '...bin\makewad.exe: Success'
2. Start a command prompt and change to the bin folder. Run makewad.exe
3. Open src/drl.lpi. Build. You should receive '...bin\drl.exe: Success'
4. Open up the Run\Run Parameters screen. Correct the working directory to point to your bin folder. Also note the Command Line Parameters, which might change the application's behaviour
5. Run
6. To build the packages, open a command prompt at the drl root folder and run "lua5.1 makefile.lua all". There are also options for lq and hq if you want to change the asset quality.

## Author's notes
All code is (C) 2003-2024 Kornel Kisielewicz

Code is distributed under the GPL 2.0 license (see LICENSE file in this folder)

Original art and sprites (0.9.9.7) by Derek Yu, (C) 2003-2024, licensed under CC BY-SA 4.0. Modified version and additions (0.9.9.8+) by Łukasz Śliwiński, (C) 2024, licensed under CC BY-SA 4.0.

All art is distributed under the CC-BY-SA 4.0 license (see LICENSE file in bin/data/drl/graphics).

sincerely,
Kornel Kisielewicz 
ChaosForge