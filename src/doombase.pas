{$INCLUDE doomrl.inc}
unit doombase;
interface

uses vsystems, vsystem, vutil, vuid, vrltools, vluasystem, vioevent,
     dflevel, dfdata, dfhof,
     doomhooks, doomlua, doommodule, doommenuview;

type TDoomState = ( DSStart,      DSMenu,    DSLoading,
                    DSPlaying,    DSSaving,  DSNextLevel,
                    DSQuit,       DSFinished );

type

{ TDoom }

TDoom = class(TSystem)
       Difficulty    : Byte;
       Challenge     : AnsiString;
       SChallenge    : AnsiString;
       ArchAngel     : Boolean;
       DataLoaded    : Boolean;
       GameWon       : Boolean;
       GameType      : TDoomGameType;
       Module        : TDoomModule;
       NVersion      : TVersion;
       ModuleID      : AnsiString;
       constructor Create; override;
       procedure CreateIO;
       procedure Apply( aResult : TMenuResult );
       procedure Load;
       procedure UnLoad;
       function LoadSaveFile : Boolean;
       procedure WriteSaveFile;
       function SaveExists : Boolean;
       procedure SetupLuaConstants;
       function Action( aCommand : Byte ) : Boolean;
       procedure Run;
       destructor Destroy; override;
       procedure ModuleMainHook( Hook : AnsiString; const Params : array of Const );
       procedure CallHook( Hook : Byte; const Params : array of Const );
       function  CallHookCheck( Hook : Byte; const Params : array of Const ) : Boolean;
       procedure LoadChallenge;
       procedure SetState( NewState : TDoomState );
     private
       function HandleMouseEvent( aEvent : TIOEvent ) : Boolean;
       function HandleKeyEvent( aEvent : TIOEvent ) : Boolean;
       procedure PreAction;
       function ModuleHookTable( Hook : Byte ) : AnsiString;
       procedure LoadModule( Base : Boolean );
       procedure DoomFirst;
       procedure RunSingle;
       procedure CreatePlayer( aResult : TMenuResult );
     private
       FState           : TDoomState;
       FLevel           : TLevel;
       FCoreHooks       : TFlags;
       FChallengeHooks  : TFlags;
       FSChallengeHooks : TFlags;
       FModuleHooks     : TFlags;
     public
       property Level : TLevel read FLevel;
       property ChalHooks : TFlags read FChallengeHooks;
       property ModuleHooks : TFlags read FModuleHooks;
       property State : TDoomState read FState;
     end;

var Doom : TDoom;
var Lua : TDoomLua;


implementation

uses Classes, SysUtils,
     vdebug, viotypes,
     dfmap,
     dfoutput, doomio, zstream,
     doomspritemap, // remove
     doomhelp, doomconfig, doomviews, dfplayer;


procedure TDoom.ModuleMainHook(Hook: AnsiString; const Params: array of const);
begin
  if not LuaSystem.Defined([ ModuleID, Hook ]) then Exit;
  Lua.ProtectedCall( [ ModuleID, Hook ], Params );
end;


procedure TDoom.CallHook( Hook : Byte; const Params : array of const ) ;
begin
  if (Hook in FModuleHooks) then LuaSystem.ProtectedCall([ModuleHookTable(Hook),HookNames[Hook]],Params);
  if (Challenge <> '')  and (Hook in FChallengeHooks) then LuaSystem.ProtectedCall(['chal',Challenge,HookNames[Hook]],Params);
  if (SChallenge <> '') and (Hook in FSChallengeHooks) then LuaSystem.ProtectedCall(['chal',SChallenge,HookNames[Hook]],Params);
  if (Hook in FCoreHooks) then LuaSystem.ProtectedCall(['core',HookNames[Hook]],Params);
end;

function TDoom.CallHookCheck ( Hook : Byte; const Params : array of const ) : Boolean;
begin
  if (Hook in FCoreHooks) then if not LuaSystem.ProtectedCall(['core',HookNames[Hook]],Params) then Exit( False );
  if (Challenge <> '') and (Hook in FChallengeHooks) then if not LuaSystem.ProtectedCall(['chal',Challenge,HookNames[Hook]],Params) then Exit( False );
  if (SChallenge <> '') and (Hook in FSChallengeHooks) then if not LuaSystem.ProtectedCall(['chal',SChallenge,HookNames[Hook]],Params) then Exit( False );
  if Hook in FModuleHooks then if not LuaSystem.ProtectedCall([ModuleHookTable(Hook),HookNames[Hook]],Params) then Exit( False );
  Exit( True );
end;

