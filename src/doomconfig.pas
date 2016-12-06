{$INCLUDE doomrl.inc}
unit doomconfig;
interface

uses Classes, SysUtils, vluaconfig;

type

{ TDoomConfig }

TDoomConfig = class(TLuaConfig)
  constructor Create( const FileName : Ansistring; Reload : Boolean );
end;


implementation

uses vsystems, vluasystem, dfplayer, dfdata, dfoutput, vluastate, vlualibrary, doomlua, doomhelp, dfitem, doomio, doomviews;

{ LUA API }

function lua_command_quick_weapon(L: Plua_State): Integer; cdecl;
var State : TLuaState;
    ID    : AnsiString;
begin
  State.Init(L);
  if Player.SCount < 5000 then Exit(0);
  ID := State.ToString(1);
  if LuaSystem.Defines.Exists(ID) then
  Player.doQuickWeapon( ID );
  Result := lua_yield( L, 0 );
end;

function lua_command_use_item(L: Plua_State): Integer; cdecl;
var State : TDoomLuaState;
    Item  : TItem;
begin
  State.Init(L);
  if Player.SCount < 5000 then Exit(0);
  Item := Player.FindChild( State.ToString(1) ) as TItem;
  if Item <> nil then
    Player.ActionUse( Item );
  State.Push( Item <> nil );
  Result := lua_yield( L, 1 );
end;


function lua_command_quit(L: Plua_State): Integer; cdecl;
var State : TLuaState;
begin
  State.Init(L);
  if Player.SCount < 5000 then Exit(0);
  Player.doQuit( State.ToBoolean(1) );
  Result := 0;
end;

function lua_command_help(L: Plua_State): Integer; cdecl;
begin
  Help.Run;
  Result := 0;
end;

function lua_command_messages(L: Plua_State): Integer; cdecl;
begin
  IO.RunUILoop( TUIMessagesViewer.Create( IO.Root, UI.MsgGetRecent ) );
  Result := 0;
end;

function lua_command_assemblies(L: Plua_State): Integer; cdecl;
begin
  IO.RunUILoop( TUIAssemblyViewer.Create( IO.Root ) );
  Result := 0;
end;

function lua_command_fire(L: Plua_State): Integer; cdecl;
var State : TLuaState;
begin
  State.Init(L);
  if Player.SCount < 5000 then Exit(0);
  Player.doFire( State.ToBoolean(1) );
  Result := lua_yield( L, 0 );
end;

function lua_command_reload(L: Plua_State): Integer; cdecl;
var State : TLuaState;
begin
  State.Init(L);
  if Player.SCount < 5000 then Exit(0);
  Player.SilentAction := State.ToBoolean(2);
  if State.ToBoolean(1)
    then Player.ActionAltReload
    else Player.ActionReload;
  Player.SilentAction := False;
  Result := lua_yield( L, 0 );
end;


{ TDoomConfig }

