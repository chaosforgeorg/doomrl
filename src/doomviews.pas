{$INCLUDE doomrl.inc}
unit doomviews;
interface
uses vuielement, vuielements, viotypes, vuitypes, vioevent, vconui, vconuiext, vconuirl, doommodule,
     dfdata, dfitem, doomtrait;

type TUIChallengeList = array of Byte;

type TUIDowloadBar = class( TUIElement )
  constructor Create( aParent : TUIElement );
  procedure Initialize( aMax : DWord );
  procedure NetUpdate( aProgress : DWord );
  procedure OnRedraw; override;
protected
  FMax     : DWord;
  FCurrent : DWord;
end;


type TUIYesNoBox = class( TConUIWindow )
  constructor Create( aParent : TUIElement; aArea : TUIRect; const aText : AnsiString; aOnConfirm : TUINotifyEvent; aOnCancel : TUINotifyEvent = nil );
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
  function OnCancel : Boolean;
  function OnConfirm : Boolean;
protected
  FOnCancel    : TUINotifyEvent;
  FOnConfirm   : TUINotifyEvent;
public
  property OnCancelEvent  : TUINotifyEvent write FOnCancel;
  property OnConfirmEvent : TUINotifyEvent write FOnConfirm;
end;

type TUINotifyBox = class( TConUIWindow )
  constructor Create( aParent : TUIElement; aArea : TUIRect; const aText : AnsiString );
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
end;

type TUIFullWindow = class( TConUIBarFullWindow )
  procedure OnRender; override;
end;

type TUIMortemViewer = class( TUIFullWindow )
  constructor Create( aParent : TUIElement );
end;

type TUIMessagesViewer = class( TUIFullWindow )
  constructor Create( aParent : TUIElement; aMessages : TUIChunkBuffer );
end;

type TUIPagedViewer = class( TUIFullWindow )
public
  constructor Create( aParent : TUIElement; const aReport : TUIPagedReport );
  procedure SetPage( aIndex : Integer );
  procedure OnRedraw; override;
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
  destructor Destroy; override;
protected
  FPage       : DWord;
  FPages      : TUIPageArray;
  FMainTitle  : TUIString;
  FTitles     : TUIStringArray;
  FHeaders    : TUIStringArray;
  FContent    : TConUIStringList;
  FIcons      : TConUIScrollableIcons;
end;

type TUIHelpViewer = class( TUIFullWindow )
  constructor Create( aParent : TUIElement );
  function OnHelpConfirm( aSender : TUIElement ) : Boolean;
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
protected
  FMenu   : TConUIMenu;
  FText   : TConUIStringList;
  FIcons  : TConUIScrollableIcons;
end;

type TUIHOFViewer = class( TUIFullWindow )
  constructor Create( aParent : TUIElement; aReport : TUIHOFReport );
  constructor Create( aParent : TUIElement; const aTitle : TUIString; aContent : TUIStringArray );
  procedure SetFilter( aFilter : Char );
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
private
  procedure Initialize;
protected
  FIcons      : TConUIScrollableIcons;
  FContent    : TConUIStringList;
  FMainTitle  : TUIString;
  FFilters    : AnsiString;
  FFilter     : Char;
  FCallback   : TUIHOFCallback;
end;

type TUIMoreViewer = class( TUIFullWindow )
  constructor Create( aParent : TUIElement; const aSID : AnsiString );
end;

type TUIPlayerViewer = class( TUIFullWindow )
  constructor Create( aParent : TUIElement );
end;

type TUIAssemblyViewer = class( TUIFullWindow )
  constructor Create( aParent : TUIElement );
end;

type TUIRankUpViewer = class( TUIFullWindow )
  constructor Create( aParent : TUIElement; aRank : THOFRank );
end;

type

{ TUITraitsViewer }

 TUITraitsViewer = class( TUIFullWindow )
  constructor Create( aParent : TUIElement; aTraits : PTraits; aLevel : Byte; aOnConfirm : TUINotifyEvent = nil ); overload;
  constructor Create( aParent : TUIElement; aKlass : Byte; aOnConfirm : TUINotifyEvent = nil ); overload;
  procedure AddTrait( aID : Byte; aValue : Byte; aActive : Boolean );
  function OnCancel : Boolean; override;
  function OnMenuSelect( aSender : TUIElement; aIndex : DWord; aItem : TUIMenuItem ) : Boolean;
private
  function Value( aIndex : Byte ) : Byte;
  procedure Initialize;
protected
  FKlass     : Byte;
  FLevel     : Byte;
  FTraits    : PTraits;
  FMenu      : TConUIMenu;
  FLabel     : TConUILabel;
  FDesc      : TConUIText;
  FOnConfirm : TUINotifyEvent;
end;

type TUIChallengesViewer = class( TUIFullWindow )
  constructor Create( aParent : TUIElement; const aTitle : AnsiString; aRank : Byte; const aChallenges : TUIChallengeList; aOnConfirm : TUINotifyEvent = nil; aArch : Boolean = False );
  function OnMenuSelect( aSender : TUIElement; aIndex : DWord; aItem : TUIMenuItem ) : Boolean;
protected
  FPrefix     : AnsiString;
  FRank       : Byte;
  FMenu       : TConUIMenu;
  FLabel      : TConUILabel;
  FDesc       : TConUIText;
  FOnConfirm  : TUINotifyEvent;
end;

type

{ TUICustomChallengesViewer }

 TUICustomChallengesViewer = class( TUIFullWindow )
   constructor Create( aParent : TUIElement; const aTitle : AnsiString; const aChallenges : TModuleList; aOnConfirm : TUINotifyEvent = nil );
   function OnMenuSelect( aSender : TUIElement; aIndex : DWord; aItem : TUIMenuItem ) : Boolean;
 protected
   FMenu       : TConUIMenu;
   FLabel      : TConUILabel;
   FDesc       : TConUIText;
 end;

type TUIModViewer = class( TUIFullWindow )
  constructor Create( aParent : TUIElement; aDownloadAllowed : Boolean; aOnConfirm : TUINotifyEvent = nil );
  procedure EmitError( const aError : TUIString );
  procedure EmitWarning( const aError : TUIString; aContinue : TUINotifyEvent );
  procedure ReloadMenu;
  function OnMenuSelect( aSender : TUIElement; aIndex : DWord; aItem : TUIMenuItem ) : Boolean;
  function OnMenuPick( aSender : TUIElement ) : Boolean;
  function OnConfirm( aSender : TUIElement ) : Boolean;
protected
  FDownAllow : Boolean;
  FGConfirmed: Boolean;
  FMode      : ( ModeRemote, ModeLocal );
  FBar       : TUIDowloadBar;
  FMenu      : TConUIMenu;
  FLabel     : TConUILabel;
  FDesc      : TConUIText;
  FOnConfirm : TUINotifyEvent;
end;

type TUIItemResult    = ( ItemResultCancel, ItemResultPick, ItemResultDrop, ItemResultSwap );
type TUIItemResultSet = set of TUIItemResult;
type TUIItemConfirm   = function( aSender : TUICustomMenu; aResult : TUIItemResult ) : Boolean of object;
type TUIBaseItemView = class( TUIFullWindow )
  constructor Create( aParent : TUIElement; aOnConfirm : TUIItemConfirm; const aTitle : AnsiString; const aActions : TUIItemResultSet );
  function OnMenuSelect( aSender : TUIElement; aIndex : DWord; aItem : TUIMenuItem ) : Boolean;
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
  function OnConfirm( aSender : TUIElement ) : Boolean;
protected
  FActions   : TUIItemResultSet;
  FMenu      : TConUIMenu;
  FDesc      : TConUIText;
  FStats     : TConUIText;
  FOnConfirm : TUIItemConfirm;
end;

type TUIInventoryView = class( TUIBaseItemView )
  constructor Create( aParent : TUIElement; aOnConfirm : TUIItemConfirm; const aItems : array of TItem; const aAction : TUIString = '' );
