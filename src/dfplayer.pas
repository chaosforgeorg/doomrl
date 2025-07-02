
{$INCLUDE doomrl.inc}
unit dfplayer;
interface
uses classes, sysutils,
     vuielement,vpath, vutil, vrltools, vuitypes,
     dfbeing, dfhof, dfdata, dfitem, dfaffect,
     doomtrait, doomkeybindings, drlstatistics, drlmultimove;


type TQuickSlotInfo = record
  UID : TUID;
  ID  : string[32];
end;

{ TPlayer }

type TPlayer = class(TBeing)
  CurrentLevel    : Word;

  SpecExit        : string[20];
  NukeActivated   : Word;

  InventorySize   : Byte;
  MasterDodge     : Boolean;
  FKills          : TKillTable;
  FKillMax        : DWord;
  FKillCount      : DWord;

  FQuickSlots     : array[1..9] of TQuickSlotInfo;

  constructor Create; reintroduce;
  procedure Initialize; reintroduce;
  constructor CreateFromStream( Stream: TStream ); override;
  procedure WriteToStream( Stream: TStream ); override;
  function CallHook( aHook : Byte; const aParams : array of Const ) : Boolean; override;
  function CallHookCheck( aHook : Byte; const aParams : array of Const ) : Boolean; override;
  function CallHookCan( aHook : Byte; const aParams : array of Const ) : Boolean; override;
  function GetBonus( aHook : Byte; const aParams : array of Const ) : Integer; override;
  function GetBonusMul( aHook : Byte; const aParams : array of Const ) : Single; override;
  function PlayerTick : Boolean;
  procedure HandlePostMove; override;
  procedure PreAction;
  procedure PostAction;
  function GetMultiMoveInput : TInputKey;
  procedure LevelEnter;
  procedure doUpgradeTrait;
  procedure RegisterKill( const aKilledID : AnsiString; aKiller : TBeing; aWeapon : TItem; aUnique : Boolean );
  procedure ApplyDamage( aDamage : LongInt; aTarget : TBodyTarget; aDamageType : TDamageType; aSource : TItem; aDelay : Integer ); override;
  procedure LevelUp;
  procedure AddExp( aAmount : LongInt );
  procedure WriteMemorial;
  destructor Destroy; override;
  procedure Kill( aBloodAmount : DWord; aOverkill : Boolean; aKiller : TBeing; aWeapon : TItem; aDelay : Integer ); override;
  procedure AddHistory( const aHistory : Ansistring );
  class procedure RegisterLuaAPI();
  procedure UpdateVisual;
  function ASCIIMoreCode : AnsiString; override;
  function RunPath( const aCoord : TCoord2D ) : Boolean;
  procedure ExamineNPC;
  procedure ExamineItem;
private
  FExp            : LongInt;
  FExpLevel       : Byte;
  FKlass          : Byte;
  FScore          : LongInt;
  FExpFactor      : Real;
  FEnemiesInVision: Word;
  FKilledBy       : AnsiString;
  FKilledMelee    : Boolean;
  FLastTurnDodge  : Boolean;

  FTraits         : TTraits;
  FStatistics     : TStatistics;
  FMultiMove      : TMultiMove;
private
  function GetSkillRank : Word;
  function GetExpRank : Word;
public
  property MultiMove       : TMultiMove  read FMultiMove;
  property Statistics      : TStatistics read FStatistics;
  property Traits          : TTraits     read FTraits;
published
  property KilledBy        : AnsiString read FKilledBy;
  property KilledMelee     : Boolean    read FKilledMelee;
  property LastTurnDodge   : Boolean    read FLastTurnDodge write FLastTurnDodge;
  property Exp             : LongInt    read FExp           write FExp;
  property ExpLevel        : Byte       read FExpLevel      write FExpLevel;
  property NukeTime        : Word       read NukeActivated  write NukeActivated;
  property Klass           : Byte       read FKlass         write FKlass;
  property ExpFactor       : Real       read FExpFactor     write FExpFactor;
  property SkillRank       : Word       read GetSkillRank;
  property ExpRank         : Word       read GetExpRank;
  property Score           : LongInt    read FScore         write FScore;
  property Depth           : Word       read CurrentLevel;
  property EnemiesInVision : Word       read FEnemiesInVision;
