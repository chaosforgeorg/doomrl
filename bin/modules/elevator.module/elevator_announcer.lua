
--Announcer fluff.  Completely inconsequential to gameplay and with no variables.
Elevator.AnnouncerPlaySound = function (arg_soundname)
  --This USED to be a wrapper so that users could disable the announcer if they hated him.
  --But the new module logic doesn't really work that way, so...
  local sound = core.resolve_sound_id(arg_soundname)
  if(sound ~= 0) then
    player:play_sound(sound)
  end
end