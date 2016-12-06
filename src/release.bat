@echo off
cp release/*.zip archive
rm release/*.*
cp d:\temp\doomrl.exe d:\projekty\doomrl\release
cp d:\temp\makewad.exe d:\projekty\doomrl
makewad
cp doomrl.wad release
perl help/makeman.pl
copy help\manual.txt release
copy version.txt release
perl makerel.pl
call makerel
rm makerel.bat
