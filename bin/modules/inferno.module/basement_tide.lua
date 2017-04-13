local map_area

Levels("basement_tide", {
  name = "Blood Tide",
  entry = "On level @1 he raided Blood Tide!",
  hint = "",
  welcome = "You enter Blood Tide.",
  mortem_location = "at Blood Tide",
  type = "basement",
  
  range = {17, 22},
  
  canGenerate = function()
    return true
  end,

  Create = function()
    Level.fill("lava")
    local translation = {
      ["#"] = {"wall", flags = {LFPERMANENT}},
	  ["="] = "lava",
      ["-"] = "windowh_fragile",
      [">"] = "unbstairs",
      ["|"] = "windowv_fragile",
      ["."] = "floor",
	  ["O"] = {"floor", being = "cacodemon"},
      ["N"] = {"floor", being = "ncacodemon"},
    }
    local map = [[
##-----------##==
#......O......#==
|...#..#..#...|==
|.#.N.....O.#.###
|N.....O....#..>#
|.#.N.....O.#.###
|...#..#..#...|==
#......O......#==
##-----------##==
    ]]
    Level.place_tile(translation, map, 31, 6)
    Level.player(46, 10)
    Level.result(0)
    map_area = area.new(31, 6, 45, 14)
  end,
  
  OnTick = function()
    local result = Level.result()
    if result == 0 and player.x <= 44 then
      Level[coord.new(45, 10)] = "wall"
      Level.light[coord.new(45, 10)][LFPERMANENT] = true
      Level.result(2)
    end
    if core.game_time() % (28 - DIFFICULTY) == 0 then
      for c in map_area:coords() do
        local cid = Level[c]
        if not cells[cid].flag_set[CF_BLOCKMOVE] and cid ~= "bridge" and cid ~= "lava" then
          if Generator.cross_around(c, {cells.lava.nid}) ~= 0 then
            Level[c] = "water"
          end
        end
      end
      Generator.transmute("water", "lava")
    end
  end,
  
  OnKillAll = function()
    if Level.result() ~= 3 then
      Level.result(3)
      Level[coord.new(45, 10)] = "bridge"
      Level[coord.new(47, 10)] = "bridge"
      Level[coord.new(48, 10)] = "bridge"
      Level[coord.new(49, 10)] = "bridge"
      Level[coord.new(50, 10)] = "bridge"
      Level.drop_item("lmed", coord.new(47, 10))
      Level.drop_item(inferno.roll_rare(ITEMTYPE_RANGED, 25), coord.new(48, 10))
      Level.drop_item(inferno.roll_rare(ITEMTYPE_ARMOR, 25), coord.new(49, 10))
      Level.drop_item(inferno.roll_rare(ITEMTYPE_BOOTS, 30), coord.new(50, 10))
      for c in map_area:coords() do
        local cid = Level[c]
        if not cells[cid].flag_set[CF_BLOCKMOVE] then
          Level[c] = "bridge"
        end
      end
    end
  end,
  
  IsCompleted = function()
    return Level.result() == 3
  end,
})