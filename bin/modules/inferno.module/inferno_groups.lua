-- Putting a dummy monster in this slot fixes iteration over new beings;
-- but I replaced this by all InfernoGroups anyway.
-- beings[29] = beings["cyberdemon"]

for _, being in ipairs(beings) do
  being.weight = 0
end

for _, group in ipairs(being_groups) do
  group.weight = 0
end

being_groups = {}

inferno.Group = {}

function inferno.Group.being_list()
  local dlevel = Level.danger_level
  local list, sum = {}, 0
  local diffmod = {0, 0, 3, 6, 6}
  diffmod = diffmod[DIFFICULTY]
  for _, bg in ipairs(inferno.groups) do
    if dlevel <= bg.maxLev and dlevel + DIFFICULTY >= bg.minLev then
      table.insert(list, bg)
      sum = sum + bg.weight
    end
  end
  return list, sum
end

-- This function is used by summon levers; the original gets broken when we set
-- all the being weights to zero.
Level.random_being = function()
  local diff_mod = math.max(math.min((DIFFICULTY - 2) * 3, 6), 0)
  local danger = Level.danger_level
  local list = {}
  local sum = 0
  for id, group in pairs(inferno.single_groups) do
    if group.weight > 0 and group.minLev <= danger + diff_mod and danger <= group.maxLev then
      table.insert(list, {being_id = id, weight = group.weight})
      sum = sum + group.weight
    end
  end
  if sum == 0 then
    return "former"
  else
    return Level.roll_weight(list, sum).being_id
  end
end

local function ch(a, b, c)
  if DIFFICULTY <= 2 then
    return a
  elseif DIFFICULTY <= 3 then
    return b
  else
    return c
  end
end

beings.former.danger_override = 0.5
beings.lostsoul.danger_override = 2

inferno.groups = {}
inferno.single_groups = {}

-- It is convenient to give this a return value
local function InfernoGroup(being_group_proto)
  if being_group_proto.single then
    inferno.single_groups[being_group_proto.single] = being_group_proto
  end
  table.insert(inferno.groups, being_group_proto)
  being_group_proto.minLev = being_group_proto.minLev or 0
  being_group_proto.maxLev = being_group_proto.maxLev or 200
  being_group_proto.weight = being_group_proto.weight or 10
  being_group_proto.is_group = true
  core.array_register(inferno.groups, being_group_proto)
end

