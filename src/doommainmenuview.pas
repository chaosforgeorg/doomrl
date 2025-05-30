{$INCLUDE doomrl.inc}
unit doommainmenuview;
interface
uses viotypes, vgenerics, vtextures, dfdata, doomio;

type TMainMenuViewMode = (
  MAINMENU_FIRST, MAINMENU_INTRO, MAINMENU_MENU,
  MAINMENU_DIFFICULTY, MAINMENU_FAIR, MAINMENU_KLASS, MAINMENU_TRAIT, MAINMENU_CTYPE, MAINMENU_NAME,
  MAINMENU_CPICK, MAINMENU_CFIRST, MAINMENU_CSECOND,
  MAINMENU_BADSAVE, MAINMENU_DONE );

type TMainMenuEntry = record
  Name  : Ansistring;
  Desc  : Ansistring;
  Allow : Boolean;
  Extra : Ansistring;
  ID    : Ansistring;
  NID   : Byte;
end;

type TMainMenuEntryArray = specialize TGArray< TMainMenuEntry >;

type TMainMenuView = class( TInterfaceLayer )
  constructor Create( aInitial : TMainMenuViewMode = MAINMENU_FIRST; aResult : TMenuResult = nil );
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
  destructor Destroy; override;
protected
  procedure Render;
  procedure UpdateFirst;
  procedure UpdateIntro;
  procedure UpdateMenu;
  procedure UpdateBadSave;
  procedure UpdateFair;
  procedure UpdateName;
  procedure UpdateDifficulty;
  procedure UpdateKlass;
  procedure UpdateChallengeType;
  procedure UpdateChallenge;
  procedure OnCancel;
  procedure SetSoundCallback;
  procedure ResetSoundCallback;
  procedure ReloadArrays;
  procedure ReloadChallenge( aType : Byte );
  procedure RenderASCIILogo;
protected
  FSize        : TIOPoint;
  FRect        : TIORect;
  FMode        : TMainMenuViewMode;
  FFirst       : Ansistring;
  FIntro1      : Ansistring;
  FIntro2      : Ansistring;
  FMOTD        : Ansistring;
  FResult      : TMenuResult;
  FSaveExists  : Boolean;

  FArrayCType  : TMainMEnuEntryArray;
  FArrayDiff   : TMainMEnuEntryArray;
  FArrayKlass  : TMainMEnuEntryArray;
  FArrayChal   : TMainMEnuEntryArray;
  FTitleChal   : Ansistring;
  FChallenges  : Boolean;

  FBGTexture   : TTextureID;
  FLogoTexture : TTextureID;
  FName        : array[0..47] of Char;
end;

implementation

uses {$IFDEF WINDOWS}Windows,{$ELSE}Unix,{$ENDIF}
     math, sysutils,
     vutil, vtig, vtigstyle, vtigio, vimage, vgltypes, vluasystem, vluavalue, vsound,
     dfhof,
     doombase, doomgfxio, doomplayerview, doomhelpview, doomsettingsview, doompagedview;

const MAINMENU_ID = 'mainmenu';

var ChallengeType : array[1..4] of TMainMenuEntry =
((
   Name : 'Angel Game';
   Desc : 'Play one of the DRL classic challenge games that place restrictions on play style or modify play behaviour.'#10#10'Reach {yPrivate FC} rank to unlock!';
   Allow : True; Extra : ''; ID : ''; NID : 0;
),(
   Name : 'Dual-angel Game';
   Desc : 'Mix two DRL challenge game types. Only the first counts highscore-wise - the latter is your own challenge!'#10#10'Reach {ySergeant} rank to unlock!';
   Allow : True; Extra : ''; ID : ''; NID : 0;
),(
   Name : 'Archangel Game';
   Desc : 'Play one of the DRL challenge in its ultra hard form. Do not expect fairness here!'#10#10'Reach {ySergeant} rank to unlock!';
   Allow : True; Extra : ''; ID : ''; NID : 0;
),(
   Name : 'Custom Challenge';
   Desc : 'Play one of many custom DRL challenge levels and episodes. Download new ones from the {yCustom game/Download Mods} option in the main menu.';
   Allow : True; Extra : ''; ID : ''; NID : 0;
));

