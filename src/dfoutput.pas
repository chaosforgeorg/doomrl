{$INCLUDE doomrl.inc}
unit dfoutput;
interface
uses SysUtils, Classes,
     vluastate, vutil, dfdata, vmath, vrltools, vimage, vgltypes,
     vnode, vcolor, vluaconfig, vgenerics,
     viotypes, vuitypes, vtextmap, vrlmsg,
     doomspritemap, doomanimation, doomio;

type TASCIIImageMap = specialize TGObjectHashMap<TUIStringArray>;


type

{ TDoomUI }

 TDoomUI = class(TVObject)
    // Initialization of all data.
    constructor Create(FullScreen : Boolean = False);
    // Graphical effect of a screen flash, of the given color, and Duration in
    // miliseconds.
    procedure Blink(Color : Byte; Duration : Word = 100; aDelay : DWord = 0);

    // ToDo : this is unused... maybe use it somewhere?
    //procedure ClearKeyBuffer;

    //procedure Save;
    procedure addMoveAnimation( aDuration : DWord; aDelay : DWord; aUID : TUID; aFrom, aTo : TCoord2D; aSprite : TSprite );
    procedure addMissileAnimation( aDuration : DWord; aDelay : DWord; aSource, aTarget : TCoord2D; aColor : Byte; aPic : Char; aDrawDelay : Word; aSprite : TSprite; aRay : Boolean = False );
    procedure addMarkAnimation( aDuration : DWord; aDelay : DWord; aCoord : TCoord2D; aColor : Byte; aPic : Char );
    procedure addSoundAnimation( aDelay : DWord; aPosition : TCoord2D; aSoundID : DWord );
    procedure addScreenMoveAnimation( aDuration : DWord; aDelay : DWord; aTo : TCoord2D );
    procedure addCellAnimation( aDuration : DWord; aDelay : DWord; aCoord : TCoord2D; aSprite : TSprite; aValue : Integer );
    procedure WaitForAnimation;
    function AnimationsRunning : Boolean;
    procedure GFXAnimationDraw;
    procedure GFXAnimationUpdate( aTime : DWord );

    procedure Explosion( aSequence : Integer; aWhere : TCoord2D; aRange, aDelay : Integer; aColor : byte; aExplSound : Word; aFlags : TExplosionFlags = [] );

    procedure Mark( aCoord : TCoord2D; aColor : Byte; aChar : Char; aDuration : DWord; aDelay : DWord = 0);

    destructor Destroy; override;

    procedure OnRedraw;
    procedure OnUpdate( aTime : DWord );
    procedure SetTextMap( aMap : ITextMap );

 public
    FTextMap    : TTextMap;

    // GFX only animations
    FAnimations : TAnimationManager;
    FWaiting    : Boolean;
  end;

var UI : TDoomUI = nil;


implementation

uses math, dateutils,
     vdebug, vsystems, vluasystem, vvision, vconuirl, vuiconsole, vtig, vglimage,
     doombase, doomlua, doomgfxio,
     dfplayer, dflevel, dfmap, dfitem;

{ TDoomUI }

constructor TDoomUI.Create(FullScreen: Boolean);
begin
  inherited Create;
  FWaiting := False;
  FTextMap := nil;
  FAnimations := nil;
  if GraphicsVersion
    then FAnimations := TAnimationManager.Create
    else FTextMap := TTextMap.Create( IO.Console, Rectangle( 2,3,MAXX,MAXY ) );
end;

procedure TDoomUI.Blink(Color : Byte; Duration : Word = 100; aDelay : DWord = 0);
var iChr : Char;
begin
  if GraphicsVersion then
  begin
    FAnimations.AddAnimation(TDoomBlink.Create(Duration,aDelay,Color));
    Exit;
  end;
  if Option_HighASCII then iChr := Chr(219) else iChr := '#';
  FTextMap.AddAnimation( TTextBlinkAnimation.Create(IOGylph( iChr, Color ),Duration,aDelay));
end;

procedure TDoomUI.GFXAnimationUpdate( aTime : DWord );
begin
  if not GraphicsVersion then Exit;
  FAnimations.Update( aTime );
end;

