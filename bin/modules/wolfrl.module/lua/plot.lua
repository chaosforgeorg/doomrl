-- DoomRL plot lua script file --

-- This function is called directly by the engine.  Challenges can override it though.
function DoomRL.OnIntro( skip )
	if skip then return end
	return DoomRL.ep7_OnIntro()
end


--The rest are called whenever and wherever I want them.
function DoomRL.plot_intro_1()
	ui.blood_slide()
	ui.plot_screen([[


Your mission was to infiltrate the Nazi fortress Castle Hollehammer and find the plans for Operation Eisenfaust (Iron Fist), the Nazi's blueprint for building the perfect army. Rumors are that deep within Castle Hollehammer the diabolical Dr. Schabbs has perfected a technique for building a fierce army from the bodies of the dead. It's so far removed from reality that it would seem silly if it wasn't so sick. But what if it were true?]])
	ui.plot_screen([[


You were never given the chance to find out! Captured in your attempt to grab the secret plans, you were taken to the Nazi prison Castle Wolfenstein for questioning and eventual execution. Now for twelve long days you've been imprisoned beneath the castle fortress. Just beyond your cell door sits a lone thick-necked Nazi guard. He assisted an SS Dentist/Mechanic in an attempt to jump start your tonsils earlier that morning.]])
	ui.plot_screen([[


You're at your breaking point! Quivering on the floor you beg for medical assistance in return for information. His face hints a smug grin of victory as he reaches for his keys. He opens the door, the tumblers in the lock echo through the corridors and the door squeaks open. HIS MISTAKE!]])
	ui.plot_screen([[


A single kick to his knee sends him to the floor. Giving him your version of the victory sign, you grab his knife and quickly finish the job. You stand over the guard's fallen body, grabbing frantically for his gun. You're not sure if the other guards heard his muffled scream. Deep in the belly of a Nazi dungeon, you must escape. This desperate act has sealed your fate—get out or die trying.]])
end
function DoomRL.plot_outro_1()
	ui.blood_slide()
	ui.plot_screen([[



You run out of the castle and hook up with the Underground. They inform you that the rumors were true: some hideous human experiments were seen around Castle Hollehammer.
      
So Operation Eisenfaust is real...
]])
	ui.plot_screen([[



You must journey there and terminate the maniacal Dr. Schabbs before his undead army marches against humanity!
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
And in Episode 3, Hitler hides in his titanic bunker as the Third Reich crumbles around him! It is your job to assassinate him, ending his mad regin.]])
end
function DoomRL.plot_intro_2()
	--none
end
function DoomRL.plot_outro_2()
	ui.blood_slide()
	ui.plot_screen([[


You stand over Schabbs' fat, evil, swollen, putrid body, glad your mission is finally over. All his journals and equipment will be destroyed. Humanity is safe from his hordes of hideous mutants.
      
Yet the Nazi atrocities continue: thousands march into death camps even as the Nazi war machine falls to its knees. There is only one way to stop the madness...]])
end
function DoomRL.plot_intro_3()
	--none
end
function DoomRL.plot_outro_3()
	ui.blood_slide()
	ui.plot_screen([[



The absolute incarnation of evil, Adolf Hitler, lies at your feet in a pool of his own blood. His wrinkled, crimson-splattered visage still strains, a jagged-toothed rictus trying to cry out.
Insane even in death.]])
	ui.plot_screen([[




Your lips pinched in bitter victory, you kick his head off his remains and spit on his corpse.
      
Sieg heil, huh. Sieg hell.]])
end
function DoomRL.plot_intro_4()
	--none
end
function DoomRL.plot_outro_4()
	ui.blood_slide()
	ui.plot_screen([[


The twisted scientist behind the chemical war lies at your feet, but the fruits of his labor grow elsewhere! The first wave of chemical war is already underway. In the heavily guarded fortress of Erlangen are the plans for the upcoming Giftkrieg (or Poison War). Find them and you'll know where to find General Fettgesicht, leader of the deadly assault.]])
	ui.plot_screen([[



So don't wait! Start the next adventure and find those plans!]])
end
function DoomRL.plot_intro_5()
	--none
end
function DoomRL.plot_outro_5()
	ui.blood_slide()
	ui.plot_screen([[



Gretel Grosse the giantess guard has fallen.
      
Hope her brother Hans doesn't get mad about this...]])
	ui.plot_screen([[



Now rush to the military installation at Offenbach and stop the horrible attack, before thousands die under the deadly, burning clouds of chemical war. Only you can do it, B.J.]])
end
function DoomRL.plot_intro_6()
	--none
end
function DoomRL.plot_outro_6()
	ui.blood_slide()
	ui.plot_screen([[


The General gasps his last breath, and the free world is safe from the terrifying Nazi chemical war. You return to Allied Headquarters, a Medal of Honor waiting for you.
      
Allied Command informs you of some nefarious activities around Castle Hollehammer. Something about some grey-skinned berserk soldiers...]])
	ui.plot_screen([[


You did it! You have finished the sixth episode of Wolfenstein! The world cheers your name! You get your picture taken with the President! People name their babies after you! You marry a movie star!
      
Yes! You are so cool!]])
end
function DoomRL.plot_intro_7()
	ui.blood_slide()
	ui.plot_screen([[


You're behind enemy lines, among the bushes far below the Nazi stronghold. A set of sewer tunnels lead to the lowest depths of the castle's dungeons. Above them stands the huge castle itself. Within lies the item which could control the fate of mankind. Hundreds of Nazi soldiers and thousands of Nazi bullets stand in your way
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
You quietly enter the moss-covered tunnel.
]])
	ui.plot_screen([[


Unknown to you and unnoticed by the nearby guards, an unnatural glow radiates from high within the tower. Feeling as if you're being watched you quietly slip a fresh magazine into your pistol, ready for what lies ahead. But nothing could prepare you for the conflict that awaits as you battle for the Spear of Destiny.]])
end
function DoomRL.plot_outro_7( isFull )
	ui.blood_slide()
	if (isFull) then
		ui.plot_screen([[


You were found by Allied Forces on a grassy hill far away from the smoking ruins of Castle Nuremberg; the spear clutched in your blistered hands, a thin wispy smoke rising from your still body. The grass beneath you appeared burned by fire.
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
In the Allied hospital you tell no one of your frightening confrontation with the Angel of Death lest they think you mad.]])
	else
		ui.plot_screen([[


You were found by Allied Forces on a grassy hill far away from the smoking ruins of Castle Nuremberg; a weapon clutched in your blistered hands, a thin wispy smoke rising from your still body. The grass beneath you appeared burned by fire.
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
The spear is gone; reclaimed to you, destroyed to Allied Command. You tell no one of your surreal defeat at the hands of the Angel of Death lest they think you mad.]])
	end
	ui.plot_screen([[


But you still bear the scars of the other great foes of the castle, dark and deadly, starkly vivid in your memory. All fighting to defend this holy relic. To keep Hitler's twisted dream alive.
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
With the Spear gone the Third Reich will fall.
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
May it never rise again.]])
	ui.plot_screen([[



"We owe you a great debt Mr. Blazkowics. You have served your contry well. With the spear gone the Allies will finally be able to defeat Hitler..."
ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ
But that's another story!]])

	--If possible I'd really like to close out on ascii end graphics similar to the ones at the end of SoD.
end
