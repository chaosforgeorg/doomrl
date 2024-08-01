{$INCLUDE doomrl.inc}
unit doomingamemenuview;
interface
uses doomio, doomconfirmview;

type TInGameMenuView = class( TInterfaceLayer )
  constructor Create;
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
protected
  FFinished       : Boolean;
end;

type TAbandonView = class( TConfirmView )
  constructor Create;
protected
  procedure OnConfirm; override;
  procedure OnCancel; override;
end;

implementation

uses vtig, vutil, vluasystem, dfplayer, doombase, doomhelpview, doomsettingsview;

constructor TInGameMenuView.Create;
begin
  VTIG_EventClear;
  VTIG_ResetSelect( 'ingame_menu_abandon' );
  //VTIG_ResetSelect( 'ingame_menu' );
  FFinished := False;
end;

procedure TInGameMenuView.Update( aDTime : Integer );
var iRect : TRectangle;
begin
  if IsFinished or (Doom.State <> DSPlaying) then Exit;

  VTIG_Begin('ingame_menu', Point( 30, 9 ) );
  iRect := VTIG_GetWindowRect;
  if VTIG_Selectable( 'Continue' ) then
  begin
    FFinished := True;
  end;
  if VTIG_Selectable( 'Help' ) then
  begin
    IO.PushLayer( THelpView.Create );
    FFinished := True;
  end;
  if VTIG_Selectable( 'Settings' ) then
  begin
    IO.PushLayer( TSettingsView.Create );
    FFinished := True;
  end;
  if VTIG_Selectable( 'Abandon Run' ) then
  begin
    FFinished := True;
    IO.PushLayer( TAbandonView.Create );
  end;
  if VTIG_Selectable( 'Save & Quit' ) then
  begin
    FFinished := True;
    Player.doSave;
  end;
  VTIG_End;

  IO.RenderUIBackground( iRect.TopLeft, iRect.BottomRight - PointUnit );

  if VTIG_EventCancel then FFinished := True;
end;

function TInGameMenuView.IsFinished : Boolean;
begin
  Exit( FFinished or ( Doom.State <> DSPlaying ) );
end;

function TInGameMenuView.IsModal : Boolean;
begin
  Exit( True );
end;

constructor TAbandonView.Create;
begin
  inherited Create;
  FCancel  := 'Continue run';
  FConfirm := 'Abandon run';
  FMessage := LuaSystem.ProtectedCall(['DoomRL','quit_message'],[]) + #10 +
    '{yAre you sure you want to abandon this run?}';
  FSize    := Point( 50, 10 );
end;

procedure TAbandonView.OnConfirm;
begin
  Player.doQuit( True );
end;

procedure TAbandonView.OnCancel;
begin
  IO.Msg('Ok, then. Stay and take what''s coming to ya...');
end;

end.

