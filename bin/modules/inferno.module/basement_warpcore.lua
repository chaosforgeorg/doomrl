Items({
  id = "spec_teleport",
  name = "teleport",
  color = LIGHTCYAN,
  sprite = 247,
  weight = 0,
  flags = {IF_NODESTROY, IF_NUKERESIST},
  type = ITEMTYPE_TELE,

  OnCreate = function(self)
    self:add_property("target", false)
    self:add_property("spec_targets", {
      coord.new(27, 6),
      coord.new(27, 14),
      coord.new(47, 6),
      coord.new(47, 14),
      coord.new(37, 10),
    })
  end,
  
  OnEnter = function(self, being)
    if being ~= player or being == player then
      self.target = false
      self.target = Generator.standard_empty_coord()
      if self.target then
        items.teleport.OnEnter(self, being)
      end
    else
      local targets = {}
      for _, t in ipairs(self.spec_targets) do
        if self:distance_to(t) > 1 then
          table.insert(targets, t)
        end
      end
      self.target = table.random_pick(targets)
      items.teleport.OnEnter(self, being)
    end
  end,
})

Levels("basement_warpcore", {
  name = "Warp Core",
  entry = "On level @1 he raided the Warp Core!",
  hint = "The lights here are flickering.",
  welcome = "You enter the Warp Core. It's teleport time!",
  mortem_location = "in the Warp Core",
  type = "basement",

  range = {10, 18},
  
  canGenerate = function()
    return true
  end,

  Create = function()
    Level.fill("wall")
    local translation = {
      ["#"] = {"wall", flags = {LFPERMANENT}},
      ["X"] = {"floor", flags = {LFNOSPAWN}},
      [">"] = {"unbstairs", flags = {LFNOSPAWN}},
      ["."] = "floor",
      ["*"] = {"floor", item = "spec_teleport"},
    }
    local map = [[
#######################
#.....................#
#.....................#
#.....................#
#.....................#
#..........>..........#
#.....................#
#.....................#
#.....................#
#.....................#
#######################
    ]]
    Level.place_tile(translation, map, 26, 5)
    Level.drop("spec_teleport", 75)
    Level.player(37, 10)
    Level.result(0)
    Level.summon("knight", 10)
    Level.summon("baron", 3)
  end,
  
  OnKillAll = function()
    if Level.result() == 0 then
      for c in area.FULL:coords() do
        local it = Level.get_item(c)
        if it and it.id == "spec_teleport" then
          Level.clear_item(c)
          Level.drop_item("phase", c)
        end
      end
      Level.drop("hphase")
      Level.result(1)
    end
  end,
  
  IsCompleted = function()
    return Level.result() == 1
  end,
  
})