
{$INCLUDE doomrl.inc}
unit dfplayer;
interface
uses classes, sysutils,
     vuielement, vutil, vrltools,
     dfbeing, dfhof, dfdata, dfitem, dfaffect,
     doomtrait;

type

TRunData = object
  Dir    : TDirection;
  Active : Boolean;
  Count  : Word;
  procedure Clear;
  procedure Stop;
  procedure Start( const aDir : TDirection );
end;

TTacticData = object
  Current : TTactic;
  Count   : Word;
  Max     : Word;
  procedure Clear;
  procedure Stop;
  procedure Tick;
  procedure Reset;
  function Change : Boolean;
end;

TStatistics = object
  Map        : TIntHashMap;
  GameTime   : LongInt;
  RealTime   : Comp;
  procedure Clear;
  procedure Destroy;
  procedure Update;
  procedure UpdateNDCount( aCount : DWord );
end;


{ TPlayer }

TPlayer = class(TBeing)
  CurrentLevel    : Word;

  SpecExit        : string[20];
  NukeActivated   : Word;

  InventorySize   : Byte;
  MasterDodge     : Boolean;
  LastTurnDodge   : Boolean;

  FScore          : LongInt;
  FExpFactor      : Real;
  FBersekerLimit  : LongInt;
  FEnemiesInVision: Word;
  FKilledBy       : AnsiString;
  FKilledMelee    : Boolean;

  FStatistics     : TStatistics;
  FKills          : TKillTable;
  FTraits         : TTraits;
  FRun            : TRunData;
  FTactic         : TTacticData;
  FAffects        : TAffects;
  FPathRun        : Boolean;

  constructor Create; reintroduce;
  procedure Initialize; reintroduce;
  constructor CreateFromStream( Stream: TStream ); override;
  procedure WriteToStream( Stream: TStream ); override;
  procedure AIControl;
  procedure LevelEnter;
  procedure doUpgradeTrait;
  function doAct( aFlagID : byte; const aActName : string ) : Boolean;
  procedure RegisterKill( const aKilledID : AnsiString; aKiller : TBeing; aWeapon : TItem );
  function doUnLoad : Boolean;
  procedure doScreen;
  procedure doDrop;
  function doQuickWeapon( const aWeaponID : Ansistring ) : Boolean;
  procedure doFire( aAlternative : Boolean = False );
  procedure doQuit( aNoConfirm : Boolean = False );
  procedure doRun;
  procedure ApplyDamage( aDamage : LongInt; aTarget : TBodyTarget; aDamageType : TDamageType; aSource : TItem ); override;
  procedure LevelUp;
  procedure AddExp( aAmount : LongInt );
  function doSave : Boolean;
  procedure WriteMemorial;
  destructor Destroy; override;
  procedure IncStatistic( const aStatisticID : AnsiString; aAmount : Integer = 1 );
  procedure Kill( BloodAmount : DWord; aOverkill : Boolean; aKiller : TBeing; aWeapon : TItem ); override;
  function DescribeLever( aItem : TItem ) : string;
  procedure AddHistory( const aHistory : Ansistring );
  class procedure RegisterLuaAPI();
  procedure UpdateVisual;
  function ASCIIMoreCode : AnsiString; override;
  function CreateAutoTarget( aRange : Integer ): TAutoTarget;
  function doChooseTarget( aActionName : string; aRadius : Byte ) : boolean;
  private
  function OnTraitConfirm( aSender : TUIElement ) : Boolean;
  procedure ExamineNPC;
  procedure ExamineItem;
  private
  FLastTargetUID  : TUID;
  FLastTargetPos  : TCoord2D;
  FExp            : LongInt;
  FExpLevel       : Byte;
  private
  procedure SetTired( Value : Boolean );
  procedure SetRunning( Value : Boolean );
  function GetTired : Boolean;
  function GetRunning : Boolean;
  function GetSkillRank : Word;
  function GetExpRank : Word;
  published
  property KilledBy      : AnsiString read FKilledBy;
  property KilledMelee   : Boolean    read FKilledMelee;
  property Running       : Boolean    read GetRunning    write SetRunning;
  property Tired         : Boolean    read GetTired      write SetTired;
  property Exp           : LongInt    read FExp          write FExp;
  property ExpLevel      : Byte       read FExpLevel     write FExpLevel;
  property NukeTime      : Word       read NukeActivated write NukeActivated;
  property Klass         : Byte       read FTraits.Klass write FTraits.Klass;
  property RunningTime   : Word       read FTactic.Max   write FTactic.Max;
  property ExpFactor     : Real       read FExpFactor    write FExpFactor;
  property SkillRank     : Word       read GetSkillRank;
  property ExpRank       : Word       read GetExpRank;
  property Score         : LongInt    read FScore        write FScore;
  property Depth         : Word       read CurrentLevel;
  property BeingsInVision: Word       read FEnemiesInVision;
end;

var   Player : TPlayer;

implementation

uses math, vpath, variants, vioevent, vgenerics,
     vnode, vcolor, vuielements, vdebug, vluasystem,
     dfmap, dflevel, dfoutput,
     doomhooks, doomio,  doomanimation, doomspritemap, doomviews, doombase,
     doomlua, doominventory;

var MortemText    : Text;
    WritingMortem : Boolean = False;

{ TStatistics }

procedure TStatistics.Clear;
begin
  Map        := TIntHashMap.Create( HashMap_NoRaise );
  GameTime   := 0;
  RealTime   := 0;
end;

procedure TStatistics.Destroy;
begin
  FreeAndNil( Map );
end;

procedure TStatistics.Update;
var iRealTime : Comp;
begin
  iRealTime := RealTime + MSecNow() - GameRealTime;
  Map['real_time']    := Round(iRealTime / 1000);
  Map['real_time_ms'] := Round(iRealTime);
  Map['game_time']    := GameTime;
  Map['kills']        := Player.FKills.Count;
  Map['max_kills']    := Player.FKills.MaxCount;
end;

procedure TStatistics.UpdateNDCount( aCount : DWord );
begin
  Map['kills_non_damage'] := Max( Map['kills_non_damage'], aCount );
end;

{ TTacticData }

procedure TTacticData.Clear;
begin
  Count   := 30;
  Current := tacticNormal;
end;

procedure TTacticData.Stop;
begin
  if Current = tacticRunning then Current := TacticTired;
