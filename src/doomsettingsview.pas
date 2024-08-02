{$INCLUDE doomrl.inc}
unit doomsettingsview;
interface
uses viotypes, vioevent, vconfiguration, doomio,
     vuielement // deleteme
     ;

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
  constructor Create( aDeleteMe : TUINotifyEvent = nil );
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
  function HandleEvent( const aEvent : TIOEvent ) : Boolean; override;
  destructor Destroy; override;
protected
  procedure Reconfigure;
  procedure Reset( aGroup : TConfigurationGroup );
  function KeyCapture( aValue : PInteger; aSelected : Boolean ) : Boolean;
protected
  FState       : TSettingsViewState;
  FSize        : TIOPoint;
  FRect        : TIORect;
  FCapture     : Boolean;
  FKey         : Word;
  FResInput    : Boolean;
  FResolutions : array of Ansistring;

  FDeleteMe : TUINotifyEvent;
end;

implementation

uses math, sysutils, vutil, vdebug, vtig, vtigio,
     dfdata, doomconfiguration, doombase;

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


constructor TSettingsView.Create( aDeleteMe : TUINotifyEvent = nil );
var i, iCount : Integer;
begin
  FDeleteMe := aDeleteMe;

  inherited Create;
  VTIG_EventClear;
  VTIG_ResetSelect( 'settings' );
  FSize := Point( 80, 25 );
  FCapture  := False;
  FResInput := False;

  if GraphicsVersion then
  begin
    iCount := Min( 17, IO.Driver.DisplayModes.Size );
    SetLength( FResolutions, iCount + 1);
    FResolutions[0] := 'Automatic';
    for i := 1 to iCount do
      with IO.Driver.DisplayModes[i-1] do
        FResolutions[i] := IntToStr( Width ) + 'x' + IntToStr( Height )
  end;
end;

procedure TSettingsView.Update( aDTime : Integer );
var iSelected : Integer;
    iNext     : TSettingsViewState;
    iApply    : Boolean;
    iReset    : Boolean;
    iGroup    : TConfigurationGroup;
    iEntry    : TConfigurationEntry;
    iHover    : TConfigurationEntry;
    iMode     : TIntegerConfigurationEntry;
    i         : Integer;
begin
  if ( FState = SETTINGSVIEW_DONE ) then Exit;
  iNext  := SETTINGSVIEW_DONE;
  iHover := nil;

  if CStates[ FState ].ID <> '' then
    iGroup := Configuration.Group[ CStates[ FState ].ID ];

  iMode := Configuration.CastInteger( 'display_mode' );

  VTIG_BeginWindow( CStates[ FState ].Title, 'settings', FSize );
    FRect := VTIG_GetWindowRect;
    VTIG_BeginGroup( 18, True );

    VTIG_BeginGroup( 50 );
      if FState = SETTINGSVIEW_DISPLAY then
        VTIG_Selectable( 'Resolution' );

      if FState = SETTINGSVIEW_GENERAL then
        for i := 1 to 6 do
          if VTIG_Selectable( CSub[i].Select ) then
            iNext := CSub[i].State;

      if iGroup <> nil then
        for iEntry in iGroup.Entries do
          if iEntry.Name <> '' then
            VTIG_Selectable( iEntry.Name );

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
              if iSelected = i then iHover := iEntry;
              Inc( i );
            end;
        end
        else
        begin
          if FState = SETTINGSVIEW_DISPLAY then
          begin
            if GraphicsVersion then
            begin
              if VTIG_EnumInput( iMode.Access, iSelected = i, @FResInput, FResolutions ) then
              begin
                if iMode.Value = 0 then
                begin
                  Configuration.AccessInteger( 'screen_width' )^  := 0;
                  Configuration.AccessInteger( 'screen_height' )^ := 0;
                end
                else
                with IO.Driver.DisplayModes[ iMode.Value - 1 ] do
                begin
                  Configuration.AccessInteger( 'screen_width' )^  := Width;
                  Configuration.AccessInteger( 'screen_height' )^ := Height;
                end;
                Doom.Reconfigure;
              end;
            end
            else
              VTIG_InputField('Unavailable');

            Inc( i );
          end;

          for iEntry in iGroup.Entries do
            if iEntry.Name <> '' then
            begin
              if iEntry is TIntegerConfigurationEntry then
              begin
                with iEntry as TIntegerConfigurationEntry do
                  if VTIG_IntInput( Access, iSelected = i, Min, Max, Step ) then
                  begin
                    if FState = SETTINGSVIEW_AUDIO then
                      IO.Audio.Reconfigure;
                    if FState = SETTINGSVIEW_DISPLAY then
                      Doom.Reconfigure;
                  end;
              end
              else if iEntry is TToggleConfigurationEntry then
                 with iEntry as TToggleConfigurationEntry do
                   VTIG_EnabledInput( Access, iSelected = i );
              if iSelected = i then iHover := iEntry;
              Inc( i );
            end;
        end;
      end;
    VTIG_EndGroup;

  VTIG_EndGroup( True );

  if FState = SETTINGSVIEW_GENERAL then
  begin
    if iSelected in [0..5]
      then VTIG_Text( CSub[iSelected + 1].Desc );
    if iSelected = i   then VTIG_Text( 'Resets ALL configuration values to default values.' );
    if iSelected = i+1 then VTIG_Text( 'Apply changes and exit.' );
  end
  else
  begin
    if iSelected = i   then VTIG_Text( 'Resets values from this screen to default values.' );
    if iSelected = i+1 then VTIG_Text( 'Apply changes and return to previous menu.' );
  end;
  if ( FState = SETTINGSVIEW_DISPLAY ) and ( iSelected = 0 )then
  begin
    if GraphicsVersion
      then VTIG_Text( 'Choose screen resolution. Pick {!Automatic} to use native in fullscreen.' )
      else VTIG_Text( 'Resolution choice unavailable in ASCII mode. You can still reset it to default if needed.' );
  end;


  if iHover <> nil
    then VTIG_Text( iHover.Description );

  VTIG_End('{l<{!Up,Down}> select, <{!Enter}> change or enter submenu, <{!Escape}> back}');

  IO.RenderUIBackground( FRect.TopLeft, FRect.BottomRight - PointUnit );

  if iNext <> SETTINGSVIEW_DONE then
  begin
    VTIG_ResetSelect( 'settings' );
    FState := iNext;
  end;

  if VTIG_EventCancel or iApply then
    if FState = SETTINGSVIEW_GENERAL
      then FState := SETTINGSVIEW_DONE
      else begin
        VTIG_ResetSelect( 'settings' );
        FState := SETTINGSVIEW_GENERAL;
      end;

  if iApply then Reconfigure;
  if iReset then
  begin
    if FState = SETTINGSVIEW_GENERAL
      then Reset( nil )
      else Reset( iGroup );
    Reconfigure;
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
  end;
  Exit( True );
end;

destructor TSettingsView.Destroy;
begin
  Configuration.Write( SettingsPath );
  inherited Destroy;
  if Assigned( FDeleteMe ) then FDeleteMe( nil );
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

procedure TSettingsView.Reset( aGroup : TConfigurationGroup );
var iEntry : TConfigurationEntry;
begin
  if aGroup = nil then
  begin
    for aGroup in Configuration.Groups do
      Reset( aGroup );
    Exit;
  end;

  for iEntry in aGroup.Entries do
    iEntry.Reset;
end;

procedure TSettingsView.Reconfigure;
begin
  Doom.Reconfigure;
end;

end.

