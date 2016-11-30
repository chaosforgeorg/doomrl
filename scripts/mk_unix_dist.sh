#!/bin/bash
set -eu

# Call this inside doomrl src directory, after every file is
# prepared/compiled etc.
# $1 must be a version number, like '0.9.8-beta4'
# $2 must be an OS name, like 'linux' or 'freebsd'
# $3 indicates that this is version with sound if nonempty (pass empty
#    string if nosound version wanted)

VERSION="$1"
OS_NAME="$2"
IS_SOUND="$3"
shift 3

BINDIR=../bin

if [ -n "$IS_SOUND" ]; then
  SOUND_SUFFIX=''
else
  SOUND_SUFFIX='-nosound'
fi

ARCHIVE_BASE_NAME=doomrl-"$OS_NAME"-"$VERSION""$SOUND_SUFFIX"

# Prepare temp dir
DIST_TMP_PATH=/tmp/"$ARCHIVE_BASE_NAME"/

rm -Rf "$DIST_TMP_PATH"
mkdir "$DIST_TMP_PATH" "$DIST_TMP_PATH"mortem/ "$DIST_TMP_PATH"modules/ "$DIST_TMP_PATH"screenshot/ "$DIST_TMP_PATH"backup/

# Copy regular files to temp dir.
# Note: Due to default doomrl_dist.ini, sound/musis* inis are needed even for nosound version.
cp -R "$BINDIR"/doomrl.wad \
      "$BINDIR"/manual.txt \
      "$BINDIR"/version.txt \
      "$BINDIR"/unix_notes.txt \
      "$BINDIR"/colors.lua \
      "$BINDIR"/keybindings.lua \
      "$BINDIR"/sound.lua \
      "$BINDIR"/music.lua \
      "$BINDIR"/musicmp3.lua \
      "$BINDIR"/musiccdmp3.lua \
      "$DIST_TMP_PATH"

cp "$BINDIR"/config.lua "$DIST_TMP_PATH"config.lua

sed --in-place --separate -e 's|AllowHighAscii   = true|AllowHighAscii   = false|g' \
  "$DIST_TMP_PATH"config.lua

cp "$BINDIR"/mortem/'!readme.txt' "$DIST_TMP_PATH"mortem/
cp "$BINDIR"/screenshot/'!readme.txt' "$DIST_TMP_PATH"screenshot/
cp "$BINDIR"/backup/'!readme.txt' "$DIST_TMP_PATH"backup/
cp "$BINDIR"/modules/'!readme.txt' "$DIST_TMP_PATH"modules/ 

if [ -n "$IS_SOUND" ]; then
  cp -R "$BINDIR"/music \
        "$BINDIR"/wav \
        "$DIST_TMP_PATH"
fi

# clean inside
find "$DIST_TMP_PATH" -type d -name .svn -prune -exec rm -Rf '{}' ';'

# Make sure permissions are OK
find "$DIST_TMP_PATH" -type f -and -exec chmod 644 '{}' ';'
find "$DIST_TMP_PATH" -type d -and -exec chmod 755 '{}' ';'

# Copy and set permissions of executable files
install "$BINDIR"/doomrl \
        "$BINDIR"/doomrl_gnome-terminal \
        "$BINDIR"/doomrl_konsole \
        "$BINDIR"/doomrl_xterm \
        "$DIST_TMP_PATH"

# Pack ----------------------------------------

DIST_ARCHIVE_NAME="$ARCHIVE_BASE_NAME".tar.gz

pushd /tmp/ > /dev/null
tar czf "$DIST_ARCHIVE_NAME" "$ARCHIVE_BASE_NAME"
pushd > /dev/null
mv /tmp/"$DIST_ARCHIVE_NAME" .

echo 'Made '"$DIST_ARCHIVE_NAME"
