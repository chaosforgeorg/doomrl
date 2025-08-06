{$INCLUDE drl.inc}
{
 ----------------------------------------------------
Copyright (c) 2002-2025 by Kornel Kisielewicz
----------------------------------------------------
}
unit drlaudio;
interface
uses classes, vgenerics, vrltools, vluaconfig, vdf;

type TSoundEvent = packed record
       Time    : QWord;
       Coord   : TCoord2D;
       SoundID : Word;
     end;

type TAudioEntry = record
       ID       : Ansistring;
       Root     : Ansistring;
       FileName : Ansistring;
       IsMusic  : Boolean;
       DataFile : TVDataFile;
     end;



type TAudioRegistry   = specialize TGArray< TAudioEntry >;
     TAudioLookup     = specialize TGHashMap< Integer >;
     TSoundEventHeap  = specialize TGHeap< TSoundEvent >;


type TDRLAudio = class
  constructor Create;
  procedure Reconfigure;
  procedure Configure( aConfig : TLuaConfig; aReload : Boolean = False );
  function LoadBindingFile( const aFile, aRoot : Ansistring ) : Boolean;
  function LoadBindingDataFile( aData : TVDataFile; const aFile, aRoot : Ansistring ) : Boolean;
  procedure Load;
  procedure Update( aMSec : DWord );
  procedure PlaySound( aSoundID : Word; aCoord : TCoord2D; aDelay : DWord = 0 );
  procedure PlayMusic( const MusicID : Ansistring; aNotFound : Boolean = False );
  procedure PlayMusicOnce( const MusicID : Ansistring );
  function ResolveSoundID( const ResolveIDs: array of AnsiString ) : Word;
  function GetSampleID( const aID: AnsiString ) : Word;
  destructor Destroy; override;
private
  procedure Register( const aID, aFileName : AnsiString; aMusic : Boolean; const aRoot : AnsiString );
  procedure SoundQuery( nkey, nvalue : Variant );
  procedure MusicQuery( nkey, nvalue : Variant );
private
  FLastMusic   : Ansistring;
  FTime        : QWord;
  FSoundEvents : TSoundEventHeap;
  FCurrentData : TVDataFile;


  FAudioRegistry : TAudioRegistry;
  FMusicCount    : DWord;
  FAudioLookup   : TAudioLookup;
  FRoot          : Ansistring;
end;

implementation

uses sysutils, math,
     vdebug, vutil, vsystems, vmath, vsound, vfmodsound, vsdlsound,
     drlio, drlconfiguration, dfplayer, dfdata;

function DRLSoundEventCompare( const Item1, Item2: TSoundEvent ): Integer;
begin
       if Item1.Time < Item2.Time then Exit(1)
  else if Item1.Time > Item2.Time then Exit(-1)
  else Exit(0);
end;

constructor TDRLAudio.Create;
begin
  FSoundEvents := TSoundEventHeap.Create( @DRLSoundEventCompare );
  FTime        := 0;
  FLastMusic   := '';

  FAudioRegistry := TAudioRegistry.Create;
  FAudioLookup   := TAudioLookup.Create;
  FMusicCount    := 0;
end;

procedure TDRLAudio.Reconfigure;
var iOldMusic : Integer;
begin
  if not Assigned( Sound ) then Exit;

  iOldMusic := Setting_MusicVolume;

  Setting_MenuSound        := Configuration.GetBoolean( 'menu_sound' );
  Setting_MusicVolume      := Configuration.GetInteger( 'music_volume' );
  Setting_SoundVolume      := Configuration.GetInteger( 'sound_volume' );

  Sound.SetSoundVolume(4*Setting_SoundVolume);
  Sound.SetMusicVolume(2*Setting_MusicVolume);

  if Setting_MusicVolume = 0
    then Sound.Silence
    else if iOldMusic = 0 then
       PlayMusic( FLastMusic );
end;

procedure TDRLAudio.Update( aMSec : DWord );
var iSoundEvent : TSoundEvent;
begin
  FTime += aMSec;
  while (not FSoundEvents.isEmpty) and (FSoundEvents.Top.Time <= FTime) do
  begin
    iSoundEvent := FSoundEvents.Pop;
    PlaySound( iSoundEvent.SoundID, iSoundEvent.Coord );
  end;
end;

procedure TDRLAudio.Configure ( aConfig : TLuaConfig; aReload : Boolean ) ;
begin
  FSoundEvents.Clear;
  if SoundVersion and (Option_SoundEngine <> 'NONE') then
  begin
    if Option_Music or Option_Sound then
    begin
      if not aReload then
      begin
        if Option_SoundEngine = 'FMOD'
          then Sound := Systems.Add( TFMODSound.Create ) as TSound
          else Sound := Systems.Add( TSDLSound.Create ) as TSound;
      end
      else
        Sound.Reset;
    end;
  end;
