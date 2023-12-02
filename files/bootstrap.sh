#!/bin/bash
#
# Run as root.

PKG_LIST=".pkgs.tmp"
REPO="https://ryanwhittingham.com/bootstrap.git"
REPO_NAME="bootstrap"

grep '-' pkg.yml | cut -d '-' -f2 | sed 's/^[[:space:]]//g' > $PKG_LIST

pacman -S --needed - < $PKG_LIST

rm $PKG_LIST

git clone $REPO $REPO_NAME
cd $REPO_NAME

ansible-playbook site.yml --ask-become-pass
