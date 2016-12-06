{$INCLUDE doomrl.inc}
program drlwad;
uses Classes, SysUtils, strutils, vpkg, vdf, vutil, dfdata, doommodule;

var WAD         : TVDataCreator;
    ModuleID    : AnsiString;
    Path        : AnsiString;
    ModuleFile  : AnsiString;

begin
  if ParamCount < 1 then
  begin
    Writeln( 'DoomRL WAD Creator, Copyright (c) ChaosForge.org' );
    Writeln( 'Usage : drlwad [module_id]' );
    Halt(0);
  end;

  ModuleID := ParamStr(1);
  Path     := 'modules' + DirectorySeparator + ModuleID + '.module';

  if not DirectoryExists( Path ) then
  begin
    Writeln( 'Bad module ID "'+ModuleID+'" - directory '+Path+' doesn''t exists!' );
    Halt(1);
  end;
  Writeln( 'Compiling module "'+ModuleID+'"...' );

  ModuleFile := 'modules' + DirectorySeparator + ModuleID + '.wad';

  if FileExists( ModuleFile ) then DeleteFile( ModuleFile );

  WADMAKE := True;
  WAD := TVDataCreator.Create(ModuleFile);

  WAD.Add(Path+'/*.lua',FILETYPE_LUA,[vdfCompressed], '' );
  WAD.Add(Path+'/data/*.lua',FILETYPE_LUA,[vdfCompressed], 'data' );
  WAD.Add(Path+'/ascii/*.asc',FILETYPE_ASCII,[vdfCompressed], 'ascii' );
  WAD.Add(Path+'/music/*.mid',FILETYPE_MUSIC,[], 'music' );
  WAD.Add(Path+'/music/*.mp3',FILETYPE_MUSIC,[], 'music' );
  WAD.Add(Path+'/music/*.ogg',FILETYPE_MUSIC,[], 'music' );
  WAD.Add(Path+'/sound/*.wav',FILETYPE_SOUND,[], 'sound' );

  FreeAndNil(WAD);
  Writeln( 'Done.' );
end.
