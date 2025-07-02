{$INCLUDE doomrl.inc}
unit doompagedview;
interface
uses vutil, doomio, dfdata, vgenerics;

type TPagedView = class( TInterfaceLayer )
  constructor Create( aPages : TPagedReport; aInitialPage : AnsiString = '' );
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
  destructor Destroy; override;
protected
  FFinished : Boolean;
  FPage     : Integer;
  FSize     : TPoint;
  FRect     : TRectangle;
  FContent  : TPagedReport;
end;

implementation

uses sysutils, vmath, vtig, vtigio;

constructor TPagedView.Create( aPages : TPagedReport; aInitialPage : AnsiString = '' );
var i : DWord;
begin
  VTIG_EventClear;
  VTIG_ResetScroll( 'paged_view' );
  VTIG_ResetScroll( 'paged_view_inner' );
  FSize      := VTIG_GetIOState.Size;
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
begin
  iTitle := FContent.Title;
  if FContent.Titles[ FPage ] <> '' then
    iTitle += ' ({y'+FContent.Titles[ FPage ]+'})';

  VTIG_BeginWindow( iTitle, 'paged_view', FSize );
    if FContent.Styled then VTIG_PushStyle( @TIGStyleColored );

    if FContent.Headers[ FPage ] <> '' then
    begin
      VTIG_Text( FContent.Headers[ FPage ] );
      VTIG_PushStyle( @TIGStyleFrameless );
      VTIG_Begin( 'paged_view_inner', FSize - Point(1,4), Point(2,4) );
      VTIG_PopStyle;
    end;

    for iString in FContent.Pages[ FPage ] do
      VTIG_Text( iString );

    if FContent.Styled then VTIG_PopStyle;
    VTIG_Scrollbar;

    if FContent.Headers[ FPage ] <> '' then
      VTIG_End;
  FRect := VTIG_GetWindowRect;
  VTIG_End('{l<{!Up},{!Down}> scroll, <{!Left},{!Right}> pages, <{!Enter},{!Escape}> return}');
  IO.RenderUIBackground( FRect.TopLeft, FRect.BottomRight - PointUnit );

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
end;


end.

