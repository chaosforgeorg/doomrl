{$INCLUDE doomrl.inc}
unit dfaffect;
interface
uses vutil, dfdata;

type

{ TAffects }

TAffects = object
  List : array[1..MAXAFFECT] of LongInt;
  procedure Clear;
  procedure Add( affnum : Byte; duration : LongInt );
  function  Remove( aAffnum : Byte; aSilent : Boolean ) : boolean;
  procedure Tick;
  function  IsActive( affnum : Byte ) : boolean;
  function  IsExpiring( affnum : Byte ) : boolean;
  function  getEffect : TStatusEffect;
  function  getTime( affnum : Byte ) : longint;
private
  procedure Run( affnum : Byte );
  procedure Expire( aAffnum : Byte; aSilent : Boolean );

end;

implementation

uses vdebug, vluasystem, dfplayer, doomio;

procedure TAffects.Clear;
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
  IO.Msg( LuaSystem.Get([ 'affects', affnum, 'message_ending' ],'') );
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

function TAffects.getTime(affnum: Byte): longint;
begin
  Exit(List[affnum]);
end;

procedure   TAffects.Add(affnum : Byte; duration : LongInt);
begin
  if duration     = 0  then Exit;
  if List[affnum] = 0  then
  begin
    IO.Msg( LuaSystem.Get([ 'affects', affnum, 'message_init' ],'') );
    if AffectHookOnAdd in Affects[affnum].Hooks then
      LuaSystem.ProtectedCall( [ 'affects',affnum,'OnAdd' ],[Player]);
  end;
  if List[affnum] >= 0
    then List[affnum] += duration;
  if duration = -1
    then List[affnum] := duration;
end;

function TAffects.Remove( aAffnum: Byte; aSilent: Boolean ): boolean;
begin
  Remove := True;
  if List[ aAffnum] = 0 then Exit(false);
  Expire( aAffnum, aSilent );
end;

procedure    TAffects.Expire( aAffnum : Byte; aSilent : Boolean );
begin
  List[ aAffnum ] := 0;
  if AffectHookOnRemove in Affects[ aAffnum ].Hooks then
    LuaSystem.ProtectedCall( [ 'affects',aAffnum,'OnRemove'],[Player]);
  if not aSilent then
    IO.Msg( LuaSystem.Get([ 'affects', aAffnum, 'message_done' ],'') );
end;

procedure   TAffects.Tick;
var cn : DWord;
begin
  for cn := 1 to MAXAFFECT do
    if List[cn] <> 0 then
      begin
        if List[cn] > 0  then Dec(List[cn]);
        if List[cn] = 5  then IO.Msg( LuaSystem.Get([ 'affects', cn, 'message_ending' ],'') );
        if List[cn] <> 0 then Run(cn)
                         else Expire( cn, False );
      end;
end;

procedure   TAffects.Run(affnum : Byte);
begin
  if AffectHookOnTick in Affects[affnum].Hooks then
    LuaSystem.ProtectedCall( [ 'affects',affnum,'OnTick' ] ,[Player]);
end;

end.
