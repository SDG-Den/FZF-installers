#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Define the list of package managers and their corresponding commands
declare -A pkg_managers=(
    ["apk-install.sh"]="apk --version"
    ["apt-install.sh"]="apt --version"
    ["aur-install.sh"]="yay --version"
    ["brew-install.sh"]="brew --version"
    ["dnf-install.sh"]="dnf --version"
    ["emerge-install.sh"]="emerge --version"
    ["equo-install.sh"]="equo --version"
    ["flatpak-install.sh"]="flatpak --version"
    ["guix-install.sh"]="guix --version"
    ["nix-env-install.sh"]="nix-env --version"
    ["nix-shell-install.sh"]="nix-shell --version"
    ["opkg-install.sh"]="opkg --version"
    ["pac-install.sh"]="pacman --version"
    ["slackpkg-install.sh"]="slackpkg --version"
    ["snap-install.sh"]="snap --version"
    ["swupd-install.sh"]="swupd --version"
    ["taz-install.sh"]="tazpkg --version"
    ["xbps-install.sh"]="xbps-query --version"
    ["yum-install.sh.sh"]="yum --version"
    ["zypper-install.sh.sh"]="zypper --version"
    ["conda-install.sh"]="conda --version"
    ["cargo-install.sh"]="cargo --version"
    ["composer-install.sh"]="composer --version"
    ["gem-install.sh"]="gem --version"
    ["pip-install.sh"]="pip --version"
    ["pnpm-install.sh"]="pnpm --version"
)

# Check which package managers are available
available_pkg_managers=()
for cmd in "${!pkg_managers[@]}"; do
    if command -v "${pkg_managers[$cmd]%% *}" &> /dev/null; then
        available_pkg_managers+=("$cmd")
    fi
done

# Exit if no package managers are available
if [ ${#available_pkg_managers[@]} -eq 0 ]; then
    echo "No supported package managers found on this system."
    exit 1
fi

# Use fzf to present a selectable menu
selected_cmd=$(printf "%s\n" "${available_pkg_managers[@]}" | fzf --prompt="Select a package manager: ")

# Exit if no selection is made
if [ -z "$selected_cmd" ]; then
    echo "No package manager selected."
    exit 0
fi

# Execute the selected command
echo "Running: $selected_cmd"
$SCRIPT_DIR/"$selected_cmd" "${@:1}"