procedure TDoom.LoadChallenge;
begin
  FChallengeHooks := [];
  FSChallengeHooks := [];
  if Challenge <> '' then
    FChallengeHooks := LoadHooks( ['chal',Challenge] ) * GlobalHooks;
  if SChallenge <> '' then
    FSChallengeHooks := LoadHooks( ['chal',SChallenge] ) * GlobalHooks;
end;

procedure TDoom.SetState(NewState: TDoomState);
begin
  FState := NewState;
end;

function TDoom.ModuleHookTable ( Hook : Byte ) : AnsiString;
begin
  if Hook in GameTypeHooks[ GameType ] then Exit( ModuleID ) else Exit( 'DoomRL' );
end;

procedure TDoom.LoadModule( Base : Boolean );
begin
  if ModuleID <> 'DoomRL' then Lua.LoadModule( Module );
  FModuleHooks := LoadHooks( ['DoomRL'] ) * GlobalHooks;
  if GameType <> GameStandard then
  begin
    Exclude( FModuleHooks, Hook_OnLoad );
    Exclude( FModuleHooks, Hook_OnLoaded );
    Exclude( FModuleHooks, Hook_OnIntro );
    FModuleHooks += ( LoadHooks( [ ModuleID ] ) * GameTypeHooks[ GameType ] );
  end;
  if Base then CallHook( Hook_OnLoadBase, [] );
  CallHook( Hook_OnLoad, [] );
end;

procedure TDoom.Load;
begin
  FreeAndNil( Config );
  IO.LoadStart;
  ColorOverrides := TIntHashMap.Create( );
  Config := TDoomConfig.Create( ConfigurationPath, True );
  IO.Configure( Config, True );

  FCoreHooks := [];
  FModuleHooks := [];
  FChallengeHooks := [];
  FSChallengeHooks := [];
  Cells := TCells.Create;
  Help := THelp.Create;

  SetState( DSLoading );
  LuaSystem := Systems.Add(TDoomLua.Create()) as TLuaSystem;
  LuaSystem.CallDefaultResult := True;
  Modules.RegisterAwards( LuaSystem.Raw );
  FCoreHooks := LoadHooks( [ 'core' ] ) * GlobalHooks;
  ModuleID := 'DoomRL';
  UI.CreateMessageWriter( Config );
  LoadModule( True );

  if GodMode and FileExists( WritePath + 'god.lua') then
    Lua.LoadFile( WritePath + 'god.lua');
  HOF.Init;
  FLevel := TLevel.Create;
  if not GraphicsVersion then
    UI.GameUI.Map.SetMap( FLevel );
  DataLoaded := True;
  IO.LoadStop;
end;

procedure TDoom.UnLoad;
begin
  DataLoaded := False;
  HOF.Done;
  FreeAndNil(LuaSystem);
  FreeAndNil(Config);
  FreeAndNil(Help);
  FreeAndNil(FLevel);
  FreeAndNil(ColorOverrides);
  FreeAndNil(Cells);
end;

constructor TDoom.Create;
begin
  inherited Create;
  ModuleID   := 'DoomRL';
  GameType   := GameStandard;
  GameWon    := False;
  DataLoaded := False;
  SetState( DSStart );
  FModuleHooks := [];
  FChallengeHooks := [];
  NVersion := ArrayToVersion(VERSION_ARRAY);
  Log( VersionToString( NVersion ) );
end;

procedure TDoom.CreateIO;
begin
  IO := TDoomIO.Create;
  ProgramRealTime := MSecNow();
  IO.Configure( Config );
end;

procedure TDoom.Apply ( aResult : TMenuResult ) ;
begin
  if aResult.Quit   then SetState( DSQuit );
  if aResult.Loaded then Exit;
  Difficulty     := aResult.Difficulty;
  Challenge      := aResult.Challenge;
  ArchAngel      := aResult.ArchAngel;
  SChallenge     := aResult.SChallenge;
  GameType       := aResult.GameType;
  ModuleID       := aResult.ModuleID;

  if aResult.Module <> nil then
  begin
    NoPlayerRecord := True;
    NoScoreRecord  := True;
    Module := aResult.Module;
  end;

  // Set Klass   Klass      : Byte;
  // Upgrade trait -- Trait : Byte;
  // Set Name    Name       : AnsiString;
end;

procedure TDoom.PreAction;
begin
  FLevel.CalculateVision( Player.Position );
  StatusEffect := Player.FAffects.getEffect;
  UI.Focus( Player.Position );
  if GraphicsVersion then
    UI.GameUI.UpdateMinimap;
  Player.PreAction;
end;

