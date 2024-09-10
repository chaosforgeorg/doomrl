{$INCLUDE doomrl.inc}
unit doomaudio;
interface
uses vgenerics, vrltools, vluaconfig;

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
     end;



type TAudioRegistry   = specialize TGArray< TAudioEntry >;
     TAudioLookup     = specialize TGHashMap< Integer >;
     TSoundEventHeap  = specialize TGHeap< TSoundEvent >;


type TDoomAudio = class
  constructor Create;
  procedure Reconfigure;
  procedure Configure( aConfig : TLuaConfig; aReload : Boolean = False );
  procedure Load;
  procedure Update( aMSec : DWord );
  procedure PlaySound( aSoundID : Word; aCoord : TCoord2D; aDelay : DWord = 0 );
  procedure PlayMusic( const MusicID : Ansistring );
  procedure PlayMusicOnce( const MusicID : Ansistring );
  function ResolveSoundID( const ResolveIDs: array of AnsiString ) : Word;
  destructor Destroy; override;
private
  procedure Register( const aID, aFileName : AnsiString; aMusic : Boolean; const aRoot : AnsiString );
  procedure SoundQuery( nkey, nvalue : Variant );
  procedure MusicQuery( nkey, nvalue : Variant );
private
  FLastMusic   : Ansistring;
  FTime        : QWord;
  FSoundEvents : TSoundEventHeap;

  FAudioRegistry : TAudioRegistry;
  FAudioLookup   : TAudioLookup;
end;

implementation

uses sysutils,
     vdebug, vutil, vsystems, vmath, vsound, vfmodsound, vsdlsound,
     doomio, doomconfiguration, dfplayer, dfdata;

function DoomSoundEventCompare( const Item1, Item2: TSoundEvent ): Integer;
begin
       if Item1.Time < Item2.Time then Exit(1)
  else if Item1.Time > Item2.Time then Exit(-1)
  else Exit(0);
end;

constructor TDoomAudio.Create;
begin
  FSoundEvents := TSoundEventHeap.Create( @DoomSoundEventCompare );
  FTime        := 0;
  FLastMusic   := '';

  FAudioRegistry := TAudioRegistry.Create;
  FAudioLookup   := TAudioLookup.Create;
end;

procedure TDoomAudio.Reconfigure;
var iOldMusic : Integer;
begin
  if not Assigned( Sound ) then Exit;

  iOldMusic := Setting_MusicVolume;

  Setting_MenuSound        := Configuration.GetBoolean( 'menu_sound' );
  Setting_MusicVolume      := Configuration.GetInteger( 'music_volume' );
  Setting_SoundVolume      := Configuration.GetInteger( 'sound_volume' );

  Sound.SetSoundVolume(5*Setting_SoundVolume);
  Sound.SetMusicVolume(5*Setting_MusicVolume);

  if Setting_MusicVolume = 0
    then Sound.Silence
    else if iOldMusic = 0 then
       PlayMusic( FLastMusic );
end;

procedure TDoomAudio.Update( aMSec : DWord );
var iSoundEvent : TSoundEvent;
begin
  FTime += aMSec;
  while (not FSoundEvents.isEmpty) and (FSoundEvents.Top.Time <= FTime) do
  begin
    iSoundEvent := FSoundEvents.Pop;
    PlaySound( iSoundEvent.SoundID, iSoundEvent.Coord );
  end;
end;

procedure TDoomAudio.Configure ( aConfig : TLuaConfig; aReload : Boolean ) ;
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
      begin
        Sound.Reset;
        if Option_Music then aConfig.EntryFeed( 'Music', @MusicQuery );
        if Option_Sound then aConfig.RecEntryFeed( 'Sound', @SoundQuery );
      end;
    end;
  end;
end;

procedure TDoomAudio.Load;
var iCount   : DWord;
    iProgress: DWord;
begin
  IO.LoadStart( FAudioRegistry.Size );
  iProgress    := 0;

  if FAudioRegistry.Size > 0 then
    for iCount := 0 to FAudioRegistry.Size - 1 do
      with FAudioRegistry[ iCount ] do
      begin
        if IsMusic
          then Sound.RegisterMusic( DataPath + Root + FileName, ID  )
          else Sound.RegisterSample( DataPath + Root + FileName, ID  );
        Inc( iProgress );
        if iProgress mod 20 = 0 then
          IO.LoadProgress( iProgress );
      end;
  IO.LoadProgress( iProgress );
end;

procedure TDoomAudio.SoundQuery(nkey,nvalue : Variant);
var iKey, iValue : AnsiString;
begin
  iKey   := LowerCase(nKey);
  iValue := nValue;
  Register( iKey, iValue, False, '' );
end;

procedure TDoomAudio.MusicQuery(nkey,nvalue : Variant);
var iKey, iValue : AnsiString;
begin
  iKey   := LowerCase(nKey);
  iValue := nValue;
  Register( iKey, iValue, True, '' );
end;

procedure TDoomAudio.Register( const aID, aFileName : AnsiString; aMusic : Boolean; const aRoot : AnsiString );
var iIndex : Integer;
    iEntry : TAudioEntry;
begin
  iIndex := FAudioLookup.Get( aID, -1 );
  iEntry.ID       := aID;
  iEntry.FileName := aFileName;
  iEntry.Root     := aRoot;
  iEntry.IsMusic  := aMusic;

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

procedure TDoomAudio.PlaySound( aSoundID : Word; aCoord : TCoord2D; aDelay : DWord = 0 );
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


function TDoomAudio.ResolveSoundID(const ResolveIDs: array of AnsiString): Word;
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

procedure TDoomAudio.PlayMusic(const MusicID : Ansistring);
begin
  FLastMusic := MusicID;
  if (not SoundVersion) or (not Option_Music) or ( Setting_MusicVolume = 0 ) then Exit;
  try
    if MusicID = '' then Sound.Silence;
    if MusicOff then Exit;
    if Sound.MusicExists(MusicID) then Sound.PlayMusic(MusicID)
                                  else PlayMusic('level'+IntToStr(Random(23)+2));
  except
    on e : Exception do
    begin
      Log('PlayMusic raised exception (' + E.ClassName + '): ' + e.message);
      IO.Msg( 'PlayMusic raised exception: ' + e.message );
    end;
  end;
end;

procedure TDoomAudio.PlayMusicOnce(const MusicID : Ansistring);
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

destructor TDoomAudio.Destroy;
begin
  FreeAndNil( FSoundEvents );
  FreeAndNil( FAudioRegistry );
  FreeAndNil( FAudioLookup );
end;

end.

