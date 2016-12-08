unit doomnet;
{$include doomrl.inc}
interface

uses Classes, SysUtils, vnode, vutil;

type TNetProgressFunc = procedure ( Progress : DWord ) of object;
type

{ TDownloadTask }

TDownloadTask = class(TVObject)
  constructor Create( const aHostName, aFileName, aTarget : AnsiString);
  procedure SetOnProgress( func : TNetProgressFunc );
  function Run : Boolean;
  function GetError : AnsiString;
  destructor Destroy; override;
private
  HostName   : Ansistring;
  FileName   : Ansistring;
  Target     : Ansistring;
  OnProgress : TNetProgressFunc;
  Error      : AnsiString;
end;

TDoomNetworkVersionInfo = record
  Version   : TVersion;
  Patch     : AnsiString;
  ModServer : AnsiString;
end;

{ TDoomNetwork }

TDoomNetwork = class(TVObject)
  constructor Create;
  function AlertCheck : Boolean;
  destructor Destroy; override;
private
  function IsNewer( aVersion : TDoomNetworkVersionInfo ) : Boolean;
  procedure ReadInfoXML;
private
  FConnected     : Boolean;
  FStable        : TDoomNetworkVersionInfo;
  FBeta          : TDoomNetworkVersionInfo;
  FMOTD          : AnsiString;
  FAlert         : AnsiString;
  FAlertURL      : AnsiString;
  FAlertOld      : AnsiString;
  FModServer     : AnsiString;
public
  property ModServer : AnsiString read FModServer;
  property MOTD      : AnsiString read FMOTD;
end;

var DoomNetwork : TDoomNetwork;

implementation

uses {$IFDEF WINDOWS}windows, {$ENDIF}strutils, vdebug, vos, vnetwork, xmlread, dom, dfdata, doombase;

{ TDoomNetwork }

constructor TDoomNetwork.Create;
begin
  FConnected := False;
  ReadInfoXML;
  FModServer := '';
  FAlertOld := FAlert;
  if not Option_NetworkConnection then
  begin
    FMOTD := 'Network connection disabled.';
    Exit;
  end;
  with TDownloadTask.Create( 'doom.chaosforge.net','/info.xml',ConfigurationPath+'info.xml' ) do
  try
    FConnected := Run;
  finally
    Free;
  end;
  if FConnected
    then ReadInfoXML
    else FMOTD := 'Could not connect to ChaosForge server!';

  Log('Remote stable - '+VersionToString( FStable.Version )+' '+FStable.Patch+'('+FStable.ModServer+')');
  Log('Remote beta   - '+VersionToString( FBeta.Version )  +' '+FBeta.Patch  +'('+FBeta.ModServer+')');
  Log('MOTD          - '+FMOTD);

  if VERSION_BETA
    then FModServer := FBeta.ModServer
    else FModServer := FStable.ModServer;
end;

