{$INCLUDE doomrl.inc}
unit doomplotview;
interface
uses vutil, doomio, dfdata;

type TPlotView = class( TInterfaceLayer )
  constructor Create( aMessage : AnsiString; aColor : DWord );
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
protected
  FMessage  : AnsiString;
  FBuffer   : AnsiString;
  FFinished : Boolean;
  FBoost    : Boolean;
  FPosition : DWord;
  FTime     : DWord;
  FColor    : DWord;
  FSize     : TPoint;
end;

implementation

uses vtig;

constructor TPlotView.Create( aMessage : AnsiString; aColor : DWord  );
begin
  VTIG_EventClear;
  FSize      := Point( 80, 25 );
  FFinished  := False;
  FPosition  := 0;
  FTime      := 0;
  FMessage   := aMessage;
  FColor     := aColor;
  FBoost     := False;
  FBuffer    := '';
end;

procedure TPlotView.Update( aDTime : Integer );
var iRate : DWord;
begin
  iRate := 40;
  if FBoost then iRate := 2;
  FTime += aDTime;
  while (FTime >= iRate) and (FPosition < Length( FMessage )) do
  begin
    FTime -= iRate;
    Inc( FPosition );
  end;
  VTIG_Clear;
  VTIG_SetMaxCharacters( FPosition );
  VTIG_FreeLabel( FMessage, Rectangle( 10, 5, 62, 15 ), RED );
  IO.RenderUIBackground( PointZero, FSize );

  if VTIG_EventCancel or VTIG_EventConfirm then
     if ( not FBoost ) and ( FPosition < ( Length(FMessage) * 0.8 ) )
        then FBoost := True
        else FFinished := True;
end;

function TPlotView.IsFinished : Boolean;
begin
  Exit( FFinished );
end;

function TPlotView.IsModal : Boolean;
begin
  Exit( True );
end;

end.

