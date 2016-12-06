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
     vdebug, doombase, dfoutput, vlog, vutil, vos,
     dfdata, doommodule, doomnet, doomio;

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
    ConfigurationPath := RootPath;
    SaveFilePath      := RootPath;
    Logger.Log( LOGINFO, 'Root path set to - '+RootPath );
    {$ENDIF}
    {$ELSE}
      {$IFDEF UNIX}
      {$ENDIF}
    {$ENDIF}

    {$IFDEF Windows}
    RootPath := ExtractFilePath( ParamStr(0) );
    DataPath          := RootPath;
    ConfigurationPath := RootPath;
    SaveFilePath      := RootPath;
    Logger.Log( LOGINFO, 'Root path set to - '+RootPath );
    {$ENDIF}

    Logger.AddSink( TTextFileLogSink.Create( LOGDEBUG, RootPath+'log.txt', False ) );
    LogSystemInfo();
    Logger.Log( LOGINFO, 'Root path set to - '+RootPath );

    {$IFDEF WINDOWS}
    Title := 'DoomRL - Doom, the Roguelike';
    SetConsoleTitle(PChar(Title));
    Sleep(40);
    {$ENDIF}

    {$IFDEF HEAPTRACE}
    SetHeapTraceOutput(RootPath+'heap.txt');
    {$ENDIF}

    Doom := Systems.Add(TDoom.Create) as TDoom;

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


