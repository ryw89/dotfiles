#!/bin/sh

# Run as root
# chmod +x bootstrap.sh
# ./bootstrap.sh

pacman -S archlinux-keyring
pacman -Syu ansible
