unit doommodule;
{$mode objfpc}
interface
uses Classes, SysUtils, vutil, vluasystem, vnode, vgenerics, dfdata, doomnet;

type TModuleException = Exception;

type TModuleType = ( ModuleSingle, ModuleEpisode, ModuleTotal );

type

{ TDoomModule }

 TDoomModule = class
    Id       : AnsiString;
    Name     : AnsiString;
    Author   : AnsiString;
    Webpage  : AnsiString;
    ModURL   : AnsiString;
    Klass    : Byte;
    Version  : TVersion;
    DrlVer   : TVersion;
    MType    : TModuleType;
    Raw      : Boolean;
    GSupport : Boolean;
    Desc     : AnsiString;
    CDesc    : AnsiString;
    Diff     : Boolean;
    Size     : DWord;
    Challenge: Boolean;
    AwardID  : AnsiString;
    Award    : TMemoryStream;
    constructor Create;
    destructor Destroy; override;
  end;

type TModuleArray = specialize TGObjectArray< TDoomModule >;
     TModuleList  = specialize TGArray< TDoomModule >;
     TModuleHash  = specialize TGHashMap< TDoomModule >;

type

{ TDoomModules }

TDoomModules = class(TVObject)
  constructor Create;
  procedure RefreshLocalModules;
  function DownloadRemoteLists( aProgress : TNetProgressFunc = nil ) : Boolean;
  function DownloadModule( aModule : TDoomModule; aProgress : TNetProgressFunc = nil ) : Boolean;
  function FindLocalMod( const aID : AnsiString ) : TDoomModule;
  function FindLocalRawMod( const aID : AnsiString ) : TDoomModule;
  procedure RegisterAwards( L : PLua_State );
  destructor Destroy; override;
private
  FModuleDirectory  : AnsiString;
  FChallengeModules : TModuleList;
  FRemoteModules    : TModuleArray;
  FLocalModules     : TModuleArray;
  FLocalMap         : TModuleHash;
private
  procedure Warning( const Warning : AnsiString ); reintroduce;
  procedure RegisterRawModule( const ModuleID : AnsiString );
  procedure RegisterWadModule( const ModuleID : AnsiString );
  procedure RegisterModule( L: PLua_State; Raw : Boolean );
public
  property LocalModules     : TModuleArray read FLocalModules;
  property RemoteModules    : TModuleArray read FRemoteModules;
  property ModulePath       : AnsiString   read FModuleDirectory;
  property ChallengeModules : TModuleList  read FChallengeModules;
end;

var Modules : TDoomModules;

implementation

uses DOM, XMLRead, URIParser, vdebug, variants, vxml, vlualibrary, vluatable, vluaext, vdf;

function VariantToVersion( aVariant : Variant ) : TVersion;
var i,n : Integer;
begin
  VariantToVersion[1] := 0;
  VariantToVersion[2] := 0;
  VariantToVersion[3] := 0;
  VariantToVersion[4] := 0;
  for i := VarArrayLowBound( aVariant, 1 ) to VarArrayHighBound( aVariant, 1 ) do
  begin
    if i > 3 then Exit;
    n := aVariant[ i ];
    VariantToVersion[ i+1 ] := n;
  end;
end;

function StringToMType( const S : AnsiString ) : TModuleType;
begin
  if S = 'single'  then Exit(ModuleSingle);
  if S = 'episode' then Exit(ModuleEpisode);
  if S = 'total'   then Exit(ModuleTotal);
  raise TModuleException.Create( 'unrecognized type field - "'+S+'"!' );
end;

function MTypeToString( const MType : TModuleType ) : AnsiString;
begin
  case MType of
    ModuleSingle  : Exit( 'single' );
    ModuleEpisode : Exit( 'episode' );
    ModuleTotal   : Exit( 'total' );
  end;
end;

constructor TDoomModule.Create;
begin
  Award   := nil;
end;

destructor TDoomModule.Destroy;
begin
  if Award <> nil then FreeAndNil( Award );
  inherited Destroy;
end;

{ TDoomModules }

constructor TDoomModules.Create;
begin
  Log('DoomModules loading...');
  FModuleDirectory := ConfigurationPath + 'modules' + DirectorySeparator;
  FRemoteModules   := TModuleArray.Create;
  FLocalModules    := TModuleArray.Create;
  FLocalMap        := TModuleHash.Create;
  FChallengeModules:= TModuleList.Create;
  RefreshLocalModules;
  Log('DoomModules loaded.');
end;

