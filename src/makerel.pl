# version.pl
open(FILE, "version.txt");
open(BAT, ">makerel.bat");
$ver = readline(FILE);
$ver =~ s/\s.*$//g;
$ver =~ s/\.//g;
close(FILE);
print BAT "\@echo off\n";
print BAT "cd release\n";
print BAT "zip doomrl-$ver-windos *.*\n";
print BAT "cd ..\n";
close(BAT);
