{$INCLUDE doomrl.inc}
unit doomtextio;
interface

uses doomio;

type TDoomTextIO = class( TDoomIO )
    constructor Create; reintroduce;
  end;

implementation

uses viotypes,
     {$IFDEF WINDOWS}
     vtextio, vtextconsole,
     {$ELSE}
     vcursesio, vcursesconsole,
     {$ENDIF}
     vioconsole;

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
end;

end.

