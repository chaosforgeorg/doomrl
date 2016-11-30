#!/bin/bash
set -eu

# $1 must be a version number, like '098-beta4'

VERSION="$1"
shift 1

BINDIR=bin

#if [ -n "$IS_SOUND" ]; then
#  SOUND_SUFFIX=''
#else
#  SOUND_SUFFIX='-nosound'
#fi

BIN_BASE_NAME=doomrl-win-"$VERSION"
SRC_BASE_NAME=doomrl-win-"$VERSION"-src

# Prepare temp dir
DIST_TMP_PATH=pkg/"$BIN_BASE_NAME"/

rm -Rf "$DIST_TMP_PATH"
/bin/mkdir "$DIST_TMP_PATH" "$DIST_TMP_PATH"mortem/ "$DIST_TMP_PATH"screenshot/ "$DIST_TMP_PATH"music/ "$DIST_TMP_PATH"wav/

# Copy regular files to temp dir
cp -R "$BINDIR"/doomrl.wad \
      "$BINDIR"/manual.txt \
      "$BINDIR"/version.txt \
      "$BINDIR"/doomrl.bat \
      "$BINDIR"/doomrl.exe \
      "$DIST_TMP_PATH"

cp "$BINDIR"/doomrl_dist.ini "$DIST_TMP_PATH"doomrl.ini
cp "$BINDIR"/sound.ini "$DIST_TMP_PATH"sound.ini
cp "$BINDIR"/music.ini "$DIST_TMP_PATH"music.ini
cp "$BINDIR"/musicmp3.ini "$DIST_TMP_PATH"musicmp3.ini

cp -R "$BINDIR"/music/*.mid "$DIST_TMP_PATH"/music
cp -R "$BINDIR"/wav/*.wav "$DIST_TMP_PATH"/wav

cp -R "$BINDIR"/*.dll "$DIST_TMP_PATH"
     
cp "$BINDIR"/mortem/'!readme.txt' "$DIST_TMP_PATH"mortem/
cp "$BINDIR"/screenshot/'!readme.txt' "$DIST_TMP_PATH"screenshot/

#if [ -n "$IS_SOUND" ]; then
#  cp -R "$BINDIR"/music \
#        "$BINDIR"/wav \
 #       "$DIST_TMP_PATH"
#fi

# Make sure permissions are OK
#find "$DIST_TMP_PATH" -type f -and -exec chmod 644 '{}' ';'
#find "$DIST_TMP_PATH" -type d -and -exec chmod 755 '{}' ';'

# Copy and set permissions of executable files
#install "$BINDIR"/doomrl \
#        "$BINDIR"/doomrl_gnome-terminal \
#        "$BINDIR"/doomrl_konsole \
#        "$BINDIR"/doomrl_xterm \
#        "$DIST_TMP_PATH"

# Pack ----------------------------------------

DIST_ARCHIVE_NAME="$BIN_BASE_NAME".zip

cd pkg
rm -f "$DIST_ARCHIVE_NAME"
zip -r "$DIST_ARCHIVE_NAME" "$BIN_BASE_NAME" 
cd .. 

#tar czf "$DIST_ARCHIVE_NAME" "$ARCHIVE_BASE_NAME"
#pushd > /dev/null
cp pkg/"$DIST_ARCHIVE_NAME" .

echo 'Made '"$DIST_ARCHIVE_NAME"