#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root to perform privileged tasks."
    exit 1
fi

# Get the name of the original user who invoked sudo.
# We need this to drop privileges later.
LOGGED_IN_USER="$(logname)"

# Define variables needed in the privileged section.
PKG_LIST="/tmp/.pkgs.tmp"
YAML_FILE="pkg.yml"

# Install git, since we know it's needed.
which git >/dev/null || pacman -S --noconfirm --needed git

# Define a function to be executed as the user.
# All unprivileged commands go inside this function.
git_clone() {
    echo "Now running as user: $(whoami)"

    # Define variables inside the function for clean scope.
    local REPO="https://github.com/ryw89/dotfiles.git"
    local REPO_NAME="dotfiles"

	# Use a regex that is agnostic to the protocol, matching both
    # "github.com/..." (HTTPS) and "github.com:..." (SSH).
	local REPO_PATTERN="${REPO#*github.com/}"
	
    # Check if we are already in the correct git repository.
    # The `grep -q` will return a 0 exit code if the remote is found.
    # The `2>/dev/null` suppresses any git errors if this is not a repo.
    if git remote -v 2>/dev/null | grep -q "$REPO_PATTERN"; then
        echo "Already in the repository. Skipping git clone and directory change."
    else
        # Git clone and directory change.
        git clone "$REPO" "$REPO_NAME"
        cd "$REPO_NAME"
    fi

	echo "Unprivileged tasks are complete; switching back to root."
}

# Run ansible-playbook
ansible_playbook() {
	echo "Now running as user: $(whoami)"

	# Jumping to root directory to run the playbok
	cd $(git rev-parse --show-toplevel 2>/dev/null)
	local ANSIBLE_CMD="ansible-playbook -i localhost site.yml --ask-become-pass"
	echo "Now running: $ANSIBLE_CMD"
	eval "$ANSIBLE_CMD"
}

# Use `sudo -u` to switch to the original user and run the function.
sudo -u "$LOGGED_IN_USER" bash -c "$(declare -f git_clone); git_clone"

# Parse minimal bootstrap package list.
GIT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
YAML_FILE="$GIT_ROOT/group_vars/all.yml"
sed -n '/_minimal_bootstrap_pkg:/,/:/p' "$YAML_FILE" \
    | grep ' - ' \
    | sed 's/^ * - //g' > "$PKG_LIST"

# Install the packages parsed from the YAML file.
pacman -S --noconfirm --needed - < "$PKG_LIST"

# Clean up the temporary package list file.
rm -f "$PKG_LIST"

# Finish bootstrapping with Ansible playbook.
sudo -u "$LOGGED_IN_USER" bash -c "$(declare -f ansible_playbook); ansible_playbook"

echo "Bootstrap script complete."
