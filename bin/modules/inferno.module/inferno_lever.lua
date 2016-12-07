function inferno.load_levers()
  Items({
    id = "lever_ammo",
    name = "lever",
    color = WHITE,
    sprite = SPRITE_LEVER,
    weight = 0,
    color_id = "lever",

    type = ITEMTYPE_LEVER,
    good = "beneficial",
    desc = "Ammo depot",

    OnCreate = function(self )
      self:add_property("charges", math.random(3))
      self:add_property("choice", false)
    end,

    OnUseCheck = function(self,being)
      if self.charges == 0 then
        ui.msg("Ammo supplies depleted.")
        return false
      end
      self.choice = ui.msg_choice("Ammo depot. @<1@>0mm ammo, @<s@>hotgun shells, @<r@>ockets, or @<c@>ells? (Escape to cancel)", "1src\001" )
      if self.choice == "\001" then
        return false
      end
      return true
    end,

    OnUse = function(self,being)
      local atype = {
        ["1"] = "ammo",
        ["s"] = "shell",
        ["r"] = "rocket",
        ["c"] = "cell",
      }
      atype = atype[self.choice]
      if atype then
        self.charges = self.charges - 1
        Level.drop_item(atype, self:get_position())
        ui.msg("Ammo deployed!")
      end
      return true
    end,
  })
  Items({
    id = "lever_mod",
    name = "lever",
    color = WHITE,
    sprite = SPRITE_LEVER,
    weight = 0,
    color_id = "lever",

    type = ITEMTYPE_LEVER,
    good = "beneficial",
    desc = "Mod depot",

    OnCreate = function(self )
      self:add_property("charges", 1)
      self:add_property("choice", false)
    end,

    OnUseCheck = function(self,being)
      if self.charges == 0 then
        ui.msg("Mod supplies depleted.")
        return false
      end
      self.choice = ui.msg_choice("Mod depot: @<a@>gility, @<b@>ulk, @<p@>ower, or @<t@>echnical? (Escape to cancel)", "abpt\001" )
      if self.choice == "\001" then
        return false
      end
      return true
    end,

    OnUse = function(self,being)
      local mtype = {
        ["a"] = "mod_agility",
        ["b"] = "mod_bulk",
        ["p"] = "mod_power",
        ["t"] = "mod_tech",
      }
      mtype = mtype[self.choice]
      if mtype then
        self.charges = self.charges - 1
        Level.drop_item(mtype, self:get_position())
        ui.msg("Mod deployed!")
      end
      return true
    end,
  })
  Items({
    id = "lever_phase",
    name = "lever",
    color = WHITE,
    sprite = SPRITE_LEVER,
    weight = 0,
    color_id = "lever",

    type = ITEMTYPE_LEVER,
    good = "dangerous",
    desc = "phase",
    warning = "You feel jumpy.",
    fullchance = 15,

    OnCreate = function(self )
      self:add_property("target_area", area.FULL_SHRINKED:clone())
    end,

    OnUse = function(self,being)
      for c in self.target_area:coords() do
        local target = Level.get_being(c)
        if target then
          items.phase.OnUse(self, target)
        end
      end
      self:destroy()
      return true
    end,
  })
end