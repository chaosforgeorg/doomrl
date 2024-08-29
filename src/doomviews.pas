{$INCLUDE doomrl.inc}
unit doomviews;
interface
uses vuielement, vuielements, viotypes, vuitypes, vioevent, vconui, vconuiext, vconuirl,
     dfdata;

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

type TUIMessagesViewer = class( TUIFullWindow )
  constructor Create( aParent : TUIElement; aMessages : TUIChunkBuffer );
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
     doomio, doomgfxio, dfhof;

const MessagesHeader   = 'Past messages viewer';
      ScrollFooterOn   = '@<Use arrows, PgUp, PgDown to scroll, Escape or Enter to exit@>';
      ScrollFooterOff  = '@<Use Escape or Enter to exit@>';

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

