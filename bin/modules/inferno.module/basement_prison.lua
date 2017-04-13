local finished, pos

local function check_reward()
  if Level.result() == 3 then
    for b in Level.beings() do
      if b ~= player then return end
    end
    Level.result(4)
    for _ = 1, 12 do Level.drop(Level.roll_item_type({ITEMTYPE_PACK}, 25, 2)) end
    for _ = 1, 6 do Level.drop(Level.roll_item_type({ITEMTYPE_POWER}, 25)) end
  end
end

Levels("basement_prison", {
  name = "Void Prison",
  entry = "On level @1 he raided the Void Prison!",
  hint = "You have a sense that reality has been pierced nearby.",
  welcome = "You enter the Void Prison. Those portals are on megadrive!",
  mortem_location = "in the Void Prison",
  type = "basement",

  range = {15, 19},
  
  canGenerate = function()
    return player.completed_levels["SINGULARITY"]
  end,

  Create = function()
    Level.fill("void1")
    for _ = 1, 5 do inferno.void_tick(true) end
    local translation = {
      ["|"] = "windowv",
      ["-"] = "windowh",
      [">"] = "unbstairs",
      ["."] = "floor",
      ["&"] = "floor",
      ["0"] = {"floor", item = "sing_portal"},
      ["1"] = "windowul",
      ["2"] = "windowur",
      ["3"] = "windowdl",
      ["4"] = "windowdr",
    }
    local map = [[
1-----------2
|&..........|
|...........|
|0..........|
|........>..|
|...........|
|0..........|
|...........|
|&..........|
3-----------4
    ]]
    Level.place_tile(translation, map, 34, 6)
    Level.player(43, 11)  
    Level.result(1)
    finished = {false, false}
    local lever_pos = {
      coord.new(35, 7),
      coord.new(35, 14),
    }
    pos = {
      coord.new(35, 9),
      coord.new(35, 12),
    }
    for i = 1, #pos do
      local lever = item.new("portal_lever")
      lever.trigger = function()
        finished[i] = true
        Level.clear_item(pos[i])
        Level.drop_item("sing_portal_closed", pos[i])
        Level.result(Level.result() + 1)
        player:add_exp(1000)
      end
      Level.drop_item(lever, lever_pos[i])
    end
  end,
  
  OnTick = function()
    local res = Level.result()
    inferno.void_tick()
    if res == 4 then
      return
    end
    if res == 3 then
      check_reward()
    end
    if player.turns_on_level % (42 - DIFFICULTY) == 0 then
      for i = 1, 2 do
        if not finished[i] and not Level.get_being(pos[i]) then
          local being = Level.drop_being("baron", pos[i])
          if being then
            being.flags[BF_HUNTING] = true
            being.flags[BF_NOEXP] = true
            being.scount = 3000 + math.random(1000)
            LurkAI.unlurk(being)
            being:play_sound("soldier.phase")
            Level.explosion(being:get_position(), 2, 50, 0, 0, LIGHTBLUE)
          end
        end
      end
    end
  end,
  
  OnKillAll = function()
    check_reward()
  end,
  
  OnExit = function()
    
  end,
  
  IsCompleted = function()
    return Level.result() == 4
  end,
  
})