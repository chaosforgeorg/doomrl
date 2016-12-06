{$INCLUDE doomrl.inc}
unit doominventory;
interface
uses SysUtils, vnode, vuielements, dfitem, dfoutput, dfthing, dfdata, doomviews, doomhooks;

type
  TItemList      = array[TItemSlot] of TItem;
  TEquipmentList = array[TEqSlot] of TItem;

TInventory = class;

TInventoryEnumerator = specialize TGNodeEnumerator< TItem >;

TInventory = class( TVObject )
       constructor Create( aOwner : TThing );
       procedure Sort( var aList : TItemList );
       function  Size : byte;
       procedure Add( aItem : TItem );
       function  Choose( aFilter : TItemTypeSet; const aAction : string) : TItem;
       function  SeekAmmo( aAmmoID : DWord ) : TItem;
       function  View : boolean;
       function  DoScrollSwap : Boolean;
       function  AddAmmo( aAmmoID : DWord; aCount : Word ) : Word;
       function  isFull : boolean;
       procedure RawSetSlot( aIndex : TEqSlot; aItem : TItem ); inline;
       function  RunEq : boolean;
       procedure EqSwap( aSlot1, aSlot2 : TEqSlot );
       procedure EqTick;
       procedure ClearSlot( aItem : TItem );
       function DoWear( aItem : TItem ) : Boolean;
       function Wear( aItem : TItem ) : Boolean;
       function Contains( aItem : TItem ) : Boolean;
       function FindSlot( aItem : TItem ) : TEqSlot;
       function GetEnumerator : TInventoryEnumerator;
       function Equipped( aItem : TItem ) : Boolean;
       destructor Destroy; override;
       procedure setSlot( aIndex : TEqSlot; aItem : TItem ); inline;
     private
       function OnInvConfirm( aSender : TUICustomMenu; aResult : TUIItemResult ) : Boolean;
       function OnEqConfirm( aSender : TUICustomMenu; aResult : TUIItemResult ) : Boolean;
     private
       FOwner  : TThing;
       FChosen : TItem;
       FSlot   : TEqSlot;
       FAction : TUIItemResult;
       FSlots  : TEquipmentList;
       function  getSlot( aIndex : TEqSlot ) : TItem; inline;
     public
       property Slot[ aIndex : TEqSlot ] : TItem read getSlot;
     end;

implementation

uses vmath, vgenerics, vmaparea, vrltools, vluasystem, doomio, dfplayer, dfbeing, dflevel;

{ TInventoryEnumerator }

function TInventory.RunEq : boolean;
var iItem   : TItem;
    iSlot   : TEqSlot;
    iCoord  : TCoord2D;
    iName   : AnsiString;
begin
  RunEq := False;
  FChosen := nil;
  FAction := ItemResultCancel;
  IO.RunUILoop( TUIEquipmentView.Create( IO.Root, @OnEqConfirm ) );
  if FAction = ItemResultCancel then Exit( False );
  iSlot := FSlot;

  if FAction = ItemResultPick then
  begin
    if (FSlots[iSlot] <> nil) and isFull then
    begin
      if not Option_InvFullDrop then
      begin
        if not UI.MsgConfirm('No room in inventory! Should it be dropped?') then Exit( False );
      end;
      FAction := ItemResultDrop;
    end;
  end;
  if (FSlots[iSlot] <> nil) and FSlots[iSlot].Flags[ IF_CURSED ] then begin UI.Msg('You can''t, it''s cursed!'); Exit(False); end;

  if (FSlots[iSlot] = nil) or (FAction = ItemResultSwap) then
  begin
    iItem := Choose(ItemEqFilters[iSlot],'wear/wield');
    if iItem = nil then Exit;
    if not iItem.CallHookCheck( Hook_OnEquipCheck,[FOwner] ) then Exit( False );
    setSlot( iSlot, iItem );
    Exit( True );
  end;

  if FAction = ItemResultDrop then
  try
    iName := FSlots[ iSlot ].GetName(false);
    iCoord := TLevel(FOwner.Parent).MapArea.Drop( FOwner.Position, [EF_NOITEMS,EF_NOBLOCK,EF_NOSTAIRS] );
    TLevel(FOwner.Parent).DropItem( FSlots[ iSlot ], iCoord );
    UI.Msg('You dropped '+iName+'.');
    setSlot( iSlot, nil );
    Exit( True );
  except
    on e : EPlacementException do
    begin
      UI.Msg('No room on the floor to drop the equipped item!');
      Exit;
    end;
  end;
  setSlot( iSlot, nil );
  Exit( True );
end;

function TInventory.Wear( aItem : TItem ) : Boolean;
begin
  if aItem = nil then Exit( False );
  if not Contains( aItem ) then Exit( False );
  if not aItem.isWearable then Exit( False );
  setSlot( aItem.eqSlot, aItem );
  Exit( True )
end;

function TInventory.getSlot(aIndex: TEqSlot): TItem; inline;
begin
  Exit(FSlots[aIndex]);
end;

