{$INCLUDE doomrl.inc}
unit doomhintview;
interface
uses vutil, vcolor, vrltools, dfdata, doomkeybindings;

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

implementation

uses vtig, dfplayer, dflevel, doombase, doomio, doomspritemap;

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

end.