end;

procedure TTacticData.Tick;
begin
  if ( Count > 0 ) and ( Current = TacticRunning ) then
  begin
    Dec( Count );
    if Count = 0 then
    begin
      UI.Msg('You stop running.');
      Current := tacticTired;
    end;
  end;
end;

procedure TTacticData.Reset;
begin
  Current := tacticNormal;
  Count := 0;
end;

function TTacticData.Change : Boolean;
begin
  Change := False;
  case Current of
    tacticTired   : UI.Msg('Too tired to do that right now.');
    tacticRunning : begin
                      UI.Msg('You stop running.');
                      Current := tacticTired;
                    end;
    tacticNormal  : begin
                      UI.Msg('You start running!');
                      Count := Max;
                      Current := tacticRunning;
                      Change := True;
                    end;
  end;
end;

{ TRunData }

procedure TRunData.Clear;
begin
  Active := False;
  Count  := 0;
end;

procedure TRunData.Stop;
begin
  Active := False;
  Count := 0;
end;

procedure TRunData.Start ( const aDir : TDirection ) ;
begin
  Active := True;
  Count  := 0;
  Dir    := aDir;
end;

constructor TPlayer.Create;
begin
  inherited Create('soldier');

  FTraits.Clear;
  FKills := TKillTable.Create;
  FRun.Clear;
  FTactic.Clear;
  FAffects.Clear;

  CurrentLevel  := 0;
  StatusEffect  := StatusNormal;
  FStatistics.Clear;
  FScore        := 0;
  SpecExit      := '';
  NukeActivated := 0;
  FExpLevel   := 1;
  FExp        := ExpTable[ FExpLevel ];
  FPathRun    := False;

  InventorySize := High( TItemSlot );
  FTactic.Max := 30;
  FExpFactor := 1.0;

  Initialize;

  CallHook( Hook_OnCreate, [] );
end;

procedure TPlayer.Initialize;
begin
  FKilledBy       := '';
  FKilledMelee    := False;

  FEnemiesInVision:= 1;
  FLastTargetPos.Create(0,0);
  FLastTargetUID := 0;
  FPathRun := False;
  FPath           := TPathFinder.Create(Self);
  MemorialWritten := False;
  MasterDodge     := False;
  LastTurnDodge   := False;

  doombase.Lua.RegisterPlayer(Self);
end;

procedure TPlayer.WriteToStream ( Stream : TStream ) ;
begin
  inherited WriteToStream( Stream );

  Stream.WriteAnsiString( SpecExit );
  Stream.WriteWord( CurrentLevel );
  Stream.WriteWord( NukeActivated );
  Stream.WriteByte( InventorySize );
  Stream.WriteByte( FExpLevel );
  Stream.WriteDWord( FExp );
  Stream.WriteDWord( FScore );
  Stream.WriteDWord( FBersekerLimit );

  Stream.Write( FExpFactor, SizeOf( FExpFactor ) );
  Stream.Write( FAffects,   SizeOf( FAffects ) );
  Stream.Write( FTraits,    SizeOf( FTraits ) );
  Stream.Write( FRun,       SizeOf( FRun ) );
  Stream.Write( FTactic,    SizeOf( FTactic ) );
  Stream.Write( FStatistics,SizeOf( FStatistics ) );

  FKills.WriteToStream( Stream );
  FStatistics.Map.WriteToStream( Stream );
end;

constructor TPlayer.CreateFromStream ( Stream : TStream ) ;
begin
  inherited CreateFromStream( Stream );
  SpecExit       := Stream.ReadAnsiString();
  CurrentLevel   := Stream.ReadWord();
  NukeActivated  := Stream.ReadWord();
  InventorySize  := Stream.ReadByte();
  FExpLevel      := Stream.ReadByte();
  FExp           := Stream.ReadDWord();
  FScore         := Stream.ReadDWord();
  FBersekerLimit := Stream.ReadDWord();

  Stream.Read( FExpFactor, SizeOf( FExpFactor ) );
  Stream.Read( FAffects,   SizeOf( TAffects ) );
  Stream.Read( FTraits,    SizeOf( FTraits ) );
  Stream.Read( FRun,       SizeOf( FRun ) );
  Stream.Read( FTactic,    SizeOf( FTactic ) );
  Stream.Read( FStatistics,SizeOf( FStatistics ) );

  FKills          := TKillTable.CreateFromStream( Stream );
  FStatistics.Map := TIntHashMap.CreateFromStream( Stream );
  
  Initialize;
end;

procedure TPlayer.LevelUp;
begin
  Inc( FExpLevel );
  UI.Blink( LightBlue, 100 );
  UI.MsgEnter( 'You advance to level %d!', [ FExpLevel ] );
  if not Doom.CallHookCheck( Hook_OnPreLevelUp, [ FExpLevel ] ) then Exit;
  UI.BloodSlideDown( 20 );
  doUpgradeTrait();
  Doom.CallHook( Hook_OnLevelUp, [ FExpLevel ] );
end;

procedure TPlayer.AddExp( aAmount : LongInt );
begin
  if Dead then Exit;
  aAmount := Round( aAmount * FExpFactor );

  FExp += aAmount;

  if FExpLevel >= MaxPlayerLevel - 1 then Exit;

  while FExp >= ExpTable[ FExpLevel + 1 ] do LevelUp;
end;



function TPlayer.doQuickWeapon( const aWeaponID : Ansistring ) : Boolean;
var iWeapon  : TItem;
    iItem    : TItem;
    iAmmo    : Byte;
