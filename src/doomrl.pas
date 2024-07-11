{
-------------------------------------------------------
DoomRL.PAS -- Main Program
Copyright (c) 2002-2006 by Kornel "Anubis" Kisielewicz
-------------------------------------------------------
}
{
[todo] move default value functionality to prototype structures
[todo] blueprints are only for type and range checking
[todo] blueprints can (should?) be turned off if not loading module, or in godmode?
[todo] however, we'd loose the option to run functions if not turned on?
[todo] container structures have meta information __blueprint and __prototype for default
[todo] the upper needs to be handled by core.unregister!
[todo] warning-only mode?
[todo] dryrun possibility of the wad file! for modders and stats generation

[todo] Copy configs from DataPath to ConfigurationPath if not present
[todo] Set proper paths on unix, create directories if needed
}

{$INCLUDE doomrl.inc}

program doomrl;
uses SysUtils, vsystems,
     {$IFDEF HEAPTRACE} heaptrc, {$ENDIF}
     {$IFDEF WINDOWS}   windows, {$ENDIF}
     vdebug, doombase, vlog, vutil, vos, vparams,
     dfdata, doommodule, doomnet, doomio, doomconfig;

{$IFDEF WINDOWS}
var Handle : HWND;
    Title  : AnsiString;

function ConsoleEventProc(CtrlType: DWORD): Bool; stdcall;
begin
  Result := True;
end;

{$R *.res}

{$ENDIF}

var RootPath : AnsiString = '';

begin
try
  try
    DoomNetwork := nil;
    Modules     := nil;

    {$IFDEF Darwin}
    {$IFDEF OSX_APP_BUNDLE}
    RootPath := GetResourcesPath();
    DataPath          := RootPath;
    ConfigurationPath := RootPath + 'config.lua';
    {$ENDIF}
    {$ELSE}
      {$IFDEF UNIX}
      {$ENDIF}
    {$ENDIF}

    {$IFDEF Windows}
    RootPath := ExtractFilePath( ParamStr(0) );
    DataPath          := RootPath;
    ConfigurationPath := RootPath + 'config.lua';
    {$ENDIF}

    {$IFDEF WINDOWS}
    Title := 'DoomRL - Doom, the Roguelike';
    SetConsoleTitle(PChar(Title));
    Sleep(40);
    {$ENDIF}
    ColorOverrides := nil;

    with TParams.Create do
    try
      if isSet('god')    then
      begin
        GodMode           := True;
        ConfigurationPath := RootPath + 'godmode.lua';
      end;
      if isSet('config')     then ConfigurationPath := get('config');
      if isSet('nonet')      then ForceNoNet := True;
      if isSet('fullscreen') then ForceFullscreen := True;
      if isSet('nosound')    then ForceNoAudio    := True;
      if isSet('graphics')   then
      begin
        GraphicsVersion := True;
        ForceGraphics := True;
      end;
      if isSet('console')    then
      begin
        GraphicsVersion := False;
        ForceConsole := True;
      end;

      Config := TDoomConfig.Create( ConfigurationPath, False );
      DataPath     := Config.Configure( 'DataPath', DataPath );
      WritePath    := Config.Configure( 'WritePath', WritePath );
      ScorePath    := Config.Configure( 'ScorePath', ScorePath );

      if isSet('datapath')   then DataPath          := get('datapath');
      if isSet('writepath')  then WritePath         := get('writepath');
      if isSet('scorepath')  then ScorePath         := get('scorepath');
      if isSet('name')       then Option_AlwaysName := get('name');
    finally
      Free;
    end;


    {$IFDEF HEAPTRACE}
    SetHeapTraceOutput( WritePath + 'heap.txt');
    {$ENDIF}

    Logger.AddSink( TTextFileLogSink.Create( LOGDEBUG, WritePath + 'log.txt', False ) );
    LogSystemInfo();
    Logger.Log( LOGINFO, 'Log path set to - ' + WritePath );

    if ScorePath = '' then ScorePath := WritePath;
    ErrorLogFileName := WritePath + 'error.log';

    Doom := Systems.Add(TDoom.Create) as TDoom;

    Option_NetworkConnection := False;

    DoomNetwork := TDoomNetwork.Create;
    if DoomNetwork.AlertCheck then Halt(0);

    Modules     := TDoomModules.Create;

    Randomize;
    Doom.CreateIO;
    {$IFDEF WINDOWS}
    if not GraphicsVersion then
    begin
      if Option_LockBreak then
      begin
        SetConsoleCtrlHandler(nil, False);
        SetConsoleCtrlHandler(@ConsoleEventProc, True);
      end;
      if Option_LockClose then
      begin
        Handle := FindWindow(nil, PChar(Title));
        RemoveMenu(GetSystemMenu( Handle, FALSE), SC_CLOSE , MF_GRAYED);
        DrawMenuBar(FindWindow(nil, PChar(Title)));
      end;
    end;
    {$ENDIF}
    Doom.Run;
  finally
    FreeAndNil( Modules );
    FreeAndNil( DoomNetwork );
    FreeAndNil( Systems );
  end;
except on e : Exception do
  begin
    if not EXCEPTEMMITED then
      EmitCrashInfo( e.Message, False );
    raise
  end;
end;

end.


