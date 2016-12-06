{$INCLUDE doomrl.inc}
unit doommenuview;
interface
uses vuielements, vuielement, vglui, viotypes, vuitypes, vioevent, vconui, dfdata, doomtextures, doommodule;

type TChallengeDesc = record Name : AnsiString; Desc : AnsiString; end;
const ChallengeType : array[1..4] of TChallengeDesc =
((
   Name : 'Angel Game';
   Desc : 'Play one of the DoomRL classic challenge games that place restrictions on play style or modify play behaviour.'#10#10'Reach @yPrivate FC@> rank to unlock!';
),(
   Name : 'Dual-angel Game';
   Desc : 'Mix two DoomRL challenge game types. Only the first counts highscore-wise - the latter is your own challenge!'#10#10'Reach @ySergeant@> rank to unlock!';
),(
   Name : 'Archangel Game';
   Desc : 'Play one of the DoomRL challenge in it''s ultra hard form. Do not expect fairness here!'#10#10'Reach @ySergeant@> rank to unlock!';
),(
   Name : 'Custom Challenge';
   Desc : 'Play one of many custom DoomRL challenge levels and episodes. Download new ones from the @yCustom game/Download Mods@> option in the main menu.';
));



type TMenuResult = class
  Quit       : Boolean;
  Loaded     : Boolean;
  GameType   : TDoomGameType;
  ArchAngel  : Boolean;
  Challenge  : AnsiString;
  SChallenge : AnsiString;
  Difficulty : Byte;
  ModuleID   : AnsiString;
  Module     : TDoomModule;

  Klass      : Byte;
  Trait      : Byte;
  Name       : AnsiString;

  constructor Create;
  procedure Reset;
end;

type TMainMenuConMenu = class( TConUIMenu )
  constructor Create( aParent : TUIElement; aRect : TUIRect );
  function OnSelect : Boolean; override;
  function OnConfirm : Boolean; override;
  function OnCancel : Boolean; override;
private
  FLast  : DWord;
  FSound : Boolean;
end;


type TMainMenuViewer = class( TUIElement )
    constructor CreateFirst( aParent : TUIElement );
    constructor CreateDonator( aParent : TUIElement );
    constructor CreateMain( aParent : TUIElement );
    constructor Create( aParent : TUIElement; aResult : TMenuResult );
    procedure Init;
    procedure CreateLogo;
    procedure CreateSubLogo;
    procedure InitMain;
    procedure InitDifficulty;
    procedure InitKlass;
    procedure InitTrait;
    procedure InitName;
    procedure InitChallenge;
    procedure OnRender; override;
    function OnSystem( const event : TIOSystemEvent ) : Boolean; override;
    function OnMouseDown( const event : TIOMouseEvent ) : Boolean; override;
    function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
    function OnMainCancel( aSender : TUIElement ) : Boolean;
    function OnCancel( aSender : TUIElement ) : Boolean;
    function OnPickMain( aSender : TUIElement ) : Boolean;
    function OnPickChallengeType( aSender : TUIElement ) : Boolean;
    function OnPickChallengeGame( aSender : TUIElement ) : Boolean;
    function OnPickFirstChallenge( aSender : TUIElement ) : Boolean;
    function OnPickSecondChallenge( aSender : TUIElement ) : Boolean;
    function OnPickDifficulty( aSender : TUIElement ) : Boolean;
    function OnPickKlass( aSender : TUIElement ) : Boolean;
    function OnPickTrait( aSender : TUIElement ) : Boolean;
    function OnPickName( aSender : TUIElement ) : Boolean;
    function OnPickMod( aSender : TUIElement ) : Boolean;
    function OnKlassMenuSelect( aSender : TUIElement; aIndex : DWord; aItem : TUIMenuItem ) : Boolean;
    function OnChalMenuSelect( aSender : TUIElement; aIndex : DWord; aItem : TUIMenuItem ) : Boolean;
    procedure OnRedraw; override;
  private
    FMode        : (MenuModeFirst, MenuModeDonator, MenuModeLogo, MenuModeMain, MenuModeDiff, MenuModeChal, MenuModeKlass, MenuModeName);
    FLogo        : Boolean;
    FLabel       : TConUILabel;
    FText        : TConUIText;
    FResult      : TMenuResult;
    FBGTexture   : TTextureID;
    FLogoTexture : TTextureID;
  end;