end;

var Player     : TPlayer;
    MortemData : TUIStringArray = nil;

implementation

uses math, vuid, variants, vioevent, vgenerics,
     vnode, vcolor, vdebug, vluasystem, vluastate, vtig,
     dfmap, dflevel,
     doomhooks, doomio, doomspritemap, doombase,
     doomlua, doominventory, doomplayerview, doomhudviews;

constructor TPlayer.Create;
var iState : TLuaState;
begin
  inherited Create('soldier');

  FTraits    := TTraits.Create;
  FKills     := TKillTable.Create;
  FKillMax   := 0;
  FKillCount := 0;

  CurrentLevel  := 0;
  StatusEffect  := StatusNormal;
  FStatistics   := TStatistics.Create;
  FScore        := 0;
  SpecExit      := '';
  NukeActivated := 0;
  FExpLevel   := 1;
  FKlass      := 1;
  FExp        := ExpTable[ FExpLevel ];

  InventorySize := High( TItemSlot );
  FExpFactor := 1.0;

  Initialize;
  iState.Init( doombase.Lua.Raw );
  iState.ClearLuaProperties( Self );

  FillChar( FQuickSlots, SizeOf(FQuickSlots), 0 );
  CallHook( Hook_OnCreate, [] );
end;

procedure TPlayer.Initialize;
begin
  FKilledBy       := '';
  FKilledMelee    := False;

  FEnemiesInVision:= 0;
  FMultiMove      := TMultiMove.Create;
  FPath           := TPathFinder.Create(Self);
  MemorialWritten := False;
  MasterDodge     := False;
  FLastTurnDodge  := False;

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
  Stream.WriteByte( FKlass );
  Stream.WriteDWord( FExp );
  Stream.WriteDWord( FScore );
  Stream.WriteDWord( FKillMax );
  Stream.WriteDWord( FKillCount );

  Stream.Write( FLastTurnDodge, SizeOf( FLastTurnDodge ) );
  Stream.Write( FExpFactor,     SizeOf( FExpFactor ) );
  Stream.Write( FQuickSlots,    SizeOf( FQuickSlots ) );

  FTraits.WriteToStream( Stream );
  FKills.WriteToStream( Stream );
  FStatistics.WriteToStream( Stream );
end;

constructor TPlayer.CreateFromStream ( Stream : TStream ) ;
begin
  inherited CreateFromStream( Stream );

  SpecExit       := Stream.ReadAnsiString();
  CurrentLevel   := Stream.ReadWord();
  NukeActivated  := Stream.ReadWord();
  InventorySize  := Stream.ReadByte();
  FExpLevel      := Stream.ReadByte();
  FKlass         := Stream.ReadByte();
  FExp           := Stream.ReadDWord();
  FScore         := Stream.ReadDWord();
  FKillMax       := Stream.ReadDWord();
  FKillCount     := Stream.ReadDWord();

  Stream.Read( FLastTurnDodge, SizeOf( FLastTurnDodge ) );
  Stream.Read( FExpFactor,     SizeOf( FExpFactor ) );
  Stream.Read( FQuickSlots,    SizeOf( FQuickSlots ) );

  FTraits         := TTraits.CreateFromStream( Stream );
  FKills          := TKillTable.CreateFromStream( Stream );
  FStatistics     := TStatistics.CreateFromStream( Stream );

  Initialize;
end;

function TPlayer.CallHook( aHook : Byte; const aParams : array of Const ) : Boolean;
begin
  CallHook := FTraits.CallHook( aHook, aParams );
  if inherited CallHook( aHook, aParams ) then
    CallHook := True;
end;

function TPlayer.CallHookCheck( aHook : Byte; const aParams : array of Const ) : Boolean;
begin
  if not ( inherited CallHookCheck( aHook, aParams ) ) then Exit ( False );
  Exit( FTraits.CallHookCheck( aHook, aParams ) );
end;

