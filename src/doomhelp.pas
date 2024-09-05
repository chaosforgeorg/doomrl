{$INCLUDE doomrl.inc}
unit doomhelp;
interface
uses classes, vnode, dfdata, vuitypes;

const MaxHelpFiles = 20;
const HLetters     : string[23] = 'abcdefghijklmnopqrstuvw';

type
THelpRecord = record
  Text  : TUIStringArray;
  Desc  : string[60];
end;
PHelpRecord = ^THelpRecord;

type THelp = class(TVObject)
  RegHelps : array[1..MaxHelpFiles] of THelpRecord;
    HNum     : byte;
    constructor Create;
    procedure StreamLoader(Stream : TStream; Name : Ansistring; Size : DWord);
    destructor Destroy; override;
end;

var Help : THelp;


implementation

uses SysUtils, vutil, vtig;

constructor THelp.Create;
var c : byte;
begin
  for c := 1 to MaxHelpFiles do RegHelps[c].Text := nil;
  HNum := 0;
end;

{$HINTS OFF}
procedure THelp.StreamLoader(Stream : TStream; Name : Ansistring; Size : DWord);
var Count      : DWord;
    Amount     : DWord;
begin
  Log('Registering help file '+Name+'...');
  Inc(HNum);
  RegHelps[HNum].text  := TUIStringArray.Create;

  Amount := Stream.ReadDWord;
  for Count := 1 to Amount do
    RegHelps[HNum].Text.Push( Stream.ReadAnsiString );

  RegHelps[HNum].desc  := VTIG_StripTags( RegHelps[HNum].Text[0] );
end;
{$HINTS ON}

destructor THelp.Destroy;
var c : byte;
begin
  for c := 1 to MaxHelpFiles do
    FreeAndNil(RegHelps[c].Text);
end;

end.
