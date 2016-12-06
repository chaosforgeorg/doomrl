program gmfplayer;
uses SysUtils, vsystems, vutil, voutput, vtoutput, vtinput, vinput, keyboard, crt, zstream, vds;
type TPointerArray      = specialize TArray<TScreenDump>;
var GMF    : TGZFileStream;
    Mov    : TPointerArray;
    Frames : DWord;
    Count  : DWord;
    Frame  : TScreenDump;
    Cmd    : Byte;
    Play   : Boolean;
    DelAmo : Word;
    SizeX  : Word;
    SizeY  : Word;


begin
  Writeln;
  Writeln('  gmfplay - GenRogue Movie File player');
  Writeln('  Copyright (c) 2004 by Kornel Kisielewicz' );
  Writeln('  All rights reserved');
  Writeln;
  if ParamCount < 1 then
  begin
    Writeln('  usage : gmfplay [filename]');
    Halt(0);
  end;
  Systems.Add(Output,TTextModeOutput.Create);
  Systems.Add(Input,TTextModeInput.Create);
  Mov := TPointerArray.Create(512);
  GMF := TGZFileStream.Create(ParamStr(1),gzopenread);
  Frames := GMF.ReadDWord;
  SizeX  := GMF.ReadDWord;
  SizeY  := GMF.ReadDWord;
  for Count := 1 to Frames do
  begin
    GetMem(Frame,SizeOf(Word)*SizeX*SizeY);
    if Frame = nil then begin Writeln('Out of memory while trying to load movie.'); Halt(0); end;
    GMF.Read(Frame^,SizeOf(Word)*SizeX*SizeY);
    Mov[Count] := Frame;
  end;
  FreeAndNil( GMF );

  Count := 1;
  DelAmo := 120;
  Play := False;
  repeat
    TTextModeOutput(Output).DrawScreenDump(TScreenDump(Mov[Count]));
    Output.DrawString(1,25,DarkGray,
'@d -- @lGMF Viewer@d -- @lFile:@L '+ParamStr(1)+
'@d -- @l<-,->,Escape,Space @d--'+
' @lFrame: @L'+IntToStr(Count)+'@l/@L'+IntToStr(Frames)+'@d --');
    Output.Update;
    if Play then
    begin
      Delay(DelAmo);
      Inc(Count);
      if Count > Frames then Count := 1;
      if PollKeyEvent = 0 then Continue;
    end;
    cmd := Input.GetKey([VKEY_ESCAPE,Ord(' '),Ord('+'),Ord('-'),VKEY_LEFT,VKEY_RIGHT,VKEY_END,VKEY_HOME]);
    case cmd of
      Ord(' ')    : begin Play := not Play; while PollKeyEvent <> 0 do Input.GetKey; end;
      VKEY_LEFT   : begin Play := False; if Count > 1 then Dec(Count); end;
      VKEY_RIGHT  : begin Play := False; if Count < Frames then Inc(Count);end;
      VKEY_HOME   : begin Play := False; Count := 1; end;
      VKEY_END    : begin Play := False; Count := Frames; end;
      Ord('+')    : if DelAmo < 1000 then Inc(DelAmo,20);
      Ord('-')    : if DelAmo > 21   then Dec(DelAmo,20);
    end;
  until cmd = VKEY_ESCAPE;

  FreeAndNil( Mov );
end.
