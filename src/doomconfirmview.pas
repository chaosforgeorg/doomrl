{$INCLUDE doomrl.inc}
unit doomconfirmview;
interface
uses vutil, doomio;

type TOnConfirmObjectCallback = procedure of object;
     TOnConfirmRawCallback    = procedure;

type TConfirmView = class( TInterfaceLayer )
  constructor Create;
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
protected
  procedure Initialize; virtual;
  procedure OnConfirm; virtual;
  procedure OnCancel; virtual;
protected
  FSize            : TPoint;
  FFinished        : Boolean;

  FCancel          : AnsiString;
  FConfirm         : AnsiString;
  FMessage         : AnsiString;

  FOnConfirmObject : TOnConfirmObjectCallback;
  FOnConfirmRaw    : TOnConfirmRawCallback;
end;

implementation

uses vtig, doombase;
 
constructor TConfirmView.Create;
begin
  Initialize;
end;

procedure TConfirmView.Initialize;
begin
  VTIG_EventClear;
  VTIG_ResetSelect( 'confirm_menu' );
  FOnConfirmObject := nil;
  FOnConfirmRaw := nil;
  FSize     := Point( 50, -1 );
  FFinished := False;
  FCancel  := 'Cancel';
  FConfirm := 'Confirm';
  FMessage := '';
end;

procedure TConfirmView.Update( aDTime : Integer );
var iRect   : TRectangle;
    iResult : ( None, Cancel, Confirm );
begin
  if IsFinished then Exit;

  iResult := None;
  VTIG_Begin('confirm_menu', FSize );
  VTIG_Text( FMessage );
  VTIG_Text( '' );
  iRect := VTIG_GetWindowRect;
  if VTIG_Selectable( FCancel )  then iResult := Cancel;
  if VTIG_Selectable( FConfirm ) then iResult := Confirm;
  VTIG_End;

  IO.RenderUIBackground( iRect.TopLeft, iRect.BottomRight - PointUnit );

  if VTIG_EventCancel then iResult := Cancel;
  case iResult of
    Confirm : begin FFinished := True; OnConfirm; end;
    Cancel  : begin FFinished := True; OnCancel; end;
  end;
end;

function TConfirmView.IsFinished : Boolean;
begin
  Exit( FFinished or ( Doom.State <> DSPlaying ) );
end;

function TConfirmView.IsModal : Boolean;
begin
  Exit( True );
end;

procedure TConfirmView.OnConfirm;
begin
  if Assigned( FOnConfirmObject ) then FOnConfirmObject;
  if Assigned( FOnConfirmRaw )    then FOnConfirmRaw;
end;

procedure TConfirmView.OnCancel;
begin
end;

end.
