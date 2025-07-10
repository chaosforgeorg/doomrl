{$INCLUDE doomrl.inc}
unit doomhudviews;
interface
uses vutil, vgenerics, vcolor, vioevent, vrltools, dfdata, dfitem, doomkeybindings;

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

type TMoreLayer = class( TInterfaceLayer )
  constructor Create( aMore : Boolean = True );
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
  function HandleInput( aInput : TInputKey ) : Boolean; override;
protected
  FPrompt   : AnsiString;
  FLength   : Byte;
  FFinished : Boolean;
end;

type TTargetModeView = class( TInterfaceLayer )
  constructor Create( aItem : TItem; aCommand : Byte; aActionName : AnsiString; aRange: byte; aLimitRange : Boolean; aTargets: TAutoTarget; aChainFire : Byte; aPadMode : Boolean );
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
  function HandleInput( aInput : TInputKey ) : Boolean; override;
  function HandleEvent( const aEvent : TIOEvent ) : Boolean; override;
protected
  procedure HandleFire;
  function MoveTarget( aNew : TCoord2D ) : Boolean;
  procedure Finalize;
  procedure UpdateTarget;
protected
  FFirst      : Boolean;
  FFinished   : Boolean;
  FLimitRange : Boolean;
  FPadMode    : Boolean;
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

type TScrollItemArray = specialize TGArray< TItem >;

type TScrollSwapLayer = class( TInterfaceLayer )
  constructor Create;
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
  function HandleInput( aInput : TInputKey ) : Boolean; override;
  destructor Destroy; override;
protected
  FFinished : Boolean;
  FIndex    : Integer;
  FArray    : TScrollItemArray;
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
    IO.FinishTargeting;
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
  Player.MultiMove.Start( aDir );
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

constructor TMoreLayer.Create( aMore : Boolean = True );
begin
  if aMore
    then FPrompt := '[more] press <{LEnter}>...'
    else FPrompt := 'Press <{LEnter}>...';
  FLength := VTIG_Length( FPrompt );
end;

procedure TMoreLayer.Update( aDTime : Integer );
begin
  VTIG_FreeLabel( FPrompt, Point( 3, 2 ), Yellow )
end;

function TMoreLayer.IsFinished : Boolean;
begin
  Exit( FFinished );
end;

function TMoreLayer.IsModal : Boolean;
begin
  Exit( True );
end;

function TMoreLayer.HandleInput( aInput : TInputKey ) : Boolean;
begin
  if aInput in [ INPUT_OK, INPUT_MLEFT, INPUT_QUIT, INPUT_HARDQUIT ] then
    FFinished := True;
  Exit( True );
end;


constructor TTargetModeView.Create( aItem : TItem; aCommand : Byte; aActionName : AnsiString;
  aRange: byte; aLimitRange : Boolean; aTargets: TAutoTarget; aChainFire : Byte; aPadMode : Boolean );
begin
  FFirst        := True;
  FFinished     := False;
  FPadMode      := aPadMode;
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
  if aInput = INPUT_TARGETNEXT then
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
    MoveTarget( FTarget + iDir );
  end;

  if aInput = INPUT_MORE then
  begin
    with Doom.Level do
     if Being[FTarget] <> nil then
       IO.FullLook( Being[FTarget].ID );
    UpdateTarget;
  end;

  if aInput in [ INPUT_FIRE, INPUT_ALTFIRE, INPUT_TARGET, INPUT_ALTTARGET, INPUT_MLEFT ] then
    HandleFire;

  Exit( True );
end;

function TTargetModeView.HandleEvent( const aEvent : TIOEvent ) : Boolean;
begin
  if aEvent.EType <> VEVENT_PADDOWN then Exit( True );
  case aEvent.Pad.Button of
    VPAD_BUTTON_X : HandleFire;
    VPAD_BUTTON_Y : begin
      with Doom.Level do
         if Being[FTarget] <> nil then
           IO.FullLook( Being[FTarget].ID );
      UpdateTarget;
      Exit( True );
    end;
    VPAD_BUTTON_RIGHTSHOULDER : begin
      FTarget := FTargets.Next;
      UpdateTarget;
    end;
    VPAD_BUTTON_LEFTSHOULDER : begin
      FTarget := FTargets.Prev;
      UpdateTarget;
    end;
    VPAD_BUTTON_BACK,
    VPAD_BUTTON_GUIDE,
    VPAD_BUTTON_START,
    VPAD_BUTTON_B : begin
      Finalize;
      Exit( True );
    end;
    VPAD_BUTTON_DPAD_UP    : MoveTarget( FTarget + NewCoord2D(0,-1) );
    VPAD_BUTTON_DPAD_DOWN  : MoveTarget( FTarget + NewCoord2D(0,1) );
    VPAD_BUTTON_DPAD_LEFT  : MoveTarget( FTarget + NewCoord2D(-1,0) );
    VPAD_BUTTON_DPAD_RIGHT : MoveTarget( FTarget + NewCoord2D(1,0) );
  end;
  Exit( True );