implementation

uses math, sysutils, vutil, vsound, vimage, vuiconsole, vluavalue, vluasystem, dfhof, dfoutput, vgltypes,
     doombase, doomio, doomnet, doomviews, vgllibrary;

const
  TextContinueGame  = '@b--@> Continue game @b---@>';
  TextNewGame       = '@b-----@> New game @b-----@>';
  TextChallengeGame = '@b--@> Challenge game @b--@>';
  TextCustomGame    = '@b---@> Custom game @b----@>';
//  TextReplay        = '@b-@> Replay last game @b-@>';
  TextShowHighscore = '@b-@> Show highscores @b--@>';
  TextShowPlayer    = '@b---@> Show player @b----@>';
  TextExit          = '@b-------@> Exit @b-------@>';
  TextHelp          = '@b-------@> Help @b-------@>';

{ TMainMenuConMenu }

constructor TMainMenuConMenu.Create ( aParent : TUIElement; aRect : TUIRect ) ;
begin
  inherited Create ( aParent, aRect ) ;
  FSound := Option_Sound and Option_MenuSound and (Sound <> nil);
  FLast  := 0;
end;

function TMainMenuConMenu.OnSelect : Boolean;
begin
  if (FLast <> 0) and (FLast <> Selected) and FSound then
    Sound.PlaySample('menu.change');
  FLast := Selected;
  Result := inherited OnSelect;
end;

function TMainMenuConMenu.OnConfirm : Boolean;
begin
  if FSound then
    Sound.PlaySample('menu.pick');
  Result := inherited OnConfirm;
end;

function TMainMenuConMenu.OnCancel : Boolean;
begin
  if FSound then
    Sound.PlaySample('menu.cancel');
  Result := inherited OnCancel;
end;


{ TMainMenuViewer }

constructor TMainMenuViewer.CreateFirst ( aParent : TUIElement ) ;
begin
  inherited Create( aParent, aParent.GetDimRect );
  Init;
  FMode   := MenuModeFirst;

  TConUIText.Create( Self, Rectangle(5,1,70,23),AnsiString( LuaSystem.ProtectedCall( ['DoomRL','first_text'], [] ) ) );
end;

constructor TMainMenuViewer.CreateDonator ( aParent : TUIElement ) ;
begin
  inherited Create( aParent, aParent.GetDimRect );
  Init;
  CreateLogo;
//  CreateSubLogo;
  FMode   := MenuModeDonator;

  TConUIText.Create( Self, Rectangle(2,9,77,16), AnsiString( LuaSystem.ProtectedCall( ['DoomRL','donator_text'], [] ) ) ).BackColor:=Black;
  TConUILabel.Create( Self, Point( Dim.X - 20, Dim.Y-1 ),'@rPress <@yEnter@r>...' );
end;

constructor TMainMenuViewer.CreateMain ( aParent : TUIElement ) ;
begin
  inherited Create( aParent, aParent.GetDimRect );
  Init;
  CreateLogo;
  CreateSubLogo;
  FMode   := MenuModeLogo;
  if GraphicsVersion then
    TGLUILabel.Create( Self, IO.TextSheet, IO.FMsgFont, Point( 10, 10 ), 'DoomRL version 0.9.9.7G' );

  TConUIText.Create( Self, Rectangle(2,14,77,11), AnsiString( LuaSystem.ProtectedCall( ['DoomRL','logo_text'], [] ) ) );
end;

constructor TMainMenuViewer.Create ( aParent : TUIElement; aResult : TMenuResult ) ;
begin
  inherited Create( aParent, aParent.GetDimRect );
  Init;
  FResult := aResult;
  InitMain;
end;

