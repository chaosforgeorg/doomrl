local positions, enemies, timer

local function carnival_next()
  local result = Level.result() + 1
  if result > #positions then return end
  local c = positions[result]
  Level[c] = "blood"
  Level.drop_being(enemies[result], c)
  Level.result(result)
end

Levels("basement_carnival", {
  name = "Carnival of Death",
  entry = "On level @1 he raided the Carnival of Death!",
  hint = "The hideous melody of death pierces your mind.",
  welcome = "You enter the Carnival of Death. You have a feeling this will be a bloodbath.",
  mortem_location = "in the Carnival of Death",
  type = "basement",

  range = {10, 18},
  
  canGenerate = function()
    return true
  end,

  Create = function()
    Level.fill("wall")
    local translation = {
      ["#"] = {"rwall", flags = {LFPERMANENT}},
      ["X"] = {"gwall", flags = {LFPERMANENT}},
      [">"] = {"unbstairs", flags = {LFNOSPAWN}},
      ["."] = "floor",
      [","] = "blood",
    }
    local map = [[
###############
#.............#
#.X.X.X.X.X.X.#
#.............#
#X.X.X.X.X.X.>#
#.............#
#.X.X.X.X.X.X.#
#.............#
###############
    ]]
    Level.place_tile(translation, map, 30, 6)
    Level.player(43, 10)
    Level.result(0)
    positions = {}
    timer = 0
    for c in area.FULL:coords() do
      if Level[c] == "gwall" then
        table.insert(positions, c:clone())
      end
    end
    table.shuffle(positions)
    enemies = {
      "former",
      "sergeant",
      "captain",
      "commando",
      "demon",
      "imp",
      "cacodemon",
      "hydra",
      "lostsoul",
      "knight",
      "pain",
      "mist",
      "revenant",
      "cinder",
      "baron",
      "mancubus",
      "asura",
      "arch",
    }
  end,
  
  OnTick = function()
    local result = Level.result()
    if player.turns_on_level > 77 + timer * (136 - 9 * DIFFICULTY) then
      carnival_next()
      timer = timer + 1
    end
  end,
  
  OnKill = function(b)
    if not b.flags[BF_NOEXP] then
      carnival_next()
    end
  end,
  
  OnKillAll = function()
    local result = Level.result()
    if result >= #positions and result ~= 1000 then
      local type = ITEMTYPE_RANGED
      if math.random(2) == 1 then type = ITEMTYPE_ARMOR end
      Level.drop(inferno.roll_rare(type, 19))
      for _ = 1, 3 do Level.drop(Level.roll_item_type({ITEMTYPE_PACK}, 20)) end
      Level.result(1000)
    end
  end,
  
  IsCompleted = function()
    return Level.result() == 1000
  end
  
})