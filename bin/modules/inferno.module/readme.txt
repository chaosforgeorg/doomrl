DoomRL: Inferno
version 0.15.1
by tehtmi

A difficult module for DoomRL version 0.9.9.6

Thanks to: add, Ander Hammer, Battleguy, Game Hunter, Gargulec, shark20061, Simon-v, Ushiki, V1cT

Special thank to: Kornel Kisielewicz

To play Inferno, extract the contents of the Inferno package into the modules subdirectory of your DoomRL folder. You will then be able to select Inferno from DoomRL's Custom Game menu.

I encourage you to play this mod without reading the sources, but I have left the sources uncompiled as a courtesy to other modders. Anyone is welcome to use any of my code for whatever purpose they want. In fact, I encourage it! The code isn't especially documented, so if you want to know how a feature works, then please ask me.

Feedback is very welcome. Praise, criticism, bug-reports, balance suggestions, screenshots, YASDs, YAVPs: bring 'em on!

The included sounds are the property of Blizzard Entertainment or id Software. Used without permission.

Version History:

version 0.15.1

[add] New rare level type.
[mod] Some levels now have trees.
[mod] Teleports take less time for the player to use.
[mod] Warp rooms are more noticeable.
[mod] Hellfire Pack nerfed on 1dX weapons.
[mod] Tracking map (and similar effects) reveal invisible enemies.
[mod] Intuition's being sense now helps against invisible enemies.
[mod] Minor Antenora tweaks.
[mod] Improved one of the secret rewards.
[mod] Cinder speed increased.
[mod] Cinders and hydras will now use superior pathfinding.
[mod] Tweak Acheron difficulty.
[mod] Starting loadout is reported in player history.
[mod] Increased the wake-up radius for most monsters.
[fix] MacOS users should be able to run the raw version (no compiled sources).
[fix] Uncommon infinite loop on level creation fixed.
[fix] Warp room crash fixed.
[fix] 'Sniper' kills only need to be more than 8 tiles away.
[fix] Basement completion checking improved on Nightmare!
[fix] Mortem should no longer report an incorrect kill rate.
[fix] Fixed revenant action sound.
[fix] Better respect for BF_HUNTING in a few places.
[fix] Tweaked Vindictive Cross condition.
[fix] Ptolomea can no longer be escaped by rocket jumping.
[fix] Medals are now outputted in a more sensible order.
[fix] Typo fix(es).
[fix] Fixed lots of graphics.

version 0.15.0 (first public release)

[add] Sounds for achlyses and asuras.
[mod] Made The Acheron a bit easier.
[fix] Fixed a possible access violation in The Acheron.

version 0.14.4

[add] New exotic item.
[add] Two new basements.
[mod] Acheron enemy placement revamp.
[mod] Warren level type tweaked for fewer walls.
[mod] Caves level type monster generation tweaked.
[mod] A few aesthetic improvements.
[mod] All statistics are now tracked per level.
[mod] Mortem changes.
[mod] Item using enemies can auto-pick-up a nearby item on level creation.
[mod] Removed lost soul spawning from Doomtrain
[fix] Fixed invulnerability + nuke on last level.
[fix] Invisibility level transition bug.
[fix] Typos, missing messages fixed.
[fix] Minor issue with glacier levels resolved.
[fix] Dodge bonus of items no longer disappears.
[fix] Basements don't break max kill counting.
[fix] Carnival of Death reward now triggers.
[fix] Problems with explorer/conquerer medals.
[fix] Nightmare hydras don't crash.

version 0.14.3

[add] New level eventy stuff.
[add] New secret.
[add] One new basement.
[mod] Inferno assembly tweaks.
[mod] Mortem now shows medal descriptions (shark)
[mod] Ammo packs can drop in vaults.
[mod] Achlys damage reduced; now piercing.
[mod] Shambler frequency reduced.
[fix] Various mortem issues (thanks shark).
[fix] Hell Keep/imp "ai" bug.
[fix] Inferno assembly recipes changed to avoid conflicts (thanks Ushiki).
[fix] The same basement can no longer be generated more than once per game.
[fix] Hydras should respect BF_HUNTING better.
[fix] Problem with swamp levels fixed.
[fix] Technomanse no longer crashes on entry (sorry!)
[fix] Erebus and Blood Temple completion fixes (shark)
[fix] Initial pass on graphics. Better but still ugly and broken.
[fix] Asura attacks use shotgun sound again.
[fix] An issue has been resolved with Carnival of Death (will be easier)

version 0.14.2

[fix] Infernal Sanctuary no longer crashes on entry (sorry!)

version 0.14.1

