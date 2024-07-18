{$INCLUDE doomrl.inc}
unit doomplayerview;
interface
uses viotypes, vgenerics, doomio, dfitem;

type TPlayerViewState = (
  PLAYERVIEW_INVENTORY,
  PLAYERVIEW_EQUIPMENT,
  PLAYERVIEW_CHARACTER,
  PLAYERVIEW_TRAITS,
  PLAYERVIEW_DONE
);

type TItemViewEntry = record
  Name  : Ansistring;
  Desc  : Ansistring;
  Stats : Ansistring;
  Item  : TItem;
  Color : Byte;
end;

type TItemViewArray = specialize TGArray< TItemViewEntry >;

type TPlayerView = class( TInterfaceLayer )
  constructor Create( aInitialState : TPlayerViewState = PLAYERVIEW_INVENTORY );
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
  destructor Destroy; override;
protected
  procedure UpdateInventory;
  procedure UpdateEquipment;
  procedure UpdateCharacter;
  procedure UpdateTraits;
  procedure PushItem( aItem : TItem; aArray : TItemViewArray );
  procedure ReadInv;
  procedure ReadEq;
  procedure Sort( aList : TItemViewArray );
protected
  FState : TPlayerViewState;
  FSize  : TIOPoint;
  FInv   : TItemViewArray;
  FEq    : TItemViewArray;
end;

implementation

uses sysutils,
     vutil, vtig, vtigio, vgltypes, vluasystem,
     dfdata, dfplayer,
     doombase, doominventory, doomtrait, doomgfxio;

constructor TPlayerView.Create( aInitialState : TPlayerViewState = PLAYERVIEW_INVENTORY );
begin
  VTIG_EventClear;
  FState := aInitialState;
  FSize  := Point( 80, 25 );
  FInv   := nil;
  FEq    := nil;
end;

procedure TPlayerView.Update( aDTime : Integer );
var iP1,iP2 : TPoint;
begin
  if IsFinished then Exit;

  if Doom.State <> DSPlaying then
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

  if VTIG_Event( VTIG_IE_LEFT ) then
  begin
    if FState = Low( TPlayerViewState ) then FState := PLAYERVIEW_TRAITS       else FState := Pred( FState );
  end;
  if VTIG_Event( VTIG_IE_RIGHT ) then
  begin
    if FState = PLAYERVIEW_TRAITS       then FState := Low( TPlayerViewState ) else FState := Succ( FState );
  end;

  if FState <> PLAYERVIEW_DONE then
  begin
    if VTIG_EventCancel or VTIG_Event( [ TIG_EV_INVENTORY, TIG_EV_EQUIPMENT, TIG_EV_CHARACTER, TIG_EV_TRAITS ] ) then
    begin
      FState := PLAYERVIEW_DONE;
    end;
  end;

  if GraphicsVersion then
    with IO as TDoomGFXIO do
    begin
      iP1 := ConsoleCoordToDeviceCoord( PointUnit );
      iP2 := ConsoleCoordToDeviceCoord( FSize + PointUnit );
      QuadSheet.PushColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.7 ) );
    end;
end;

function TPlayerView.IsFinished : Boolean;
begin
  Exit( FState = PLAYERVIEW_DONE );
end;

function TPlayerView.IsModal : Boolean;
begin
  Exit( True );
end;

destructor TPlayerView.Destroy;
begin
  FreeAndNil( FEq );
  FreeAndNil( FInv );
  inherited Destroy;
end;

procedure TPlayerView.UpdateInventory;
var iEntry    : TItemViewEntry;
    iSelected : Integer;
begin
  if FInv = nil then ReadInv;
  VTIG_BeginWindow('Inventory', FSize );
    VTIG_BeginGroup( 50 );
    for iEntry in FInv do
      VTIG_Selectable( iEntry.Name, True, iEntry.Color );
    iSelected := VTIG_Selected;
    VTIG_EndGroup;

    VTIG_BeginGroup;
    if iSelected >= 0 then
    begin
      VTIG_Text( FInv[iSelected].Desc );
      VTIG_FreeLabel( FInv[iSelected].Stats, Point( 0, 7 ) );
    end;
    VTIG_EndGroup;
  VTIG_End('{l<{!Left,Right}> panels, <{!Up,Down}> select, <{!Escape}> exit, <{!Backspace}> drop}');
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
begin
  if FEq = nil then ReadEq;
  VTIG_BeginWindow('Equipment', FSize );
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

  VTIG_End('{l<{!Left,Right}> panels, <{!Up,Down}> select, <{!Escape}> exit, <{!Backspace}> drop}');
end;

procedure TPlayerView.UpdateCharacter;
begin
  VTIG_BeginWindow('Character', FSize );
  VTIG_End('{l<{!Left,Right}> panels, <{!Up,Down}> scroll, <{!Escape}> exit}');
end;

procedure TPlayerView.UpdateTraits;
begin
  VTIG_BeginWindow('Traits', FSize );
  VTIG_End('{l<{!Left,Right}> panels, <{!Up,Down}> scroll, <{!Escape}> exit}');
end;

procedure TPlayerView.PushItem( aItem : TItem; aArray : TItemViewArray );
var iEntry : TItemViewEntry;
    iSet   : AnsiString;
begin
  iEntry.Item  := aItem;
  iEntry.Name  := aItem.Description;
  iEntry.Stats := aItem.DescriptionBox( True );
  iEntry.Color := aItem.MenuColor;

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
          FEq.Push( iEntry );
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

end.

