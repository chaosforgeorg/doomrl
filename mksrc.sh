#!/bin/bash
set -eu

# $1 must be a version number, like '098-beta4'

VERSION="$1"
shift 1

BINDIR=bin
SRCDIR=src

#if [ -n "$IS_SOUND" ]; then
#  SOUND_SUFFIX=''
#else
#  SOUND_SUFFIX='-nosound'
#fi

SRC_BASE_NAME=doomrl-win-"$VERSION"-src
# Prepare temp dir
DIST_TMP_PATH=pkg/"$SRC_BASE_NAME"/



rm -Rf "$DIST_TMP_PATH"
/bin/mkdir "$DIST_TMP_PATH"  "$DIST_TMP_PATH"bin/  "$DIST_TMP_PATH"src/ "$DIST_TMP_PATH"bin/mortem/ "$DIST_TMP_PATH"bin/screenshot/ 

# Copy regular files to temp dir
cp -R "$BINDIR"/doomrl.wad \
      "$BINDIR"/manual.txt \
      "$BINDIR"/version.txt \
      "$BINDIR"/doomrl.bat \
      "$DIST_TMP_PATH"bin

cp "$BINDIR"/doomrl_dist.ini "$DIST_TMP_PATH"bin/doomrl.ini
 
cp -R "$BINDIR"/music \
      "$BINDIR"/wav \
      "$BINDIR"/data \
      "$BINDIR"/lua \
      "$BINDIR"/helpunzi \
      "$DIST_TMP_PATH"bin

cp -R "$SRCDIR"/*.pas "$DIST_TMP_PATH"src
cp -R "$SRCDIR"/*.inc "$DIST_TMP_PATH"src
cp -R "$SRCDIR"/*.lpi "$DIST_TMP_PATH"src
cp -R "$SRCDIR"/*.sh "$DIST_TMP_PATH"src
cp -R "$SRCDIR"/Makefile "$DIST_TMP_PATH"src
     
cp "$BINDIR"/mortem/'!readme.txt' "$DIST_TMP_PATH"bin/mortem/
cp "$BINDIR"/screenshot/'!readme.txt' "$DIST_TMP_PATH"bin/screenshot/

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

DIST_ARCHIVE_NAME="$SRC_BASE_NAME".zip

cd pkg
rm -f "$DIST_ARCHIVE_NAME"
zip -r "$DIST_ARCHIVE_NAME" "$SRC_BASE_NAME" 
cd .. 

#tar czf "$DIST_ARCHIVE_NAME" "$ARCHIVE_BASE_NAME"
#pushd > /dev/null
cp pkg/"$DIST_ARCHIVE_NAME" .

echo 'Made '"$DIST_ARCHIVE_NAME"