function TDoomNetwork.AlertCheck: Boolean;
begin
  {$IFDEF WINDOWS}
  if (not FConnected) or (not Option_NetworkConnection) then Exit( False );
  if Option_VersionCheck and IsNewer(FStable) then
    if ( MessageBox( 0, 'You''re running an old version of DoomRL, missing out on some awesome features! It is highly recommended for you to upgrade!'#10#10'Do you want to download the newest version now?','DoomRL - new version available!', MB_YESNO or MB_ICONQUESTION ) = IDYES ) then
    begin
      OpenWebPage('https://drl.chaosforge.org');
      Exit( True );
    end;
  if Option_BetaCheck and IsNewer(FBeta) then
    if ( MessageBox( 0, 'New BETA version available! Upgrade is highly recommended!'#10#10'Do you want to download the newest version now?','DoomRL - new version available!', MB_YESNO or MB_ICONQUESTION ) = IDYES ) then
    begin
      OpenWebPage('http://forum.chaosforge.org');
      Exit( True );
    end;
  if Option_AlertCheck and (FAlert <> '') and (FAlertOld <> FAlert) then
    if ( MessageBox( 0, PChar(FAlert),'ChaosForge Alert!', MB_YESNO or MB_ICONQUESTION ) = IDYES ) then
    begin
      OpenWebPage(FAlertURL);
      Exit( True );
    end;
  {$ENDIF}
  Exit( False );
end;

destructor TDoomNetwork.Destroy;
begin
  inherited Destroy;
end;

function TDoomNetwork.IsNewer(aVersion: TDoomNetworkVersionInfo): Boolean;
begin
  if aVersion.Version > Doom.NVersion then Exit( True );
  if Doom.NVersion > aVersion.Version then Exit( False );
  if aVersion.Patch <> '' then
  begin
    if AnsiEndsText( aVersion.Patch, VERSION_STRING ) then Exit( False );
    Exit( True );
  end;
  Exit( False );
end;

procedure TDoomNetwork.ReadInfoXML;
var iXML      : TXMLDocument;
    iElement  : TDOMElement;
    iFileName : AnsiString;
  procedure ReadVersion( var aInfo : TDoomNetworkVersionInfo; aNode : TDOMElement );
  begin
    if aNode = nil then
    begin
      aInfo.Version   := StringToVersion('');
      aInfo.Patch     := '';
      aInfo.ModServer := '';
    end
    else
    begin
      aInfo.Version   := StringToVersion( aNode.GetAttribute('version') );
      aInfo.Patch     := aNode.GetAttribute('patch');
      aInfo.ModServer := aNode.GetAttribute({$IFDEF CPU64}'mod_url64'{$ELSE}'mod_url'{$ENDIF});
    end;
  end;
begin
  FMOTD          := '';
  FAlert         := '';
  FAlertURL      := '';
  ReadVersion( FStable, nil );
  ReadVersion( FBeta,   nil );
  iFileName      := ConfigurationPath+'info.xml';
  if (not Option_NetworkConnection) or (not FileExists( iFileName )) then Exit;
  try
    try
      iXML := nil;
      ReadXMLFile( iXML, iFileName );
      ReadVersion( FStable, TDOMElement(iXML.DocumentElement.GetElementsByTagName('stable').Item[0]) );
      ReadVersion( FBeta,   TDOMElement(iXML.DocumentElement.GetElementsByTagName('beta').Item[0]) );
      iElement := TDOMElement(iXML.DocumentElement.GetElementsByTagName('motd').Item[0]);
      if iElement <> nil then FMOTD := iElement.TextContent;
      iElement := TDOMElement(iXML.DocumentElement.GetElementsByTagName('alert').Item[0]);
      if iElement <> nil then
      begin
        FAlert    := iElement.TextContent;
        FAlertURL := iElement.GetAttribute('url');
      end;
    finally
      FreeAndNil( iXML );
    end;
  except on Exception do
    begin
      Log('Corrupted info.xml!');
      DeleteFile( PChar(iFileName) );
    end;
  end;
end;

{ TDownloadTask }

constructor TDownloadTask.Create( const aHostName, aFileName, aTarget : AnsiString);
begin
  HostName   := aHostName;
  FileName   := aFileName;
  Target     := aTarget;
  OnProgress := nil;
  Error      := '';
end;

procedure TDownloadTask.SetOnProgress(func: TNetProgressFunc);
begin
  OnProgress := Func;
end;

function TDownloadTask.Run: Boolean;
begin
  Log('DoomNet: downloading ' + HostName + FileName + ' to ' + Target + '...');
  Run := True;
  try
    with THTTPRequest.Create( HostName, 80 ) do
    try
      OnProgress := Self.OnProgress;
      Request( FileName );
      SaveToFile( Target );
      Log('DoomNet: download completed - ' + IntToStr(Total) + ' bytes received');
    finally
      Free;
    end;
  except on e : Exception do
    begin
      Log('DoomNet: '+e.ClassName+' caught - '+ e.Message );
      Error := e.Message;
      Run := False;
    end
  end;
end;

function TDownloadTask.GetError: AnsiString;
begin
  Exit( Error );
end;

destructor TDownloadTask.Destroy;
begin

end;




end.

