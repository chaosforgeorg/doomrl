{$INCLUDE doomrl.inc}
unit doomanimation;

interface

uses
  Classes, SysUtils, math,
  vnode, vutil, vcolor, vgenerics, vmath, vrltools, vvision, vgltypes, vanimation,
  dfdata;

type TAnimation        = vanimation.TAnimation;
     TAnimationManager = vanimation.TAnimations;

{ TDoomMissile }

TDoomMissile = class(TAnimation)
  constructor Create( aDuration : DWord; aDelay : DWord; aSource, aTarget : TCoord2D; aDrawDelay : Word; aSprite : TSprite; aRay : Boolean = False );
  procedure OnUpdate( aTime : DWord ); override;
  procedure OnDraw; override;
private
  FSource   : TGLVec2i;
  FTarget   : TGLVec2i;
  FPath     : TVisionRay;
  FHeading  : Float;
  FRay      : Boolean;
  FSprite   : TSprite;
  FStepDelay: DWord;
  FStep     : Word;
end;

{ TDoomMessage }

{TDoomMessage = class(TAnimation)
  constructor Create( aMessage : Ansistring );
  procedure OnDraw; override;
private
  FMessage : AnsiString;
end;}

{ TDoomMark }

TDoomMark = class(TAnimation)
  constructor Create( aDuration : DWord; aDelay : DWord; aCoord : TCoord2D );
  procedure OnDraw; override;
private
  FCoord : TCoord2D;
end;

{ TDoomExplodeMark }

TDoomExplodeMark = class(TAnimation)
  constructor Create( aDuration : DWord; aDelay : DWord; aCoord : TCoord2D; aColor : Byte );
  procedure OnDraw; override;
private
  FCoord    : TCoord2D;
  FGColor1  : TColor;
  FGColor2  : TColor;
  FGColor3  : TColor;
end;

{ TDoomSoundEvent }

TDoomSoundEvent = class(TAnimation)
  constructor Create( aDelay : DWord; aPosition : TCoord2D; aSoundID : DWord );
  procedure OnStart; override;
private
  FPosition : TCoord2D;
  FSoundID  : DWord;
end;

{ TDoomBlink }

TDoomBlink = class(TAnimation)
  constructor Create( aDuration : DWord; aDelay : DWord; aColor : Word );
  procedure OnDraw; override;
private
  FGColor   : TColor;
end;

{ TDoomMove }

TDoomMove = class(TAnimation)
  constructor Create( aDuration : DWord; aDelay : DWord; aUID : TUID; aFrom, aTo : TCoord2D; aSprite : TSprite );
  procedure OnStart; override;
  procedure OnDraw; override;
  destructor Destroy; override;
private
  FLightStart : Byte;
  FLightEnd   : Byte;
  FSprite     : TSprite;
  FSource     : TGLVec2i;
  FTarget     : TGLVec2i;
end;

{ TDoomScreenMove }

TDoomScreenMove = class(TAnimation)
  constructor Create( aDuration : DWord; aDelay : DWord; aTo : TCoord2D );
  procedure OnUpdate( aTime : DWord ); override;
  procedure OnDraw; override;
  destructor Destroy; override;
private
  FSource : TCoord2D;
  FDest   : TCoord2D;
end;


implementation

uses viotypes, vuid,
     dfoutput, dfbeing,
     doombase, doomio, doomspritemap;

{ TDoomMissile }

constructor TDoomMissile.Create(aDuration : DWord; aDelay : DWord; aSource, aTarget: TCoord2D; aDrawDelay: Word; aSprite : TSprite;
  aRay: Boolean);
var iSize : Word;
begin
  inherited Create( aDuration, aDelay, 0 );
  FPath.Init(Doom.Level,aSource,aTarget);
  FSprite := aSprite;
  FStepDelay := Max( FDuration div Max( ( aSource - aTarget ).LargerLength, 1 ), 1 );
  FRay    := aRay;
  FStep   := 0;
  FPath.Next;
  FPath.Prev := aSource;
  iSize := SpriteMap.TileSize;

  FSource.Init( aSource.X*iSize-iSize div 2, aSource.Y*iSize-iSize div 2 );
  FTarget.Init( aTarget.X*iSize-iSize div 2, aTarget.Y*iSize-iSize div 2 );
  FHeading := -arctan2( aTarget.X - aSource.X, aTarget.Y - aSource.Y );
  if FHeading < 0 then FHeading := FHeading + 2*PI;