-- We call this AFTER difficulty selection.
inferno.make_groups = function()
  -- TEMP
  --[[
  InfernoGroup({
    minLev = 0,
    weight = 1000,
    danger = 10,
    size = 2,
    beings = {
      {being = "arachne", amount = 1},
    },
  })
  ]]
  InfernoGroup({
    minLev = 0,
    maxLev = 12,
    weight = 100,
    danger = ch(2, 3, 4),
    size = 2,
    former = true,
    single = "former",
    beings = {
      {being = "sergeant", amount = ch(0, 1, {2, 3})},
      {being = "former", amount = ch({2, 4}, {3, 5}, {4, 6})},
    }
  })
  InfernoGroup({
    minLev = 2,
    maxLev = 15,
    weight = 100,
    danger = ch(2, 3, 4),
    size = 2,
    former = true,
    single = "sergeant",
    beings = {
      {being = "sergeant", amount = ch({1, 2}, {2, 3}, {4, 6})},
    }
  })
  InfernoGroup({
    minLev = 5,
    maxLev = 15,
    weight = 100,
    danger = ch(5, 6, 7),
    size = ch(2, 3, 3),
    former = true,
    single = "captain",
    beings = {
      {being = "captain", amount = ch(1, {1, 3}, {1, 5})},
      {being = "sergeant", amount = ch(0, {0, 3}, {0, 3})},
      {being = "former", amount = ch({3, 5}, {4, 6}, {4, 8})},
    }
  })
  InfernoGroup({
    minLev = 12,
    maxLev = 30,
    weight = 40,
    danger = ch(7, 10, 15),
    size = 2,
    former = true,
    single = "commando",
    beings = {
      {being = "commando", amount = ch(1, {1, 2}, {3, 5})},
    }
  })
  InfernoGroup({
    minLev = 16,
    maxLev = 35,
    weight = 20,
    danger = ch(13, 16, 20),
    size = 2,
    former = true,
    beings = {
      {being = "commando", amount = ch({2, 3}, {2, 5}, {3, 6})},
    }
  })
  InfernoGroup({
    minLev = 0,
    maxLev = 17,
    weight = 85,
    danger = ch(4, 5, 7),
    size = ch(2, 2, 3),
    single = "imp",
    beings = {
      {being = "imp", amount = ch({2, 3}, {3, 4}, {5, 9})},
    }
  })
  InfernoGroup({
    minLev = 24,
    maxLev = 25,
    weight = 30,
    danger = 5,
    size = 2,
    beings = {
      {being = "nimp", amount = ch(1, 1, {1, 3})},
    }
  })
  InfernoGroup({
    minLev = 26,
    maxLev = 40,
    weight = 75,
    danger = ch(7, 10, 14),
    size = ch(2, 2, 3),
    single = "nimp",
    beings = {
      {being = "nimp", amount = ch({2, 3}, {3, 4}, {5, 9})},
    }
  })
  InfernoGroup({
    minLev = 3,
    maxLev = 29,
    weight = 70,
    danger = ch(4, 5, 6),
    size = ch(2, 2, 3),
    acid = true,
    single = "hydra",
    beings = {
      {being = "hydra", amount = ch({2, 3}, {3, 4}, {5, 7})},
    }
  })
  InfernoGroup({
    minLev = 29,
    maxLev = 50,
    weight = 50,
    danger = ch(8, 9, 10),
    size = 3,
    acid = true,
    beings = {
      {being = "nhydra", amount = ch({1, 2}, {2, 3}, {2, 4})},
      {being = "hydra", amount = {3, 5}},
    }
  })
  InfernoGroup({
    minLev = 35,
    maxLev = 100,
    weight = 40,
    danger = ch(8, 9, 10),
    size = ch(2, 2, 3),
    acid = true,
    single = "nhydra",
    beings = {
      {being = "nhydra", amount = ch({2, 3}, {3, 4}, {3, 5})},
    }
  })
  InfernoGroup({
    minLev = 4,
    maxLev = 10,
    weight = 50,
    danger = ch(6, 8, 10),
    size = ch(2, 2, 3),
    melee = true,
    single = "demon",
    beings = {
      {being = "demon", amount = ch({2, 3}, {4, 6}, {5, 9})},
    }
  })
  InfernoGroup({
    minLev = 11,
    maxLev = 200,
    weight = 45,
    danger = ch(6, 8, 10),
    size = ch(2, 2, 3),
    melee = true,
    dark = true,
    single = "spectre",
    beings = {
      {being = "spectre", amount = ch({2, 3}, {4, 6}, {5, 9})},
    }
  })
  InfernoGroup({
    minLev = 30,
    maxLev = 50,
    weight = 30,
    danger = ch(8, 10, 12),
    size = ch(2, 2, 3),
    melee = true,
    single = "ndemon",
    beings = {
      {being = "ndemon", amount = ch({2, 3}, {4, 6}, {5, 9})},
    }
  })
  InfernoGroup({
    minLev = 13,
    maxLev = 17,
    weight = 40,
    danger = ch(6, 6, 9),
    size = 2,
    fire = true,
    single = "cinder",
    beings = {
      {being = "cinder", amount = ch(1, 1, {2, 3})},
    }
  })
  InfernoGroup({
    minLev = 18,
    maxLev = 45,
    weight = 40,
    danger = ch(12, 15, 18),
    size = 2,
    fire = true,
    beings = {
      {being = "cinder", amount = ch({2, 3}, {2, 4}, {2, 6})},
    }
  })
  InfernoGroup({
    minLev = 42,
    maxLev = 200,
    weight = 50,
    danger = ch(15, 15, 20),
    fire = true,
    single = "ember",
    beings = {
      {being = "ember", amount = ch(1, 1, {1, 2})},
      {being = "cinder", amount = {1, 3}},
    }
  })
  InfernoGroup({
    minLev = 6,
    maxLev = 16,
    weight = 80,
    danger = ch(4, 5, 6),
    size = 2,
    melee = true,
    flying = true,
    bone = true,
    single = "lostsoul",
    beings = {
      {being = "lostsoul", amount = ch({3, 5}, {5, 7}, {5, 9})},
    }
  })
  InfernoGroup({
    minLev = 48,
    maxLev = 200,
    weight = 75,
    danger = ch(10, 12, 14),
    size = 2,
    melee = true,
    flying = true,
    bone = true,
    phasing = true,
    single = "nskull",
    beings = {
      {being = "nskull", amount = ch({3, 5}, {4, 6}, {5, 7})},
    }
  })
  InfernoGroup({
    minLev = 12,
    maxLev = 48,
    weight = 20,
    danger = ch(6, 7, 8),
    size = 2,
    melee = true,
    flying = true,
    bone = true,
    single = "pain",
    beings = {
      {being = "lostsoul", amount = ch({3, 5}, {5, 7}, {5, 9})},
      {being = "pain", amount = ch(1, 1, {2, 3})}
    }
  })
  InfernoGroup({
    minLev = 14,
    maxLev = 52,
    weight = 30,
    danger = ch(6, 7, 8),
    size = 2,
    melee = true,
    flying = true,
    bone = true,
    beings = {
      {being = "lostsoul", amount = ch({3, 5}, {5, 7}, {5, 9})},
      {being = "pain", amount = ch(1, 1, {2, 3})}
    }
  })
  InfernoGroup({
    minLev = 53,
    weight = 45,
    danger = ch(15, 16, 17),
    size = 1,
    melee = true,
    flying = true,
    bone = true,
    single = "npain",
    beings = {
      {being = "npain", amount = 1},
      {being = "nskull", amount = ch({2, 3}, {3, 4}, {4, 5})},
    }
  })
  InfernoGroup({
    minLev = 9,
    maxLev = 50,
    weight = 100,
    danger = 4,
    size = 1,
    phasing = true,
    single = "mist",
    beings = {
      {being = "mist", amount = {1, 2}},
    }
  })
  InfernoGroup({
    minLev = 9,
    maxLev = 40,
    weight = 100,
    danger = 5,
    size = 1,
    phasing = true,
    beings = {
      {being = "mist", amount = 1},
      {being = "imp", amount = {2, 5}},
    }
  })
  InfernoGroup({ -- This is for a weight boost
    minLev = 12,
    maxLev = 43,
    weight = 60,
    danger = 6,
    size = 1,
    phasing = true,
    beings = {
      {being = "mist", amount = {1, 3}},
    }
  })
  InfernoGroup({
    minLev = 38,
    maxLev = 200,
    weight = 40,
    danger = ch(12, 14, 15),
    size = 2,
    phasing = true,
    beings = {
      {being = "nmist", amount = 1},
      {being = "mist", amount = ch({2, 3}, {3, 5}, {4, 6})},
    }
  })
  InfernoGroup({
    minLev = 43,
    maxLev = 200,
    weight = 40,
    danger = 18,
    size = 2,
    phasing = true,
    single = "nmist",
    beings = {
      {being = "nmist", amount = {2, 3}},
    }
  })
  InfernoGroup({
    minLev = 8,
    maxLev = 16,
    weight = 60,
    danger = ch(6, 10, 12),
    size = 1,
    flying = true,
    single = "cacodemon",
    beings = {
      {being = "cacodemon", amount = ch(1, 2, {2, 3})}
    }
  })
  InfernoGroup({
    minLev = 16,
    maxLev = 35,
    weight = 70,
    danger = ch(10, 13, 15),
    size = 2,
    flying = true,
    beings = {
      {being = "cacodemon", amount = ch(2, {2, 3}, {2, 5})}
    }
  })
  InfernoGroup({
    minLev = 34,
    maxLev = 41,
    weight = 100,
    danger = ch(15, 18, 21),
    size = 2,
    flying = true,
    beings = {
      {being = "ncacodemon", amount = ch(1, 1, {1, 2})},
      {being = "cacodemon", amount = ch({2, 3}, {2, 4}, {2, 5})},
    }
  })
  InfernoGroup({
    minLev = 38,
    maxLev = 200,
    weight = 105,
    danger = ch(18, 21, 23),
    size = 2,
    flying = true,
    single = "ncacodemon",
    beings = {
      {being = "ncacodemon", amount = ch({2, 3}, {3, 4}, {4, 5})},
    }
  })
  InfernoGroup({
    minLev = 9,
    maxLev = 15,
    weight = 60,
    danger = ch(6, 7, 10),
    size = ch(2, 3, 3),
    beings = {
      {being = "knight", amount = ch(1, 1, {1, 2})},
      {being = "imp", amount = ch({3, 4}, {4, 7}, {4, 9})},
    }
  })
  InfernoGroup({
    minLev = 16,
    maxLev = 20,
    weight = 40,
    danger = ch(10, 11, 12),
    size = ch(1, 1, 2),
    acid = true,
    single = "knight",
    beings = {
      {being = "knight", amount = ch({2, 4}, {2, 5}, {3, 6})},
    }
  })
  InfernoGroup({
    minLev = 12,
    maxLev = 20,
    weight = 30,
    danger = ch(10, 10, 15),
    size = 1,
    acid = true,
    single = "baron",
    beings = {
      {being = "baron", amount = ch(1, 1, {1, 2})}
    }
  })
  InfernoGroup({
    minLev = 12,
    maxLev = 30,
    weight = 20,
    danger = ch(12, 13, 18),
    size = 2,
    beings = {
      {being = "baron", amount = ch(1, 1, {1, 2})},
      {being = "imp", amount = ch({2, 6}, {4, 6}, {4, 8})},
    }
  })
  InfernoGroup({
    minLev = 31,
    maxLev = 60,
    weight = 20,
    danger = ch(13, 14, 17),
    size = ch(2, 2, 3),
    beings = {
      {being = "baron", amount = ch({1, 2}, {1, 2}, {2, 3})},
      {being = "nimp", amount = ch({3, 5}, {4, 6}, {5, 7})},
    }
  })
  InfernoGroup({
    minLev = 21,
    maxLev = 200,
    weight = 50,
    danger = ch(18, 23, 28),
    size = 2,
    acid = true,
    beings = {
      {being = "baron", amount = ch(2, {2, 3}, {3, 5})}
    }
  })
  InfernoGroup({
    minLev = 20,
    maxLev = 200,
    weight = 50,
    danger = ch(20, 24, 28),
    size = 2,
    beings = {
      {being = "baron", amount = ch(2, {2, 3}, {2, 4})},
      {being = "captain", amount = {2, 3}},
      {being = "sergeant", amount = {3, 5}},
    }
  })
  InfernoGroup({
    minLev = 20,
    maxLev = 200,
    weight = 35,
    danger = ch(15, 20, 25),
    size = 2,
    acid = true,
    beings = {
      {being = "baron", amount = ch(1, {1, 2}, {1, 4})},
      {being = "knight", amount = ch({2, 4}, {2, 5}, {3, 7})},
    }
  })
  InfernoGroup({
    minLev = 13,
    maxLev = 20,
    weight = 35,
    danger = ch(12, 16, 24),
    size = 2,
    spider = true,
    single = "arachno",
    beings = {
      {being = "arachno", amount = ch({1, 2}, {1, 3}, {2, 5})},
    }
  })
  InfernoGroup({
    minLev = 13,
    maxLev = 20,
    weight = 45,
    danger = ch(20, 25, 30),
    size = ch(2, 2, 3),
    spider = true,
    beings = {
      {being = "arachno", amount = ch({2, 4}, {3, 6}, {4, 8})},
    }
  })
  InfernoGroup({
    minLev = 39,
    maxLev = 60,
    weight = 55,
    danger = ch(17, 20, 22),
    size = 2,
    spider = true,
    single = "narachno",
    beings = {
      {being = "narachno", amount = ch({2, 3}, {3, 5}, {3, 6})},
    }
  })
  InfernoGroup({
    minLev = 13,
    maxLev = 200,
    weight = 50,
    danger = ch(11, 14, 19),
    size = 3,
    bone = true,
    single = "revenant",
    beings = {
      {being = "revenant", amount = ch(1, {1, 2}, {1, 5})}
    }
  })
  InfernoGroup({
    minLev = 15,
    maxLev = 200,
    weight = 50,
    danger = ch(12, 15, 20),
    size = 3,
    single = "mancubus",
    beings = {
      {being = "mancubus", amount = ch(1, {1, 2}, {1, 5})}
    }
  })
  InfernoGroup({
    minLev = 16,
    maxLev = 200,
    weight = 55,
    danger = ch(13, 16, 22),
    size = 3,
    single = "asura",
    beings = {
      {being = "asura", amount = ch(1, {1, 2}, {1, 5})}
    }
  })
  InfernoGroup({
    minLev = 16,
    maxLev = 20,
    weight = 10,
    danger = ch(12, 12, 15),
    size = 1,
    single = "arch",
    beings = {
      {being = "arch", amount = ch(1, 1, {1, 2})},
    }
  })
  InfernoGroup({
    minLev = 16,
    maxLev = 200,
    weight = 30,
    danger = ch(14, 14, 17),
    size = 3,
    beings = {
      {being = "arch", amount = ch(1, 1, {1, 2})},
      {being = "captain", amount = {3, 4}},
      {being = "sergeant", amount = {3, 6}},
      {being = "sergeant", amount = {4, 8}},
    }
  })
  InfernoGroup({
    minLev = 20,
    maxLev = 200,
    weight = 20,
    danger = ch(20, 25, 35),
    size = 3,
    beings = {
      {being = "arch", amount = ch(1, 1, {1, 2})},
      {being = "mancubus", amount = ch({1, 4}, {2, 5}, {2, 6})},
    }
  })
  InfernoGroup({
    minLev = 20,
    maxLev = 200,
    weight = 30,
    danger = ch(20, 25, 35),
    size = 3,
    beings = {
      {being = "arch", amount = ch(1, 1, {1, 2})},
      {being = "mancubus", amount = ch({2, 4}, {3, 5}, {3, 6})},
    }
  })
  InfernoGroup({
    minLev = 20,
    maxLev = 200,
    weight = 25,
    danger = ch(24, 29, 39),
    size = 3,
    beings = {
      {being = "arch", amount = ch(1, 1, {1, 2})},
      {being = "asura", amount = ch({2, 4}, {3, 5}, {3, 6})},
    }
  })
  InfernoGroup({
    minLev = 20,
    maxLev = 200,
    weight = 40,
    danger = ch(20, 25, 35),
    size = 3,
    bone = true,
    beings = {
      {being = "arch", amount = ch(1, 1, {1, 2})},
      {being = "revenant", amount = ch({2, 4}, {3, 5}, {3, 6})},
    }
  })
  InfernoGroup({
    minLev = 44,
    maxLev = 200,
    weight = 75,
    danger = 20,
    size = 1,
    acid = true,
    single = "duke",
    beings = {
      {being = "duke", amount = 1},
    }
  })
  InfernoGroup({
    minLev = 56,
    maxLev = 200,
    weight = 65,
    danger = 26,
    size = 1,
    acid = true,
    single = "archduke",
    beings = {
      {being = "archduke", amount = 1},
    }
  })
  InfernoGroup({
    minLev = 60,
    maxLev = 200,
    weight = 40,
    danger = 30,
    size = 1,
    single = "hwitch",
    beings = {
      {being = "hwitch", amount = 1},
    }
  })
end