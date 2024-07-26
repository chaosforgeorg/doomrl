{$INCLUDE doomrl.inc}
unit doomaudio;
interface
uses vgenerics, vrltools, vluaconfig;

type TSoundEvent = packed record
       Time    : QWord;
       Coord   : TCoord2D;
       SoundID : Word;
     end;

type TAnsiStringArray = specialize TGArray< AnsiString >;
     TSoundEventHeap  = specialize TGHeap< TSoundEvent >;

type TDoomAudio = class
  constructor Create;
  procedure Configure( aConfig : TLuaConfig; aReload : Boolean = False );
  procedure Update( aMSec : DWord );
  procedure PlaySound( aSoundID : Word; aCoord : TCoord2D; aDelay : DWord = 0 );
  procedure PlayMusic( const MusicID : Ansistring );
  procedure PlayMusicOnce( const MusicID : Ansistring );
  function ResolveSoundID( const ResolveIDs: array of AnsiString ) : Word;

  destructor Destroy; override;
private
  procedure SoundQuery( nkey, nvalue : Variant );
  procedure MusicQuery( nkey, nvalue : Variant );
private
  FTime        : QWord;
  FSoundEvents : TSoundEventHeap;

  // Temporary values when loading
  FSoundKeys   : TAnsiStringArray;
  FSoundValues : TAnsiStringArray;
  FMusicKeys   : TAnsiStringArray;
  FMusicValues : TAnsiStringArray;
end;

implementation

uses sysutils,
     vdebug, vsystems, vmath, vsound, vfmodsound, vsdlsound,
     doomio, dfplayer, dfdata;

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
var iCount   : DWord;
    iProgress: DWord;
begin
  FSoundEvents.Clear;
    if SoundVersion and (Option_SoundEngine <> 'NONE') then
  begin
    Option_SoundVol := aConfig.Configure('SoundVolume',Option_SoundVol);
    Option_MusicVol := aConfig.Configure('MusicVolume',Option_MusicVol);

    if Option_Music or Option_Sound then
    begin
      if Option_SoundVol > 25 then Option_SoundVol := 25;
      if Option_MusicVol > 25 then Option_MusicVol := 25;
      if not aReload then
      begin
        if Option_SoundEngine = 'FMOD'
          then Sound := Systems.Add(TFMODSound.Create) as TSound
          else Sound := Systems.Add(TSDLSound.Create(Option_SDLMixerFreq, Option_SDLMixerFormat, Option_SDLMixerChunkSize ) ) as TSound;
      end
      else
        Sound.Reset;
      Sound.SetSoundVolume(5*Option_SoundVol);
      Sound.SetMusicVolume(5*Option_MusicVol);

      if aReload then
      begin
        FSoundKeys   := TAnsiStringArray.Create;
        FSoundValues := TAnsiStringArray.Create;
        FMusicKeys   := TAnsiStringArray.Create;
        FMusicValues := TAnsiStringArray.Create;
        if Option_Music then
          aConfig.EntryFeed('Music', @MusicQuery );
        if Option_Sound then
          aConfig.RecEntryFeed('Sound', @SoundQuery );

        IO.LoadStart( (FSoundKeys.Size+FMusicKeys.Size) div 2 );
        iProgress    := 0;

        if FSoundKeys.Size > 0 then
          for iCount := 0 to FSoundKeys.Size - 1 do
          begin
            Sound.RegisterSample(DataPath+FSoundValues[iCount],FSoundKeys[iCount]);
            Inc( iProgress );
            if iProgress mod 20 = 0 then
              IO.LoadProgress( iProgress div 2 );
          end;

        if FMusicKeys.Size > 0 then
          for iCount := 0 to FMusicKeys.Size - 1 do
          begin
            Sound.RegisterMusic(DataPath+FMusicValues[iCount],FMusicKeys[iCount]);
            Inc( iProgress );
            if iProgress mod 20 = 0 then
              IO.LoadProgress( iProgress div 2 );
          end;
        IO.LoadProgress( iProgress div 2 );
        FreeAndNil( FSoundKeys );
        FreeAndNil( FSoundValues );
        FreeAndNil( FMusicKeys );
        FreeAndNil( FMusicValues );
      end;
    end;
  end;
end;

procedure TDoomAudio.SoundQuery(nkey,nvalue : Variant);
var iKey, iValue : AnsiString;
begin
  iKey   := LowerCase(nKey);
  iValue := nValue;
  FSoundKeys.Push( iKey );
  FSoundValues.Push( iValue );
end;

procedure TDoomAudio.MusicQuery(nkey,nvalue : Variant);
var iKey, iValue : AnsiString;
begin
  iKey   := LowerCase(nKey);
  iValue := nValue;
  FMusicKeys.Push( iKey );
  FMusicValues.Push( iValue );
end;

procedure TDoomAudio.PlaySound( aSoundID : Word; aCoord : TCoord2D; aDelay : DWord = 0 );
var iVolume     : Byte;
    iPan        : Byte;
    iDist       : Word;
    iPos        : TCoord2D;
    iSoundEvent : TSoundEvent;
begin
  if aSoundID = 0 then Exit;
  if (not SoundVersion) or (not Option_Sound) or SoundOff then Exit;
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
  if (not SoundVersion) or (not Option_Music) then Exit;
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
  if (not SoundVersion) or (not Option_Music) then Exit;
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
end;

end.