const CTYPE_ANGEL  = 1;
      CTYPE_DANGEL = 2;
      CTYPE_AANGEL = 3;
      CTYPE_CUSTOM = 4;

      CTYPE_SECOND = 10;


constructor TMainMenuView.Create( aInitial : TMainMenuViewMode = MAINMENU_FIRST; aResult : TMenuResult = nil );
begin
  VTIG_EventClear;
  VTIG_ResetSelect( MAINMENU_ID );

  FMode       := aInitial;
  FResult     := aResult;
  FSaveExists := False;
  FArrayCType := nil;
  FArrayDiff  := nil;
  FArrayKlass := nil;
  FArrayChal  := nil;
  FTitleChal  := '';
  FSize       := Point( 80, 25 );
  FChallenges := LuaSystem.Get( ['chal','__counter'], 0 ) > 0;

  if not ( FMode in [MAINMENU_FIRST,MAINMENU_INTRO] ) then
    Assert( aResult <> nil, 'nil result passed!' );

  if FMode = MAINMENU_FIRST then
  begin
    if not FileExists( WritePath + 'drl.prc' ) then
    begin
      WriteFileString( WritePath + 'drl.prc', 'DRL was already run.' );

      FFirst := AnsiString( LuaSystem.ProtectedCall( [CoreModuleID,'GetFirstText'], [] ) );
      if FFirst = '' then FMode := MAINMENU_INTRO;
    end
    else
      FMode := MAINMENU_INTRO;
  end;

  FMOTD := AnsiString( LuaSystem.ProtectedCall( [CoreModuleID,'GetMOTD'], [] ) );

  if FMode in [MAINMENU_FIRST,MAINMENU_INTRO] then
  begin
    FIntro1 := AnsiString( LuaSystem.ProtectedCall( [CoreModuleID,'GetLogoBox'], [] ) );
    FIntro2 := AnsiString( LuaSystem.ProtectedCall( [CoreModuleID,'GetLogoText'], [] ) );
  end;

  if GraphicsVersion then
  begin
    FBGTexture   := (IO as TDoomGFXIO).Textures.TextureID['background'];
    FLogoTexture := (IO as TDoomGFXIO).Textures.TextureID['logo'];
  end;

  if FMode = MAINMENU_MENU then
  begin
    FSaveExists := Doom.SaveExists;
  end;
end;

procedure TMainMenuView.Update( aDTime : Integer );
begin
  if FMode = MAINMENU_KLASS then
  begin
    if FArrayKlass.Size = 1 then
    begin
      FResult.Klass := FArrayKlass[0].NID;
      FMode         := MAINMENU_TRAIT;
      IO.PushLayer( TPlayerView.CreateTrait( True, FResult.Klass ) );
    end;
  end;
  VTIG_Clear;
  if GraphicsVersion then Render;
  if not IO.IsTopLayer( Self ) then
  begin
    ResetSoundCallback;
    Exit;
  end;
  SetSoundCallback;

  if not GraphicsVersion then
    if FMode in [MAINMENU_INTRO,MAINMENU_MENU,MAINMENU_DIFFICULTY,MAINMENU_KLASS,MAINMENU_FAIR,MAINMENU_CTYPE,MAINMENU_NAME] then
      RenderASCIILogo;

  case FMode of
    MAINMENU_FIRST      : UpdateFirst;
    MAINMENU_INTRO      : UpdateIntro;
    MAINMENU_MENU       : UpdateMenu;
    MAINMENU_BADSAVE    : UpdateBadSave;
    MAINMENU_DIFFICULTY : UpdateDifficulty;
    MAINMENU_KLASS      : UpdateKlass;
    MAINMENU_FAIR       : UpdateFair;
    MAINMENU_CTYPE      : UpdateChallengeType;
    MAINMENU_NAME       : UpdateName;
    MAINMENU_CPICK      : UpdateChallenge;
    MAINMENU_CFIRST     : UpdateChallenge;
    MAINMENU_CSECOND    : UpdateChallenge;
    MAINMENU_TRAIT      :
    begin
      if TPlayerView.TraitPick = 255 then
      begin
        OnCancel;
        FMode := MAINMENU_MENU;
      end
      else
      begin
        FResult.Trait := TPlayerView.TraitPick;
        if (Option_AlwaysName <> '') or Setting_AlwaysRandomName
          then FMode := MAINMENU_DONE
          else begin
            IO.Root.Console.ShowCursor;
            FName[0] := #0;
            IO.Driver.StartTextInput;
            FMode := MAINMENU_NAME;
          end;
      end;
    end;
  end;