procedure TDoomModules.RefreshLocalModules;
var iInfo : TSearchRec;
begin
  FreeAndNil( FLocalMap );
  FLocalMap := TModuleHash.Create;
  FLocalModules.Clear;
  FChallengeModules.Clear;
  if FindFirst( FModuleDirectory + '*.module', faDirectory, iInfo ) = 0 then
  repeat
    with iInfo do
      RegisterRawModule( LeftStr( Name, Length( Name ) - 7 ) );
  until FindNext(iInfo) <> 0;
  FindClose(iInfo);

  if FindFirst( FModuleDirectory + '*.wad', faAnyFile, iInfo ) = 0 then
  repeat
    with iInfo do
      RegisterWadModule( LeftStr( Name, Length( Name ) - 4 ) );
  until FindNext(iInfo) <> 0;

  if LuaSystem <> nil then
    RegisterAwards( LuaSystem.Raw );

  FindClose(iInfo);
end;

destructor TDoomModules.Destroy;
begin
  FreeAndNil( FLocalMap );
  FreeAndNil( FLocalModules );
  FreeAndNil( FRemoteModules );
  FreeAndNil( FChallengeModules );
  Log('DoomModules destroyed.');
end;

function TDoomModules.DownloadRemoteLists( aProgress : TNetProgressFunc = nil ) : Boolean;
var iModInfo : TVXMLDocument;
    iXML     : TXMLDocument;
    iAmount  : Integer;
    iCount   : Integer;
    iElement : TDOMElement;
    iModule  : TDoomModule;
    iSuccess : Boolean;
    iURI     : TURI;
begin
  FRemoteModules.Clear;
  iURI := ParseURI( DoomNetwork.ModServer, 'http', 80 );
  with TDownloadTask.Create(iURI.Host,iURI.Path+iURI.Document, FModuleDirectory + 'modules.xml') do
  try
    SetOnProgress(aProgress);
    iSuccess := Run;
  finally
    Free;
  end;

  if not iSuccess then
  begin
    DeleteFile( FModuleDirectory + 'modules.xml' );
    Exit( False );
  end;
  ReadXMLFile( iXML, FModuleDirectory + 'modules.xml');
  iModInfo := TVXMLDocument( iXML );
  iAmount := iModInfo.DocumentElement.ChildNodes.Count;

  for iCount := 1 to iAmount do
  begin
    iElement := TDOMElement(iModInfo.DocumentElement.ChildNodes.Item[iCount-1]);
    if iElement.TagName <> 'module' then Continue;
    iModule  := TDoomModule.Create;
    iModule.Id       := iElement.GetAttribute('id');
    iModule.Name     := iElement.GetAttribute('name');
    iModule.Author   := iElement.GetAttribute('author');
    iModule.Webpage  := iElement.GetAttribute('webpage');
    iModule.ModURL   := iElement.GetAttribute('url');
    iModule.GSupport := iElement.GetAttribute('gsupport') = 'true';
    iModule.Klass    := 0;
    iModule.Version  := StringToVersion( iElement.GetAttribute('version') );
    iModule.DrlVer   := StringToVersion( iElement.GetAttribute('drlver') );
    iModule.MType    := StringToMType( iElement.GetAttribute('type') );
    iModule.Desc     := iElement.GetAttribute('desc');
    iModule.CDesc    := '';
    iModule.Size     := StrToIntDef( iElement.GetAttribute('size'), 0 );
    iModule.Raw      := False;
    iModule.Diff     := False;
    iModule.AwardID  := '';
    iModule.Challenge:= False;

    FRemoteModules.Push( iModule );
  end;

  FreeAndNil( iModInfo );
  Exit( True );
end;

function TDoomModules.DownloadModule( aModule : TDoomModule; aProgress: TNetProgressFunc ) : Boolean;
var iURI     : TURI;
begin
  iURI := ParseURI( aModule.ModURL, 'http', 80 );
  with TDownloadTask.Create(iURI.Host,iURI.Path+iURI.Document, FModuleDirectory + aModule.ID+'.wad') do
  try
    SetOnProgress(aProgress);
    DownloadModule := Run;
  finally
    Free;
  end;
end;

function TDoomModules.FindLocalMod( const aID : AnsiString ) : TDoomModule;
var iModule : TDoomModule;
begin
  for iModule in FLocalModules do
    if (not iModule.Raw) and (iModule.ID = aID) then
      Exit( iModule );
  Exit( nil );
end;

function TDoomModules.FindLocalRawMod( const aID : AnsiString ) : TDoomModule;
var iModule : TDoomModule;
begin
  for iModule in FLocalModules do
    if iModule.Raw and (iModule.ID = aID) then
      Exit( iModule );
  Exit( nil );
end;