begin
  if (not LuaSystem.Defines.Exists(aWeaponID)) or (LuaSystem.Defines[aWeaponID] = 0)then Exit( False );

  if Inv.Slot[ efWeapon ] <> nil then
  begin
    if Inv.Slot[ efWeapon ].ID = aWeaponID then Exit( Fail( 'You already have %s in your hands.', [ Inv.Slot[ efWeapon ].GetName(true) ] ) );
    if Inv.Slot[ efWeapon ].Flags[ IF_CURSED ] then Exit( Fail( 'You can''t!', [] ) );
  end;

  if Inv.Slot[ efWeapon2 ] <> nil then
    if Inv.Slot[ efWeapon2 ].ID = aWeaponID then
      Exit( ActionQuickSwap );

  iAmmo   := 0;
  iWeapon := nil;
  for iItem in Inv do
    if iItem.isWeapon then
      if iItem.ID = aWeaponID then
      if iItem.Ammo >= iAmmo then
      begin
        iWeapon := iItem;
        iAmmo   := iItem.Ammo;
      end;

  if iWeapon = nil then Exit( Fail( 'You don''t have a %s!', [ Ansistring(LuaSystem.Get([ 'items', aWeaponID, 'name' ])) ] ) );

  Inv.Wear( iWeapon );

  if Option_SoundEquipPickup
    then PlaySound( iWeapon.Sounds.Pickup )
    else PlaySound( iWeapon.Sounds.Reload );

  if not ( BF_QUICKSWAP in FFlags )
     then Exit( Success( 'You prepare the %s!',[ iWeapon.Name ], 1000 ) )
     else Exit( Success( 'You prepare the %s instantly!',[ iWeapon.Name ] ) );
end;

function TPlayer.doUnLoad : Boolean;
var iItem : TItem;
    iModID : AnsiString;
    iName  : AnsiString;
begin
  iItem := TLevel(Parent).Item[ FPosition ];
  if (iItem = nil) or ( not (iItem.isRanged or iItem.isAmmoPack ) ) then
  begin
    iItem := Inv.Choose( [ ItemType_Ranged, ItemType_AmmoPack ] , 'unload' );
    if iItem = nil then Exit( False );
  end;
  iName := iItem.Name;

  if iItem.isAmmoPack then
    if not UI.MsgConfirm('An ammopack might serve better in the Prepared slot. Continuing will unload the ammo destroying the pack. Are you sure?', True)
       then Exit( False );

  if (not iItem.isAmmoPack) and (BF_SCAVENGER in FFlags) and
     ((iItem.Ammo = 0) or iItem.Flags[ IF_NOUNLOAD ] or iItem.Flags[ IF_RECHARGE ] or iItem.Flags[ IF_NOAMMO ]) and
     (iItem.Flags[ IF_EXOTIC ] or iItem.Flags[ IF_UNIQUE ] or iItem.Flags[ IF_ASSEMBLED ] or iItem.Flags[ IF_MODIFIED ]) then
  begin
    iModId := LuaSystem.ProtectedCall( ['DoomRL','OnDisassemble'], [ iItem ] );
    if iModID = '' then Exit( ActionUnload( iItem ) );
    if UI.MsgConfirm('Do you want to disassemble the '+iName+'?', True) then
    begin
      FreeAndNil( iItem );
      iItem := TItem.Create( iModId );
      playSound(iItem.Sounds.Reload);
      if not Inv.isFull
        then Inv.Add( iItem )
        else TLevel(Parent).DropItem( iItem, FPosition );
      Exit( Success( 'You disassemble the %s.',[iName], ActionCostReload ) );
    end;
  end;
  Exit( ActionUnload( iItem ) );
end;

procedure TPlayer.ApplyDamage(aDamage: LongInt; aTarget: TBodyTarget; aDamageType: TDamageType; aSource : TItem);
begin
  if aDamage < 0 then Exit;

  FPathRun := False;
  FRun.Stop;
  if BF_INV in FFlags then Exit;
  if ( aDamage >= Max( FHPNom div 3, 10 ) ) then
  begin
    UI.Blink(Red,100);
    if BF_BERSERKER in FFlags then
    begin
      UI.Msg('That hurt! You''re going berserk!');
      FTactic.Stop;
      FAffects.Add(LuaSystem.Defines['berserk'],20);
    end;
  end;

  if aDamage > 0 then
  begin
    FKills.DamageTaken;
    FStatistics.UpdateNDCount( FKills.BestNoDamageSequence );
  end;
  inherited ApplyDamage(aDamage, aTarget, aDamageType, aSource );
end;

procedure TPlayer.doDrop;
var Item : TItem;
begin
  Item := Inv.Choose([],'drop');
  if Item <> nil then ActionDrop( Item );
end;

procedure TPlayer.doRun;
var Key : Byte;
begin
  FPathRun := False;
  if FEnemiesInVision > 1 then
  begin
    Fail( 'Can''t run, there are enemies present.',[] );
    Exit;
  end;
  Key := UI.MsgCommandChoice('Run - direction...',COMMANDS_MOVE+[COMMAND_ESCAPE,COMMAND_WAIT]);
  if Key = COMMAND_ESCAPE then Exit;
  FRun.Start( CommandDirection(Key) );
end;

function TPlayer.doAct( aFlagID : byte; const aActName : string) : Boolean;
var iLevel  : TLevel;
    iDir    : TDirection;
    iScan   : TCoord2D;
    iAct    : TCoord2D;
    iCount  : byte;
begin
  iLevel := TLevel(Parent);
  iCount := 0;
  for iScan in NewArea( FPosition, 1 ).Clamped( iLevel.Area ) do
    if iLevel.cellFlagSet(iScan, aFlagID) and iLevel.isEmpty( iScan ,[EF_NOITEMS,EF_NOBEINGS] ) then
    begin
      Inc(iCount);
      iAct := iScan;
    end;
    
  if iCount = 0 then Exit( Fail( 'There''s no door you can %s here.', [ aActName ] ) );

  if iCount > 1 then
  begin
    iDir := UI.ChooseDirection(Capitalized(aActName)+' door');
    if iDir.code = DIR_CENTER then Exit;
    iAct := FPosition + iDir;
  end;

  if iLevel.isProperCoord( iAct ) and iLevel.cellFlagSet( iAct, aFlagID )
    then iLevel.CallHook( iAct, Self, CellHook_OnAct )
    else Exit( Fail( 'You can''t %s that.', [ aActName ] ) );
  Exit( True );
end;

procedure TPlayer.RegisterKill ( const aKilledID : AnsiString; aKiller : TBeing; aWeapon : TItem ) ;
var iKillClass : AnsiString;
begin
  iKillClass := 'other';
  if aKiller = Self then
  begin
    iKillClass := 'melee';
    if aWeapon <> nil then
      iKillClass := aWeapon.ID;
  end;
  FKills.Add( aKilledID, iKillClass );
end;

function TPlayer.CreateAutoTarget( aRange : Integer ): TAutoTarget;
var iLevel : TLevel;
    iCoord : TCoord2D;