end;

procedure TMainMenuView.UpdateFirst;
begin
  VTIG_FreeLabel( FFirst, Rectangle(5,2,70,23) );
  if VTIG_EventCancel or VTIG_EventConfirm then
    FMode := MAINMENU_INTRO;
end;

procedure TMainMenuView.UpdateIntro;
begin
  VTIG_FreeLabel( FIntro1, Point( 28, 9 ) );
  VTIG_FreeLabel( FIntro2, Rectangle(2,14,77,11) );

  if VTIG_EventCancel or VTIG_EventConfirm then
    FMode := MAINMENU_DONE;
end;

const
  TextContinueGame  = '{b--} Continue game {b---}';
  TextNewGame       = '{b-----} New game {b-----}';
  TextChallengeGame = '{b--} Challenge game {b--}';
  TextJHC           = '{B==} Wishlist JHC! {B===}';
  TextShowHighscore = '{b-} Show highscores {b--}';
  TextShowPlayer    = '{b---} Show player {b----}';
  TextExit          = '{b------} Exit {b--------}';
  TextHelp          = '{b------} Help {b--------}';
  TextSettings      = '{b----} Settings {b------}';

const
  JHCURL = 'https://store.steampowered.com/app/3126530/Jupiter_Hell_Classic/';

procedure TMainMenuView.UpdateMenu;
begin
  IO.Root.Console.HideCursor;
  VTIG_PushStyle( @TIGStyleFrameless );
  VTIG_Begin( 'mainmenu', Point( 24, 9 ), Point( 29, 14 ) );
  VTIG_PopStyle;
    VTIG_PushStyle( @TIGStyleColored );
    if FSaveExists then
      if VTIG_Selectable( TextContinueGame ) then
      begin
        if Doom.LoadSaveFile then
        begin
          FResult.Loaded := True;
          FMode := MAINMENU_DONE;
        end
        else
          FMode := MAINMENU_BADSAVE;
      end;
    if not FSaveExists then
      if VTIG_Selectable( TextNewGame ) then
      begin
        FResult.Reset;
        ReloadArrays;
        FMode := MAINMENU_DIFFICULTY;
      end;
    if VTIG_Selectable( TextChallengeGame, (not FSaveExists) and FChallenges ) then
    begin
      FResult.Reset;
      ReloadArrays;
      FMode := MAINMENU_CTYPE;
    end;
    if VTIG_Selectable( TextShowHighscore ) then IO.PushLayer( TPagedView.Create( HOF.GetPagedScoreReport ) );
    if VTIG_Selectable( TextShowPlayer )    then IO.PushLayer( TPagedView.Create( HOF.GetPagedPlayerReport ) );
    if VTIG_Selectable( TextHelp )          then IO.PushLayer( THelpView.Create );
    if VTIG_Selectable( TextSettings )      then IO.PushLayer( TSettingsView.Create );
    if VTIG_Selectable( TextJHC ) then
    begin
      {$IFDEF UNIX}
      fpSystem('xdg-open ' + JHCURL); // Unix-based systems
      {$ENDIF}
      {$IFDEF WINDOWS}
        ShellExecute(0, 'open', PChar(JHCURL), nil, nil, SW_SHOWNORMAL); // Windows
      {$ENDIF}
    end;
    if VTIG_Selectable( TextExit ) then
    begin
      FResult.Quit := True;
      FMode := MAINMENU_DONE;
    end;
    VTIG_PopStyle;
  VTIG_End;

  VTIG_FreeLabel( FMOTD, Point(2,24) );


  if VTIG_EventCancel then
  begin
    OnCancel;
    if VTIG_Selected( MAINMENU_ID ) = 7
      then begin FMode := MAINMENU_DONE; FResult.Quit := True; end
      else VTIG_ResetSelect( MAINMENU_ID, 7 );
  end;