procedure TDoomModules.RegisterAwards( L : PLua_State );
var iModule : TDoomModule;
begin
  for iModule in FLocalModules do
    if (iModule.Award <> nil) and (FLocalMap[iModule.ID] = iModule) then
    begin
      lua_getglobal( L, 'register_award_plain' );
      lua_pushansistring( L, iModule.ID );
      lua_pushansistring( L, iModule.Name );
      iModule.Award.Position := 0;
      vlua_pushfromstream( L, iModule.Award );
      if lua_pcall( L, 3, 1, 0 ) <> 0
        then LuaSystem.OnError( 'Register award for module '+iModule.ID+' -- ' + lua_tostring( L, -1) )
        else iModule.AwardID := lua_tostring( L, -1 );
      lua_pop( L, 1 );
    end;
end;

procedure TDoomModules.Warning(const Warning: AnsiString);
begin
  Log( LOGERROR, 'Doom Module Loader > '+ Warning );
//  Writeln( 'Doom Module Loader > '+ Warning );
//  Readln;
end;

procedure TDoomModules.RegisterRawModule(const ModuleID: AnsiString);
var L     : PLua_State;
    iPath : AnsiString;
begin
  if (Lowercase(ModuleID) = 'DoomRL') then exit;
  iPath := FModuleDirectory + ModuleID + '.module' + DirectorySeparator + 'module.lua';
  if not FileExists( iPath ) then Exit;
  LoadLua;
  L := lua_open;
  luaopen_base(L);
  try
    if luaL_dofile( L, PChar(iPath)) <> 0 then
      raise TModuleException.Create(lua_tostring(L,-1));
    RegisterModule( L, True );
    FLocalMap[ ModuleID ] := FLocalModules.Top;
    if FLocalModules.Top.Challenge then FChallengeModules.Push( FLocalModules.Top );
  except on e : Exception do
    Warning( ModuleID+'.module : ' + e.Message );
  end;
  lua_close(L);
end;

procedure TDoomModules.RegisterWadModule(const ModuleID: AnsiString);
var WAD    : TVDataFile;
    L      : PLua_State;
    Path   : AnsiString;
    EStr   : AnsiString;
    Stream : TStream;
    Size   : Int64;
    Buf    : PByte;

begin
  Path := FModuleDirectory + ModuleID + '.wad';
  WAD := TVDataFile.Create(Path);
  LoadLua;
  L := lua_open;
  luaopen_base(L);
  try
    if not WAD.FileExists('module.lua') then raise TModuleException.Create( 'failed to extract!' );

    Stream := WAD.GetFile('module.lua','');
    Size   := WAD.GetFileSize('module.lua','');
    GetMem(Buf,Size);
    Stream.ReadBuffer(Buf^,Size);
    FreeAndNil(Stream);
    if ( luaL_loadbuffer(L,PChar(Buf),Size,'module.lua') <> 0 ) or
       ( lua_pcall(L, 0, 0, 0) <> 0 ) then
    begin
      EStr := lua_tostring(L,-1);
      lua_pop(L,1);
      raise TModuleException.Create( 'module.lua: '+EStr);
    end;
    FreeMem(Buf);
    RegisterModule( L, False );
    if not FLocalMap.Exists( ModuleID ) then
    begin
      FLocalMap[ ModuleID ] := FLocalModules.Top;
      if FLocalModules.Top.Challenge then FChallengeModules.Push( FLocalModules.Top );
    end;
  except on e : TModuleException do
    Warning( ModuleID+'.wad : ' + e.Message );
  end;
  lua_close(L);
end;

procedure TDoomModules.RegisterModule(L: PLua_State; Raw: Boolean);
var MD : TDoomModule;
    AW : Boolean;
begin
  try
    MD := TDoomModule.Create;
    MD.Raw := Raw;
    with TLuaTable.Create( L, 'module' ) do
    try
      MD.Id      := getString('id');
      MD.Name    := getString('name');
      MD.Author  := getString('author');
      MD.Webpage := getString('webpage');
      MD.Version := VariantToVersion( getValue('version') );
      MD.DrlVer  := VariantToVersion( getValue('drlver') );
      MD.MType   := StringToMType( getString('type') );
      MD.Desc    := getString('description');
      MD.CDesc   := getString('cdescription',MD.Desc);
      MD.Klass   := getInteger('klass',0);
      MD.Diff    := getBoolean('difficulty');
      MD.GSupport:= getBoolean('gsupport',False);
      MD.ModURL   := '';
      MD.AwardID  := '';
      MD.Challenge:= getBoolean('challenge',False);
      AW := IsTable('award');
    finally
      Free;
    end;
    if AW then
    begin
      MD.Award := TMemoryStream.Create;
      vlua_getpath( L, ['module','award'] );
      vlua_tostream( L, -1, MD.Award );
      lua_pop( L, 1 );
    end;

    FLocalModules.Push( MD );
  except
    on e : Exception do
    begin
      FreeAndNil(MD);
      raise;
    end;
  end;
end;

end.

