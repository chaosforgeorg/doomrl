{$INCLUDE doomrl.inc}
unit doomhelpview;
interface
uses vutil, doomio,
    vuielement // deleteme
  ;

type THelpView = class( TInterfaceLayer )
  constructor Create( aDeleteMe : TUINotifyEvent = nil );
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
  destructor Destroy; override;
protected
  procedure UpdateRead;
  procedure UpdateMenu;
protected
  FMode    : ( HELPVIEW_MENU, HELPVIEW_READ, HELPVIEW_DONE );
  FCurrent : Byte;
  FSize    : TPoint;

  FDeleteMe : TUINotifyEvent;
end;

implementation

uses vtig, doomhelp;

// deleteme
destructor THelpView.Destroy;
begin
  inherited Destroy;
  if Assigned( FDeleteMe ) then FDeleteMe( nil );
end;

constructor THelpView.Create( aDeleteMe : TUINotifyEvent = nil );
begin
  FDeleteMe := aDeleteMe;

  VTIG_EventClear;
  VTIG_ResetSelect( 'help_view' );

  FSize    := Point( 80, 25 );
  FMode    := HELPVIEW_MENU;
  FCurrent := 0;
end;

procedure THelpView.Update( aDTime : Integer );
begin
       if FMode = HELPVIEW_MENU then UpdateMenu
  else if FMode = HELPVIEW_READ then UpdateRead;
  IO.RenderUIBackground( PointZero, FSize );
end;

function THelpView.IsFinished : Boolean;
begin
  Exit( FMode = HELPVIEW_DONE );
end;

function THelpView.IsModal : Boolean;
begin
  Exit( True );
end;

procedure THelpView.UpdateRead;
var iText : Ansistring;
begin
  VTIG_BeginWindow( Help.RegHelps[FCurrent].Desc, 'help_view_read', FSize );
  for iText in Help.RegHelps[FCurrent].Text do
    VTIG_Text( iText );
  VTIG_Scrollbar;
  VTIG_End('{l<{!Up},{!Down}> scroll, <{!Enter},{!Escape}> return}');
  if VTIG_EventCancel or VTIG_EventConfirm then
    FMode := HELPVIEW_MENU;
end;

procedure THelpView.UpdateMenu;
var i,iSelect : Integer;

begin
  VTIG_BeginWindow( 'Help topics', 'help_view', FSize );
  iSelect := 0;
  for i := 1 to Help.HNum do
    if VTIG_Selectable( '      '+Help.RegHelps[i].Desc ) then
       iSelect := i;
  if VTIG_Selectable(   '      '+'Quit help' ) then
     FMode := HELPVIEW_DONE;

  VTIG_Ruler;

  VTIG_Text('Select help topic above. Quick (default) kebindings primer:');
  VTIG_Text('');
  VTIG_Text('  {!Escape}    - game menu (Save, Quit, Settings, Help, etc)');
  VTIG_Text('  {!Arrows}    - movement (Home,End,PgUp,PgDown - diagonals)');
  VTIG_Text('  {!.}(period) - wait (pass turn)');
  VTIG_Text('  {!SPACE}     - action (open,close,press button,descend stairs)');
  VTIG_Text('  {!I},{!E},{!P},{!T}   - inventory, equipment etc (left/right to switch while open)');
  VTIG_Text('  {!F}         - fire weapon (SHIFT for alternative mode)');
  VTIG_Text('  {!R}         - reload weapon (SHIFT for alternative mode)');
  VTIG_Text('  {!G}         - get item (pickup) from floor (SHIFT to use)');
  VTIG_Text('  ...          see "Controls" entry for the rest');




  VTIG_End('{l<{!Up},{!Down}> select, <{!Enter}> open, <{!Escape}> exit}');
  if iSelect > 0 then
  begin
    VTIG_ResetScroll( 'help_view_read' );
    FMode    := HELPVIEW_READ;
    FCurrent := iSelect;
  end;

  if VTIG_EventCancel then
     FMode := HELPVIEW_DONE;
end;

end.

