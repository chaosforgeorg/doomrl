{$INCLUDE drl.inc}
{
 ----------------------------------------------------
Copyright (c) 2002-2025 by Kornel Kisielewicz
----------------------------------------------------
}
unit drlmodule;
interface
uses vlua, vutil, vnode, vgenerics;

type TDRLModule = class
    ID           : Ansistring;
    Name         : Ansistring;
    Version      : Ansistring;
    Path         : Ansistring;
    BaseRequired : AnsiString;
    WorkshopID   : QWord;
    LoadPriority : Integer;
    SaveVersion  : Integer;
    SaveAgnostic : Boolean;
    IsBase       : Boolean;
  end;

type TModuleArray = specialize TGObjectArray< TDRLModule >;
     TModuleList  = specialize TGArray< TDRLModule >;
     TModuleHash  = specialize TGHashMap< TDRLModule >;



type

{ TDRLModules }

TDRLModules = class(TVObject)
  constructor Create;
  procedure ScanModules;
  function Validate( const aCoreModuleID : Ansistring ) : Ansistring;
  procedure ActivateModules( const aCoreModuleID : Ansistring );
  destructor Destroy; override;
private
  FModules       : TModuleArray;
  FModuleMap     : TModuleHash;
  FCoreModules   : TModuleList;
  FActiveModules : TModuleList;
  FCoreModuleID  : Ansistring;
  FModString     : Ansistring;
private
  function ReadMetaFromModule( aLua : TLua; aOverride : Boolean ) : TDRLModule;
  procedure ReadMetaFromWAD( aLua : TLua; const aPath : Ansistring; aOverride : Boolean = True );
  procedure ReadMetaFromFolder( aLua : TLua; const aPath : Ansistring; aOverride : Boolean = True );
public
  property ActiveModules : TModuleList read FActiveModules;
  property CoreModules   : TModuleList read FCoreModules;
  property CoreModuleID  : Ansistring  read FCoreModuleID;
  property ModString     : Ansistring  read FModString;
end;

var Modules : TDRLModules;

implementation

uses sysutils, vluatable, vdf, dfdata;

function DRLModuleCompare( const A, B : TDRLModule ) : Integer;
begin
  Exit( B.LoadPriority - A.LoadPriority );
end;

constructor TDRLModules.Create;
begin
  FModules       := TModuleArray.Create( True );
  FModuleMap     := TModuleHash.Create;
  FActiveModules := TModuleList.Create;
  FCoreModules   := TModuleList.Create;
  FCoreModuleID  := '';
  FModString     := '';
end;

procedure TDRLModules.ScanModules;
var iInfo   : TSearchRec;
    iModule : TDRLModule;
    iLua    : TLua;
begin
  FModules.Clear;
  FModuleMap.Clear;
  FCoreModules.Clear;
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
  FModules.Sort( @DRLModuleCompare );

  for iModule in FModules do
    if iModule.IsBase then
    begin
      FCoreModules.Push( iModule );
      Log( 'found base module %s (%s)', [ iModule.ID, iModule.Path ] );
    end;

  if FCoreModules.Size = 1 then
     FCoreModuleID := FCoreModules[0].ID;
end;

function TDRLModules.Validate( const aCoreModuleID : Ansistring ) : Ansistring;
var iModule : TDRLModule;
begin
  if aCoreModuleID <> '' then
    for iModule in FCoreModules do
      if iModule.ID = aCoreModuleID then
      begin
        FCoreModuleID := iModule.ID;
        Break;
      end;
  Exit( FCoreModuleID );
end;

procedure TDRLModules.ActivateModules( const aCoreModuleID : Ansistring );
var iModule : TDRLModule;
begin
  FCoreModuleID := aCoreModuleID;
  FModString    := '';
  FActiveModules.Clear;

  for iModule in FModules do
    if ( ( iModule.BaseRequired = aCoreModuleID ) or ( iModule.BaseRequired = '' ) )
    and ( ( not iModule.IsBase ) or ( iModule.ID = aCoreModuleID ) ) then
    begin
      FActiveModules.Push( iModule );
      if ( not iModule.IsBase ) and ( not iModule.SaveAgnostic ) then
      begin
        if FModString <> '' then FModString += ' ';
        FModString += iModule.ID;
        if iModule.SaveVersion > 0 then FModString += IntToStr( iModule.SaveVersion );
      end;
      Log( 'activating module %s (%s)', [ iModule.ID, iModule.Path ] );
    end;
  Log( 'mod_string generated "%s"', [ FModString ] );
end;

function TDRLModules.ReadMetaFromModule( aLua : TLua; aOverride : Boolean ) : TDRLModule;
var iModule : TDRLModule;
    i       : Integer;
begin
  iModule := TDRLModule.Create;
  try
    iModule.ID := 'unknown';
    with TLuaTable.Create( aLua.NativeState, 'meta' ) do
    try
      iModule.ID           := GetString( 'id' );
      iModule.Name         := GetString( 'name', iModule.ID );
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

procedure TDRLModules.ReadMetaFromWAD( aLua : TLua; const aPath : Ansistring; aOverride : Boolean = True );
var iData   : TVDataFile;
    iModule : TDRLModule;
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

procedure TDRLModules.ReadMetaFromFolder( aLua : TLua; const aPath : Ansistring; aOverride : Boolean = True );
var iModule : TDRLModule;
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

destructor TDRLModules.Destroy;
begin
  FreeAndNil( FActiveModules );
  FreeAndNil( FCoreModules );
  FreeAndNil( FModuleMap );
  FreeAndNil( FModules );
  inherited Destroy;
end;

end.

