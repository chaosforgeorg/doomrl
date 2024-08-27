{$INCLUDE doomrl.inc}
unit doomviews;
interface
uses vuielement, vuielements, viotypes, vuitypes, vioevent, vconui, vconuiext, vconuirl,
     dfdata;

type TUIChallengeList = array of Byte;

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
  constructor Create( aParent : TUIElement; aReport : TPagedReport );
  procedure SetPage( aIndex : Integer );
  procedure OnRedraw; override;
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
  destructor Destroy; override;
protected
  FReport     : TPagedReport;
  FPage       : DWord;
  FContent    : TConUIStringList;
  FIcons      : TConUIScrollableIcons;
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

type TUIRankUpViewer = class( TUIFullWindow )
  constructor Create( aParent : TUIElement; aRank : THOFRank );
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

{
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

}

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
     doombase, doomhelp, doomio, doomgfxio, dfplayer, dfhof;

const HelpHeader       = 'DRL Help System';
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
    with IO as TDoomGFXIO do
    begin
      iSize.Init( Driver.GetSizeX, Driver.GetSizeY );
      iStep.Init( iSize.X div 15, iSize.Y div 15 );
      iPoint.Init( iSize.X div 400, iSize.X div 400 );
      iV1.Init(           iStep.X, iStep.Y * 7 );
      iV2.Init( iSize.X - iStep.X, iStep.Y * 8 );
      QuadSheet.PushColoredQuad( iV1, iV2, TGLVec4f.Create( 1,0,0,1 ) );
      iV1 := iV1 + iPoint;
      iV2 := iV2 - iPoint;
      QuadSheet.PushColoredQuad( iV1, iV2, TGLVec4f.Create( 0,0,0,1 ) );
      iV1 := iV1 + iPoint.Scaled(2);
      iV2 := iV2 - iPoint.Scaled(2);
      iV2.X := Round( ( iV2.X - iV1.X ) * (FCurrent / FMax) ) + iV1.X;
      QuadSheet.PushColoredQuad( iV1, iV2, TGLVec4f.Create( 1,0.9,0,1 ) );
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
    if FCurrent = 0 then
    begin
      // Don't ask. Simply don't ask. Either FPC video unit or Windows 11 console
      // is so broken that without this part, the loading screen gets printed
      // incorrectly. Why? No fucking clue.
      Sleep(100);
      Exit;
    end;
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
    (IO as TDoomGFXIO).QuadSheet.PushColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.7 ) );
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
  iContent := TConUIStringList.Create( Self, iRect, TextFileToUIStringArray( WritePath + 'mortem.txt' ), True );
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

{ TUIPagedViewer }

constructor TUIPagedViewer.Create ( aParent : TUIElement; aReport : TPagedReport ) ;
var iRect : TUIRect;
begin
  inherited Create( aParent, aReport.Title, PagedFooter );
  FPage        := 0;
  FReport      := aReport;
  iRect        := aParent.GetDimRect.Shrinked(0,2);
  FContent     := TConUIStringList.Create( Self, iRect );
  FIcons       := TConUIScrollableIcons.Create( Self, FContent, iRect, Point( FAbsolute.X2 - 7, FAbsolute.Y ) );
  FContent.EventFilter := [ VEVENT_KEYDOWN, VEVENT_MOUSEDOWN ];
  SetPage(0);
end;

procedure TUIPagedViewer.SetPage ( aIndex : Integer ) ;
var iRect : TUIRect;
begin
  if aIndex >= FReport.Titles.Size then Exit;

  iRect := GetDimRect.Shrinked(0,2);
  if FReport.Headers[ aIndex ] <> ''
    then
    begin
      iRect.Pos.y += 2;
      iRect.Dim.y -= 2;
    end;

  FContent.SetArea( iRect );
  FIcons.SetArea( iRect );
  FContent.SetContent( FReport.Pages[ aIndex ], False );
  FPage  := aIndex;
  FDirty := True;
end;

procedure TUIPagedViewer.OnRedraw;
var iCon   : TUIConsole;
begin
  inherited OnRedraw;
  iCon.Init( TConUIRoot(FRoot).Renderer );
  FTitle := FReport.Title;
  if FReport.Titles[FPage] <> '' then
    FTitle += ' (@y'+ FReport.Titles[FPage] + '@>)';
  if FReport.Pages.Size = 0 then Exit;

  if FReport.Headers[FPage] <> '' then
    iCon.Print( Point( FAbsolute.x, FAbsolute.y+2 ), FForeColor, FBackColor, FReport.Headers[FPage], True );
end;

function TUIPagedViewer.OnKeyDown ( const event : TIOKeyEvent ) : Boolean;
begin
  if (event.ModState <> []) or (FReport.Titles.Size = 0) then Exit( inherited OnKeyDown( event ) );
  case event.Code of
    VKEY_LEFT   : SetPage( TrueModulo( FPage - 1, FReport.Titles.Size ) );
    VKEY_RIGHT  : SetPage( TrueModulo( FPage + 1, FReport.Titles.Size ) );
  else Exit( inherited OnKeyDown( event ) );
  end;
end;

destructor TUIPagedViewer.Destroy;
begin
  FreeAndNil( FReport );
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
    FMenu.Add(LuaSystem.Get(['chal',aChallenges[iCount],FPrefix+'name']),(aRank >= LuaSystem.Get(['chal',aChallenges[iCount],FPrefix+'rank'],0)) or (GodMode) or (Setting_UnlockAll), Pointer(aChallenges[iCount]) );

end;

function TUIChallengesViewer.OnMenuSelect ( aSender : TUIElement; aIndex : DWord; aItem : TUIMenuItem ) : Boolean;
var iChoice : Byte;
begin
  if not FMenu.IsValid( aIndex ) then Exit( True );
  iChoice := Byte( FMenu.SelectedItem.Data );
  FLabel.Text := Padded( '- @<' + LuaSystem.Get(['chal',iChoice,FPrefix+'name']) + ' @>', 53, '-');
  FDesc.Text  := '@rRating: @y'+LuaSystem.Get(['chal',iChoice,FPrefix+'rating'],'UNRATED')+#10#10+
                 '@l'+LuaSystem.Get(['chal',iChoice,FPrefix+'description']);
  Exit( True )
end;

{ TUICustomChallengesViewer }
{
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
}

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

end.

