--Level modifying.  Invasion is the antithesis of roguelikes.
--NOTHING is generated at random.

--This is the exposed interface
Elevator.Level = {}
Elevator.Level.Init         = nil
Elevator.Level.ClearMemory  = nil
Elevator.Level.ClearCorpses = nil
Elevator.Level.ClearHazards = nil
Elevator.Level.DropItemNearPlayer = nil

--and this is the const/internal stuff
local CorpseCells   = {}
local HazardCells   = {}

--here's the actual interface
Elevator.Level.ClearMemory = function ()

  --New wave, possibly new level history.
  for c in area.FULL() do
    local cell = cells[ level.map[ c ] ]
    if cell.id == "void" then
      level.light[ c ][LFEXPLORED] = false
    end
  end
end
Elevator.Level.ClearCorpses = function ()

  --fade away all blood
  generator.transmute("blood", "floor")
  generator.transmute("bloodpool", "blood")

  for i = 1, #CorpseCells do
    generator.transmute(CorpseCells[i], "bloodpool")
  end
end
Elevator.Level.ClearHazards = function ()
  for i = 1, #HazardCells do
    generator.transmute(HazardCells[i], "floor")
  end
end
Elevator.Level.DropItemNearPlayer = function (item, radius, noforce)
    radius = radius or 6
    local ret = level:drop_item( item, generator.random_empty_coord({ EF_NOITEMS, EF_NOBLOCK, EF_NOHARM, EF_NOSPAWN }, area.around( player.position, radius ):clamped( area.FULL_SHRINKED )))
    if(not ret and not noforce) then
        ret = level:drop_item(item)
    end

    return ret
end
--And here's some init code.
Elevator.Level.Init = function ()

  --Iterate through all cell prototypes (this table is indexable by number or string;
  --we only want to traverse it once so we'll stick with numbers)
  for i = 1, #cells do
    if(cells[i] ~= nil and cells[i].flags ~= nil) then
      if(cells[i].flags[CF_CORPSE] == true) then
        table.insert(CorpseCells, i) --i == CELL_sID's numeric value
      elseif(cells[i].flags[CF_HAZARD] == true) then
        table.insert(HazardCells, i)
      end
    end
  end
end