begin
  iLevel := TLevel(Parent);
  Result := TAutoTarget.Create( FPosition );
  for iCoord in NewArea( FPosition, aRange ).Clamped( iLevel.Area ) do
    if iLevel.Being[ iCoord ] <> nil then
    with iLevel.Being[ iCoord ] do
      if (not isPlayer) and isVisible then
        Result.AddTarget( iCoord );
end;

function TPlayer.doChooseTarget( aActionName : string; aRadius : Byte ) : boolean;
var iTargets : TAutoTarget;
    iTarget  : TBeing;
    iLevel   : TLevel;
begin
  if aRadius = 0 then aRadius := FVisionRadius;

  iLevel   := TLevel(Parent);
  iTargets := CreateAutoTarget( aRadius );

  iTarget := nil;
  if (FLastTargetUID <> 0) and iLevel.isAlive( FLastTargetUID ) then
  begin
    iTarget := iLevel.FindChild( FLastTargetUID ) as TBeing;
    if iTarget <> nil then
      if iTarget.isVisible then
        if Distance( iTarget.Position, FPosition ) <= aRadius then
          iTargets.PriorityTarget( iTarget.Position );
  end;

  if FLastTargetPos.X*FLastTargetPos.Y <> 0 then
    if FLastTargetUID = 0 then
      if iLevel.isVisible( FLastTargetPos ) then
        if Distance( FLastTargetPos, FPosition ) <= aRadius then
          iTargets.PriorityTarget( FLastTargetPos );

  FTargetPos := UI.ChooseTarget(aActionName, aRadius+1, iTargets, FChainFire > 0);
  FreeAndNil(iTargets);
  if FTargetPos.X = 0 then Exit( False );

  if FTargetPos = FPosition then
  begin
    UI.Msg( 'Find a more constructive way to commit suicide.' );
    Exit( False );
  end;

  FLastTargetUID := 0;
  if iLevel.Being[ FTargetPos ] <> nil then
    FLastTargetUID := iLevel.Being[ FTargetPos ].UID;
  FLastTargetPos := FTargetPos;
  Exit( True );
end;

function TPlayer.OnTraitConfirm ( aSender : TUIElement ) : Boolean;
begin
  with aSender as TUICustomMenu do
    FTraits.Upgrade( Word(SelectedItem.Data) );
  aSender.Parent.Free;
  Exit( True );
end;

procedure TPlayer.doFire( aAlternative : Boolean = False );
var iDirection : TDirection;
    iWeapon    : TItem;
begin
  iWeapon := Inv.Slot[ efWeapon ];
  if (not aAlternative) and (iWeapon <> nil) and iWeapon.isMelee then
  begin
    iDirection := UI.ChooseDirection('Melee attack');
    if (iDirection.code = DIR_CENTER) then Exit;
    Attack( FPosition + iDirection );
    Exit;
  end;

  if aAlternative
     then ActionAltFire( True, FTargetPos{unused}, iWeapon )
     else ActionFire( True, FTargetPos{unused}, iWeapon );
end;

function TPlayer.doSave : Boolean;
begin
  if Doom.Difficulty >= DIFF_NIGHTMARE then Exit( Fail( 'There''s no escape from a NIGHTMARE! Stand and fight like a man!', [] ) );
  if not (CellHook_OnExit in Cells[ TLevel(Parent).Cell[ FPosition ] ].Hooks) then Exit( Fail( 'You can only save the game standing on the stairs to the next level.', [] ) );
  Doom.SetState( DSSaving );
  TLevel(Parent).CallHook( Position, CellHook_OnExit );
end;

procedure TPlayer.doQuit( aNoConfirm : Boolean = False );
begin
  if not aNoConfirm then
  begin
    UI.Msg( LuaSystem.ProtectedCall(['DoomRL','quit_message'],[]) );
    if not UI.MsgConfirm('Are you sure you want to commit suicide?', true) then
    begin
      UI.Msg('Ok, then. Stay and take what''s coming to ya...');
      Exit;
    end;
  end;
  Doom.SetState( DSQuit );
  FScore      := -100000;
end;

procedure TPlayer.AIControl;
var iLevel      : TLevel;
    iCommand    : Byte;
    iDir        : TDirection;
    iMove       : TCoord2D;
    iItem       : TItem;
    iAlt        : Boolean;
    iMoveResult : TMoveResult;
    iTempSC     : LongInt;
    function RunStopNear : boolean;
    begin
      if iLevel.isProperCoord( FPosition.ifIncX(+1) ) and iLevel.cellFlagSet( FPosition.ifIncX(+1), CF_RUNSTOP ) then Exit( True );
      if iLevel.isProperCoord( FPosition.ifIncX(-1) ) and iLevel.cellFlagSet( FPosition.ifIncX(-1), CF_RUNSTOP ) then Exit( True );
      if iLevel.isProperCoord( FPosition.ifIncY(+1) ) and iLevel.cellFlagSet( FPosition.ifIncY(+1), CF_RUNSTOP ) then Exit( True );
      if iLevel.isProperCoord( FPosition.ifIncY(-1) ) and iLevel.cellFlagSet( FPosition.ifIncY(-1), CF_RUNSTOP ) then Exit( True );
      Exit( False );
    end;
begin
  iLevel := TLevel(Parent);
  UI.WaitForAnimation;
  MasterDodge := False;
  FAffects.Tick;
  FLastPos := FPosition;
  if Doom.State <> DSPlaying then Exit;
  FTactic.Tick;
  Inv.EqTick;
repeat
  iCommand := 0;
  // FArmor color //
  StatusEffect := FAffects.getEffect;
  UI.Focus( FPosition );
  iLevel.CalculateVision( FPosition );
  if GraphicsVersion then
    UI.GameUI.UpdateMinimap;
  FEnemiesInVision := iLevel.BeingsVisible;
  if FEnemiesInVision > 1 then begin FPathRun := False; FRun.Stop; end;

  if iLevel.Item[ FPosition ] <> nil then
    if iLevel.Item[ FPosition ].Hooks[ Hook_OnEnter ] then
    begin
      iLevel.Item[ FPosition ].CallHook( Hook_OnEnter, [ Self ] );
      if (FSpeedCount < 5000) or (Doom.State <> DSPlaying) then Exit;
    end
    else
    if not FPathRun then
      with iLevel.Item[ FPosition ] do
        if isLever then
           UI.Msg('There is a %s here.', [ DescribeLever( iLevel.Item[ FPosition ] ) ] )
        else
          if Flags[ IF_PLURALNAME ]
            then UI.Msg('There are %s lying here.', [ GetName( False ) ] )
            else UI.Msg('There is %s lying here.', [ GetName( False ) ] );

  if FRun.Active then
  begin
    if IO.CommandEventPending then
    begin
      FPathRun := False;
      FRun.Stop;
      IO.ClearEventBuffer;
    end
    else
    begin
      iCommand := COMMAND_WALKNORTH;

      if not GraphicsVersion then
        IO.Delay( Option_RunDelay );
    end;
  end;

  if FEnemiesInVision < 2 then
  begin
    FChainFire := 0;
    if FBersekerLimit > 0 then Dec( FBersekerLimit );
  end;

