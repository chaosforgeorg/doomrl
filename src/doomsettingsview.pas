{$INCLUDE doomrl.inc}
unit doomsettingsview;
interface
uses viotypes, vioevent, doomio;

type TSettingsViewState = (
  SETTINGSVIEW_GENERAL,
  SETTINGSVIEW_DISPLAY,
  SETTINGSVIEW_AUDIO,
  SETTINGSVIEW_KEYMOVEMENT,
  SETTINGSVIEW_KEYACTION,
  SETTINGSVIEW_KEYUI,
  SETTINGSVIEW_KEYHELPER,
  SETTINGSVIEW_DONE
);

const SETTINGSVIEW_KEYS : set of TSettingsViewState = [
  SETTINGSVIEW_KEYMOVEMENT,
  SETTINGSVIEW_KEYACTION,
  SETTINGSVIEW_KEYUI,
  SETTINGSVIEW_KEYHELPER
];

type TSettingsView = class( TInterfaceLayer )
  constructor Create;
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
  function HandleEvent( const aEvent : TIOEvent ) : Boolean; override;
  destructor Destroy; override;
protected
  function KeyCapture( aValue : PInteger; aSelected : Boolean ) : Boolean;
protected
  FState   : TSettingsViewState;
  FSize    : TIOPoint;
  FRect    : TIORect;
  FCapture : Boolean;
  FKey     : Word;
end;

implementation

uses sysutils, vutil, vdebug, vtig, vtigio, vconfiguration,
     doomconfiguration;

const CStates : array[ TSettingsViewState ] of record Title, ID : Ansistring; end = (
   ( Title : 'Settings'; ID : 'general' ),
   ( Title : 'Settings (Display)'; ID : 'display' ),
   ( Title : 'Settings (Audio)'; ID : 'audio' ),
   ( Title : 'Settings (Keybindings - Movement)'; ID : 'keybindings_movement' ),
   ( Title : 'Settings (Keybindings - Actions)'; ID : 'keybindings_actions' ),
   ( Title : 'Settings (Keybindings - UI)'; ID : 'keybindings_ui' ),
   ( Title : 'Settings (Keybindings - Helper)'; ID : 'keybindings_helper' ),
   ( Title : ''; ID : '' )
);

const CSub : array[ 1..6 ] of record State : TSettingsViewState; Select, Desc : Ansistring; end = (
  ( State : SETTINGSVIEW_DISPLAY;    Select : 'Display';                Desc : 'Configure video and display options.' ),
  ( State : SETTINGSVIEW_AUDIO;      Select : 'Audio';                  Desc : 'Configure audio, music and sound options.' ),
  ( State : SETTINGSVIEW_KEYMOVEMENT;Select : 'Keybindings - Movement'; Desc : 'Configure keybindings for movement.' ),
  ( State : SETTINGSVIEW_KEYACTION;  Select : 'Keybindings - Actions';  Desc : 'Configure keybindings for in-game actions.' ),
  ( State : SETTINGSVIEW_KEYUI;      Select : 'Keybindings - UI';       Desc : 'Configure keybindings accessing UI elements (inventory, etc.).' ),
  ( State : SETTINGSVIEW_KEYHELPER;  Select : 'Keybindings - Helper';   Desc : 'Configure extra helper keybindings and quickslot keys.' )
);


constructor TSettingsView.Create;
begin
  inherited Create;
  VTIG_EventClear;
  VTIG_ResetSelect( 'settings' );
  FSize := Point( 80, 25 );
  FCapture := False;
end;

procedure TSettingsView.Update( aDTime : Integer );
var iSelected : Integer;
    iNext     : TSettingsViewState;
    iApply    : Boolean;
    iReset    : Boolean;
    iGroup    : TConfigurationGroup;
    iEntry    : TConfigurationEntry;
    iPick     : TConfigurationEntry;
    i         : Integer;
