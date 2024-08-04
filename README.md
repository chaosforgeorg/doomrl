# doomrl

DRL a.k.a. doomrl, a.k.a, D**m, the Roguelike
http://drl.chaosforge.org/

This release is dedicated to *eniMax, and the Jupiter Hell Kickstarter:

https://www.kickstarter.com/projects/2020043306/jupiter-hell-a-modern-turn-based-sci-fi-roguelike

If you enjoy this Open Source release, please consider pledging!

Parts of this codebase date back to 2002, please do not judge! :P

This FreePascal source code release is provided as is. You can try compiling it using the latest version of Lazarus ( http://www.lazarus-ide.org/ ). You will also need the FPC Valkyrie library ( https://github.com/ChaosForge/fpcvalkyrie/ ). You will also probably need the binary files of the full game downloadable from http://drl.chaosforge.org/ (in particular the sound, soundhq, music and mp3 folder contents, and the premade drl.wad and core.wad if you don't want to create it yourself).

The current public versions are 32-bit, but going forward only 64-bit releases will be supported.

Detailed compilation instructions will appear at some later point after the Jupiter Hell Kickstarter finishes.

Short version:

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

All code is (C) 2003-2023 Kornel Kisielewicz

Code is distributed under the GPL 2.0 license (see LICENSE file in this folder)

All art is (C) 2003-2023 Derek Yu

Art is distributed under the CC-BY-SA 4.0 license (see LICENSE file in the bin/graphics/ folder)

sincerely,

Kornel Kisielewicz of ChaosForge