procedure TMainMenuViewer.Init;
begin
  if GraphicsVersion then
  begin
    FBGTexture   := Textures.TextureID['background'];
    FLogoTexture := Textures.TextureID['logo'];
  end;
  FEventFilter := [ VEVENT_KEYDOWN, VEVENT_MOUSEDOWN, VEVENT_SYSTEM ];
  IO.Root.Console.HideCursor;
  FResult := nil;
  FLabel  := nil;
  FText   := nil;
  FMode   := MenuModeLogo;
end;

procedure TMainMenuViewer.CreateLogo;
begin
  if GraphicsVersion then
    FLogo   := True
  else
    TConUIStringList.Create( Self, Rectangle(17,0,46,20), UI.Ascii['logo'], False );
end;

procedure TMainMenuViewer.CreateSubLogo;
begin
  TConUIText.Create( Self, Rectangle(28,10,48,3),
    '@rDoom Roguelike @R'+VERSION_STRING+#10+
    '@rby @RKornel Kisielewicz'#10+
    '@rgraphics by @RDerek Yu' ).BackColor:=Black;
end;

procedure TMainMenuViewer.InitMain;
var iSaveExists : Boolean;
    iMenu       : TConUIMenu;
begin
  FMode := MenuModeMain;
  FResult.Reset;

  iSaveExists := Doom.SaveExists;
  CreateLogo;

  TConUILabel.Create( Self, Point(2,24), '@B'+DoomNetwork.MOTD );

  iMenu := TMainMenuConMenu.Create( Self, Rectangle( 30,15,24,9 ) );
  if iSaveExists then
    iMenu.Add(TextContinueGame)
  else
    iMenu.Add(TextNewGame);
  iMenu.Add(TextChallengeGame,(not iSaveExists) );
  iMenu.Add(TextCustomGame, (not iSaveExists) );
  iMenu.Add(TextShowHighscore);
  iMenu.Add(TextShowPlayer);
  iMenu.Add(TextHelp);
  iMenu.Add(TextExit);
  iMenu.OnConfirmEvent := @OnPickMain;
  iMenu.OnCancelEvent  := @OnMainCancel;
end;

procedure TMainMenuViewer.InitDifficulty;
var iMenu  : TConUIMenu;
    iAllow : Boolean;
    iTable : TLuaTable;
begin
  FMode   := MenuModeDiff;
  CreateLogo;

  iMenu := TMainMenuConMenu.Create( Self, Rectangle( 30,16,24,9 ) );
  iMenu.SelectInactive := False;

  for iTable in LuaSystem.ITables('diff') do
  with iTable do
  begin
    iAllow := True;
    if (FResult.Challenge <> '') and (not GetBoolean( 'challenge' )) then iAllow := False;
    if GetInteger('req_skill',0) > HOF.SkillRank then iAllow := False;
    if GetInteger('req_exp',0)   > HOF.ExpRank   then iAllow := False;
    iMenu.Add(GetString('name'), iAllow );
  end;

  iMenu.OnConfirmEvent := @OnPickDifficulty;
  iMenu.OnCancelEvent  := @OnCancel;
end;

procedure TMainMenuViewer.InitKlass;
var iMenu  : TConUIMenu;
    iCount : DWord;
begin
  FMode   := MenuModeKlass;
  CreateLogo;
  FLabel := TConUILabel.Create( Self, Point( 30,16 ), StringOfChar( '-', 43 ) );
  FLabel.ForeColor := Red;
  FText := TConUIText.Create( Self, Rectangle( 32,18, 42,6 ) ,'' );
  iMenu := TMainMenuConMenu.Create( Self, Rectangle( 12,18, 10,6 )  );
  iMenu.OnSelectEvent  := @OnKlassMenuSelect;
  for iCount := 1 to LuaSystem.Get(['klasses','__counter']) do
    if not LuaSystem.Get(['klasses',iCount,'hidden']) then
      iMenu.Add(LuaSystem.Get(['klasses',iCount,'name']));
  iMenu.OnConfirmEvent := @OnPickKlass;
  iMenu.OnCancelEvent  := @OnCancel;