function TPlayer.CallHookCan( aHook : Byte; const aParams : array of Const ) : Boolean;
begin
  if ( inherited CallHookCan( aHook, aParams ) ) then Exit ( true );
  Exit( FTraits.CallHookCan( aHook, aParams ) );
end;

function TPlayer.GetBonus( aHook : Byte; const aParams : array of Const ) : Integer;
begin
  GetBonus := inherited GetBonus( aHook, aParams );
  GetBonus += FTraits.GetBonus( aHook, aParams );
end;

function TPlayer.GetBonusMul( aHook : Byte; const aParams : array of Const ) : Single;
begin
  GetBonusMul := inherited GetBonusMul( aHook, aParams );
  GetBonusMul *= FTraits.GetBonusMul( aHook, aParams );
end;

procedure TPlayer.LevelUp;
begin
  Inc( FExpLevel );
  IO.Blink( LightBlue, 100 );

  IO.Msg( 'You advance to level %d!', [ FExpLevel ] );
  IO.PushLayer( TMoreLayer.Create( False ) );
  IO.WaitForLayer( False );

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

procedure TPlayer.ApplyDamage(aDamage: LongInt; aTarget: TBodyTarget; aDamageType: TDamageType; aSource : TItem; aDelay : Integer );
begin
  if aDamage < 0 then Exit;
  if BF_INV in FFlags then Exit;
  FMultiMove.Stop;
  Doom.DamagedLastTurn := True;
  if ( aDamage >= Max( FHPMax div 3, 10 ) ) then
    IO.Blink( Red, 100 );

  if aDamage > 0 then FKills.DamageTaken;
  inherited ApplyDamage(aDamage, aTarget, aDamageType, aSource, aDelay );
end;

procedure TPlayer.RegisterKill ( const aKilledID : AnsiString; aKiller : TBeing; aWeapon : TItem; aUnique : Boolean ) ;
var iKillClass : AnsiString;
begin
  iKillClass := 'other';
  if ( aKiller = Self ) and ( TLevel(Parent).ActiveBeing = Self ) then
  begin
    if FMeleeAttack   then iKillClass := 'melee';
    if aWeapon <> nil then iKillClass := aWeapon.ID;
  end;
  FKills.Add( aKilledID, iKillClass );
  if aUnique then Inc( FKillCount );
end;

function TPlayer.RunPath( const aCoord : TCoord2D ) : boolean;
begin
  FPathHazards := [];
  FPathClear   := [];
  if FPath.Run( FPosition, aCoord, 200) then
  begin
    FMultiMove.Start( FPath );
    Exit( True );
  end;
  Exit( False );
end;

function TPlayer.PlayerTick : Boolean;
var iThisUID    : DWord;
begin
  iThisUID := UID;
  TLevel(Parent).CallHook( FPosition, Self, CellHook_OnEnter );
  if UIDs[ iThisUID ] = nil then Exit( False );

  MasterDodge := False;
  FAffects.OnUpdate;
  if Doom.State <> DSPlaying then Exit( False );
  Inv.EqTick;
  FLastPos := FPosition;
  FMeleeAttack := False;
  Exit( True );
end;

procedure TPlayer.HandlePostMove;

  function RunStopNear : boolean;
  begin
    if TLevel( Parent ).isProperCoord( FPosition.ifIncX(+1) ) and TLevel( Parent ).cellFlagSet( FPosition.ifIncX(+1), CF_RUNSTOP ) then Exit( True );
    if TLevel( Parent ).isProperCoord( FPosition.ifIncX(-1) ) and TLevel( Parent ).cellFlagSet( FPosition.ifIncX(-1), CF_RUNSTOP ) then Exit( True );
    if TLevel( Parent ).isProperCoord( FPosition.ifIncY(+1) ) and TLevel( Parent ).cellFlagSet( FPosition.ifIncY(+1), CF_RUNSTOP ) then Exit( True );
    if TLevel( Parent ).isProperCoord( FPosition.ifIncY(-1) ) and TLevel( Parent ).cellFlagSet( FPosition.ifIncY(-1), CF_RUNSTOP ) then Exit( True );
    Exit( False );
  end;