procedure TDoomUI.addMoveAnimation ( aDuration : DWord; aDelay : DWord; aUID : TUID; aFrom, aTo : TCoord2D; aSprite : TSprite );
begin
  if Doom.State <> DSPlaying then Exit;
  if not GraphicsVersion then Exit;
  FAnimations.AddAnimation(TDoomMove.Create(aDuration, aDelay, aUID, aFrom, aTo, aSprite));
end;

procedure TDoomUI.addMissileAnimation(aDuration: DWord; aDelay: DWord; aSource,
  aTarget: TCoord2D; aColor: Byte; aPic: Char; aDrawDelay: Word;
  aSprite: TSprite; aRay: Boolean);
begin
  if Doom.State <> DSPlaying then Exit;
  if GraphicsVersion then
  begin
    FAnimations.addAnimation(
      TDoomMissile.Create( aDuration, aDelay, aSource,
        aTarget, aDrawDelay, aSprite, aRay ) );
    Exit;
  end;
  if aRay
    then FTextMap.AddAnimation( TTextRayAnimation.Create( Doom.Level, aSource, aTarget, IOGylph( aPic, aColor ), aDuration, aDelay, Player.Vision ) )
    else FTextMap.AddAnimation( TTextBulletAnimation.Create( Doom.Level, aSource, aTarget, IOGylph( aPic, aColor ), aDuration, aDelay, Player.Vision ) );
end;

procedure TDoomUI.addMarkAnimation(aDuration: DWord; aDelay: DWord;
  aCoord: TCoord2D; aColor: Byte; aPic: Char);
begin
  if Doom.State <> DSPlaying then Exit;
  if GraphicsVersion
    then FAnimations.addAnimation( TDoomMark.Create(aDuration, aDelay, aCoord ) )
    else FTextMap.AddAnimation( TTextMarkAnimation.Create( aCoord, IOGylph( aPic, aColor ), aDuration, aDelay ) );
end;

procedure TDoomUI.addSoundAnimation(aDelay: DWord; aPosition: TCoord2D;
  aSoundID: DWord);
begin
  if Doom.State <> DSPlaying then Exit;
  if GraphicsVersion
    then FAnimations.addAnimation( TDoomSoundEvent.Create( aDelay, aPosition, aSoundID ) )
    else FTextMap.AddAnimation( TDoomSoundEvent.Create( aDelay, aPosition, aSoundID ) )
end;

procedure TDoomUI.addScreenMoveAnimation(aDuration: DWord; aDelay: DWord; aTo: TCoord2D);
begin
  if Doom.State <> DSPlaying then Exit;
  if not GraphicsVersion then Exit;
  FAnimations.addAnimation( TDoomScreenMove.Create( aDuration, aDelay, aTo ) );
end;

procedure TDoomUI.addCellAnimation( aDuration : DWord; aDelay : DWord; aCoord : TCoord2D; aSprite : TSprite; aValue : Integer );
begin
  if Doom.State <> DSPlaying then Exit;
  if not GraphicsVersion then Exit;
  FAnimations.addAnimation( TDoomAnimateCell.Create( aDuration, aDelay, aCoord, aSprite, aValue ) );
end;

function TDoomUI.AnimationsRunning : Boolean;
begin
  if Doom.State <> DSPlaying then Exit(False);
  if GraphicsVersion
    then Exit( not FAnimations.Finished )
    else Exit( not FTextMap.AnimationsFinished );
end;

procedure TDoomUI.GFXAnimationDraw;
begin
  if not GraphicsVersion then Exit;
  FAnimations.Draw;
end;

procedure TDoomUI.WaitForAnimation;
begin
  if FWaiting then Exit;
  if Doom.State <> DSPlaying then Exit;
  FWaiting := True;
  while AnimationsRunning do
  begin
    IO.Delay(5);
  end;
  FWaiting := False;
  Doom.Level.RevealBeings;
  if GraphicsVersion
    then FAnimations.Clear
    else FTextMap.ClearAnimations;
end;

procedure TDoomUI.Explosion(aSequence : Integer; aWhere: TCoord2D; aRange, aDelay: Integer;
  aColor: byte; aExplSound: Word; aFlags: TExplosionFlags);
