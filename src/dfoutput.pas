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

    procedure BloodSlideDown(DelayTime : word);

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
    procedure ASCIILoader( aStream : TStream; aName : Ansistring; aSize : DWord );

    procedure OnRedraw;
    procedure OnUpdate( aTime : DWord );
    procedure SetTextMap( aMap : ITextMap );

  private
    FTextMap    : TTextMap;

    FASCII      : TASCIIImageMap;

    // GFX only animations
    FAnimations : TAnimationManager;
    FWaiting    : Boolean;

  private
    function Chunkify( const aString : AnsiString; aStart : Integer; aColor : TIOColor ) : TUIChunkBuffer;
//    procedure SlideDown(DelayTime : word; var NewScreen : TGFXScreen);
  public
    property ASCII      : TASCIIImageMap read FASCII;
  end;

var UI : TDoomUI = nil;


implementation

uses math, dateutils,
     vdebug, vsystems, vluasystem, vvision, vconuirl, vuiconsole, vtig, vglimage,
     doombase, doomlua, doomgfxio,
     dfplayer, dflevel, dfmap, dfitem;

{
procedure OutPutRestore;
var vx,vy : byte;
begin
  if GraphicsVersion then Exit;
  for vx := 1 to 80 do for vy := 1 to 25 do VideoBuf^[(vx-1)+(vy-1)*ScreenSizeX] := GFXCapture[vy,vx];
end;
}

//type TGFXScreen = array[1..25,1..80] of Word;
//var  GFXCapture : TGFXScreen;


procedure TDoomUI.BloodSlideDown(DelayTime : word);
{
const BloodPic : TPictureRec = (Picture : ' '; Color : 16*Red);
var Temp  : TGFXScreen;
    Blood : TGFXScreen;
    vx,vy : byte;
}
begin
  if Option_NoBloodSlide or GraphicsVersion then
  begin
    exit;
  end;
{
  for vx := 1 to 80 do for vy := 1 to 25 do Temp [vy,vx] := VideoBuf^[(vx-1)+(vy-1)*ScreenSizeX];
  OutputRestore;
  FillWord(Blood,25*80,Word(BloodPic));
  SlideDown(DelayTime,Blood);
  SlideDown(DelayTime,Temp);
}
end;

{
procedure TDoomUI.SlideDown(DelayTime : word; var NewScreen : TGFXScreen);
var Pos  : array[1..80] of Byte;
    cn,t, vx,vy : byte;
  procedure MoveColumn(x : byte);
  var y : byte;
  begin
    if pos[x]+1 > 25 then Exit;
    for y := 24 downto pos[x]+1 do
      VideoBuf^[(x-1)+y*LongInt(ScreenSizeX)] := VideoBuf^[(x-1)+(y-1)*LongInt(ScreenSizeX)];
    VideoBuf^[(x-1)+pos[x]*LongInt(ScreenSizeX)] := NewScreen[pos[x]+1,x];
    Inc(pos[x]);
  end;

begin
  if GraphicsVersion then Exit;
  for cn := 1 to 80  do Pos[cn] := 0;
  for cn := 1 to 160 do MoveColumn(Random(80)+1);
  t := 1;
  repeat
    Inc(t);
    IO.Delay(DelayTime);
    for cn := 1 to 80 do MoveColumn(cn);
  until t = 25;
  for vx := 1 to 80 do for vy := 1 to 25 do VideoBuf^[(vx-1)+(vy-1)*ScreenSizeX] := NewScreen[vy,vx];

end;
}

{ TDoomUI }

constructor TDoomUI.Create(FullScreen: Boolean);
begin
  inherited Create;
  FWaiting := False;
  FTextMap := nil;
  FAnimations := nil;
  FASCII := TASCIIImageMap.Create( True );
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
  if GraphicsVersion
    then FAnimations.Clear
    else FTextMap.ClearAnimations;
  FWaiting := False;
  Doom.Level.RevealBeings;
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
  FreeAndNil( FASCII );
  inherited Destroy;
end;

procedure TDoomUI.ASCIILoader ( aStream : TStream; aName : Ansistring; aSize : DWord ) ;
var iImage   : TUIStringArray;
    iCounter : DWord;
    iAmount  : DWord;
begin
  Log('Registering ascii file '+aName+'...');
  iAmount := aStream.ReadDWord;
  iImage := TUIStringArray.Create;
  for iCounter := 1 to Min(iAmount,25) do
    iImage.Push( aStream.ReadAnsiString );
  FASCII.Items[LowerCase(LeftStr(aName,Length(aName)-4))] := iImage;
end;

function TDoomUI.Chunkify( const aString : AnsiString; aStart : Integer; aColor : TIOColor ) : TUIChunkBuffer;
var iCon       : TUIConsole;
    iChunkList : TUIChunkList;
    iPosition  : TUIPoint;
    iColor     : TUIColor;
