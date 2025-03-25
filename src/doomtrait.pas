{$INCLUDE doomrl.inc}
unit doomtrait;
interface
uses classes, sysutils, vutil, vnode, dfdata, doomhooks;

const   MAXTRAITS  = 50;
        MAXKLASS   = 10;

type TTraits = class( TVObject )
  constructor Create;
  constructor CreateFromStream( aStream : TStream ); override;
  procedure WriteToStream( aStream : TStream ); override;
  procedure CallHook( aHook : Byte; const aParams : array of Const );
  function CallHookCheck( aHook : Byte; const aParams : array of Const ) : Boolean;
  function GetHistory : AnsiString;
  procedure Upgrade ( aKlass : Byte; aTrait : Byte ) ;
  function CanPick( aKlass : Byte; aTrait : Byte; aCharLevel : Byte ): Boolean;
  class function CanPickInitially( aTrait : Byte; aKlassID : Byte ) : Boolean; static;
protected
  function Get( aTrait : Byte ) : Byte;
protected
  FBlocked  : array[1..MAXTRAITS]      of Boolean;
  FOrder    : array[1..MaxPlayerLevel] of Byte;
  FValues   : array[1..MAXTRAITS]      of Byte;
  FHooks    : array[1..MAXTRAITS]      of TFlags;
  FHookMask : TFlags;
  FCount    : Byte;
  FMastered : Boolean;
protected
  property Values[ aIndex : Byte ] : Byte read Get; default;
end;

implementation

uses vluasystem, dfplayer;

function TTraits.CanPick( aKlass : Byte; aTrait : Byte; aCharLevel : Byte ): Boolean;
var iOther, iValue : DWord;
    iVariant : Variant;
    iTable   : TLuaTable;
begin
  if FBlocked[ aTrait ] then Exit( False );
  if not LuaSystem.Defined(['traits',aTrait,'OnPick']) then Exit( False );

  with LuaSystem.GetTable(['klasses',aKlass,'trait',aTrait]) do
  try
    if (aCharLevel < 12) and (FValues[ aTrait ] >= getInteger( 'max', 1 )) then Exit( False );
    if aCharLevel < getInteger( 'reqlevel', 0 ) then Exit( False );
	
    if IsTable('blocks') then
    begin
      with GetTable('blocks') do
      try
        for iVariant in VariantValues do
          if FValues[ Word(iVariant) ] >= 1 then Exit( False );
      finally
        Free;
      end;
    end;
	
    if IsTable('requires') then
    for iTable in ITables('requires') do
    begin
      iOther := iTable.GetValue( 1 );
      iValue := iTable.GetValue( 2 );
      if FValues[ iOther ] < iValue then Exit( False );
    end;
  finally
    Free;
  end;
  Exit( True );
end;

procedure TTraits.Upgrade ( aKlass : Byte; aTrait : Byte ) ;
var i            : Byte;
    iMax, iMax12 : DWord;
    iMaster      : Boolean;
    iVariant     : Variant;
    iHooks       : TFlags;
begin
  Inc( FValues[ aTrait ] );
  Inc( FCount );

  with LuaSystem.GetTable(['klasses',aKlass,'trait',aTrait]) do
  try
    iMax    := getInteger( 'max', 1 );
    iMax12  := getInteger( 'max_12', iMax );
    iMaster := getBoolean( 'master', False );
  finally
    Free;
  end;

  FHooks[ aTrait ] := LoadHooks( ['traits',aTrait] );
  FHookMask += FHooks[ aTrait ];

  if FValues[ aTrait ] >= iMax12 then
    FBlocked[ aTrait ] := True;

  if iMaster then
  begin
    FMastered := True;
    for i := 1 to MAXTRAITS do
      if LuaSystem.Get(['klasses',aKlass,'trait',i,'master'], False ) then
        FBlocked[ i ] := True;
  end;

  LuaSystem.ProtectedCall( [ 'traits',aTrait,'OnPick' ], [ Player, FValues[ aTrait ] ] );

  if (FValues[ aTrait ] = 1) and LuaSystem.Defined(['klasses',aKlass,'trait',aTrait,'blocks']) then
  begin
    with LuaSystem.GetTable(['klasses',aKlass,'trait',aTrait,'blocks']) do
    try
      for iVariant in VariantValues do
        FBlocked[ Word(iVariant) ] := True;
    finally
      Free;
    end;
  end;

  FOrder[ FCount ] := aTrait;
