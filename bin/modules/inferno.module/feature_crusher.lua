Items({
  id = "lever_crusher",
  name = "lever",
  color = WHITE,
  sprite = SPRITE_LEVER,
  weight = 0,
  color_id = "lever",
  type = ITEMTYPE_LEVER,
  good = "neutral",
  desc = "controls crusher",
  OnCreate = function(self)
    self:add_property("down", false)
    self:add_property("target_area", false)
    self:add_property("floor_cell", false)
  end,
  OnUse = function(self, being)
    if not being:is_player() then
      return
    end
    if self.down then
      for c in self.target_area() do
        if Level[c] == "crusher" then
          Level[c] = self.floor_cell
        elseif Level[c] == "bcrusher" then
          Level[c] = "bloodpool"
        end
      end
      self.down = false
    else
      -- Scan twice: first for things to destroy, then to place tiles
      for c in self.target_area() do
        if Level.get_being(c) then
          local b = Level.get_being(c)
          b:play_sound("gib")
          b:kill()
        end
        if Level.get_item(c) then
          Level.clear_item(c)
        end
        if cells[Level[c]].OnDestroy then
          cells[Level[c]].OnDestroy(c.x, c.y)
        end
        if Level[c] == "nukecell" then
          player.nuketime = 0
          player:nuke(1)
          player.scount = math.min(player.scount, 4999)
        end
      end
      for c in self.target_area() do
        if Level[c] == "blood" or Level[c] == "bloodpool" or Level[c] == "corpse" or cells[Level[c]].flag_set[CF_CORPSE] then
          Level[c] = "bcrusher"
        else
          Level[c] = "crusher"
        end
      end
      self.down = true
    end
    return false
  end,
})

Features({
  id = "crusher",
  type = "full",
  weight = 15,
  Check = function(room, rm)
    return Generator.check_dims(rm, 6, 6, 12, 12)
  end,
  Create = function(room)
    Generator.room_meta[room].full = true
    local floor_cell = styles[Level.style].floor
    local interior = room:shrinked()
    local crusher = interior:shrinked()
    Level.fill(floor_cell, interior)
    local lever_pos = interior:random_edge_coord()
    local lever = Level.drop_item("lever_crusher", lever_pos)
    lever.target_area = crusher
    lever.floor_cell = floor_cell
    for c in crusher() do
      Level.light[c][LFNOSPAWN] = true
    end
  end,
})