function TDoom.Action( aCommand : Byte ) : Boolean;
begin
  UI.MsgUpDate;
  Player.Action( aCommand );
  if State <> DSPlaying then Exit;
  UI.Focus( Player.Position );
  Player.UpdateVisual;
  while (Player.SCount < 5000) and (State = DSPlaying) do
  begin
    FLevel.CalculateVision( Player.Position );
    FLevel.Tick;
    UI.WaitForAnimation;
    if not Player.PlayerTick then Exit( True );
  end;
  PreAction;
  Exit( True );
end;

function TDoom.HandleMouseEvent( aEvent : TIOEvent ) : Boolean;
var iPoint : TIOPoint;
begin
  iPoint := SpriteMap.DevicePointToCoord( aEvent.Mouse.Pos );
  IO.MTarget.Create( iPoint.X, iPoint.Y );
  if Doom.Level.isProperCoord( IO.MTarget ) then
    case aEvent.Mouse.Button of
      VMB_BUTTON_LEFT     : Exit( Action( INPUT_MLEFT ) );
      VMB_BUTTON_MIDDLE   : Exit( Action( INPUT_MMIDDLE ) );
      VMB_BUTTON_RIGHT    : Exit( Action( INPUT_MRIGHT ) );
      VMB_WHEEL_UP        : Exit( Action( INPUT_MSCRUP ) );
      VMB_WHEEL_DOWN      : Exit( Action( INPUT_MSCRDOWN ) );
    end;
  Exit( False );
end;

function TDoom.HandleKeyEvent( aEvent : TIOEvent ) : Boolean;
var iCommand : Byte;
begin
  IO.KeyCode := IOKeyEventToIOKeyCode( aEvent.Key );
  iCommand := Config.Commands[ IO.KeyCode ];
  if ( iCommand = 255 ) then // GodMode Keys
  begin
    Config.RunKey( IO.KeyCode );
    Action( 0 );
    Exit( True );
  end;
  if iCommand > 0 then
    Exit( Action( iCommand ) );
  Exit( False );
end;


procedure TDoom.Run;
var iRank       : THOFRank;
    iResult     : TMenuResult;
    iEvent      : TIOEvent;
begin
  iResult    := TMenuResult.Create;
  Doom.Load;

  if not FileExists( WritePath + 'doom.prc' ) then DoomFirst;

  IO.RunUILoop( TMainMenuViewer.CreateMain( IO.Root ) );
  if FState <> DSQuit then
    IO.RunUILoop( TMainMenuViewer.CreateDonator( IO.Root ) );
  if FState <> DSQuit then
