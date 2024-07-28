{$INCLUDE doomrl.inc}
unit doomplayerview;
interface
uses viotypes, vgenerics,
     dfitem, dfdata,
     doomio, doomtrait, doomconfirmview;

type TPlayerViewState = (
  PLAYERVIEW_INVENTORY,
  PLAYERVIEW_EQUIPMENT,
  PLAYERVIEW_CHARACTER,
  PLAYERVIEW_TRAITS,
  PLAYERVIEW_CLOSING,
  PLAYERVIEW_DONE
);

type TItemViewEntry = record
  Name  : Ansistring;
  Desc  : Ansistring;
  Stats : Ansistring;
  Item  : TItem;
  Color : Byte;
  QSlot : Byte;
end;

type TItemViewArray = specialize TGArray< TItemViewEntry >;

type TTraitViewEntry = record
  Entry     : Ansistring;
  Name      : Ansistring;
  Quote     : Ansistring;
  Desc      : Ansistring;
  Requires  : Ansistring;
  Blocks    : Ansistring;
  Available : Boolean;
  Value     : Byte;
  Index     : Byte;
end;

type TTraitViewArray = specialize TGArray< TTraitViewEntry >;
     TOnPickTrait    = function ( aTrait : Byte ) : Boolean of object;

type TPlayerView = class( TInterfaceLayer )
  constructor Create( aInitialState : TPlayerViewState = PLAYERVIEW_INVENTORY );
  constructor CreateTrait( aFirstTrait : Boolean; aKlass : Byte = 0; aCallback : TOnPickTrait = nil );
  constructor CreateCommand( aCommand : Byte; aScavenger : Boolean = False );
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
  destructor Destroy; override;
protected
  procedure Initialize;
  procedure UpdateInventory;
  procedure UpdateEquipment;
  procedure UpdateCharacter;
  procedure UpdateTraits;
  procedure PushItem( aItem : TItem; aArray : TItemViewArray );
  procedure ReadInv;
  procedure ReadEq;
  procedure ReadTraits( aKlass : Byte );
  procedure ReadCharacter;
  procedure ReadQuickslots;
  procedure InitSwapMode( aSlot : TEqSlot );
  procedure Sort( aList : TItemViewArray );
protected
  procedure Filter( aSet : TItemTypeSet );
protected
  FState       : TPlayerViewState;
  FSize        : TIOPoint;
  FInv         : TItemViewArray;
  FEq          : TItemViewArray;
  FCharacter   : TStringGArray;
  FAction      : AnsiString;
  FITitle      : AnsiString;
  FCTitle      : AnsiString;
  FSwapMode    : Boolean;
  FTraitMode   : Boolean;
  FTraitFirst  : Boolean;
  FScavenger   : Boolean;
  FSSlot       : TEqSlot;
  FTraits      : TTraitViewArray;
  FOnPick      : TOnPickTrait;
  FCommandMode : Byte;
  FRect        : TIORect;
end;

type TUnloadConfirmView = class( TConfirmView )
  constructor Create( aItem : TItem; aID : Ansistring = '' );
protected
  procedure OnConfirm; override;
protected
  FItem : TItem;
  FID   : Ansistring;
end;

implementation

uses sysutils, variants,
     vutil, vtig, vtigio, vluasystem,
     dfplayer,
     doomcommand, doombase, doominventory;

constructor TPlayerView.Create( aInitialState : TPlayerViewState = PLAYERVIEW_INVENTORY );
begin
  Initialize;
  FState := aInitialState;
end;

constructor TPlayerView.CreateTrait( aFirstTrait : Boolean; aKlass : Byte = 0; aCallback : TOnPickTrait = nil );
begin
  Initialize;
  FState     := PLAYERVIEW_TRAITS;
  FTraitMode := True;
  FTraitFirst:= aFirstTrait;
  FOnPick    := aCallback;

  if FTraitFirst
    then ReadTraits( aKlass )
    else ReadTraits( Player.Klass )
end;

constructor TPlayerView.CreateCommand( aCommand : Byte; aScavenger : Boolean = False );
begin
  Initialize;
  FCommandMode := aCommand;
  FScavenger   := aScavenger;
  FState       := PLAYERVIEW_INVENTORY;
  ReadInv;
  case aCommand of
    COMMAND_USE    : begin FAction := 'use';  FITitle := 'Choose item to use';  Filter( [ITEMTYPE_PACK] ); end;
    COMMAND_DROP   : begin FAction := 'drop'; FITitle := 'Choose item to drop'; end;
    COMMAND_UNLOAD : if aScavenger
                       then begin FAction := 'unload/scavenge';  FITitle := 'Choose item to unload/scavenge';  Filter( [ITEMTYPE_RANGED, ITEMTYPE_AMMOPACK, ITEMTYPE_MELEE, ITEMTYPE_ARMOR, ITEMTYPE_BOOTS] ); end
                       else begin FAction := 'unload';           FITitle := 'Choose item to unload';  Filter( [ITEMTYPE_RANGED, ITEMTYPE_AMMOPACK] ); end;
  end;
