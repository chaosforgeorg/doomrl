This is Skulltag Arena, the most likely last variant on the infinite arena that I will do.  It is based on the Skulltag source port--go play that if you want to call yourself a doomer.

Skulltag is like doom, only with more.  In roguelike terms, skulltag is DoomRL's Slash'EM.  New weapons have been added to match Skulltag's lineup, new powerups, new monsters, and new runes!


Weapons:
The chainsaw, minigun, railgun, and BFG9/10K are now standard weapons.

Powerups:
All powerups have been recreated owing to affects being a bit limited.  This means that a berserk pack won't change your status on the HUD or make the screen flash red.  On the other hand we now have turbo spheres, invisibility spheres, and even a time freeze powerup!

Runes:
Skulltag runes are bonus granting items that never expire but you can only pick up one rune at a time.  Pick up a prosperity rune?  Health powerups will count up to 250%.  Pick up a rage rune later?  Your health bonus expires but now your reload and fire speeds are decreased!

Monsters:
Skulltag's beefed up versions of barons demons and cacos
Rocket and double shotgun wielding soldiers
Suicide Skulls and Spectres
The Bruiser Demon and Diabloist!

Issues:
Powerup effects don't have any interface screws
Powerups no longer have color specific HUD text (obviously the whole using your NAME is a currently necessary hack to get you anything at all, but older versions had color coding too)
G-mode ascii characters differ from console mode ascii characters.  Result: rune powerup status indicator is displayed incorrectly in G-mode.  May also affect unnecessary umlauts.
Drain rune only triggers on being death; would be nice to get it on being damage in a non-hacky manner.
Sound binding is a god-awful mess.  It mostly works but there are a few which aren't for some reason...
No new sprites are possible in 0997 so the new content is all overlayed original sprites.  Brown became my new favorite color doing that.
The berserker trait will proc the original berserk status affect, not the skulltag variant.  There is nothing I can do about this.  The standard berserk affect greatly increases your defensive prowess in ways the Skulltag one intentionally does not.

Future:
Keep updated, fix bugs
Changelog:

v1.0.1
------
Bug fixes
Suicide skull speed nerfed since his charge is, well, a suicide attack
Some sounds (re)mapped

v1.0.0
------
0997 released!  SkulltagRL also synced to new major version.  No other change.

v0.9.9
------
Added simple badges

v0.9.8
------
Just a port to the latest DoomRL, nothing 'proper' about it

v0.9.7 (Since modules now have a three digit version I can't go .1 at the end)
------
Proper update that uses the newer concepts
Runes and Powerups are fun so I added a special mode that ups the spawn rate.  I could add more configs if requested, though as a bonus to source divers a lot of constants are easily tweakable
Level memory adjusted.  No more can you scout the map once and be omniscient afterwards; items are hidden after each round.  Tracking maps and computer maps still work, but only for one and five rounds respectively.
 This results in a weird AoDarkness-like effect every round but it's worth it
Partial Invis powerup changed, Total Invis powerup added
Prosperity no longer grants badass (was too powerful for such a low level since now marines get that as basic trait)
Rate of enemies decreased along with the rate of items.  Experience also raised to match.  This should reduce the 'swarm' feeling.
A plethora of porting bugs that weren't serious enough to cause crashes have been exterminated.
A plethora of porting bugs that were serious enough to cause crashes have also been exterminated.
The usual array of small tweaks and tricks.  No more 0.00 movement speed bug for instance.

v0.9.6
------
Updated for DoomRL 0.9.9.4.  Minimal actual gameplay changes; those are coming soon.

v0.9.5.1
------
Balance tweaks.  To wit:
Being groups disabled for now
Harder enemies more likely to spawn
Difficulty levels now set the global DIFFICULTY variable.  Hard is now hard!
Boss spawns by level 25
Diabloist and boss slightly buffed, will be buffed more if desired

v0.9.5
------
Updated for DoomRL 0.9.9.2!
Reflection Rune!
New boss enemy!
Lots of little tweaks that weren't possible before!

v0.9.1
------
revamped item and monster selection.  Should be a smoother, more even experience now.
Tweaked a few monsters, weights, and other odd things
Four difficulties!  Changes the speed at which you advance through rounds

v0.9.0
------
New monsters and the structuring needed to support them

v0.8.7
------
Time freeze fixed

v0.8.6
------
HUD now displays active runes and powerups!
Drain rune fixed
Strength rune bonus reduced
Resistance rune bonus reduced

v0.8.5
------
File now split into multiple nicely encapsulated sections.  Which are themselves files.
Railgun added from You's invasion mod!
Minigun has new firing sound
All runes are light green until powerup ascii can be altered
Many hacks not hackish now


v0.8.1
------
A few minor tweaks as suggested by IRCers
NPC selction should be a bit more even now
Rewards should also be a bit more linearly scaled now


v0.8
------
Initial beta release
