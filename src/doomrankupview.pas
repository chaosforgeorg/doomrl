{$INCLUDE doomrl.inc}
unit doomrankupview;
interface
uses vutil, doomio, dfdata;

type TRankUpView = class( TInterfaceLayer )
  constructor Create( aRank : THOFRank );
  procedure Update( aDTime : Integer ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
protected
  FFinished : Boolean;
  FSize     : TPoint;
  FSRName   : Ansistring;
  FERName   : Ansistring;
end;

implementation

uses sysutils, vluasystem, vtig, dfhof;

constructor TRankUpView.Create( aRank : THOFRank );
begin
  VTIG_EventClear;
  FSize      := Point( 80, 25 );
  FSRName := '';
  FERName := '';
  if aRank.SkillRank <> 0 then FSRName := LuaSystem.Get(['skill_ranks',aRank.SkillRank+1,'name'],'');
  if aRank.ExpRank   <> 0 then FERName := LuaSystem.Get(['exp_ranks',aRank.ExpRank+1,'name'],'');
end;

procedure TRankUpView.Update( aDTime : Integer );
var iString : Ansistring;
begin
  VTIG_BeginWindow('Congratulations!', 'rank_up_view', FSize );

  if (FSRName <> '') and (FERName <> '') then
    VTIG_FreeLabel( 'You have shown both skill and determination and advanced', Point( 12, 4 ) )
  else
    if FSRName <> ''
      then VTIG_FreeLabel( 'You have amazing skill and advanced', Point( 12, 4 ) )
      else VTIG_FreeLabel( 'You have fierceful determination and advanced', Point( 12, 4 ) );

  if (FSRName <> '') and (FERName <> '') then
    VTIG_FreeLabel( 'to {!{0}} skill rank and {!{1}} experience rank!', Point( 12, 5 ), [ FSRName, FERName ] )
  else
    if FSRName <> ''
      then VTIG_FreeLabel( 'to {!{0}} rank!', Point( 12, 5 ), [ FSRName ] )
      else VTIG_FreeLabel( 'to {!{0}} rank!', Point( 12, 5 ), [ FERName ] );

  VTIG_FreeLabel( 'Press <{!Enter}>...', Point( 12, 7 ) );


  VTIG_End('{l<{!Enter},{!Escape}> continue}');
  if VTIG_EventCancel or VTIG_EventConfirm then
    FFinished := True;
  IO.RenderUIBackground( PointZero, FSize );
end;


function TRankUpView.IsFinished : Boolean;
begin
  Exit( FFinished );
end;

function TRankUpView.IsModal : Boolean;
begin
  Exit( True );
end;

end.

