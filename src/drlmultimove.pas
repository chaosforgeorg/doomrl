{$INCLUDE doomrl.inc}
unit drlmultimove;
interface
uses classes, vnode, vrltools, vpath, doomkeybindings;

type TMultiMove = class( TVObject )
  constructor Create;
  procedure Stop;
  procedure Start( const aDir : TDirection );
  procedure Start( aPath : TPathfinder );
  function IsRepeat : Boolean;
  function IsPath   : Boolean;
  function CalculateInput( const aPosition : TCoord2D ) : TInputKey;
private
  FActive   : Boolean;
  FCount    : Word;
  FPath     : TPathFinder;
  FDir      : TDirection;
public
  property Active : Boolean read FActive;
end;

implementation

uses dfdata;

{ TRunData }

constructor TMultiMove.Create;
begin
  FCount  := 0;
  FActive := False;
  FPath   := nil;
end;

procedure TMultiMove.Stop;
begin
  FCount  := 0;
  FActive := False;
  FPath   := nil;
end;

procedure TMultiMove.Start( const aDir : TDirection ) ;
begin
  FActive := True;
  FCount  := 0;
  FDir    := aDir;
  FPath   := nil;
end;

procedure TMultiMove.Start( aPath : TPathfinder );
begin
  FCount      := 0;
  FActive     := True;
  FPath       := aPath;
  FPath.Start := FPath.Start.Child;
end;

function TMultiMove.IsRepeat : Boolean;
begin
  Exit( FActive and ( FPath = nil ) );
end;

function TMultiMove.IsPath   : Boolean;
begin
  Exit( Assigned( FPath ) );
end;

function TMultiMove.CalculateInput( const aPosition : TCoord2D ) : TInputKey;
var iDir : TDirection;
begin
  Inc( FCount );
  if Assigned( FPath ) then
  begin
    if (not FPath.Found) or (FPath.Start = nil) or (FPath.Start.Coord = aPosition) then
    begin
      Stop;
      Exit( INPUT_NONE );
    end;
    iDir := NewDirection( aPosition, FPath.Start.Coord );
    FPath.Start := FPath.Start.Child;
  end
  else
  begin
    iDir := FDir;
    if iDir.code = 5 then
    begin
      if FCount >= Option_MaxWait then Stop;
    end
    else
      if FCount >= Option_MaxRun then Stop;
  end;
  Exit( DirectionToInput( iDir ) );
end;

end.

