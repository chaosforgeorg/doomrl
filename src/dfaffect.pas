{$INCLUDE doomrl.inc}
unit dfaffect;
interface
uses vutil, dfoutput, dfdata;

type

{ TAffects }

TAffects = object
  List : array[1..MAXAFFECT] of DWord;
  constructor Clear;
  procedure   Add( affnum : Byte; duration : dword);
  function    Remove( affnum : Byte ) : boolean;
  procedure   Tick;
  function    IsActive( affnum : Byte ) : boolean;
  function    IsExpiring( affnum : Byte ) : boolean;
  function    getEffect : TStatusEffect;
  function    getTime( affnum : Byte ) : longint;
  private
  procedure   Run( affnum : Byte );
  procedure   Expire( affnum : Byte );

end;

implementation

uses vdebug, vluasystem, dfplayer;

constructor TAffects.Clear;
var aff : Word;
begin
  for aff := 1 to MAXAFFECT do
    List[aff] := 0;
end;

function    TAffects.IsActive(affnum : Byte) : boolean;
begin
  Exit(List[affnum] <> 0);
end;

function TAffects.IsExpiring(affnum : Byte): boolean;
begin
  Exit(List[affnum] <= 5);
  UI.Msg( LuaSystem.Get([ 'affects', affnum, 'message_ending' ],'') );
end;

function TAffects.getEffect : TStatusEffect;
var cn : DWord;
    st : DWord;
begin
  getEffect := StatusNormal;
  st := 0;
  for cn := 1 to MAXAFFECT do
    if List[cn] <> 0 then
      if Affects[cn].StatusStr > st then
      begin
        getEffect := Affects[cn].StatusEff;
        st        := Affects[cn].StatusStr;
      end;
end;

function TAffects.getTime(affnum : Byte): LongInt;
begin
  Exit(List[affnum]);
end;

procedure   TAffects.Add(affnum : Byte; duration : dword);
begin
  if duration     = 0  then Exit;
  if List[affnum] = 0  then
  begin
    UI.Msg( LuaSystem.Get([ 'affects', affnum, 'message_init' ],'') );
    if AffectHookOnAdd in Affects[affnum].Hooks then
      LuaSystem.ProtectedCall( [ 'affects',affnum,'OnAdd' ],[Player]);
  end;
  List[affnum] := List[affnum] + duration;
end;

function    TAffects.Remove(affnum : Byte) : boolean;
begin
  Remove := True;
  if List[affnum] = 0 then Exit(false);
  Expire( affnum );
end;

procedure    TAffects.Expire(affnum : Byte);
begin
  List[affnum] := 0;
  if AffectHookOnRemove in Affects[affnum].Hooks then
    LuaSystem.ProtectedCall( [ 'affects',affnum,'OnRemove'],[Player]);
  UI.Msg( LuaSystem.Get([ 'affects', affnum, 'message_done' ],'') );
end;

procedure   TAffects.Tick;
var cn : DWord;
begin
  for cn := 1 to MAXAFFECT do
    if List[cn] <> 0 then
      begin
        Dec(List[cn]);
        if List[cn] <> 0 then Run(cn)
                         else Expire(cn);
      end;
end;

procedure   TAffects.Run(affnum : Byte);
begin
  if AffectHookOnTick in Affects[affnum].Hooks then
    LuaSystem.ProtectedCall( [ 'affects',affnum,'OnTick' ] ,[Player]);
end;

end.
