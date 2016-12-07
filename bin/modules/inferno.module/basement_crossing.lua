Levels("basement_crossing", {
  name = "The Crossing",
  entry = "On level @1 he raided The Crossing!",
  hint = "You wonder if you truly exist.",
  welcome = "You enter The Crossing. This place is only what it seems to be.",
  mortem_location = "in The Crossing",
  type = "basement",

  range = {10, 15},
  
  canGenerate = function()
    return true
  end,

  Create = function()
    Level.fill("wall")
    local translation = {
      ["#"] = {"wall", flags = {LFPERMANENT}},
      [">"] = {"unbstairs", flags = {LFNOSPAWN}},
      ["."] = "floor",
      [","] = "blood",
      ["*"] = {"floor", item = "spec_teleport"},
    }
    local map = [[
#########################
#.,.,.,.,.,.,.,.,.,.,.,.#
#,#,#,#,#,#,#,#,#,#,#,#,#
#.,.,.,.,.,.,.,.,.,.,.,.#
#,#,#,#,#,#,#,#,#,#,#,#,#
#.,>,.,.,.,.,.,.,.,.,.,.#
#,#,#,#,#,#,#,#,#,#,#,#,#
#.,.,.,.,.,.,.,.,.,.,.,.#
#,#,#,#,#,#,#,#,#,#,#,#,#
#.,.,.,.,.,.,.,.,.,.,.,.#
#########################
    ]]
    Level.place_tile(translation, map, 26, 5)
    Level.player(29, 10)
    Level.result(0)
    Level.summon("nimp", 14)
    Level.summon("ndemon", 4)
  end,
  
  OnTick = function()
    if core.game_time() % 8 == 0 then
      local hidden = {}
      for c in area.FULL:coords() do
        if not Level.light[c][LFVISIBLE] then
          if Generator.is_empty(c, {EF_NOBEINGS, EF_NOBLOCK}) then
            table.insert(hidden, c)
          end
        end
      end
      for b in Level.beings() do
        if b ~= player then
          local c = b:get_position()
          if not Level.light[c][LFVISIBLE] then
            local target = table.random_pick(hidden)
            if Generator.is_empty(target, {EF_NOBEINGS, EF_NOBLOCK}) then
              thing.displace(b, target)
            end
          end
        end
      end
    end
  end,
  
  OnKillAll = function()
    local result = Level.result()
    if result == 0 then
      local type = ITEMTYPE_RANGED
      if math.random(2) == 1 then type = ITEMTYPE_ARMOR end
      Level.drop(inferno.roll_rare(type, 19))
      for _ = 1, 3 do Level.drop(Level.roll_item_type({ITEMTYPE_PACK}, 20)) end
      Level.result(1)
    end
  end,
  
  IsCompleted = function()
    return Level.result() == 1
  end
})