end;

procedure TMainMenuViewer.InitTrait;
var iFull : TUITraitsViewer;
begin
  FLogo := False;
  iFull := TUITraitsViewer.Create( Self, FResult.Klass, @OnPickTrait );
  iFull.OnCancelEvent  := @OnCancel;
end;

procedure TMainMenuViewer.InitName;
var iInput : TConUIInputLine;
begin
  FMode   := MenuModeName;
  CreateLogo;
  IO.Root.Console.ShowCursor;
  TConUILabel.Create( Self, Point( 25,18 ), '@rType a name for your character' );
  iInput := TConUIInputLine.Create( Self, Point( 25,19 ), 26 );
  iInput.ForeColor := LightRed;
  iInput.OnConfirmEvent := @OnPickName;
  iInput.OnCancelEvent  := @OnCancel;
end;

procedure TMainMenuViewer.InitChallenge;
var iMenu  : TConUIMenu;
begin
  FMode   := MenuModeChal;
  CreateLogo;
  FLabel := TConUILabel.Create( Self, Point( 30,16 ), StringOfChar( '-', 43 ) );
  FLabel.ForeColor := Red;
  FText := TConUIText.Create( Self, Rectangle( 32,18, 42,6 ) ,'' );
  iMenu := TMainMenuConMenu.Create( Self, Rectangle( 9,18, 10,6 ) );
//  iMenu.SelectInactive := False;
  iMenu.OnSelectEvent  := @OnChalMenuSelect;
  iMenu.Add( ChallengeType[1].Name, (HOF.SkillRank > 0) or (GodMode) );
  iMenu.Add( ChallengeType[2].Name, (HOF.SkillRank > 3) or (GodMode)  );
  iMenu.Add( ChallengeType[3].Name, (HOF.SkillRank > 3) or (GodMode)  );
  iMenu.Add( ChallengeType[4].Name, Modules.ChallengeModules.Size > 0 );
  iMenu.OnConfirmEvent := @OnPickChallengeType;
  iMenu.OnCancelEvent  := @OnCancel;
end;

procedure TMainMenuViewer.OnRender;
var iSizeX, iSizeY : Single;
    iMinX,iMaxX    : Single;
    iMinY,iMaxY    : Single;
    iTX,iTY        : Single;
    iImage         : TImage;
    iP1,iP2        : TPoint;
    iRoot          : TConUIRoot;
