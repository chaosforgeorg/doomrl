{$include doomrl.inc}
unit doomui; 
interface
uses sysutils, vgltypes, vglimage, vimage, vrltools, vconui, vconuirl, vuielements, vuiconsole, vuielement, vuitypes, vioevent;

type TDoomUIMiniMap = class( TUIElement )
  constructor Create( aParent : TUIElement );
  procedure SetScale( aScale : Byte );
  procedure OnRedraw; override;
  procedure Update;
  procedure Upload;
  destructor Destroy; override;
protected
  FImage    : TImage;
  FTexture  : DWord;
  FScale    : Integer;
  FGLPos    : TGLVec2i;
end;

type TDoomStatusUIElement = class( TUIElement )
  constructor Create( aParent : TUIElement; const aArea : TUIRect );
  procedure OnRedraw; override;
  procedure OnUpdate( aTime : DWord ); override;
end;

type TDoomHintUIElement = class( TUIElement )
  constructor Create( aParent : TUIElement; const aPos : TUIPoint; aLength : Word );
  procedure OnRedraw; override;
  procedure SetText( const aText : TUIString );
  procedure OnUpdate( aTime : DWord ); override;
private
  FHint : TUIString;
end;

type TDoomConTargetLineUIElement = class( TUIElement )
  constructor Create( aParent : TUIElement; aArea : TUIRect );
  procedure OnRedraw; override;
  procedure SetTarget( aTarget : TCoord2D; aTargetColor : TUIColor; aTargetRange : Byte );
  procedure SetLast( aLastTarget : TCoord2D );
  procedure OnUpdate( aTime : DWord ); override;
  procedure Paint( aCoord : TCoord2D; aColor : TUIColor; aChar : Char = ' ');
private
  FShowLast    : Boolean;
  FLastTarget  : TCoord2D;
  FTarget      : TCoord2D;
  FTargetColor : TUIColor;
  FTargetRange : Byte;
end;

type TDoomGameUI = class( TUIElement )
  constructor Create( aParent : TUIElement; const aArea : TUIRect );
  procedure OnRedraw; override;
  procedure OnRender; override;
  procedure OnUpdate( aTime : DWord ); override;
  function OnMouseDown( const event : TIOMouseEvent ) : Boolean; override;
  function OnMouseMove( const event : TIOMouseMoveEvent ) : Boolean; override;
  procedure SetTarget( aTarget : TCoord2D; aTargetColor : TUIColor; aTargetRange : Byte = 100 );
  procedure SetLastTarget( aLastTarget : TCoord2D );
  procedure ResetTarget;
  procedure UpdateMinimap;
  procedure SetMinimapScale( aScale : Byte );
private
  FLastMouse: DWord;
  FTime     : DWord;
  FStatus   : TDoomStatusUIElement;
  FHint     : TDoomHintUIElement;
  FMessages : TUICustomMessages;
  FTarget   : TDoomConTargetLineUIElement;
  FMap      : TConUIMapArea;
  FMouseLock: Boolean;
  FMiniMap  : TDoomUIMiniMap;
public
  property Status   : TDoomStatusUIElement read FStatus;
  property Hint     : TDoomHintUIElement   read FHint;
  property Messages : TUICustomMessages    read FMessages;
  property Map      : TConUIMapArea        read FMap;
end;


implementation

uses math, dfoutput,
     vcolor, vmath, vutil, viotypes,
     dfmap, dfdata, dflevel, dfitem, dfbeing, dfplayer,
     doomio, doomspritemap, doombase, vvision;

{ TDoomUIMiniMap }

constructor TDoomUIMiniMap.Create ( aParent : TUIElement ) ;
begin
  inherited Create( aParent, Rectangle( 0,0, 0, 0 ) );
  FScale    := 0;
  FTexture  := 0;
  FGLPos    := TGLVec2i.Create( 0, 0 );
  FImage    := TImage.Create( 128, 32 );
  FImage.Fill( NewColor( 0,0,0,0 ) );
end;

procedure TDoomUIMiniMap.SetScale ( aScale : Byte ) ;
begin
  FScale := aScale;
  FGLPos.Init( IO.Driver.GetSizeX - FScale*(MAXX+2) - 10, IO.Driver.GetSizeY - FScale*(MAXY+2) - ( 10 + IO.FontMult*20*3 ) );
