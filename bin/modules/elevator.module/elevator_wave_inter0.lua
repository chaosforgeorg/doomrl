--Waves are predefined objects with rules and other fun things.
Elevator.Intermission = {}

local elevator_area = area.new(36, 16, 44, 20)
local map = [[
###===###
#1P:::P2#
|:+:}:+:|
#2T:::C1#
###---###
]]
local item_translation =  {
  ['}'] = { sid = "dshotgun", rate_next = 0 },
  ['1'] = { sid = "shell",    rate_next = 0 },
  ['2'] = { sid = "shell",    rate_next = 0 },
  ['+'] = { sid = "smed",     rate_next = 0 },
}

local timer = 0
Elevator.Intermission.level = {

  name = "inter",

  OnLoad = function()

    generator.fill("floor", area.FULL)
    local translation = {
      [':'] = "floor",
      ['='] = { "edoor", flags = { LFPERMANENT } },
      ['#'] = { "ewall", flags = { LFPERMANENT } },
      ['-'] = { "ehwindow", flags = { LFPERMANENT } },
      ['|'] = { "evwindow", flags = { LFPERMANENT } },
      ['P'] = "plant1",
      ['T'] = { "tv", flags = { LFPERMANENT } },
      ['C'] = "couch",
      ['}'] = "floor",
      ['1'] = "floor",
      ['2'] = "floor",
      ['+'] = "floor",
    }
    generator.place_tile( translation, map, elevator_area.a.x, elevator_area.a.y )

    if(player:get_trait( traits["gun"].nid ) > 0) then
      item_translation['1'] = { sid = "ammo", rate_next = 0 }
    end
    Elevator.ItemEngine.ClearItems()
    Elevator.ItemEngine.PauseSounds(true)
    Elevator.ItemEngine.AddMap( item_translation, map, elevator_area.a )
    Elevator.ItemEngine.CheckItems()
    Elevator.ItemEngine.PauseSounds(false)

    for c in elevator_area:coords() do
      level.light[ c ][LFEXPLORED] = true
    end

    core.play_music("D_MAP08")
    timer = 250
  end,


  OnUnload = function()

    for c in area.FULL:coords() do
      if not elevator_area:contains( c ) then
        level.light[ c ][LFEXPLORED] = false
      end
    end

  end,

  OnTick = function()
    timer = timer - 1
    if    (timer == 80) then Elevator.AnnouncerPlaySound("three")
    elseif(timer == 50) then Elevator.AnnouncerPlaySound("two")
    elseif(timer == 20) then Elevator.AnnouncerPlaySound("one")
    elseif(timer == 0)  then
      Elevator.AnnouncerPlaySound("fight")
      Elevator.WaveEngine.Next(true)
    end
  end,

  OnDieCheck = function(player)

    player:play_sound(beings["soldier"].sound_die)
    if(not level.map[ player.position ].flags[ CF_NOCHANGE ]) then
      level.map[ player.position ] = "corpse"
    end
    Elevator.Player.DropEquipment(player)

    player:displace(coord.new(40,18))

    player.hp = player.hpmax
    return false
  end,
}
Elevator.Intermission.close = {

  name = "close",
  items = {},

  OnLoad = function()
    timer = 250
  end,

  OnTick = function()
    timer = timer - 1

    --countdown
    if    (timer == 245) then ui.msg("Elevator is closing!")
    elseif(timer == 160) then ui.msg("5")
    elseif(timer == 130) then ui.msg("4")
    elseif(timer == 100) then ui.msg("3")
    elseif(timer == 70)  then ui.msg("2")
    elseif(timer == 40)  then ui.msg("1")
    elseif(timer == 0)   then
      Elevator.WaveEngine.Next(false)
    end
  end,

  OnUnload = function()
    if(level.map[ player.position ] == "oedoor") then
      thing.displace(player, player.position + coord.new( 0, 1 ))
    end

    generator.transmute("oedoor", "edoor")
    for c in area.FULL:coords() do
      level.light[ c ][LFPERMANENT] = false
      level.light[ c ][LFEXPLORED] = false
      level.light[ c ][LFBLOOD] = false
      if(not elevator_area:contains(c) or level.map[c] == "teleport" or elevator_area:is_edge(c)) then
        local item = level:get_item(c)
        if item then item:destroy() end
      end
    end

    if(not elevator_area:contains( player.position )) then
      player:kill() --Outside of the elevator
    end
  end,
}