begin
  inherited HandlePostMove;
  if FMultiMove.IsRepeat then
    if RunStopNear or ((not Setting_RunOverItems) and (TLevel( Parent ).Item[ FPosition ] <> nil)) then
      FMultiMove.Stop;
end;

function TPlayer.GetMultiMoveInput : TInputKey;
begin
  GetMultiMoveInput := INPUT_NONE;
  if FMultiMove.Active then
  begin
    if BF_SESSILE in FFlags then
    begin
      FMultiMove.Stop;
      Fail('You can''t!',[] );
      Exit( INPUT_NONE );
    end;

    Exit( FMultiMove.CalculateInput( FPosition ) );
  end;
end;

procedure TPlayer.PreAction;
var iLevel      : TLevel;
begin
  iLevel := TLevel( Parent );

  if iLevel.Item[ FPosition ] <> nil then
  begin
    if not FMultiMove.IsPath then
      IO.Msg( iLevel.Item[ FPosition ].GetExtName( True ) );
  end;

  FEnemiesInVision := iLevel.EnemiesVisible;
  if FEnemiesInVision > 0
    then FMultiMove.Stop
    else FChainFire := 0;

  if FMultiMove.Active then
  begin
    if IO.CommandEventPending then
    begin
      IO.Msg('Stop.');
      FMultiMove.Stop;
      IO.ClearEventBuffer;
    end
    else
    begin
      if not GraphicsVersion then
        IO.Delay( Option_RunDelay );
    end;
  end;

  CallHook(Hook_OnPreAction,[]);
end;

procedure TPlayer.PostAction;
begin
  CallHook(Hook_OnPostAction,[]);
  if Doom.State <> DSPlaying then Exit;
  FLastTurnDodge := False;
  UpdateVisual;
end;

procedure TPlayer.LevelEnter;
begin
  if FHP < (FHPMax div 10) then
    AddHistory('Entering @1 he was almost dead...');

  FStatistics.OnLevelEnter;

  FTargetPos.Create(0,0);
  FChainFire := 0;
end;

procedure TPlayer.ExamineNPC;
var iLevel : TLevel;
    iWhere : TCoord2D;
    iCount : Word;
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
  FreeAndNil( FStatistics );
  FreeAndNil( FKills );
  FreeAndNil( FMultiMove );
  inherited Destroy;
end;

procedure TPlayer.Kill( aBloodAmount : DWord; aOverkill : Boolean; aKiller : TBeing; aWeapon : TItem; aDelay : Integer );
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
     else PlaySound( 'die' );

  IO.addKillAnimation( 1000, aDelay, Self );
  IO.WaitForAnimation;
  FAnimCount := 1;

  begin
    IO.Msg('You die!...');
    IO.PushLayer( TMoreLayer.Create( False ) );
    IO.WaitForLayer( False );
  end;
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
var iCopyText   : Text;
    iMortemText : Text;
    iString     : AnsiString;

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
  LuaSystem.ProtectedCall([CoreModuleID,'RunAwards'],[NoPlayerRecord]);

  // FScore
  ScoreCRC(FScore);

  HOF.Add(Name,FScore,FKilledBy,FExpLevel,CurrentLevel,Doom.Challenge,Doom.Level.Abbr);

  if Assigned( MortemData ) then
  begin
    Log( LOGERROR, 'Mortem data not cleared!');
    FreeAndNil( MortemData );
  end;
  MortemData := TUIStringArray.Create;
  LuaSystem.ProtectedCall([CoreModuleID,'RunPrintMortem'],[]);
  Assign(iMortemText, ModuleUserPath + 'mortem.txt' );
  Rewrite(iMortemText);
  for iString in MortemData do
    Writeln( iMortemText, VTIG_StripTags( iString ) );
  Close(iMortemText);

  FScore := -1000;

  if Option_MortemArchive then
  begin
    iString :=  ModuleUserPath + 'mortem'+PathDelim+ToProperFilename('['+FormatDateTime(Option_TimeStamp,Now)+'] '+Name)+'.txt';
    Assign(iCopyText,iString);
    Log('Writing mortem...: '+iString);
    Rewrite(iCopyText);
    Assign(iMortemText, ModuleUserPath + 'mortem.txt');
    Reset(iMortemText);
    
    while not EOF(iMortemText) do
    begin
      Readln(iMortemText,iString);
      Writeln(iCopyText,iString);
    end;

    Close(iCopyText);
    Close(iMortemText);
  end;
