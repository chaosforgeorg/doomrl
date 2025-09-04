{$INCLUDE drl.inc}
{
 ----------------------------------------------------
Copyright (c) 2002-2025 by Kornel Kisielewicz
----------------------------------------------------
}
unit drlmoreview;
interface
uses vutil, viotypes, drlio, dfdata, dfbeing;

type TMoreView = class( TIOLayer )
  constructor Create( aBeing : TBeing );
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
protected
  FFinished : Boolean;
  FSize     : TPoint;
  FBeing    : TBeing;
  FDesc     : Ansistring;
  FASCII    : Ansistring;
end;

implementation

uses vluasystem, vtig, dfplayer, drlbase;

constructor TMoreView.Create( aBeing : TBeing );
begin
  VTIG_EventClear;
  FFinished := False;
  FBeing    := aBeing;
  FDesc     := LuaSystem.Get(['beings',FBeing.ID,'desc']);
  FASCII    := '';
  if not ModuleOption_FullBeingDescription then
    if FBeing.ID = 'soldier'
      then FASCII := Player.ASCIIMoreCode
      else FASCII := FBeing.ID;
  FSize      := Point( 80, 25 );
end;

procedure TMoreView.Update( aDTime : Integer; aActive : Boolean );
var iString : Ansistring;
    iCount  : Integer;
begin
  if not ModuleOption_FullBeingDescription then
  begin
    VTIG_PushStyle(@TIGStylePadless);
    VTIG_BeginWindow(FBeing.name, 'more_view', FSize );
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

    VTIG_BeginWindow(FBeing.name, Point( 38, -1 ), Point( 40,11 ) );
    VTIG_Text( FDesc );
    VTIG_End;
    VTIG_End('{l<{!{$input_escape}},{!{$input_ok}}> exit}');
  end
  else
  begin
    VTIG_BeginWindow(FBeing.name, 'more_view', FSize );
    VTIG_Text( 'Health   : {!{R{0}}/{1}}',[ FBeing.HP, FBeing.HPMax ] );
    VTIG_End('{l<{!{$input_escape}},{!{$input_ok}}> exit}');
  end;

  if VTIG_EventCancel or VTIG_EventConfirm or VTIG_Event( TIG_EV_MORE ) then
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

