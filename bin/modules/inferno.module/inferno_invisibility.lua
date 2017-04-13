core.declare("Invisibility", {})

function Invisibility.initialize()
  player:add_property("stealth", 0)
end

function Invisibility.register()
  local usual_in_sight = being.in_sight
  function being:in_sight(other)
    if other == player and player:is_affect("invis") and not self:has_property("_invis_seen_player") then
      return false
    end
    if other == player and self.vision > 0 and player.stealth > 0 and math.max(self.vision - player.stealth, 1) < self:distance_to(player) and not self:has_property("_invis_seen_player") then
      return false
    end
    return usual_in_sight(self, other)
  end
  local function OnSoundCast(b)
    if not b:has_property("_invis_seen_player") then
      b:add_property("_invis_seen_player", true)
    end
  end
  LurkAI.OnSoundCast = create_seq_function(LurkAI.OnSoundCast, OnSoundCast)
  Affect({
    name = "ivs",
    id = "invis",
    color = MAGENTA,
    color_expire = DARKGRAY,
    message_init = "You blend in with your surroundings.",
    message_ending = "You body is beginning to regain its color.",
    message_done = "You are now visible again.",

    OnAdd = function(being)
      if not player:has_property("invis_picture") then
        player:add_property("invis_picture", false)
      end
      player.invis_picture = player.picture
      player.picture = string.byte(" ")
      for b in Level.beings() do
        if b:has_property("_invis_seen_player") then
          b:remove_property("_invis_seen_player")
        end
      end
      player.dodgebonus = player.dodgebonus + 18
    end,
    
    OnRemove = function(being)
      player.picture = player.invis_picture
      player.dodgebonus = player.dodgebonus - 18
    end,
  })
end

Items({
  name = "Invisibility Globe",
  id = "invisgl",
  color = MAGENTA,
  level = 4,
  weight = 180,
  sprite = SPRITE_SUPERCHARGE,
  flags = {F_GLOW},
  glow = {0.4, 0.1, 0.4, 0.8},
  type = ITEMTYPE_POWER,
  OnPickup = function(self, being)
    being:set_affect("invis", 50)
  end,
})