try

  if FChainFire > 0 then
    iCommand := COMMAND_ALTFIRE;

  if iCommand = 0
    then iCommand := IO.GetCommand
    else UI.MsgUpDate;

  if iCommand in [ COMMAND_MLEFT, COMMAND_MRIGHT ] then
    iAlt := VKMOD_ALT in IO.Driver.GetModKeyState;

  if iCommand = COMMAND_MMIDDLE then
    if IO.MTarget = FPosition
      then iCommand := COMMAND_SWAPWEAPON
      else iCommand := COMMAND_EQUIPMENT;

  if iCommand = COMMAND_MLEFT then
    if IO.MTarget = FPosition then
      if iAlt then iCommand := COMMAND_INVENTORY
      else
      if iLevel.cellFlagSet( FPosition, CF_STAIRS ) then
        iCommand := COMMAND_ENTER
      else
        if iLevel.Item[ FPosition ] <> nil then
          if iLevel.Item[ FPosition ].isLever then
            iCommand := COMMAND_USE
          else
            iCommand := COMMAND_PICKUP
          else
            iCommand := COMMAND_INVENTORY
    else
    if Distance( FPosition, IO.MTarget ) = 1
      then iCommand := DirectionToCommand( NewDirection( FPosition, IO.MTarget ) )
      else if iLevel.isExplored( IO.MTarget ) then
      begin
        if FPath.Run( FPosition, IO.MTarget, 200) then
        begin
          FPath.Start := FPath.Start.Child;
          FRun.Active := True;
          FPathRun := True;
        end
        else
        begin
          UI.Msg('Can''t get there!');
          continue;
        end;
      end
      else
      begin
        UI.Msg('You don''t know how to get there!');
        continue;
      end;

  if ( iCommand in COMMANDS_MOVE ) or FRun.Active then
  begin
    FLastTargetPos.Create(0,0);
    Inc( FRun.Count );
    if BF_SESSILE in FFlags then
    begin
      UI.Msg('You can''t!');
      FPathRun := False;
      FRun.Stop;
      continue;
    end;

    
    if FRun.Active
      then
        if FPathRun then
        begin
          if (not FPath.Found) or (FPath.Start = nil) or (FPath.Start.Coord = FPosition) then
          begin
            FPathRun := False;
            FRun.Stop;
            Continue;
          end;
          iDir := NewDirection( FPosition, FPath.Start.Coord );
          FPath.Start := FPath.Start.Child;
        end
        else iDir := FRun.Dir
      else iDir := CommandDirection( iCommand );
               
    if iDir.code = 5 then
    begin
      if FRun.Count >= Option_MaxWait then begin FPathRun := False; FRun.Stop; end;
      Dec( FSpeedCount, 1000 );
      Break;
    end;
               
    iMove := FPosition + iDir;
    iMoveResult := TryMove( iMove );
    
    if (not FPathRun) and FRun.Active and (
         ( FRun.Count >= Option_MaxRun ) or
         ( iMoveResult <> MoveOk ) or
         iLevel.cellFlagSet( iMove, CF_NORUN ) or
         (not iLevel.isEmpty(iMove,[EF_NOTELE]))
       ) then
    begin
      FPathRun := False;
      FRun.Stop;
      Continue;
    end;
    
    case iMoveResult of
       MoveBlock :
         begin
           if iLevel.isProperCoord( iMove ) and iLevel.cellFlagSet( iMove, CF_PUSHABLE ) then
             iLevel.CallHook( iMove, Self, CellHook_OnAct )
           else
           begin
             if Option_Blindmode then UI.Msg( 'You bump into a wall.' );
             Continue;
           end;
         end;
       MoveOk :
         begin
           if GraphicsVersion then
           begin
             UI.addScreenMoveAnimation(100,0,iMove);
             UI.addMoveAnimation(100, 0, FUID, Position, iMove, Sprite );
           end;

           Displace( iMove );
           BloodFloor;
           Dec( FSpeedCount, getMoveCost );
           iTempSC := FSpeedCount;
           if Inv.Slot[ efWeapon ] <> nil then
           with Inv.Slot[ efWeapon ] do
             if isRanged then
             begin // Autoreloading
               if Ammo < AmmoMax then
                 if ( ( ( IF_SHOTGUN in FFlags ) and ( BF_SHOTTYMAN in Self.FFlags ) ) or
                    ( ( IF_ROCKET  in FFlags ) and ( BF_ROCKETMAN in Self.FFlags ) ) )
                    and (not (IF_RECHARGE in FFlags)) then
                 begin
                   iItem := Inv.SeekAmmo(AmmoID);
                   if iItem <> nil then
                     Reload( iItem, IF_SINGLERELOAD in FFlags )
                   else if canPackReload then
                     Reload( FInv.Slot[ efWeapon2 ], IF_SINGLERELOAD in FFlags );
                 end;
               if IF_PUMPACTION in FFlags then
                 if (IF_CHAMBEREMPTY in FFlags) and (Ammo <> 0) then
                 begin
                   iLevel.playSound( ID, 'pump', Player.FPosition );
                   Exclude( FFlags, IF_CHAMBEREMPTY );
                   UI.Msg( 'You pump a shell into the shotgun chamber.' );
                 end;
               if (BF_GUNRUNNER in Self.FFlags) and canFire and (Shots < 3) and GetRunning then
               with CreateAutoTarget( Player.Vision ) do
               try
                 FTargetPos := Current;
                 if FTargetPos <> FPosition then
                   ActionFire( False, FTargetPos, Inv.Slot[ efWeapon ] );
               finally
                 Free;
               end;
             end;
           FSpeedCount := iTempSC;
         end;
       MoveBeing : Attack( iLevel.Being[ iMove ] );
       MoveDoor  : iLevel.CallHook( iMove, Self, CellHook_OnAct );
    end;
    if FRun.Active and (not FPathRun) then
      if RunStopNear or
         (iMoveResult <> MoveOk) or
         ((not Option_RunOverItems) and (iLevel.Item[ FPosition ] <> nil)) then
      begin
        FPathRun := False;
        FRun.Stop;
        continue;
      end;
  end
  else
  case iCommand of
    COMMAND_GRIDTOGGLE: if GraphicsVersion then SpriteMap.ToggleGrid;
    COMMAND_WAIT      : Dec( FSpeedCount, 1000 );
    COMMAND_ESCAPE    : if GodMode then begin Doom.SetState( DSQuit ); Exit; end;
    COMMAND_UNLOAD    : doUnLoad;
    COMMAND_ENTER     : iLevel.CallHook( Position, CellHook_OnExit );
    COMMAND_PICKUP    : ActionPickup;
    COMMAND_DROP      : doDrop;
    COMMAND_INVENTORY : if Inv.View then Dec(FSpeedCount,1000);
    COMMAND_EQUIPMENT : if Inv.RunEq then Dec(FSpeedCount,1000);
    COMMAND_OPEN      : doAct( CF_OPENABLE, 'open' );
    COMMAND_CLOSE     : doAct( CF_CLOSABLE, 'close' );
    COMMAND_LOOK      : begin UI.Msg( '-' ); UI.LookMode end;
    COMMAND_ALTFIRE   : doFire( True );
    COMMAND_FIRE      : doFire();
    COMMAND_USE       : ActionUse( nil );
    COMMAND_PLAYERINFO: doScreen;
    COMMAND_QUIT      : doQuit;
    COMMAND_HARDQUIT  : begin
      Option_MenuReturn := False;
      doQuit(True);
    end;
    COMMAND_SAVE      : doSave;
    COMMAND_MSCRUP,
    COMMAND_MSCRDOWN  : if Inv.DoScrollSwap then Dec(FSpeedCount,1000);

    COMMAND_MRIGHT    : if (IO.MTarget = FPosition) or
                           ((Inv.Slot[ efWeapon ] <> nil) and (Inv.Slot[ efWeapon ].isRanged) and (not (Inv.Slot[efWeapon].GetFlag(IF_NOAMMO))) and (Inv.Slot[ efWeapon ].Ammo = 0))  then
                          if iAlt
                            then ActionAltReload
                            else ActionReload
                        else if (Inv.Slot[ efWeapon ] <> nil) and (Inv.Slot[ efWeapon ].isRanged) then
                          if iAlt
                            then ActionAltFire( False, IO.MTarget, Inv.Slot[ efWeapon ] )
                            else ActionFire( False, IO.MTarget, Inv.Slot[ efWeapon ] )
                        else Attack( FPosition + NewDirectionSmooth( FPosition, IO.MTarget ) );
    COMMAND_TRAITS    : IO.RunUILoop( TUITraitsViewer.Create( IO.Root, @FTraits, ExpLevel ) );
    COMMAND_TACTIC    : if not (BF_BERSERK in FFlags) then
                          if FTactic.Change then
                            Dec(FSpeedCount,100);
    COMMAND_RUNMODE   : doRun;

    COMMAND_SWAPWEAPON   : ActionQuickSwap;

    COMMAND_EXAMINENPC   : ExamineNPC;
    COMMAND_EXAMINEITEM  : ExamineItem;

    COMMAND_SOUNDTOGGLE  : SoundOff := not SoundOff;
    COMMAND_MUSICTOGGLE  : begin
                             MusicOff := not MusicOff;
                             if MusicOff then IO.PlayMusic('')
                                         else IO.PlayMusic(iLevel.ID);
                           end;

    255 {COMMAND_INVALID} :;
    COMMAND_YIELD        :;
    else UI.Msg('Unknown command. Press "?" for help.');
  end;
  UI.Focus( FPosition );
  UpdateVisual;
