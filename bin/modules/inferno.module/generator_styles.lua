inferno.styles = {}

inferno.styles.base_style = 1
inferno.styles.tech_style = 2
inferno.styles.hell_style = 3

table.insert(styles, {
  floor = "floor",
  wall = "rwall",
  door = "doorb",
  odoor = "odoorb"
})

inferno.styles.hellbase_style = #styles

table.insert(styles, {
  floor = "floorc",
  wall = "cwall",
  door = "door",
  odoor = "odoor",
})

inferno.styles.cave_style = #styles