end;

function TDRLAudio.LoadBindingFile( const aFile, aRoot : Ansistring ) : Boolean;
var iState : TLuaConfig;
begin
  FCurrentData := nil;
  if not FileExists( aFile ) then Exit( False );
  FRoot  := aRoot;
  Result := False;
  try
    iState := TLuaConfig.Create( aFile );
    if Option_Music and iState.TableExists('music') then iState.EntryFeed( 'music', @MusicQuery );
    if Option_Sound and iState.TableExists('sound') then iState.RecEntryFeed( 'sound', @SoundQuery );
  finally
    iState.Free;
  end;
  Result := True;
end;

function TDRLAudio.LoadBindingDataFile( aData : TVDataFile; const aFile, aRoot : Ansistring ) : Boolean;
var iStream : TStream;
    iSize   : Integer;
    iState  : TLuaConfig;
begin
  if not aData.FileExists( aFile ) then Exit( False );
  FCurrentData := aData;
  iSize   := aData.GetFileSize( aFile );
  iStream := aData.GetFile( aFile );
  try
    FRoot  := aRoot;
    iState := TLuaConfig.Create;
    iState.Load( iStream, iSize, aFile );
    if Option_Music and iState.TableExists('music') then iState.EntryFeed( 'music', @MusicQuery );
    if Option_Sound and iState.TableExists('sound') then iState.RecEntryFeed( 'sound', @SoundQuery );
  finally
    FreeAndNil( iState );
    FreeAndNil( iStream );
  end;
  Exit( True );
end;


procedure TDRLAudio.Load;
var iCount   : DWord;
    iProgress: DWord;
    iProgMod : Single;
    iDataFile: TVDataFile;

  procedure RegisterMusic( const aPath : Ansistring; aID : Ansistring );
  var iFileName : Ansistring;
      iStream   : TStream;
  begin
    if iDataFile <> nil then
    begin
      iFileName := ExtractFileName( aPath );
      if iDataFile.FileExists( iFileName, 'music' ) then
      begin
        iStream := iDataFile.GetFile( iFileName, 'music' );
        try
          Sound.RegisterMusic( iStream, iDataFile.GetFileSize( iFileName, 'music' ), aID, ExtractFileExt( iFileName ) );
        finally
          FreeAndNil( iStream );
        end;
        Exit;
      end;
    end;
    Sound.RegisterMusic( aPath, aID );
  end;

  procedure RegisterSample( const aPath : Ansistring; aID : Ansistring );
  var iFileName : Ansistring;
      iStream   : TStream;
  begin
    if iDataFile <> nil then
    begin
      iFileName := ExtractFileName( aPath );
      if iDataFile.FileExists( iFileName, 'sound' ) then
      begin
        iStream := iDataFile.GetFile( iFileName, 'sound' );
        try
          Sound.RegisterSample( iStream, iDataFile.GetFileSize( iFileName, 'sound' ), aID );
        finally
          FreeAndNil( iStream );
        end;
        Exit;
      end;
    end;
    Sound.RegisterSample( aPath, aID );
  end;

begin
  iProgMod := 0;
  if FAudioRegistry.Size > 0 then
    iProgMod  := 50 / Single(FAudioRegistry.Size);
  iProgress := IO.LoadCurrent;

  if FAudioRegistry.Size > 0 then
    for iCount := 0 to FAudioRegistry.Size - 1 do
      with FAudioRegistry[ iCount ] do
      begin
        iDataFile := DataFile;
        if IsMusic
          then RegisterMusic( Root + FileName, ID  )
          else RegisterSample( Root + FileName, ID  );
        if iCount mod 10 = 0 then
          IO.LoadProgress( Floor(iProgMod * iCount) + iProgress );
      end;
  IO.LoadProgress( 100 );
end;

procedure TDRLAudio.SoundQuery(nkey,nvalue : Variant);
var iKey, iValue : AnsiString;
begin
  iKey   := LowerCase(nKey);
  iValue := nValue;
  Register( iKey, iValue, False, FRoot );
end;

procedure TDRLAudio.MusicQuery(nkey,nvalue : Variant);
var iKey, iValue : AnsiString;
begin
  iKey   := LowerCase(nKey);
  iValue := nValue;
  Register( iKey, iValue, True, FRoot );
end;