procedure TInventory.setSlot( aIndex: TEqSlot; aItem: TItem); inline;
begin
  if FSlots[aIndex] = aItem then Exit;
  if FSlots[aIndex] <> nil  then FSlots[aIndex].CallHook( Hook_OnRemove, [FOwner] );
  FSlots[aIndex] := nil;
  if aItem <> nil then aItem.CallHook( Hook_OnEquip, [FOwner] );
  if aItem <> nil then FOwner.Add( aItem );
  FSlots[aIndex] := aItem;
end;

function TInventory.OnInvConfirm ( aSender : TUICustomMenu; aResult : TUIItemResult ) : Boolean;
begin
  if (aSender.SelectedItem <> nil) and ( aSender.SelectedItem.Data <> nil ) then
  begin
    if aResult = ItemResultDrop
      then TBeing(FOwner).ActionDrop( TItem( aSender.SelectedItem.Data ) )
      else FChosen := TItem( aSender.SelectedItem.Data );
  end;
  Exit( True );
end;

function TInventory.OnEqConfirm ( aSender : TUICustomMenu; aResult : TUIItemResult ) : Boolean;
begin
  if (aSender.SelectedItem <> nil) and (aSender.Selected > 0) then
  begin
    FSlot   := TEqSlot(aSender.Selected-1);
    FChosen := TItem( aSender.SelectedItem.Data );
    FAction := aResult;
  end;
  Exit( True );
end;

procedure TInventory.RawSetSlot( aIndex: TEqSlot; aItem: TItem ); inline;
begin
  if aItem <> nil then FOwner.Add( aItem );
  FSlots[aIndex] := aItem;
end;

constructor TInventory.Create( aOwner : TThing );
var iSlot : TEqSlot;
begin
  FChosen := nil;
  FOwner  := aOwner;
  for iSlot in TEqSlot do
    FSlots[iSlot] := nil;
end;

function TInventory.Size : byte;
var iSlot : TEqSlot;
begin
  Size := FOwner.ChildCount;
  for iSlot in TEqSlot do
    if FSlots[iSlot] <> nil then
      Dec(Size);
end;

procedure TInventory.Add( aItem : TItem );
begin
  if aItem = nil then Exit;
  if isFull then raise EItemException.Create('Inventory full at add!');
  FOwner.Add( aItem );
end;

destructor TInventory.Destroy;
begin
end;

procedure   TInventory.Sort( var aList : TItemList );
var iCount  : Integer;
    iCount2 : Integer;
begin
  for iCount := Low(TItemSlot) to High(TItemSlot)-Low(TItemSlot) do
    for iCount2 := Low(TItemSlot) to High(TItemSlot)-iCount do
      if TItem.Compare(aList[iCount2],aList[iCount2+1]) then
        SwapItem(aList[iCount2],aList[iCount2+1]);
end;

function TInventory.Choose ( aFilter : TItemTypeSet; const aAction : string ) : TItem;
var iList  : TItemList;
    iItem  : TItem;
    iCount : Integer;
begin
  for iCount in TItemSlot do
    iList[ iCount ] := nil;

  if aFilter = [] then aFilter := ItemsAll;
  iCount := 0;
  for iItem in Self do
  if (not Equipped( iItem )) and (iItem.IType in aFilter) then
  begin
    Inc( iCount );
    iList[ iCount ] := iItem;
  end;

  Sort( iList );

  FChosen := nil;
  IO.RunUILoop( TUIInventoryView.Create( IO.Root, @OnInvConfirm, iList, aAction ) );
  Result := FChosen;
  FChosen := nil;
end;

function TInventory.SeekAmmo( aAmmoID : DWord ) : TItem;
var iAmmo      : TItem;
    iAmmoCount : Integer;
begin
  SeekAmmo   := nil;
  iAmmoCount := 65000;

  for iAmmo in Self do
     if iAmmo.isAmmo then
       if iAmmo.NID = aAmmoID then
       if iAmmo.Ammo < iAmmoCount then
       begin
         SeekAmmo   := iAmmo;
         iAmmoCount := iAmmo.Ammo;
       end;
end;


function TInventory.View : boolean;
var iItem : TItem;
begin
  View := False;
  iItem := Choose([],'');
  if iItem = nil then Exit;
  if iItem.isWearable then Exit(DoWear(iItem));
  if iItem.isPack then (FOwner as TBeing).ActionUse(iItem);
end;

type TItemArray = specialize TGObjectArray< TItem >;

function TInventory.DoScrollSwap : Boolean;
var iArray   : TItemArray;
    iItem    : TItem;
    iIdx     : Integer;
    iCommand : Byte;