end;

procedure TPlayerView.Initialize;
begin
  VTIG_EventClear;
  VTIG_ResetSelect( 'inventory' );
  VTIG_ResetSelect( 'equipment' );
  VTIG_ResetSelect( 'traits' );
  VTIG_ResetSelect( 'unload_confirm' );
  FState       := PLAYERVIEW_INVENTORY;
  FSize        := Point( 80, 25 );
  FInv         := nil;
  FEq          := nil;
  FTraits      := nil;
  FSwapMode    := False;
  FTraitMode   := False;
  FTraitFirst  := False;
  FCommandMode := 0;
  FAction      := 'wear/use';
  FITitle      := 'Inventory';
end;

procedure TPlayerView.Update( aDTime : Integer );
begin
  if IsFinished or (FState = PLAYERVIEW_CLOSING) then Exit;

  if ( Doom.State <> DSPlaying ) and ( not FTraitFirst ) then
  begin
    FState := PLAYERVIEW_DONE;
    Exit;
  end;

  case FState of
    PLAYERVIEW_INVENTORY : UpdateInventory;
    PLAYERVIEW_EQUIPMENT : UpdateEquipment;
    PLAYERVIEW_CHARACTER : UpdateCharacter;
    PLAYERVIEW_TRAITS    : UpdateTraits;
  end;

  if IsFinished or (FState = PLAYERVIEW_CLOSING) then Exit;

  if ( not FSwapMode ) and ( not FTraitMode ) and ( FCommandMode = 0 ) then
  begin
    if VTIG_Event( VTIG_IE_LEFT ) then
    begin
      if FState = Low( TPlayerViewState ) then FState := PLAYERVIEW_TRAITS       else FState := Pred( FState );
    end;
    if VTIG_Event( VTIG_IE_RIGHT ) then
    begin
      if FState = PLAYERVIEW_TRAITS       then FState := Low( TPlayerViewState ) else FState := Succ( FState );
    end;
    if ( FState <> PLAYERVIEW_DONE ) and VTIG_Event( [ TIG_EV_INVENTORY, TIG_EV_EQUIPMENT, TIG_EV_CHARACTER, TIG_EV_TRAITS ] ) then
    begin
      FState := PLAYERVIEW_DONE;
    end;
  end;

  if ( FState <> PLAYERVIEW_DONE ) and VTIG_EventCancel then
  begin
    if ( not FTraitMode )
      then FState := PLAYERVIEW_DONE
      else if FTraitFirst then
        begin
          FState := PLAYERVIEW_DONE;
          FOnPick(255);
        end;
  end;

  IO.RenderUIBackground( FRect.TopLeft, FRect.BottomRight - PointUnit );
end;

function TPlayerView.IsFinished : Boolean;
begin
  Exit( FState = PLAYERVIEW_DONE );
end;

function TPlayerView.IsModal : Boolean;
begin
  Exit( FState <> PLAYERVIEW_CLOSING );
end;

destructor TPlayerView.Destroy;
begin
  FreeAndNil( FEq );
  FreeAndNil( FInv );
  FreeAndNil( FTraits );
  FreeAndNil( FCharacter );
  inherited Destroy;
end;

procedure TPlayerView.UpdateInventory;
var iEntry    : TItemViewEntry;
    iSelected : Integer;
    iCommand  : Byte;
  function MarkQSlot( aIndex, aValue : Byte ) : Boolean;
  var iItem : TItem;
      i     : Integer;
  begin
    if ( aIndex < FInv.Size ) and Assigned( FInv[ aIndex ].Item ) then
    begin
      iItem := FInv[ aIndex ].Item;
      if iItem.isWearable then
      begin
        if Player.FQuickSlots[ aValue ].UID = iItem.UID
          then Player.FQuickSlots[ aValue ].UID := 0
          else Player.FQuickSlots[ aValue ].UID := iItem.UID;
        Player.FQuickSlots[ aValue ].ID := '';
        for i := 1 to 9 do
          if ( i <> aValue ) and ( Player.FQuickSlots[ i ].UID = iItem.UID ) then
            Player.FQuickSlots[ i ].UID := 0;
        ReadQuickslots;
        Exit( True );
      end;
      if iItem.isPack then
      begin
        if Player.FQuickSlots[ aValue ].ID = iItem.ID
          then Player.FQuickSlots[ aValue ].ID := ''
          else Player.FQuickSlots[ aValue ].ID := iItem.ID;
        Player.FQuickSlots[ aValue ].UID := 0;
        for i := 1 to 9 do
          if ( i <> aValue ) and ( Player.FQuickSlots[ i ].ID = iItem.ID ) then
            Player.FQuickSlots[ i ].ID := '';
        ReadQuickslots;
        Exit( True );
      end;
    end;
    Exit( False );
  end;
