inferno.Sound = {}

local sound_loaded = false

function inferno.Sound.load()
  if sound_loaded then return end
  sound_loaded = true
  local r = core.resolve_sound_id
  beings.former.sound_sight = {r("dsposit1"), r("dsposit2"), r("dsposit3")}
  beings.sergeant.sound_sight = beings.former.sound_sight
  beings.captain.sound_sight = beings.former.sound_sight
  beings.commando.sound_sight = beings.former.sound_sight
  beings.imp.sound_sight = {r("dsbgsit1"), r("dsbgsit2")}
  beings.demon.sound_sight = r("dssgtsit")
  beings.lostsoul.sound_sight = beings.lostsoul.sound_act
  beings.cacodemon.sound_sight = beings.cacodemon.sound_act
  beings.cacodemon.sound_act = beings.demon.sound_act
  beings.arachno.sound_sight = r("dsbspsit")
  beings.knight.sound_sight = beings.knight.sound_act
  beings.knight.sound_act = beings.demon.sound_act
  beings.baron.sound_sight = beings.baron.sound_act
  beings.baron_sound_act = beings.demon.sound_act
  beings.mancubus.sound_sight = beings.mancubus.sound_act
  beings.mancubus.sound_act = beings.demon.sound_act
  beings.mancubus.sound_attack = r("dsmanatk")
  beings.revenant.sound_sight = r("dsskesit")
  beings.revenant.sound_act = r("dsskeact")
  beings.arch.sound_sight = r("dsvilsit")
  beings.hydra.sound_sight = r("hydra.sight")
  beings.hydra.sound_hit = beings.imp.sound_hit
  beings.mist.sound_sight = r("mist.sight")
  beings.asura.sound_sight = r("asura.sight")
  for nid = 1, beings.__counter do
    if beings[nid] and beings[nid].sound_id and not beings[nid].sound_sight then
      local sound_id = beings[nid].sound_id
      if sound_id and beings[sound_id] and not beings[nid].sound_sight then
        beings[nid].sound_sight = beings[sound_id].sound_sight
      end
    end
  end
end

function inferno.Sound.being_sound(b, id)
  local proto
  if type(b) == "string" or type(b) == "number" then
    proto = beings[b]
  else
    proto = b.__proto
  end
  local sound = proto["sound_" .. id]
  if type(sound) == "table" then
    sound = table.random_pick(sound)
  end
  if type(b) == "string" or type(b) == "number" then
    return sound
  else
    b:play_sound(sound)
  end
end

--[[
for _, bp in ipairs(beings) do
  if type(bp.sound_act) ~= "number" then
    local function act_sound(self)
      if not self:has_property("lurking") or not self.lurking then
        if math.random(20) == 1 then
          inferno.Sound.being_sound(self, "act")
        end
      end
    end
    bp.OnAction = create_seq_function(act_sound, bp.OnAction)
  end
end
]]