end;

procedure TDoomUIMiniMap.OnRedraw;
const UnitTex : TGLVec2f = ( Data : ( 1, 1 ) );
      ZeroTex : TGLVec2f = ( Data : ( 0, 0 ) );
begin
  inherited OnRedraw;
  if FScale <> 0 then
    IO.QuadSheet.PostTexturedQuad( FGLPos, FGLPos + TGLVec2i.Create( FScale*128, FScale*32 ), ZeroTex, UnitTex, FTexture );
end;

procedure TDoomUIMiniMap.Update;
var x, y : DWord;
begin
  if Doom.State <> DSPlaying then Exit;
  for x := 0 to MAXX+1 do
    for y := 0 to MAXY+1 do
      FImage.ColorXY[x,y] := Doom.Level.GetMiniMapColor( NewCoord2D( x, y ) );
  if FTexture = 0
    then Upload
    else ReUploadImage( FTexture, FImage, False );
end;

procedure TDoomUIMiniMap.Upload;
begin
  FTexture := UploadImage( FImage, False );
end;

destructor TDoomUIMiniMap.Destroy;
begin
  FreeAndNil( FImage );
  inherited Destroy;
end;

constructor TDoomStatusUIElement.Create ( aParent : TUIElement;
  const aArea : TUIRect ) ;
begin
  inherited Create( aParent, aArea );
end;


procedure TDoomStatusUIElement.OnRedraw;
var iCount  : DWord;
    iCon    : TUIConsole;
    iColor  : TUIColor;
    iHPP    : Integer;

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
  if Player = nil then Exit;
  iCon.Init( TConUIRoot(FRoot).Renderer );
  iCon.ClearRect( FAbsolute, FBackColor );

  iHPP := Round((Player.HP/Player.HPMax)*100);

  iCon.RawPrint( FAbsolute.Pos + Point(28,0),DarkGray, 'Armor :' );
  iCon.RawPrint( FAbsolute.Pos + Point(1,0), NameColor(iHPP), Player.Name );
  iCon.RawPrint( FAbsolute.Pos + Point(1,1), DarkGray, 'Health:      Exp:   /      Weapon:');
  iCon.RawPrint( FAbsolute.Pos + Point(9,1), Red, IntToStr(iHPP)+'%');
  iCon.RawPrint( FAbsolute.Pos + Point(19,1),LightGray, TwoInt(Player.ExpLevel) );
  iCon.RawPrint( FAbsolute.Pos + Point(22,1),LightGray, ExpString);


  if Player.Inv.Slot[efWeapon] = nil
    then iCon.RawPrint( FAbsolute.Pos + Point(36,1), LightGray, 'none')
    else iCon.RawPrint( FAbsolute.Pos + Point(36,1), WeaponColor(Player.Inv.Slot[efWeapon]), Player.Inv.Slot[efWeapon].Description );

  if Player.Inv.Slot[efTorso] = nil
    then iCon.RawPrint( FAbsolute.Pos + Point(36,0), LightGray, 'none')
    else iCon.RawPrint( FAbsolute.Pos + Point(36,0), ArmorColor(Player.Inv.Slot[efTorso].Durability), Player.Inv.Slot[efTorso].Description );

  iColor := Red;
  if Doom.Level.Empty then iColor := Blue;
  iCon.RawPrint( FAbsolute.Pos + Point(61,2), iColor,Doom.Level.Name);
  if Doom.Level.lnum >= 100 then iCon.RawPrint( FAbsolute.Pos + Point(73,2), iColor, 'Lev'+IntToStr(Doom.Level.lnum))
  else if Doom.Level.lnum <> 0 then iCon.RawPrint( FAbsolute.Pos + Point(74,2), iColor,'Lev'+IntToStr(Doom.Level.lnum));

  with Player do
  for iCount := 1 to MAXAFFECT do
    if FAffects.IsActive(iCount) then
    begin
      if FAffects.IsExpiring(iCount)
        then iColor := Affects[iCount].Color_exp
        else iColor := Affects[iCount].Color;
      iCon.RawPrint( Point( FAbsolute.x+((Byte(iCount)-1)*4)+14, FAbsolute.y2 ),iColor,Affects[iCount].name)
    end;

  with Player do
    iCon.RawPrint( Point(FAbsolute.x+1, FAbsolute.y2), TacticColor[FTactic.Current], TacticName[FTactic.Current] );

  inherited OnRedraw;
