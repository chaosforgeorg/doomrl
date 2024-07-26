{$INCLUDE doomrl.inc}
unit doomtextio;
interface

uses doomio, vrltools, vtextmap, dfdata;

type TDoomTextIO = class( TDoomIO )
    constructor Create; reintroduce;
    function ChooseTarget( aActionName : string; aRange: byte; aLimitRange : Boolean; aTargets: TAutoTarget; aShowLast: Boolean): TCoord2D; override;
    destructor Destroy; override;
    procedure Update( aMSec : DWord ); override;

    procedure WaitForAnimation; override;
    function AnimationsRunning : Boolean; override;
    procedure Mark( aCoord : TCoord2D; aColor : Byte; aChar : Char; aDuration : DWord; aDelay : DWord = 0 ); override;
    procedure Blink( aColor : Byte; aDuration : Word = 100; aDelay : DWord = 0); override;
    procedure addMissileAnimation( aDuration : DWord; aDelay : DWord; aSource, aTarget : TCoord2D; aColor : Byte; aPic : Char; aDrawDelay : Word; aSprite : TSprite; aRay : Boolean = False ); override;
    procedure addMarkAnimation( aDuration : DWord; aDelay : DWord; aCoord : TCoord2D; aColor : Byte; aPic : Char ); override;
    procedure addSoundAnimation( aDelay : DWord; aPosition : TCoord2D; aSoundID : DWord ); override;
    procedure Explosion( aSequence : Integer; aWhere : TCoord2D; aRange, aDelay : Integer; aColor : byte; aExplSound : Word; aFlags : TExplosionFlags = [] ); override;

    procedure SetTextMap( aMap : ITextMap );
  protected
    procedure ExplosionMark( aCoord : TCoord2D; aColor : Byte; aDuration : DWord; aDelay : DWord ); override;
    procedure DrawHud; override;
    procedure SetTarget( aTarget : TCoord2D; aColor : Byte; aRange : Byte ); override;
  protected
    FTextMap        : TTextMap;
    FExpl           : TTextExplosionArray;

    FTargetLast     : Boolean;
    FTarget         : TCoord2D;
    FTargetRange    : Byte;
    FTargetEnabled  : Boolean;
  end;

implementation

uses sysutils,
     viotypes,
     {$IFDEF WINDOWS}
     vtextio, vtextconsole,
     {$ELSE}
     vcursesio, vcursesconsole,
     {$ENDIF}
     vioconsole, vtig, vtigstyle, vvision, vutil,
     doombase, doomanimation,
     dflevel, dfplayer;

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
  FTextMap       := TTextMap.Create( FConsole, Rectangle( 2,3,MAXX,MAXY ) );
  VTIGDefaultStyle.Color[ VTIG_SELECTED_BACKGROUND_COLOR ] := DarkGray;
  VTIGDefaultStyle.Color[ VTIG_SELECTED_DISABLED_COLOR ]   := Black;

  inherited Create;
  FTargetEnabled := False;
  FTargetLast    := False;
end;

destructor TDoomTextIO.Destroy;
begin
  FreeAndNil( FTextMap );
  inherited Destroy;
end;

procedure TDoomTextIO.Update( aMSec : DWord );
begin
  FTextMap.Update( aMSec );
  inherited Update( aMSec );
end;

function TDoomTextIO.ChooseTarget( aActionName : string; aRange: byte; aLimitRange : Boolean; aTargets: TAutoTarget; aShowLast: Boolean ): TCoord2D;
begin
  FTargetLast := aShowLast;
  ChooseTarget := inherited ChooseTarget( aActionName, aRange, aLimitRange, aTargets, aShowLast );
  FTargetEnabled := False;
end;

procedure TDoomTextIO.WaitForAnimation;
begin
  inherited WaitForAnimation;
  FTextMap.ClearAnimations;
end;

function TDoomTextIO.AnimationsRunning : Boolean;
begin
  if Doom.State <> DSPlaying then Exit(False);
  Exit( not FTextMap.AnimationsFinished );
end;