except
  on e : Exception do
  begin
    if CRASHMODE then raise;
    ErrorLogOpen('CRITICAL','Player action exception!');
    ErrorLogWriteln('Error message : '+e.Message);
    ErrorLogClose;
    UI.ErrorReport(e.Message);
    CRASHMODE := True;
  end;
end;
until (FSpeedCount < 5000) or (Doom.State <> DSPlaying);
  CRASHMODE := False;
  LastTurnDodge := False;
  //UI.WaitForAnimation;
  iLevel.CalculateVision( FPosition );
end;

procedure TPlayer.LevelEnter;
begin
  if FHP < (FHPMax div 10) then
    AddHistory('Entering level '+IntToStr(CurrentLevel)+' he was almost dead...');

  FStatistics.Map['damage_on_level'] := 0;
  FStatistics.Map['entry_time'] := FStatistics.GameTime;

  FTargetPos.Create(0,0);
  FTactic.Reset;
  FChainFire := 0;
end;

procedure TPlayer.doScreen;
begin
  IO.RunUILoop( TUIPlayerViewer.Create( IO.Root ) );
end;

procedure TPlayer.ExamineNPC;
var iLevel : TLevel;
    iWhere : TCoord2D;
    iCount  : Word;
begin
  iLevel := TLevel(Parent);
  iCount := 0;
  for iWhere in iLevel.Area do
    if iLevel.isVisible(iWhere) and ( iLevel.Being[iWhere] <> nil ) and (iWhere <> FPosition) then
    with iLevel.Being[iWhere] do
    begin
      Inc(iCount);
      UI.Msg('You see '+ GetName(false) + ' (' + WoundStatus + ') ' + BlindCoord(iWhere-Self.FPosition)+'.');
    end;
  if iCount = 0 then UI.Msg('There are no monsters in sight.');
end;

procedure TPlayer.ExamineItem;
var iLevel : TLevel;
    iWhere : TCoord2D;
    iCount : Word;
begin
  iLevel := TLevel(Parent);
  iCount := 0;
  for iWhere in iLevel.Area do
    if iLevel.isVisible(iWhere) then
      if iLevel.Item[iWhere] <> nil then
      with iLevel.Item[iWhere] do
      begin
        Inc(iCount);
        UI.Msg('You see '+ GetName(false) + ' ' + BlindCoord(iWhere-Self.FPosition)+'.');
      end;
  if iCount = 0 then UI.Msg('There are no items in sight.');