end;

class function TTraits.CanPickInitially(aTrait: Byte; aKlassID: Byte): Boolean;
begin
  CanPickInitially := True;
  if not LuaSystem.Defined(['traits',aTrait,'OnPick']) then Exit( False );

  // #5 ReqLevel
  with LuaSystem.GetTable(['klasses',aKlassID,'trait',aTrait]) do
  try
    if IsTable('requires') or (GetInteger('reqlevel',0) > 1) then CanPickInitially := False;
  finally
    Free;
  end;
end;

function TTraits.Get( aTrait : Byte ) : Byte;
begin
  Exit( FValues[ aTrait ] );
end;

constructor TTraits.Create;
var iCount : Byte;
begin
  inherited Create;
  for iCount := 1 to High(FBlocked) do FBlocked[iCount] := False;
  for iCount := 1 to High(FValues)  do FValues[iCount] := 0;
  for iCount := 1 to High(FOrder)   do FOrder[iCount] := 0;
  for iCount := 1 to High(FHooks)   do FHooks[iCount] := [];
  FCount := 0;
  FMastered := False;
  FHookMask := [];
end;

constructor TTraits.CreateFromStream( aStream : TStream );
begin
  inherited CreateFromStream( aStream );
  aStream.Read( FValues,   SizeOf( FValues ) );
  aStream.Read( FBlocked,  SizeOf( FBlocked ) );
  aStream.Read( FOrder,    SizeOf( FOrder ) );
  aStream.Read( FCount,    SizeOf( FCount ) );
  aStream.Read( FMastered, SizeOf( FMastered ) );
  aStream.Read( FHooks,    SizeOf( FHooks ) );
  aStream.Read( FHookMask, SizeOf( FHookMask ) );
end;

procedure TTraits.WriteToStream( aStream : TStream );
begin
  inherited WriteToStream( aStream );
  aStream.Write( FValues,   SizeOf( FValues ) );
  aStream.Write( FBlocked,  SizeOf( FBlocked ) );
  aStream.Write( FOrder,    SizeOf( FOrder ) );
  aStream.Write( FCount,    SizeOf( FCount ) );
  aStream.Write( FMastered, SizeOf( FMastered ) );
  aStream.Write( FHooks,    SizeOf( FHooks ) );
  aStream.Write( FHookMask, SizeOf( FHookMask ) );
end;

procedure TTraits.CallHook( aHook : Byte; const aParams : array of Const );
var i : Integer;
begin
  if not ( aHook in FHookMask ) then Exit;
  for i := 1 to High(FHooks) do
    if aHook in FHooks[i] then
      LuaSystem.ProtectedCall( [ 'traits', i, HookNames[aHook] ], ConcatConstArray( [Player], aParams ) )
end;


function TTraits.CallHookCheck( aHook : Byte; const aParams : array of Const ) : Boolean;
var i : Integer;
begin
  if not ( aHook in FHookMask ) then Exit( True );
  for i := 1 to High(FHooks) do
    if aHook in FHooks[i] then
      if not LuaSystem.ProtectedCall( [ 'traits', i, HookNames[aHook] ], ConcatConstArray( [Player], aParams ) ) then
        Exit( False );
  Exit( True );
end;

function TTraits.GetHistory: AnsiString;
var iCount : Byte;
begin
  GetHistory := '';
  for iCount := 1 to High(FOrder) do
    if (FOrder[iCount] > 0) and (FOrder[iCount] <= High(FValues)) then
      GetHistory += LuaSystem.Get(['traits',FOrder[iCount],'abbr'], False )+'->';
end;

end.