begin
  if GraphicsVersion then
  begin
    iImage := Textures.Texture[ FBGTexture ].Image;
    iTX    := iImage.RawX / iImage.SizeX;
    iTY    := iImage.RawY / iImage.SizeY;
    iSizeX := IO.Driver.GetSizeX;
    iSizeY := IO.Driver.GetSizeY;
    iMinX  := 0;
    iMaxX  := iSizeX-1;
    iMinY  := 0;
    iMaxY  := iSizeY-1;
    if (iImage.RawX / iImage.RawY) > (iSizeX / iSizeY) then
    begin
      iSizeX := iImage.RawX * (IO.Driver.GetSizeY / iImage.RawY);
      iMinX  := ( IO.Driver.GetSizeX - iSizeX ) / 2;
      iMaxX  := iMinX + iSizeX;
    end
    else
    begin
      iSizeY := iImage.RawY * (IO.Driver.GetSizeX / iImage.RawX);
      iMinY  := ( IO.Driver.GetSizeY - iSizeY ) / 2;
      iMaxY  := iMinY + iSizeY;
    end;

    IO.QuadSheet.PostTexturedQuad(
      TGLVec2i.Create(Floor(iMinX), Floor(iMinY)),
      TGLVec2i.Create(Floor(iMaxX), Floor(iMaxY)),
      TGLVec2f.Create(0,0),TGLVec2f.Create(iTX,iTY),
      Textures.Texture[ FBGTexture ].GLTexture
    );

    if FMode = MenuModeFirst then
    begin
      iRoot := TConUIRoot(FRoot);
      iP1 := iRoot.ConsoleCoordToDeviceCoord( Point(5,2) );
      iP2 := iRoot.ConsoleCoordToDeviceCoord( Point(77,25) );
      IO.QuadSheet.PostColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.7 ) );
      FLogo := False;
    end;

    if FLogo then
    begin
      iImage := Textures.Texture[ FLogoTexture ].Image;
      iSizeX := IO.Driver.GetSizeX;
      iSizeY := IO.Driver.GetSizeY;
      iMinY  := Floor(iSizeY / 25) * (-8);
      if (FMode <> MenuModeLogo) and (FMode <> MenuModeDonator)
        then begin iMaxY  := Floor(iSizeY / 25) * 24; iMinY := Floor(iSizeY / 25) * (-10); end
        else iMaxY  := Floor(iSizeY / 25) * 20;
      iMinX  := (iSizeX - (iMaxY - iMinY)) / 2;
      iMaxX  := (iSizeX + (iMaxY - iMinY)) / 2;

      IO.QuadSheet.PostTexturedQuad(
        TGLVec2i.Create(Floor(iMinX), Floor(iMinY)),
        TGLVec2i.Create(Floor(iMaxX), Floor(iMaxY)),
        TGLVec2f.Create( 0,0 ), TGLVec2f.Create( 1,1 ),
        Textures.Texture[ FLogoTexture ].GLTexture
      );
      iRoot := TConUIRoot(FRoot);
      case FMode of
        MenuModeDonator :
        begin
          iP1 := iRoot.ConsoleCoordToDeviceCoord( Point(2,10) );
          iP2 := iRoot.ConsoleCoordToDeviceCoord( Point(80,26) );
          IO.QuadSheet.PostColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.7 ) );
        end;
        MenuModeLogo :
        begin
          iP1 := iRoot.ConsoleCoordToDeviceCoord( Point(26,11) );
          iP2 := iRoot.ConsoleCoordToDeviceCoord( Point(56,14) );
          IO.QuadSheet.PostColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.7 ) );
          iP1 := iRoot.ConsoleCoordToDeviceCoord( Point(2,15) );
          iP2 := iRoot.ConsoleCoordToDeviceCoord( Point(80,26) );
          IO.QuadSheet.PostColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.7 ) );
        end;
        MenuModeMain  :
        begin
          iP1 := iRoot.ConsoleCoordToDeviceCoord( Point(24,15) );
          iP2 := iRoot.ConsoleCoordToDeviceCoord( Point(58,24) );
          IO.QuadSheet.PostColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.7 ) );
          iP1 := iRoot.ConsoleCoordToDeviceCoord( Point(1,25) );
          iP2 := iRoot.ConsoleCoordToDeviceCoord( Point(81,26) );
          IO.QuadSheet.PostColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.7 ) );
        end;
        MenuModeDiff  :
        begin
          iP1 := iRoot.ConsoleCoordToDeviceCoord( Point(24,16) );
          iP2 := iRoot.ConsoleCoordToDeviceCoord( Point(58,23) );
          IO.QuadSheet.PostColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.7 ) );
        end;
        MenuModeKlass :
        begin
          iP1 := iRoot.ConsoleCoordToDeviceCoord( Point(10,18) );
          iP2 := iRoot.ConsoleCoordToDeviceCoord( Point(26,23) );
          IO.QuadSheet.PostColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.7 ) );

          iP1 := iRoot.ConsoleCoordToDeviceCoord( Point(29,16) );
          iP2 := iRoot.ConsoleCoordToDeviceCoord( Point(78,25) );
          IO.QuadSheet.PostColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.7 ) );
        end;
        MenuModeChal :
        begin
          iP1 := iRoot.ConsoleCoordToDeviceCoord( Point(8,18) );
          iP2 := iRoot.ConsoleCoordToDeviceCoord( Point(27,24) );
          IO.QuadSheet.PostColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.7 ) );

          iP1 := iRoot.ConsoleCoordToDeviceCoord( Point(29,16) );
          iP2 := iRoot.ConsoleCoordToDeviceCoord( Point(78,25) );
          IO.QuadSheet.PostColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.7 ) );
        end;
        MenuModeName  :
        begin
          iP1 := iRoot.ConsoleCoordToDeviceCoord( Point(23,18) );
          iP2 := iRoot.ConsoleCoordToDeviceCoord( Point(59,22) );
          IO.QuadSheet.PostColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.7 ) );
        end;
      end;
    end;
  end;
  inherited OnRender;
