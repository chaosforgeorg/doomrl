
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

TQuickSlotInfo = record
  UID : TUID;
  ID  : string[32];
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
  FQuickSlots     : array[1..9] of TQuickSlotInfo;

  FLastTargetPos  : TCoord2D;

  constructor Create; reintroduce;
  procedure Initialize; reintroduce;
  constructor CreateFromStream( Stream: TStream ); override;
  procedure WriteToStream( Stream: TStream ); override;
  function PlayerTick : Boolean;
  procedure HandlePostMove; override;
  procedure PreAction;
  function GetRunInput : Byte;
  procedure LevelEnter;
  procedure doUpgradeTrait;
  procedure RegisterKill( const aKilledID : AnsiString; aKiller : TBeing; aWeapon : TItem );
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
  function doChooseTarget( aActionName : string; aRadius : Byte; aLimitRange : Boolean ) : Boolean;
  function RunPath( const aCoord : TCoord2D ) : Boolean;
  procedure ExamineNPC;
  procedure ExamineItem;
  private
  function OnTraitConfirm( aSender : TUIElement ) : Boolean;
  private
  FLastTargetUID  : TUID;
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

uses math, vuid, vpath, variants, vioevent, vgenerics,
     vnode, vcolor, vuielements, vdebug, vluasystem,
     dfmap, dflevel,
     doomhooks, doomio, doomspritemap, doomviews, doombase,
     doomlua, doominventory, doomcommand, doomhelp, doomplayerview;

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
      IO.Msg('You stop running.');
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
    tacticTired   : IO.Msg('Too tired to do that right now.');
    tacticRunning : begin
                      IO.Msg('You stop running.');
                      Current := tacticTired;
                    end;
    tacticNormal  : begin
                      IO.Msg('You start running!');
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
  FillChar( FQuickSlots, SizeOf(FQuickSlots), 0 );

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
  Stream.Write( FQuickSlots,SizeOf( FQuickSlots ) );

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
  Stream.Read( FQuickSlots,SizeOf( FQuickSlots ) );

  FKills          := TKillTable.CreateFromStream( Stream );
  FStatistics.Map := TIntHashMap.CreateFromStream( Stream );
  
  Initialize;
end;

procedure TPlayer.LevelUp;
begin
  Inc( FExpLevel );
  IO.Blink( LightBlue, 100 );
  IO.MsgEnter( 'You advance to level %d!', [ FExpLevel ] );
  if not Doom.CallHookCheck( Hook_OnPreLevelUp, [ FExpLevel ] ) then Exit;
  IO.BloodSlideDown( 20 );
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

procedure TPlayer.ApplyDamage(aDamage: LongInt; aTarget: TBodyTarget; aDamageType: TDamageType; aSource : TItem);
begin
  if aDamage < 0 then Exit;

  FPathRun := False;
  FRun.Stop;
  if BF_INV in FFlags then Exit;
  if ( aDamage >= Max( FHPNom div 3, 10 ) ) then
  begin
    IO.Blink(Red,100);
    if BF_BERSERKER in FFlags then
    begin
      IO.Msg('That hurt! You''re going berserk!');
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

procedure TPlayer.doRun;
var Key : Byte;
begin
  FPathRun := False;
  if FEnemiesInVision > 1 then
  begin
    Fail( 'Can''t run, there are enemies present.',[] );
    Exit;
  end;
  Key := IO.MsgCommandChoice('Run - direction...',INPUT_MOVE+[INPUT_ESCAPE,INPUT_WAIT]);
  if Key = INPUT_ESCAPE then Exit;
  FRun.Start( InputDirection(Key) );
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

function TPlayer.doChooseTarget( aActionName : string; aRadius : Byte; aLimitRange : Boolean ) : boolean;
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

  FTargetPos := IO.ChooseTarget(aActionName, aRadius+1, aLimitRange, iTargets, FChainFire > 0 );
  if FLastTargetPos.X*FLastTargetPos.Y <> 0
     then FPrevTargetPos := FLastTargetPos
     else FPrevTargetPos := FTargetPos;
  FreeAndNil(iTargets);
  if FTargetPos.X = 0 then Exit( False );

  if FTargetPos = FPosition then
  begin
    IO.Msg( 'Find a more constructive way to commit suicide.' );
    Exit( False );
  end;

  FLastTargetUID := 0;
  if iLevel.Being[ FTargetPos ] <> nil then
    FLastTargetUID := iLevel.Being[ FTargetPos ].UID;
  FLastTargetPos := FTargetPos;
  Exit( True );
