# doomrl

DRL a.k.a. doomrl, a.k.a, D**m, the Roguelike, version 0.9.9.8
http://drl.chaosforge.org/

This release is dedicated to Jupiter Hell Classic, the newly announced commercial remake/expansion to DRL:

https://store.steampowered.com/app/3126530/Jupiter_Hell_Classic/

If you enjoy this Open Source release, please consider wishlisting and later buying Jupiter Hell Classic! Also, you might be interested in DRL's modern 3D spiritual successor, Jupiter Hell (yes, it's still turn-based :P):

https://store.steampowered.com/app/811320/Jupiter_Hell/

Parts of this codebase date back to 2002, please do not judge! :P

This FreePascal source code release is provided as is. You can try compiling it using the latest version of Lazarus ( http://www.lazarus-ide.org/ ). You will also need the FPC Valkyrie library ( https://github.com/ChaosForge/fpcvalkyrie/ ), version 0.9.0. You will also probably need the binary files of the full game downloadable from http://drl.chaosforge.org/ (in particular the sound, soundhq, music and mp3 folder contents, and the premade drl.wad and core.wad if you don't want to create it yourself).

Compilation instructions, short version:

1. Download DRL from http://drl.chaosforge.org/
2. Copy bin/mp3, bin/music, bin/sound, bin/soundhq from the DRL folders to the source tree bin folder
3. Download 64-bit Lazarus
4. Open src/makewad.lpi build, do not run
5. Run makewad.exe from the command line in the bin folder to generate drl.wad and core.wad (precompiled lua files)
6. Open src/drl.lpi, build and run
7. Profit (?)

Lua makefile path (tested on Windows, might work on Linux):

1. Have lua (5.1 is tested, but any should work?) in your path
2. Have fpc bin directory in your path
3. From the root folder run lua5.1 makefile.lua
4. You can build packages by running "lua5.1 makefile.lua all" or lq or hq

All code is (C) 2003-2024 Kornel Kisielewicz

Code is distributed under the GPL 2.0 license (see LICENSE file in this folder)

Original art (0.9.9.7) and sprites by Derek Yu, (C) 2003-2024, licensed under CC BY-SA 4.0. Modified version and additions (0.9.9.8+) by Łukasz Śliwiński, (C) 2024, licensed under CC BY-SA 4.0.

All art is distributed under the CC-BY-SA 4.0 license (see LICENSE file in the bin/graphics/ folder).

sincerely,
Kornel Kisielewicz 
ChaosForge