begin
  if FInv = nil then ReadInv;
  VTIG_BeginWindow( FITitle, 'inventory', FSize );
    FRect := VTIG_GetWindowRect;
    VTIG_BeginGroup( 50 );
    for iEntry in FInv do
      if iEntry.QSlot <> 0
        then VTIG_Selectable( '[{!{0}}] {1}',[Chr(Ord('0') + iEntry.QSlot), iEntry.Name], True, iEntry.Color )
        else VTIG_Selectable( iEntry.Name, True, iEntry.Color );
    iSelected := VTIG_Selected;
    if FInv.Size = 0 then
    begin
      iSelected := -1;
      if FSwapMode
        then VTIG_Text( 'No matching items, press <{!Enter}>.' )
        else VTIG_Text( '{!No items in inventory!}' );
    end;

    VTIG_EndGroup;

    VTIG_BeginGroup;
    if iSelected >= 0 then
    begin
      VTIG_Text( FInv[iSelected].Desc );
      VTIG_FreeLabel( FInv[iSelected].Stats, Point( 0, 7 ) );

      VTIG_Ruler( 19 );
      VTIG_Text( '<{!Enter}> {0}',[FAction] );
      if (not FSwapMode) and ( FCommandMode in [0, COMMAND_USE] ) then
      begin
        VTIG_Text( '<{!Backspace}> drop' );
        VTIG_Text( '<{!1-9}> mark quickslot' );
      end;
    end;

    VTIG_EndGroup;
  if FSwapMode or ( FCommandMode <> 0 )
    then VTIG_End('{l<{!Up,Down}> select, <{!Escape}> exit}')
    else VTIG_End('{l<{!Left,Right}> panels, <{!Up,Down}> select, <{!Escape}> exit}');

  if (iSelected >= 0) then
  begin
    if FSwapMode then
    begin
      if VTIG_EventConfirm then
      begin
        FState := PLAYERVIEW_CLOSING;
        Doom.HandleCommand( TCommand.Create( COMMAND_SWAP, FInv[iSelected].Item, FSSlot ) );
        FState := PLAYERVIEW_DONE;
      end;
    end
    else
    begin
      if ( FCommandMode in [0, COMMAND_USE] ) then
      begin
        if VTIG_Event( VTIG_IE_BACKSPACE ) then
        begin
          FState := PLAYERVIEW_CLOSING;
          Doom.HandleCommand( TCommand.Create( COMMAND_DROP, FInv[iSelected].Item ) );
          FState := PLAYERVIEW_DONE;
        end
        else
        if VTIG_EventConfirm then
        begin
          iCommand := COMMAND_NONE;
          if FInv[iSelected].Item.isWearable then iCommand := COMMAND_WEAR;
          if FInv[iSelected].Item.isPack     then iCommand := COMMAND_USE;
          FState := PLAYERVIEW_CLOSING;
          if iCommand <> COMMAND_NONE then
            Doom.HandleCommand( TCommand.Create( iCommand, FInv[iSelected].Item ) );
          FState := PLAYERVIEW_DONE;
        end;
        if VTIG_Event( VTIG_IE_1 ) then MarkQSlot( iSelected, 1 );
        if VTIG_Event( VTIG_IE_2 ) then MarkQSlot( iSelected, 2 );
        if VTIG_Event( VTIG_IE_3 ) then MarkQSlot( iSelected, 3 );
        if VTIG_Event( VTIG_IE_4 ) then MarkQSlot( iSelected, 4 );
        if VTIG_Event( VTIG_IE_5 ) then MarkQSlot( iSelected, 5 );
        if VTIG_Event( VTIG_IE_6 ) then MarkQSlot( iSelected, 6 );
        if VTIG_Event( VTIG_IE_7 ) then MarkQSlot( iSelected, 7 );
        if VTIG_Event( VTIG_IE_8 ) then MarkQSlot( iSelected, 8 );
        if VTIG_Event( VTIG_IE_9 ) then MarkQSlot( iSelected, 9 );
      end
      else
      begin
        if VTIG_EventConfirm then
        begin
          iCommand := FCommandMode;
          FState := PLAYERVIEW_CLOSING;
               if iCommand = COMMAND_UNLOAD then
            Doom.HandleUnloadCommand( FInv[iSelected].Item )
          else if iCommand <> COMMAND_NONE then
            Doom.HandleCommand( TCommand.Create( iCommand, FInv[iSelected].Item ) );
          FState := PLAYERVIEW_DONE;
        end;
      end;
    end;
  end
  else
  begin
    if VTIG_EventConfirm then
      FState := PLAYERVIEW_DONE;
  end;

