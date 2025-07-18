{$INCLUDE doomrl.inc}
program makewad;
uses Classes,SysUtils, strutils, vlog, vpkg,vdf, vutil, dfdata, idea;

var WAD         : TVDataCreator;
    EKey,DKKey  : TIDEAKey;
    KeyFile     : Text;
    Count       : Byte;
    ModuleID    : AnsiString;
    Path        : AnsiString;

const UserKey : TIdeaCryptKey = (123,111,10,12,222,90,1,8);
begin
  Logger.AddSink( TTextFileLogSink.Create( LOGDEBUG, WritePath + 'runtime.log', False ) );
  Logger.AddSink( TConsoleLogSink.Create( LOGDEBUG ) );

  EnKeyIdea(UserKey,EKey);
  DeKeyIdea(EKey,DKKey);

  WAD := TVDataCreator.Create('core.wad');
  WAD.Add('data/core/*.lua',FILETYPE_LUA,[vdfCompressed], '' );
  FreeAndNil(WAD);

  Assign(KeyFile,'dkey.inc');
  Rewrite(KeyFile);
  Write(KeyFile,'const LoveLace : TIDEAKey = ( ');
  for Count := Low(DKKey) to High(DKKey)-1 do
    Write(KeyFile,DKKey[Count],', ');
  Writeln(KeyFile,DKKey[High(DKKey)],' );');
  Close(KeyFile);

  if ParamCount < 1
    then ModuleID := 'drl'
    else ModuleID := ParamStr(1);
  begin
    Path := 'data/' + ModuleID + '/';

    WAD := TVDataCreator.Create(ModuleID+'.wad');
    WAD.SetKey( EKey );

    WAD.Add(Path+'help/*.hlp',FILETYPE_RAW,[vdfCompressed,vdfEncrypted], 'help' );

    WAD.Add(Path+'ascii/*.asc',FILETYPE_RAW,[vdfCompressed,vdfEncrypted], 'ascii' );
    WAD.Add(Path+'*.lua',FILETYPE_LUA,[vdfCompressed,vdfEncrypted], '' );
    WAD.Add(Path+'levels/**.lua',FILETYPE_LUA,[vdfCompressed,vdfEncrypted], 'levels' );
    WAD.Add(Path+'items/*.lua',FILETYPE_LUA,[vdfCompressed,vdfEncrypted], 'items' );
    WAD.Add(Path+'fonts/font*.png',FILETYPE_IMAGE,[], 'fonts' );
    WAD.Add(Path+'fonts/default',FILETYPE_RAW,[], 'fonts' );
    WAD.Add(Path+'graphics/*.png',FILETYPE_IMAGE,[], 'graphics' );
    WAD.Add(Path+'sound/*.wav',FILETYPE_RAW,[vdfCompressed], 'sound' );
    WAD.Add(Path+'music/*.ogg',FILETYPE_RAW,[], 'music' );
    WAD.Add(Path+'music/*.mp3',FILETYPE_RAW,[], 'music' );
    WAD.Add(Path+'music/*.mid',FILETYPE_RAW,[vdfCompressed], 'music' );

    FreeAndNil(WAD);
  end;
end.
