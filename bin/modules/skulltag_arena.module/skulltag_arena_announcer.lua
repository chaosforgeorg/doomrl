
--Announcer fluff.  Completely inconsequential to gameplay and with no variables.
Skulltag.AnnouncerPlaySound = function (arg_soundname)
  --This USED to be a wrapper so that users could disable the announcer if they hated him.
  --But the new module logic doesn't really work that way, so...
  local sound = core.resolve_sound_id(arg_soundname)
  if(sound ~= 0) then
    player:play_sound(sound)
  end
end
Skulltag.AnnouncerIntro = function ()
  ui.msg("A devilish voice announces:")
  ui.msg("\"Welcome to Hell's Arena, mortal!\"")
  ui.msg("\"You are either very brave or very foolish. Either way I like it!\"")
  ui.msg("\"And so do the crowds!\"")
  ui.msg("Suddenly you hear screams everywhere! \"Blood! Blood! BLOOD!\"")
  ui.msg("The voice booms again, \"Kill all enemies and I shall reward thee!\"")
end
Skulltag.AnnouncerContinueAsk = function ()
  if (Skulltag.Round <= 1) then
    ui.msg("The voice booms, \"Not bad mortal! For a weakling that you")
    ui.msg("are, you show some determination.\"");
    ui.msg("You hear screams everywhere! \"More Blood! More BLOOD!\"")
    ui.msg("The voice continues, \"I can now let you go free, or")
    ui.msg("you may try to complete the challenge!\"")
  elseif (Skulltag.Round <= 2) then
    ui.msg("The voice booms, \"Impressive mortal! Your determination")
    ui.msg("to survive makes me excited!\"")
    ui.msg("You hear screams everywhere! \"More Blood! More BLOOD!\"")
    ui.msg("\"I can let you go now, and give you a small reward, or")
    ui.msg("you can choose to fight an additional challenge!\"")
  else
    --Randomly build an announcer message
    ui.msg(table.random_pick( {
    "The voice booms, \"Congratulations mortal!",
    "The voice booms, \"Impressive mortal!",
    "The voice booms, \"Most impressive.",
    "The voice booms, \"You are a formidable warrior!"
    } ))
    ui.msg(table.random_pick( {
    "The blood you paint on the arena is like art",
    "You are a natural born killer.",
    "You've given us a great show.",
    "You would be a great addition to Team Hell."
    } ))
    ui.msg(table.random_pick( {
    "But can you keep going?\"",
    "How much longer can you go?\"",
    "Will you fight with us a little more?\"",
    "I can let you go now if you like, or...\""
    } ))
  end
end
Skulltag.AnnouncerContinue = function()
  ui.msg(table.random_pick( {
  "The voice booms, \"I like it! Let the show go on!\"",
  "The voice booms, \"Excellent! May the fight begin!!!\"",
  } ))
  ui.msg(table.random_pick( {
  "You hear screams everywhere! \"More Blood! More BLOOD!\"",
  "You hear screams everywhere! \"Kill, Kill, KILL!\"",
  } ))
end
Skulltag.AnnouncerQuit = function ()
  if Skulltag.Round <= 1 then
    ui.msg("The voice booms, \"Coward!\" ")
    ui.msg("You hear screams everywhere! \"Coward! Coward! COWARD!\"")
  elseif (Skulltag.Round <= 2) then
    ui.msg("The voice booms, \"Too bad, you won't make it far then...!\" ")
    ui.msg("You hear screams everywhere! \"Boooo...\"")
  elseif (Skulltag.Round < 20) then
    ui.msg("The voice booms, \"An impressive run, Mortal!  We appreciate it!\" ")
    ui.msg("the crowd starts to chant! \"Encore! Encore!\"")
  else
    ui.msg("\"Ladies and gentlemen, your champion, " .. Skulltag.HUD.PlayerName .. ".")
    ui.msg("He survived " .. Skulltag.Round .. " rounds in our arena!")
    ui.msg("That has to be some sort of record.  Give him a hand folks!\"")
    ui.msg("the crowd starts to chant your name")
    ui.msg("and they begin throwing items into the ring!")
  end
end
Skulltag.AnnouncerLeave = function ()
  if Skulltag.Round < 20 then
    ui.msg("The voice laughs, \"Flee mortal, flee! There's no hiding in hell!\"")
  else
    ui.msg("The voice laughs, \"Remember to come back once you return to Hell for the extended stay.\"")
  end
end
Skulltag.AudienceOnKill = function (being)
  local temp = math.random(3)

  if     temp == 1 then ui.msg("The crowd goes wild! \"BLOOD! BLOOD!\"") --enemy WAS visible
  elseif temp == 2 then ui.msg("The crowd cheers! \"Blood! Blood!\"") --enemy WAS visible
  elseif temp == 3 then ui.msg("The crowd cheers! \"Kill! Kill!\"") --enemy WAS visible
  end
end