end;

procedure TDoomMissile.OnUpdate( aTime : DWord );
var iOldStep : Word;
begin
  inherited OnUpdate( aTime );
  iOldStep := FStep;
  if not FRay then
  begin
    FStep    := FTime div FStepDelay;
    if FStep > iOldStep then
    for iOldStep := iOldStep+1 to FStep do
    begin
      FPath.Next;
      if FPath.Done then Break;
    end;
  end;
end;

procedure TDoomMissile.OnDraw;
var v : TGLVec2i;
begin
  if Doom.Level.isProperCoord( FPath.GetC ) and Doom.Level.isVisible( FPath.GetC ) then
  begin
    v := Lerp( FSource, FTarget, Minf(FTime / FDuration, 1.0) );
    SpriteMap.PushSpriteRotated( v.x, v.y, FSprite, FHeading + PI/2)
  end;
end;

{ TDoomMessage }

{constructor TDoomMessage.Create(aMessage: Ansistring);
begin
  inherited Create;
  FMessage := aMessage;
end;

procedure TDoomMessage.Draw;
begin
  if (not FExpired) and (not UI.isMsgWaiting) then ;
  begin
    UI.Msg(FMessage);
    FExpired := True;
  end;
end;}

{ TDoomMark }

constructor TDoomMark.Create( aDuration : DWord; aDelay : DWord; aCoord : TCoord2D );
begin
  inherited Create( aDuration, aDelay, 0 );
  FCoord    := aCoord;
end;

procedure TDoomMark.OnDraw;
var iMarkSprite : TSprite;
begin
  iMarkSprite.Large    := False;
  iMarkSprite.Glow     := False;
  iMarkSprite.CosColor := False;
  iMarkSprite.Overlay  := False;
  iMarkSprite.SpriteID := HARDSPRITE_HIT;
  SpriteMap.PushSprite( FCoord.X, FCoord.Y, iMarkSprite )
end;

{ TDoomExplodeMark }

constructor TDoomExplodeMark.Create( aDuration : DWord; aDelay : DWord; aCoord: TCoord2D; aColor: Byte );
var c1, c2, c3 : Byte;
begin
  inherited Create( Max( aDuration, 1 ), aDelay, 0 );
  case aColor of
    LightBlue: begin C1 := LightBlue;C2 := Cyan;       C3 := White;  end;
    Blue     : begin C1 := Blue;     C2 := LightBlue;  C3 := White;  end;
    Magenta  : begin C1 := Magenta;  C2 := Red;        C3 := Blue;   end;
    Green    : begin C1 := Green;    C2 := LightGreen; C3 := White;  end;
    LightRed : begin C1 := LightRed; C2 := Yellow;     C3 := White;  end;
    Yellow   : begin C1 := Brown;    C2 := Yellow;     C3 := White;  end;
  else         begin C1 := Red;      C2 := LightRed;   C3 := Yellow; end;
  end;
  FGColor1 := vcolor.NewColor(c1);
  FGColor2 := vcolor.NewColor(c2);
  FGColor3 := vcolor.NewColor(c3);
  FCoord    := aCoord;
end;

procedure TDoomExplodeMark.OnDraw;
var iMarkSprite : TSprite;
begin
  iMarkSprite.Large    := False;
  iMarkSprite.Glow     := False;
  iMarkSprite.CosColor := False;
  iMarkSprite.Overlay  := True;
  iMarkSprite.SpriteID := HARDSPRITE_EXPL;

  case (( FTime * 3 ) div FDuration) of
    0 : iMarkSprite.Color    := FGColor1;
    1 : iMarkSprite.Color    := FGColor2;
    2 : iMarkSprite.Color    := FGColor3;
  else iMarkSprite.Color    := FGColor2;
  end;
  SpriteMap.PushSprite( FCoord.X, FCoord.Y, iMarkSprite );