end;

procedure TPlayerView.UpdateEquipment;
const ResNames : array[TResistance] of AnsiString = ('Bullet','Melee','Shrap','Acid','Fire','Plasma');
      ResIDs   : array[TResistance] of AnsiString = ('bullet','melee','shrapnel','acid','fire','plasma');
var iEntry       : TItemViewEntry;
    iSelected,iY : Integer;
    iB, iA       : Integer;
    iCount       : Integer;
    iRes         : TResistance;
    iName        : Ansistring;
  function Cursed : Boolean;
  begin
    if ( FEq[iSelected].Item <> nil ) and FEq[iSelected].Item.Flags[ IF_CURSED ] then
    begin
      FState := PLAYERVIEW_CLOSING;
      IO.Msg('You can''t, it''s cursed!');
      FState := PLAYERVIEW_DONE;
      Exit( True );
    end;
    Exit( False );
  end;

begin
  if FEq = nil then ReadEq;
  VTIG_BeginWindow('Equipment', 'equipment', FSize );
    FRect := VTIG_GetWindowRect;
    VTIG_BeginGroup( 9, True );

      VTIG_BeginGroup( 50 );
        for iEntry in FEq do
          VTIG_Selectable( iEntry.Name, iEntry.Item <> nil, iEntry.Color );
      iSelected := VTIG_Selected;
      VTIG_Text( '' );
      if ( iSelected >= 0 ) and Assigned( FEq[iSelected].Item ) then
        VTIG_Text( FEq[iSelected].Desc );
      VTIG_EndGroup;

      VTIG_BeginGroup;
      if ( iSelected >= 0 ) and Assigned( FEq[iSelected].Item ) then
        VTIG_FreeLabel( FEq[iSelected].Stats, Point(0,0) );
      VTIG_EndGroup;

    VTIG_EndGroup( True );

    iY := 9;
    iB := 0;
    iA := 0;
    VTIG_FreeLabel( 'Basic traits',    Point(0, iY) );
    VTIG_FreeLabel( 'Advanced traits', Point(20,iY) );
    VTIG_FreeLabel( 'Resistances',     Point(42,iY) );

    for iCount := 1 to MAXTRAITS do
      if Player.FTraits.Values[iCount] > 0 then
      begin
        iName := LuaSystem.Get(['traits',iCount,'name']);
        if iCount < 10 then
        begin
          Inc( iB );
          VTIG_FreeLabel( '{d'+Padded(iName,16) + '({!' + IntToStr(Player.FTraits.Values[iCount])+ '})}', Point(0, iY+iB) );
        end
        else
        begin
          Inc( iA );
          VTIG_FreeLabel( '{d'+Padded(iName,16) + '({!' + IntToStr(Player.FTraits.Values[iCount])+ '})}', Point(20, iY+iA) );
        end;
      end;

    for iRes := Low(TResistance) to High(TResistance) do
    begin
      Inc( iY );
      VTIG_FreeLabel( '{d'+Padded(ResNames[iRes],7)+'{!'+Padded(BonusStr(Player.getTotalResistance(ResIDs[iRes],TARGET_INTERNAL))+'%',5)+
           '} Torso {!'+Padded(BonusStr(Player.getTotalResistance(ResIDs[iRes],TARGET_TORSO))+'%',5)+
           '} Feet {!'+Padded(BonusStr(Player.getTotalResistance(ResIDs[iRes],TARGET_FEET))+'%',5)+'}', Point( 42, iY ) );
    end;

     VTIG_FreeLabel( '<{!Enter}> take off/wear', Point(53, 18) );
     VTIG_FreeLabel( '<{!Tab}> swap item',       Point(53, 19) );
     VTIG_FreeLabel( '<{!Backspace}> drop item', Point(53, 20) );
  VTIG_End('{l<{!Left,Right}> panels, <{!Up,Down}> select, <{!Escape}> exit}');

  if (iSelected >= 0) then
  begin
    if VTIG_EventConfirm then
    begin
      if Assigned( FEq[iSelected].Item ) then
      begin
        if ( Player.Inv.isFull ) then
        begin
          FState := PLAYERVIEW_CLOSING;
          if not Option_InvFullDrop then
          begin
            if not IO.MsgConfirm('No room in inventory! Should it be dropped?') then
            begin
              FState := PLAYERVIEW_DONE;
              Exit;
            end;
          end;
          if Cursed then Exit;
          FState := PLAYERVIEW_CLOSING;
          Doom.HandleCommand( TCommand.Create( COMMAND_DROP, FEq[iSelected].Item ) );
          FState := PLAYERVIEW_DONE;
        end
        else
        begin
          if Cursed then Exit;
          FState := PLAYERVIEW_CLOSING;
          Doom.HandleCommand( TCommand.Create( COMMAND_TAKEOFF, nil, TEqSlot(iSelected) ) );
          FState := PLAYERVIEW_DONE;
        end;
      end
      else
      begin
        InitSwapMode( TEqSlot(iSelected) );
        Exit;
      end;
    end
    else
    if VTIG_Event( VTIG_IE_TAB ) then
    begin
      if Cursed then Exit;
      InitSwapMode( TEqSlot(iSelected) );
      Exit;
    end
    else
    if VTIG_Event( VTIG_IE_BACKSPACE ) then
    begin
      if Assigned( FEq[iSelected].Item ) then
        begin
          if Cursed then Exit;
          FState := PLAYERVIEW_CLOSING;
          Doom.HandleCommand( TCommand.Create( COMMAND_DROP, FEq[iSelected].Item ) );
          FState := PLAYERVIEW_DONE;
        end;
    end;
  end;