procedure TDoomTextIO.Mark(aCoord: TCoord2D; aColor: Byte; aChar: Char; aDuration: DWord; aDelay: DWord);
begin
  FTextMap.AddAnimation( TTextMarkAnimation.Create( aCoord, IOGylph( aChar, aColor ), aDuration, aDelay ) );
end;

procedure TDoomTextIO.Blink( aColor : Byte; aDuration : Word = 100; aDelay : DWord = 0 );
var iChr : Char;
begin
  if Option_HighASCII then iChr := Chr(219) else iChr := '#';
  FTextMap.AddAnimation( TTextBlinkAnimation.Create( IOGylph( iChr, aColor ), aDuration, aDelay ) );
end;

procedure TDoomTextIO.addMissileAnimation(aDuration: DWord; aDelay: DWord; aSource,
  aTarget: TCoord2D; aColor: Byte; aPic: Char; aDrawDelay: Word;
  aSprite: TSprite; aRay: Boolean);
begin
  if Doom.State <> DSPlaying then Exit;
  if aRay
    then FTextMap.AddAnimation( TTextRayAnimation.Create( Doom.Level, aSource, aTarget, IOGylph( aPic, aColor ), aDuration, aDelay, Player.Vision ) )
    else FTextMap.AddAnimation( TTextBulletAnimation.Create( Doom.Level, aSource, aTarget, IOGylph( aPic, aColor ), aDuration, aDelay, Player.Vision ) );
end;

procedure TDoomTextIO.addMarkAnimation(aDuration: DWord; aDelay: DWord;
  aCoord: TCoord2D; aColor: Byte; aPic: Char);
begin
  if Doom.State <> DSPlaying then Exit;
  FTextMap.AddAnimation( TTextMarkAnimation.Create( aCoord, IOGylph( aPic, aColor ), aDuration, aDelay ) );
end;

procedure TDoomTextIO.addSoundAnimation(aDelay: DWord; aPosition: TCoord2D; aSoundID: DWord);
begin
  if Doom.State <> DSPlaying then Exit;
  FTextMap.AddAnimation( TDoomSoundEvent.Create( aDelay, aPosition, aSoundID ) )
end;

procedure TDoomTextIO.ExplosionMark( aCoord : TCoord2D; aColor : Byte; aDuration : DWord; aDelay : DWord );
begin
  FTextMap.AddAnimation( TTextExplosionAnimation.Create( aCoord, '*', FExpl, aDelay ) );
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
  FConsole.Clear;
  FTextMap.OnRedraw;

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

procedure TDoomTextIO.SetTextMap( aMap : ITextMap );
begin
  FTextMap.SetMap( aMap );
end;

procedure TDoomTextIO.Explosion( aSequence : Integer; aWhere: TCoord2D; aRange, aDelay: Integer;
  aColor: byte; aExplSound: Word; aFlags: TExplosionFlags);
begin
  FTextMap.FreezeMarks;
  FExpl := nil;
  SetLength( FExpl, 4 );
  FExpl[0].Time := aDelay;
  FExpl[1].Time := aDelay;
  FExpl[2].Time := aDelay;
  FExpl[3].Time := aDelay;
  case aColor of
    Blue    : begin FExpl[3].Color := Blue;    FExpl[0].Color := LightBlue;  FExpl[1].Color := White; end;
    Magenta : begin FExpl[3].Color := Magenta; FExpl[0].Color := Red;        FExpl[1].Color := Blue; end;
    Green   : begin FExpl[3].Color := Green;   FExpl[0].Color := LightGreen; FExpl[1].Color := White; end;
    LightRed: begin FExpl[3].Color := LightRed;FExpl[0].Color := Yellow;     FExpl[1].Color := White; end;
     else     begin FExpl[3].Color := Red;     FExpl[0].Color := LightRed;   FExpl[1].Color := Yellow; end;
  end;
  FExpl[2].Color := FExpl[0].Color;
  inherited Explosion( aSequence, aWhere, aRange, aDelay, aColor, aExplSound, aFlags );
  FTextMap.AddAnimation( TTextClearMarkAnimation.Create( aRange*aDelay+aSequence ) );
end;

end.

