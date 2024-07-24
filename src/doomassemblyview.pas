{$INCLUDE doomrl.inc}
unit doomassemblyview;
interface
uses vutil, doomio, dfdata;

type TAssemblyView = class( TInterfaceLayer )
  constructor Create;
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
  destructor Destroy; override;
protected
  procedure ReadAssemblies;
protected
  FFinished : Boolean;
  FSize     : TPoint;
  FContent  : TStringGArray;
end;

implementation

uses sysutils, vluasystem, vtig, dfhof;

constructor TAssemblyView.Create;
begin
  VTIG_EventClear;
  FSize      := Point( 80, 25 );
end;

procedure TAssemblyView.Update( aDTime : Integer );
var iString : Ansistring;
begin
  if FContent = nil then ReadAssemblies;
  VTIG_BeginWindow('Known assemblies', 'assembly_view', FSize );
  for iString in FContent do
    VTIG_Text( iString );
  VTIG_Scrollbar;
  VTIG_End('{l<{!Up},{!Down}> scroll, <{!Enter},{!Escape}> return}');
  if VTIG_EventCancel or VTIG_EventConfirm then
    FFinished := True;
  IO.RenderUIBackground( PointZero, FSize );
end;


function TAssemblyView.IsFinished : Boolean;
begin
  Exit( FFinished );
end;

function TAssemblyView.IsModal : Boolean;
begin
  Exit( True );
end;

destructor TAssemblyView.Destroy;
begin
  FreeAndNil( FContent );
  inherited Destroy;
end;

procedure TAssemblyView.ReadAssemblies;
var iType, iFound, i : DWord;
    iString, iID     : AnsiString;
const TypeName : array[0..2] of string = ('Basic','Advanced','Master');
begin
  if FContent = nil then FContent := TStringGArray.Create;
  FContent.Clear;
  for iType := 0 to 2 do
  begin
    FContent.Push('{y'+TypeName[iType]+' assemblies}');
    FContent.Push('');
    for i := 1 to LuaSystem.Get(['mod_arrays','__counter']) do
    if LuaSystem.Get(['mod_arrays',i,'level']) = iType then
    begin
      iID    := LuaSystem.Get(['mod_arrays',i,'id']);
      iFound := HOF.GetCounted( 'assemblies','assembly', iID );
      if LuaSystem.Get( [ 'player','__props', 'assemblies', iID ], 0 ) > 0 then Inc( iFound );
      if iFound = 0
        then if iType = 0
          then iString := '  {d'+LuaSystem.Get(['mod_arrays',i,'name'])+' ({L-})}'
          else iString := '  {d  -- ? -- ({L-})}'
        else iString := '  {y'+Padded(LuaSystem.Get(['mod_arrays',i,'name'])+' ({L'+IntToStr(iFound)+'})}',36)
                        + '{l' + LuaSystem.Get(['mod_arrays',i,'desc'])+'}';
      FContent.Push( iString );
    end;
    if iType <> 2 then FContent.Push('');
  end;
end;


end.