end;

procedure TPlayerView.UpdateCharacter;
var iString : Ansistring;
    iCount  : Integer;
begin
  if FCharacter = nil then ReadCharacter;
  VTIG_BeginWindow(FCTitle, 'character', FSize );
  FRect := VTIG_GetWindowRect;
  iCount := 0;
  for iString in IO.NewAscii[Player.ASCIIMoreCode] do
  begin
    VTIG_FreeLabel( iString, Point( 47, iCount ) );
    Inc( iCount );
  end;
  for iString in FCharacter do
    VTIG_Text( iString );
  VTIG_End('{l<{!Left,Right}> panels, <{!Escape}> exit}');
end;

procedure TPlayerView.UpdateTraits;
var iSelected : Integer;
    iEntry    : TTraitViewEntry;
begin
  if FTraits = nil then ReadTraits( Player.Klass );
  if FTraitMode
    then VTIG_BeginWindow('Select trait to upgrade', 'traits', FSize )
    else VTIG_BeginWindow('Traits', 'traits', FSize );
  FRect := VTIG_GetWindowRect;

  VTIG_BeginGroup( 23 );
    VTIG_AdjustPadding( Point(0,-1) );
    for iEntry in FTraits do
      if iEntry.Available
        then VTIG_Selectable( iEntry.Entry, True, LightRed )
        else VTIG_Selectable( iEntry.Entry, False );
    iSelected := VTIG_Selected;
  VTIG_EndGroup;

  VTIG_BeginGroup;
  if iSelected >= 0 then
  begin
    VTIG_Text( FTraits[iSelected].Name, LightRed );
    VTIG_Ruler;
    VTIG_Text( FTraits[iSelected].Quote, Yellow );
    VTIG_Text( '' );
    VTIG_Text( FTraits[iSelected].Desc );
    VTIG_Text( '' );
    if FTraits[iSelected].Requires <> '' then
      VTIG_Text( 'Requires : {0}',[FTraits[iSelected].Requires] );
    if FTraits[iSelected].Blocks <> '' then
      VTIG_Text( 'Blocks   : {0}',[FTraits[iSelected].Blocks] );
  end;
  VTIG_EndGroup;

  if FTraitMode
    then VTIG_End('{l<{!Up,Down}> scroll, <{!Enter}> select}')
    else VTIG_End('{l<{!Left,Right}> panels, <{!Up,Down}> scroll, <{!Escape}> exit}');

  if (iSelected >= 0) and FTraitMode then
    if VTIG_EventConfirm then
    begin
      FState := PLAYERVIEW_CLOSING;
      if FTraitFirst
        then FOnPick( FTraits[iSelected].Index )
        else Player.FTraits.Upgrade( FTraits[iSelected].Index );
      FState := PLAYERVIEW_DONE;
    end;