end;

function TMainMenuViewer.OnSystem ( const event : TIOSystemEvent ) : Boolean;
begin
  if event.Code = VIO_SYSEVENT_QUIT then
  begin
    if FResult <> nil
      then FResult.Quit := True
      else Doom.SetState( DSQuit );
    Self.Free;
    Exit( True );
  end;
  Exit( False );
end;

function TMainMenuViewer.OnMouseDown ( const event : TIOMouseEvent ) : Boolean;
begin
  if (FMode = MenuModeLogo) and (event.Button in [ VMB_BUTTON_LEFT, VMB_BUTTON_RIGHT ]) then
  begin
    Free;
    Exit( True );
  end;
  Result := inherited OnMouseDown ( event ) ;
end;

function TMainMenuViewer.OnKeyDown ( const event : TIOKeyEvent ) : Boolean;
begin
  if (FResult = nil) and (event.ModState = []) then
  begin
    case event.Code of
      VKEY_SPACE,
      VKEY_ESCAPE,
      VKEY_ENTER  : begin Free; Exit( True ); end;
    end;
  end;
  Result := inherited OnKeyDown ( event ) ;
end;

function TMainMenuViewer.OnMainCancel ( aSender : TUIElement ) : Boolean;
var iMenu : TUICustomMenu;
begin
  iMenu := aSender as TUICustomMenu;
  if iMenu.Selected = 7
    then begin FResult.Quit := True; Free; end
    else iMenu.SetSelected( 7 );
  Exit( True );
end;

function TMainMenuViewer.OnCancel( aSender : TUIElement ) : Boolean;
begin
  FLabel := nil;
  FText  := nil;
  IO.Root.Console.HideCursor;
  DestroyChildren;
  InitMain;
  Exit( True );
end;

function TMainMenuViewer.OnPickMain( aSender : TUIElement ) : Boolean;
var iMenu       : TConUIMenu;
    iFull       : TUIFullWindow;
begin
  iMenu := aSender as TConUIMenu;
  DestroyChildren;
  iFull := nil;
  case iMenu.Selected of
    1 : if not Doom.SaveExists then
        begin
          InitDifficulty;
          Exit( True );
        end
        else
        if Doom.LoadSaveFile then
          FResult.Loaded := True
        else
        begin
          InitMain;
          TUINotifyBox.Create( Self, Rectangle( 15, 15, 50, 10 ),
            #10#10#10+
            '@r    Save file corrupted! Removing corrupted'#10+
            '@r    save file, sorry. Press <@yEnter@r>...').BackColor := Black;
          Exit( True );
        end;
    2 : begin
          InitChallenge;
          Exit( True );
        end;
    3 : iFull := TUIModViewer.Create( Self, Option_NetworkConnection and (DoomNetwork.ModServer <> ''), @OnPickMod );
    4 : iFull := TUIHOFViewer.Create( Self, HOF.GetHOFReport );
    5 : iFull := TUIPagedViewer.Create( Self, HOF.GetPagedReport );
    6 : iFull := TUIHelpViewer.Create( Self );
    7 : FResult.Quit := True;
  end;
  if iFull <> nil then
  begin
    FLogo := False;
    iFull.OnCancelEvent := @OnCancel
  end
  else
    Free;
  Exit( True );
end;

function TMainMenuViewer.OnPickChallengeType( aSender : TUIElement ) : Boolean;
var iFull       : TUIFullWindow;
    iChallenges : array of Byte;
    iCount      : DWord;
    iChoices    : DWord;
    iResult     : Byte;
    iChalCount  : DWord;
