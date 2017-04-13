--Level modifying.  Drops items, enemies, clears cells, etc.

--This is the exposed interface
Skulltag.Level = {}
Skulltag.Level.Init         = nil
Skulltag.Level.ClearMemory  = nil
Skulltag.Level.ClearCorpses = nil
Skulltag.Level.ClearHazards = nil
Skulltag.Level.DropItems    = nil
Skulltag.Level.DropBarrels  = nil
Skulltag.Level.DropWave     = nil

--and this is the const/internal stuff
local TurnsComputerMap = 4
local TurnsTrackingMap = 1
local MaxTurnsComputerMap = 5
local MaxTurnsTrackingMap = 2
local SpawnedBeingPercentage = .5
local SpawnedItemPercentage = .5
local PlayerExpRate = 2.0
local CorpseCells   = {}
local HazardCells   = {}

--here's the actual interface
Skulltag.Level.ClearMemory = function ()

  --Without this function the player will instantly know where newly spawned
  --items are.  That doesn't make sense.  I tried being clever and leaving cells
  --with items exposed, but this led to other oddities.  The only fair thing to
  --do is blank the map until we can convince KK not to show all items again.
  for c in area.FULL() do
    local cell = cells[ level.map[ c ] ]
    if cell.set ~= CELLSET_WALLS then 
      level.light[ c ][LFEXPLORED] = false
    end
  end

  --Check the player powerups too.
  if (level.flags[ LF_ITEMSVISIBLE ] and player.map_rounds > 0) then
    if (player.map_rounds - 1 <= 0) then
      level.flags[ LF_ITEMSVISIBLE ] = false
    else
      player.map_rounds = player.map_rounds - 1
    end
  end
  if (level.flags[ LF_BEINGSVISIBLE ] and player.pmap_rounds > 0) then
    if (player.pmap_rounds - 1 <= 0) then
      level.flags[ LF_BEINGSVISIBLE ] = false
    else
      player.pmap_rounds = player.pmap_rounds - 1
    end
  end
end
Skulltag.Level.ClearCorpses = function ()

  --fade away all blood
  generator.set_blood( area.FULL_SHRINKED, false, "floor")
  generator.set_blood( area.FULL_SHRINKED, true, "bloodpool")
  generator.transmute("bloodpool", "floor")

  for i = 1, #CorpseCells do
    generator.transmute(CorpseCells[i], "bloodpool")
  end
end
Skulltag.Level.ClearHazards = function ()
  for i = 1, #HazardCells do
    generator.transmute(HazardCells[i], "floor")
  end
end

Skulltag.Level.DropItems = function ()

  --We used to always make sure ammo and medicine was dropped but that's no longer necessary.
  level:flood_items({ amount = generator.item_amount() * SpawnedItemPercentage })
end
Skulltag.Level.DropBarrels = function ()

  --There is a generator.generate_barrels() procedure but it does not satisfy my needs.
  local barrels = math.random(5 + math.max(level.danger_level / 5, 5))
  for i = 1, barrels do

    local barreltype = "barrel"
    if(level.danger_level > 3 and math.random(3) == 1) then
      barreltype = "barrela"
      if(level.danger_level > 7 and math.random(2) == 1) then
        barreltype = "barreln"
      end
    end

    generator.set_cell( generator.standard_empty_coord(), barreltype )
  end
end
Skulltag.Level.DropWave = function ()

  --Replaced with API code!
  level:flood_monsters({ danger = math.ceil( generator.being_weight() * SpawnedBeingPercentage ) })
  Skulltag.TotalNPCs = Skulltag.NPCs
end


--And here's some init code.
Skulltag.Level.Init = function ()

  player.expfactor = player.expfactor * PlayerExpRate

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

  --Adjust tracking/computer maps
  items["map"].OnPickup = core.create_seq_function(items["map"].OnPickup,
    function(self,being)

      player.map_rounds = math.min(player.map_rounds + TurnsComputerMap, MaxTurnsComputerMap)
      if being.flags[BF_MAPEXPERT] then
        player.pmap_rounds = math.min(player.pmap_rounds + TurnsTrackingMap, MaxTurnsTrackingMap)
      end
    end
  )
  items["pmap"].OnPickup = core.create_seq_function(items["pmap"].OnPickup,
    function(self,being)

      player.map_rounds = math.min(player.map_rounds + TurnsComputerMap, MaxTurnsComputerMap)
      player.pmap_rounds = math.min(player.pmap_rounds + TurnsTrackingMap, MaxTurnsTrackingMap)
    end
  )

  --Hook being create and death in order to keep these counts accurate.
  for i=2, #beings, 1 do
    beings[i].OnCreate = core.create_seq_function(beings[i].OnCreate,
    function(self)
      Skulltag.NPCs = Skulltag.NPCs + 1
      Skulltag.TotalNPCs = Skulltag.TotalNPCs + 1
      Skulltag.HUD.MarkDirty()
    end)
  end
  for i=2, #beings, 1 do
    beings[i].OnDie = core.create_seq_function(beings[i].OnDie,
    function(self)
      Skulltag.AudienceOnKill()
      Skulltag.NPCs = Skulltag.NPCs - 1
      Skulltag.HUD.MarkDirty()
    end)
  end
end
