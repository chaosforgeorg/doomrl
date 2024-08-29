{$INCLUDE doomrl.inc}
unit doomchallengesview;
interface
uses vutil, doomio,
    vuielement // deleteme
  ;

type TChallengesList = array of Byte;

type TChallengesView = class( TInterfaceLayer )
  constructor Create( aTitle : Ansistring; aRank : Byte; aList : TChallengesList; aArch : Boolean; aDeleteMe : TUINotifyEvent = nil );
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
  destructor Destroy; override;

protected
  FSize     : TPoint;
  FFinished : Boolean;
  FTitle    : AnsiString;
  FList     : TChallengesList;
  FNames    : array of AnsiString;
  FValid    : array of Boolean;
  FPrefix   : AnsiString;

  FDeleteMe : TUINotifyEvent;

  class var FClassResult : Byte;
public
  class property Result : Byte read FClassResult;
end;

implementation

uses vtig, vtigstyle, vluasystem, dfdata;

// deleteme
destructor TChallengesView.Destroy;
begin
  inherited Destroy;
  if Assigned( FDeleteMe ) then FDeleteMe( nil );
end;

constructor TChallengesView.Create( aTitle : Ansistring; aRank : Byte; aList : TChallengesList; aArch : Boolean; aDeleteMe : TUINotifyEvent = nil );
var i : Byte;
begin
  FDeleteMe := aDeleteMe;

  VTIG_EventClear;
  VTIG_ResetSelect( 'challenges_view' );

  FSize     := Point( 80, 25 );
  FFinished := False;
  FTitle    := aTitle;
  FList     := aList;
  FPrefix   := '';
  if aArch then FPrefix := 'arch_';
  SetLength( FNames, Length( FList ) );
  SetLength( FValid, Length( FList ) );
  for i := 0 to High( FList ) do
  begin
    FNames[i] := LuaSystem.Get(['chal',FList[i],FPrefix+'name']);
    FValid[i] := (aRank >= LuaSystem.Get(['chal',FList[i],FPrefix+'rank'],0)) or (GodMode) or (Setting_UnlockAll);
  end;
  FClassResult := 0;
end;

procedure TChallengesView.Update( aDTime : Integer );
var iSelect : Integer;
    iCount  : Byte;
begin
  VTIG_BeginWindow( FTitle, 'challenges_view', FSize );
    iSelect := 0;

    VTIG_BeginGroup( 28 );
      VTIG_PushStyle( @TIGStyleColored );
      for iCount := 0 to High( FList ) do
        if VTIG_Selectable( FNames[iCount], FValid[iCount] ) then
          FClassResult := FList[iCount];
      iSelect := VTIG_Selected;
      VTIG_PopStyle;

      VTIG_EndGroup;

      VTIG_BeginGroup;
          VTIG_Text( FNames[iSelect], VTIGDefaultStyle.Color[ VTIG_TITLE_COLOR ] );
          VTIG_Ruler;
          VTIG_Text( 'Rating: {!'+LuaSystem.Get(['chal',FList[iSelect],FPrefix+'rating'],'UNRATED')+'}'#10#10+
                 LuaSystem.Get(['chal',FList[iSelect],FPrefix+'description']) );
      VTIG_EndGroup;

  VTIG_End('{l<{!Up},{!Down}> select, <{!Enter}> select, <{!Escape}> exit}');

  if VTIG_EventCancel or (FClassResult <> 0) then
     FFinished := True;

  IO.RenderUIBackground( PointZero, FSize );
end;

function TChallengesView.IsFinished : Boolean;
begin
  Exit( FFinished );
end;

function TChallengesView.IsModal : Boolean;
begin
  Exit( True );
end;


end.