protected
  FGeneral   : Boolean;
end;

type TUIEquipmentView = class( TUIBaseItemView )
  constructor Create( aParent : TUIElement; aOnConfirm : TUIItemConfirm );
end;

type TUILoadingScreen = class( TUIElement )
  constructor Create( aParent : TUIElement; aMax : DWord );
  procedure OnRedraw; override;
  procedure OnUpdate( aTime : DWord ); override;
  procedure OnProgress( aProgress : DWord );
protected
  FMax     : DWord;
  FCurrent : DWord;
public
  property Max     : DWord read FMax     write FMax;
  property Current : DWord read FCurrent write FCurrent;
end;

implementation

uses SysUtils,
     vgltypes, variants, vutil, vmath, vuiconsole, vluasystem,
     doombase, doomhelp, doomio, dfoutput, dfplayer, dfhof;

const HelpHeader       = 'DoomRL Help System';
      PostMortemHeader = 'PostMortem (@<mortem.txt@>)';
      MessagesHeader   = 'Past messages viewer';

      HelpFooter       = '@<Choose the topic, Escape exits@>';
      EscapeFooter     = '@<<Enter>@>,@<<Escape>@>,@<<Space>@>';
      ScrollFooterOn   = '@<Use arrows, PgUp, PgDown to scroll, Escape or Enter to exit@>';
      ScrollFooterOff  = '@<Use Escape or Enter to exit@>';
      PagedFooter      = '@<<Enter/Escape/Space>@>,@<<Up/Down>@>,@<<Left/Right>@>';
      MenuFooter       = '@<Up,Down to select, Enter to confirm, Escape to exit@>';

function CreateMenu( const aMenuClass : AnsiString; aParent : TUIElement; aArea : TUIRect ) : TConUIMenu;
begin
  if aMenuClass = 'CHOICE' then Exit( TConUIMenu.Create( aParent, aArea ) );
  if aMenuClass = 'LETTER' then Exit( TConUITextMenu.Create( aParent, aArea ) );
  {if aMenuClass = 'HYBRID' then }Exit( TConUIHybridMenu.Create( aParent, aArea ) );
end;


{ TUILoadingScreen }

constructor TUILoadingScreen.Create ( aParent : TUIElement; aMax : DWord ) ;
begin
  inherited Create( aParent, aParent.GetDimRect );
  FEventFilter := [ VEVENT_KEYDOWN, VEVENT_MOUSEDOWN ];
  FFullScreen  := True;
  FMax         := aMax;
  FCurrent     := 0;
end;

procedure TUILoadingScreen.OnRedraw;
var iSize   : TGLVec2i;
    iStep   : TGLVec2i;
    iV1,iV2 : TGLVec2i;
    iPoint  : TGLVec2i;
begin
  inherited OnRedraw;
  if GraphicsVersion and ( FMax > 0 ) then
  begin
    iSize.Init( IO.Driver.GetSizeX, IO.Driver.GetSizeY );
    iStep.Init( iSize.X div 15, iSize.Y div 15 );
    iPoint.Init( iSize.X div 400, iSize.X div 400 );
    iV1.Init(           iStep.X, iStep.Y * 7 );
    iV2.Init( iSize.X - iStep.X, iStep.Y * 8 );
    IO.QuadSheet.PostColoredQuad( iV1, iV2, TGLVec4f.Create( 1,0,0,1 ) );
    iV1 := iV1 + iPoint;
    iV2 := iV2 - iPoint;
    IO.QuadSheet.PostColoredQuad( iV1, iV2, TGLVec4f.Create( 0,0,0,1 ) );
    iV1 := iV1 + iPoint.Scaled(2);
    iV2 := iV2 - iPoint.Scaled(2);
    iV2.X := Round( ( iV2.X - iV1.X ) * (FCurrent / FMax) ) + iV1.X;
    IO.QuadSheet.PostColoredQuad( iV1, iV2, TGLVec4f.Create( 1,0.9,0,1 ) );
  end;
end;

procedure TUILoadingScreen.OnUpdate ( aTime : DWord ) ;
var iCon      : TUIConsole;
    iMaxChar  : DWord;
    iProgChar : DWord;
begin
  if FMax = 0 then Exit;
  if not GraphicsVersion then
  begin
    iMaxChar  := FAbsolute.w-1 - 20;
    iProgChar := Min( Round(( FCurrent / FMax ) * iMaxChar), iMaxChar );
    iCon.Init( TConUIRoot(FRoot).Renderer );
    iCon.RawPrint( FAbsolute.Pos + Point(10,12), Yellow, FBackColor, 'L O A D I N G . . .');
    iCon.RawPrint( FAbsolute.Pos + Point(10,13), Yellow, FBackColor, '['+StringOfChar( ' ',iMaxChar )+']');
    iCon.RawPrint( FAbsolute.Pos + Point(11,13), LightRed, FBackColor, StringOfChar( '=', iProgChar ) );
    TConUIRoot( FRoot ).NeedRedraw := True;
  end;
  FDirty := True;
end;

procedure TUILoadingScreen.OnProgress ( aProgress : DWord ) ;
begin
  FCurrent := aProgress;
end;

{ TUINotifyBox }

constructor TUINotifyBox.Create ( aParent : TUIElement; aArea : TUIRect; const aText : AnsiString );
begin
  inherited Create( aParent, aArea, '' );
  TConUIText.Create( Self, aText );
  FEventFilter := [ VEVENT_KEYDOWN ];
  FRoot.GrabInput(Self);
end;

function TUINotifyBox.OnKeyDown ( const event : TIOKeyEvent ) : Boolean;
begin
  if event.ModState <> [] then Exit( True );
  case event.Code of
    VKEY_SPACE,
    VKEY_ESCAPE,
    VKEY_ENTER  : Free;
  end;
  Exit( True );
end;

{ TUIDowloadBar }

constructor TUIDowloadBar.Create ( aParent : TUIElement ) ;
var iRect : TUIRect;
begin
  iRect := aParent.GetDimRect;
  inherited Create( aParent, Rectangle( iRect.x+1, iRect.y2, iRect.w - 3, 1  ) );
  Initialize( 0 );
end;

procedure TUIDowloadBar.Initialize ( aMax : DWord ) ;
begin
  FMax     := aMax;
  FCurrent := 0;
end;

procedure TUIDowloadBar.NetUpdate ( aProgress : DWord ) ;
begin
  FCurrent := aProgress;
  TConUIRoot( FRoot ).NeedRedraw := True;
  FDirty := True;
  IO.FullUpdate;
end;

procedure TUIDowloadBar.OnRedraw;
var iCon      : TUIConsole;
    iMaxChar  : DWord;
    iProgChar : DWord;
begin
  if not isVisible then Exit;
  if FMax = 0 then Exit;
  iMaxChar  := FAbsolute.w-1;
  iProgChar := Min( Round(( FCurrent / FMax ) * iMaxChar), iMaxChar );
  iCon.Init( TConUIRoot(FRoot).Renderer );
  iCon.RawPrint( FAbsolute.Pos, FForeColor, FBackColor, '['+StringOfChar( ' ',iMaxChar )+']');
  iCon.RawPrint( FAbsolute.Pos + Point(1,0), LightRed, FBackColor, StringOfChar( '=', iProgChar ) );
  TConUIRoot( FRoot ).NeedRedraw := True;
  FDirty := True;
end;

{ TUIFullWindow }

procedure TUIFullWindow.OnRender;
var iRoot   : TConUIRoot;
    iP1,iP2 : TPoint;
begin
  if GraphicsVersion then
  begin
    iRoot := TConUIRoot(FRoot);
    iP1 := iRoot.ConsoleCoordToDeviceCoord( FAbsolute.Pos );
    iP2 := iRoot.ConsoleCoordToDeviceCoord( Point( FAbsolute.x2+1, FAbsolute.y2+1 ) );
    IO.QuadSheet.PostColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.7 ) );
  end;

  inherited OnRender;