[fix] Took out ui.delay. Goodbye animation :(

version 0.14.0

[add] Ported to DoomRL version 0.9.9.6. (Graphics not supported yet)
[add] New level feature: Basements (more coming soon!)
[mod] Experimental Acheron revamp.
[mod] Small Singularity nerf.
[fix] All existing sounds should be loading properly now. (Many haven't been added yet.)
[fix] Fix issue with save/continue and special levels.
[fix] Duplicate mods no longer get removed on level transitions.

version 0.13.1

[mod] Singularity tweaks. Should be harder.
[mod] Finished work on message tweak/additions/removals. (for now)
[fix] Sound loading works again.
[fix] Got rid of error when picking up uniques in special levels.
[api] Some as-yet unused lib_being work.

version 0.13.0

[mod] Level event refactoring (and changed rates).
[mod] Various message tweaks/additions/removals.
[mod] Removed the lava passage from Hell Keep.
[fix] Saving now works!
[fix] Medals can now require victory as intended.
[fix] Undertaker medals removed pending a proper fix.
[fix] Disallowed an unfortunate level event/level type combination.
[fix] Shotgun autopickup only works in Hell Keep.
[???] Replaced the old unique emulation hack with a history message replacement hack.
[???] Other various refactoring.

version 0.12.0

[add] Ported to DRL version 0.9.9.5
[add] New final level.
[add] New level types.
[add] New levers.
[mod] Hell Keep layout tweaks.
[mod] LurkAI tweaks/fixes.
[mod] Lowered achlys out-of-combat blink frequency.
[mod] Now uses built-in episode system.
[mod] Invisibility is now a real effect/affect.
[mod] Invisibility globe color changed to purple.

version 0.11.0

[---] Unfinished, limited release.

version 0.10.0

[---] Unfinished, limited release.
[add] Ported to DRL version 0.9.9.4
[mod] Built-in difficulty selection is used.
[mod] Welcome level has changed.
[mod] Removed the Thomas Clause.
[mod] The inferno AI is now backed by lua AI instead of pascal AI.
[mod] Reduced HP of most abyss enemies.
[fix] Cell HP works.

version 0.9.0

[---] Unfinished, limited release.
[add] There are now a bunch of medals!
[add] Added some statistics to the mortem.
[add] New challenge mode. It's ... hard.
[add] New uncommon level type (acid swamp).
[mod] Monster generation method tweaked to be more consistent.
[mod] As a result, earlier levels and UV may be a bit easier. (Comments welcome!)
[mod] Added an island near the shotgun in Hell Keep.
[mod] Some monsters' exp rewards have been tweaked.
[mod] Achlys damage decreased.
[mod] Vault monster quantity now matches baseline DoomRL.
[mod] Nightmare! speed emulation is disabled.
[mod] The Backpack is now accompanied by ammo (as was originally intended).
[mod] Monster generation on battlefield levels tweaked.
[fix] Quashed a bug with the Sanctuary's reward.
[fix] Fixed a bug with Backpack generation.
[fix] Invisible enemies no can no longer make other enemies disappear.
[fix] Unique items (and invisibility globes) now drop again. (For real this time!)
[fix] Minor tweak to cinder AI.

version 0.8.0
[add] Invisibility powerup.
[add] Welcome BackPack!
[add] New artifact for an old special level.
[add] Medals implemented; not many to start with.
[add] Hydras now have their own sound-set.
[add] New special level.
[mod] Room generation tweaked.
[mod] City rooms only spawn in larger rooms, but more likely there.
[mod] Increased lever to teleport ratio.
[mod] Teleporters no longer occur inside large rooms.
[mod] Achlys teleport range is now restricted.
[mod] Arch-viles don't occur as often in corpse rooms.
[mod] The floor of the player's death is now recorded properly at the top of the mortem.
[mod] As a result of the above, level enter spam is removed from history messages.
[mod] Other mortem history messages now report a level again.
[mod] Tweaked Dis layout.
[mod] Cinders are now immune to acid and lava.
[fix] Unique items now drop. (Most couldn't before.)
[fix] Artifact find messages are now modified as other unique find messages.
[fix] Warp room bug squashed. (alpha 7b)
[fix] Item pickup messages in AoMr and AoSh are fixed.
[fix] Cover rooms no longer create cover next to walls.
[fix] Pain elementals now use the lurking AI tweak.
[fix] Mortem properly reports Spider Mastermind kill/win by sacrifice.
[fix] Cinders no longer attack without line-of-sight.

version 0.7.0
[add] New rare level type.
[add] Implemented more challenges: Marksmanship, Shotgunnery, Masochism, Humanity
[mod] Former commandos are slightly more common.
[mod] Rooms in caves require a bit less lava wading.
[mod] Doors in corners of rooms no longer occur in caves.
[mod] Doors no longer appear next to each other in caves.
[mod] New ranged enemies have proper line of sight. (They can be corner tricked now.)
[mod] Warp rooms rebalanced, have greater enemy variety.
[mod] Tweaked corpse selection in corpse rooms.
[fix] Crushed barrels now explode.
[fix] Crusher + nuke = ?
[fix] Added the unique item level feeling.
[fix] Challenges can no longer be played on I'm Too Young To Die.
[fix] No repeated level entry history messages on levels 15 and 25.

version 0.6.0
[add] Challenge framework. AoB is added.
[mod] Monster wake-up propegation now respects walls.
[mod] Cost to use Erebus reward halved.
[mod] Mortem history difficulty messages match real DoomRL mortem difficulty messages.
[mod] Mortem history messages will no longer redundantly report level.
[fix] Changed unique item player histroy message. (Doesn't say "level 0".)
[fix] Mortem no longer speaks of a "custom location".
[fix] Setting a nuke and then leaving no longer gives exp or kills.
[fix] "You enter Level X" message now occurs before level feelings.

version 0.5.0
[add] Rooms can now have multiple features.
[add] New room features.
[mod] Cinder picture changed to "e".
[mod] Pain elementals are more common.
[mod] Readded minimum floor for level events.
[mod] Added a few monsters to Singularity.
[mod] Demons and lost souls now use the startle system. Also spectres.
[mod] Achlys changed from light teal to teal.
[mod] Number of monsters reduced on braid levels to make up for smaller size.
[mod] Shadow orb is now black.
[fix] H mod works properly on melee weapons.
[fix] Super shotgun changed to x2 a la double shotgun (and F now works on it).
[fix] Scout armor: "Targetting" -> "Targeting"

version 0.4.0
[add] Difficulty ammo drop modifier emulated.
[mod] Asuras now drop shells.
[mod] New assemblies no longer have to be reeqipped. (add)
[mod] New assemblies are no longer indestructable.
[mod] Scout armor's protection increased by 1.
[mod] Autoequip of shotgun is now instant.
[mod] Slightly less lava wading on Hell Keep.
[mod] Fewer imps in your face after Hell Keep bridge.
[mod] Fewer cacodemons on Hell Keep. :(
[mod] Spider Mastermind HP scaling toned down.
[mod] Spider Mastermind now avoids melee.
[mod] Shadow demon HP scaling added.
[mod] Shadow demon speed increased (a smidge).
[mod] Achlys min level increased by 1.
[mod] Hydras are now green.
[mod] Hydras are slightly slower.
[mod] Hydras no longer have a blast radius attack.
[mod] Hydras split a bit less rapidly.
[mod] Cave levels appear a bit less often.
[mod] Cave levels with rooms now have monster quantity more in line with normal caves.
[mod] Tweaked door placement in cave rooms.
[mod] Double shotgun damage is correctly reported as x2.
[mod] Firestorm pack now has a useful effect on double shotguns.
[mod] Cell armor returned to 0.9.9.0 values. (see above)
[fix] Singularity spawned monsters no longer give exp. (But closing portals gives exp.)
[fix] Summon levers work properly again
[fix] Singularity: "here" -> "hear"
[fix] Blood Temple: "worshipers" -> "worshippers"
[fix] "achlyss" -> "achlyses"

version 0.3.0
Big Stuff:
[add] Some new monsters.
[add] A bunch of all-new special levels!
[add] Some new level generation stuff.
[add] A few new assemblies.
[add] Lots of features that already exist in DoomRL emulated in sandbox.
[mod] Monster ai is changed; most monsters will not move around the level until they see the player.
Small Stuff:
[mod] Player starts with steel boots equipped and combat knife prepared.
[mod] Monsters now use a startle sound binding.
[mod] A couple of soundbindings changed to be more true to Doom.
[mod] Chainsaw does not drop randomly. Same for bfg.
[mod] Permanent bloodstone walls can now be blooded.
[mod] Small vaults will not have item drops overridden by enemies.
[mod] Ammo no longer spawns in vaults.
[mod] Monster groups now generate in proximity.
[mod] Monster generation is completely group-based.
[mod] Probably other things that I forgot.

Since there is no way to find schematics for the new assemblies, I'll list their recipes here for anyone who wants to be spoiled without looking at the source files.

[spoiler]
scout armor: green armor + AP
powered exoskeleton: blue armor + BB
shield boots: protective boots + BP
enhanced shield boots: plasteel boots + BPP
[/spoiler]