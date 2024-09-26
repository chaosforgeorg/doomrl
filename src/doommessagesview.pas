{$INCLUDE doomrl.inc}
unit doommessagesview;
interface
uses vutil, vmessages, doomio, dfdata;

type TMessagesView = class( TInterfaceLayer )
  constructor Create( aContent : TMessageBuffer );
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
protected
  FContent  : TMessageBuffer;
  FSize     : TPoint;
  FRect     : TRectangle;
  FFinished : Boolean;
  FFirst    : Boolean;
end;

implementation

uses sysutils, vtig;

constructor TMessagesView.Create( aContent : TMessageBuffer );
begin
  VTIG_EventClear;
  FSize      := Point( 80, 25 );
  FContent   := aContent;
  FFinished  := False;
  FFirst     := True;
end;

procedure TMessagesView.Update( aDTime : Integer );
var i : Integer;
begin
  VTIG_BeginWindow('Past messages', 'messages_view', FSize );
  VTIG_AdjustPadding( Point(-1,0) );
  if FContent.Size > 0 then
    for i := 0 to FContent.Size-1 do
      if FContent[i] <> '' then
        VTIG_Text( FContent[i] );
  VTIG_Scrollbar( FFirst );
  FRect := VTIG_GetWindowRect;
  VTIG_End('{l<{!Up,Down,PgUp,PgDown}> scroll, <{!Enter},{!Escape}> continue}');

  if FFirst then
  begin
    FFirst := False;
    Update( aDTime );
    Exit;
  end;

  if VTIG_EventCancel or VTIG_EventConfirm then
    FFinished := True;
  IO.RenderUIBackground( FRect.TopLeft, FRect.BottomRight - PointUnit );
end;


function TMessagesView.IsFinished : Boolean;
begin
  Exit( FFinished );
end;

function TMessagesView.IsModal : Boolean;
begin
  Exit( True );
end;

end.

