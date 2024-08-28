{$INCLUDE doomrl.inc}
unit doompagedview;
interface
uses vutil, doomio, dfdata, vgenerics,
  vuielement // deleteme
  ;

type TPagedView = class( TInterfaceLayer )
  constructor Create( aPages : TPagedReport; aInitialPage : AnsiString = ''; aDeleteMe : TUINotifyEvent = nil );
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
  destructor Destroy; override;
protected
  FFinished : Boolean;
  FPage     : Integer;
  FSize     : TPoint;
  FContent  : TPagedReport;

  FDeleteMe : TUINotifyEvent;
end;

implementation

uses sysutils, vmath, vtig, vtigio, vtigstyle;

constructor TPagedView.Create( aPages : TPagedReport; aInitialPage : AnsiString = ''; aDeleteMe : TUINotifyEvent = nil );
var i : DWord;
begin
  FDeleteMe := aDeleteMe;

  VTIG_EventClear;
  VTIG_ResetScroll( 'paged_view' );
  VTIG_ResetScroll( 'paged_view_inner' );
  FSize      := Point( 80, 25 );
  FContent   := aPages;
  FPage      := 0;
  if aInitialPage <> '' then
    for i := 0 to aPages.Titles.Size-1 do
      if aPages.Titles[i] = aInitialPage then
        FPage := i;
end;

procedure TPagedView.Update( aDTime : Integer );
var iString     : Ansistring;
    iTitle      : Ansistring;
    iStoreFrame : Ansistring;
    iStoreColor : DWord;
    iStoreBold  : DWord;
begin
  iStoreFrame := VTIGDefaultStyle.Frame[ VTIG_BORDER_FRAME ];
  iStoreColor := VTIGDefaultStyle.Color[ VTIG_TEXT_COLOR ];
  iStoreBold  := VTIGDefaultStyle.Color[ VTIG_BOLD_COLOR ];
  iTitle := FContent.Title;
  if FContent.Titles[ FPage ] <> '' then
    iTitle += ' ({y'+FContent.Titles[ FPage ]+'})';

  VTIG_BeginWindow( iTitle, 'paged_view', FSize );
    if FContent.Styled then
    begin
      VTIGDefaultStyle.Color[ VTIG_TEXT_COLOR ] := VTIGDefaultStyle.Color[ VTIG_FOOTER_COLOR ];
      VTIGDefaultStyle.Color[ VTIG_BOLD_COLOR ] := VTIGDefaultStyle.Color[ VTIG_TITLE_COLOR ];
    end;

    if FContent.Headers[ FPage ] <> '' then
    begin
      VTIG_Text( FContent.Headers[ FPage ] );
      VTIGDefaultStyle.Frame[ VTIG_BORDER_FRAME ] := '';
      VTIG_Begin( 'paged_view_inner', FSize - Point(0,4), Point(1,4) );
      VTIGDefaultStyle.Frame[ VTIG_BORDER_FRAME ] := iStoreFrame;
    end;

    for iString in FContent.Pages[ FPage ] do
      VTIG_Text( iString );

    if FContent.Styled then
    begin
      VTIGDefaultStyle.Color[ VTIG_TEXT_COLOR ] := iStoreColor;
      VTIGDefaultStyle.Color[ VTIG_BOLD_COLOR ] := iStoreBold;
    end;
    VTIG_Scrollbar;

    if FContent.Headers[ FPage ] <> '' then
      VTIG_End;
  VTIG_End('{l<{!Up},{!Down}> scroll, <{!Left},{!Right}> pages, <{!Enter},{!Escape}> return}');
  IO.RenderUIBackground( PointZero, FSize );

  if VTIG_EventCancel or VTIG_EventConfirm then
    FFinished := True;
  if VTIG_Event( [VTIG_IE_LEFT,VTIG_IE_RIGHT] ) then
  begin
    if VTIG_Event( VTIG_IE_LEFT )  then FPage := TrueModulo( FPage - 1, FContent.Pages.Size );
    if VTIG_Event( VTIG_IE_RIGHT ) then FPage := TrueModulo( FPage + 1, FContent.Pages.Size );
    VTIG_ResetScroll( 'paged_view' );
    VTIG_ResetScroll( 'paged_view_inner' );
  end;
end;

function TPagedView.IsFinished : Boolean;
begin
  Exit( FFinished );
end;

function TPagedView.IsModal : Boolean;
begin
  Exit( True );
end;

destructor TPagedView.Destroy;
begin
  FreeAndNil( FContent );
  inherited Destroy;
  if Assigned( FDeleteMe ) then FDeleteMe( nil );
end;


end.