end;

function TPlayer.RunPath( const aCoord : TCoord2D ) : boolean;
begin
  if FPath.Run( FPosition, aCoord, 200) then
  begin
    FPath.Start := FPath.Start.Child;
    FRun.Active := True;
    FPathRun := True;
    Exit( True );
  end;
  Exit( False );
end;

function TPlayer.OnTraitConfirm ( aSender : TUIElement ) : Boolean;
begin
  with aSender as TUICustomMenu do
    FTraits.Upgrade( Word(SelectedItem.Data) );
  aSender.Parent.Free;
  Exit( True );
end;

function TPlayer.doSave : Boolean;
begin
  //if Doom.Difficulty >= DIFF_NIGHTMARE then Exit( Fail( 'There''s no escape from a NIGHTMARE! Stand and fight like a man!', [] ) );
  if not (CellHook_OnExit in Cells[ TLevel(Parent).Cell[ FPosition ] ].Hooks) then Exit( Fail( 'You can only save the game standing on the stairs to the next level.', [] ) );
  Doom.SetState( DSSaving );
  TLevel(Parent).CallHook( Position, CellHook_OnExit );
end;

procedure TPlayer.doQuit( aNoConfirm : Boolean = False );
begin
  if not aNoConfirm then
  begin
    IO.Msg( LuaSystem.ProtectedCall(['DoomRL','quit_message'],[]) );
    if not IO.MsgConfirm('Are you sure you want to commit suicide?', true) then
    begin
      IO.Msg('Ok, then. Stay and take what''s coming to ya...');
      Exit;
    end;
  end;
  Doom.SetState( DSQuit );
  FScore      := -100000;
end;

function TPlayer.PlayerTick : Boolean;
var iThisUID    : DWord;
begin
  iThisUID := UID;
  TLevel(Parent).CallHook( FPosition, Self, CellHook_OnEnter );
  if UIDs[ iThisUID ] = nil then Exit( False );

  MasterDodge := False;
  FAffects.Tick;
  if Doom.State <> DSPlaying then Exit( False );
  FTactic.Tick;
  Inv.EqTick;
  FLastPos := FPosition;
  FMeleeAttack := False;
  Exit( True );
end;

procedure TPlayer.HandlePostMove;
var iTempSC : LongInt;
    iItem   : TItem;
  function RunStopNear : boolean;
  begin
    if TLevel( Parent ).isProperCoord( FPosition.ifIncX(+1) ) and TLevel( Parent ).cellFlagSet( FPosition.ifIncX(+1), CF_RUNSTOP ) then Exit( True );
    if TLevel( Parent ).isProperCoord( FPosition.ifIncX(-1) ) and TLevel( Parent ).cellFlagSet( FPosition.ifIncX(-1), CF_RUNSTOP ) then Exit( True );
    if TLevel( Parent ).isProperCoord( FPosition.ifIncY(+1) ) and TLevel( Parent ).cellFlagSet( FPosition.ifIncY(+1), CF_RUNSTOP ) then Exit( True );
    if TLevel( Parent ).isProperCoord( FPosition.ifIncY(-1) ) and TLevel( Parent ).cellFlagSet( FPosition.ifIncY(-1), CF_RUNSTOP ) then Exit( True );
    Exit( False );
  end;

begin
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
         TLevel( Parent ).playSound( ID, 'pump', Player.FPosition );
         Exclude( FFlags, IF_CHAMBEREMPTY );
         IO.Msg( 'You pump a shell into the shotgun chamber.' );
       end;
     if (BF_GUNRUNNER in Self.FFlags) and canFire and (Shots < 3) and GetRunning then
     with CreateAutoTarget( Player.Vision ) do
     try
       FTargetPos := Current;
       if FTargetPos <> FPosition then
       begin
         // TODO: fix?
         if Inv.Slot[ efWeapon ].CallHookCheck( Hook_OnFire, [Self,false] ) then
           ActionFire( FTargetPos, Inv.Slot[ efWeapon ] );
       end;
     finally
       Free;
     end;
    end;
  FSpeedCount := iTempSC;

  if FRun.Active and (not FPathRun) then
    if RunStopNear or ((not Option_RunOverItems) and (TLevel( Parent ).Item[ FPosition ] <> nil)) then
    begin
      FPathRun := False;
      FRun.Stop;
    end;
end;