end;

procedure TDoomStatusUIElement.OnUpdate ( aTime : DWord ) ;
begin
  FDirty := True;
  inherited OnUpdate ( aTime ) ;
end;

{ TDoomHintUIElement }

constructor TDoomHintUIElement.Create ( aParent : TUIElement; const aPos : TUIPoint; aLength : Word ) ;
begin
  inherited Create( aParent, Rectangle( aPos, aLength, 1 ) );
  FHint := '';
end;

procedure TDoomHintUIElement.OnRedraw;
var iCon    : TUIConsole;
begin
  if FHint <> '' then
  begin
    iCon.Init( TConUIRoot(FRoot).Renderer );
    iCon.RawPrint( Point( FAbsolute.x2 - Length(FHint) - 1,FAbsolute.y), Yellow, ' '+FHint+' ');
  end;
  inherited OnRedraw;
end;

procedure TDoomHintUIElement.SetText ( const aText : TUIString ) ;
begin
  FHint := aText;
end;

procedure TDoomHintUIElement.OnUpdate ( aTime : DWord ) ;
begin
  FDirty := True;
  inherited OnUpdate ( aTime ) ;
end;

{ TDoomConTargetLineUIElement }

constructor TDoomConTargetLineUIElement.Create ( aParent : TUIElement;
  aArea : TUIRect ) ;
begin
  inherited Create( aParent, aArea );
  FShowLast := False;
  FEnabled  := False;
end;

procedure TDoomConTargetLineUIElement.OnRedraw;
var iTargetLine : TVisionRay;
    iCurrent    : TCoord2D;
    iColor      : TUIColor;
    iLevel      : TLevel;
const Good   = Green;
      TooFar = Yellow;
      Bad    = Red;
begin
  if FEnabled then
  begin
    iLevel := Doom.Level;
    if FShowLast then
      Paint( Player.TargetPos, Yellow );
  { if range > PLight.Rad then range := Plight.rad;}
    if GraphicsVersion then Exit;
    if Player.Position = FTarget then Exit;
    iColor := Good;
    iTargetLine.Init( iLevel, Player.Position, FTarget );
    repeat
      iTargetLine.Next;
      iCurrent := iTargetLine.GetC;
      if not iLevel.isProperCoord( iCurrent ) then Break;
      if not iLevel.isVisible( iCurrent ) then iColor := Bad;
      if icolor = good then if iTargetLine.Cnt > FTargetRange then icolor := TooFar;
      if iTargetLine.Done then Paint( iCurrent, iColor, 'X' )
                          else Paint( iCurrent, iColor, '*' );
      if iLevel.cellFlagSet( iCurrent, CF_BLOCKMOVE ) then iColor := Bad;
    until (iTargetLine.Done) or (iTargetLine.cnt > 30);
  end;
  inherited OnRedraw;
end;

procedure TDoomConTargetLineUIElement.SetTarget ( aTarget : TCoord2D; aTargetColor : TUIColor; aTargetRange : Byte ) ;
var iCon        : TUIConsole;
begin
  iCon.Init( TConUIRoot(FRoot).Renderer );
  iCon.Raw.ShowCursor;
  iCon.Raw.MoveCursor( aTarget.x+FAbsolute.x, aTarget.y+FAbsolute.y );
  FShowLast    := False;
  FEnabled     := True;
  FDirty       := True;
  FTarget      := aTarget;
  FTargetColor := aTargetColor;
  FTargetRange := aTargetRange;
end;

procedure TDoomConTargetLineUIElement.SetLast ( aLastTarget : TCoord2D ) ;
begin
  FLastTarget := aLastTarget;
  FShowLast   := True;
end;

procedure TDoomConTargetLineUIElement.OnUpdate ( aTime : DWord ) ;
begin
  FDirty := FEnabled;
  inherited OnUpdate ( aTime ) ;