end;

procedure TTargetModeView.HandleFire;
begin
  Finalize;
  if FTarget = FPosition then
    IO.Msg( 'Find a more constructive way to commit suicide.' )
  else
  begin
    Doom.Targeting.OnTarget( FTarget );
    Player.TargetPos := FTarget;
    Player.ChainFire := FChainFire;
    Doom.HandleCommand( TCommand.Create( FCommand, FTarget, FItem ) );
  end;
end;

function TTargetModeView.MoveTarget( aNew : TCoord2D ) : Boolean;
begin
  if Doom.Level.isProperCoord( aNew )
    and ((not FLimitRange) or (Distance((aNew), FPosition) <= FRange-1)) then
  begin
    FTarget := aNew;
    UpdateTarget;
    Exit( True );
  end;
  Exit( False );
end;

procedure TTargetModeView.Finalize;
begin
  FTargets := nil;
  IO.FinishTargeting;
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
      if (not iLevel.isProperCoord( iTargetLine.GetC ) ) or (not iLevel.isPassable( iTargetLine.GetC ) ) then
      begin
        iBlock := true;
        Break;
      end;
    until iTargetLine.Done;
  end
  else iBlock := False;
  if iBlock then FColor := Red else FColor := Green;

  FFirst := False;
  IO.Focus( FTarget );
  IO.LookDescription( FTarget );
  IO.SetTarget( FTarget, FColor, FRange );
end;

constructor TScrollSwapLayer.Create;
var iItem : TItem;

begin
  with Player.Inv do
  begin
    FArray := TScrollItemArray.Create;
    if Slot[ efWeapon ]  <> nil then
    begin
      FArray.Push( Slot[ efWeapon ] );
      if Slot[ efWeapon ].Flags[ IF_CURSED ] then
      begin
        IO.Msg('You can''t!');
        FFinished := True;
        Exit;
      end;
    end;
    if (Slot[ efWeapon2 ] <> nil) and Slot[ efWeapon2 ].isWeapon then FArray.Push( Slot[ efWeapon2 ] );
    for iItem in Player.Inv do
      if not Equipped( iItem ) then
        if iItem.isWeapon then
          FArray.Push( iItem );

    if FArray.Size <= 1 then
    begin
      IO.MsgUpDate;
      if FArray.Size = 0
        then IO.Msg('You have no weapons!')
        else IO.Msg('You have no other weapons!');
      FFinished := True;
      Exit;
    end;
  end;
  FIndex := 1;
  if Player.Inv.Slot[ efWeapon ] = nil then FIndex := 0;
end;

procedure TScrollSwapLayer.Update( aDTime : Integer );
begin
  VTIG_FreeLabel( 'Scroll, <{!LMB}> wield, <{!RMB}> cancel:', Point( 0, 2 ), Yellow );
  IO.HintOverlay := FArray[ FIndex ].Description;
end;

function TScrollSwapLayer.IsFinished : Boolean;
begin
  Exit( FFinished );
end;

function TScrollSwapLayer.IsModal : Boolean;
begin
  Exit( True );
end;

function TScrollSwapLayer.HandleInput( aInput : TInputKey ) : Boolean;
begin
  if aInput in [ INPUT_MRIGHT, INPUT_ESCAPE, INPUT_QUIT, INPUT_HARDQUIT ] then
  begin
    IO.HintOverlay := '';
    FFinished := True;
    Exit( True );
  end;

  if aInput = INPUT_MSCRUP   then if FIndex = 0 then FIndex := FArray.Size-1 else FIndex -= 1;
  if aInput = INPUT_MSCRDOWN then FIndex := (FIndex + 1) mod FArray.Size;

  if aInput in [INPUT_MLEFT, INPUT_OK ] then
  begin
    IO.HintOverlay := '';
    FFinished      := True;
    if FArray[ FIndex ] = Player.Inv.Slot[ efWeapon2 ] then
      Doom.HandleCommand( TCommand.Create( COMMAND_SWAPWEAPON ) )
    else
      if FArray[ FIndex ] <> Player.Inv.Slot[ efWeapon ] then
        Doom.HandleCommand( TCommand.Create( COMMAND_WEAR, FArray[FIndex] ) );
    Exit( True );
  end;

  Exit( True );
end;

destructor TScrollSwapLayer.Destroy;
begin
  FreeAndNil( FArray );
  inherited Destroy;
end;

end.