begin
  if ( FState = SETTINGSVIEW_DONE ) then Exit;
  iNext := SETTINGSVIEW_DONE;
  iPick := nil;

  if CStates[ FState ].ID <> '' then
    iGroup := Configuration.Group[ CStates[ FState ].ID ];

  VTIG_BeginWindow( CStates[ FState ].Title, 'settings', FSize );
    FRect := VTIG_GetWindowRect;
    VTIG_BeginGroup( 18, True );

    VTIG_BeginGroup( 50 );
      if FState = SETTINGSVIEW_GENERAL then
        for i := 1 to 6 do
          if VTIG_Selectable( CSub[i].Select ) then
            iNext := CSub[i].State;

      if iGroup <> nil then
        for iEntry in iGroup.Entries do
          if iEntry.Name <> '' then
            if VTIG_Selectable( iEntry.Name ) then
              iPick := iEntry;

      // options

      iReset := VTIG_Selectable( 'Reset to defaults' );
      iApply := VTIG_Selectable( 'Apply settings' );
      iSelected := VTIG_Selected;
    VTIG_EndGroup;

    VTIG_BeginGroup;
      i := 0;
      if FState = SETTINGSVIEW_GENERAL then
      begin
        for i := 1 to 6 do
          VTIG_Text( '' );
        i := 6;
      end;
      if iGroup <> nil then
      begin
        if FState in SETTINGSVIEW_KEYS then
        begin
          for iEntry in iGroup.Entries do
            if iEntry.Name <> '' then
            begin
              with iEntry as TIntegerConfigurationEntry do
                KeyCapture( Access, iSelected = i );
              Inc( i );
            end;
        end
        else
          for iEntry in iGroup.Entries do
            if iEntry.Name <> '' then
            begin
              if iEntry is TIntegerConfigurationEntry then
                with iEntry as TIntegerConfigurationEntry do
                  VTIG_IntInput( Access, iSelected = i, Min, Max, Step )
              else if iEntry is TToggleConfigurationEntry then
                 with iEntry as TToggleConfigurationEntry do
                   VTIG_EnabledInput( Access, iSelected = i );
              Inc( i );
            end;
      end;
    VTIG_EndGroup;

  VTIG_EndGroup( True );

  if FState = SETTINGSVIEW_GENERAL then
    if iSelected in [0..5] then
      VTIG_Text( CSub[iSelected + 1].Desc );

  VTIG_End('{l<{!Up,Down}> select, <{!Enter}> change or enter submenu, <{!Escape}> back}');

  IO.RenderUIBackground( FRect.TopLeft, FRect.BottomRight - PointUnit );

  if iNext <> SETTINGSVIEW_DONE then
  begin
    VTIG_ResetSelect( 'settings' );
    FState := iNext;
  end;

  if VTIG_EventCancel then
    if FState = SETTINGSVIEW_GENERAL
      then FState := SETTINGSVIEW_DONE
      else begin
        VTIG_ResetSelect( 'settings' );
        FState := SETTINGSVIEW_GENERAL;
      end;

end;

function TSettingsView.IsFinished : Boolean;
begin
  Exit( FState = SETTINGSVIEW_DONE );
end;

function TSettingsView.IsModal : Boolean;
begin
  Exit( True );
end;

function TSettingsView.HandleEvent( const aEvent : TIOEvent ) : Boolean;
begin
  if FCapture and (aEvent.EType = VEVENT_KEYDOWN) and (aEvent.Key.Code <> 0) then
  begin
    if aEvent.Key.Code = VKEY_ESCAPE
      then FKey := VKEY_ESCAPE
      else FKey := IOKeyEventToIOKeyCode( aEvent.Key );
    Log( IOKeyEventToString( aEvent.Key ) );
  end;
  Exit( True );
end;

destructor TSettingsView.Destroy;
begin
  inherited Destroy;
end;

function TSettingsView.KeyCapture( aValue : PInteger; aSelected : Boolean ) : Boolean;
begin
  VTIG_InputField( IOKeyCodeToString( aValue^ ) );
  if aSelected then
  begin
    if FCapture then
    begin
      VTIG_Begin( 'capture', Point( 34, 7 ) );
      VTIG_Text('Press the key or chord you want to bind, or <{!Escape}> to cancel...');
      VTIG_End;

      if FKey <> 0 then
      begin
        FCapture := False;
        if FKey <> VKEY_ESCAPE then
          aValue^ := FKey;
        FKey := 0;
      end;
      VTIG_EventClear;
    end
    else
      if VTIG_Event( [VTIG_IE_LEFT, VTIG_IE_RIGHT, VTIG_IE_CONFIRM] ) then
      begin
        FCapture := True;
        FKey     := 0;
        Exit( False );
      end;
  end;
  Exit( False );
end;

end.