begin
  iArray := TItemArray.Create( False );
  if Slot[ efWeapon ]  <> nil then iArray.Push( Slot[ efWeapon ] );
  if (Slot[ efWeapon2 ] <> nil) and Slot[ efWeapon2 ].isWeapon then iArray.Push( Slot[ efWeapon2 ] );
  for iItem in Self do
    if not Equipped( iItem ) then
      if iItem.isWeapon then
        iArray.Push( iItem );
  DoScrollSwap := False;
  if iArray.Size = 0 then UI.Msg('You have no weapons!');
  if iArray.Size = 1 then UI.Msg('You have no other weapons!');
  if iArray.Size > 1 then
  begin
    UI.Msg('Use @<scroll@> to choose weapon, @<left@> button to wield, @<right@> to cancel...');
    iIdx := 1;
    if Slot[ efWeapon ] = nil then iIdx := 0;
    repeat
      UI.SetHint( iArray[iIdx].Description );
      iCommand := IO.WaitForCommand( [COMMAND_MSCRUP,COMMAND_MSCRDOWN,COMMAND_MLEFT,COMMAND_MRIGHT,COMMAND_ESCAPE,COMMAND_ENTER] );
      if iCommand = COMMAND_MSCRUP   then if iIdx = 0 then iIdx := iArray.Size-1 else iIdx -= 1;
      if iCommand = COMMAND_MSCRDOWN then iIdx := (iIdx + 1) mod iArray.Size;
    until iCommand in [0,COMMAND_ESCAPE,COMMAND_ENTER,COMMAND_MLEFT,COMMAND_MRIGHT];
    if iCommand in [COMMAND_ENTER,COMMAND_MLEFT] then
    begin
      if iArray[ iIdx ] = Slot[ efWeapon2 ] then
      begin
        TBeing(FOwner).ActionQuickSwap;
        DoScrollSwap := False;
      end
      else
      if iArray[ iIdx ] <> Slot[ efWeapon ] then
        DoScrollSwap := DoWear( iArray[ iIdx ] ) and (not FOwner.Flags[BF_QUICKSWAP]);
    end;
  end;
  UI.SetHint('');
  FreeAndNil( iArray );
end;

function TInventory.AddAmmo( aAmmoID : DWord; aCount : Word ) : Word;
var iAmount   : Word;
    iAmmoItem : TItem;
    iAmmoMax  : Word;
begin
  iAmmoMax  := LuaSystem.Get(['items',aAmmoID,'ammomax']);
  iAmmoItem := SeekAmmo(aAmmoID);

  if FOwner.Flags[ BF_BACKPACK ] then iAmmoMax := Round(iAmmoMax * 1.4);

  if iAmmoItem <> nil then
  begin
    iAmount := Min(aCount,iAmmoMax-iAmmoItem.Ammo);
    aCount -= iAmount;
    iAmmoItem.Ammo := iAmmoItem.Ammo + iAmount;
  end;
  if aCount = 0 then Exit(0);

  repeat
    if isFull then Exit(aCount);

    iAmount := Min(aCount,iAmmoMax);
    iAmmoItem := TItem.Create(aAmmoID);
    iAmmoItem.Ammo := iAmount;
    Add(iAmmoItem);
    aCount -= iAmount;
  until aCount = 0;
  Exit(0);
end;

function TInventory.isFull: boolean;
var iSize : Integer;
begin
  iSize := Size;
  if FOwner = Player then Exit( iSize >= Player.InventorySize );
  Exit(iSize >= High(TItemSlot));
end;


procedure TInventory.EqSwap(aSlot1, aSlot2: TEqSlot);
var iItem : TItem;
begin
  iItem          := FSlots[aSlot1];
  FSlots[aSlot1] := FSlots[aSlot2];
  FSlots[aSlot2] := iItem;
end;

procedure TInventory.EqTick;
var iSlot : TEqSlot;
begin
  for iSlot in TEqSlot do
    if FSlots[iSlot] <> nil then
      FSlots[iSlot].Tick(FOwner);
end;

procedure TInventory.ClearSlot ( aItem : TItem ) ;
var iSlot : TEqSlot;
begin
  for iSlot in TEqSlot do
    if FSlots[iSlot] = aItem then
      setSlot( iSlot, nil );
end;

function TInventory.DoWear ( aItem : TItem ) : Boolean;
var iItem : TItem;
begin
  if aItem = nil then Exit( False );
  if aItem.Hooks[ Hook_OnEquipCheck ] then
    if not aItem.CallHookCheck( Hook_OnEquipCheck,[FOwner] ) then Exit( False );
  iItem := FSlots[aItem.eqSlot];
  if (iItem <> nil) and iItem.Flags[ IF_CURSED ] then begin UI.Msg('You can''t, your '+iItem.Name+' is cursed!'); Exit( False ); end;
  UI.Msg('You wear/wield : '+aItem.GetName(false));
  Wear( aItem );
  Exit( True );
end;

function TInventory.Contains( aItem : TItem ) : Boolean;
begin
  Exit( aItem.Parent = FOwner );
end;

function TInventory.FindSlot ( aItem : TItem ) : TEqSlot;
var iSlot : TEqSlot;
begin
  for iSlot in TEqSlot do
    if FSlots[iSlot] = aItem then Exit( iSlot );
  Exit( TEqSlot(0) );
end;

function TInventory.GetEnumerator : TInventoryEnumerator;
begin
  GetEnumerator.Create(FOwner);
end;

function TInventory.Equipped ( aItem : TItem ) : Boolean;
var iSlot : TEqSlot;
begin
  for iSlot in TEqSlot do
    if FSlots[ iSlot ] = aItem then
      Exit( True );
  Exit( False );
end;

end.