begin
  iResult := (aSender as TUICustomMenu).Selected;
  FreeAndNil( FText );
  FreeAndNil( FLabel );
  DestroyChildren;
  iChalCount := LuaSystem.Get(['chal','__counter']);

  FMode := MenuModeMain;
  case iResult of
    1 :
    begin
      SetLength( iChallenges, iChalCount );
      for iCount := 1 to iChalCount do
        iChallenges[iCount-1] := iCount;

      iFull := TUIChallengesViewer.Create( Self, 'Choose your Challenge', HOF.SkillRank, iChallenges, @OnPickChallengeGame );
    end;
    2 :
    begin
      SetLength( iChallenges, iChalCount );
      iChoices := 0;
      for iCount := 1 to iChalCount do
        if LuaSystem.Defined([ 'chal', iCount, 'secondary' ]) then
        begin
          iChallenges[iChoices] := iCount;
          Inc( iChoices );
        end;
      SetLength( iChallenges, iChoices );
      iFull := TUIChallengesViewer.Create( Self, 'Choose your Primary Challenge', HOF.SkillRank, iChallenges, @OnPickFirstChallenge );
    end;
    3 :
    begin
      FResult.ArchAngel := True;
      SetLength( iChallenges, iChalCount );
      iChoices := 0;
      for iCount := 1 to iChalCount do
        if LuaSystem.Defined([ 'chal', iCount, 'arch_name' ]) then
        begin
          iChallenges[iChoices] := iCount;
          Inc( iChoices );
        end;
      SetLength( iChallenges, iChoices );
      iFull := TUIChallengesViewer.Create( Self, 'Choose your Arch-challenge', HOF.SkillRank, iChallenges, @OnPickChallengeGame,True );
    end;
    4 : iFull := TUICustomChallengesViewer.Create( Self, 'Choose your Custom Challenge', Modules.ChallengeModules, @OnPickMod );
  else Exit( True );
  end;
  FLogo := False;
  iFull.OnCancelEvent := @OnCancel;
  Exit( True );
end;

function TMainMenuViewer.OnPickChallengeGame( aSender : TUIElement ) : Boolean;
var iChallengeID : Byte;
begin
  iChallengeID := Byte((aSender as TUICustomMenu).SelectedItem.Data);
  FResult.Challenge := '';
  if iChallengeID <> 0 then FResult.Challenge := LuaSystem.Get(['chal',iChallengeID,'id']);
  DestroyChildren;
  InitDifficulty;
  Exit( True );
end;

function TMainMenuViewer.OnPickFirstChallenge( aSender : TUIElement ) : Boolean;
var iFull        : TUIFullWindow;
    iChallengeID : Byte;
    iChallenges  : array of Byte;
    iChalCount   : DWord;
    iChoices     : DWord;
    iValue       : TLuaValue;
begin
  iChallengeID := Byte((aSender as TUICustomMenu).SelectedItem.Data);
  FResult.Challenge := '';
  if iChallengeID <> 0 then FResult.Challenge := LuaSystem.Get(['chal',iChallengeID,'id']);
  DestroyChildren;

  iChalCount := LuaSystem.Get( ['chal','__counter'] );
  SetLength( iChallenges, iChalCount );
  iChoices := 0;
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
  SetLength( iChallenges, iChoices );
  iFull := TUIChallengesViewer.Create( Self, 'Choose your Secondary Challenge', HOF.SkillRank, iChallenges, @OnPickSecondChallenge );
  FLogo := False;
  iFull.OnCancelEvent := @OnCancel;

  Exit( True );
end;

function TMainMenuViewer.OnPickSecondChallenge( aSender : TUIElement ) : Boolean;
var iChallengeID : Byte;
begin
  iChallengeID := Byte((aSender as TUICustomMenu).SelectedItem.Data);
  FResult.SChallenge := '';
  if iChallengeID <> 0 then FResult.SChallenge := LuaSystem.Get(['chal',iChallengeID,'id']);
  DestroyChildren;
  InitDifficulty;
  Exit( True );
end;

