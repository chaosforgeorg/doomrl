-- TODO: tunnels

local train_x

local valid_y = {1, 2, 3, 4, 5, 6, 14, 15, 16, 17, 18, 19, 20}

local y_set = table.toset(valid_y)

local rocks = {}

local train_fringe

local function train_init()
  for x = 1, MAXX do
    train_x = x
    train_fringe()
  end
end

function train_fringe()
  if math.random(7) == 1 then
    Level[coord.new(train_x, table.random_pick(valid_y))] = "tree"
  end
  local new_rocks = {}
  for _, y in ipairs(rocks) do
    if math.random(5) <= 2 then
      Level[coord.new(train_x, y)] = "wall"
      table.insert(new_rocks, y)
    end
    if y_set[y + 1] and math.random(6) <= 1 then
      Level[coord.new(train_x, y + 1)] = "wall"
      table.insert(new_rocks, y + 1)
    end
    if y_set[y - 1] and math.random(6) <= 1 then
      Level[coord.new(train_x, y - 1)] = "wall"
      table.insert(new_rocks, y - 1)
    end
  end
  rocks = new_rocks
  if math.random(10) == 1 then
    local y = table.random_pick(valid_y)
    Level[coord.new(train_x, y)] = "wall"
    table.insert(rocks, y)
  end
end

local function train_tick()
  if core.game_time() % 10 ~= 0 then return end
  local c = coord.new(0, 0)
  local d = coord.new(0, 0)
  for _, y in ipairs(valid_y) do
    c.y = y
    d.y = y
    for x = 1, MAXX - 1 do
      c.x = x
      d.x = x + 1
      Level[c] = Level[d]
    end
    c.x = MAXX
    Level[c] = "rock"
  end
  train_fringe()
end

Levels("basement_train", {
  name = "Doomtrain",
  entry = "On level @1 he raided the Doomtrain!",
  hint = "You hear a whistle sound in the distance.",
  welcome = "You enter the Doomtrain. A train? Here?",
  mortem_location = "on the Doomtrain",
  type = "basement",

  range = {15, 19},
  
  canGenerate = function()
    return true
  end,

  Create = function()
    Level.fill("rock")
    local translation = {
      ["#"] = {"wall", flags = {LFPERMANENT}},
      ["-"] = {"windowh", flags = {LFPERMANENT}},
      [">"] = "unbstairs",
      ["+"] = "ldoor",
      ["."] = "floor",
      [","] = "rock",
      ["s"] = {"floor", being = "lostsoul"},
      ["o"] = {"floor", being = "commando"},
      ["R"] = {"floor", being = "revenant"},
      ["M"] = {"floor", being = "mancubus"},
      ["U"] = {"floor", being = "asura"},
      ["V"] = {"floor", being = "arch"},
    }
    local map = [[
#----#----#----#,#----#----#----#,#----#----#----#.###########----##,
#...s#o..s#o..s###.s..R....R....###............M.###.U.s.s.........##
#>.............+.+...###..###...+.+..............+.+...........V....#
#...s#o..s#o..s###.s..R....R....###............M.###.U.s.s.........##
#----#----#----#,#----#----#----#,#----#----#----#.###########----##,
    ]]
    Level.place_tile(translation, map, 5, 8)
    Level.player(6, 10)
    Level.result(0)
    for c in area.FULL:coords() do
      if Level[c] == "rock" then
        Level.light[c][LFNOSPAWN] = true
      end
    end
    train_init()
  end,
  OnTick = function()
    train_tick()
  end,
  OnKillAll = function()
    if Level.result() == 0 then
      Level.drop_item(inferno.roll_rare(ITEMTYPE_ARMOR, 25), coord.new(72, 10))
      Level.result(1)
    end
  end,
  IsCompleted = function()
    return Level.result() == 1
  end,
})