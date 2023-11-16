#!/bin/sh
#
# Run as root.

PKG_LIST=".pkgs.tmp"

grep '-' pkg.yml | cut -d '-' -f2 | sed 's/^[[:space:]]//g' > $PKG_LIST

pacman -S --needed - < $PKG_LIST

rm $PKG_LIST