end;

procedure TDoomConTargetLineUIElement.Paint ( aCoord : TCoord2D; aColor : TUIColor; aChar : Char = ' ') ;
var iCon        : TUIConsole;
    iPos        : TUIPoint;
begin
  iCon.Init( TConUIRoot(FRoot).Renderer );
  iPos := Point( aCoord.x+FAbsolute.x, aCoord.y+FAbsolute.y );
  if aChar = ' ' then aChar := iCon.Raw.GetChar( iPos.X, iPos.Y );
  if StatusEffect = StatusInvert
     then iCon.DrawChar( iPos, Black, LightGray, aChar )
     else iCon.DrawChar( iPos, aColor, aChar );
end;

{ TDoomGameUI }

constructor TDoomGameUI.Create ( aParent : TUIElement; const aArea : TUIRect );
begin
  inherited Create( aParent, aArea );
  if GraphicsVersion then
    FEventFilter := [ VEVENT_MOUSEDOWN, VEVENT_MOUSEMOVE ];
  FFullScreen := True;
  FTarget   := nil;
  FMap      := nil;
  FTime     := 0;
  if not GraphicsVersion then
//    FMap := TDoomConMapUIElement.Create( Self, Rectangle( 0,1,MAXX,MAXY ) );
    FMap := TConUIMapArea.Create( Self, Rectangle( 1,2,MAXX,MAXY ) );

{  if GraphicsVersion then
  begin
    FMessages := TGLUIMessages.Create( Self, IO.TextSheet, IO.FMsgFont, Point(10,10) );
    FMessages.ForeColor := Yellow;
  end
  else  }
  begin
    FMessages := TConUIMessages.Create( Self, Rectangle( 1,0,FAbsolute.w-3,2 ), @IO.EventWaitForMore, Option_MessageBuffer );
    FMessages.ForeColor := DarkGray;
  end;

  FStatus   := TDoomStatusUIElement.Create( Self, Rectangle( 1,22,78,3 ) );
  FHint     := TDoomHintUIElement.Create( Self, Point( 2, 2 ), FAbsolute.w-2 );
  if not GraphicsVersion then
     FTarget := TDoomConTargetLineUIElement.Create( Self, Rectangle( 0,1,MAXX,MAXY ) );
  FEnabled := False;
  FMouseLock := True;
  FMiniMap  := nil;

  if GraphicsVersion then
  begin
    FMiniMap := TDoomUIMiniMap.Create( Self );
    FMiniMap.SetScale( IO.MiniScale );
  end;

end;

procedure TDoomGameUI.OnRedraw;
var iCon    : TUIConsole;
begin
  iCon.Init( TConUIRoot(FRoot).Renderer );
  iCon.ClearRect( FAbsolute, Black );
  inherited OnRedraw;
end;

procedure TDoomGameUI.OnRender;
var iRoot   : TConUIRoot;
    iP1,iP2 : TPoint;
begin
  if GraphicsVersion then
  begin
    iRoot := TConUIRoot(FRoot);
    iP1 := iRoot.ConsoleCoordToDeviceCoord( FAbsolute.Pos );
    iP2 := iRoot.ConsoleCoordToDeviceCoord( Point( FAbsolute.x2+1, FAbsolute.y+2 ) );
    IO.QuadSheet.PostColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.1 ) );

    iP1 := iRoot.ConsoleCoordToDeviceCoord( Point( FAbsolute.x, FAbsolute.y2-2 ) );
    iP2 := iRoot.ConsoleCoordToDeviceCoord( Point( FAbsolute.x2+1, FAbsolute.y2+2 ) );
    IO.QuadSheet.PostColoredQuad( TGLVec2i.Create( iP1.x, iP1.y ), TGLVec2i.Create( iP2.x, iP2.y ), TGLVec4f.Create( 0,0,0,0.1 ) );
  end;

  inherited OnRender;
end;

procedure TDoomGameUI.OnUpdate ( aTime : DWord ) ;
var iPoint   : TUIPoint;
    iValueX  : Single;
    iValueY  : Single;
    iActiveX : Integer;
    iActiveY : Integer;
    iMaxX    : Integer;
    iMaxY    : Integer;
    iShift   : TCoord2D;
