
--Thanks to the prosperity rune we have a more complicated HP gaining system.
--This module is in charge of tweaking all healing items that need to be tweaked.

--This is the exposed interface
Elevator.Healing = {}
Elevator.Healing.Init = nil
Elevator.Healing.AddBeingHP = nil

--locals
local GetHPMax = function(arg_being, arg_allowboost)
  if(arg_allowboost or arg_being.flags[ BF_MEDPLUS ]) then
    return arg_being.hpmax * 2
  elseif(arg_being:has_property("rune") and arg_being.rune == RUNE_PROSPERITY) then
    return arg_being.hpmax * 1.75
  else
    return arg_being.hpmax
  end
end

--implemented interface
Elevator.Healing.AddBeingHP = function(arg_being, arg_amount, arg_allowboost)

  if(arg_being.flags[ BF_NOHEAL ]) then
    return false
  end

  local tempHP = math.min(arg_being.hp + arg_amount, GetHPMax(arg_being, arg_allowboost))
  if(tempHP <= arg_being.hp) then
    return false
  end

  arg_being.hp = tempHP
  return true
end


--init code.
Elevator.Healing.Init = function()
  --All (major) healing items must be reimplemented due to Prosperity.
  items["smed"].OnUse   = function(self,being)

    if being:is_player() then
      being.tired = false
    end

    if Elevator.Healing.AddBeingHP(being, being.hpmax / 4, false) then
      being:msg("You feel healed.",being:get_name(true,true).." looks healthier!")
    else
      being:msg("Nothing happens.")
    end

    return true
  end
  items["lmed"].OnUse   = function(self,being)

    if being:is_player() then
      being.tired = false
    end

    if Elevator.Healing.AddBeingHP(being, being.hpmax, false) then
      being:msg("You feel fully healed.",being:get_name(true,true).." looks a lot healthier!")
    else
      being:msg("Nothing happens.")
    end

    return true
  end
  items["shglobe"].OnPickup   = function(self,being)

    --Should always be player
    being.tired = false

    if(Elevator.Healing.AddBeingHP(being, 10, true) == false) then
      being:msg("Nothing happens.")
    else
      being:msg("You feel like new!")
    end
  end
  items["lhglobe"].OnPickup   = function(self,being)

    --Should always be player
    being.tired = false

    if(Elevator.Healing.AddBeingHP(being, 10, true) == false)  then
      being:msg("Nothing happens.")
    else
      Elevator.Healing.AddBeingHP(being, math.max(being.hpmax - 10, 0), false)
      being:msg("You feel like new!")
    end
  end
  items["scglobe"].OnPickup   = function(self,being)

    --Should always be player
    being.tired = false
    Elevator.Healing.AddBeingHP(being, math.max(being.hpmax, being.hpmax*2 - being.hp), true)

    Elevator.AnnouncerPlaySound("soulsphere")
    being:msg("SuperCharge!")
    ui.blink(LIGHTBLUE, 100)
  end
  items["msglobe"].OnPickup   = function(self,being)

    --Should always be player
    being.tired = false
    if being.eq.armor then being.eq.armor:fix() end
    if being.eq.boots then being.eq.boots:fix() end

    Elevator.Healing.AddBeingHP(being, math.max(being.hpmax, being.hpmax*2 - being.hp), true)

    Elevator.AnnouncerPlaySound("megasphere")
    being:msg("MegaSphere!")
    ui.blink(LIGHTMAGENTA,100)
  end
end
