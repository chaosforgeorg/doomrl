Features({
  id = "shambler",
  type = "full",
  weight = 50,
  unique = true,
  Check = function(room, rm)
    return
      Generator.check_dims(rm, 8, 8, 26, 14) and
      Level.danger_level >= 10
  end,
  Create = function(room)
    return Generator.generate_vault(room, "shambler")
  end
})