core.declare("hellgate_remix",{})

hellgate_remix.am = nil
hellgate_remix.friends = {player}

function hellgate_remix.register_friend(friend_being)
  table.insert(hellgate_remix.friends, friend_being)
end

function hellgate_remix.delete_friend(friend_being)
  for index, being in ipairs(hellgate_remix.friends) do
    if friend_being == being then
      table.remove(hellgate_remix.friends, index)
      return true
    end
  end
  return false
end

function hellgate_remix.is_alive(friend_being)
  for _, being in ipairs(hellgate_remix.friends) do
    if friend_being == being then
      return true
    end
  end
  return false
end

-- calculates if being1 can see being2
-- algorithm is conservative compared to real LOS
function hellgate_remix.check_visible(being1, being2)
  if being1:distance_to(being2) > being1.vision then
    return false
  elseif being1:is_player() then
    return being2:is_visible()
  elseif being2:is_player() then
    return being1:is_visible()
  else
    local pos = being1:get_position()
    local x0, y0 = pos.x, pos.y
    pos = being2:get_position()
    local x1, y1 = pos.x, pos.y
    local steps = math.max(math.abs(x1 - x0), math.abs(y1 - y0))
    local x, y = x0, y0
    local dx, dy = (x1 - x0) / steps, (y1 - y0) / steps
    local step = 1
    while step <= steps do
      x = x + dx
      y = y + dy
      local poss = {
        coord.new(math.ceil(x), math.ceil(y)),
        coord.new(math.ceil(x), math.floor(y)),
        coord.new(math.floor(x), math.ceil(y)),
        coord.new(math.floor(x), math.floor(y))}
      for _, pos in ipairs(poss) do
        local cell = cells[Generator.get_cell(pos)]
        if cell.flag_set[CF_BLOCKLOS] then
          return false
        end
      end
      step = step + 1
    end
    return true
  end    
end