repeat
  if not DataLoaded then
    Doom.Load;
  IO.LoadStop;

  StatusEffect   := StatusNormal;
  Difficulty     := 2;
  ArchAngel      := False;
  Challenge      := '';
  SChallenge     := '';
  GameWon        := False;
  Module         := nil;
  NoPlayerRecord := False;
  NoScoreRecord  := False;

  UI.ClearAllMessages;

  IO.PlayMusicOnce('start');
  SetState( DSMenu );
  iResult.Reset; // TODO : could reuse for same game!
  IO.RunUILoop( TMainMenuViewer.Create( IO.Root, iResult ) );
  Apply( iResult );
  if State = DSQuit then Break;

  if iResult.Loaded then
  begin
    SetState( DSLoading );
    SetupLuaConstants;
  end
  else
  begin
    SetupLuaConstants;
    LoadChallenge;
    CreatePlayer( iResult );
  end;

  LuaSystem.SetValue('level', Level );

  if GameType = GameEpisode then LoadModule( False );

  if (not (State = DSLoading)) then
    CallHookCheck( Hook_OnIntro, [Option_NoIntro] );


  if (GameType <> GameSingle) and (State <> DSLoading) then
  begin
    CallHook( Hook_OnCreateEpisode, [] );
  end;
  CallHook( Hook_OnLoaded, [State = DSLoading] );

  GameRealTime := MSecNow();
  try
  repeat
    if Player.NukeActivated > 0 then
    begin
      UI.Msg('You hear a gigantic explosion above!');
      Inc(Player.FScore,1000);
      Player.IncStatistic('levels_nuked');
      Player.NukeActivated := 0;
    end;

    with Player do
    begin
      FStatistics.Update;
    end;

    if GameType = GameSingle then
       RunSingle
    else
    begin
      if Player.SpecExit = '' then
        Inc(Player.CurrentLevel)
      else
        Player.IncStatistic('bonus_levels_visited');

      with LuaSystem.GetTable(['player','episode',Player.CurrentLevel]) do
      try
        FLevel.Init(getInteger('style',0),
                   getInteger('number',0),
                   getString('name',''),
                   getString('special',''),
                   Player.CurrentLevel,
                   getInteger('danger',0));

        if Player.SpecExit <> ''
          then FLevel.Flags[ LF_BONUS ] := True
          else Player.SpecExit := getString('script','');

      finally
        Free;
      end;

      if Player.SpecExit <> ''
        then
          FLevel.ScriptLevel(Player.SpecExit)
        else
        begin
          if FLevel.lnum <> 0 then UI.Msg('You enter %s, level %d.',[ FLevel.Name, FLevel.lnum ]);
          CallHookCheck(Hook_OnGenerate,[]);
          FLevel.AfterGeneration( True );
        end;
      Player.SpecExit := '';
    end;
    
    FLevel.CalculateVision( Player.Position );
    SetState( DSPlaying );
    UI.BloodSlideDown(20);
    
    IO.PlayMusic(FLevel.ID);
    FLevel.PreEnter;

    FLevel.Tick;
    PreAction;

    while ( State = DSPlaying ) do
    begin
      if Player.ChainFire > 0 then
      begin
        Action( COMMAND_ALTFIRE );
        Continue;
      end;

      if ( Player.FRun.Active ) then
      begin
        Action( 0 );
        Continue;
      end;

      repeat
        while not IO.Driver.EventPending do
        begin
          IO.FullUpdate;
          IO.Driver.Sleep(10);
        end;
        if not IO.Driver.PollEvent( iEvent ) then continue;
        if IO.Root.OnEvent( iEvent ) then iEvent.EType := VEVENT_KEYUP;
        if (iEvent.EType = VEVENT_SYSTEM) and (iEvent.System.Code = VIO_SYSEVENT_QUIT) then
          break;
      until ( iEvent.EType = VEVENT_KEYDOWN ) or ( GraphicsVersion and ( iEvent.EType = VEVENT_MOUSEDOWN ) );

      if (iEvent.EType = VEVENT_SYSTEM) then
      begin
        if Option_LockClose
           then Action( INPUT_QUIT )
           else Action( INPUT_HARDQUIT );
        Continue;
      end;

      if iEvent.EType = VEVENT_MOUSEDOWN then
        HandleMouseEvent( iEvent );

      if iEvent.EType = VEVENT_KEYDOWN then
        HandleKeyEvent( iEvent );
    end;

    if State in [ DSNextLevel, DSSaving ] then
      FLevel.Leave;

    Inc(Player.FScore,100);
    if GameWon and (State <> DSNextLevel) then Player.WriteMemorial;
    FLevel.Clear;
    UI.SetHint('');
  until (State <> DSNextLevel) or (GameType = GameSingle);
  except on e : Exception do
  begin
    EmitCrashInfo( e.Message, True );
    EXCEPTEMMITED := True;
    if Option_SaveOnCrash and ((Player.FStatistics.Map['crash_count'] = 0) or{thelaptop: Vengeance is MINE} (Doom.Difficulty < DIFF_NIGHTMARE)) then
    begin
      if Player.CurrentLevel <> 1 then Dec(Player.CurrentLevel);
      Player.IncStatistic('crash_count');
      Player.SpecExit := '';
      WriteSaveFile;
    end;
    raise;
  end;
  end;

  if GameType <> GameSingle then
  begin
    if State = DSSaving then
    begin
      WriteSaveFile;
      UI.MsgEnter('Game saved. Press <Enter> to exit.');
    end;
    if State = DSFinished then
    begin
      if GameWon then
      begin
        IO.PlayMusic('victory');
        CallHookCheck(Hook_OnWinGame,[]);
      end
      else IO.PlayMusic('bunny');
    end;
  end;

  if GameType = GameStandard then
  begin
    if State = DSFinished then
    begin
      if HOF.RankCheck( iRank ) then
        IO.RunUILoop( TUIRankUpViewer.Create( IO.Root, iRank ) );
      if Player.FScore >= -1000 then
        IO.RunUILoop( TUIMortemViewer.Create( IO.Root ) );
      IO.RunUILoop( TUIHOFViewer.Create( IO.Root, HOF.GetHOFReport ) );
    end;
    CallHook(Hook_OnUnLoad,[]);
  end
  else
    if (State <> DSSaving) and (State <> DSQuit) then
    begin
      Player.WriteMemorial;
      if Player.FScore >= -1000 then
        IO.RunUILoop( TUIMortemViewer.Create( IO.Root ) );
    end;

  UI.BloodSlideDown(20);
  FreeAndNil(Player);

  if GameType <> GameStandard then
    Doom.UnLoad;

