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
  
  WAD := TVDataCreator.Create('doomrl.wad');
  WAD.SetKey( EKey );

  WAD.Add('help/*.hlp',FILETYPE_HELP,[vdfCompressed,vdfEncrypted], 'ascii' );
  WAD.Add('help/*.asc',FILETYPE_ASCII,[vdfCompressed,vdfEncrypted], 'ascii' );
  WAD.Add('help/logo.dat', FILETYPE_ASCII, [vdfCompressed,vdfEncrypted], 'ascii' );
  WAD.Add('lua/*.lua',FILETYPE_LUA,[vdfCompressed,vdfEncrypted], '' );
  WAD.Add('lua/levels/*.lua',FILETYPE_LUA,[vdfCompressed,vdfEncrypted], 'levels' );
  WAD.Add('lua/items/*.lua',FILETYPE_LUA,[vdfCompressed,vdfEncrypted], 'items' );
  WAD.Add('font*.png',FILETYPE_IMAGE,[], 'fonts' );
  WAD.Add('graphics/*.png',FILETYPE_IMAGE,[], 'graphics' );
  WAD.Add('graphics/doom.ini', FILETYPE_ASCII, [], '' );
  WAD.Add('graphics/message.xml', FILETYPE_FONT, [], '' );

  Assign(KeyFile,'dkey.inc');
  Rewrite(KeyFile);
  Write(KeyFile,'const LoveLace : TIDEAKey = ( ');
  for Count := Low(DKKey) to High(DKKey)-1 do
    Write(KeyFile,DKKey[Count],', ');
  Writeln(KeyFile,DKKey[High(DKKey)],' );');
  Close(KeyFile);

  FreeAndNil(WAD);

  WAD := TVDataCreator.Create('core.wad');
  WAD.Add('core/*.lua',FILETYPE_LUA,[vdfCompressed], '' );
  FreeAndNil(WAD);
end.
