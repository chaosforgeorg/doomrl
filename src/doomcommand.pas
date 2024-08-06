{$INCLUDE doomrl.inc}
unit doomcommand;
interface
uses vrltools, dfitem, dfdata;

type TCommand = object
  Command : Byte;
  Target  : TCoord2D;
  Item    : TItem;
  Slot    : TEqSlot;
  ID      : AnsiString;

  class function Create( aCommand : Byte ) : TCommand; static;
  class function Create( aCommand : Byte; aTarget : TCoord2D ) : TCommand; static;
  class function Create( aCommand : Byte; aID : AnsiString ) : TCommand; static;
  class function Create( aCommand : Byte; aItem : TItem ) : TCommand; static;
  class function Create( aCommand : Byte; aItem : TItem; aSlot : TEqSlot ) : TCommand; static;
  class function Create( aCommand : Byte; aItem : TItem; aID : AnsiString ) : TCommand; static;
  class function Create( aCommand : Byte; aTarget : TCoord2D; aItem : TItem ) : TCommand; static;
end;

implementation

class function TCommand.Create( aCommand : Byte ) : TCommand;
begin
  Result.Command := aCommand;
  Result.Target  := NewCoord2D(0,0);
end;

class function TCommand.Create( aCommand : Byte; aTarget : TCoord2D ) : TCommand;
begin
  Result.Command := aCommand;
  Result.Target  := aTarget;
end;

class function TCommand.Create( aCommand : Byte; aID : AnsiString ) : TCommand;
begin
  Result.Command := aCommand;
  Result.Item    := nil;
  Result.ID      := aID;
end;

class function TCommand.Create( aCommand : Byte; aItem : TItem ) : TCommand;
begin
  Result.Command := aCommand;
  Result.Item    := aItem;
  Result.ID      := '';
end;

class function TCommand.Create( aCommand : Byte; aItem : TItem; aSlot : TEqSlot ) : TCommand;
begin
  Result.Command := aCommand;
  Result.Item    := aItem;
  Result.Slot    := aSlot;
  Result.ID      := '';
end;

class function TCommand.Create( aCommand : Byte; aItem : TItem; aID : AnsiString ) : TCommand;
begin
  Result.Command := aCommand;
  Result.Item    := aItem;
  Result.Id      := aID;
end;

class function TCommand.Create( aCommand : Byte; aTarget : TCoord2D; aItem : TItem ) : TCommand; static;
begin
  Result.Command := aCommand;
  Result.Target  := aTarget;
  Result.Item    := aItem;
  Result.Id      := '';
end;

end.
