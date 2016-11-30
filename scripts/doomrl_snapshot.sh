#!/bin/bash
set -eu

# Make doomrl snapshot: svn up, clean build and pack both sound and nosound versions,
# move generated tar.gz to ~/public_html/doomrl-snapshots/...

DOOMRL_VERSION='snapshot-'`date +%F`
DOOMRL_OS_NAME='linux-i386'

# Set to non-empty to link statically with lua.
#
# This adds proper options to "make" and checks with ldd afterwards,
# but to actually make it work you also have to make sure /usr/lib/liblua*.so
# do not exist.
#
# TODO: is there any way to do it more intelligently? I was trying
# to set in lua.pas LuaDLL='', then you have to link with -k-lxxx options,
# and make 'FPCOPT=-k--export-dynamic -k-Bstatic -k-llua5.1 -k-Bdynamic'
# should work --- but it doesn't. For now use this hack.
#
LINK_LUA_STATICALLY='t'

if [ -n "$LINK_LUA_STATICALLY" ]; then
  MAKE_FPCOPT='FPCOPT=-k-lm'
else
  MAKE_FPCOPT=''
fi

# log messages and dates in english
export LANG=C
# make sure FPC and utilities is on path
export PATH=/usr/local/bin:"$PATH"

do_clean_src ()
{
  # clean doomrl and fpcvalkyrie
  find /home/epyon/src/doomrl/trunk/ \
       /home/epyon/src/fpcvalkyrie/trunk/ \
       '(' -iname '*.o' -or -iname '*.ppu' ')' -exec rm -f '{}' ';'
}

OUTPUT_PATH=~/public_html/doomrl-snapshots/`date +%F`/
mkdir -p "$OUTPUT_PATH"

OUTPUT_LOG="$OUTPUT_PATH"snapshot.log
echo 'doomrl_snapshot started at '`date` > "$OUTPUT_LOG"

# svn up doomrl and fpcvalkyrie
svn up /home/epyon/src/doomrl/trunk/ >> "$OUTPUT_LOG"
svn up /home/epyon/src/fpcvalkyrie/trunk/ >> "$OUTPUT_LOG"

cd /home/epyon/src/doomrl/trunk/src/

# compile nosound version
do_clean_src
sed --in-place --separate -e 's|{$DEFINE SOUND}|{x$DEFINE SOUND}|g' doomrl.inc
make "$MAKE_FPCOPT" >> "$OUTPUT_LOG" 2>&1

# check nosound version really not linked to SDL, SDL_mixer etc.
ldd ../bin/doomrl > /tmp/doomrl_snapshot_temp.txt
ldd ../bin/makewad >> /tmp/doomrl_snapshot_temp.txt
if grep --quiet -i SDL /tmp/doomrl_snapshot_temp.txt; then
  echo 'doomrl_snapshot: Check failed: doomrl or makewad compiled (supposedly) without SOUND are still linked to SDL lib.'
  exit 1
fi

# check nosound version really not dynamically linked to lua, if requested statically.
if [ -n "$LINK_LUA_STATICALLY" ]; then
  if grep --quiet -i lua /tmp/doomrl_snapshot_temp.txt; then
    echo 'doomrl_snapshot: Check failed: doomrl or makewad are dynamically linked to lua, but requested statically.'
    exit 1
  fi
fi

# run makewad to gen doomrl.wad
cd /home/epyon/src/doomrl/trunk/bin/
./makewad
cd /home/epyon/src/doomrl/trunk/src/

# pack nosound version
../scripts/mk_unix_dist.sh "$DOOMRL_VERSION" "$DOOMRL_OS_NAME" '' >> "$OUTPUT_LOG"

# compile sound version
do_clean_src
sed --in-place --separate -e 's|{x$DEFINE SOUND}|{$DEFINE SOUND}|g' doomrl.inc
make "$MAKE_FPCOPT" >> "$OUTPUT_LOG"  2>&1

# pack sound version
../scripts/mk_unix_dist.sh "$DOOMRL_VERSION" "$DOOMRL_OS_NAME" 't' >> "$OUTPUT_LOG"

# now that we created tar.gz packages, move them to appropriate directory at ~/public_html/doomrl-snapshots/
mv -f doomrl-"$DOOMRL_OS_NAME"-"$DOOMRL_VERSION".tar.gz \
      doomrl-"$DOOMRL_OS_NAME"-"$DOOMRL_VERSION"-nosound.tar.gz \
      "$OUTPUT_PATH"

# Clean old snapshots, to conserve disk space.
# Keep only snapshots from last couple of days.
cd ~/public_html/doomrl-snapshots/
set +e
find . -mindepth 1 -maxdepth 1 \
  -type d -and \
  -name '????-??-??' -and \
  '(' -not -iname `date +%F` ')' -and \
  '(' -not -iname `date --date='-1 day' +%F` ')' -and \
  '(' -not -iname `date --date='-2 day' +%F` ')' -and \
  '(' -not -iname `date --date='-3 day' +%F` ')' -and \
  '(' -not -iname `date --date='-4 day' +%F` ')' -and \
  '(' -not -iname `date --date='-5 day' +%F` ')' -and \
  '(' -not -iname `date --date='-6 day' +%F` ')' -and \
  '(' -not -iname `date --date='-7 day' +%F` ')' -and \
  -exec rm -Rf '{}' ';'
set -e

# Create "latest" link.
rm -f ~/public_html/doomrl-snapshots/latest
ln -s `date +%F` ~/public_html/doomrl-snapshots/latest
