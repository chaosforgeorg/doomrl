local sense_flags = {
  "BF_BEINGSENSE",
}

function inferno.darkness_setup()
  player:add_property("vision_penalty", 0)
  inferno.darkness_tick()
  player.flags[BF_DARKNESS] = true
end

function inferno.darkness_cleanup()
  player.vision = player.vision + player.vision_penalty
  player:remove_property("vision_penalty")
  for _, flag in ipairs(sense_flags) do
    local f = _G[flag]
    if player:has_property("_removed_" .. flag) then
      player:remove_property("_removed_" .. flag)
      player.flags[f] = true
    end
  end
  player.flags[BF_DARKNESS] = false
end

function inferno.darkness_tick()
  if player.vision > 1 then
    player.vision_penalty = player.vision_penalty + player.vision - 1
    player.vision = 1
  end
  local sense_removed = false
  for _, flag in ipairs(sense_flags) do
    local f = _G[flag]
    if player.flags[f] then
      player:add_property("_removed_" .. flag, true)
      player.flags[f] = false
      sense_removed = true
    end
  end
  if sense_removed then
    ui.msg("Your extraordinary senses are failing you.")
  end
end

Levels("basement_dark", {
  name = "The Dark",
  entry = "On level @1 he raided The Dark!",
  hint = "Shadows dance upon the walls.",
  welcome = "You enter The Dark. It's pitch black.",
  mortem_location = "in The Dark",
  type = "basement",

  range = {15, 19},
  
  canGenerate = function()
    return player.completed_levels["SHADOW"]
  end,

  Create = function()
    inferno.darkness_setup()
    Level.fill("rwall")
    local translation = {
      ["#"] = {"rwall", flags = {LFPERMANENT}},
      ["X"] = "rwall",
      [">"] = "unbstairs",
      [","] = "blood",
      ["."] = "floor",
      ["A"] = {"floor", being = "angel"},
      ["c"] = {"floor", being = "ndemon"},
      ["-"] = "bridge",
      ["="] = "lava",
      ["+"] = "door",
    }
    local map = [[
####################
####.....##.....####
##................##
##...#.#....#.#...##
##........>.......##
##...#.#....#.#...##
##................##
####.....##.....####
####################
    ]]
    Level.place_tile(translation, map, 28, 6)
    Level.player(38, 10)  
    Level.result(0)
    Level.summon("ndemon", 5)
  end,
  
  OnTick = function()
    inferno.darkness_tick()
  end,
  
  OnKillAll = function()
    local result = Level.result()
    if result == 0 then
      Level.summon("nimp", 7)
      Level.result(1)
    elseif result == 1 then
      Level.summon("ncacodemon", 3)
      Level.summon("lostsoul", 8)
      Level.result(2)
    elseif result == 2 then
      player.flags[BF_DARKNESS] = false
      Level.drop("msglobe")
      Level.drop("pammo")
      Level.drop("pshell")
      Level.drop("procket")
      Level.drop("pcell")
      Level.drop("rarmor")
      Level.drop("lmed")
      Level.drop("lmed")
      Level.result(3)
    end
  end,
  
  OnExit = function()
    inferno.darkness_cleanup()
  end,
  
  IsCompleted = function()
    return Level.result() == 3
  end
})