function TMainMenuViewer.OnPickDifficulty( aSender : TUIElement ) : Boolean;
var iChoice : Byte;
begin
  if aSender = nil
    then iChoice := 5
    else
    begin
      iChoice := (aSender as TUICustomMenu).Selected;
      if iChoice = 5 then
      begin
        TUIYesNoBox.Create( Self, Rectangle( 23, 15, 34, 7 ),
          '@r        Are you sure?'#10+
          '@r  This difficulty level isn''t'#10+
          '@r   even remotely fair! [@yy@r/@yn@r]', @Self.OnPickDifficulty ).BackColor := Black;
        Exit( True );
      end;
    end;
  FResult.Difficulty := iChoice;
  DestroyChildren;
  if FResult.Klass = 0
    then InitKlass
    else InitTrait;
  Exit( True );
end;

function TMainMenuViewer.OnPickKlass ( aSender : TUIElement ) : Boolean;
begin
  FResult.Klass := (aSender as TUICustomMenu).Selected;
  FreeAndNil( FText );
  FreeAndNil( FLabel );
  DestroyChildren;
  InitTrait;
  Exit( True );
end;

function TMainMenuViewer.OnPickTrait ( aSender : TUIElement ) : Boolean;
begin
  FResult.Trait := Word((aSender as TUICustomMenu).SelectedItem.Data);
  DestroyChildren;
  FLogo := False;

  if (Option_AlwaysName <> '') or Option_AlwaysRandomName
    then Free
    else InitName;
  Exit( True );
end;

function TMainMenuViewer.OnPickName ( aSender : TUIElement ) : Boolean;
begin
  FResult.Name := Trim((aSender as TConUIInputLine).Input);
  IO.Root.Console.HideCursor;
  DestroyChildren;
  Free;
  Exit( True );
end;

function TMainMenuViewer.OnPickMod ( aSender : TUIElement ) : Boolean;
var iModule : TDoomModule;
begin
  iModule := TDoomModule((aSender as TUICustomMenu).SelectedItem.Data);
  FResult.GameType   := GameSingle;
  FResult.Module     := iModule;
  FResult.Difficulty := 1;
  FResult.Klass      := iModule.Klass;

  if iModule.MType = ModuleEpisode then
  begin
    FResult.GameType := GameEpisode;
    FResult.ModuleID := iModule.Id;
  end;

  DestroyChildren;
  if iModule.Diff
    then InitDifficulty
    else if FResult.Klass = 0
      then InitKlass
      else InitTrait;
  Exit( True );
end;

function TMainMenuViewer.OnKlassMenuSelect ( aSender : TUIElement; aIndex : DWord; aItem : TUIMenuItem ) : Boolean;
begin
  FLabel.Text := Padded( '- @<' + LuaSystem.Get(['klasses',aIndex,'name']) + ' @>', 49, '-');
  FText.Text  := LuaSystem.Get(['klasses',aIndex,'desc']);
  Exit( True );
end;

function TMainMenuViewer.OnChalMenuSelect ( aSender : TUIElement; aIndex : DWord; aItem : TUIMenuItem ) : Boolean;
begin
  FLabel.Text := Padded( '- @<' + ChallengeType[aIndex].Name + ' @>', 49, '-');
  FText.Text  := ChallengeType[aIndex].Desc;
  Exit( True );
end;

procedure TMainMenuViewer.OnRedraw;
var iCon   : TUIConsole;
begin
  inherited OnRedraw;
  iCon.Init( TConUIRoot(FRoot).Renderer );
  iCon.ClearRect( FAbsolute, FBackColor );
end;

{ TMenuResult }

constructor TMenuResult.Create;
begin
  Reset;
end;

procedure TMenuResult.Reset;
begin
  Quit       := False;
  Loaded     := False;
  Difficulty := 0;
  Challenge  := '';
  SChallenge := '';
  ArchAngel  := False;
  Klass      := 0;
  Trait      := 0;
  GameType   := GameStandard;
  ModuleID   := 'DoomRL';
  Module     := nil;
  Name       := '';
end;


end.

