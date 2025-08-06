{$INCLUDE drl.inc}
{
 ----------------------------------------------------
Copyright (c) 2002-2025 by Kornel Kisielewicz
----------------------------------------------------
}
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
  procedure ScanModules( const aCoreModuleID : Ansistring );
  destructor Destroy; override;
private
  FActiveModules : TModuleList;
  FModules       : TModuleArray;
  FModuleMap     : TModuleHash;
  FCoreModuleID  : Ansistring;
private
  function ReadMetaFromModule( aLua : TLua; aOverride : Boolean ) : TDoomModule;
  procedure ReadMetaFromWAD( aLua : TLua; const aPath : Ansistring; aOverride : Boolean = True );
  procedure ReadMetaFromFolder( aLua : TLua; const aPath : Ansistring; aOverride : Boolean = True );
public
  property ActiveModules : TModuleList read FActiveModules;
  property CoreModuleID  : Ansistring  read FCoreModuleID;
end;

var Modules : TDoomModules;

implementation

uses sysutils, vluatable, vdf, dfdata;

function DoomModuleCompare( const A, B : TDoomModule ) : Integer;
begin
  Exit( B.LoadPriority - A.LoadPriority );
end;

constructor TDoomModules.Create;
begin
  FModules       := TModuleArray.Create( True );
  FModuleMap     := TModuleHash.Create;
  FActiveModules := TModuleList.Create;
  FCoreModuleID  := '';
end;

procedure TDoomModules.ScanModules( const aCoreModuleID : Ansistring );
var iInfo   : TSearchRec;
    iModule : TDoomModule;
    iLua    : TLua;
begin
  FCoreModuleID := aCoreModuleID;
  FModules.Clear;
  FModuleMap.Clear;
  FActiveModules.Clear;
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
          ReadMetaFromFolder( iLua,DataPath + 'data' + PathDelim + iInfo.Name + PathDelim, Option_ForceRaw );
      until FindNext(iInfo) <> 0;
    end;
    FindClose(iInfo);

    // Add steam workshop folders support
  finally
    FreeAndNil( iLua );
  end;

  FModules.Sort( @DoomModuleCompare );
  for iModule in FModules do
    if ( ( iModule.BaseRequired = aCoreModuleID ) or ( iModule.BaseRequired = '' ) )
    and ( ( not iModule.IsBase ) or ( iModule.ID = aCoreModuleID ) ) then
    begin
      FActiveModules.Push( iModule );
      Log( 'activating module %s (%s)', [ iModule.ID, iModule.Path ] );
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
      Log( LOGERROR, 'error while loading module "%s"...', [iModule.ID] );
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
    Log( LOGINFO, 'overriding module "%s"!', [iModule.ID] );
  end
  else
  begin
    FModules.Push( iModule );
    Log( LOGINFO, 'registered module "%s".', [iModule.ID] );
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
  FreeAndNil( FActiveModules );
  inherited Destroy;
end;

end.

