--The Player

--This is the exposed interface
Elevator.Player = {}
Elevator.Player.DropEquipment = nil
Elevator.Player.OnDieCheck = nil
Elevator.Player.Init = nil

local _cloneItem = function(old_item)

  local new_item = item.new(old_item.id)

  new_item.Armor          = old_item.Armor
  new_item.RechargeDelay  = old_item.RechargeDelay
  new_item.RechargeAmount = old_item.RechargeAmount
  new_item.IType          = old_item.IType
  new_item.Durability     = old_item.Durability
  new_item.MaxDurability  = old_item.MaxDurability
  new_item.MoveMod        = old_item.MoveMod
  new_item.DodgeMod       = old_item.DodgeMod
  new_item.KnockMod       = old_item.KnockMod
  new_item.AmmoID         = old_item.AmmoID
  new_item.Ammo           = old_item.Ammo
  new_item.AmmoMax        = old_item.AmmoMax
  new_item.Acc            = old_item.Acc
  new_item.Damage_Dice    = old_item.Damage_Dice
  new_item.Damage_Sides   = old_item.Damage_Sides
  new_item.Damage_Add     = old_item.Damage_Add
  new_item.Missile        = old_item.Missile
  new_item.BlastRadius    = old_item.BlastRadius
  new_item.Shots          = old_item.Shots
  new_item.ShotCost       = old_item.ShotCost
  new_item.ReloadTime     = old_item.ReloadTime
  new_item.UseTime        = old_item.UseTime
  new_item.DamageType     = old_item.DamageType
  new_item.AltFire        = old_item.AltFire
  new_item.AltReload      = old_item.AltReload
  new_item.Desc           = old_item.Desc

  new_item.picture       = old_item.picture
  new_item.color         = old_item.color
  new_item.name          = old_item.name
  new_item.x             = old_item.x
  new_item.y             = old_item.y

  new_item.resist.bullet    = old_item.resist.bullet
  new_item.resist.melee     = old_item.resist.melee
  new_item.resist.shrapnel  = old_item.resist.shrapnel
  new_item.resist.acid      = old_item.resist.acid
  new_item.resist.fire      = old_item.resist.fire
  new_item.resist.plasma    = old_item.resist.plasma

  for f, v in pairs(old_item.flags) do
    new_item[f] = v
  end

  return(new_item)
end
Elevator.Player.DropEquipment = function()

  --We don't actually 'drop' everything; there's no way to
  --do that without spamming messages and dealing with scounts.
  --What we do is recreate and drop every item and then
  --clear the inventory.
  local target = nil
  for item in player.inv:items() do
    target = generator.drop_coord( player.position, {EF_NOITEMS, EF_NOHARM} )
    item = level:drop_item( _cloneItem(item), target )
  end
  for item in player.eq:items() do
    target = generator.drop_coord( player.position, {EF_NOITEMS, EF_NOHARM} )
    level:drop_item( _cloneItem(item), target )
  end

  player.inv:clear()
  player.eq:clear()
end
Elevator.Player.OnDieCheck = function(player)
  player.deaths = player.deaths + 1
  return Elevator.WaveEngine.OnPlayerDieCheck(player)
end

--init code.
Elevator.Player.Init = function ()

    --Adjust as reports come in
        if DIFFICULTY == DIFF_EASY      then player.expfactor = 0.4
    elseif DIFFICULTY == DIFF_MEDIUM    then player.expfactor = 0.35
    elseif DIFFICULTY == DIFF_HARD      then player.expfactor = 0.3
    elseif DIFFICULTY == DIFF_VERYHARD  then player.expfactor = 0.25
    elseif DIFFICULTY == DIFF_NIGHTMARE then player.expfactor = 0.2
    end
end
