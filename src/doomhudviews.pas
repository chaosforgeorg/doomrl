{$INCLUDE doomrl.inc}
unit doomhudviews;
interface
uses vutil, vcolor, vrltools, dfdata, dfitem, doomkeybindings;

type TLookModeView = class( TInterfaceLayer )
  constructor Create;
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
  function HandleInput( aInput : TInputKey ) : Boolean; override;
protected
  procedure UpdateTarget;
protected
  FFirst    : Boolean;
  FFinished : Boolean;
  FTarget   : TCoord2D;
end;

type TDirectionQueryLayer = class( TInterfaceLayer )
  constructor Create;
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
  function HandleInput( aInput : TInputKey ) : Boolean; override;
protected
  procedure Finalize( aDir : TDirection ); virtual; abstract;
protected
  FPrompt   : AnsiString;
  FFinished : Boolean;
end;

type TRunModeView = class( TDirectionQueryLayer )
  constructor Create;
protected
  procedure Finalize( aDir : TDirection ); override;
end;

type TMeleeDirView = class( TDirectionQueryLayer )
  constructor Create;
protected
  procedure Finalize( aDir : TDirection ); override;
end;

type TActionDirView = class( TDirectionQueryLayer )
  constructor Create( aAction : Ansistring; aFlag : Byte );
protected
  procedure Finalize( aDir : TDirection ); override;
protected
  FFlag : Byte;
end;

type TTargetModeView = class( TInterfaceLayer )
  constructor Create( aItem : TItem; aCommand : Byte; aActionName : AnsiString; aRange: byte; aLimitRange : Boolean; aTargets: TAutoTarget; aChainFire : Byte );
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
  function HandleInput( aInput : TInputKey ) : Boolean; override;
protected
  procedure Finalize;
  procedure UpdateTarget;
protected
  FFirst      : Boolean;
  FFinished   : Boolean;
  FLimitRange : Boolean;
  FTarget     : TCoord2D;
  FPosition   : TCoord2D;
  FColor      : Byte;
  FRange      : Byte;
  FChainFire  : Byte;
  FActionName : AnsiString;
  FNameLen    : Byte;
  FTargets    : TAutoTarget;
  FItem       : TItem;
  FCommand    : Byte;
end;

implementation

uses sysutils, vtig, vvision, dfplayer, dflevel, doombase, doomio, doomcommand, doomspritemap;

constructor TLookModeView.Create;
begin
  FFirst  := True;
  FTarget := Player.Position;
  IO.Targeting := True;
end;

procedure TLookModeView.Update( aDTime : Integer );
begin
  if FFirst then UpdateTarget;
  VTIG_FreeLabel( ' = LOOK MODE =', Point( -15, 1 ), Yellow )
end;

function TLookModeView.IsFinished : Boolean;
begin
  Exit( FFinished );
end;

function TLookModeView.IsModal : Boolean;
begin
  Exit( True );
end;

function TLookModeView.HandleInput( aInput : TInputKey ) : Boolean;
var iLevel : TLevel;
    iDir   : TDirection;
begin
  if aInput in [ INPUT_ESCAPE, INPUT_MRIGHT, INPUT_QUIT, INPUT_HARDQUIT ] then
  begin
    IO.MsgUpDate;
    IO.Console.HideCursor;
    IO.Targeting := False;
    if SpriteMap <> nil then SpriteMap.ClearTarget;
    FFinished := true;
    Exit( True );
  end;

  if (aInput = INPUT_TOGGLEGRID) and GraphicsVersion then SpriteMap.ToggleGrid;
  if aInput in [ INPUT_MMOVE, INPUT_MRIGHT, INPUT_MLEFT ] then FTarget := IO.MTarget;
  iLevel := Doom.Level;
  if aInput <> INPUT_MORE then
  begin
    iDir := InputDirection( aInput );
    if iLevel.isProperCoord( FTarget + iDir ) then
    begin
      FTarget += iDir;
      UpdateTarget;
    end;
   end;
   if (aInput in [ INPUT_MORE, INPUT_MLEFT ]) and iLevel.isVisible( FTarget ) then
   begin
     with iLevel do
       if Being[FTarget] <> nil then
         IO.FullLook( Being[FTarget].ID );
     UpdateTarget;
   end;
   Exit( True );
end;

procedure TLookModeView.UpdateTarget;
begin
  FFirst := False;
  IO.Focus( FTarget );
  IO.LookDescription( FTarget );
  if SpriteMap <> nil then SpriteMap.SetTarget( FTarget, NewColor( White ), False );
end;

constructor TDirectionQueryLayer.Create;
begin
  FPrompt := '';
end;

procedure TDirectionQueryLayer.Update( aDTime : Integer );
begin
  VTIG_FreeLabel( FPrompt + ', choose direction...', Point( 0, 2 ), Yellow )
end;

function TDirectionQueryLayer.IsFinished : Boolean;
begin
  Exit( FFinished );
end;

function TDirectionQueryLayer.IsModal : Boolean;
begin
  Exit( True );
end;

function TDirectionQueryLayer.HandleInput( aInput : TInputKey ) : Boolean;
begin
  if aInput in [ INPUT_ESCAPE, INPUT_MRIGHT, INPUT_QUIT, INPUT_HARDQUIT ] then
  begin
    FFinished := True;
    Exit( True );
  end;
  if aInput in INPUT_MOVE+[INPUT_WAIT] then
  begin
    FFinished := True;
    Finalize( InputDirection( aInput ) );
    Exit( True );
  end;
  Exit( True );
end;

constructor TRunModeView.Create;
begin
  inherited Create;
  FPrompt := 'Run mode';