end;

procedure TPlayer.AddHistory( const aHistory : Ansistring );
begin
  LuaSystem.ProtectedCall(['player','add_history'],[ Self, aHistory ]);
end;

procedure TPlayer.UpdateVisual;
var Spr       : LongInt;
    Gray      : TColor;
    iWeapon   : TItem;
    iSpMod    : Integer;
    iPDSprite : Integer;
begin
  Color  := LightGray;
  iSpMod := 0;
  if Inv.Slot[ efTorso ] <> nil then
    Color := Inv.Slot[ efTorso ].Color;
  Gray := NewColor( 200,200,200 );
  Include( FSprite.Flags, SF_COSPLAY );
  FSprite.GlowColor := ColorZero;
  FSprite.Color     := GRAY;
  if Inv.Slot[ efTorso ] <> nil then
  begin
    if Inv.Slot[ efTorso ].PGlowColor.A > 0 then
      FSprite.GlowColor := Inv.Slot[ efTorso ].PGlowColor;
    FSprite.Color     := Inv.Slot[ efTorso ].PCosColor;
    iSpMod            := Inv.Slot[ efTorso ].SpriteMod;
  end;
  iWeapon := Inv.Slot[ efWeapon ];
  if iWeapon <> nil then
  begin
    iPDSprite := LuaSystem.Get( ['items', iWeapon.ID, 'pdsprite'], 0 );
    if ( iPDSprite <> 0 ) and ( canDualWield )
      then FSprite.SpriteID[0] := iPDSprite
      else FSprite.SpriteID[0] := LuaSystem.Get( ['items', iWeapon.ID, 'psprite'], 0 );
    if FSprite.SpriteID[0] <> 0 then
    begin
      FSprite.SpriteID[0] += iSpMod;
      Exit;
    end;
    // HACK via the spritesheet
    Spr := Inv.Slot[ efWeapon ].Sprite.SpriteID[0] - SpriteCellRow;
    if (Spr <= 12) and (Spr >= 1) then
      FSprite.SpriteID[0] := Spr
    else
      if Inv.Slot[ efWeapon ].isMelee then FSprite.SpriteID[0] := 2 else FSprite.SpriteID[0] := 11;
  end
  else
    FSprite.SpriteID[0] := LuaSystem.Get( ['beings', ID, 'sprite'], 0 ) + iSpMod;
end;

function TPlayer.ASCIIMoreCode : AnsiString;
begin
  if (Inv.Slot[efTorso] <> nil) and (IO.ASCII.Exists(Inv.Slot[efTorso].ID)) then
    exit(Inv.Slot[efTorso].ID);
  Exit('player');
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
  IO.WaitForLayer( True );
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

function lua_player_resort_ammo(L: Plua_State): Integer; cdecl;
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
  if not Assigned( MortemData ) then raise Exception.Create('player:mortem_print called in wrong place!');
  MortemData.Push( State.ToString(2) );
  Result := 0;
end;

function lua_player_get_trait(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  State.Push( Player.Traits[ State.ToInteger( 2 ) ] );
  Result := 1;
end;

function lua_player_get_trait_hist(L: Plua_State): Integer; cdecl;
var State   : TDoomLuaState;
    Being   : TBeing;
begin
  State.Init(L);
  Being := State.ToObject(1) as TBeing;
  if not (Being is TPlayer) then Exit(0);
  State.Push( Player.Traits.GetHistory );
  Result := 1;
end;

const lua_player_lib : array[0..13] of luaL_Reg = (
      ( name : 'add_exp';         func : @lua_player_add_exp),
      ( name : 'has_won';         func : @lua_player_has_won),
      ( name : 'get_trait';       func : @lua_player_get_trait),
      ( name : 'get_trait_hist';  func : @lua_player_get_trait_hist),
      ( name : 'resort_ammo';     func : @lua_player_resort_ammo),
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