var iExpl     : TTextExplosionArray;
    iCoord    : TCoord2D;
    iDistance : Byte;
    iVisible  : boolean;
    iLevel    : TLevel;
begin
  if not GraphicsVersion then
  begin
    FTextMap.FreezeMarks;
    iExpl := nil;
    SetLength( iExpl, 4 );
    iExpl[0].Time := aDelay;
    iExpl[1].Time := aDelay;
    iExpl[2].Time := aDelay;
    iExpl[3].Time := aDelay;
    case aColor of
      Blue    : begin iExpl[3].Color := Blue;    iExpl[0].Color := LightBlue;  iExpl[1].Color := White; end;
      Magenta : begin iExpl[3].Color := Magenta; iExpl[0].Color := Red;        iExpl[1].Color := Blue; end;
      Green   : begin iExpl[3].Color := Green;   iExpl[0].Color := LightGreen; iExpl[1].Color := White; end;
      LightRed: begin iExpl[3].Color := LightRed;iExpl[0].Color := Yellow;     iExpl[1].Color := White; end;
       else     begin iExpl[3].Color := Red;     iExpl[0].Color := LightRed;   iExpl[1].Color := Yellow; end;
    end;
    iExpl[2].Color := iExpl[0].Color;
  end;

  iLevel := Doom.Level;
  if not iLevel.isProperCoord( aWhere ) then Exit;

  if aExplSound <> 0 then
    addSoundAnimation( aSequence, aWhere, aExplSound );

  for iCoord in NewArea( aWhere, aRange ).Clamped( iLevel.Area ) do
    begin
      if aRange < 10 then if iLevel.isVisible(iCoord) then iVisible := True else Continue;
      if aRange < 10 then if not iLevel.isEyeContact( iCoord, aWhere ) then Continue;
      iDistance := Distance(iCoord, aWhere);
      if iDistance > aRange then Continue;
      if GraphicsVersion
        then FAnimations.AddAnimation( TDoomExplodeMark.Create(3*aDelay,aSequence+aDelay*iDistance,iCoord,aColor) )
        else FTextMap.AddAnimation( TTextExplosionAnimation.Create( iCoord, '*', iExpl, iDistance*aDelay+aSequence ) );
    end;
  if aRange >= 10 then iVisible := True;

  if not GraphicsVersion then
     FTextMap.AddAnimation( TTextClearMarkAnimation.Create( aRange*aDelay+aSequence ) );

  // TODO : events
  if efAfterBlink in aFlags then
  begin
    Blink(LightGreen,50,aSequence+aDelay*aRange);
    Blink(White,50,aSequence+aDelay*aRange+60);
  end;

  if not iVisible then if aRange > 3 then
    IO.Msg( 'You hear an explosion!' );
//    Animations.Add(TDoomMessage.Create('You hear an explosion!'),Sequence+EDelay*Range);
end;

procedure TDoomUI.Mark(aCoord: TCoord2D; aColor: Byte; aChar: Char; aDuration: DWord; aDelay: DWord);
begin
  if GraphicsVersion
    then FAnimations.AddAnimation(TDoomMark.Create( aDuration, aDelay, aCoord ) )
    else FTextMap.AddAnimation( TTextMarkAnimation.Create( aCoord, IOGylph( aChar, aColor ), aDuration, aDelay ) );
end;

destructor TDoomUI.Destroy;
begin
  FreeAndNil( FTextMap );
  FreeAndNil( FAnimations );
  inherited Destroy;
end;

procedure TDoomUI.OnRedraw;
begin
  if Assigned( FTextMap ) then
    FTextMap.OnRedraw;
end;

procedure TDoomUI.OnUpdate( aTime : DWord );
begin
  if Assigned( FTextMap ) then
    FTextMap.OnUpdate( aTime );
end;

procedure TDoomUI.SetTextMap( aMap : ITextMap );
begin
  Assert( Assigned( FTextMap ) );
  FTextMap.SetMap( aMap );
end;

initialization

{with VDefaultWindowStyle do
begin
  MainColor     := Red;
  BoldColor     := Yellow;
  InactiveColor := DarkGray;
end;}

end.