end;

procedure TPlayerView.PushItem( aItem : TItem; aArray : TItemViewArray );
var iEntry : TItemViewEntry;
    iSet   : AnsiString;
begin
  iEntry.Item  := aItem;
  iEntry.Name  := aItem.Description;
  iEntry.Stats := aItem.DescriptionBox( True );
  iEntry.Color := aItem.MenuColor;
  iEntry.QSlot := 0;

  iEntry.Desc  := LuaSystem.Get(['items',aItem.ID,'desc']);
  if aItem.Flags[ IF_SETITEM ] then
  begin
    iSet        := LuaSystem.Get(['items',aItem.ID,'set']);
    iEntry.Desc := Format('@<%s@> (1/%d)', [
      AnsiString( LuaSystem.Get(['itemsets',iSet,'name']) ),
      Byte( LuaSystem.Get(['itemsets',iSet,'trigger']) ) ])
      + #10+ iEntry.Desc;
  end;
  aArray.Push( iEntry );
end;

procedure TPlayerView.ReadInv;
var iItem  : TItem;
begin
  if FInv = nil then FInv := TItemViewArray.Create;
  FInv.Clear;

  for iItem in Player.Inv do
    if (not Player.Inv.Equipped( iItem )) {and (iItem.IType in aFilter) }then
      PushItem( iItem, FInv );

  Sort( FInv );
  ReadQuickSlots;
end;

procedure TPlayerView.ReadEq;
var iSlot  : TEqSlot;
    iEntry : TItemViewEntry;
begin
  if FEq = nil then FEq := TItemViewArray.Create;
  FEq.Clear;

  for iSlot := Low(TEqSlot) to High(TEqSlot) do
    if Player.Inv.Slot[iSlot] <> nil
      then PushItem( Player.Inv.Slot[iSlot], FEq )
      else
        begin
          iEntry.Item  := nil;
          iEntry.Name  := SlotName( iSlot );
          iEntry.Stats := '';
          iEntry.Desc  := '';
          iEntry.Color := DarkGray;
          iEntry.QSlot := 0;
          FEq.Push( iEntry );
        end;
end;

procedure TPlayerView.ReadTraits( aKlass : Byte );
var iEntry    : TTraitViewEntry;
    iKlass    : Byte;
    iLevel    : Byte;
    iTrait, i : byte;
    iTraits   : Variant;
    iTData    : PTraits;
    iName     : AnsiString;
    iNID      : Word;
    iValue    : Word;
    iSize     : Word;
    iCount    : Word;
    iTable  : TLuaTable;
const RG : array[Boolean] of Char = ('G','R');
      RL : array[Boolean] of Char = ('L','R');
  function Value( aTrait : Byte ) : Byte;
  begin
    if FTraitFirst then Exit(0);
    Exit( iTData^.Values[aTrait] );
  end;

begin
  if FTraits = nil then FTraits := TTraitViewArray.Create;
  FTraits.Clear;

  iKlass := aKlass;
  iLevel := 0;
  iTData := nil;
  if not FTraitFirst then
  begin
    iLevel := Player.ExpLevel;
    iTData := @(Player.FTraits);
  end;

  iTraits := LuaSystem.Get(['klasses',iKlass,'traitlist']);
  for i := VarArrayLowBound(iTraits, 1) to VarArrayHighBound(iTraits, 1) do
  begin
    iTrait := iTraits[ i ];
    iEntry.Value     := Value( iTrait );
    iEntry.Name      := LuaSystem.Get(['traits',iTrait,'name']);
    iEntry.Entry     := Padded(iEntry.Name,16) +' ({!'+IntToStr(iEntry.Value)+'})';
    with LuaSystem.GetTable(['traits',iTrait]) do
    try
      iEntry.Quote := getString('quote');
      iEntry.Desc  := getString('full');
    finally
      Free;
    end;

    iEntry.Requires := '';
    iEntry.Blocks   := '';
    with LuaSystem.GetTable(['klasses',iKlass,'trait',iTrait]) do
    try
      if GetTableSize('requires') > 0 then
      for iTable in ITables('requires') do
      begin
        iNID            := iTable.GetValue( 1 );
        iName           := LuaSystem.Get(['traits',iNID,'name']);
        iValue          := iTable.GetValue( 2 );
        iEntry.Requires += '{'+RG[Value(iNID) < iValue]+iName+'} ({!'+IntToStr(iValue)+'}), ';
      end;

      iValue := GetInteger('reqlevel',0);
      if iValue > 0
        then iEntry.Requires += '{'+RG[iLevel < iValue]+'Level }({!'+IntToStr(iValue)+'})'
        else Delete( iEntry.Requires, Length(iEntry.Requires) - 1, 2 );

      iSize   := GetTableSize('blocks');
      if iSize > 0 then
      begin
        with GetTable('blocks') do
        try
          for iCount := 1 to iSize do
          begin
            iNID          := GetValue( iCount );
            iName         := LuaSystem.Get(['traits',iNID,'name']);
            iEntry.Blocks += '{'+RL[Value(iNID) > 0]+iName+'}, ';
          end;
        finally
          Free;
        end;
        Delete( iEntry.Blocks, Length(iEntry.Blocks) - 1, 2 );
      end;
    finally
      Free;
    end;

    iEntry.Index     := iTrait;
    if FTraitFirst
      then iEntry.Available := TTraits.CanPickInitially( iTrait, iKlass )
      else iEntry.Available := iTData^.CanPick( iTrait, iLevel );
    FTraits.Push( iEntry );
  end;
