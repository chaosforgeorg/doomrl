{$INCLUDE doomrl.inc}
unit doomtrait;interface
uses Classes, SysUtils, dfdata;

const   MAXTRAITS  = 50;
        MAXKLASS   = 10;

type

{ TTraits }

TTraits = object
  Values   : array[1..MAXTRAITS]      of Byte;
  Blocked  : array[1..MAXTRAITS]      of Boolean;
  Order    : array[1..MaxPlayerLevel] of Byte;
  Count    : Byte;
  Klass    : Byte;
  Mastered : Boolean;
  procedure Clear;
  function GetHistory : AnsiString;
  procedure Upgrade ( aTrait : Byte ) ;
  function CanPick( aTrait : Byte; aCharLevel : Byte ): Boolean;
  class function CanPickInitially( aTrait : Byte; aKlassID : Byte ) : Boolean;
end;
PTraits = ^TTraits;


implementation

uses vluasystem, vutil, dfplayer;

function TTraits.CanPick( aTrait : Byte; aCharLevel : Byte ): Boolean;
var iOther, iValue : DWord;
    iVariant : Variant;
    iTable   : TLuaTable;
begin
  if Blocked[ aTrait ] then Exit( False );

  with LuaSystem.GetTable(['klasses',Klass,'trait',aTrait]) do
  try
    if (aCharLevel < 12) and (Self.Values[ aTrait ] >= getInteger( 'max', 1 )) then Exit( False );
    if aCharLevel < getInteger( 'reqlevel', 0 ) then Exit( False );
	
    if IsTable('blocks') then
    begin
      with GetTable('blocks') do
      try
        for iVariant in VariantValues do
          if Self.Values[ Word(iVariant) ] >= 1 then Exit( False );
      finally
        Free;
      end;
    end;
	
    if IsTable('requires') then
    for iTable in ITables('requires') do
    begin
      iOther := iTable.GetValue( 1 );
      iValue := iTable.GetValue( 2 );
      if Self.Values[ iOther ] < iValue then Exit( False );
    end;
  finally
    Free;
  end;
  Exit( True );
end;

procedure TTraits.Upgrade ( aTrait : Byte ) ;
var i            : Byte;
    iMax, iMax12 : DWord;
    iMaster      : Boolean;
    iVariant     : Variant;
begin
  Inc( Values[ aTrait ] );
  Inc( Count );

  with LuaSystem.GetTable(['klasses',Klass,'trait',aTrait]) do
  try
    iMax    := getInteger( 'max', 1 );
    iMax12  := getInteger( 'max_12', iMax );
    iMaster := getBoolean( 'master', False );
  finally
    Free;
  end;

  if Values[ aTrait ] >= iMax12 then
    Blocked[ aTrait ] := True;

  if iMaster then
  begin
    Mastered := True;
    for i := 1 to MAXTRAITS do
      if LuaSystem.Get(['klasses',Klass,'trait',i,'master'], False ) then
        Blocked[ i ] := True;
  end;

  LuaSystem.ProtectedCall( [ 'traits',aTrait,'OnPick' ], [ Player, Values[ aTrait ] ] );

  if (Values[ aTrait ] = 1) and LuaSystem.Defined(['klasses',Klass,'trait',aTrait,'blocks']) then
  begin
    with LuaSystem.GetTable(['klasses',Klass,'trait',aTrait,'blocks']) do
    try
      for iVariant in VariantValues do
        Blocked[ Word(iVariant) ] := True;
    finally
      Free;
    end;
  end;

  Order[ Count ] := aTrait;
end;

class function TTraits.CanPickInitially(aTrait: Byte; aKlassID: Byte): Boolean;
begin
  CanPickInitially := True;

  // #5 ReqLevel
  with LuaSystem.GetTable(['klasses',aKlassID,'trait',aTrait]) do
  try
    if IsTable('requires') or (GetInteger('reqlevel',0) > 1) then CanPickInitially := False;
  finally
    Free;
  end;
end;

procedure TTraits.Clear;
var iCount : Byte;
begin
  for iCount := 1 to High(Blocked) do Blocked[iCount] := False;
  for iCount := 1 to High(Values)  do Values[iCount] := 0;
  for iCount := 1 to High(Order)   do Order[iCount] := 0;
  Count := 0;
  Mastered := False;
  Klass := 1;
end;

function TTraits.GetHistory: AnsiString;
var iCount : Byte;
begin
  GetHistory := '';
  for iCount := 1 to High(Order) do
    if (Order[iCount] > 0) and (Order[iCount] <= High(Values)) then
      GetHistory += LuaSystem.Get(['traits',Order[iCount],'abbr'], False )+'->';
end;

end.