end;

procedure TMainMenuView.UpdateBadSave;
begin
  VTIG_BeginWindow('Corrupted save file', Point( 42, 8 ), Point(19,8) );
  VTIG_Text('Save file is corrupted! Removed corrupted save file, sorry :(.');
  VTIG_End('Press <{!Enter,Escape}> to continue...');
  IO.RenderUIBackground( Point(18,7), Point(60,15), 0.7 );
  if VTIG_EventCancel or VTIG_EventConfirm then
    FMode := MAINMENU_MENU;
end;

procedure TMainMenuView.UpdateFair;
begin
  VTIG_BeginWindow('Warning', Point( 40, 9 ), Point(21,14) );
  VTIG_PushStyle( @TIGStyleColored );
  VTIG_Text('Are you sure? This difficulty level isn''t even remotely fair!');
  VTIG_Text('');

  if VTIG_Selectable( 'Bring it on!' ) then
    FMode := MAINMENU_KLASS;
  if VTIG_Selectable( 'Cancel' ) then
    FMode := MAINMENU_DIFFICULTY;
  VTIG_PopStyle;
  VTIG_End();
  IO.RenderUIBackground( Point(20,13), Point(60,22), 0.7 );
  if VTIG_EventCancel then
  begin
    OnCancel;
    FMode := MAINMENU_DIFFICULTY;
  end;
end;

procedure TMainMenuView.UpdateName;
begin
  VTIG_PushStyle( @TIGStyleFrameless );
  VTIG_Begin( 'mainmenu_name', Point( 34, 4 ), Point(25,18) );
  VTIG_PopStyle;
  VTIG_PushStyle( @TIGStyleColored );
  VTIG_Text('Type a name for your character');
  if VTIG_Input(@FName[0],47) then
  begin
    FResult.Name := AnsiString(FName);
    IO.Driver.StopTextInput;
    IO.Root.Console.HideCursor;
    FMode := MAINMENU_DONE;
  end;
  VTIG_PopStyle;
  VTIG_End();
  IO.RenderUIBackground( Point(22,17), Point(58,21), 0.7 );

  if VTIG_EventCancel then
  begin
    IO.Driver.StopTextInput;
    IO.Root.Console.HideCursor;
    OnCancel;
    FMode := MAINMENU_MENU;
  end;
end;

procedure TMainMenuView.UpdateDifficulty;
var i : Integer;
begin
  VTIG_PushStyle( @TIGStyleFrameless );
  VTIG_Begin( 'mainmenu_difficulty', Point( 26, 9 ), Point( 29, 16 ) );
  VTIG_PopStyle;
    VTIG_PushStyle( @TIGStyleColored );
    for i := 0 to FArrayDiff.Size - 1 do
      if VTIG_Selectable( FArrayDiff[i].Name, FArrayDiff[i].Allow ) then
      begin
        FResult.Difficulty := FArrayDiff[i].NID;
        if FResult.Difficulty >= 5
          then FMode := MAINMENU_FAIR
          else FMode := MAINMENU_KLASS;
      end;
    VTIG_PopStyle;
  VTIG_End;

  IO.RenderUIBackground( Point(23,15), Point(57,22), 0.7 );
  if VTIG_EventCancel then
  begin
    FMode := MAINMENU_MENU;
    OnCancel;
  end;
end;

