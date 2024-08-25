{$INCLUDE doomrl.inc}
program makewad;
uses Classes,SysUtils, strutils, vpkg,vdf, vutil, dfdata, idea;

var WAD         : TVDataCreator;
    EKey,DKKey  : TIDEAKey;
    KeyFile     : Text;
    Count       : Byte;

const UserKey : TIdeaCryptKey = (123,111,10,12,222,90,1,8);
begin
  WADMAKE := True;

  EnKeyIdea(UserKey,EKey);
  DeKeyIdea(EKey,DKKey);
  
  WAD := TVDataCreator.Create('drl.wad');
  WAD.SetKey( EKey );

  WAD.Add('data/drl/help/*.hlp',FILETYPE_HELP,[vdfCompressed,vdfEncrypted], 'help' );
  WAD.Add('data/drl/ascii/*.asc',FILETYPE_ASCII,[vdfCompressed,vdfEncrypted], 'ascii' );
  WAD.Add('data/drl/*.lua',FILETYPE_LUA,[vdfCompressed,vdfEncrypted], '' );
  WAD.Add('data/drl/levels/*.lua',FILETYPE_LUA,[vdfCompressed,vdfEncrypted], 'levels' );
  WAD.Add('data/drl/items/*.lua',FILETYPE_LUA,[vdfCompressed,vdfEncrypted], 'items' );
  WAD.Add('data/drl/fonts/font*.png',FILETYPE_IMAGE,[], 'fonts' );
  WAD.Add('data/drl/graphics/*.png',FILETYPE_IMAGE,[], 'graphics' );

  Assign(KeyFile,'dkey.inc');
  Rewrite(KeyFile);
  Write(KeyFile,'const LoveLace : TIDEAKey = ( ');
  for Count := Low(DKKey) to High(DKKey)-1 do
    Write(KeyFile,DKKey[Count],', ');
  Writeln(KeyFile,DKKey[High(DKKey)],' );');
  Close(KeyFile);

  FreeAndNil(WAD);

  WAD := TVDataCreator.Create('core.wad');
  WAD.Add('data/core/*.lua',FILETYPE_LUA,[vdfCompressed], '' );
  FreeAndNil(WAD);
end.
