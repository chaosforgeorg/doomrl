program costest;
{$mode objfpc}{$H+}
uses gl, glu, sdl, vsystems, vsdl, voutput, vsdloutput, vinput, vsdlinput;

const Colors : array[0..15] of array[0..2] of Real = (
      ( 0,   0,   0 ),
      ( 0,   0,   0.625 ),
      ( 0,   0.625, 0 ),
      ( 0,   0.625, 0.625 ),
      ( 0.625, 0,   0 ),
      ( 0.625, 0,   0.625 ),
      ( 0.625, 0.625, 0 ),
      ( 0.75, 0.75, 0.75 ),
      ( 0.5, 0.5, 0.5 ),
      ( 0,   0,   1.0 ),
      ( 0,   1.0, 0 ),
      ( 0,   1.0, 1.0 ),
      ( 1.0, 0,   0 ),
      ( 1.0, 0,   1.0 ),
      ( 1.0, 1.0, 0 ),
      ( 1.0, 1.0, 1.0 )
      );
var  Color : Byte = 1;

type

{ TCosOutput }

TCosOutput = class( TSDLOutput )
  constructor Create;
  procedure Update; override;
private
  Sprites    : TSurface;
  SpriteMask : TSurface;
end;

{ TCosOutput }

constructor TCosOutput.Create;
begin
  inherited Create;
  Sprites    := TSurface.Create('graphics/spritesheet_base.png');
  SpriteMask := TSurface.Create('graphics/spritesheet_mask.png');
  Sprites.SetColorKey(255,0,255);
  Sprites.RenderGL();
  SpriteMask.RenderGL();
  SetTitle('DoomRL Cosplay Test','DoomRL Cosplay Test');
end;

procedure TCosOutput.Update;
var Idx : Byte;
begin
  glEnable( GL_TEXTURE_2D );
  //glDisable( GL_DEPTH_TEST );
  glEnable( GL_BLEND );
  glClearColor(0.0,0.0,0.0,1.0);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glMatrixMode( GL_PROJECTION );
  glPushMatrix();
  glLoadIdentity();
  gluOrtho2D(0, ValkyrieSDL.Width-1, ValkyrieSDL.Height-1, 0);

  glMatrixMode( GL_MODELVIEW );
  glPushMatrix();
  glLoadIdentity();

  glDisable( GL_BLEND );

  glBindTexture(GL_TEXTURE_2D, 0);
  glBegin(GL_QUADS);
    Idx := Color;
    glColor4f(Colors[Idx][0],Colors[Idx][1],Colors[Idx][2],1.0);
    glVertex2i(512,10);
    glVertex2i(512,50);
    glVertex2i(790,50);
    glVertex2i(790,10);

    glColor4f(1,1,1,1.0);
    glVertex2i(9+Idx*40, 561);
    glVertex2i(9+Idx*40, 583);
    glVertex2i(31+Idx*40,583);
    glVertex2i(31+Idx*40,561);

    for Idx := 0 to 15 do
    begin
      glColor4f(Colors[Idx][0],Colors[Idx][1],Colors[Idx][2],1.0);
      glVertex2i(10+Idx*40, 562);
      glVertex2i(10+Idx*40, 582);
      glVertex2i(30+Idx*40, 582);
      glVertex2i(30+Idx*40, 562);
    end;

  glEnd();

  glColor4f(1.0,1.0,1.0,1.0);
  glEnable( GL_BLEND );
  glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );

  Sprites.DrawGL;
  Idx := Color;
  glColor4f(Colors[Idx][0],Colors[Idx][1],Colors[Idx][2],1.0);
  glBlendFunc( GL_ONE, GL_ONE );
  SpriteMask.DrawGL;

  SDL_GL_SwapBuffers();
end;

var Key : Byte;
begin
  Systems.Add(Output,TCosOutput.Create);
  Systems.Add(Input,TSDLInput.Create);

  repeat
    Key := Input.GetKey;
    if Key = VKEY_RIGHT then if Color >= 15 then Color := 0 else Inc( Color );
    if Key = VKEY_LEFT  then if Color = 0   then Color := 15 else Dec( Color );
  until Key = VKEY_ESCAPE;

end.