end;

procedure TPlayerView.ReadCharacter;
var iKillRecord : Integer;
    iDodgeBonus : Word;
    iKnockMod   : Integer;
begin
  if FCharacter = nil then FCharacter := TStringGArray.Create;
  FCharacter.Clear;

  FCTitle := LuaSystem.Get([ 'diff', Doom.Difficulty, 'ccode' ]);
  if Doom.Challenge <> ''  then FCTitle += ' / ' + LuaSystem.Get(['chal',Doom.Challenge,'abbr']);
  if Doom.SChallenge <> '' then FCTitle += ' + ' + LuaSystem.Get(['chal',Doom.SChallenge,'abbr']);
  FCTitle := 'Character ( '+FCTitle+' )';

  with Player do
  begin
    FStatistics.Update();
    iKillRecord := FStatistics.Map['kills_non_damage'];
    if FKills.NoDamageSequence > iKillRecord then iKillRecord := FKills.NoDamageSequence;

    FCharacter.Push( Format( '{!%s}, level {!%d} {!%s},',[ Name, ExpLevel, AnsiString(LuaSystem.Get(['klasses',Klass,'name']))] ) );
    FCharacter.Push( Format( 'currently on level {!%d} of the Phobos base. ', [CurrentLevel] ) );
    FCharacter.Push( Format( 'He survived {!%d} turns, which took him {!%d} seconds. ', [ FStatistics.Map['game_time'], FStatistics.Map['real_time'] ] ) );
    FCharacter.Push( Format( 'He took {!%d} damage, {!%d} on this floor alone. ', [ FStatistics.Map['damage_taken'], FStatistics.Map['damage_on_level'] ] ) );
    FCharacter.Push( Format( 'He killed {!%d} out of {!%d} enemies total. ', [ FStatistics.Map['kills'], FStatistics.Map['max_kills'] ] ) );
    FCharacter.Push( Format( 'His current killing spree is {!%d}, with a record of {!%d}. ', [ FKills.NoDamageSequence, iKillRecord ] ) );
    FCharacter.Push( '' );
    FCharacter.Push( Format( 'Current movement speed is {!%.2f} second/move.', [getMoveCost/(Speed*10.0)] ) );
    FCharacter.Push( Format( 'Current fire speed is {!%.2f} second/%s.', [getFireCost/(Speed*10.0),IIf(canDualGun,'dualshot','shot')] ) );
    FCharacter.Push( Format( 'Current reload speed is {!%.2f} second/reload.', [getReloadCost/(Speed*10.0)] ) );
    FCharacter.Push( Format( 'Current to hit chance (point blank) is {!%s}.',[toHitPercent(10+getToHitRanged(Inv.Slot[efWeapon]))]));
    FCharacter.Push( Format( 'Current melee hit chance is {!%s}.',[toHitPercent(10+getToHitMelee(Inv.Slot[efWeapon]))]));
    FCharacter.Push( '' );

    iDodgeBonus := getDodgeMod;
    if Player.Running then iDodgeBonus += 20;
    iKnockMod   := getKnockMod;

    if iDodgeBonus <> 0
      then FCharacter.Push( Format( 'He has a {!%d%%} bonus toward dodging attacks.', [iDodgeBonus]))
      else FCharacter.Push( 'He has no bonus toward dodging attacks.' );

    { Knockback Modifier }
    if ( ( iKnockMod <> 100 ) and ( BodyBonus <> 0 ) ) then
    begin
      if ( iKnockMod < 100 )
      then FCharacter.Push( Format( 'He resists {!%d%%} of knockback', [100-iKnockMod]))
      else FCharacter.Push( Format( 'He receives {!%d%%} extra knockback', [iKnockMod-100]));
      FCharacter.Push( Format( '%s prevents {!%d} space%s of knockback.', [IIf( iKnockMod < 100, 'and', 'but' ), BodyBonus, IIf(BodyBonus <> 1, 's') ]));
    end
    else if ( iKnockMod <> 100 ) then
      if ( iKnockMod < 100 )
      then FCharacter.Push( Format( 'He resists {!%d%%} of knockback.', [100-iKnockMod]))
      else FCharacter.Push( Format( 'He receives {!%d%%} extra knockback.', [iKnockMod-100]))
    else if ( BodyBonus <> 0 )
      then FCharacter.Push( Format( 'He prevents {!%d} space%s of knockback.', [BodyBonus, IIf(BodyBonus <> 1,'s')]))
    else
      FCharacter.Push( 'He has no resistance to knockback.' );
    FCharacter.Push( '' );
    FCharacter.Push( Format( 'Enemies left : {!%d}', [Doom.Level.EnemiesLeft] ) );
    if Doom.Level.Feeling <> '' then
      FCharacter.Push( Format( 'Level feel : {!%s}', [Doom.Level.Feeling] ) )
  end;

