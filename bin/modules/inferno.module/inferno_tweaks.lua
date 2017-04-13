-- Not exotic anymore
items["chainsaw"].weight = 0
items["chainsaw"].color = RED
items["bfg9000"].weight = 0
items["bfg9000"].color = MAGENTA

-- Mostly copied from KK's version
items["umod_firestorm"].OnUse = function(self, being)
  if not being:is_player() then
    return false
  end
  local item = being.eq.weapon
  if not item then
    ui.msg("Nothing to modify!")
    return false
  end
  if item:check_mod_array("F", being.techbonus) then
    return true
  end
  if not item:can_mod("F") then
    ui.msg("This weapon can't be modded any more!")
    return false
  end
  if item.itype ~= ITEMTYPE_RANGED then
    ui.msg("This weapon can't be modified!")
    return false
  end
  if item.shots <= 1 and item.blastradius < 3 then
    ui.msg("Only a rapid-fire or explosive weapon can be modded!")
    return false
  elseif item.shots >= 2 and item.shots == item.ammomax then
    -- New case
    item.shots = item.shots + 1
    item.ammomax = item.ammomax + 1
  elseif item.shots >= 2 then
    item.shots = item.shots + 2
  else
    item.blastradius = item.blastradius + 2
  end
  ui.msg("You upgrade your weapon!")
  item:add_mod("F")
  return true
end

do
  local usual_teleport_OnEnter = items["teleport"].OnEnter
  items["teleport"].OnEnter = function(self, being)
    usual_teleport_OnEnter(self, being)
    if(being == player) then
      player.scount = math.min(4999, player.scount + 1000)
    end
  end
end

-- Fix Level.item_list to allow items past the dragonslayer.
-- Caching is also diabled.
function Level.get_item_list(max_level,unique_mult)
  local list = {}
  local sum = 0
  local unique_mod = unique_mult or 1
  local danger = max_level or Level.danger_level
  for index = 1, items.__counter do
    local item_proto = items[index]
    if item_proto then
      if item_proto.weight > 0 and danger >= item_proto.level then 
        if not item_proto.is_unique or not player:found_item(item_proto.id) then
          if item_proto.is_unique then
            for z = 1, unique_mod do table.insert(list, item_proto) end
            sum = sum + item_proto.weight * unique_mod
          else
            table.insert(list, item_proto)
            sum = sum + item_proto.weight
          end
        end
      end
    end
  end
  return list, sum
end