procedure TMainMenuView.UpdateKlass;
var iSelected, i, iLines : Integer;
begin
  iSelected := VTIG_Selected('mainmenu_klass');
  if iSelected < 0 then iSelected := 0;
  iLines := 8;
  if Length( FArrayKlass[iSelected].Desc ) > 255 then iLines := 13;
  VTIG_PushStyle( @TIGStyleFrameless );
  VTIG_Begin( 'mainmenu_klass_desc', Point( 47, iLines ), Point( 30, 16 ) );
  VTIG_PopStyle;
    VTIG_PushStyle( @TIGStyleColored );
    VTIG_Text( Padded( '- {!' + FArrayKlass[iSelected].Name + ' }', 48, '-' ) );
    VTIG_PopStyle;
    VTIG_Text( FArrayKlass[iSelected].Desc );
  VTIG_End;

  VTIG_PushStyle( @TIGStyleFrameless );
  VTIG_Begin( 'mainmenu_klass', Point( 16, 2+FArrayKlass.Size ), Point( 10, 16 ) );
  VTIG_PopStyle;
    VTIG_PushStyle( @TIGStyleColored );
    for i := 0 to FArrayKlass.Size - 1 do
      if VTIG_Selectable( FArrayKlass[i].Name, FArrayKlass[i].Allow ) then
      begin
        FResult.Klass := FArrayKlass[i].NID;
        FMode         := MAINMENU_TRAIT;
        IO.PushLayer( TPlayerView.CreateTrait( True, FResult.Klass ) );
      end;
    iSelected := VTIG_Selected;
    VTIG_PopStyle;
  VTIG_End;

  IO.RenderUIBackground(  Point(9,15), Point(25,17+FArrayKlass.Size), 0.7 );
  IO.RenderUIBackground( Point(28,15), Point(77,16+iLines), 0.7 );
  if VTIG_EventCancel then
  begin
    FMode := MAINMENU_MENU;
    OnCancel;
  end;
end;

procedure TMainMenuView.UpdateChallengeType;
var iSelected, i : Integer;
begin
  iSelected := VTIG_Selected('mainmenu_ctype');
  if iSelected < 0 then iSelected := 0;
  VTIG_PushStyle( @TIGStyleFrameless );
  VTIG_Begin( 'mainmenu_ctype_desc', Point( 47, 8 ), Point( 30, 16 ) );
  VTIG_PopStyle;
    VTIG_PushStyle( @TIGStyleColored );
    VTIG_Text( Padded( '- {!' + FArrayCType[iSelected].Name + ' }', 48, '-' ) );
    VTIG_PopStyle;
    VTIG_Text( FArrayCType[iSelected].Desc );
  VTIG_End;

  VTIG_PushStyle( @TIGStyleFrameless );
  VTIG_Begin( 'mainmenu_ctype', Point( 19, 5 ), Point( 9, 18 ) );
  VTIG_PopStyle;
    VTIG_PushStyle( @TIGStyleColored );
    for i := 0 to FArrayCType.Size - 1 do
      if VTIG_Selectable( FArrayCType[i].Name, FArrayCType[i].Allow ) then
      begin
        ReloadChallenge( i+1 );
        if i = 1
          then FMode := MAINMENU_CFIRST
          else FMode := MAINMENU_CPICK;
      end;
    iSelected := VTIG_Selected;
    VTIG_PopStyle;
  VTIG_End;

  IO.RenderUIBackground(  Point(7,17), Point(26,23), 0.7 );
  IO.RenderUIBackground( Point(28,15), Point(77,24), 0.7 );
  if VTIG_EventCancel then
  begin
    FMode := MAINMENU_MENU;
    OnCancel;
  end;
end;

procedure TMainMenuView.UpdateChallenge;
var iSelect : Integer;
    iCount  : Byte;
    iPick   : Integer;
