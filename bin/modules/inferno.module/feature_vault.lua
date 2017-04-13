beings["shambler"].OnDie = function(self)
  if self:has_property("target_area") then
    local room = self.target_area:clamped(area.FULL_SHRINKED)
    for c in room() do
      local tile = cells[Level[c]]
      if tile.set == CELLSET_WALLS then
        Level[c] = "floor"
      end
    end
    ui.msg("The lab cache opens.")
  end
end

Items({
  id = "lever_shambler",
  name = "lever",
  color = WHITE,
  sprite = SPRITE_LEVER,
  weight = 0,
  color_id = "lever",
  type = ITEMTYPE_LEVER,
  good = "dangerous",
  desc = "opens the lab",
  OnCreate = function(self)
    self:add_property("target_area", false)
  end,
  OnUse = function(self, being)
    local pos = self.target_area:shrinked():random_coord()
    local shambler = Level.drop_being("shambler", pos)
    shambler:add_property("target_area", self.target_area)
    player:play_sound({"shambler.act", "baron.act"})
    ui.msg("You hear a familiar wail!")
    Level.clear_item(self:get_position())
    return false
  end,
})

-- This is included outside of the feature framework because
-- it is also used for the shambler feature.
Generator.generate_vault = function(room, mode)
  local rm = Generator.room_meta[room]
  rm.full = true
  local locked = mode == "locked" or mode == "shambler"
  local shambler = mode == "shambler"
  if locked then
    local auxiliary_room = Generator.get_auxiliary_room()
    if not auxiliary_room then
      rm.full = false
      return false
    end
    local arm = Generator.room_meta[auxiliary_room]
    local keypos = Generator.random_empty_coord({EF_NOITEMS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN}, auxiliary_room)
    if not keypos then
      rm.full = false
      return false
    end
    local lever
    if shambler then
      lever = Level.drop_item("lever_shambler", keypos)
    else
      lever = Level.drop_item("lever_walls", keypos)
    end
    lever.flags[IF_NODESTROY] = true
    if not lever:has_property("target_area") then
      lever:add_property("target_area", false)
    end
    lever.target_area = room:shrinked(1)
    arm.used = true
  end
  local hallway = room:shrinked(1)
  for c in hallway:edges() do
    if Level[c] == styles[Level.style].wall then
      if math.random(6) == 1 then
        Level[c] = "door"
      else
        Level[c] = styles[Level.style].floor
      end
    end
  end
  local vault = room:shrinked(2)
  if locked then
    Level.fill("rwall", vault)
  else
    Level.fill("wall", vault)
    Generator.set_cell(vault:random_inner_edge_coord(), "door")
  end
  vault:shrink(1)
  Level.fill(styles[Level.style].floor, vault)
  if locked then
    Generator.set_permanence(vault:expanded(1), true, "rwall")
  end
  local roll = math.max(math.random(5) + Level.danger_level + (DIFFICULTY - 2) * 3, 1)
  local unique_mod = 2
  local diffmod = (DIFFICULTY - 2) * 2
  if 0 < diffmod then
    diffmod = math.random(diffmod)
  end
  if locked then
    roll = roll + 5
    unique_mod = 3
  end
  if shambler then
    local amount = 5
    for i = 1, 50 do
      if amount == 0 then
        break
      end
      local pos = vault:random_coord()
      if not pos then
        break
      end
      if not Level.get_item(pos) then
        local item
        if amount <= 4 then
          item = table.random_pick({
            "mod_agility",
            "mod_bulk",
            "mod_tech",
            "mod_power"
          })
        else
          item = Level.roll_weight({
            items["umod_sniper"],
            items["umod_firestorm"],
            items["umod_nano"],
            items["umod_onyx"],
          })
          item = item.id
        end
        Level.drop_item(item, pos)
        amount = amount - 1
      end
    end
    player:add_history("On level @1 there was a strange laboratory.")
    ui.msg("The air here is slightly charged.")
  else
    local amount = math.random(3) + 2
    local very_excited = math.random(100) == 1
    if very_excited then
      roll = roll + 5
      amount = amount + 3
      unique_mod = unique_mod + 1
    end
    local being
    if roll < 4 then
      being = "former"
    elseif roll < 10 then
      being = "lostsoul"
    elseif roll < 15 then
      being = "demon"
      if math.random(3) == 1 then
        being = "spectre"
      end
    elseif roll < 28 then
      being = "cacodemon"
    else
      being = "mist"
    end
    if roll >= 35 and math.random(6) == 1 then
      being = "ndemon"
    end
    if roll >= 35 and math.random(3) == 1 then
      being = "ncacodemon"
    end
    if roll >= 50 and math.random(4) == 1 then
      being = "narachno"
    end
    if roll >= 50 and math.random(6) == 1 then
      being = "nmist"
    end
    if roll >= 55 and math.random(4) == 1 then
      being = "nskull"
    end
    if roll >= 60 and math.random(8) == 1 then
      being = "arch"
    end
    if roll >= 100 and math.random(10) == 1 then
      being = "narch"
    end
    if roll >= 50 and being == "cacodemon" then
      being = "ncacodemon"
    end
    local diffmod = (DIFFICULTY - 2)*2
    if diffmod > 0 then
      diffmod = math.random(diffmod)
    end
    Level.area_summon(vault, being, math.random(4) + 2+ diffmod)
    for i = 1, 50 do
      if amount == 0 then
        break
      end
      local pos = vault:random_coord()
      if not pos then
        break
      end
      if not Level.get_item(pos) then
        local item = Level.roll_item_type({
          ITEMTYPE_ARMOR,
          ITEMTYPE_RANGED,
          ITEMTYPE_AMMOPACK,
          ITEMTYPE_PACK}, roll + 3, unique_mod)
        Level.drop_item(item, pos)
        amount = amount - 1
      end
    end
    if very_excited then
      -- ;)
      ui.msg("You feel very excited!")      
    else
      ui.msg(table.random_pick({
        "You feel excited!",
        "There's the smell of blood in the air!",
        "There's something special here..."}))
    end
  end
  for i = 1, 30 do
    local pos = vault:random_coord()
    Generator.set_cell(pos, "blood")
  end
  for c in vault() do
    Level.light[c][LFNOSPAWN] = true
  end
  return true
end

Features({
  id = "vault",
  type = "full",
  weight = 70,
  Check = function(room, rm)
    return Generator.check_dims(rm, 8, 8, 26, 14)
  end,
  Create = function(room)
    local locked = math.random(25) < Level.danger_level and math.random(4) == 1
    --locked = true
    if locked and Generator.generate_vault(room, "locked") then
      return
    end
    Generator.generate_vault(room, "normal")
  end
})