function TPlayer.GetRunInput : Byte;
var iDir : TDirection;
begin
  GetRunInput := 0;
  if FRun.Active then
  begin
    Inc( FRun.Count );
    if BF_SESSILE in FFlags then
    begin
      FPathRun := False;
      FRun.Stop;
      Fail('You can''t!',[] );
      Exit( 0 );
    end;

    if FPathRun then
    begin
      if (not FPath.Found) or (FPath.Start = nil) or (FPath.Start.Coord = FPosition) then
      begin
        FPathRun := False;
        FRun.Stop;
        Exit( 0 );
      end;
      iDir := NewDirection( FPosition, FPath.Start.Coord );
      FPath.Start := FPath.Start.Child;
    end
    else iDir := FRun.Dir;

    if iDir.code = 5 then
    begin
      if FRun.Count >= Option_MaxWait then begin FPathRun := False; FRun.Stop; end;
    end;
    Exit( DirectionToInput( iDir ) );
  end;
end;

procedure TPlayer.PreAction;
var iLevel      : TLevel;
begin
  iLevel := TLevel( Parent );

  if iLevel.Item[ FPosition ] <> nil then
  begin
    if not FPathRun then
      with iLevel.Item[ FPosition ] do
        if isLever then
           IO.Msg('There is a %s here.', [ DescribeLever( iLevel.Item[ FPosition ] ) ] )
        else
          if Flags[ IF_PLURALNAME ]
            then IO.Msg('There are %s lying here.', [ GetName( False ) ] )
            else IO.Msg('There is %s lying here.', [ GetName( False ) ] );
  end;

  FEnemiesInVision := iLevel.BeingsVisible;
  if FEnemiesInVision < 2 then
  begin
    FChainFire := 0;
    if FBersekerLimit > 0 then Dec( FBersekerLimit );
  end;

  if FEnemiesInVision > 1 then
  begin
    FPathRun := False;
    FRun.Stop;
  end;

  if FRun.Active then
  begin
    if IO.CommandEventPending then
    begin
      IO.Msg('Pending stop');
      FPathRun := False;
      FRun.Stop;
      IO.ClearEventBuffer;
    end
    else
    begin
      if not GraphicsVersion then
        IO.Delay( Option_RunDelay );
    end;
  end;
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
      IO.Msg('You see '+ GetName(false) + ' (' + WoundStatus + ') ' + BlindCoord(iWhere-Self.FPosition)+'.');
    end;
  if iCount = 0 then IO.Msg('There are no monsters in sight.');
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
        IO.Msg('You see '+ GetName(false) + ' ' + BlindCoord(iWhere-Self.FPosition)+'.');
      end;
  if iCount = 0 then IO.Msg('There are no items in sight.');
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

  IO.WaitForAnimation;

  IO.MsgEnter('You die!...');
  Doom.SetState( DSFinished );

  if NukeActivated > 0 then
  begin
    NukeActivated := 1;
    iLevel.NukeTick;
    IO.WaitForAnimation;
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

  Assign(MortemText, WritePath + 'mortem.txt' );
  Rewrite(MortemText);
  WritingMortem := True;
  LuaSystem.ProtectedCall(['DoomRL','print_mortem'],[]);
  WritingMortem := False;
  Close(MortemText);

  FScore := -1000;

  if Option_MortemArchive then
  begin
    iString :=  WritePath + 'mortem'+PathDelim+ToProperFilename('['+FormatDateTime(Option_TimeStamp,Now)+'] '+Name)+'.txt';
    Assign(iCopyText,iString);
    Log('Writing mortem...: '+iString);
    Rewrite(iCopyText);
    Assign(MortemText, WritePath + 'mortem.txt');
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
  Include( FSprite.Flags, SF_COSPLAY );
  Exclude( FSprite.Flags, SF_GLOW );
  if Inv.Slot[ efTorso ] <> nil then
  begin
    if SF_GLOW in Inv.Slot[ efTorso ].Sprite.Flags then
      Include( FSprite.Flags, SF_GLOW );
    FSprite.Color     := Inv.Slot[ efTorso ].Sprite.Color;
    FSprite.GlowColor := Inv.Slot[ efTorso ].Sprite.GlowColor;
  end
  else
    FSprite.Color    := GRAY;
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
  if (Inv.Slot[efTorso] <> nil) and (IO.NewASCII.Exists(Inv.Slot[efTorso].ID)) then
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
  IO.PushLayer( TPlayerView.CreateTrait( False ) );
//  IO.RunUILoop( TUITraitsViewer.Create( IO.Root, @FTraits, ExpLevel, @OnTraitConfirm) );
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
  Player.ActionQuickWeapon(State.ToString(2));
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