constructor TDoomConfig.Create( const FileName : Ansistring; Reload : Boolean );
begin
  inherited Create;

  SetConstant('VERSION_STRING', VERSION_STRING);
  SetConstant('VERSION_BETA',   VERSION_BETA);

  LoadMain( FileName );

  Option_Graphics         := Configure('Graphics',Option_Graphics);
  Option_Blending         := Configure('Blending',Option_Blending);
  Option_SaveOnCrash      := Configure('SaveOnCrash',Option_SaveOnCrash);
  Option_SoundEngine      := Configure('SoundEngine',Option_SoundEngine);
  Option_SDLMixerFreq     := Configure('SDLMixerFreq',Option_SDLMixerFreq);
  Option_SDLMixerFormat   := Configure('SDLMixerFormat',Option_SDLMixerFormat);
  Option_SDLMixerChunkSize:= Configure('SDLMixerChunkSize',Option_SDLMixerChunkSize);

  Option_HighASCII        := Configure('AllowHighAscii',Option_HighASCII);
  Option_AlwaysRandomName := Configure('AlwaysRandomName',Option_AlwaysRandomName);
  Option_AlwaysName       := Configure('AlwaysName',Option_AlwaysName);
  Option_NoIntro          := Configure('SkipIntro',Option_NoIntro);
  Option_NoFlash          := Configure('NoFlashing',Option_NoFlash);
  Option_NoBloodSlide     := Configure('NoBloodSlides',Option_NoBloodSlide);
  Option_RunOverItems     := Configure('RunOverItems',Option_RunOverItems);
  Option_Music            := Configure('GameMusic',Option_Music);
  Option_Sound            := Configure('GameSound',Option_Sound);
  Option_MenuSound        := Configure('MenuSound',Option_MenuSound);
  Option_BlindMode        := Configure('BlindMode',Option_BlindMode);
  Option_ColorBlindMode   := Configure('ColorBlindMode',Option_ColorBlindMode);
  Option_ClearMessages    := Configure('ClearMessages',Option_ClearMessages);// TODO : Reimplement
  Option_MorePrompt       := Configure('MorePrompt',Option_MorePrompt);
  Option_MessageColoring  := Configure('MessageColoring',Option_MessageColoring);
  Option_InvFullDrop      := Configure('InvFullDrop',Option_InvFullDrop);
  Option_MortemArchive    := Configure('MortemArchive',Option_MortemArchive);
  Option_MenuReturn       := Configure('MenuReturn',Option_MenuReturn);
  Option_EmptyConfirm     := Configure('EmptyConfirm',Option_EmptyConfirm);
  Option_SoundEquipPickup := Configure('SoundEquipPickup',Option_SoundEquipPickup);
  Option_ColoredInventory := Configure('ColoredInventory',Option_ColoredInventory);
  Option_LockBreak        := Configure('LockBreak',Option_LockBreak);
  Option_LockClose        := Configure('LockClose',Option_LockClose);
  Option_TimeStamp        := Configure('TimeStamp',Option_TimeStamp);
  Option_Hints            := Configure('Hints',Option_Hints);
  Option_NetworkConnection:= Configure('NetworkConnection',Option_NetworkConnection);
  Option_VersionCheck     := Configure('VersionCheck',Option_VersionCheck);
  Option_AlertCheck       := Configure('AlertCheck',Option_AlertCheck);
  Option_BetaCheck        := Configure('BetaCheck',Option_BetaCheck);
  Option_CustomModServer  := Configure('CustomModServer',Option_CustomModServer);
  Option_InvMenuStyle     := Configure('InvMenuStyle',Option_InvMenuStyle);
  Option_EqMenuStyle      := Configure('EqMenuStyle',Option_EqMenuStyle);
  Option_HelpMenuStyle    := Configure('HelpMenuStyle',Option_HelpMenuStyle);

  Option_PlayerBackups    := Configure('PlayerBackups',Option_PlayerBackups);
  Option_ScoreBackups     := Configure('ScoreBackups',Option_ScoreBackups);

  Option_RunDelay         := Configure('RunDelay',Option_RunDelay);
  Option_MessageBuffer    := Configure('MessageBuffer',Option_MessageBuffer);

  Option_IntuitionColor   := Configure('IntuitionColor',Option_IntuitionColor);
  Option_IntuitionChar    := AnsiString(Configure('IntuitionChar',Option_IntuitionChar))[1];

  Option_MaxRun           := Configure('MaxRun',Option_MaxRun);
  Option_MaxWait          := Configure('MaxWait',Option_MaxWait);

  State.Register( 'command', 'quick_weapon', @lua_command_quick_weapon );
  State.Register( 'command', 'quit',         @lua_command_quit );
  State.Register( 'command', 'help',         @lua_command_help );
  State.Register( 'command', 'messages',     @lua_command_messages );
  State.Register( 'command', 'assemblies',   @lua_command_assemblies);
  State.Register( 'command', 'reload',       @lua_command_reload );
  State.Register( 'command', 'fire',         @lua_command_fire );
  State.Register( 'command', 'use_item',     @lua_command_use_item );

  if ForceNoNet then Option_NetworkConnection := False;

  if not Option_NetworkConnection then
  begin
    Option_VersionCheck     := False;
    Option_AlertCheck       := False;
    Option_BetaCheck        := False;
  end;

  if ForceNoAudio then
  begin
    Option_Sound := False;
    Option_Music := False;
    Option_SoundEngine := 'NONE';
  end;

  if (not Option_Music) and (not Option_Sound) then Option_SoundEngine := 'NONE';
  if Option_SoundEngine = 'DEFAULT' then
     Option_SoundEngine := {$IFDEF WINDOWS}'FMOD'{$ELSE}'SDL'{$ENDIF};
  if (Option_SoundEngine <> 'FMOD') and (Option_SoundEngine <> 'SDL') then
     Option_SoundEngine := 'NONE';
  if Option_SoundEngine = 'NONE' then
  begin
    Option_Music     := False;
    Option_Sound     := False;
    Option_MenuSound := False;
    SoundVersion     := False;
  end
  else
    SoundVersion     := True;

  // synchro
  if ForceConsole or ForceGraphics then
  begin
    if ForceConsole
      then Option_Graphics := 'CONSOLE'
      else Option_Graphics := 'TILES';
    GraphicsVersion := not ForceConsole;
  end
  else
  begin
    if (Option_Graphics <> 'TILES') and (Option_Graphics <> 'CONSOLE') then
      Option_Graphics := 'TILES';
    if Option_Graphics = 'TILES'
      then GraphicsVersion := True
      else GraphicsVersion := False;
  end;

  TDoomUI.RegisterLuaAPI( State );
end;

end.

