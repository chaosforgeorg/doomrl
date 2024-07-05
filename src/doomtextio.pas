{$INCLUDE doomrl.inc}
unit doomtextio;
interface

uses doomio, vrltools;

type TDoomTextIO = class( TDoomIO )
    constructor Create; reintroduce;
    function ChooseTarget( aActionName : string; aRange: byte; aLimitRange : Boolean; aTargets: TAutoTarget; aShowLast: Boolean): TCoord2D; override;
  protected
    procedure DrawHud; override;
    procedure SetTarget( aTarget : TCoord2D; aColor : Byte; aRange : Byte ); override;
  protected
    FTargetLast     : Boolean;
    FTarget         : TCoord2D;
    FTargetRange    : Byte;
    FTargetEnabled  : Boolean;
  end;

implementation

uses viotypes,
     {$IFDEF WINDOWS}
     vtextio, vtextconsole,
     {$ELSE}
     vcursesio, vcursesconsole,
     {$ENDIF}
     vioconsole, vtig, vvision, vutil,
     doombase,
     dflevel, dfdata, dfplayer;

constructor TDoomTextIO.Create;
begin
  {$IFDEF WINDOWS}
  FIODriver := TTextIODriver.Create( 80, 25 );
  {$ELSE}
  FIODriver := TCursesIODriver.Create( 80, 25 );
  {$ENDIF}
  if (FIODriver.GetSizeX < 80) or (FIODriver.GetSizeY < 25) then
    raise EIOException.Create('Too small console available, resize your console to 80x25!');
  {$IFDEF WINDOWS}
  FConsole  := TTextConsoleRenderer.Create( 80, 25, [VIO_CON_BGCOLOR, VIO_CON_CURSOR] );
  {$ELSE}
  FConsole  := TCursesConsoleRenderer.Create( 80, 25, [VIO_CON_BGCOLOR, VIO_CON_CURSOR] );
  {$ENDIF}

  inherited Create;

  FTargetEnabled := False;
  FTargetLast    := False;
end;

function TDoomTextIO.ChooseTarget( aActionName : string; aRange: byte; aLimitRange : Boolean; aTargets: TAutoTarget; aShowLast: Boolean ): TCoord2D;
begin
  FTargetLast := aShowLast;
  ChooseTarget := inherited ChooseTarget( aActionName, aRange, aLimitRange, aTargets, aShowLast );
  FTargetEnabled := False;
end;

procedure TDoomTextIO.SetTarget( aTarget : TCoord2D; aColor : Byte; aRange : Byte );
begin
  FTargetEnabled := True;
  FTarget        := aTarget;
  FTargetRange   := aRange;
  // TODO: this clashes with TIG
  IO.Console.ShowCursor;
  IO.Console.MoveCursor( aTarget.x+1, aTarget.y+2 );
end;

procedure TDoomTextIO.DrawHud;
var iColor      : TIOColor;
    iCurrent    : TCoord2D;
    iLevel      : TLevel;
    iTargetLine : TVisionRay;

  procedure Paint ( aCoord : TCoord2D; aColor : TIOColor; aChar : Char = ' ') ;
  var iPos        : TIOPoint;
  begin
    iPos := Point( aCoord.x + 1, aCoord.y + 2 );
    if aChar = ' ' then aChar := IO.Console.GetChar( iPos.X, iPos.Y );
    if StatusEffect = StatusInvert
       then VTIG_FreeChar( aChar, iPos, Black, LightGray )
       else VTIG_FreeChar( aChar, iPos, aColor );
  end;
begin
  inherited DrawHud;

  if FTargetEnabled then
  begin
    iLevel := Doom.Level;
    if FTargetLast then
      Paint( Player.TargetPos, Yellow );
    if ( Player.Position <> FTarget ) then
    begin
      iColor := Green;
      iTargetLine.Init( iLevel, Player.Position, FTarget );
      repeat
        iTargetLine.Next;
        iCurrent := iTargetLine.GetC;
        if not iLevel.isProperCoord( iCurrent ) then Break;
        if not iLevel.isVisible( iCurrent ) then iColor := Red;
        if iColor = Green then if iTargetLine.Cnt > FTargetRange then icolor := Yellow;
        if iTargetLine.Done then Paint( iCurrent, iColor, 'X' )
                            else Paint( iCurrent, iColor, '*' );
        if iLevel.cellFlagSet( iCurrent, CF_BLOCKMOVE ) then iColor := Red;
      until (iTargetLine.Done) or (iTargetLine.cnt > 30);
    end;
  end;
end;

end.