begin
  FDirty := True;
  if GraphicsVersion then
  begin
    FTime += aTime;
    if FTime - FLastMouse > 3000 then
    begin
      IO.MCursor.Active := False;
      UI.SetTempHint('');
    end;

    if (IO.MCursor.Active) and IO.Driver.GetMousePos( iPoint ) and (not FMouseLock) then
    begin
      iMaxX   := IO.Driver.GetSizeX;
      iMaxY   := IO.Driver.GetSizeY;
      iValueX := 0;
      iValueY := 0;
      iActiveX := iMaxX div 8;
      iActiveY := iMaxY div 8;
      if iPoint.X < iActiveX      then iValueX := ((iActiveX -        iPoint.X) / iActiveX);
      if iPoint.X > iMaxX-iActiveX then iValueX := ((iActiveX -(iMaxX-iPoint.X)) /iActiveX);
      if iPoint.X < iActiveX then iValueX := -iValueX;
      if iMaxY < MAXY*IO.TileMult*32 then
      begin
        if iPoint.Y < iActiveY       then iValueY := ((iActiveY -        iPoint.Y) / iActiveY) / 2;
        if iPoint.Y > iMaxY-iActiveY then iValueY := ((iActiveY -(iMaxY-iPoint.Y)) /iActiveY) / 2;
        if iPoint.Y < iActiveY then iValueY := -iValueY;
      end;

      iShift := SpriteMap.Shift;
      if (iValueX <> 0) or (iValueY <> 0) then
      begin
        iShift := NewCoord2D(
          Clamp( SpriteMap.Shift.X + Ceil( iValueX * aTime ), SpriteMap.MinShift.X, SpriteMap.MaxShift.X ),
          Clamp( SpriteMap.Shift.Y + Ceil( iValueY * aTime ), SpriteMap.MinShift.Y, SpriteMap.MaxShift.Y )
        );
        SpriteMap.NewShift := iShift;
        FMouseLock :=
          ((iShift.X = SpriteMap.MinShift.X) or (iShift.X = SpriteMap.MaxShift.X))
       and ((iShift.Y = SpriteMap.MinShift.Y) or (iShift.Y = SpriteMap.MaxShift.Y));
      end;
    end;
  end;

  inherited OnUpdate ( aTime ) ;
end;

function TDoomGameUI.OnMouseDown ( const event : TIOMouseEvent ) : Boolean;
begin
  if IO.MCursor <> nil then IO.MCursor.Active := True;
  FLastMouse := FTime;
  Exit( False );
end;

function TDoomGameUI.OnMouseMove ( const event : TIOMouseMoveEvent ) : Boolean;
begin
  if IO.MCursor <> nil then IO.MCursor.Active := True;
  FLastMouse := FTime;
  FMouseLock := False;
  Exit( False );
end;

procedure TDoomGameUI.SetTarget ( aTarget : TCoord2D; aTargetColor : TUIColor;
  aTargetRange : Byte ) ;
begin
  if GraphicsVersion and (SpriteMap <> nil) then
  begin
    SpriteMap.SetTarget( aTarget, NewColor( aTargetColor ), True );
    Exit;
  end;
  FTarget.SetTarget( aTarget, aTargetColor, aTargetRange );
end;

procedure TDoomGameUI.SetLastTarget ( aLastTarget : TCoord2D ) ;
begin
  if not GraphicsVersion then
    FTarget.SetLast( aLastTarget );
end;

procedure TDoomGameUI.ResetTarget;
begin
  if GraphicsVersion and (SpriteMap <> nil) then
  begin
    SpriteMap.ClearTarget;
    Exit;
  end;
  FTarget.Enabled := False;
end;

procedure TDoomGameUI.UpdateMinimap;
begin
  if GraphicsVersion and (FMiniMap <> nil) then
    FMiniMap.Update;
end;

procedure TDoomGameUI.SetMinimapScale ( aScale : Byte ) ;
begin
  if FMiniMap <> nil then
  begin
    FMiniMap.SetScale( aScale );
    FMiniMap.Update;
  end;
end;

end.