function hellgate_remix.open_door(being)
  for c in area.around(being:get_position(), 1)() do
    local cell = cells[Generator.get_cell(c)]
    if cell.id == "door" then
      -- (Not sure why this doesn't work) cell.proto.OnAct(c, being)
      being:msg("You open the door.")
      being:play_sound("door.open")
      Generator.set_cell(c, "odoor")
      being.scount = being.scount - 500
      return
    end
  end
end

function hellgate_remix.pickup_item(being)
  local item = Level.get_item(being:get_position())
  if item then
    being:play_sound(item.proto.id .. ".pickup")
    Level.clear_item(being:get_position())
    being.scount = being.scount - 1000
    return item.id
  end
  return nil
end

AI({
  name = "am_ai",
  OnCreate = function(self)
    self:add_property("ai_state", "default")
    self:add_property("objectives", {
      {"item", coord.new(2, 10)},
      {"equip", "armor", "rarmor"},
      {"item", coord.new(2, 7)},
      {"item", coord.new(4, 7)},
      {"item", coord.new(5, 7)},
      {"item", coord.new(7, 7)},
      {"item", coord.new(7, 13)},
      {"item", coord.new(5, 13)},
      {"item", coord.new(4, 13)},
      {"item", coord.new(2, 13)},
      {"move", coord.new(7, 10)},
      {"move", coord.new(8, 10)},
      {"ikill", coord.new(12, 13), coord.new(12, 4)},
      {"ikill", coord.new(12, 13), coord.new(14, 5)},
      {"ikill", coord.new(12, 13), coord.new(16, 4)},
      {"ikill", coord.new(12, 13), coord.new(18, 5)},
      {"ikill", coord.new(12, 7), coord.new(12, 16)},
      {"ikill", coord.new(12, 7), coord.new(14, 15)},
      {"ikill", coord.new(12, 7), coord.new(16, 16)},
      {"ikill", coord.new(12, 7), coord.new(18, 15)},
      {"ikill", coord.new(17, 10), coord.new(22, 5)},
      {"ikill", coord.new(17, 10), coord.new(22, 15)},
      {"ikill", coord.new(19, 10), coord.new(24, 4)},
      {"ikill", coord.new(19, 10), coord.new(24, 16)},
      {"ikill", coord.new(20, 10), coord.new(26, 5)},
      {"ikill", coord.new(20, 10), coord.new(28, 4)},
      {"ikill", coord.new(20, 10), coord.new(26, 15)},
      {"ikill", coord.new(20, 10), coord.new(28, 16)},
      {"move", coord.new(30, 10)},
      {"killplayer"}
    })
    self:add_property("ikill", nil)
    self:add_property("medpacks", 2)
  end,
  states = {
    default = function(self)
      if self.hp <= 20 and self.medpacks > 0 then
        self.medpacks = self.medpacks - 1
        self.hp = self.hpmax
        self:play_sound("lmed.use")
        if self:is_visible() then
          ui.msg(self.name .. " uses a large med-pack. " .. self.name .. " looks healthy!")
        end
        self.scount = self.scount - 1000
        return
      end
      local target = nil
      local target_dist = 200
      for _, friend in ipairs(hellgate_remix.friends) do
        local dist = self:distance_to(friend)
        if dist < target_dist and hellgate_remix.check_visible(self, friend) then
          target = friend
          target_dist = dist
        end
      end
      if target then
        if target_dist < 5 then
          self.eq.weapon = item.new("uashotgun")
          self:fire(target:get_position(), self.eq.weapon)
        else
          self.eq.weapon = item.new("bazooka")
          self:fire(target:get_position(), self.eq.weapon)
        end
      end
      local obj = nil
      if #self.objectives > 0 then
        obj = self.objectives[1]
      end
      if obj and self.scount >= 5000 then
        local otype = obj[1]
        if otype == "item" then
          local c = obj[2]
          if self:get_position() == c then
            hellgate_remix.pickup_item(self)
            table.remove(self.objectives, 1)
          else
            self:direct_seek(c)
          end
        elseif otype == "equip" then
          local slot, id = obj[2], obj[3]
          self.eq[slot] = item.new(id)
          self.color = RED
          table.remove(self.objectives, 1)          
          self.scount = self.scount - 1000         
        elseif otype == "move" then
          local c = obj[2]
          if self:get_position() == c then
            table.remove(self.objectives, 1)
            return
          end
          hellgate_remix.open_door(self)
          if self.scount >= 5000 then
            self:direct_seek(c)
          end
        elseif otype == "ikill" then
          if #obj == 3 then
            local c_me, c_him = obj[2], obj[3]
            local being = Level.get_being(c_him)
            if being and hellgate_remix.is_alive(being) then
              self.ikill = being
              self.objectives[1] = {"ikill", c_me}
            else
              table.remove(self.objectives, 1)
              return
            end
          end
          if self.ikill and hellgate_remix.is_alive(self.ikill) then
            local c = obj[2]
            if self:get_position() == c then
              self.eq.weapon = item.new("bazooka")
              self:fire(self.ikill:get_position(), self.eq.weapon)
            else
              self:direct_seek(c)
            end
          else
            table.remove(self.objectives, 1)
            return
          end
        elseif otype == "killplayer" then
          hellgate_remix.open_door(self)
          if self.scount >= 5000 then
            self:direct_seek(player:get_position())
          end
        end
      end
      if self.scount >= 5000 then
        self.scount = self.scount - 1000
      end
    end}})

AI({
  name = "friend_ranged_seek_ai",
  OnCreate = function(self)
    self:add_property("ai_state", "seek")
  end,
  states = {
    seek = function(self)
      if math.random(30) == 1 then
        self:play_sound(self.proto.sound_act)
      end
      local target = hellgate_remix.am
      local roll = math.random(100)
      if self:distance_to(target) == 1 then
        self:attack(target)
      elseif roll <= self.proto.attackchance and hellgate_remix.check_visible(self, target) then
        self:fire(target:get_position(), self.eq.weapon)
      else
        self:direct_seek(target:get_position())
      end
      if self.scount >= 5000 then
        self.scount = self.scount - 1000
      end
    end}})
    
AI({
  name = "friend_melee_seek_ai",
  OnCreate = function(self)
    self:add_property("ai_state", "seek")
  end,
  states = {
    seek = function(self)
      if math.random(30) == 1 then
        self:play_sound(self.proto.sound_act)
      end
      local target = hellgate_remix.am
      if self:distance_to(target) == 1 then
        self:attack(target)
      else
        self:direct_seek(target:get_position())
      end
      if self.scount >= 5000 then
        self.scount = self.scount - 1000
      end
    end}})

-- Imp with friendly ai and 0 xp
Beings({
  name = "imp",
  id = "friend_imp",
  sound_id = "imp",
  ascii = "i",
  color = BROWN,
  todam = 2,
  tohit = 3,
  hp = 12,
  speed = 105,
  min_lev = 200,
  corpse = true,
  danger = 2,
  xp = 0,
  weight = 0,
  bulk = 100,
  flags = {BF_OPENDOORS},
  attackchance = 40,
  desc = "Brown demonic servants from hell, imps can cast fireballs. They're puny and weak. They stand no chance against the ass-kicking marine...",
  sprite = 53,
  kill_desc = "burned by an imp",
  kill_desc_melee = "slashed by an imp",
  ai_type = "friend_ranged_seek_ai",
  weapon = {
    damage = "2d5",
    damagetype = DAMAGE_FIRE,
    missile = {
      sound_id = "imp",
      ascii = "*",
      sprite = 233,
      color = LIGHTRED,
      delay = 30,
      miss_base = 50,
      miss_dist = 5,
      expl_delay = 40,
      expl_color = RED},
    radius = 1},
  OnCreate = function(self)
    hellgate_remix.register_friend(self)
  end,
  OnDie = function(self)
    hellgate_remix.delete_friend(self)
  end})

-- Demon with friendly ai and 0 xp
Beings({
  name = "demon",
  id = "friend_demon",
  sound_id = "demon",
  ascii = "c",
  color = LIGHTRED,
  todam = 5,
  tohit = 3,
  hp = 25,
  speed = 130,
  min_lev = 200,
  armor = 2,
  corpse = true,
  danger = 4,
  xp = 0,
  weight = 0,
  bulk = 100,
  flags = {BF_CHARGE},
  desc = "You thought pink is cute? So does the ass-kicking marine. These things don't scare him one bit!",
  sprite = 54,
  kill_desc_melee = "bit by a demon",
  ai_type = "friend_melee_seek_ai",
  OnCreate = function(self)
    hellgate_remix.register_friend(self)
  end,
  OnDie = function(self)
    hellgate_remix.delete_friend(self)
  end})

-- Cacodemon with friendly ai and 0 xp
Beings({
  name = "cacodemon",
  id = "friend_cacodemon",
  sound_id = "cacodemon",
  ascii = "O",
  color = RED,
  todam = 6,
  tohit = 4,
  hp = 40,
  min_lev = 200,
  armor = 1,
  corpse = true,
  danger = 6,
  xp = 0,
  weight = 0,
  flags = {BF_ENVIROSAFE},
  attackchance = 40,
  bulk = 100,
  desc = "Big, flying, red, horned heads. They spit huge explosive plasma balls. Sadly, they are no match for the ass-kicking marine's rocket launcher...",
  sprite = 56,
  kill_desc = "smitten by a cacodemon",
  kill_desc_melee = "got too close to a cacodemon",
  ai_type = "friend_ranged_seek_ai",
  weapon = {
    damage = "2d6",
    damagetype = DAMAGE_PLASMA,
    radius = 1,
    missile = {
      sound_id = "cacodemon",
      ascii = "*",
      color = LIGHTMAGENTA,
      delay = 30,
      sprite = 234,
      miss_base = 50,
      miss_dist = 4,
      expl_delay = 40,
      expl_color = MAGENTA}},
  OnCreate = function(self)
    hellgate_remix.register_friend(self)
  end,
  OnDie = function(self)
    hellgate_remix.delete_friend(self)
  end})

-- Bruiser brother with friendly ai and 0 xp
Beings({
  name = "bruiser brother",
  id = "friend_bruiser",
  sound_id = "bruiser",
  ascii = "B",
  color = LIGHTRED,
  todam = 8,
  tohit = 6,
  hp = 125,
  min_lev = 200,
  armor = 3,
  corpse = true,
  danger = 14,
  xp = 0,
  weight = 0,
  attackchance = 40,
  bulk = 100,
  flags = {BF_USESITEMS, BF_OPENDOORS, BF_ENVIROSAFE, BF_HUNTING},
  desc = "Tough as a dump truck and nearly as big, these Goliaths are the worst things on two legs since an ass-kicking marine.",
  sprite = 59,
  overlay = {1, 0.4, 0.4},
  kill_desc = "baptised by a bruiser brother",
  kill_desc_melee = "pounded rather hard by a bruiser brother",
  ai_type = "friend_ranged_seek_ai",
  weapon = {
    damage = "4d5",
    radius = 2,
    damagetype = DAMAGE_ACID,
    missile = {
      sound_id = "baron",
      ascii = "*",
      color = LIGHTGREEN,
      sprite = 235,
      delay = 35,
      miss_base = 40,
      miss_dist = 3,
      expl_delay = 40,
      expl_color = GREEN}},
  OnCreate = function(self)
    hellgate_remix.register_friend(self)
  end,
  OnDie = function(self)
    hellgate_remix.delete_friend(self)
  end})
  
Beings({
  name = "ass-kicking marine",
  id = "am",
  sound_id = "soldier",
  ascii = '@',
  color = LIGHTGRAY,
  tohit = 6, -- Eagle Eye = 3
  hp = 80, -- Ironman = 3
  level = 200,
  xp = 0,
  danger = 20,
  weight = 0,
  attackchance = 100, -- not used by custom ai?
  bulk = 100,
  flags = {BF_USESITEMS, BF_OPENDOORS, BF_UNIQUENAME},
  desc = "It's an ass-kicking marine. The best that the world could set against the demonic invasion.",
  sprite = 0,
  kill_desc = "vanquished by an ass-kicking marine",
  kill_desc_melee = "brutalized by an ass-kicking marine",
  ai_type = "am_ai",
  OnCreate = function(self)
    --self.firetime = 70 -- Finesse 2
    self.bodybonus = 1 -- Badass!
    self.hp = 160 -- also badass
    --self.movetime = 70 -- Hellrunner 2
  end,
  OnDie = function(self)
    player:exit()
  end})

Items({
  name = "acid ball",
  id = "nat_player",
  color = LIGHTGRAY,
  level = 200,
  weight = 0,
  sprite = 84,
  type = ITEMTYPE_RANGED,
  ammo_id = "ammo",
  ammomax = 1,
  acc = 0,
  damage = "4d5",
  radius = 2,
  damagetype = DAMAGE_ACID,
  missile = {
    sound_id = "baron",
    ascii = "*",
    color = LIGHTGREEN,
    delay = 35,
    sprite = 235,
    miss_base = 40,
    miss_dist = 3,
    expl_delay = 40,
    expl_color = GREEN},
  reload = 0,
  fire = 10,
  flags = {IF_CURSED, IF_NOUNLOAD, IF_NOAMMO, IF_NODROP},
  altreload = RELOAD_SCRIPT,
  OnAltReload = function(self, being)
    if being:is_player() then
      being:play_sound("baron.act")
    end
  end})

Items({
  name = "Hellgate",
  id = "fake_hellgate",
  color = MULTIPORTAL,
  ascii = "0",
  weight = 0,
  sprite = 246,

  type = ITEMTYPE_TELE,
  flags = {IF_NODESTROY, IF_NUKERESIST},
  OnEnter = function(self, being)
    if not being:is_player() then
      return
    end
    ui.msg_enter("You hear a sinister voice: \"Don't think you can get away that easily!\"")
  end})
  
function hellgate_remix.run()
    Level.name = "Phobos Hellgate"
	Level.name_number = 0
    Level.fill("wall")
    Level.fill("floor", area.FULL_SHRINKED)
	  local translation = {
      ['W'] = "wall",
		  ['#'] = "wall",
		  ['$'] = "rwall",
      [','] = "floor",
      ['\''] = "blood",
      [':'] = "blood",
	  	['.'] = "rock",
      ['+'] = "door",
      ['T'] = {"floor", item = "lmed"},
		  ['^'] = {"floor", item = "lhglobe"},
		  ['['] = {"floor", item = "rarmor"},
      ['|'] = {"floor", item = "rocket"},
      ['/'] = {"floor", item = "ammo"},
      ['V'] = {"floor", being = "friend_cacodemon"},
      ['i'] = {"floor", being = "friend_imp"},
      ['c'] = {"floor", being = "friend_demon"},
      ['C'] = {"floor", being = "friend_cacodemon"},
      ['B'] = {"blood", being = "friend_bruiser"},
      ['*'] = {"floor", item = "fake_hellgate"},
      ['&'] = "wall2",
      ['X'] = "rwall",
      ['='] = "rwall"
	}
	local map = [[
WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW.................$$$$$$$$$$$$$$$$$$$$$$$$$$$
WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW..................$$$$$$,,,,,,,,,,,,,,$$$$$$
WWWWWWW&&&V&&&i&&&&&&&i&&&C&####...................$$$,,,,,,,,,,,,,,,,,,,$$$
WWWWWWW&&&&&c&&&c&&&c&&&c&&&####...................$,,,,,,,,''XX,,,,,,,,,,$$
WWWWWWW&&&&&&&&&&&&&&&&&&&&&####...................$,,,,,,,''XXXX,,,,,,,,,,$
T,/|,^#:::,,:,,:::,,,:,:,:::#,,,,,.................=,,,,,,,,'==,X,,,,XXXX,,$
,,,,:,#,,,,,,:,,,,,,,,,,,,,:#,,,,,,,...............=,,,,,,,,'XXXX,,,XX==XX,$
,,,,,:#,,,,,,,,,,,,,,,,,,,,,#,,,,,,,,,,,,,,,,....,,=,,,,,,,,''XX,,,,X====X|$
[,,,::+,,,,,,,,,,,,,,,,,,,,,+,,,,,,,,,,,,,,,,,,,,,,=,,,,,,,,,,,,,,,,===*=X|$
,,,,,:#,,,,,,,,,,,,,,,,,,,,,#,,,,,,,,,,....,,,,,,,,=,,,,,,,,''XX,,,,X====X|$
,,,,::#::,,,,:,,,,,,,,,,,:::#,,,,,,,...............=,,,,,,,,'XXXX,,,XX==XX,$
T,/|,^#::::,:,:::,,::,:,:,::#,,,,,.................=,,,,,,,,'==BX,,,,XXXX,,$
WWWWWWW&&&&&&&&&&&&&&&&&&&&&####...................$,,,,,,,''XXXX,,,,,,,,,,$
WWWWWWW&&&&&c&&&c&&&c&&&c&&&####...................$,,,,,,,,''XX,,,,,,,,,,$$
WWWWWWW&&&V&&&i&&&&&&&i&&&C&####...................$$$,,,,,,,,,,,,,,,,,,,$$$
WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW..................$$$$$$,,,,,,,,,,,,,,$$$$$$
WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW.................$$$$$$$$$$$$$$$$$$$$$$$$$$$
WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW$$$$$$$$$$$$$$$$$$$$$$$$$$$
    ]]
	  Level.place_tile(translation, map, 2, 2)
    Level.player(65, 7)
end
  
function hellgate_remix.OnEnter()
    local name = player.name
    hellgate_remix.am = Level.drop_being('am', coord.new(2, 10))
    hellgate_remix.am.name = name
    player.inv:clear()
    player.name = "Bruiser"
    player.color = LIGHTRED
    player.todam = 8
    player.tohit = 6
    player.hp = 125
    player.hpmax = 125
    player.todamall = 0
    player.tohitmelee = 0
    player.armor = 3
    player.techbonus = 0
    player.pistolbonus = 0
    player.rapidbonus = 0
    player.bodybonus = 0
    player.reloadtime = 100
    player.firetime = 100
    player.movetime = 100
	  player.eq.weapon = item.new("nat_player")
    player.proto.name = "bruiser brother"
    player.proto.desc = "You're tough as a dump truck and nearly as big, but are you powerful enough to take on Earth's last savior, " .. name .. "?"
    for c in area.FULL() do
      local cell = cells[Level[c]]
      --if cell.flag_set[CF_BLOCKMOVE] or cell.flag_set[CF_NOCHANGE] then
        Level.light[c][LFEXPLORED] = true
      --end
    end
    Level.flags[LF_ITEMSVISIBLE] = true
    Level.flags[LF_BEINGSVISIBLE] = true
    Level.result(1)
end

function hellgate_remix.OnTick()
    player.tired = true
    local res = Level.result()
    if 2 < res then
      return
    end
    if hellgate_remix.am and res == 1 and 20 < hellgate_remix.am.x then
      hellgate_remix.am:play_sound("door.close")
      Generator.transmute("wall2", "floor")
      Level.result(2)
    end
    if hellgate_remix.am and res == 2 and 50 < hellgate_remix.am.x then
      ui.msg("Suddenly the walls dissapear!")
      player:play_sound("barrel.explode")
      Generator.transmute("brwall", "floor")
      Level.result(3)
    end
  end
