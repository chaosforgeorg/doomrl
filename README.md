# doomrl

DRL a.k.a. doomrl, a.k.a, D**m, the Roguelike
http://drl.chaosforge.org/

This release is dedicated to *eniMax, and the Jupiter Hell Kickstarter:

https://www.kickstarter.com/projects/2020043306/jupiter-hell-a-modern-turn-based-sci-fi-roguelike

If you enjoy this Open Source release, please consider pledging!

Parts of this codebase date back to 2002, please do not judge! :P

This FreePascal source code release is provided as is. You can try compiling it using the latest version of Lazarus ( http://www.lazarus-ide.org/ ). You need to download the 32 bit version (64-bit is possible, but much more tricky). You will also need the FPC Valkyrie library ( https://github.com/ChaosForge/fpcvalkyrie/ ). You will also probably need the binary files of the full game downloadable from http://drl.chaosforge.org/ (in particular the sound, soundhq, music and mp3 folder contents, and the premade doomrl.wad and core.wad if you don't want to create it yourself).

Detailed compilation instructions will appear at some later point after the Jupiter Hell Kickstarter finishes.

Short version:

1. Download 32-bit DRL from http://drl.chaosforge.org/
2. Copy bin/mp3, bin/music, bin/sound, bin/soundhq from the DRL folders to the source tree bin folder
3. Download 32-bit Lazarus
3.1. Get a 32-bit SDL 1.2.x. (On Mac OS X) Copy the SDL framework to /Library/Frameworks/.
3.2. (On Mac OS X) Get patched SDL_image.framework at https://github.com/ChaosForge/doomrl/issues/4. Copy it to /Library/Frameworks/.
3.3. Build a 32-bit libSDLmain.a using [these instructions](http://wiki.freepascal.org/FPC_and_SDL#SDL_headers_from_JEDI-SDL)
3.4. Get a 32-bit Lua libraries. 5.1.4 worked once.
3.5. Copy libSDLmain.a and liblua5.1.a to DRL directory.
3.6. (On Mac OS X) see Makefile.macosx for build hints.
4. Open src/makewad.lpi build, do not run
5. Run makewad.exe from the command line in the bin folder to generate doomrl.wad and core.wad (precompiled lua files)
6. Open src/doomrl.lpi, build. Or use `lua makefile.lua install` to build from command line (the only way that works on Mac OS X)
7. (On Mac OS X) debugging DRL on Mac in Lazarus should require installing gdb and [codesigning it](https://sourceware.org/gdb/wiki/BuildingOnDarwin#Giving_gdb_permission_to_control_other_processes)
lldb already works.

7. Profit (?)

All code is (C) 2003-2016 Kornel Kisielewicz

Code is distributed under the GPL 2.0 license (see LICENSE file in this folder)

All art is (C) 2003-2016 Derek Yu

Art is distributed under the CC-BY-SA 4.0 license (see LICENSE file in the bin/graphics/ folder)

sincerely,

Kornel Kisielewicz of ChaosForge
