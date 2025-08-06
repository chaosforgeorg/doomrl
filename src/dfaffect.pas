{$INCLUDE drl.inc}
{
 ----------------------------------------------------
Copyright (c) 2002-2025 by Kornel Kisielewicz
----------------------------------------------------
}
unit dfaffect;
interface
uses classes, vutil, vnode, dfdata, dfthing;

type TAffects = class( TVObject )
  constructor Create( aOwner : TThing );
  constructor CreateFromStream( aStream : TStream; aOwner : TThing ); reintroduce;
  procedure WriteToStream( aStream : TStream ); override;
  function GetBonus( aHook : Byte; const aParams : array of Const ) : Integer;
  function GetBonusMul( aHook : Byte; const aParams : array of Const ) : Single;
  procedure Add( aAffnum : Byte; aDuration : LongInt );
  function  Remove( aAffnum : Byte; aSilent : Boolean ) : boolean;
  procedure OnUpdate;
  function  IsActive( aAffnum : Byte ) : boolean;
  function  IsExpiring( aAffnum : Byte ) : boolean;
  function  getEffect : TStatusEffect;
  function  getTime( aAffnum : Byte ) : longint;
  destructor Destroy; override;
private
  FOwner : TThing;
  FHooks : TFlags;
  FList  : array[1..MAXAFFECT] of LongInt;
  procedure Run( aAffnum : Byte );
  procedure Expire( aAffnum : Byte; aSilent : Boolean );
  procedure UpdateHooks;
end;

implementation

uses vdebug, vluasystem, vuid, dfbeing, dfplayer, drlio, doomhooks;

constructor TAffects.Create( aOwner : TThing );
var iAff : Word;
begin
  FOwner := aOwner;
  FHooks := [];
  for iAff := 1 to MAXAFFECT do
    FList[iAff] := 0;
end;

constructor TAffects.CreateFromStream( aStream : TStream; aOwner : TThing );
begin
  inherited CreateFromStream( aStream );
  FOwner := aOwner;
  aStream.Read( FList, SizeOf( FList ) );
  UpdateHooks;
end;

procedure TAffects.WriteToStream( aStream : TStream );
begin
  inherited WriteToStream( aStream );
  aStream.Write( FList, SizeOf( FList ) );
end;

function TAffects.GetBonus( aHook : Byte; const aParams : array of Const ) : Integer;
var i : Integer;
begin
  GetBonus := 0;
  if aHook in FHooks then
    for i := 1 to MAXAFFECT do
      if FList[i] <> 0 then
        if aHook in Affects[i].Hooks then
          GetBonus += LuaSystem.ProtectedCall( [ 'affects',i, HookNames[ aHook ] ], ConcatConstArray( [FOwner], aParams ) );
end;

function TAffects.GetBonusMul( aHook : Byte; const aParams : array of Const ) : Single;
var i : Integer;
begin
  GetBonusMul := 1.0;
  if aHook in FHooks then
    for i := 1 to MAXAFFECT do
      if FList[i] <> 0 then
        if aHook in Affects[i].Hooks then
          GetBonusMul *= LuaSystem.ProtectedCall( [ 'affects',i, HookNames[ aHook ] ], ConcatConstArray( [FOwner], aParams ) );
end;

function TAffects.IsActive( aAffnum : Byte ) : boolean;
begin
  Exit( FList[aAffnum] <> 0 );
end;

function TAffects.IsExpiring(aAffnum : Byte): boolean;
begin
  Exit(FList[aAffnum] <= 5);
end;

function TAffects.getEffect : TStatusEffect;
var iCount    : DWord;
    iStrength : DWord;
begin
  getEffect := StatusNormal;
  iStrength := 0;
  for iCount := 1 to MAXAFFECT do
    if FList[iCount] <> 0 then
      if Affects[iCount].StatusStr > iStrength then
      begin
        getEffect := Affects[iCount].StatusEff;
        iStrength := Affects[iCount].StatusStr;
      end;
end;

function TAffects.getTime( aAffnum : Byte ) : longint;
begin
  Exit(FList[aAffnum]);
end;

procedure   TAffects.Add( aAffnum : Byte; aDuration : LongInt );
begin
  if aDuration      = 0  then Exit;
  if FList[aAffnum] = 0  then
  begin
    if FOwner is TPlayer then
      IO.Msg( LuaSystem.Get([ 'affects', aAffnum, 'message_init' ],'') );
    if AffectHookOnAdd in Affects[aAffnum].AffHooks then
      LuaSystem.ProtectedCall( [ 'affects',aAffnum,'OnAdd' ],[ FOwner as TBeing ]);
  end;
  if FList[aAffnum] >= 0
    then FList[aAffnum] += aDuration;
  if aDuration = -1
    then FList[aAffnum] := aDuration;
  UpdateHooks;
end;

function TAffects.Remove( aAffnum: Byte; aSilent: Boolean ): boolean;
begin
  Remove := True;
  if FList[ aAffnum] = 0 then Exit(false);
  Expire( aAffnum, aSilent );
end;

procedure TAffects.Expire( aAffnum : Byte; aSilent : Boolean );
begin
  FList[ aAffnum ] := 0;
  if AffectHookOnRemove in Affects[ aAffnum ].AffHooks then
    LuaSystem.ProtectedCall( [ 'affects',aAffnum,'OnRemove'],[ FOwner as TBeing ]);
  if FOwner is TPlayer and ( not aSilent ) then
    IO.Msg( LuaSystem.Get([ 'affects', aAffnum, 'message_done' ],'') );
  UpdateHooks;
end;

procedure TAffects.UpdateHooks;
var i : Integer;
begin
  FHooks := [];
  for i := 1 to MAXAFFECT do
    if FList[i] <> 0 then
      FHooks += Affects[i].Hooks;
end;

procedure   TAffects.OnUpdate;
var iCount   : DWord;
    iThisUID : DWord;
begin
  iThisUID := FOwner.UID;
  for iCount := 1 to MAXAFFECT do
    if FList[iCount] <> 0 then
      begin
        if FList[iCount] > 0  then Dec( FList[iCount] );
        if FList[iCount] = 5  then if FOwner is TPlayer then IO.Msg( LuaSystem.Get([ 'affects', iCount, 'message_ending' ],'') );
        if FList[iCount] <> 0 then Run( iCount )
                              else Expire( iCount, False );
        if UIDs[ iThisUID ] = nil then Exit;
      end;
end;

procedure   TAffects.Run( aAffnum : Byte);
begin
  if AffectHookOnUpdate in Affects[aAffnum].AffHooks then
    LuaSystem.ProtectedCall( [ 'affects',aAffnum,'OnUpdate' ] ,[ FOwner as TBeing ]);
end;

destructor TAffects.Destroy;
begin
  inherited Destroy;
end;

end.
