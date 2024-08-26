{$INCLUDE doomrl.inc}
unit doomlua;
interface

uses SysUtils, Classes, vluastate, vluasystem, vlualibrary, vrltools, vutil, vcolor, vdf, vbitmapfont, dfitem, dfbeing, dfthing, dfdata, doommodule;

var LuaPlayerX : Byte = 2;
    LuaPlayerY : Byte = 2;
    

type

{ TDoomLua }

TDoomLua = class(TLuaSystem)
       constructor Create; reintroduce;
       procedure OnError(const ErrorString : Ansistring); override;
       destructor Destroy; override;
       procedure RegisterPlayer(Thing: TThing);
       procedure LoadModule(Module : TDoomModule);
       function LoadFont( const aFontName : AnsiString ) : TBitmapFont;
     private
       procedure ReadWad(WADName : string);
     private
       FCoreData     : TVDataFile;
       FMainData     : TVDataFile;
     end;

type

{ TDoomLuaState }

TDoomLuaState = object(TLuaState)
  function ToId( Index : Integer) : DWord;
  function ToSoundId( Index : Integer ) : DWord;
  function ToPosition( Index : Integer ) : TCoord2D;
end;

// published functions

implementation

uses typinfo, variants, strutils, xmlread, dom,
     vnode, vdebug, viotypes, vluatools, vsystems, vluadungen, vluaentitynode,
     vmath, vtextures, vimage,
     dfplayer, dflevel, dfmap, doomhooks, doomhelp, dfhof, doombase, doomio, vsound, doomgfxio, doomspritemap;

var SpriteSheetCounter : Integer = -1;

function GenerateGlow ( Shadow : TImage ) : TImage;
const GaussSize = 1;
var Glow        : TImage;
    X,Y,P,XX,YY : Integer;
    RX,RY       : Integer;
    Value       : Integer;
begin
  Glow := TImage.Create( Shadow.SizeX, Shadow.SizeY );
  Glow.Fill( ColorZero );
  XX := 1 * 4;
  YY := Glow.SizeX * 4;
  for X := 1 to Glow.SizeX - 2 do
    for Y := 1 to Glow.SizeY - 2 do
    begin
      P  := (Integer(Glow.SizeX)*Y + X) * 4;
      RX := ( Shadow.Data[ P-YY ] - Shadow.Data[ P+YY ] );
      RY := ( Shadow.Data[ P+XX ] - Shadow.Data[ P-XX ] );
      Value := Clamp( Round( 0.1 * Sqrt( RX * RX + RY * RY ) ), 0, 255 );
      Glow.Data[ P   ] := Value;
      Glow.Data[ P+1 ] := Value;
      Glow.Data[ P+2 ] := Value;
      Glow.Data[ P+3 ] := Value;
    end;
  GenerateGlow := Glow.Clone;
  for X := GaussSize to Glow.SizeX - 1 - GaussSize do
    for Y := GaussSize to Glow.SizeY - 1 - GaussSize do
    begin
      Value := 0;
      for RX := -GaussSize to GaussSize do
        for RY := -GaussSize to GaussSize do
          Value += Glow.Data[ (Integer(Glow.SizeX)*(Y+RY) + (X+RX)) * 4 ];
      Value := Clamp( Value div ( GaussSize * GaussSize ), 0, 255 );
      P  := (Integer(Glow.SizeX)*Y + X) * 4;
      GenerateGlow.Data[ P   ] := Value;
      GenerateGlow.Data[ P+1 ] := Value;
      GenerateGlow.Data[ P+2 ] := Value;
      GenerateGlow.Data[ P+3 ] := Value;
    end;
  FreeAndNil( Glow );
end;