end;

{ TUIMortemViewer }

constructor TUIMortemViewer.Create ( aParent : TUIElement ) ;
var iRect    : TUIRect;
    iContent : TConUIStringList;
begin
  inherited Create( aParent, PostMortemHeader, ScrollFooterOn );
  iRect := aParent.GetDimRect.Shrinked(1,2);
  iContent := TConUIStringList.Create( Self, iRect, TextFileToUIStringArray(SaveFilePath+'mortem.txt'), True );
  iContent.EventFilter := [ VEVENT_KEYDOWN, VEVENT_MOUSEDOWN ];
  TConUIScrollableIcons.Create( Self, iContent, iRect, Point( FAbsolute.x2 - 7, FAbsolute.y ) );
end;


{ TUIMessagesViewer }

constructor TUIMessagesViewer.Create ( aParent : TUIElement; aMessages : TUIChunkBuffer ) ;
var iRect    : TUIRect;
    iContent : TConUIChunkBuffer;
begin
  inherited Create( aParent, MessagesHeader, ScrollFooterOn );
  iRect := aParent.GetDimRect.Shrinked(1,2);
  iContent := TConUIChunkBuffer.Create( Self, iRect, aMessages, False );
  iContent.SetScroll( iContent.Count );
  iContent.EventFilter := [ VEVENT_KEYDOWN, VEVENT_MOUSEDOWN ];
  if iContent.Count <= iContent.VisibleCount then Footer := ScrollFooterOff;
  TConUIScrollableIcons.Create( Self, iContent, iRect, Point( FAbsolute.x2 - 7, FAbsolute.Y ) );
end;

{ TUIHelpViewer }

constructor TUIHelpViewer.Create ( aParent : TUIElement ) ;
var i : Byte;
    iRect : TUIRect;
begin
  inherited Create( aParent, HelpHeader, HelpFooter );
  FEventFilter := [ VEVENT_KEYDOWN, VEVENT_MOUSEDOWN ];
  iRect := aParent.GetDimRect;
  FMenu := CreateMenu( Option_HelpMenuStyle, Self,iRect.Shrinked(2) );

  for i := 1 to Help.HNum do
    FMenu.Add( Help.RegHelps[i].Desc, True, @(Help.RegHelps[i]) );
  FMenu.Add('Quit Help');
  FMenu.OnConfirmEvent := @OnHelpConfirm;

  iRect  := aParent.GetDimRect.Shrinked(1,2);
  FText  := TConUIStringList.Create( Self, iRect );
  FIcons := TConUIScrollableIcons.Create( Self, FText, iRect, Point( FAbsolute.X2 - 7, FAbsolute.Y ) );
  FText.EventFilter := [ VEVENT_KEYDOWN, VEVENT_MOUSEDOWN ];
  FText.Enabled := False;
  FIcons.Enabled := False;
end;

function TUIHelpViewer.OnHelpConfirm( aSender : TUIElement ) : Boolean;
begin
  if FMenu.SelectedItem.Data = nil then Exit( OnCancel );
  FText.SetContent( PHelpRecord(FMenu.SelectedItem.Data)^.Text, False );
  FTitle := ' '+PHelpRecord(FMenu.SelectedItem.Data)^.Desc+' ';
  if FText.Count <= FText.VisibleCount
    then FFooter := ScrollFooterOff
    else FFooter := ScrollFooterOn;
  FText.Enabled := True;
  FIcons.Enabled := True;
  FMenu.Enabled := False;
  Exit( True );
end;

function TUIHelpViewer.OnKeyDown ( const event : TIOKeyEvent ) : Boolean;
begin
  if (event.Code = VKEY_ESCAPE) or (event.Code = VKEY_ENTER) or (event.Code = VKEY_SPACE) then
  begin
    if FText.Enabled then
    begin
      FText.Enabled := False;
      FIcons.Enabled := False;
      FMenu.Enabled := True;
      FTitle := HelpHeader;
      FFooter := HelpFooter;
    end
    else
      Exit( OnCancel );
    Exit( True );
  end;
  Result := False;
end;

{ TUIPagedViewer }

constructor TUIPagedViewer.Create ( aParent : TUIElement; const aReport : TUIPagedReport ) ;
var iRect : TUIRect;
begin
  inherited Create( aParent, aReport.Title, PagedFooter );
  FPage        := 0;
  FPages       := aReport.Pages;
  FTitles      := aReport.Titles;
  FHeaders     := aReport.Headers;
  iRect        := aParent.GetDimRect.Shrinked(0,2);
  FContent     := TConUIStringList.Create( Self, iRect );
  FIcons       := TConUIScrollableIcons.Create( Self, FContent, iRect, Point( FAbsolute.X2 - 7, FAbsolute.Y ) );
  FContent.EventFilter := [ VEVENT_KEYDOWN, VEVENT_MOUSEDOWN ];
  FMainTitle   := aReport.Title;
  SetPage(0);
end;

procedure TUIPagedViewer.SetPage ( aIndex : Integer ) ;
var iRect : TUIRect;
begin
  if aIndex >= FTitles.Size then Exit;

  iRect := GetDimRect.Shrinked(0,2);
  if FHeaders[ aIndex ] <> ''
    then
    begin
      iRect.Pos.y += 2;
      iRect.Dim.y -= 2;
    end;

  FContent.SetArea( iRect );
  FIcons.SetArea( iRect );
  FContent.SetContent( FPages[ aIndex ], False );
  FPage  := aIndex;
  FDirty := True;
end;

procedure TUIPagedViewer.OnRedraw;
var iCon   : TUIConsole;
begin
  inherited OnRedraw;
  iCon.Init( TConUIRoot(FRoot).Renderer );
  FTitle := FMainTitle;
  if FTitles[FPage] <> '' then
    FTitle += ' (@y'+ FTitles[FPage] + '@>)';
  if FPages.Size = 0 then Exit;

  if FHeaders[FPage] <> '' then
    iCon.Print( Point( FAbsolute.x, FAbsolute.y+2 ), FForeColor, FBackColor, FHeaders[FPage], True );
end;

function TUIPagedViewer.OnKeyDown ( const event : TIOKeyEvent ) : Boolean;
begin
  if (event.ModState <> []) or (FTitles.Size = 0) then Exit( inherited OnKeyDown( event ) );
  case event.Code of
    VKEY_LEFT   : SetPage( TrueModulo( FPage - 1, FTitles.Size ) );
    VKEY_RIGHT  : SetPage( TrueModulo( FPage + 1, FTitles.Size ) );
  else Exit( inherited OnKeyDown( event ) );
  end;
end;

destructor TUIPagedViewer.Destroy;
begin
  FreeAndNil( FPages );
  FreeAndNil( FTitles );
  FreeAndNil( FHeaders );

  inherited Destroy;
end;

{ TUIHOFViewer }

constructor TUIHOFViewer.Create ( aParent : TUIElement; aReport : TUIHOFReport ) ;
begin
  inherited Create( aParent, aReport.Title, aReport.Footer );
  FMainTitle := aReport.Title;
  FFilters   := aReport.Filters;
  FFilter    := aReport.Filters[1];
  FCallback  := aReport.Callback;

  Initialize;
  SetFilter( FFilter );
end;

constructor TUIHOFViewer.Create ( aParent : TUIElement; const aTitle : TUIString; aContent : TUIStringArray ) ;
begin
  inherited Create( aParent, aTitle, EscapeFooter );
  FMainTitle := aTitle;
  FFilters   := '';
  FFilter    := #0;
  FCallback  := nil;

  Initialize;
  FContent.SetContent( aContent );
end;

