{$INCLUDE doomrl.inc}
unit doommodule;
interface
uses vlua, vutil, vnode, vgenerics;

type TDoomModule = class
    ID           : Ansistring;
    Version      : Ansistring;
    Path         : Ansistring;
    BaseRequired : AnsiString;
    WorkshopID   : QWord;
    LoadPriority : Integer;
    SaveVersion  : Integer;
    SaveAgnostic : Boolean;
    IsBase       : Boolean;
  end;

type TModuleArray = specialize TGObjectArray< TDoomModule >;
     TModuleList  = specialize TGArray< TDoomModule >;
     TModuleHash  = specialize TGHashMap< TDoomModule >;



type

{ TDoomModules }

TDoomModules = class(TVObject)
  constructor Create;
  procedure ScanModules;
  destructor Destroy; override;
private
  FModules   : TModuleArray;
  FModuleMap : TModuleHash;
private
  function ReadMetaFromModule( aLua : TLua; aOverride : Boolean ) : TDoomModule;
  procedure ReadMetaFromWAD( aLua : TLua; const aPath : Ansistring; aOverride : Boolean = True );
  procedure ReadMetaFromFolder( aLua : TLua; const aPath : Ansistring; aOverride : Boolean = True );
public
  property Modules : TModuleArray read FModules;
end;

var Modules : TDoomModules;

implementation

uses sysutils, vluatable, vdf, dfdata;

constructor TDoomModules.Create;
begin
  FModules   := TModuleArray.Create( True );
  FModuleMap := TModuleHash.Create;
end;

procedure TDoomModules.ScanModules;
var iInfo : TSearchRec;
    iLua  : TLua;
begin
  FModules.Clear;
  FModuleMap.Clear;
  try
    iLua := TLua.Create;

    if FindFirst( DataPath + '*.wad', faAnyFile, iInfo ) = 0 then
    repeat
       ReadMetaFromWAD( iLua, DataPath + iInfo.Name );
    until FindNext(iInfo) <> 0;
    FindClose(iInfo);

    if FindFirst( DataPath + 'data' + PathDelim + '*', faDirectory, iInfo ) = 0 then
    begin
      repeat
        if (iInfo.Attr and faDirectory <> 0) and (iInfo.Name <> '.') and (iInfo.Name <> '..') then
          ReadMetaFromFolder( iLua,DataPath + 'data' + PathDelim + iInfo.Name + PathDelim );
      until FindNext(iInfo) <> 0;
    end;
    FindClose(iInfo);

    // Add steam workshop folders support
  finally
    FreeAndNil( iLua );
  end;
end;

function TDoomModules.ReadMetaFromModule( aLua : TLua; aOverride : Boolean ) : TDoomModule;
var iModule : TDoomModule;
    i       : Integer;
begin
  iModule := TDoomModule.Create;
  try
    iModule.ID := 'unknown';
    with TLuaTable.Create( aLua.NativeState, 'meta' ) do
    try
      iModule.ID           := GetString( 'id' );
      iModule.Version      := GetString( 'version', '' );
      iModule.Path         := '';
      iModule.BaseRequired := GetString( 'base_required', '' );
      iModule.WorkshopID   := GetQWord( 'workshop_id', 0 );
      iModule.LoadPriority := GetInteger( 'load_priority', 0 );
      iModule.SaveVersion  := GetInteger( 'save_version', 0 );
      iModule.SaveAgnostic := GetBoolean( 'save_agnostic', False );
      iModule.IsBase       := GetBoolean( 'is_base', False );
    finally
      Free;
    end;
  except on e : Exception do
    begin
      Log( LOGERROR, 'error while loading module "%s" ...', [iModule.ID] );
      FreeAndNil( iModule );
      Exit( nil );
    end;
  end;
  if FModuleMap[ iModule.ID ] <> nil then
  begin
    if not aOverride then
    begin
      Log( LOGINFO, 'module "%s" repeated - ignoring...', [iModule.ID] );
      FreeAndNil( iModule );
      Exit( nil );
    end;
    for i := 0 to FModules.Size - 1 do
      if FModules[i].ID = iModule.ID then
      begin
        FModules[i] := iModule;
        Break;
      end;
    Log( LOGINFO, 'overriding module "%s" successfuly!', [iModule.ID] );
  end
  else
  begin
    FModules.Push( iModule );
    Log( LOGINFO, 'loaded module "%s" successfuly!', [iModule.ID] );
  end;
  FModuleMap[ iModule.ID ] := iModule;
  Exit( iModule );
end;

procedure TDoomModules.ReadMetaFromWAD( aLua : TLua; const aPath : Ansistring; aOverride : Boolean = True );
var iData   : TVDataFile;
    iModule : TDoomModule;
begin
  Log( LOGINFO, 'found WAD module "%s"...', [aPath] );
  try
    iData       := TVDataFile.Create( aPath );
    iData.DKKey := LoveLace;
    if iData.FileExists( 'meta.lua' ) then
    begin
      aLua.LoadStream( iData, 'meta.lua' );
      iModule := ReadMetaFromModule( aLua, aOverride );
      if iModule <> nil then
        iModule.Path := aPath;
    end;
  finally
    iData.Free;
  end;
end;

procedure TDoomModules.ReadMetaFromFolder( aLua : TLua; const aPath : Ansistring; aOverride : Boolean = True );
var iModule : TDoomModule;
begin
  Log( LOGINFO, 'found module "%s"...', [aPath] );
  if FileExists( aPath + 'meta.lua' ) then
  begin
    aLua.LoadFile( aPath + 'meta.lua' );
    iModule := ReadMetaFromModule( aLua, aOverride );
    if iModule <> nil then
      iModule.Path := aPath;
  end;
end;

destructor TDoomModules.Destroy;
begin
  FreeAndNil( FModules );
  FreeAndNil( FModuleMap );
  inherited Destroy;
end;

end.