function lua_core_is_playing(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  State.Push( Doom.State = DSPlaying );
  Result := 1;
end;

function lua_statistics_get(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  Player.FStatistics.Update;
  // Unused parameter #1 is self
  State.Push( Player.FStatistics.Map[ State.ToString( 2 ) ] );
  Result := 1;
end;

function lua_statistics_set(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  // Unused parameter #1 is self
  Player.FStatistics.Map[ State.ToString( 2 ) ] := State.ToInteger( 3 );
  Result := 0;
end;

function lua_statistics_inc(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  Player.IncStatistic( State.ToString( 1 ), State.ToInteger( 2 ) );
  Result := 0;
end;

function lua_statistics_get_date(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    Curr : TSystemTime;
    DOW  : integer;
begin
  State.Init(L);
  DateTimeToSystemTime(Now(), Curr);
  DOW := DayOfWeek(Now());
  lua_newtable(L);
  // Build the table.
  lua_pushnumber(L, Curr.Millisecond); // Push the value to go in.
  lua_setfield(L, -2, 'millisecond'); // Assign it to the table.
  lua_pushnumber(L, Curr.Second);
  lua_setfield(L, -2, 'second');
  lua_pushnumber(L, Curr.Minute);
  lua_setfield(L, -2, 'minute');
  lua_pushnumber(L, Curr.Hour);
  lua_setfield(L, -2, 'hour');
  lua_pushnumber(L, Curr.Day);
  lua_setfield(L, -2, 'day');
  lua_pushnumber(L, DOW);
  lua_setfield(L, -2, 'dayofweek');
  lua_pushnumber(L, Curr.Month);
  lua_setfield(L, -2, 'month');
  lua_pushnumber(L, Curr.Year);
  lua_setfield(L, -2, 'year');
  Exit(1);
end;

function lua_core_register_missile(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    mID : Integer;
begin
  State.Init(L);
  if High(Missiles) = -1 then SetLength(Missiles,20);
  mID := State.ToInteger(1);
  if mID > High(Missiles) then
    SetLength(Missiles,High(Missiles)*2);
  with Missiles[mID] do
  with LuaSystem.GetTable(['missiles', mID]) do
  try
    SoundID   := getString('sound_id');
    if isTable('coscolor')
      then Sprite := NewSprite( getInteger( 'sprite', 0 ), NewColor( getVec4f( 'coscolor' ) ) )
      else Sprite := NewSprite( getInteger( 'sprite', 0 ) );
    Picture   := getChar('ascii');
    Color     := getInteger('color');
    Delay     := getInteger('delay');
    Flags     := getFlags('flags');
    Range     := getInteger('range');
    MaxRange  := getInteger('maxrange');
    MissBase  := getInteger('miss_base');
    MissDist  := getInteger('miss_dist');
    ExplDelay := getInteger('expl_delay');
    ExplColor := getInteger('expl_color');
    ExplFlags := ExplosionFlagsFromFlags( getFlags('expl_flags') );
    RayDelay  := getInteger('ray_delay');
    Content   := getInteger('content');
  finally
    Free;
  end;
  Result := 0;
end;

function lua_core_register_shotgun(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    mID : Integer;
begin
  State.Init(L);
  if High(Shotguns) = -1 then SetLength(Shotguns,20);
  mID := State.ToInteger(1);
  if mID > High(Shotguns) then
    SetLength(Shotguns,High(Shotguns)*2);
  with Shotguns[mID] do
  with LuaSystem.GetTable(['shotguns',mID]) do
  try
    Range      := getInteger('range');
    MaxRange   := getInteger('maxrange');
    Spread     := getInteger('spread');
    Reduce     := getFloat ('reduce');
    DamageType := TDamageType( getInteger('damage') );
  finally
    Free;
  end;
  Result := 0;
end;

function lua_core_register_affect(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    mID : Integer;
begin
  State.Init(L);
  if High(Affects) = -1 then SetLength(Affects,MAXAFFECT);
  mID := State.ToInteger(1);
  if mID > High(Affects) then
    raise Exception.Create('Maximum number of registered affects reached!');
  with Affects[mID] do
  with LuaSystem.GetTable(['affects',mID]) do
  try
    Name       := getString('name');
    Color      := getInteger('color');
    Color_exp  := getInteger('color_expire');
    Hooks      := [];
    StatusEff  := TStatusEffect( getInteger('status_effect',0) );
    StatusStr  := getInteger('status_strength',0);
    if isFunction('OnTick')   then Include(Hooks, AffectHookOnTick);
    if isFunction('OnAdd')    then Include(Hooks, AffectHookOnAdd);
    if isFunction('OnRemove') then Include(Hooks, AffectHookOnRemove);
  finally
    Free;
  end;
  Result := 0;
end;

function lua_core_add_to_cell_set(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  case State.ToInteger(1) of
    0 : State.Error('Bad Cellset in Lua!');
    CELLSET_FLOORS  : Include(CellFloors,State.ToInteger(2));
    CELLSET_WALLS   : Include(CellWalls ,State.ToInteger(2));
  end;
  Result := 0;
end;

function lua_core_player_data_count(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  State.Push( LongInt(HOF.GetCount( State.ToString( 1 ) )) );
  Result := 1;
end;

function lua_core_player_data_child_count(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  State.Push( LongInt(HOF.GetChildCount( State.ToString( 1 ) )) );
  Result := 1;
end;

function lua_core_player_data_get_counted(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  State.Push( LongInt(HOF.GetCounted( State.ToString( 1 ), State.ToString( 2 ), State.ToString( 3 ) ) ) );
  Result := 1;
end;

function lua_core_player_data_add_counted(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  State.Push( Boolean(HOF.AddCounted( State.ToString( 1 ), State.ToString( 2 ), State.ToString( 3 ), State.ToInteger( 4,1 ) ) ) );
  Result := 1;
end;

function lua_core_resolve_sound_id(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  State.Push(IO.Audio.ResolveSoundID([State.ToString(1),State.ToString(2),State.ToString(3)]));
  Result := 1;
end;

function lua_core_play_music(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  IO.Audio.PlayMusic(State.ToString(1));
  Result := 0;
end;

function lua_core_game_type(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  State.Push(Byte(Doom.GameType));
  Result := 1;
end;

function lua_core_game_module(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  if Doom.Module = nil
     then State.PushNil
     else State.Push(Doom.Module.Id);
  Result := 1;
end;


// ************************************************************************ //
// ************************************************************************ //

function lua_core_game_time(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  State.Push(Player.FStatistics.GameTime);
  Result := 1;
end;

function lua_core_register_cell(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
begin
  State.Init(L);
  Cells.RegisterCell(State.ToInteger(1));
  Result := 0;
end;

function lua_core_texture_upload(L: Plua_State): Integer; cdecl;
var State    : TDoomLuaState;
    iTexture : TTexture;
begin
  State.Init(L);
  if not GraphicsVersion then Exit( 0 );
  iTexture := (IO as TDoomGFXIO).Textures.Textures[ State.ToString(1) ];
  if iTexture = nil then State.Error( 'Texture not found: '+State.ToString(1) );
  if State.IsBoolean( 2 ) and State.ToBoolean( 2 ) then iTexture.Blend := True;
  if State.IsBoolean( 3 ) and State.ToBoolean( 3 ) then iTexture.is3D  := True;
  if iTexture.GLTexture = 0
    then iTexture.Upload
    else Log( LOGWARN, 'Texture redefinition: '+State.ToString(1) );
  Result := 0;
end;


function lua_core_texture_generate_glow(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    iIn   : TTexture;
begin
  State.Init(L);
  if not GraphicsVersion then Exit( 0 );
  iIn := (IO as TDoomGFXIO).Textures.Textures[ State.ToString(1) ];
  if iIn = nil then State.Error( 'Texture not found: '+State.ToString(1) );
  (IO as TDoomGFXIO).Textures.AddImage( State.ToString(2), GenerateGlow( iIn.Image ), Option_Blending );
  Result := 0;
end;


function lua_core_register_sprite_sheet(L: Plua_State): Integer; cdecl;
var State    : TDoomLuaState;
    iNormal  : TTexture;
    iCosplay : TTexture;
    iGlow    : TTexture;

  function LoadTexture( iIndex : Integer ) : TTexture;
  begin
    if not State.IsString( iIndex ) then Exit( nil );
    LoadTexture := (IO as TDoomGFXIO).Textures.Textures[ State.ToString( iIndex ) ];
    if LoadTexture = nil then State.Error( 'register_sprite_sheet - texture not found : "'+State.ToString( iIndex )+'"!');
    if LoadTexture.GLTexture = 0 then
      LoadTexture.Upload;
  end;

begin
  State.Init(L);
  if not GraphicsVersion then
  begin
    Inc( SpriteSheetCounter );
    State.Push( Integer( SpriteSheetCounter * 100000 ) );
    Exit( 1 );
  end;
  iNormal  := LoadTexture( 1 );
  iCosplay := LoadTexture( 2 );
  iGlow    := LoadTexture( 3 );
  if iNormal = nil then State.Error( 'Bad parameters passes to register_sprite_sheet!');
  State.Push( Integer( SpriteMap.Engine.Add( iNormal, iCosplay, iGlow, State.ToInteger(4) ) * 100000 ) );
  Result := 1;
end;

// -------------------------------------------------------------------------------

procedure TDoomLua.LoadModule(Module: TDoomModule);
var Path : AnsiString;
    WAD  : TVDataFile;
    procedure LoadMusic( Ext : Ansistring );
    var Info : TSearchRec;
    begin
      if FindFirst( Path + 'music' + DirectorySeparator + '*'+Ext, faAnyFile, Info ) = 0 then
      repeat with Info do
          Sound.RegisterMusic( Path + 'music' + DirectorySeparator + Name, LeftStr( Name, Length( Name ) - 4 ) );
      until FindNext(info) <> 0;
      FindClose(Info);
    end;
    procedure LoadSound( Ext : Ansistring );
    var Info : TSearchRec;
    begin
      if FindFirst( Path + 'sound' + DirectorySeparator + '*'+Ext, faAnyFile, Info ) = 0 then
      repeat with Info do
          Sound.RegisterSample( Path + 'sound' + DirectorySeparator + Name, LeftStr( Name, Length( Name ) - 4 ) );
      until FindNext(info) <> 0;
      FindClose(Info);
    end;
begin
  if Module.Raw then
  begin
    Path := Modules.ModulePath + Module.ID + '.module' + DirectorySeparator;
//    Lua.Register('require',@lua_core_require);
    RegisterModule( Module.ID, Path );
    LoadFile( Path + 'module.lua' );
    LoadFile( Path + 'main.lua' );
    if SoundVersion then
    begin
      LoadMusic('.mid');
      LoadMusic('.mp3');
      LoadMusic('.ogg');
      LoadSound('.wav');
    end;
  end
  else
  begin
    WAD := TVDataFile.Create( Modules.ModulePath + Module.ID + '.wad' );
    RegisterModule(Module.ID, WAD);
    LoadStream(WAD,'','module.lua');
    LoadStream(WAD,'','main.lua');
    WAD.RegisterLoader(FILETYPE_ASCII,@IO.ASCIILoader);
    if SoundVersion then
    begin
      WAD.RegisterLoader(FILETYPE_MUSIC,@Sound.MusicStreamLoader);
      WAD.RegisterLoader(FILETYPE_SOUND,@Sound.SampleStreamLoader);
    end;
    WAD.Load('ascii');
    if SoundVersion then
    begin
      WAD.Load('sound');
      WAD.Load('music');
    end;
    FreeAndNil(WAD);
  end;
end;

function TDoomLua.LoadFont(const aFontName: AnsiString) : TBitmapFont;
var iXML : TXMLDocument;
//    iStream : TStream;
begin
  if GodMode
    then ReadXMLFile( iXML, DataPath + 'graphics' + DirectorySeparator + aFontName+'.xml' )
    else iXML := FMainData.GetXMLDocument(aFontName + '.xml','');
  Result := TBitmapFont.CreateFromXML( (IO as TDoomGFXIO).Textures.TextureID[aFontName],iXML );
  FreeAndNil( iXML );
  {iStream := TFileStream.Create('aero.ttf', fmOpenRead);
  FMsgFont := TBitmapFont.CreateFromTTF( iStream, iStream.Size, 12 );
  FreeAndNil( iStream );}
  //FMsgFont := TGLConsoleRenderer( FConsole ).Font;
end;

procedure TDoomLua.ReadWad(WADName : string);
var iProgBase : DWord;
begin
  FCoreData := TVDataFile.Create(DataPath+'core.wad');
  FMainData := TVDataFile.Create(DataPath+WADName);
  FMainData.DKKey := LoveLace;

  iProgBase := IO.LoadCurrent;
  IO.LoadProgress(iProgBase + 10);

  if GodMode then
  begin
    RegisterModule( 'core', 'data' + DirectorySeparator + 'core' + DirectorySeparator );
    RegisterModule( 'drl', 'data' + DirectorySeparator + 'drl' + DirectorySeparator );
    LoadFile( 'data' + DirectorySeparator + 'core' + DirectorySeparator + 'core.lua' );
    IO.LoadProgress(iProgBase + 20);
    LoadFile( 'data' + DirectorySeparator + 'drl' + DirectorySeparator + 'main.lua' );
    IO.LoadProgress(iProgBase + 30);
    if GraphicsVersion then
      (IO as TDoomGFXIO).Textures.LoadTextureFolder( 'data' + DirectorySeparator + 'drl' + DirectorySeparator + 'graphics' );
  end
  else
  begin
    RegisterModule('core',FCoreData);
    RegisterModule('drl',FMainData);
    LoadStream(FCoreData,'','core.lua');
    IO.LoadProgress(iProgBase + 20);
    LoadStream(FMainData,'','main.lua');
    IO.LoadProgress(iProgBase + 30);
    if GraphicsVersion then
      FMainData.RegisterLoader(FILETYPE_IMAGE ,@((IO as TDoomGFXIO).Textures.LoadTextureCallback));
  end;
  FMainData.RegisterLoader(FILETYPE_HELP ,@Help.StreamLoader);
  FMainData.RegisterLoader(FILETYPE_ASCII,@IO.ASCIILoader);
  IO.LoadProgress(iProgBase + 35);
  FMainData.Load('help');
  IO.LoadProgress(iProgBase + 40);
  FMainData.Load('ascii');
  IO.LoadProgress(iProgBase + 50);

  if (not GodMode) and GraphicsVersion then
    FMainData.Load('graphics');

  IO.LoadProgress(iProgBase + 100);
end;

procedure TDoomLua.OnError(const ErrorString : Ansistring);
begin
  if (IO <> nil) and (Doom.State = DSPlaying) then
  begin
    IO.ErrorReport( ErrorString );
  end
  else
    raise ELuaException.Create('LuaError: '+ErrorString);
  Log('LuaError: '+ErrorString);
end;

destructor TDoomLua.Destroy;
begin
  FreeAndNil(FCoreData);
  FreeAndNil(FMainData);
  inherited Destroy;
end;

procedure TDoomLua.RegisterPlayer(Thing: TThing);
begin
  LuaSystem.SetValue('player',Thing);
  RegisterKillsClass( Raw, (Thing as TPlayer).FKills );
end;

procedure LogProps( aClass : TClass );
var
  Count, I : Longint;
  PP       : PPropList;
  PD       : PTypeData;
begin
  PD := GetTypeData(aClass.ClassInfo);
  Count := PD^.PropCount;
  GetMem(PP,Count*SizeOf(Pointer));
  GetPropInfos(aClass.ClassInfo,PP);
  Log('Properties : '+aClass.ClassName+' (total count : '+IntToStr(Count)+')');
  for I:=0 to Count-1 do
    Log('Property ('+IntToStr(I)+'): '+PP^[I]^.Name); //('+GetPropInfo(aClass,Name)^.PropType^.Name+')');
  FreeMem(PP);
end;

const lua_statistics_lib : array[0..2] of luaL_Reg = (
    ( name : 'inc';        func : @lua_statistics_inc),
    ( name : 'get_date';   func : @lua_statistics_get_date),
    ( name : nil;          func : nil; )
);

const lua_player_data_lib : array[0..4] of luaL_Reg = (
    ( name : 'count';       func : @lua_core_player_data_count),
    ( name : 'child_count'; func : @lua_core_player_data_child_count),
    ( name : 'get_counted'; func : @lua_core_player_data_get_counted),
    ( name : 'add_counted'; func : @lua_core_player_data_add_counted),
    ( name : nil;           func : nil; )
);


const lua_core_lib : array[0..14] of luaL_Reg = (
    ( name : 'add_to_cell_set';func : @lua_core_add_to_cell_set),
    ( name : 'game_time';func : @lua_core_game_time),
    ( name : 'game_type';func : @lua_core_game_type),
    ( name : 'game_module';func : @lua_core_game_module),
    ( name : 'is_playing';func : @lua_core_is_playing),
    ( name : 'register_cell';   func : @lua_core_register_cell),
    ( name : 'register_missile';func : @lua_core_register_missile),
    ( name : 'register_shotgun';func : @lua_core_register_shotgun),
    ( name : 'register_affect'; func : @lua_core_register_affect),

    ( name : 'resolve_sound_id';func : @lua_core_resolve_sound_id),
    ( name : 'play_music';func : @lua_core_play_music),

    ( name : 'texture_upload';        func : @lua_core_texture_upload),
    ( name : 'texture_generate_glow'; func : @lua_core_texture_generate_glow),
    ( name : 'register_sprite_sheet'; func : @lua_core_register_sprite_sheet),

    ( name : nil;          func : nil; )
);

constructor TDoomLua.Create;
var Count : Byte;
begin
  if GodMode
    then inherited Create( Config.Raw )
    else inherited Create( nil );

  RegisterTableAuxFunctions( Raw );
  RegisterMathAuxFunctions( Raw );

  RegisterUIDClass( Raw );
  RegisterCoordClass( Raw );
  RegisterAreaClass( Raw );
  RegisterAreaFull( Raw, NewArea( NewCoord2D(1,1), NewCoord2D(MaxX,MaxY) ) );
  RegisterWeightTableClass( Raw );

  LuaSystem := Self;
  SetPrintFunction( @IO.ConsolePrint );

  ErrorFunc := @OnError;
  
  SetValue('WINDOWSVERSION', {$IFDEF WINDOWS}1{$ELSE}0{$ENDIF});
  SetValue('VERSION', VERSION_STRING);
  SetValue('VERSION_STRING', VERSION_STRING);
  SetValue('VERSION_BETA',   VERSION_BETA);
  SetValue('GRAPHICSVERSION',GraphicsVersion);

  for Count := 0 to 15 do SetValue(ColorNames[Count],Count);
  TDoomIO.RegisterLuaAPI( State );

  Register( 'statistics', lua_statistics_lib );
  RegisterMetaTable('statistics',@lua_statistics_get, @lua_statistics_set );

  Register( 'player_data', @lua_player_data_lib );
  Register( 'core', lua_core_lib );

  State.RegisterEnumValues( TypeInfo(TItemType) );
  State.RegisterEnumValues( TypeInfo(TBodyTarget) );
  State.RegisterEnumValues( TypeInfo(TEqSlot) );
  State.RegisterEnumValues( TypeInfo(TStatusEffect) );
  State.RegisterEnumValues( TypeInfo(TDamageType) );
  State.RegisterEnumValues( TypeInfo(TAltFire) );
  State.RegisterEnumValues( TypeInfo(TAltReload) );
  State.RegisterEnumValues( TypeInfo(TExplosionFlag) );
  State.RegisterEnumValues( TypeInfo(TResistance) );
  State.RegisterEnumValues( TypeInfo(TMoveResult) );
  State.RegisterEnumValues( TypeInfo(TDoomGameType) );

  TNode.RegisterLuaAPI( 'game_object' );

  TLuaEntityNode.RegisterLuaAPI( 'thing' );

  TItem.RegisterLuaAPI();
  TBeing.RegisterLuaAPI();
  TLevel.RegisterLuaAPI();
  TPlayer.RegisterLuaAPI();
  RegisterDungenClass( LuaSystem.Raw, 'generator' );

  doombase.Lua := Self;

  LogProps( TThing );
  LogProps( TItem );
  LogProps( TBeing );
  LogProps( TPlayer );
  LogProps( TLevel );


  RegisterType( TBeing,  'being', 'beings' );
  RegisterType( TPlayer, 'player', 'beings' );
  RegisterType( TItem,   'item',  'items'  );
  RegisterType( TLevel,  'level', 'levels' );

  LuaSystem.GetClassInfo( TBeing ).RegisterHooks( BeingHooks, HookNames );
  LuaSystem.GetClassInfo( TPlayer ).RegisterHooks( BeingHooks, HookNames );
  LuaSystem.GetClassInfo( TItem ).RegisterHooks( ItemHooks, HookNames );

  ReadWAD('drl.wad');

end;

{ TDoomLuaState }

function TDoomLuaState.ToId(Index: Integer ): DWord;
begin
  if IsNumber( Index ) then Exit( ToInteger( Index ) );
  ToId := LuaSystem.Defines[ToString( Index )];
  if ToId = 0 then Error( 'unknown define ('+ToString( Index ) +')!' );
end;

function TDoomLuaState.ToSoundId(Index: Integer): DWord;
begin
  if IsNumber( Index ) then
     Exit( ToInteger( Index ) )
  else if IsTable( Index ) then
     Exit( IO.Audio.ResolveSoundID( ToStringArray( Index ) ) )
  else
     Exit( IO.Audio.ResolveSoundID( [ ToString(Index) ] ) );
end;

function TDoomLuaState.ToPosition( Index : Integer ) : TCoord2D;
begin
  if IsCoord( Index ) then
     Exit( ToCoord( Index ) )
  else
     Exit( (ToObject( Index ) as TThing).Position );
end;

end.

