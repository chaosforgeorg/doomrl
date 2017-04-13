-- Some medals are awarded as the game progesses; they needn't be included here.
function inferno.award_medals()
  for i = 1, medals.__counter do
    if medals[i] and medals[i].inferno and medals[i].condition() then
      player:add_medal(medals[i].id)
    end
  end
end

local stats = setmetatable({}, {
  __index = function(self, idx)
    return inferno.Statistics.get(idx)
  end
})

Medal({
  id = "inferno_killall1",
  name = "Order of Slaughter",
  desc = "Killed every monster",
  hidden = false,
  inferno = true,
  condition = function()
    return player.victory and stats.kills == stats.max_kills
  end,
})

Medal({
  id = "inferno_explore1",
  name = "Wanderlust Token",
  desc = "Visited every special floor",
  hidden = false,
  inferno = true,
  condition = function()
    return #(player._statistics_visited.special or {}) >= statistics.bonus_levels_count + 3
  end,
})

Medal({
  id = "inferno_conquer1",
  name = "Order of Conquest",
  desc = "Completed every special floor",
  hidden = false,
  inferno = true,
  condition = function()
    return #(player._statistics_completed.special or {}) >= statistics.bonus_levels_count + 3
  end,
})

Medal({
  id = "inferno_tactical1",
  name = "Tactician's Token",
  desc = "Cleared a random floor without taking damage",
  hidden = false,
  inferno = true,
  condition = function()
    return stats.tactical_clears >= 1
  end,
})

Medal({
  id = "inferno_tactical2",
  name = "Tactician's Medal",
  desc = "Cleared five random floors without taking damage",
  hidden = true,
  inferno = true,
  condition = function()
    return stats.tactical_clears >= 5
  end,
})

Medal({
  id = "inferno_tactical3",
  name = "Tactician's Cross",
  desc = "Cleared ten random floors without taking damage",
  hidden = true,
  inferno = true,
  condition = function()
    return stats.tactical_clears >= 10
  end,
})

Medal({
  id = "inferno_paragon",
  name = "Paragon Insignia",
  desc = "Won without taking damage",
  hidden = true,
  inferno = true,
  condition = function()
    return player.victory and stats.damage_taken == 0
  end,
})

Medal({
  id = "inferno_killspree1",
  name = "Massacre Medal",
  desc = "Killed eight monsters in fifty turns",
  hidden = false,
  inferno = true,
  condition = function()
    return player.killspree >= 8
  end,
})

Medal({
  id = "inferno_killspree2",
  name = "Massacre Cross",
  desc = "Killed fifteen monsters in fifty turns",
  hidden = true,
  inferno = true,
  condition = function()
    return player.killspree >= 15
  end,
})

Medal({
  id = "inferno_killspree3",
  name = "Bloodbath Medal",
  desc = "Killed 25 monsters in fifty turns",
  hidden = true,
  inferno = true,
  condition = function()
    return player.killspree >= 25
  end,
})

Medal({
  id = "inferno_assembly1",
  name = "Genius Medal",
  desc = "Created three assemblies in one game",
  hidden = false,
  inferno = true,
  condition = function()
    return stats.assemblies >= 3
  end,
})

Medal({
  id = "inferno_assembly2",
  name = "Genius Cross",
  desc = "Created five assemblies in one game",
  hidden = true,
  inferno = true,
  condition = function()
    return stats.assemblies >= 5
  end,
})

Medal({
  id = "inferno_shotgun1",
  name = "Shottyman Medallion",
  desc = "Won with at least 80% shotgun kills",
  hidden = false,
  inferno = true,
  condition = function()
    return player.victory and stats.kills >= 1 and
      inferno.Statistics.shotgun_kills >= 0.8 * stats.kills
  end,
})

Medal({
  id = "inferno_chaingun1",
  name = "Carnage Medallion",
  desc = "Won with at least 80% chaingun-type kills",
  hidden = false,
  inferno = true,
  condition = function()
    return player.victory and stats.kills >= 1 and
      inferno.Statistics.chaintype_kills >= 0.8 * stats.kills
  end,
})

Medal({
  id = "inferno_sniper1",
  name = "Sniper Medal",
  desc = "Killed 100 monsters that are more than 8 tiles away",
  hidden = true,
  inferno = true,
  condition = function()
    return player.sniper_kills >= 100
  end,
})

Medal({
  id = "inferno_sniper2",
  name = "Sniper Cross",
  desc = "Killed 500 monsters that are more than 8 tiles away",
  hidden = true,
  inferno = true,
  condition = function()
    return player.sniper_kills >= 500
  end,
})

--[[ TODO: fix with respawning

Medal({
  id = "inferno_corpsekill1",
  name = "Undertaker Medal",
  desc = "Destroy 100 corpses",
  hidden = true,
  inferno = true,
  condition = function()
    return player.corpse_kills >= 100
  end,
})

Medal({
  id = "inferno_corpsekill2",
  name = "Undertaker Cross",
  desc = "Destroy 500 corpses",
  hidden = true,
  inferno = true,
  condition = function()
    return player.corpse_kills >= 500
  end,
})

]]

Medal({
  id = "inferno_noarmor",
  name = "Unbreakable Medal",
  desc = "Won without wearing armor",
  hidden = true,
  inferno = true,
  condition = function()
    return player.victory and not player.worn_armor
  end,
})

Medal({
  id = "inferno_secret1",
  name = "Eagle's Token",
  desc = "Discovered a secret area",
  hidden = false,
  inferno = true,
  condition = function()
    return player.secrets_found >= 1
  end,
})

Medal({
  id = "inferno_secret2",
  name = "Secret Hunter Cross",
  desc = "Discovered all secret areas",
  hidden = true,
  inferno = true,
  condition = function()
    return player.secrets_found >= 4
  end,
})