end;

{ TDoomSoundEvent }

constructor TDoomSoundEvent.Create( aDelay : DWord; aPosition : TCoord2D; aSoundID : DWord );
begin
  inherited Create( 1, aDelay, 0 );
  FPosition := aPosition;
  FSoundID  := aSoundID;
end;

procedure TDoomSoundEvent.OnStart;
begin
  IO.PlaySound( FSoundID, FPosition );
end;

{ TDoomBlink }

constructor TDoomBlink.Create( aDuration : DWord; aDelay : DWord; aColor: Word );
begin
  inherited Create( aDuration, aDelay, 0 );
  FGColor   := NewColor( aColor );
end;

procedure TDoomBlink.OnDraw;
begin
  IO.PostSheet.PostColoredQuad( TGLVec2i.Create(0,0), TGLVec2i.Create(IO.Driver.GetSizeX,IO.Driver.GetSizeY), TGLVec4f.Create(FGColor.R,FGColor.G,FGColor.B,0.7) );
end;

{ TDoomMove }

constructor TDoomMove.Create ( aDuration : DWord; aDelay : DWord; aUID : TUID; aFrom, aTo : TCoord2D;
  aSprite : TSprite ) ;
var iSize : Word;
begin
  inherited Create( aDuration, aDelay, 0 );
  FUID        := aUID;
  FSprite     := aSprite;
  FLightStart := Iif( Doom.Level.isVisible(aFrom), 255, 0 );
  FLightEnd   := Iif( Doom.Level.isVisible(aTo),   255, 0 );

  if Doom.Level.Flags[ LF_BEINGSVISIBLE ] then
  begin
    FLightStart := Max( FLightStart, 40 );
    FLightEnd   := Max( FLightEnd, 40 );
  end;

  iSize := SpriteMap.TileSize;
  FSource.Init( (aFrom.X - 1)*iSize,(aFrom.Y - 1)*iSize);
  FTarget.Init( (aTo.X   - 1)*iSize,(aTo.Y   - 1)*iSize);
end;

procedure TDoomMove.OnStart;
var iBeing : TBeing;
begin
  iBeing := UIDs.Get( FUID ) as TBeing;
  if iBeing <> nil then iBeing.AnimCount := iBeing.AnimCount + 1;
end;

procedure TDoomMove.OnDraw;
var iPosition : TGLVec2i;
    iValue    : Single;
    iLight    : Byte;
begin
  iValue    := Clampf( FTime / FDuration, 0, 1 );
  iLight    := Lerp( FLightStart, FLightEnd, iValue );
  iPosition := Lerp( FSource, FTarget, iValue );
  SpriteMap.PushSpriteXY( iPosition.X, iPosition.Y, FSprite, iLight );
end;

destructor TDoomMove.Destroy;
var iBeing : TBeing;
begin
  iBeing := UIDs.Get( FUID ) as TBeing;
  if iBeing <> nil then iBeing.AnimCount := Max( 0, iBeing.AnimCount - 1 );
  inherited Destroy;
end;

{ TDoomScreenMove }

constructor TDoomScreenMove.Create( aDuration : DWord; aDelay : DWord; aTo: TCoord2D );
begin
  inherited Create( aDuration, aDelay, 0 );
  FSource   := SpriteMap.Shift;
  FDest     := SpriteMap.ShiftValue(aTo);
  FDuration := Max( FDuration, Round( Sqrt( Distance( FSource, FDest ) ) ) );
end;

procedure TDoomScreenMove.OnUpdate( aTime : DWord );
begin
  inherited OnUpdate( aTime );
  SpriteMap.NewShift := NewCoord2D(
    Lerp( FSource.X, FDest.X, Minf(FTime/FDuration,1.0) ),
    Lerp( FSource.Y, FDest.Y, Minf(FTime/FDuration,1.0) )
  );
end;

procedure TDoomScreenMove.OnDraw;
begin
end;

destructor TDoomScreenMove.Destroy;
begin
  SpriteMap.NewShift := FDest;
  inherited Destroy;
end;

end.