end;

// pieczarki oliwki szynka kielbasa peperoni motzarella //

destructor TPlayer.Destroy;
begin
  FStatistics.Destroy;
  FreeAndNil( FKills );
  inherited Destroy;
end;

procedure TPlayer.IncStatistic(const aStatisticID: AnsiString; aAmount: Integer);
begin
  FStatistics.Map[ aStatisticID ] := FStatistics.Map[ aStatisticID ] + aAmount;
end;

procedure TPlayer.Kill( BloodAmount : DWord; aOverkill : Boolean; aKiller : TBeing; aWeapon : TItem );
var iLevel : TLevel;
begin
  iLevel := TLevel(Parent);
  if (Doom.State <> DSPlaying) and IsPlayer then Exit;

  if not CallHookCheck( Hook_OnDieCheck, [ aOverkill ] ) then
  begin
    HP := Max(1,HP);
    Exit;
  end;

  if (aKiller <> nil) and (not Doom.GameWon) then
  begin
    FKilledBy          := aKiller.ID;
    FKilledMelee       := aKiller.MeleeAttack;
  end;

  Blood( NewDirection(0,0),15 );
  iLevel.DropCorpse( FPosition, GetLuaProtoValue('corpse') );

  if aOverkill
     then iLevel.playSound( 'gib',FPosition )
     else playSound(FSounds.Die);

  UI.WaitForAnimation;

  UI.MsgEnter('You die!...');
  Doom.SetState( DSFinished );

  if NukeActivated > 0 then
  begin
    NukeActivated := 1;
    iLevel.NukeTick;
    UI.WaitForAnimation;
  end;
  WriteMemorial;
end;

procedure TPlayer.WriteMemorial;
var iCopyText : Text;
    iString   : AnsiString;

procedure ScoreCRC(var Score : LongInt);
begin
  if Score < 2000 then Exit;
  while not ((Score mod 277) = 0) do Inc(Score);
  Inc(Score,FExpLevel);
  Inc(Score,CurrentLevel*3);
end;
function lowASCII(c : char) : char; begin if c in ['ù',''] then Exit('.'); Exit(c); end;

begin
  if MemorialWritten then Exit;
  MemorialWritten := True;
  if FScore = -1000 then Exit;

  FScore += Max(FExp + (CurrentLevel * 1000) + Max(FHP,0) * 20,0);
  if FScore < 0 then FScore := 0;
  if GodMode   then FScore := 0;
  if Doom.Difficulty = DIFF_NIGHTMARE then FScore -= FStatistics.GameTime div 500;

  if Doom.GameWon then FScore += FScore div 4;

  FStatistics.Update;

  FScore := Round( FScore * Double(LuaSystem.Get([ 'diff', Doom.Difficulty, 'scorefactor' ])) );

  Doom.CallHook(Hook_OnMortem,[ not NoPlayerRecord ]);
  LuaSystem.ProtectedCall(['DoomRL','award_medals'],[]);
  LuaSystem.ProtectedCall(['DoomRL','register_awards'],[NoPlayerRecord]);

  // FScore
  ScoreCRC(FScore);

  HOF.Add(Name,FScore,FKilledBy,FExpLevel,CurrentLevel,Doom.Challenge);

  Assign(MortemText,SaveFilePath+'mortem.txt');
  Rewrite(MortemText);
  WritingMortem := True;
  LuaSystem.ProtectedCall(['DoomRL','print_mortem'],[]);
  WritingMortem := False;
  Close(MortemText);

  FScore := -1000;

  if Option_MortemArchive then
  begin
    iString := SaveFilePath+'mortem'+PathDelim+ToProperFilename('['+FormatDateTime(Option_TimeStamp,Now)+'] '+Name)+'.txt';
    Assign(iCopyText,iString);
    Log('Writing mortem...: '+iString);
    Rewrite(iCopyText);
    Assign(MortemText,SaveFilePath+'mortem.txt');
    Reset(MortemText);
    
    while not EOF(MortemText) do
    begin
      Readln(MortemText,iString);
      Writeln(iCopyText,iString);
    end;

    Close(iCopyText);
    Close(MortemText);
  end;
end;

function TPlayer.DescribeLever( aItem : TItem ) : string;
begin
  if BF_LEVERSENSE2 in FFlags then Exit('lever ('+LuaSystem.Get(['items',aItem.ID,'desc'],'')+')' );
  if BF_LEVERSENSE1 in FFlags then Exit('lever ('+LuaSystem.Get(['items',aItem.ID,'good'],'')+')' );
  Exit('lever');
end;

procedure TPlayer.AddHistory( const aHistory : Ansistring );
begin
  LuaSystem.ProtectedCall(['player','add_history'],[ Self, aHistory ]);
end;

procedure TPlayer.UpdateVisual;
var Spr : LongInt;
    Gray : TColor;
begin
  Color := LightGray;
  if Inv.Slot[ efTorso ] <> nil then
    Color := Inv.Slot[ efTorso ].Color;
  Gray := NewColor( 200,200,200 );
  FSprite.CosColor := True;
  if Inv.Slot[ efTorso ] <> nil then
  begin
    FSprite.Glow      := Inv.Slot[ efTorso ].Sprite.Glow;
    FSprite.Color     := Inv.Slot[ efTorso ].Sprite.Color;
    FSprite.GlowColor := Inv.Slot[ efTorso ].Sprite.GlowColor;
  end
  else
  begin
    FSprite.Glow     := False;
    FSprite.Color    := GRAY;
  end;
  FSprite.SpriteID := HARDSPRITE_PLAYER;
  if Inv.Slot[ efWeapon ] <> nil then
  begin
    FSprite.SpriteID := LuaSystem.Get( ['items', Inv.Slot[ efWeapon ].ID, 'psprite'], 0 );
    if FSprite.SpriteID <> 0 then Exit;
    // HACK via the spritesheet
    Spr := Inv.Slot[ efWeapon ].Sprite.SpriteID - SpriteCellRow;
    if (Spr <= 12) and (Spr >= 1) then
      FSprite.SpriteID := Spr
    else
      if Inv.Slot[ efWeapon ].isMelee then FSprite.SpriteID := 2 else FSprite.SpriteID := 11;
  end;
end;

