register_level "phobos_arena"
{
  name = "Phobos Arena",
  entry = "Then at last he found the Phobos Arena!",
  welcome = "You enter a big arena. There's blood everywhere. You hear heavy mechanical footsteps...",

  Create = function ()
    generator.fill( "wall", area.FULL )
    generator.fill( "floor", area.FULL_SHRINKED )
    local scatter_area = area.new( 5,3,68,15 )
    local translation = {
        ['.'] = { "floor", flags = { LFBLOOD } },
        ['#'] = "gwall",
        ['>'] = "stairs",
    }
    generator.scatter_put(scatter_area,translation, [[
      .....
      .###.
      .###.
      .###.
      .....
    ]],"floor",12)

    level.flags[ LF_NOHOMING ] = true
    generator.scatter_blood(area.FULL_SHRINKED,"floor",100)
    generator.set_permanence( area.FULL )
  end,

  OnEnter = function ()
    local boss = level:summon("cyberdemon")
    boss.flags[ BF_BOSS ] = true
  end, 
}