begin
  iCon.Init( IO.Console );
  iPosition  := Point(aStart,0);
  iColor     := aColor;
  iChunkList := nil;
  iCon.ChunkifyEx( iChunkList, iPosition, iColor, aString, iColor, Point(78,2) );
  Exit( iCon.LinifyChunkList( iChunkList ) );
end;

procedure TDoomUI.OnRedraw;
var iCount      : DWord;
    i, iMax     : DWord;
    iCon        : TUIConsole;
    iColor      : TUIColor;
    iHPP        : Integer;
    iPos        : TIOPoint;
    iBottom     : Integer;

  function ArmorColor( aValue : Integer ) : TUIColor;
  begin
    case aValue of
     -100.. 25  : Exit(LightRed);
      26 .. 49  : Exit(Yellow);
      50 ..1000 : Exit(LightGray);
      else Exit(LightGray);
    end;
  end;
  function NameColor( aValue : Integer ) : TUIColor;
  begin
    case aValue of
     -100.. 25  : Exit(LightRed);
      26 .. 49  : Exit(Yellow);
      50 ..1000 : Exit(LightBlue);
      else Exit(LightGray);
    end;
  end;
  function WeaponColor( aWeapon : TItem ) : TUIColor;
  begin
    if aWeapon.IType = ITEMTYPE_MELEE then Exit(lightgray);
    if ( aWeapon.Ammo = 0 ) and not ( aWeapon.Flags[ IF_NOAMMO ] ) then Exit(LightRed);
    Exit(LightGray);
  end;
  function ExpString : AnsiString;
  begin
    if Player.ExpLevel >= MaxPlayerLevel - 1 then Exit('MAX');
    Exit(IntToStr(Clamp(Floor(((Player.Exp-ExpTable[Player.ExpLevel]) / (ExpTable[Player.ExpLevel+1]-ExpTable[Player.ExpLevel]))*100),0,99))+'%');
  end;

begin
  if Assigned( FTextMap ) then
    FTextMap.OnRedraw;

  if Player <> nil then
  begin
    iPos    := Point( 2,23 );
    iBottom := 25;
    iHPP    := Round((Player.HP/Player.HPMax)*100);

    VTIG_FreeLabel( 'Armor :',                            iPos + Point(28,0), DarkGray );
    VTIG_FreeLabel( Player.Name,                          iPos + Point(1,0),  NameColor(iHPP) );
    VTIG_FreeLabel( 'Health:      Exp:   /      Weapon:', iPos + Point(1,1),  DarkGray );
    VTIG_FreeLabel( IntToStr(iHPP)+'%',                   iPos + Point(9,1),  Red );
    VTIG_FreeLabel( TwoInt(Player.ExpLevel),              iPos + Point(19,1), LightGray );
    VTIG_FreeLabel( ExpString,                            iPos + Point(22,1), LightGray );

    if Player.Inv.Slot[efWeapon] = nil
      then VTIG_FreeLabel( 'none',                                iPos + Point(36,1), LightGray )
      else VTIG_FreeLabel( Player.Inv.Slot[efWeapon].Description, iPos + Point(36,1), WeaponColor(Player.Inv.Slot[efWeapon]) );

    if Player.Inv.Slot[efTorso] = nil
      then VTIG_FreeLabel( 'none',                                iPos + Point(36,0), LightGray )
      else VTIG_FreeLabel( Player.Inv.Slot[efTorso].Description,  iPos + Point(36,0), ArmorColor(Player.Inv.Slot[efTorso].Durability) );

    iColor := Red;
    if Doom.Level.Empty then iColor := Blue;
    VTIG_FreeLabel( Doom.Level.Name, iPos + Point(61,2), iColor );
    if Doom.Level.Name_Number >= 100 then VTIG_FreeLabel( 'Lev'+IntToStr(Doom.Level.Name_Number), iPos + Point(73,2), iColor )
    else if Doom.Level.Name_Number <> 0 then VTIG_FreeLabel( 'Lev'+IntToStr(Doom.Level.Name_Number), iPos + Point(74,2), iColor );

    with Player do
    for iCount := 1 to MAXAFFECT do
      if FAffects.IsActive(iCount) then
      begin
        if FAffects.IsExpiring(iCount)
          then iColor := Affects[iCount].Color_exp
          else iColor := Affects[iCount].Color;
        VTIG_FreeLabel( Affects[iCount].name, Point( iPos.X+((Byte(iCount)-1)*4)+14, iBottom ), iColor )
      end;

    with Player do
      if (FTactic.Current = TacticRunning) and (FTactic.Count < 6) then
        VTIG_FreeLabel( TacticName[FTactic.Current], Point(iPos.x+1, iBottom ), Brown )
      else
        VTIG_FreeLabel( TacticName[FTactic.Current], Point(iPos.x+1, iBottom ), TacticColor[FTactic.Current] );
  end;

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