function TPlayer.ASCIIMoreCode : AnsiString;
begin
  if (Inv.Slot[efTorso] <> nil) and (UI.ASCII.Exists(Inv.Slot[efTorso].ID)) then
    exit(Inv.Slot[efTorso].ID);
  Exit('player');
end;

procedure TPlayer.SetTired(Value: Boolean);
begin
  if Value then FTactic.Current := TacticTired   else FTactic.Current := TacticNormal;
end;

procedure TPlayer.SetRunning(Value: Boolean);
begin
  if Value then FTactic.Current := TacticRunning else FTactic.Current := TacticTired;
end;

function TPlayer.GetTired: Boolean;
begin
  Exit( FTactic.Current = TacticTired );
end;

function TPlayer.GetRunning: Boolean;
begin
  Exit( FTactic.Current = TacticRunning );
end;

function TPlayer.GetSkillRank: Word;
begin
  Exit( HOF.SkillRank );
end;

function TPlayer.GetExpRank: Word;
begin
  Exit( HOF.ExpRank );
end;

procedure TPlayer.doUpgradeTrait;
begin
  IO.RunUILoop( TUITraitsViewer.Create( IO.Root, @FTraits, ExpLevel, @OnTraitConfirm) );
end;

function lua_player_set_affect(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  Player.FAffects.Add(State.ToId(2),State.ToInteger(3));
  Result := 0;
end;

function lua_player_get_affect_time(L: Plua_State): Integer; cdecl;
var State    : TDoomLuaState;
    Being    : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  State.Push(Player.FAffects.getTime(State.ToId(2)));
  Result := 1;
end;

function lua_player_remove_affect(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  Player.FAffects.Remove(State.ToId(2));
  Result := 0;
end;

function lua_player_is_affect(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  State.Push( ( Being is TPlayer ) and Player.FAffects.IsActive(State.ToId(2)));
  Result := 1;
end;

function lua_player_add_exp(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  Player.addExp(State.ToInteger(2));
  Result := 0;
end;


function lua_player_has_won(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
begin
  State.Init(L);
  State.Push(Doom.GameWon);
  Result := 1;
end;

function lua_player_power_backpack(L: Plua_State): Integer; cdecl;
var State     : TDoomLuaState;
    Being     : TBeing;
    Item      : TItem;
    Node, Temp: TNode;
var List : TItemList;
    Cnt  : Byte;

begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  Include(Player.FFlags,BF_BackPack);

  for Cnt in TItemSlot do
    List[ Cnt ] := nil;

  Cnt := 0;
  for Node in Player do
    if Node is TItem then
      if (Node as TItem).isAmmo then
      begin
        Inc( Cnt );
        List[ Cnt ] := Node as TItem;
      end;

  Temp := TNode.Create;
  for Item in List do
    if Item <> nil then
      Temp.Add( Item );

  for Node in Temp do
    with Node as TItem do
      Player.Inv.AddAmmo( NID, Ammo );

  FreeAndNil( Temp );
  Result := 0;
end;

function lua_player_win(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  Doom.SetState( DSFinished );
  Doom.GameWon := True;
  Result := 0;
end;

function lua_player_continue_game(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  Doom.SetState( DSPlaying );
  Result := 0;
end;

function lua_player_choose_trait(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  Player.doUpgradeTrait();
  Result := 0;
end;

function lua_player_level_up(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  Player.LevelUp();
  Result := 0;
end;

function lua_player_exit(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  if Doom.State <> DSSaving then Doom.SetState( DSNextLevel );
  Player.FSpeedCount := 4000;
  if State.StackSize < 2 then
  begin
    Player.SpecExit   := '';
    Exit(0);
  end;
  if State.IsNumber(2) then
  begin
    Player.SpecExit     := '';
    Player.CurrentLevel := State.ToInteger(2)-1;
    Exit(0);
  end;
  if State.IsString(2) then
  begin
    Player.SpecExit    := State.ToString(2);
    Exit(0);
  end;
  State.Error('Player.exit - bad parameters!');
  Result := 0;
end;

function lua_player_quick_weapon(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  Player.doQuickWeapon(State.ToString(2));
  Result := 0;
end;

function lua_player_set_inv_size(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
    n : byte;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  n := State.ToInteger(2);
  if (n = 0) or (n > High(TItemSlot)) then
    State.Error( 'Inventory size must be in the 1..'+IntToStr(High(TItemSlot))+' range!' );
  Player.InventorySize := n;
  Result := 0;
end;


function lua_player_mortem_print(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  if not WritingMortem then raise Exception.Create('player:mortem_print called in wrong place!');
  Writeln(MortemText, State.ToString(2) );
  Result := 0;
end;

function lua_player_get_trait(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  State.Push( Player.FTraits.Values[ State.ToInteger( 2 ) ] );
  Result := 1;
end;

function lua_player_get_trait_hist(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  State.Push( Player.FTraits.GetHistory );
  Result := 1;
end;

const lua_player_lib : array[0..17] of luaL_Reg = (
      ( name : 'set_affect';      func : @lua_player_set_affect),
      ( name : 'get_affect_time'; func : @lua_player_get_affect_time),
      ( name : 'remove_affect';   func : @lua_player_remove_affect),
      ( name : 'is_affect';       func : @lua_player_is_affect),
      ( name : 'add_exp';         func : @lua_player_add_exp),
      ( name : 'has_won';         func : @lua_player_has_won),
      ( name : 'get_trait';       func : @lua_player_get_trait),
      ( name : 'get_trait_hist';  func : @lua_player_get_trait_hist),
      ( name : 'power_backpack';  func : @lua_player_power_backpack),
      ( name : 'win';             func : @lua_player_win),
      ( name : 'continue_game';   func : @lua_player_continue_game),
      ( name : 'choose_trait';    func : @lua_player_choose_trait),
      ( name : 'level_up';        func : @lua_player_level_up),
      ( name : 'exit';            func : @lua_player_exit),
      ( name : 'quick_weapon';    func : @lua_player_quick_weapon),
      ( name : 'set_inv_size';    func : @lua_player_set_inv_size),
      ( name : 'mortem_print';    func : @lua_player_mortem_print),
      ( name : nil;               func : nil; )
);

class procedure TPlayer.RegisterLuaAPI();
begin
  LuaSystem.Register( 'player', lua_player_lib );
end;

end.
