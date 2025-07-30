{$INCLUDE doomrl.inc}
unit doomrankupview;
interface
uses vutil, doomio, dfdata;

type TRankUpView = class( TInterfaceLayer )
  constructor Create( aRank : THOFRank );
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
protected
  FFinished : Boolean;
  FSize     : TPoint;
  FRect     : TRectangle;
  FLines    : array of Ansistring;
end;

implementation

uses sysutils, vluasystem, vtig;

constructor TRankUpView.Create( aRank : THOFRank );
var i     : Integer;
    iSize : Integer;
    iRank : Ansistring;
    iDesc : Ansistring;
begin
  VTIG_EventClear;
  FSize      := Point( 80, 25 );
  iSize := 0;
  SetLength( FLines, High( aRank.Data ) );
  for i := 0 to High( aRank.Data ) do
    if aRank.Data[i].Value <> 0 then
    begin
      iRank := LuaSystem.Get(['ranks',aRank.Data[i].ID,aRank.Data[i].Value+1,'name'],'');
      iDesc := LuaSystem.Get(['ranks',aRank.Data[i].ID,'award'],'');
      FLines[iSize] := Format( iDesc, [iRank] );
      Inc( iSize );
    end;

  SetLength( FLines, iSize );
end;

procedure TRankUpView.Update( aDTime : Integer );
var i : Integer;
begin
  VTIG_BeginWindow('Congratulations!', 'rank_up_view', FSize );

  for i := 0 to High( FLines ) do
    VTIG_FreeLabel( FLines[i], Point( 4, 6+i ) );

  VTIG_FreeLabel( 'Press <{!{$input_ok}}>...', Point( 12, 8+i ) );

  FRect := VTIG_GetWindowRect;
  VTIG_End('{l<{!{$input_ok},{$input_escape}}> continue}');
  if VTIG_EventCancel or VTIG_EventConfirm then
    FFinished := True;
  IO.RenderUIBackground( FRect.TopLeft, FRect.BottomRight - PointUnit );
end;


function TRankUpView.IsFinished : Boolean;
begin
  Exit( FFinished );
end;

function TRankUpView.IsModal : Boolean;
begin
  Exit( True );
end;

end.