end;

procedure TRunModeView.Finalize( aDir : TDirection );
begin
  Player.FRun.Start( aDir );
end;

constructor TMeleeDirView.Create;
begin
  inherited Create;
  FPrompt := 'Melee attack';
end;

procedure TMeleeDirView.Finalize( aDir : TDirection );
begin
  if aDir.code <> DIR_CENTER then
    Doom.HandleCommand( TCommand.Create( COMMAND_MELEE, Player.Position + aDir ) );
end;

constructor TActionDirView.Create( aAction : Ansistring; aFlag : Byte );
begin
  inherited Create;
  FPrompt := aAction;
  FFlag   := aFlag;
end;

procedure TActionDirView.Finalize( aDir : TDirection );
begin
  if aDir.code = DIR_CENTER then Exit;
  Doom.HandleActionCommand( Player.Position + aDir, FFlag );
end;

constructor TTargetModeView.Create( aItem : TItem; aCommand : Byte; aActionName : AnsiString;
  aRange: byte; aLimitRange : Boolean; aTargets: TAutoTarget; aChainFire : Byte );
begin
  FFirst        := True;
  FTargets      := aTargets;
  FTarget       := aTargets.Current;
  FActionName   := aActionName;
  FNameLen      := VTIG_Length( aActionName );
  FLimitRange   := aLimitRange;
  FRange        := aRange;
  FPosition     := Player.Position;
  FColor        := Green;
  FItem         := aItem;
  FCommand      := aCommand;
  FChainFire    := aChainFire;
  IO.TargetLast := FChainFire > 0;
  IO.Targeting  := True;
end;

procedure TTargetModeView.Update( aDTime : Integer );
begin
  if FFirst then UpdateTarget;
  VTIG_FreeLabel( FActionName, Point( 0, 2 ), Yellow )
end;

function TTargetModeView.IsFinished : Boolean;
begin
  Exit( FFinished );
end;

function TTargetModeView.IsModal : Boolean;
begin
  Exit( True );
end;

function TTargetModeView.HandleInput( aInput : TInputKey ) : Boolean;
var iDir        : TDirection;
    iDist       : Byte;
    iTargetLine : TVisionRay;
begin
  if aInput in [ INPUT_ESCAPE, INPUT_MRIGHT, INPUT_QUIT, INPUT_HARDQUIT ] then
  begin
    Finalize;
    Exit( True );
  end;

  if (aInput = INPUT_TOGGLEGRID) and GraphicsVersion then SpriteMap.ToggleGrid;
  if aInput = INPUT_TACTIC then
  begin
    FTarget := FTargets.Next;
    UpdateTarget;
  end;

  if aInput in [ INPUT_MMOVE, INPUT_MRIGHT, INPUT_MLEFT ] then
  begin
    FTarget := IO.MTarget;
    iDist   := Distance( FTarget, FPosition );
    if FLimitRange and ( iDist > FRange - 1 ) then
    begin
      iDist := 0;
      iTargetLine.Init( Doom.Level, FPosition, FTarget);
      while iDist < (FRange - 1) do
      begin
        iTargetLine.Next;
        iDist := Distance( iTargetLine.GetSource, iTargetLine.GetC );
      end;
      if Distance(iTargetLine.GetSource, iTargetLine.GetC ) > FRange-1
        then FTarget := iTargetLine.prev
        else FTarget := iTargetLine.GetC;
    end;
    UpdateTarget;
  end;
  if aInput in INPUT_MOVE then
  begin
    iDir := InputDirection( aInput );
    if Doom.Level.isProperCoord( FTarget + iDir )
      and ((not FLimitRange) or (Distance((FTarget + iDir), FPosition) <= FRange-1)) then
    begin
      FTarget += iDir;
      UpdateTarget;
    end;
  end;

  if aInput = INPUT_MORE then
  begin
    with Doom.Level do
     if Being[FTarget] <> nil then
       IO.FullLook( Being[FTarget].ID );
    UpdateTarget;
  end;

  if aInput in [ INPUT_FIRE, INPUT_ALTFIRE, INPUT_MLEFT ] then
  begin
    Finalize;
    if FTarget = FPosition then
      IO.Msg( 'Find a more constructive way to commit suicide.' )
    else
    begin
      Player.UpdateTargeting( FTarget );
      Player.ChainFire := FChainFire;
      Doom.HandleCommand( TCommand.Create( FCommand, FTarget, FItem ) );
    end;
    Exit( True );
  end;

  Exit( True );
end;

procedure TTargetModeView.Finalize;
begin
  FreeAndNil( FTargets );
  IO.MsgUpDate;
  IO.Console.HideCursor;
  IO.Targeting := False;
  if SpriteMap <> nil then SpriteMap.ClearTarget;
  IO.TargetEnabled := False;
  FFinished := true;
end;


procedure TTargetModeView.UpdateTarget;
var iBlock      : Boolean;
    iTargetLine : TVisionRay;
    iLevel      : TLevel;
begin
  iLevel := Doom.Level;
  if FTarget <> FPosition then
  begin
    iTargetLine.Init(iLevel, FPosition, FTarget);
    iBlock := false;
    repeat
      iTargetLine.Next;
      if iLevel.cellFlagSet( iTargetLine.GetC, CF_BLOCKMOVE ) then iBlock := true;
    until iTargetLine.Done;
  end
  else iBlock := False;
  if iBlock then FColor := Red else FColor := Green;

  FFirst := False;
  IO.Focus( FTarget );
  IO.LookDescription( FTarget );
  IO.SetTarget( FTarget, FColor, FRange );
end;

end.

