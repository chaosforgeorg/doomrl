{$INCLUDE drl.inc}
{
 ----------------------------------------------------
Copyright (c) 2002-2025 by Kornel Kisielewicz
----------------------------------------------------
}
unit drlmodulechoiceview;
interface
uses vutil, drlio, dfdata;

type TModuleChoiceView = class( TInterfaceLayer )
  constructor Create;
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
protected
  FFinished : Boolean;
end;

implementation

uses vtig;

constructor TModuleChoiceView.Create;
begin
  FFinished := False;
end;

procedure TModuleChoiceView.Update( aDTime : Integer );
begin
  VTIG_Clear;
  IO.Root.Console.HideCursor;
  VTIG_Begin( 'core_module_choice', Point( 30, 10 ) );
     VTIG_Selectable('drl');
     VTIG_Selectable('jhc');
     if VTIG_Selectable('cancel') then FFinished := True;
  VTIG_End;
end;

function TModuleChoiceView.IsFinished : Boolean;
begin
  Exit( FFinished );
end;

function TModuleChoiceView.IsModal : Boolean;
begin
  Exit( True );
end;

end.

