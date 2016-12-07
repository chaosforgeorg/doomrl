local function map_write(s, y)
  Level.flags[LF_ITEMSVISIBLE] = true
  local cr = coord.new(1, y)
  for x = 1, #s do
    cr.x = x
    local c = string.sub(s, x, x)
    if c ~= " " then
      Level[cr] = "floorb"
      local it = Level.drop_item("stubitem", cr)
      if it then
        it.picture = string.byte(c)
        it.color = RED
      end
    end
  end
end

local function map_clear(y)
  local cr = coord.new(1, y)
  for x = 1, MAXX do
    cr.x = x
    Level.clear_item(cr)
  end
end

local soft_selection = nil

inferno.loadouts = {
  {
    name = "standard",
    desc = "This is a standard loadout with flexible equipment and strong recovery.",
    eq = {
      weapon = "pistol",
      prepared = "knife",
      boots = "sboots",
    },
    inv = {
      {"ammo", ammo = 24},
      "smed",
      "smed",
    },
    coord = coord.new(38, 10),
    enter = coord.new(38, 15),
  },
  {
    name = "shotgun",
    desc = "This one's for shotgun fanatics! Start with a shotgun, but lose some frills.",
    eq = {
      weapon = "shotgun",
    },
    inv = {
      {"shell", ammo = 24},
      "smed",
    },
    coord = coord.new(34, 10),
    enter = coord.new(34, 15),
  },
  {
    name = "melee",
    desc = "Here's a loadout for true berserkers.",
    eq = {
      weapon = "knife",
      armor = "barmor",
      boots = "sboots",
    },
    inv = {
      "lmed",
      "lmed",
      "mod_bulk",
    },
    coord = coord.new(42, 10),
    enter = coord.new(42, 15),
  },
}

for _, loadout in ipairs(inferno.loadouts) do
  inferno.loadouts[loadout.name] = loadout
end

Levels("WELCOME", {
  
  type = "none",

  Create = function()
    local translation = {
      ["X"] = "rwall",
      ["."] = "floorb",
      ["+"] = "doorb",
      [">"] = "stairs",
      ["?"] = "water",
      ["{"] = {"water", item = {"pistol"}},
      ["G"] = {"water", item = {"shotgun"}},
      ["/"] = {"water", item = {"knife"}},
      ["a"] = {"water", item = {"ammo", ammo = 24}},
      ["s"] = {"water", item = {"shell", ammo = 24}},
      ["m"] = {"water", item = {"smed"}},
      ["M"] = {"water", item = {"lmed"}},
      ["B"] = {"water", item = {"mod_bulk"}},
      ["b"] = {"water", item = {"barmor"}},
      [";"] = {"water", item = {"sboots"}},
    }
    local map = [[
XXXXXXXXXXXX.XXXXXXXXXXXX
XXXXXXXXXXX...XXXXXXXXXXX
XXXXXXXXXX..>..XXXXXXXXXX
XXXXXXXXXXX...XXXXXXXXXXX
XXXXXXXXXXXX.XXXXXXXXXXXX
XXXXXXXXXXXX+XXXXXXXXXXXX
XXXXXXXX.........XXXXXXXX
XXXXXXXX.XXX.XXX.XXXXXXXX
XX....X?.?X;.?X?.MX....XX
X.....Xs.mX/.mX;.BX.....X
X.....XG.?Xa.mX/.bX.....X
X.....X?.?X{.?X?.MX.....X
XX....XX.XXX.XXX.XX....XX
XXXXXXXX.........XXXXXXXX
XXXXXXXXXXXX.XXXXXXXXXXXX
    ]]
    Level.fill("rwall")
    Level.place_tile(translation, map, 26, 3)
    Generator.transmute("water", "display")
    Level.light[LFPERMANENT] = true
    Level.player(38, 17)
  end,
  OnEnter = function()
    player.eq:clear()
    player.inv:clear()
    player:add_property("equipment_loadout", false)
    ui.msg("Choose the path that displays the initial equipment you prefer.")
    --map_write("Welcome to Inferno.", 19)
  end,
  OnExit = function()
    map_clear(19)
    if player:has_property("equipment_loadout") and player.equipment_loadout then
      local loadout = inferno.loadouts[player.equipment_loadout]
      player:add_history("He selected the " .. loadout.name .. " loadout.")
    end
  end,
  OnTick = function()
    for _, loadout in ipairs(inferno.loadouts) do
      if player:get_position() == loadout.coord then
        if player.equipment_loadout ~= loadout.name then
          player.equipment_loadout = loadout.name
          ui.msg("Loadout selected: " .. loadout.name)
        end
      elseif player.equipment_loadout and player.equipment_loadout ~= loadout.name then
        Level[loadout.coord] = "rwall"
      end
      if player.y >= 16 then
        Level[loadout.coord] = "floorb"
      end
      if player:get_position() == loadout.enter and loadout.name ~= soft_selection then
        soft_selection = loadout.name
        ui.msg(loadout.desc)
      end
    end
    if player.y >= 16 and player.equipment_loadout then
      player.equipment_loadout = false
    end
  end,
})