until not Option_MenuReturn;
  FreeAndNil( iResult );
end;

procedure TDoom.CreatePlayer ( aResult : TMenuResult ) ;
begin
  FreeAndNil( UIDs );
  UIDs := Systems.Add(TUIDStore.Create) as TUIDStore;
  Player := TPlayer.Create;
  FLevel.Place( Player, NewCoord2D(4,4) );
  Player.Klass := aResult.Klass;

  if Option_AlwaysName <> '' then
    Player.Name := Option_AlwaysName
  else
    if (Option_AlwaysRandomName) or (aResult.Name = '')
      then Player.Name := LuaSystem.ProtectedCall(['DoomRL','random_name'],[])
      else Player.Name := aResult.Name;

  LuaSystem.ProtectedCall(['klasses',Player.Klass,'OnPick'], [ Player ] );
  CallHook(Hook_OnCreatePlayer,[]);
  Player.FTraits.Upgrade( aResult.Trait );
  Player.UpdateVisual;
end;

function TDoom.LoadSaveFile: Boolean;
var Stream : TStream;
begin
  try
    try
      Stream := TGZFileStream.Create( WritePath + 'save',gzOpenRead );

      ModuleID        := Stream.ReadAnsiString;
      UIDs            := TUIDStore.CreateFromStream( Stream );
      GameType        := TDoomGameType( Stream.ReadByte );
      GameWon         := Stream.ReadByte <> 0;
      Difficulty      := Stream.ReadByte;
      Challenge       := Stream.ReadAnsiString;
      ArchAngel       := Stream.ReadByte <> 0;
      SChallenge      := Stream.ReadAnsiString;

      Player := TPlayer.CreateFromStream( Stream );
    finally
      Stream.Destroy;
    end;
    DeleteFile( WritePath + 'save' );

    if GameType <> GameStandard then
    begin
      Module := Modules.FindLocalRawMod( ModuleID );
      if Module = nil then Module := Modules.FindLocalMod( ModuleID );
      if Module = nil then raise TModuleException.Create( 'Module '+ModuleID+' used by the savefile not found!' );
      NoPlayerRecord := True;
      NoScoreRecord  := True;
    end;
    UI.Msg('Game loaded.');

    if Player.Dead then
      raise EException.Create('Player in save file is dead anyway.');
    LoadChallenge;
    LoadSaveFile := True;
  except
    on e : Exception do
    begin
      Log('Save file corrupted! Error while loading : '+ e.message );
      DeleteFile( WritePath + 'save' );
      LoadSaveFile := False;
    end;
  end;
end;

procedure TDoom.WriteSaveFile;
var Stream : TStream;
begin
  Player.FStatistics.RealTime += MSecNow() - GameRealTime;
  Player.IncStatistic('save_count');

  Stream := TGZFileStream.Create( WritePath + 'save',gzOpenWrite );

  Stream.WriteAnsiString( ModuleID );
  UIDs.WriteToStream( Stream );
  Stream.WriteByte( Byte(GameType) );
  if GameWon   then Stream.WriteByte( 1 ) else Stream.WriteByte( 0 );
  Stream.WriteByte( Difficulty );
  Stream.WriteAnsiString( Challenge );
  if ArchAngel then Stream.WriteByte( 1 ) else Stream.WriteByte( 0 );
  Stream.WriteAnsiString( SChallenge );

  Player.WriteToStream(Stream);

  FreeAndNil( Stream );
end;

function TDoom.SaveExists : Boolean;
begin
  Exit( FileExists( WritePath + 'save' ) );
end;

procedure TDoom.SetupLuaConstants;
begin
  LuaSystem.SetValue('DIFFICULTY', Difficulty);
  LuaSystem.SetValue('CHALLENGE',  Challenge);
  LuaSystem.SetValue('SCHALLENGE', SChallenge);
  LuaSystem.SetValue('ARCHANGEL', ArchAngel);
end;

procedure TDoom.DoomFirst;
var T : Text;
begin
  Assign(T, WritePath + 'doom.prc');
  Rewrite(T);
  Writeln(T,'Doom was already run.');
  Close(T);
  IO.RunUILoop( TMainMenuViewer.CreateFirst( IO.Root ) );
end;

procedure TDoom.RunSingle;
begin
  FLevel.Init(1,1,'','',1,1);
  Player.SpecExit := '';
  ModuleID := Module.Id;
  LoadModule( False );
  FLevel.SingleLevel(Module.Id);
end;

destructor TDoom.Destroy;
begin
  UnLoad;
  Log('Doom destroyed.');
  FreeAndNil( IO );
  inherited Destroy;
end;

end.
