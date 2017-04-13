items.lever_walls.fullchance = 15
items.lever_flood_water.fullchance = 23
items.lever_flood_acid.fullchance = 4
items.lever_flood_lava.fullchance = 3
items.lever_kill.fullchance = 15

Features({
  id = "lever",
  type = "doodad",
  weight = 85,
  Check = function(room, rm)
    return Generator.check_dims(rm, 4, 4, 20, 15)
  end,
  Create = function(room)
    local rm = Generator.room_meta[room]
    rm.doodad = rm.doodad - 1
    local lid
    local roll = math.random(100)
        if roll <= 11 then lid = "lever_explode"
    elseif roll <= 23 then lid = "lever_summon"
    elseif roll <= 35 then lid = "lever_walls"
    elseif roll <= 39 then lid = "lever_flood_lava"
    elseif roll <= 43 then lid = "lever_flood_acid"
    elseif roll <= 47 then lid = "lever_phase"
    elseif roll <= 48 then lid = "lever_mod"
    elseif roll <= 62 then lid = "lever_kill"
    elseif roll <= 74 then lid = "lever_medical"
    elseif roll <= 86 then lid = "lever_repair"
    elseif roll <= 90 then lid = "lever_flood_water"
    else                   lid = "lever_ammo"
    end
    local pos = Generator.random_empty_coord({EF_NOBLOCK, EF_NOSTAIRS, EF_NOITEMS, EF_NOHARM, EF_NOSPAWN}, room)
    if not pos then
      return
    end
    local lever = item.new(lid)
    if lever:has_property("target_area") then
      lever.target_area = room:clone()
    end
    Level.drop_item(lever, pos)
    if items[lid].fullchance and math.random(100) < items[lid].fullchance then
      lever.target_area = area.FULL:clone()
      if items[lid].warning then
        ui.msg(items[lid].warning)
      end
    end
  end,
})