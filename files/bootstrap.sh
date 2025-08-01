#!/bin/bash
#
# Run as root to handle the pacman command.

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

PKG_LIST=".pkgs.tmp"
REPO="https://my-website.com/bootstrap.git"
REPO_NAME="bootstrap"
LOGGED_IN_USER="$(logname)" # Get the name of the user who invoked sudo

# Parse the YAML file to get only the bootstrap packages.
# The sed script prints lines between 'bootstrap_pkg:' and the next blank line.
sed -n '/bootstrap_pkg:/,/^extra_pkg:/p' pkg.yml \
  | grep ' - ' \
  | sed 's/^ * - //g' > "$PKG_LIST"

# Install packages with pacman
pacman -S --needed - < "$PKG_LIST"

# Clean up the temporary package list
rm "$PKG_LIST"

# --- Drop sudo privileges and continue as the original user ---
# This executes the rest of the script as a normal user.
sudo -u "$LOGGED_IN_USER" bash << EOF
    git clone $REPO $REPO_NAME
    cd $REPO_NAME
    
    # Your `ansible-playbook` command would go here.
    echo "Now running as user: \$(whoami)"
EOF