begin
  VTIG_BeginWindow( FTitleChal, 'challenges_view', FSize );
    iSelect := -1;
    iPick   := -1;

    VTIG_BeginGroup( 28 );
      VTIG_PushStyle( @TIGStyleColored );
      for iCount := 0 to FArrayChal.Size-1 do
        if VTIG_Selectable( FArrayChal[iCount].Name, FArrayChal[iCount].Allow ) then
          iPick := iCount;
      iSelect := VTIG_Selected;
      VTIG_PopStyle;

      VTIG_EndGroup;

      VTIG_BeginGroup;
      if iSelect >= 0 then
      begin
          VTIG_Text( FArrayChal[iSelect].Name, VTIGDefaultStyle.Color[ VTIG_TITLE_COLOR ] );
          VTIG_Ruler;
          VTIG_Text( 'Rating: {!'+FArrayChal[iSelect].Extra+'}'#10#10+FArrayChal[iSelect].Desc );
      end;
      VTIG_EndGroup;

  FRect := VTIG_GetWindowRect;
  VTIG_End('{l<{!Up},{!Down}> select, <{!Enter}> select, <{!Escape}> cancel}');

  if VTIG_EventCancel then
  begin
    OnCancel;
    FMode := MAINMENU_MENU;

  end
  else if iPick >= 0 then
  begin
    case FMode of
      MAINMENU_CPICK   : begin FResult.Challenge := FArrayChal[iPick].ID;  FMode := MAINMENU_DIFFICULTY; end;
      MAINMENU_CFIRST  : begin FResult.Challenge := FArrayChal[iPick].ID;  FMode := MAINMENU_CSECOND; ReloadChallenge( CTYPE_SECOND ); end;
      MAINMENU_CSECOND : begin FResult.SChallenge := FArrayChal[iPick].ID; FMode := MAINMENU_DIFFICULTY; end;
    end;
    ReloadArrays;
  end;
  IO.RenderUIBackground( FRect.TopLeft, FRect.BottomRight - PointUnit );
end;

procedure TMainMenuView.OnCancel;
begin
  if (not Option_Sound) or (Sound = nil) or ( not Setting_MenuSound ) then Exit;
  if Sound.SampleExists('menu.cancel') then Sound.PlaySample('menu.cancel');
end;

procedure SoundCallback( aEvent : TTIGSoundEvent; aParam : Pointer );
begin
  if (not Option_Sound) or (Sound = nil) or ( not Setting_MenuSound ) then Exit;
  case aEvent of
    VTIG_SOUND_CHANGE : if Sound.SampleExists('menu.change') then Sound.PlaySample('menu.change');
    VTIG_SOUND_ACCEPT : if Sound.SampleExists('menu.pick')   then Sound.PlaySample('menu.pick');
  end;
end;

procedure TMainMenuView.SetSoundCallback;
begin
  VTIG_GetIOState.SoundCallback := @SoundCallback;
end;

procedure TMainMenuView.ResetSoundCallback;
begin
  VTIG_GetIOState.SoundCallback := nil;
end;


procedure TMainMenuView.Render;
var iIO             : TDoomGFXIO;
    iMin, iMax      : TGLVec2f;
    iSize, iSz, iTC : TGLVec2f;
    iImage          : TImage;
begin
  iIO := IO as TDoomGFXIO;
  Assert( iIO <> nil );

  iImage := iIO.Textures.Texture[ FBGTexture ].Image;
  iTC.Init( iImage.RawX / iImage.SizeX, iImage.RawY / iImage.SizeY );
  iSize.Init( IO.Driver.GetSizeX, IO.Driver.GetSizeY );
  iMin.Init( 0,0 );
  iMax := iSize - GLVec2f( 1, 1 );

  if (iImage.RawX / iImage.RawY) > (iSize.X / iSize.Y) then
  begin
    iSz.X  := iImage.RawX * (IO.Driver.GetSizeY / iImage.RawY);
    iMin.X := ( IO.Driver.GetSizeX - iSz.X ) / 2;
    iMax.X := iMin.X + iSz.X;
  end
  else
  begin
    iSz.Y  := iImage.RawY * (IO.Driver.GetSizeX / iImage.RawX);
    iMin.Y := ( IO.Driver.GetSizeY - iSz.Y ) / 2;
    iMax.Y := iMin.Y + iSz.Y;
  end;

  iIO.QuadSheet.PushTexturedQuad(
    GLVec2i(Floor(iMin.X), Floor(iMin.Y)),
    GLVec2i(Floor(iMax.X), Floor(iMax.Y)),
    GLVec2f(0,0),iTC,
    iIO.Textures.Texture[ FBGTexture ].GLTexture
  );

  if FMode = MAINMENU_FIRST then
    IO.RenderUIBackground( Point(4,1), Point(76,24), 0.7 );

  if ( FMode in [MAINMENU_INTRO,MAINMENU_MENU,MAINMENU_DIFFICULTY,MAINMENU_KLASS,MAINMENU_FAIR,MAINMENU_NAME,MAINMENU_CTYPE] )
    and IO.IsTopLayer( Self ) then
  begin
    iImage := iIO.Textures.Texture[ FLogoTexture ].Image;
    iMin.Y  := Floor(iSize.Y / 25) * (-8);
    if (FMode <> MAINMENU_INTRO)
      then begin iMax.Y  := Floor(iSize.Y / 25) * 24; iMin.Y := Floor(iSize.Y / 25) * (-10); end
      else iMax.Y  := Floor(iSize.Y / 25) * 18;
    iMin.X  := (iSize.X - (iMax.Y - iMin.Y)) / 2;
    iMax.X  := (iSize.X + (iMax.Y - iMin.Y)) / 2;

    iIO.QuadSheet.PushTexturedQuad(
      GLVec2i(Floor(iMin.X), Floor(iMin.Y)),
      GLVec2i(Floor(iMax.X), Floor(iMax.Y)),
      GLVec2f( 0,0 ), GLVec2f( 1,1 ),
      iIO.Textures.Texture[ FLogoTexture ].GLTexture
    );

    case FMode of
      MAINMENU_INTRO : begin
        IO.RenderUIBackground( Point(25,9), Point(55,13), 0.7 );
        IO.RenderUIBackground( Point(1,14), Point(79,25), 0.7 );
      end;
      MAINMENU_MENU : begin
        IO.RenderUIBackground( Point(23,13), Point(57,23), 0.7 );
        IO.RenderUIBackground( Point(0,24),  Point(80,25), 0.7 );
      end;
    end;

  end;

end;


function TMainMenuView.IsFinished : Boolean;
begin
  Exit( FMode = MAINMENU_DONE );
end;

function TMainMenuView.IsModal : Boolean;
begin
  Exit( True );
end;

procedure TMainMenuView.ReloadArrays;
var iEntry : TMainMenuEntry;
    iTable : TLuaTable;
    iCount : Word;
begin
  if FArrayCType = nil then FArrayCType := TMainMenuEntryArray.Create;
  if FArrayDiff  = nil then FArrayDiff  := TMainMenuEntryArray.Create;
  if FArrayKlass = nil then FArrayKlass := TMainMenuEntryArray.Create;
  FArrayCType.Clear;
  FArrayDiff.Clear;
  FArrayKlass.Clear;

  ChallengeType[1].Allow := (HOF.SkillRank > 0) or (GodMode) or (Setting_UnlockAll);
  ChallengeType[2].Allow := (HOF.SkillRank > 3) or (GodMode) or (Setting_UnlockAll);
  ChallengeType[3].Allow := (HOF.SkillRank > 3) or (GodMode) or (Setting_UnlockAll);
  FArrayCType.Push( ChallengeType[1] );
  FArrayCType.Push( ChallengeType[2] );
  FArrayCType.Push( ChallengeType[3] );

  for iTable in LuaSystem.ITables('diff') do
  with iTable do
  begin
    FillChar( iEntry, Sizeof(iEntry), 0 );
    iEntry.Allow := True;
    if (FResult.Challenge <> '') and (not GetBoolean( 'challenge' )) then Continue;
    if GetInteger('req_skill',0) > HOF.SkillRank then iEntry.Allow := Setting_UnlockAll;
    if GetInteger('req_exp',0)   > HOF.ExpRank   then iEntry.Allow := Setting_UnlockAll;
    iEntry.Name := GetString('name');
    iEntry.Desc := '';
    iEntry.Extra:= '';
    iEntry.ID   := GetString('id');
    iEntry.NID  := GetInteger('nid');
    FArrayDiff.Push( iEntry );
  end;

  for iCount := 1 to LuaSystem.Get(['klasses','__counter']) do
    with LuaSystem.GetTable([ 'klasses', iCount ]) do
    try
      if not GetBoolean( 'hidden',False ) then
      begin
        iEntry.Name  := GetString('name');
        iEntry.Desc  := GetString('desc');
        iEntry.ID    := GetString('id');
        iEntry.Extra := '';
        iEntry.NID   := GetInteger('nid');
        iEntry.Allow := IsFunction('OnPick');
        FArrayKlass.Push( iEntry );
      end;
    finally
      Free;
    end;
end;

procedure TMainMenuView.ReloadChallenge( aType : Byte );
var iChalCount  : DWord;
    iChoices    : DWord;
    iCount      : Integer;
    iPrefix     : Ansistring;
    iChallenges : array of Byte;
    iEntry      : TMainMenuEntry;
    iValue      : TLuaValue;
begin
  VTIG_EventClear;
  VTIG_ResetSelect( 'challenges_view' );

  if FArrayChal = nil then FArrayChal := TMainMenuEntryArray.Create;
  FArrayChal.Clear;
  iChalCount  := LuaSystem.Get(['chal','__counter']);
  iChallenges := nil;
  iChoices    := 0;
  iPrefix     := '';

  SetLength( iChallenges, iChalCount );

  case aType of
    CTYPE_ANGEL  : begin
      FTitleChal := 'Choose your Challenge';
      for iCount := 1 to iChalCount do
        iChallenges[iCount-1] := iCount;
      iChoices := iChalCount;
    end;
    CTYPE_DANGEL : begin
      FTitleChal := 'Choose your Primary Challenge';
      for iCount := 1 to iChalCount do
        if LuaSystem.Defined([ 'chal', iCount, 'secondary' ]) then
        begin
          iChallenges[iChoices] := iCount;
          Inc( iChoices );
        end;
    end;
    CTYPE_AANGEL : begin
      FTitleChal := 'Choose your Arch-Challenge';
      FResult.ArchAngel := True;
      iPrefix := 'arch_';
      for iCount := 1 to iChalCount do
        if LuaSystem.Defined([ 'chal', iCount, 'arch_name' ]) then
        begin
          iChallenges[iChoices] := iCount;
          Inc( iChoices );
        end;
    end;
//        CTYPE_CUSTOM = 4;
    CTYPE_SECOND : begin
      FTitleChal := 'Choose your Secondary Challenge';
      with LuaSystem.GetTable([ 'chal', FResult.Challenge, 'secondary' ]) do
      try
        for iValue in Values do
        begin
          iChallenges[iChoices] := LuaSystem.Get( ['chal','challenge_'+LowerCase(iValue.ToString),'nid'] );
          Inc( iChoices );
        end;
      finally
        Free;
      end;
    end;
  end;
  SetLength( iChallenges, iChoices );

  for iCount := 0 to High( iChallenges ) do
    with LuaSystem.GetTable([ 'chal', iChallenges[iCount] ]) do
    try
      iEntry.Name  := GetString(iPrefix+'name');
      iEntry.Desc  := GetString(iPrefix+'description');
      iEntry.Extra := GetString(iPrefix+'rating');
      if iEntry.Extra = '' then iEntry.Extra := 'UNRATED';
      iEntry.ID    := GetString('id');
      iEntry.NID   := iChallenges[iCount];
      iEntry.Allow := (HOF.SkillRank >= GetInteger(iPrefix+'rank',0)) or (GodMode) or (Setting_UnlockAll);
      FArrayChal.Push( iEntry );
    finally
      Free;
    end;
end;

procedure TMainMenuView.RenderASCIILogo;
var iCount  : Integer;
    iString : AnsiString;
begin
  if GraphicsVersion then Exit;

  if IO.Ascii.Exists('logo') then
  begin
    iCount := 0;
    for iString in IO.Ascii['logo'] do
    begin
      VTIG_FreeLabel( iString, Point( 17, iCount ) );
      Inc( iCount );
    end;
  end;
end;

destructor TMainMenuView.Destroy;
begin
  FreeAndNil( FArrayCType );
  FreeAndNil( FArrayDiff );
  FreeAndNil( FArrayKlass );
  FreeAndNil( FArrayChal );
  ResetSoundCallback;
  inherited Destroy;
end;

end.

