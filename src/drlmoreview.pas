{$INCLUDE drl.inc}
{
 ----------------------------------------------------
Copyright (c) 2002-2025 by Kornel Kisielewicz
----------------------------------------------------
}
unit drlmoreview;
interface
uses vutil, viotypes, drlio, dfdata;

type TMoreView = class( TIOLayer )
  constructor Create( aSid : Ansistring );
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
protected
  FFinished : Boolean;
  FSize     : TPoint;
  FSID      : Ansistring;
  FName     : Ansistring;
  FDesc     : Ansistring;
  FASCII    : Ansistring;
end;

implementation

uses vluasystem, vtig, dfplayer, drlbase;

constructor TMoreView.Create( aSid : Ansistring );
begin
  VTIG_EventClear;
  FFinished := False;
  FSID  := aSid;
  FName := Capitalized(LuaSystem.Get(['beings',FSID,'name']));
  FDesc := LuaSystem.Get(['beings',FSID,'desc']);
  if FSID = 'soldier'
    then FASCII := Player.ASCIIMoreCode
    else FASCII := FSID;
  FSize      := Point( 80, 25 );
end;

procedure TMoreView.Update( aDTime : Integer; aActive : Boolean );
var iString : Ansistring;
    iCount  : Integer;
begin
  VTIG_PushStyle(@TIGStylePadless);
  VTIG_BeginWindow(FName, 'more_view', FSize );
  VTIG_PopStyle();
  iCount := 0;
  if IO.Ascii.Exists(FASCII) then
    for iString in IO.Ascii[FASCII] do
    begin
      VTIG_FreeLabel( iString, Point( 2, iCount ) );
      Inc( iCount );
    end
  else
    VTIG_FreeLabel( 'Picture'#10'N/A', Point( 10, 10 ), LightRed );

  VTIG_BeginWindow(FName, Point( 38, -1 ), Point( 40,11 ) );
  VTIG_Text( FDesc );
  VTIG_End;

  VTIG_End('{l<{!{$input_escape}},{!{$input_ok}}> exit}');
  if VTIG_EventCancel or VTIG_EventConfirm then
    FFinished := True;
end;


function TMoreView.IsFinished : Boolean;
begin
  Exit( FFinished or ( DRL.State <> DSPlaying ) );
end;

function TMoreView.IsModal : Boolean;
begin
  Exit( True );
end;

end.