procedure TDRLAudio.Register( const aID, aFileName : AnsiString; aMusic : Boolean; const aRoot : AnsiString );
var iIndex : Integer;
    iEntry : TAudioEntry;
begin
  iIndex := FAudioLookup.Get( aID, -1 );
  iEntry.ID       := aID;
  iEntry.FileName := aFileName;
  iEntry.Root     := aRoot;
  iEntry.IsMusic  := aMusic;
  iEntry.DataFile := FCurrentData;

  if iIndex >= 0 then
  begin
    if FAudioRegistry[iIndex].Root = aRoot then
      Log( LOGWARN, 'Audio ID "'+aID+'" redefinition within same module!' );
    if FAudioRegistry[iIndex].IsMusic <> aMusic then
    begin
      Log( LOGERROR, 'Audio ID "'+aID+'" redefinition type mismatch!' );
      Exit;
    end;
    FAudioRegistry[iIndex] := iEntry;
  end
  else
  begin
    iIndex := FAudioRegistry.Size;
    FAudioRegistry.Push( iEntry );
    FAudioLookup[ aID ] := iIndex;
  end;
end;

procedure TDRLAudio.PlaySound( aSoundID : Word; aCoord : TCoord2D; aDelay : DWord = 0 );
var iVolume     : Byte;
    iPan        : Byte;
    iDist       : Word;
    iPos        : TCoord2D;
    iSoundEvent : TSoundEvent;
begin
  if aSoundID = 0 then Exit;
  if (not SoundVersion) or (not Option_Sound) or SoundOff or ( Setting_SoundVolume = 0 ) then Exit;
  if aDelay > 0 then
  begin
    iSoundEvent.Coord   := aCoord;
    iSoundEvent.SoundID := aSoundID;
    iSoundEvent.Time    := FTime + aDelay;
    FSoundEvents.Insert( iSoundEvent );
    Exit;
  end;

  iPos := Player.Position;

  iDist := Distance(aCoord,iPos);
  if iDist <= 1 then iVolume := 127 else
                    iVolume := Clamp((25 - iDist) * 6,0,127);
  if iVolume <> 0 then
    if iVolume < 30 then iVolume := 30;

  iPan := Clamp((aCoord.x-iPos.x) * 15,-128,127)+128;
  Sound.PlaySample(aSoundID,iVolume,iPan);
end;


function TDRLAudio.ResolveSoundID(const ResolveIDs: array of AnsiString): Word;
var c : DWord;
begin
  if (not SoundVersion) or (not Option_Sound) or SoundOff then Exit(0);
  for c := Low(ResolveIDs) to High(ResolveIDs) do
    if ResolveIDs[c] <> '' then
    begin
      Result := Sound.GetSampleID(ResolveIDs[c]);
      if Result <> 0 then Exit( Result );
    end;
  Exit(0);
end;

function TDRLAudio.GetSampleID( const aID: AnsiString ) : Word;
begin
  if (not SoundVersion) or (not Option_Sound) or SoundOff then Exit(0);
  Exit( Sound.GetSampleID( aID ) );
end;

procedure TDRLAudio.PlayMusic(const MusicID : Ansistring; aNotFound : Boolean = False );
begin
  FLastMusic := MusicID;
  if (not SoundVersion) or (not Option_Music) or ( Setting_MusicVolume = 0 ) then Exit;
  try
    if MusicID = '' then Sound.Silence;
    if MusicOff then Exit;
    if Sound.MusicExists(MusicID)
      then Sound.PlayMusic(MusicID)
      else if aNotFound
        then Exit
        else PlayMusic('level'+IntToStr(Random(23)+2), True );
  except
    on e : Exception do
    begin
      Log('PlayMusic raised exception (' + E.ClassName + '): ' + e.message);
      IO.Msg( 'PlayMusic raised exception: ' + e.message );
    end;
  end;
end;

procedure TDRLAudio.PlayMusicOnce(const MusicID : Ansistring);
begin
  if (not SoundVersion) or (not Option_Music) or ( Setting_MusicVolume = 0 )  then Exit;
  try
    if MusicID = '' then Sound.Silence;
    if MusicOff then Exit;
    if Sound.MusicExists(MusicID) then Sound.PlayMusicOnce(MusicID);
  except
      on e : Exception do
      begin
        Log('PlayMusicOnce raised exception (' + E.ClassName + '): ' + e.message);
        IO.Msg( 'PlayMusic raised exception: ' + e.message );
      end;
  end;
end;

destructor TDRLAudio.Destroy;
begin
  FreeAndNil( FSoundEvents );
  FreeAndNil( FAudioRegistry );
  FreeAndNil( FAudioLookup );
end;

end.

