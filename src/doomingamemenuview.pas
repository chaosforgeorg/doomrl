{$INCLUDE doomrl.inc}
unit doomingamemenuview;
interface
uses doomio;

type TInGameMenuView = class( TInterfaceLayer )
  constructor Create;
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
protected
  FFinished       : Boolean;
  FAbandonMode    : Boolean;
  FAbandonMessage : Ansistring;
end;

implementation

uses vtig, vutil, vluasystem, dfplayer, doombase;

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

  if FAbandonMode then
  begin
    VTIG_Begin('ingame_menu_abandon', Point( 50, 10 ) );
    VTIG_Text( FAbandonMessage );
    VTIG_Text( 'Are you sure you want to abandon this run?', Yellow );
    VTIG_Text( '' );
    iRect := VTIG_GetWindowRect;
    if VTIG_Selectable( 'Continue run' ) then
    begin
      FFinished := True;
      IO.Msg('Ok, then. Stay and take what''s coming to ya...');
    end;

    if VTIG_Selectable( 'Abandon run' ) then
    begin
      Player.doQuit( True );
      FFinished := True;
    end;
    VTIG_End;

    IO.RenderUIBackground( iRect.TopLeft, iRect.BottomRight - PointUnit );

    if VTIG_EventCancel then FFinished := True;
    Exit;
  end;

  VTIG_Begin('ingame_menu', Point( 30, 9 ) );
  iRect := VTIG_GetWindowRect;
  if VTIG_Selectable( 'Continue' ) then
  begin
    FFinished := True;
  end;
  if VTIG_Selectable( 'Help', False ) then
  begin
  end;
  if VTIG_Selectable( 'Settings', False ) then
  begin
  end;
  if VTIG_Selectable( 'Abandon Run' ) then
  begin
    FAbandonMode    := True;
    FAbandonMessage := LuaSystem.ProtectedCall(['DoomRL','quit_message'],[]);
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

end.