procedure TUIHOFViewer.Initialize;
var iRect : TUIRect;
begin
  iRect        := GetDimRect.Shrinked(0,2);
  FContent     := TConUIStringList.Create( Self, iRect );
  FIcons       := TConUIScrollableIcons.Create( Self, FContent, iRect, Point( FAbsolute.X2 - 7, FAbsolute.Y ) );
  FContent.EventFilter := [ VEVENT_KEYDOWN, VEVENT_MOUSEDOWN ];
end;

procedure TUIHOFViewer.SetFilter ( aFilter : Char ) ;
var iFilterDesc : AnsiString;
begin
  FFilter := aFilter;
  FContent.SetContent( FCallback( aFilter, iFilterDesc ), True );
  FTitle := FMainTitle;
  if iFilterDesc <> '' then
    FTitle +=' @R(@y'+iFilterDesc+'@R)@>';
end;

function TUIHOFViewer.OnKeyDown ( const event : TIOKeyEvent ) : Boolean;
begin
  if FFilters = '' then Exit( inherited OnKeyDown ( event ) );
  if (event.ASCII <> #0) and ( system.Pos( event.ASCII, FFilters ) <> 0 ) then
  begin
    if event.ASCII <> FFilter then SetFilter( event.ASCII );
    Exit( True );
  end;
  Result := inherited OnKeyDown ( event );
end;

{ TUIMoreViewer }

constructor TUIMoreViewer.Create ( aParent : TUIElement; const aSID : AnsiString ) ;
var iName  : AnsiString;
    iASCII : AnsiString;
    iDesc  : AnsiString;
begin
  iName := Capitalized(LuaSystem.Get(['beings',aSID,'name']));
  iDesc := LuaSystem.Get(['beings',aSID,'desc']);
  if aSID = 'soldier'
    then iASCII := Player.ASCIIMoreCode
    else iASCII := aSID;

  inherited Create( aParent, iName, EscapeFooter );

  if UI.Ascii.Exists(iASCII) then
    TConUIStringList.Create( Self, FAbsolute.Shrinked(2,1), UI.Ascii[iASCII], False )
  else
    TConUIText.Create( Self, Rectangle(10,10,10,2), '@rPicture'#10'  N/A' );

  TConUIText.Create( Self, Rectangle(40,8,38,1),'@r'+iName );
  TConUIText.Create( Self, Rectangle(40,9,38,14),'@l'+iDesc );
end;


{ TUIPlayerViewer }

constructor TUIPlayerViewer.Create ( aParent : TUIElement ) ;
var iStatus  : AnsiString;
    iContent : TUIStringArray;
    iText    : TConUIStringList;
    
    iDepth      : DWord;
    iGameTime   : DWord;
    iRealTime   : DWord;
    iDamTotal   : DWord;
    iDamLevel   : DWord;
    iKills      : DWord;
    iMaxKills   : DWord;
    iKillSpree  : DWord;
    iKillRecord : DWord;
    iDodgeBonus : Word;
    iKnockMod   : Integer;

begin
  iStatus := LuaSystem.Get([ 'diff', Doom.Difficulty, 'code' ]);
  if Doom.Challenge <> ''  then iStatus += '@> / ' + LuaSystem.Get(['chal',Doom.Challenge,'abbr']);
  if Doom.SChallenge <> '' then iStatus += ' + ' + LuaSystem.Get(['chal',Doom.SChallenge,'abbr']);
  iStatus := '( '+iStatus+'@> )';

  inherited Create( aParent, 'DoomRL Character Info '+iStatus, EscapeFooter );

  TConUIStringList.Create( Self, Rectangle(48,3,30,21), UI.Ascii[Player.ASCIIMoreCode], False );

  iContent := TUIStringArray.Create;

  with Player do
  begin
    FStatistics.Update();
    iDepth      := CurrentLevel;
    iGameTime   := FStatistics.Map['game_time'];
    iRealTime   := FStatistics.Map['real_time'];
    iDamTotal   := FStatistics.Map['damage_taken'];
    iDamLevel   := FStatistics.Map['damage_on_level'];
    iKills      := FStatistics.Map['kills'];
    iMaxKills   := FStatistics.Map['max_kills'];
    iKillSpree  := FKills.BestNoDamageSequence;
    iKillRecord := FStatistics.Map['kills_non_damage'];
    if iKillSpree > iKillRecord then iKillRecord := iKillSpree;

    iContent.Push( Format( '@L%s@l, level @L%d@l @L%s,',[Name,ExpLevel,AnsiString(LuaSystem.Get(['klasses',Klass,'name']))] ) );
    iContent.Push( Format( 'currently on level @L%d@l of the Phobos base. ', [iDepth] ) );
    iContent.Push( Format( 'He survived @L%d@l turns, which took him @L%d@l seconds. ', [ iGameTime, iRealTime ] ) );
    iContent.Push( Format( 'He took @L%d@l damage, @L%d@l on this floor alone. ', [ iDamTotal, iDamLevel ] ) );
    iContent.Push( Format( 'He killed @L%d@l out of @L%d@l enemies total. ', [ iKills, iMaxKills ] ) );
    iContent.Push( Format( 'His current killing spree is @L%d@l, with a record of @L%d@l. ', [ iKillSpree, iKillRecord ] ) );
    iContent.Push( '' );
    iContent.Push( Format( 'Current movement speed is @L%.2f@l second/move.', [getMoveCost/(Speed*10.0)] ) );
    iContent.Push( Format( 'Current fire speed is @L%.2f@l second/%s.', [getFireCost/(Speed*10.0),IIf(canDualGun,'dualshot','shot')] ) );
    iContent.Push( Format( 'Current reload speed is @L%.2f@l second/reload.', [getReloadCost/(Speed*10.0)] ) );
    iContent.Push( Format( 'Current to hit chance (point blank) is @L%s',[toHitPercent(10+getToHitRanged(Inv.Slot[efWeapon]))]));
    iContent.Push( Format( 'Current melee hit chance is @L%s',[toHitPercent(10+getToHitMelee(Inv.Slot[efWeapon]))]));
    iContent.Push( '' );

    iDodgeBonus := getDodgeMod;
    iKnockMod   := getKnockMod;

    { Dodge Bonus }
    if iDodgeBonus <> 0
    then iContent.Push( Format( 'He has a @L%d%%@l bonus toward dodging attacks.', [iDodgeBonus]))
    else iContent.Push( 'He has no bonus toward dodging attacks.' );

    { Knockback Modifier }
    if ( ( iKnockMod <> 100 ) and ( BodyBonus <> 0 ) ) then
    begin
      if ( iKnockMod < 100 )
      then iContent.Push( Format( 'He resists @L%d%%@l of knockback', [100-iKnockMod]))
      else iContent.Push( Format( 'He receives @L%d%%@l extra knockback', [iKnockMod-100]));
      iContent.Push( Format( '%s prevents @L%d@l space%s of knockback.', [IIf( iKnockMod < 100, 'and', 'but' ), BodyBonus, IIf(BodyBonus <> 1, 's') ]));
    end
    else if ( iKnockMod <> 100 ) then
      if ( iKnockMod < 100 )
      then iContent.Push( Format( 'He resists @L%d%%@l of knockback.', [100-iKnockMod]))
      else iContent.Push( Format( 'He receives @L%d%%@l extra knockback.', [iKnockMod-100]))
    else if ( BodyBonus <> 0 )
      then iContent.Push( Format( 'He prevents @L%d@l space%s of knockback.', [BodyBonus, IIf(BodyBonus <> 1,'s')]))
    else
      iContent.Push( 'He has no resistance to knockback.' );
    iContent.Push( '' );
  end;

  iText := TConUIStringList.Create( Self, FAbsolute.Shrinked(2,2), iContent, True );
  iText.ForeColor := LightGray;
  iText.BackColor := ColorNone;
end;

{ TUIAssemblyViewer }

constructor TUIAssemblyViewer.Create ( aParent : TUIElement ) ;
var iRect            : TUIRect;
    iContent         : TUIStringArray;
    iText            : TConUIStringList;
    iType, iFound, i : DWord;
    iString, iID     : AnsiString;
const TypeName : array[0..2] of string = ('Basic','Advanced','Master');
begin
  inherited Create( aParent, 'Known assemblies', ScrollFooterOn );
  iContent := TUIStringArray.Create;
  for iType := 0 to 2 do
  begin
    iContent.Push('@y'+TypeName[iType]+' assemblies');
    iContent.Push('');
    for i := 1 to LuaSystem.Get(['mod_arrays','__counter']) do
    if LuaSystem.Get(['mod_arrays',i,'level']) = iType then
    begin
      iID    := LuaSystem.Get(['mod_arrays',i,'id']);
      iFound := HOF.GetCounted( 'assemblies','assembly', iID );
      if LuaSystem.Get( [ 'player','__props', 'assemblies', iID ], 0 ) > 0 then Inc( iFound );
      if iFound = 0
        then if iType = 0
          then iString := '  @d'+LuaSystem.Get(['mod_arrays',i,'name'])+' (@L-@d)'
          else iString := '  @d  -- ? -- (@L-@d)'
        else iString := '  @y'+Padded(LuaSystem.Get(['mod_arrays',i,'name'])+' (@L'+IntToStr(iFound)+'@d@y)',36)
                        + '@l' + LuaSystem.Get(['mod_arrays',i,'desc']);
      iContent.Push( iString );
    end;
    if iType <> 2 then iContent.Push('');
  end;

  iRect := GetDimRect.Shrinked(2,2);
  iText := TConUIStringList.Create( Self, iRect, iContent, True );
  iText.EventFilter := [ VEVENT_KEYDOWN, VEVENT_MOUSEDOWN ];
  TConUIScrollableIcons.Create( Self, iText, iRect, Point( FAbsolute.X2 - 7, FAbsolute.Y ) );
end;

{ TUIRankUpViewer }

constructor TUIRankUpViewer.Create ( aParent : TUIElement; aRank : THOFRank ) ;
var iSRName, iERName, iText : AnsiString;
begin
  inherited Create( aParent, 'Congratulations!', EscapeFooter );

  if aRank.SkillRank <> 0 then iSRName := LuaSystem.Get(['skill_ranks',aRank.SkillRank+1,'name'],'') else iSRName := '';
  if aRank.ExpRank   <> 0 then iERName := LuaSystem.Get(['exp_ranks',aRank.ExpRank+1,'name'],'')     else iERName := '';

  if (aRank.SkillRank <> 0) and (aRank.ExpRank <> 0) then
    iText := '@rYou have shown both skill and determination and advanced'#10+
             'to @y'+iSRName+'@r skill rank and @y'+iERName+'@r experience rank!'
  else if (aRank.SkillRank <> 0)
    then iText := '@rYou have amazing skill and advanced'#10'to @y'+iSRName+'@r rank!'
    else iText := '@rYou have fierceful determination and advanced'#10'to @y'+iERName+'@r rank!';
  iText += #10#10'Press <@yEnter@r>...';

  TConUIText.Create( Self, GetAvailableDim.Shrinked(12,4), iText, False );
end;

{ TUISelectionViewer }

constructor TUITraitsViewer.Create ( aParent : TUIElement; aKlass : Byte; aOnConfirm : TUINotifyEvent ) ;
begin
  inherited Create( aParent, '@yChoose a trait to upgrade', MenuFooter );
  FOnConfirm := aOnConfirm;
  FKlass  := aKlass;
  FLevel  := 0;
  FTraits := nil;
  Initialize;
end;

constructor TUITraitsViewer.Create(aParent: TUIElement; aTraits: PTraits; aLevel : Byte; aOnConfirm: TUINotifyEvent);
begin
  inherited Create( aParent, '@yChoose a trait to upgrade', MenuFooter );
  FOnConfirm := aOnConfirm;
  FLevel  := aLevel;
  FTraits := aTraits;
  FKlass  := aTraits^.Klass;
  Initialize;
end;

procedure TUITraitsViewer.Initialize;
var iTrait, i : byte;
    iTraits   : Variant;
begin
  if not Assigned( FOnConfirm ) then
  begin
    FTitle  := 'Character traits';
    FFooter := '@<Up,Down to select, Enter or Escape to exit@>';
  end
  else
    if FTraits <> nil then
      FFooter := '@<Up,Down to select, Enter to pick@>';
  FMenu       := TConUIMenu.Create( Self, Rectangle( 3,1,22,23 ) );
  FLabel      := TConUILabel.Create( Self, Point( 27, 2 ), StringOfChar('-',57) );
  FDesc       := TConUIText.Create( Self, Rectangle( 29,4,47,21 ),'' );
  FLabel.ForeColor      := Red;
  FMenu.ForeColor       := LightRed;
  FMenu.SelectedColor   := Yellow;
  FMenu.OnSelectEvent   := @OnMenuSelect;
  FMenu.OnConfirmEvent  := FOnConfirm;
  FMenu.ForceChoice     := (FTraits <> nil) and Assigned( FOnConfirm );
  FMenu.ConfirmInactive := not Assigned( FOnConfirm );

  iTraits := LuaSystem.Get(['klasses',FKlass,'traitlist']);
  for i := VarArrayLowBound(iTraits, 1) to VarArrayHighBound(iTraits, 1) do
  begin
    iTrait := iTraits[ i ];
    if FTraits <> nil
      then AddTrait( iTrait, Value( iTrait ), FTraits^.CanPick( iTrait, FLevel ) )
      else AddTrait( iTrait, 0, TTraits.CanPickInitially( iTrait, FKlass ) );
  end;
end;


procedure TUITraitsViewer.AddTrait ( aID : Byte; aValue : Byte; aActive : Boolean ) ;
begin
  FMenu.Add( Padded(LuaSystem.Get(['traits',aID,'name']),16)+' (@<'+IntToStr(aValue)+'@>)', aActive, Pointer(aID) );
end;

function TUITraitsViewer.OnCancel : Boolean;
begin
  if FMenu.ForceChoice then Exit( True );
  Result := inherited OnCancel;
end;

function TUITraitsViewer.OnMenuSelect ( aSender : TUIElement; aIndex : DWord; aItem : TUIMenuItem ) : Boolean;
var iCount  : Byte;
    iSize   : Word;
    iValue  : Word;
    iNID    : Word;
    iTID    : Word;
    iString : AnsiString;
    iDesc   : AnsiString;
    iName   : AnsiString;
    iTable  : TLuaTable;
const RG : array[Boolean] of Char = ('G','R');
      RL : array[Boolean] of Char = ('L','R');
begin
  if not FMenu.IsValid( aIndex ) then Exit( True );
  iTID := Word(aItem.Data);

  FLabel.Text := Padded( '- @<' + LuaSystem.Get(['traits',iTID,'name']) + ' @>', 54, '-');

  iString := '';
  iDesc   := '';

  with LuaSystem.GetTable(['klasses',FKlass,'trait',iTID]) do
  try
    if GetTableSize('requires') > 0 then
    for iTable in ITables('requires') do
    begin
      iNID    := iTable.GetValue( 1 );
      iName   := LuaSystem.Get(['traits',iNID,'name']);
      iValue  := iTable.GetValue( 2 );
      iString += '@'+RG[Value(iNID) < iValue]+iName+' @l(@<'+IntToStr(iValue)+'@l), ';
    end;

    iValue := GetInteger('reqlevel',0);
    if iValue > 0
      then iString += '@'+RG[FLevel < iValue]+'Level @l(@<'+IntToStr(iValue)+'@l)'
      else Delete( iString, Length(iString) - 1, 2 );

    if iString <> '' then iDesc += #10#10'Requires : '+iString;

    iString := '';
    iSize   := GetTableSize('blocks');
    if iSize > 0 then
    begin
      with GetTable('blocks') do
      try
        for iCount := 1 to iSize do
        begin
          iNID    := GetValue( iCount );
          iName   := LuaSystem.Get(['traits',iNID,'name']);
          iString += '@'+RL[Value(iNID) > 0]+iName+'@l, ';
        end;
      finally
        Free;
      end;
      Delete( iString, Length(iString) - 1, 2 );
    end;
    if iString <> '' then iDesc += #10'Blocks   : '+iString;
  finally
    Free;
  end;

  with LuaSystem.GetTable(['traits',iTID]) do
  try
    FDesc.Text  := '@y'+getString('quote')+#10#10+'@l'+getString('full')+iDesc;
  finally
    Free;
  end;
  Exit( True );
end;

function TUITraitsViewer.Value ( aIndex : Byte ) : Byte;
begin
  if FTraits <> nil then Exit( FTraits^.Values[ aIndex ] );
  Exit(0);
end;

{ TUIChallengesViewer }

constructor TUIChallengesViewer.Create ( aParent : TUIElement; const aTitle : AnsiString; aRank : Byte; const aChallenges : TUIChallengeList; aOnConfirm : TUINotifyEvent; aArch : Boolean ) ;
var iCount : DWord;
begin
  inherited Create( aParent, '@y'+aTitle, '@<Up,Down to select, Enter or Escape to exit@>');

  FOnConfirm  := aOnConfirm;
  FRank       := aRank;
  FMenu       := TConUIMenu.Create( Self, Rectangle( 3,2,22,21 ) );
  FLabel      := TConUILabel.Create( Self, Point( 27, 2 ), StringOfChar('-',57) );
  FDesc       := TConUIText.Create( Self, Rectangle( 29,4,47,21 ),'' );
  FLabel.ForeColor    := Red;
  FMenu.ForeColor     := LightRed;
  FMenu.SelectedColor := Yellow;
  FMenu.OnSelectEvent := @OnMenuSelect;
  FMenu.OnConfirmEvent:= FOnConfirm;

  FPrefix := '';
  if aArch then FPrefix := 'arch_';
  for iCount := 0 to High( aChallenges ) do
    FMenu.Add(LuaSystem.Get(['chal',aChallenges[iCount],FPrefix+'name']),(aRank >= LuaSystem.Get(['chal',aChallenges[iCount],FPrefix+'rank'],0)) or GodMode, Pointer(aChallenges[iCount]) );

end;

function TUIChallengesViewer.OnMenuSelect ( aSender : TUIElement; aIndex : DWord; aItem : TUIMenuItem ) : Boolean;
var iChoice : Byte;
begin
  if not FMenu.IsValid( aIndex ) then Exit( True );
  iChoice := Byte(FMenu.SelectedItem.Data);
  FLabel.Text := Padded( '- @<' + LuaSystem.Get(['chal',iChoice,FPrefix+'name']) + ' @>', 53, '-');
  FDesc.Text  := '@rRating: @y'+LuaSystem.Get(['chal',iChoice,FPrefix+'rating'],'UNRATED')+#10#10+
                 '@l'+LuaSystem.Get(['chal',iChoice,FPrefix+'description']);
  Exit( True )
end;

{ TUICustomChallengesViewer }

constructor TUICustomChallengesViewer.Create(aParent: TUIElement;
  const aTitle: AnsiString; const aChallenges: TModuleList;
  aOnConfirm: TUINotifyEvent);
var iCount : DWord;
begin
  inherited Create( aParent, '@y'+aTitle, '@<Up,Down to select, Enter or Escape to exit@>');

  FMenu       := TConUIMenu.Create( Self, Rectangle( 3,2,22,21 ) );
  FLabel      := TConUILabel.Create( Self, Point( 27, 2 ), StringOfChar('-',57) );
  FDesc       := TConUIText.Create( Self, Rectangle( 29,4,47,21 ),'' );
  FLabel.ForeColor    := Red;
  FMenu.ForeColor     := LightRed;
  FMenu.SelectedColor := Yellow;
  FMenu.OnSelectEvent := @OnMenuSelect;
  FMenu.OnConfirmEvent:= aOnConfirm;

  for iCount := 0 to aChallenges.Size-1 do
    FMenu.Add(aChallenges[iCount].Name, True, Pointer(aChallenges[iCount]) );
end;

function TUICustomChallengesViewer.OnMenuSelect(aSender: TUIElement;
  aIndex: DWord; aItem: TUIMenuItem): Boolean;
var iModule : TDoomModule;
    iDesc   : AnsiString;
    iAwards : AnsiString;
    iMax    : LongInt;
    iAmount : DWord;
    iCount  : DWord;
    iItems  : DWord;
    iID     : AnsiString;
begin
  if not FMenu.IsValid( aIndex ) then Exit( True );
  iModule := TDoomModule(FMenu.SelectedItem.Data);
  FLabel.Text := Padded( '- @<' + iModule.Name + ' @>', 53, '-');
  iDesc := '@l'+iModule.CDesc+#10+#10;
  iAwards := '';
  if iModule.AwardID <> '' then
  begin
    iID     := iModule.AwardID;
    iItems  := LuaSystem.GetTableSize(['awards',iID,'levels']);
    if iItems > 0 then
    begin
      iAwards := '';
      iMax    := 0;
      for iCount := 1 to iItems do
      begin
        iAmount := HOF.GetCounted( 'awards', 'award', iID + '_' + IntToStr(iCount) );
        if iAmount > 0 then iAwards += '@y' else iAwards += '@d';
        iAwards += '* '+LuaSystem.Get(['awards',iID,'levels',iCount,'name']);
        if iAmount > 1 then iAwards += ' (@Lx'+IntToStr(iAmount)+'@y)';
        iAwards += ' - '+LuaSystem.Get(['awards',iID,'levels',iCount,'desc'])+#10;
        if iAmount > 0 then iMax := iCount;
      end;
      if iMax > 0
        then iAwards := '@rAward : @y'+LuaSystem.Get(['awards',iID,'name'])+' (@L'+LuaSystem.Get(['awards',iID,'levels',iMax,'name'])+'@y)'+#10+#10 + iAwards
        else iAwards := '@rAward : @d'+LuaSystem.Get(['awards',iID,'name'])+#10+#10 + iAwards;
    end;
  end;
  FDesc.Text  := iDesc + iAwards;
end;

{ TUIModViewer }

constructor TUIModViewer.Create ( aParent : TUIElement;
  aDownloadAllowed : Boolean; aOnConfirm : TUINotifyEvent ) ;
begin
  inherited Create( aParent, '@yChoose Module to Play', MenuFooter);

  FOnConfirm  := aOnConfirm;
  FDownAllow  := aDownloadAllowed;
  FMode       := ModeLocal;
  FMenu       := TConUIMenu.Create( Self, Rectangle( 3,2,22,21 ) );
  FLabel      := TConUILabel.Create( Self, Point( 27, 2 ), StringOfChar('-',57) );
  FDesc       := TConUIText.Create( Self, Rectangle( 29,4,47,21 ),'' );
  FBar        := TUIDowloadBar.Create( Self );
  FBar.Visible:= False;

  FLabel.ForeColor    := Red;
  FMenu.ForeColor     := LightRed;
  FMenu.SelectedColor := Yellow;
  FMenu.OnSelectEvent := @OnMenuSelect;
  FMenu.OnConfirmEvent:= @OnMenuPick;

  ReloadMenu;
end;

procedure TUIModViewer.EmitError ( const aError : TUIString ) ;
begin
  TUINotifyBox.Create( Self, Rectangle( 9,5, 54, 11),
  '@r  Error!'#10#10+
  '@y  '+aError+#10#10+
  '          @rPress <@yEnter@r>...');
end;

procedure TUIModViewer.EmitWarning ( const aError : TUIString;
  aContinue : TUINotifyEvent ) ;
begin
  TUIYesNoBox.Create( Self, Rectangle( 9,5, 54, 11),
  '@y  Warning!'#10#10+
  '@y  '+aError+#10#10+
  '          @rPress [@yy@r/@yn@r]...', aContinue );
end;

procedure TUIModViewer.ReloadMenu;
var iList   : TModuleArray;
    iModule : TDoomModule;
begin
  if FMode = ModeLocal then
  begin
    FTitle := '@yChoose Module to Play';
    iList := Modules.LocalModules;
  end
  else
  begin
    (* TODO Separate network error (actually cannot download the file) from local error (file system cannot write the file because the directory is missing etc) *)
    if not Modules.DownloadRemoteLists( nil ) then
    begin
      EmitError( 'Could not download module list from remote'#10+'repository!' );
      Exit;
    end;
    FTitle := '@yChoose Module to Download';
    iList := Modules.RemoteModules;
  end;

  FMenu.Clear;
  for iModule in iList do
    FMenu.Add( iModule.Name+IIf( iModule.Raw, ' (raw)'), True, iModule );
  if (FMode = ModeLocal) and FDownAllow then FMenu.Add('Download mods');
  FMenu.Add('Back');
end;

function TUIModViewer.OnMenuSelect ( aSender : TUIElement; aIndex : DWord; aItem : TUIMenuItem ) : Boolean;
var iModule : TDoomModule;
    iLocal  : TDoomModule;
  function VersionInfo( Version : TVersion ) : AnsiString;
  begin
    if iLocal = nil then
      Exit( VersionToString(Version) );
    if iLocal.Version > Version then
      Exit( VersionToString(Version)+' @R(older)' );
    if Version > iLocal.Version then
      Exit( VersionToString(Version)+' @W(newer)' );
    Exit( VersionToString(Version)+' (same)' );
  end;

begin
  FGConfirmed := False;
  if ( not FMenu.IsValid( aIndex ) ) or ( aItem.Data = nil ) then
  begin
    FLabel.Text := '';
    FDesc.Text  := '';
    Exit( True );
  end;
  iModule := TDoomModule(aItem.Data);
  if FMode = ModeLocal
    then iLocal  := nil
    else iLocal  := Modules.FindLocalMod( iModule.ID );

  FLabel.Text := Padded( '- @<' + iModule.Name + ' @>', 53, '-');
  FDesc.Text  :=
  '@RVersion: @y'+VersionInfo(iModule.Version)+#10+
  '@RAuthor : @y'+iModule.Author+#10+
  '@RWebpage: @y'+iModule.Webpage+#10+
  '@RReqVer : @y'+VersionToString(iModule.drlver)+#10+
  IIf( GraphicsVersion,'@RGSupport: @y'+BoolToStr(iModule.GSupport)+#10)+
  IIf( FMode = ModeRemote,'@RSize   : @y'+IntToStr(iModule.Size)+#10)+
  #10+'@L'+iModule.Desc+IIf( iModule.Challenge, #10#10+'@yNote: @lThis module is also available via Challenge Game menu now.' );
  Exit( True );
end;

function TUIModViewer.OnMenuPick ( aSender : TUIElement ) : Boolean;
const OlderWarning = 'This module is designed for an older version'#10+
                     '  of DoomRL, and as such might not work on your'#10+
                     '  version. Do you want to try to load it anyway?';
      NewerWarning = 'This module is designed for a newer version'#10+
                     '  of DoomRL, and as such might not work on your'#10+
                     '  version. Do you want to try to load it anyway?';
      GVerWarning  = 'This module was not designed with graphics'#10+
                     '  support in mind. It might crash and look'#10+
                     '  corrupted in G-mode. Try to play it anyway?';
var iModule : TDoomModule;
begin
  if FBar.Visible then Exit( True );
  if FMenu.SelectedItem.Data = nil then
  begin
    if (FMode = ModeLocal) and (FMenu.Selected = FMenu.Count) then
        Exit( OnCancel )
    else
    begin
      if FMode = ModeLocal
        then FMode := ModeRemote
        else FMode := ModeLocal;
      ReloadMenu;
    end;
    Exit( True );
  end;

  iModule := TDoomModule(FMenu.SelectedItem.Data);
  if FMode = ModeLocal then
  begin
    if GraphicsVersion and (not iModule.GSupport) and (not FGConfirmed) then
    begin
      EmitWarning( GVerWarning, @Self.OnMenuPick );
      FGConfirmed := True;
      Exit( True );
    end;

    if iModule.DrlVer > Doom.NVersion then
      EmitWarning( NewerWarning, @OnConfirm )
    else if Doom.NVersion > iModule.DrlVer then
      EmitWarning( OlderWarning, @OnConfirm )
    else
      OnConfirm( FMenu );
  end
  else
  begin
    FBar.Visible := True;
    FBar.Initialize( iModule.Size );
    if not Modules.DownloadModule( iModule, @FBar.NetUpdate ) then
    begin
      EmitError('Could not download module from remote repository!');
    end
    else
    begin
      TUINotifyBox.Create( Self, Rectangle( 9,5, 51, 7),'@y  Module downloaded successfuly!'#10#10'          @rPress <@yEnter@r>...');
      Modules.RefreshLocalModules;
    end;
    FBar.Visible := False;
  end;
  Exit( True );
end;

function TUIModViewer.OnConfirm ( aSender : TUIElement ) : Boolean;
begin
  if FMode = ModeLocal then
  begin
    if Assigned( FOnConfirm ) then FOnConfirm( FMenu ) else Free;
  end;
  Exit( True );
end;

{ TUIYesNoBox }

constructor TUIYesNoBox.Create ( aParent : TUIElement; aArea : TUIRect;
  const aText : AnsiString; aOnConfirm : TUINotifyEvent; aOnCancel : TUINotifyEvent ) ;
begin
  inherited Create( aParent, aArea, '' );
  TConUIText.Create( Self, aText );
  FEventFilter := [ VEVENT_KEYDOWN ];
  FOnConfirm := aOnConfirm;
  FOnCancel  := aOnCancel;
  FRoot.GrabInput(Self);
end;

function TUIYesNoBox.OnKeyDown ( const event : TIOKeyEvent ) : Boolean;
begin
  if (event.ModState <> []) then Exit( True );
  if (event.ASCII in ['y','Y']) then Exit( OnConfirm );
  if (event.ASCII in ['n','N']) or
     (event.Code = VKEY_ESCAPE) then Exit( OnCancel );
  Exit( True )
end;

function TUIYesNoBox.OnCancel : Boolean;
begin
  if Assigned( FOnCancel ) then
  begin
    Free;
    Exit( FOnCancel( nil ) );
  end;
  Free;
  Exit( True );
end;

function TUIYesNoBox.OnConfirm : Boolean;
begin
  if Assigned( FOnConfirm ) then
  begin
    Free;
    Exit( FOnConfirm( nil ) );
  end;
  Free;
  Exit( True );
end;

{ TUIBaseItemView }

constructor TUIBaseItemView.Create ( aParent : TUIElement;
  aOnConfirm : TUIItemConfirm; const aTitle : AnsiString; const aActions : TUIItemResultSet ) ;
begin
  inherited Create( aParent, aTitle, '');
  FOnConfirm := aOnConfirm;
  FActions   := aActions;
end;

function TUIBaseItemView.OnMenuSelect ( aSender : TUIElement; aIndex : DWord;
  aItem : TUIMenuItem ) : Boolean;
var iItem : TItem;
    iDesc : AnsiString;
    iSet  : AnsiString;
begin
  if not FMenu.IsValid(aIndex) then Exit( True );
  iItem := TItem( aItem.Data );
  if iItem = nil then
  begin
    FDesc.Text  := '';
    FStats.Text := '';
    Exit( True );
  end;
  iDesc := LuaSystem.Get(['items',iItem.ID,'desc']);
  if iItem.Flags[ IF_SETITEM ] then
  begin
    iSet := LuaSystem.Get(['items',iItem.ID,'set']);
    iDesc := Format('@<%s@> (1/%d)', [
      AnsiString( LuaSystem.Get(['itemsets',iSet,'name']) ),
      Byte( LuaSystem.Get(['itemsets',iSet,'trigger']) ) ])
      + #10+iDesc;
  end;
  FDesc.Text := iDesc;
  FStats.Text := iItem.DescriptionBox;
  Exit( True )
end;

function TUIBaseItemView.OnKeyDown ( const event : TIOKeyEvent ) : Boolean;
begin
  if (FMenu <> nil) and Assigned(FOnConfirm) and (event.ModState = []) and (FMenu.IsValid( FMenu.Selected ) ) and (FMenu.SelectedItem.Data <> nil) then
  begin
    if (ItemResultDrop in FActions) and  (event.Code = VKEY_BACK) then
    begin
      FOnConfirm( FMenu, ItemResultDrop );
      Free;
      Exit( True );
    end;
    if (ItemResultSwap in FActions) and  (event.Code = VKEY_TAB) then
    begin
      FOnConfirm( FMenu, ItemResultSwap );
      Free;
      Exit( True );
    end;
  end;
  Result := inherited OnKeyDown ( event );
end;

function TUIBaseItemView.OnConfirm ( aSender : TUIElement ) : Boolean;
begin
  if Assigned( FOnConfirm ) then FOnConfirm( FMenu, ItemResultPick );
  Free;
  Exit( True );
end;


{ TUIInventoryView }

constructor TUIInventoryView.Create ( aParent : TUIElement; aOnConfirm : TUIItemConfirm; const aItems : array of TItem; const aAction : TUIString = ''  ) ;
var iVSep  : TUICustomSeparator;
    iHSep  : TUICustomSeparator;
    iCont  : TUIElement;
    iCount : DWord;
    iMax   : DWord;
    iDesc  : AnsiString;
begin
  FGeneral := aAction = '';
  if FGeneral
    then inherited Create( aParent, aOnConfirm, '@yInventory', [ ItemResultPick, ItemResultDrop ] )
    else inherited Create( aParent, aOnConfirm, '@yChoose item (@W'+aAction+'@y)', [ ItemResultPick ] );

  iCont := TUIElement.Create( Self, aParent.GetDimRect.Shrinked(0,1) );
  iVSep := TConUISeparator.Create( iCont, VORIENT_VERTICAL, 54 );
  iHSep := TConUISeparator.Create( iVSep.Right, VORIENT_HORIZONTAL, 16 );
  iHSep.Top.SetPadding( PointUnit );
  iHSep.Bottom.SetPadding( Point(1,0) );

  iMax := 0;
  for iCount := Low( aItems ) to High( aItems ) do
    if aItems [ iCount ] <> nil then Inc(iMax);

  FMenu := nil;
  if iMax = 0 then
    TConUILabel.Create( iVSep.Left, Point( 1,1 ), 'No items, Press <Enter>' )
  else
  begin
    FMenu       := CreateMenu( Option_InvMenuStyle, iVSep.Left, Rectangle( 2,1,50,22 ) );
    FDesc       := TConUIText.Create( iHSep.Top, '' );
    FStats      := TConUIText.Create( iHSep.Top, Rectangle( 0,7,28,6 ),'' );

    FOnConfirm := aOnConfirm;
    FMenu.SelectedColor  := White;
    FMenu.OnSelectEvent  := @OnMenuSelect;
    FMenu.OnConfirmEvent := @OnConfirm;

    for iCount := Low( aItems ) to High( aItems ) do
      if aItems [ iCount ] <> nil then
        FMenu.Add( aItems[ iCount ].Description, True, aItems[ iCount ], aItems[ iCount ].MenuColor );
  end;

  if FGeneral
    then iDesc := 'Press @<Escape@> to exit, to wear/wield or use an item press the item letter or use @<Up/Down@> to browse and @<Enter@> to choose, or @<Backspace@> to drop.'
    else iDesc := 'To '+aAction+' an item press the item letter or use @<Up/Down@> to browse and @<Enter@> to accept. Press @<Escape@> to exit.';

  TConUIText.Create( iHSep.Bottom, iDesc );
end;


{ TUIEquipmentView }

constructor TUIEquipmentView.Create ( aParent : TUIElement; aOnConfirm : TUIItemConfirm ) ;
const ResNames : array[TResistance] of AnsiString = ('Bullet','Melee','Shrap','Acid','Fire','Plasma');
      ResIDs   : array[TResistance] of AnsiString = ('bullet','melee','shrapnel','acid','fire','plasma');
var iVSep  : TUICustomSeparator;
    iHSep  : TUICustomSeparator;
    iCont  : TUIElement;
    iName  : AnsiString;
    iDesc1 : AnsiString;
    iDesc2 : AnsiString;
    iSlot  : TEqSlot;
    iCount : DWord;
    iRes   : TResistance;
begin
  inherited Create( aParent, aOnConfirm, '@yEquipment and Character Info', [ ItemResultPick, ItemResultDrop, ItemResultSwap ] );
  FFooter := '@<up/down/letter (pick), Enter (wear/wield), Backspace (drop), TAB (swap)@>';

  iCont := TUIElement.Create( Self, aParent.GetDimRect.Shrinked(0,1) );
  iHSep := TConUISeparator.Create( iCont, VORIENT_HORIZONTAL, 11 );
  iVSep := TConUISeparator.Create( iHSep.Top, VORIENT_VERTICAL, 54 );
  iVSep.Right.SetPadding( PointUnit );

  FMenu       := CreateMenu( Option_EqMenuStyle, iVSep.Left, Rectangle( 2,1,50,4 ) );
  FDesc       := TConUIText.Create( iHSep.Top, Rectangle( 2,6,50,2 ),'' );
  FStats      := TConUIText.Create( iVSep.Right, '' );

  FOnConfirm := aOnConfirm;
  FMenu.SelectedColor  := White;
  FMenu.OnSelectEvent  := @OnMenuSelect;
  FMenu.OnConfirmEvent := @OnConfirm;

  for iSlot := Low(TEqSlot) to High(TEqSlot) do
     if Player.Inv.Slot[iSlot] <> nil
       then FMenu.Add( Player.Inv.Slot[iSlot].Description, True, Player.Inv.Slot[iSlot], Player.Inv.Slot[iSlot].MenuColor )
       else FMenu.Add( SlotName(iSlot), True, nil, DarkGray );

  iDesc1 := '@lBasic traits@d'#10;
  iDesc2 := '@lAdvanced traits@d'#10;
  for iCount := 1 to MAXTRAITS do
    if Player.FTraits.Values[iCount] > 0 then
    begin
      iName := LuaSystem.Get(['traits',iCount,'name']);
      if iCount < 10
        then iDesc1 += Padded(iName,16)+'@d (@l'+IntToStr(Player.FTraits.Values[iCount])+'@d)'#10
        else iDesc2 += Padded(iName,16)+'@d (@l'+IntToStr(Player.FTraits.Values[iCount])+'@d)'#10;
    end;

  TConUIText.Create( iHSep.Bottom, Rectangle( 1,1,20,9 ), iDesc1);
  TConUIText.Create( iHSep.Bottom, Rectangle( 22,1,20,9 ), iDesc2);

  iDesc1 := '@lResistances@d'#10;
  for iRes := Low(TResistance) to High(TResistance) do
    iDesc1 +=  '@d'+Padded(ResNames[iRes],7)+'@l'+Padded(BonusStr(LuaSystem.Get(['player','resist',ResIDs[iRes]],0))+'%',5)+
       '@d Torso @l'+Padded(BonusStr(Player.getTotalResistance(ResIDs[iRes],TARGET_TORSO))+'%',5)+
       '@d Feet @l'+Padded(BonusStr(Player.getTotalResistance(ResIDs[iRes],TARGET_FEET))+'%',5)+#10;

  TConUIText.Create( iHSep.Bottom, Rectangle( 44,1,36,9 ), iDesc1);

end;

end.

