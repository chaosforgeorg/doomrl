The Elevator of Dimensions will take you on a journey through space and time.  It is an invasion style map that uses SkulltagRL as a base.  That means most things are scripted--levels aren't generated randomly, nor are most items and enemies.

Levels:
* RAID the Pharaoh's tomb!
* TORCH the baron enclave!
* RANSACK the German castle!
* ZAP the computer corridor!
* SHOWER the outer limits!

Difficulty levels:
Since monsters and items aren't spawned randomly XP is given a flat modifier based on difficulty.  Higher difficulty slows level gain and ups enemy accuracy (that last part is as it normally is).  Ideally the difficulty curve should follow this spread:
* ITYTD: A player familiar with the waves can get through without casualty and without relying on overpowered builds or cheap tactics.  Ammo shortages will be the bigger threat.
* HNTR:  A player can expect to suffer in the tricky spots or they can corner shoot everywhere.  A good player with a good build and careful tactics might still clear this without casualties.
* HMP:   Player casualties will start to mount up but a good build will prevent getting stuck in a loop of carnage and death.
* UV:    Even using every dirty trick in the book player casualties will be all too common.  One shot kills will be a reality and cycles of death and rebirth distressingly common as you try to get a handle on the demon hordes.
* N:     You're dead, you just don't know it yet.

Monsters:
* In addition to enemies found and derived from Doom you can expect to see enemies from Blood, Duke 3D, and a host of other odd games I don't recognize.

Issues:
* The player name is treated as part of the HUD now with an enemy count as well as an active powerup/rune display.  In previous revisions the level name served thie purpose; 0996 invalidates that.  Consequently looking at yourself displays the adapted HUD text instead and the powerup color coding is gone.  Lesser of three evils...
* Color flashes don't work quite right.  This has been mitigated for now but once they are fixed they'll need to be returned to their proper state of being.
* Better rips of the music would be nice as to get them to loop correctly I had to re-encode them and they were already lossily compressed.
* No doubt there are some balancing tweaks that could be implemented.  I was very careful with the first level and moderately careful with the second.  After that it is difficult to get a good measure since builds can diverge very heavily.
* You know how the mastermind's shots, when being spread across an area, all come at once?  I would really like a hack to circumvent that.

Future:
* Add being ascii art
* When possible, add sprites
* When possible, add the other HUD stuff that's kludged in
* Fix other issues and balancing concerns

Credits:
* GH for AI
* Other guys on IRC who probably helped in some way
* The testers, mostly
* The guys who originally make the EoD for Skulltag for the obvious inspiration, and by proxy, everyone they stole content from

Dedications:
* For all coffee makers
* For all disco lovers
* For all the paranoids
* For all the psychopaths

Changelog:

v0.9.2
------
Scaled experience gains down.  Seems there's no way to make a boss scary to a sufficiently prepared doomguy.  So now you can't be that prepared.
Since there are no spawn rate differences UV and N! difficulties now give enemies damage bonuses while ITYTD and HNTR give damage penalties.
Badge requirements have changed to be harder since it took all of three runs for TWO people to get angelic.
Prosperity nerfed, is no longer as good as MEDPLUS
Level 3 should be faster paced and less dull now.
Fixed boss level river
AI and HP tweaks to keep the boss alive long enough to do cool things before Tormuse kills it.

v0.9.1
------
Sound binding fixes, also monster that should drop rockets was not dropping rockets
Beefed up clones to make them more of a threat and make them appear more often

v0.9.0
------
First public release for DoomRL 097.  1.0 will be whatever version makes it to the mod server; KK has stated that won't happen without G support.