end;

procedure TPlayerView.Sort( aList : TItemViewArray );
var iCount  : Integer;
    iCount2 : Integer;
    iTemp   : TItemViewEntry;
begin
  for iCount := 0 to aList.Size - 1 do
    for iCount2 := 0 to aList.Size - iCount - 2 do
      if TItem.Compare(aList[iCount2].Item,aList[iCount2+1].Item) then
      begin
        iTemp := aList[iCount2];
        aList[iCount2] := aList[iCount2+1];
        aList[iCount2+1] := iTemp;
      end;
end;

procedure TPlayerView.Filter( aSet : TItemTypeSet );
var iCount  : Integer;
    iSize   : Integer;
begin
  iSize := 0;
  if FInv = nil then ReadInv;
  if FInv.Size > 0 then
  for iCount := 0 to FInv.Size - 1 do
    if FInv[ iCount ].Item.IType in aSet then
    begin
      if iCount <> iSize then
        FInv[ iSize ] := FInv[ iCount ];
      Inc( iSize );
    end;
  FInv.Resize( iSize );
end;

procedure TPlayerView.ReadQuickslots;
var i,s    : Integer;
begin
  if FInv.Size = 0 then Exit;

  for i := 0 to FInv.Size - 1 do
    FInv.Data^[i].QSlot := 0;

  if FInv.Size > 0 then
  for s := 1 to 9 do
  begin
    if Player.FQuickSlots[s].UID <> 0 then
    begin
      for i := 0 to FInv.Size - 1 do
        if Assigned( FInv.Data^[i].Item ) then
          if FInv.Data^[i].Item.UID = Player.FQuickSlots[s].UID then
            FInv.Data^[i].QSlot := s;
    end
    else if Player.FQuickSlots[s].ID <> '' then
    begin
      for i := 0 to FInv.Size - 1 do
        if Assigned( FInv.Data^[i].Item ) then
          if FInv.Data^[i].Item.ID = Player.FQuickSlots[s].ID then
            FInv.Data^[i].QSlot := s;
    end;
  end;
end;

procedure TPlayerView.InitSwapMode( aSlot : TEqSlot );
begin
  VTIG_ResetSelect( 'inventory' );
  FState    := PLAYERVIEW_INVENTORY;
  FSwapMode := True;
  FITitle   := 'Select item to wear/wield';
  FAction   := 'wear/wield';
  Filter( ItemEqFilters[ aSlot ] );
  FSSlot := aSlot;
end;

constructor TUnloadConfirmView.Create( aItem : TItem; aID : Ansistring = '' );
begin
  inherited Create;
  FItem := aItem;
  FID   := aID;
  if FID = ''
    then FMessage := 'An ammopack might serve better in the Prepared slot. Continuing will unload the ammo destroying the pack. Are you sure?'
    else FMessage := 'Do you want to disassemble the '+FItem.Name+'?';
  if FID = ''
    then FSize := Point( 50,10 )
    else FSize := Point( 50, 9 );
end;

procedure TUnloadConfirmView.OnConfirm;
begin
  Doom.HandleCommand( TCommand.Create( COMMAND_UNLOAD, FItem, FID ) );
end;

end.

