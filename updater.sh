#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CACHE_DIR="/tmp/package_updates"
mkdir -p "$CACHE_DIR"

# Clear previous cache
rm -f "$CACHE_DIR"/*

# Create all cache file
ALL_CACHE="$CACHE_DIR/all"
echo "Updates for all package managers:" > "$ALL_CACHE"
echo "=================================" >> "$ALL_CACHE"

# Load package managers definitions
pkg_managers=$(cat "$SCRIPT_DIR/defs.list")

# Function to check for updates for a package manager
check_updates() {
    local pkgmgr="$1"
    local update_check_cmd="$2"
    local update_all_cmd="$3"
    local cache_file="$CACHE_DIR/$pkgmgr"

    # Extract the first command to check if it exists
    local check_cmd=$(echo "$update_check_cmd" | awk '{print $1}' | cut -d ';' -f 1)
    if ! command -v "$check_cmd" &> /dev/null; then
        echo >&2 "  [SKIP] $pkgmgr: $check_cmd not found."
        return 1
    fi

    echo >&2 "  [CHECK] $pkgmgr: Running '$update_check_cmd'..."
    # Run the update check command and capture output to cache file
    echo "=== $pkgmgr ===" > "$cache_file"
    echo "Command: $update_check_cmd" >> "$cache_file"
    echo "---------------------------------" >> "$cache_file"
    local updates=$(eval "$update_check_cmd" 2>&1 | tee -a "$cache_file" | tee -a "$ALL_CACHE")
    local count=$(grep -v "^$" "$cache_file" | wc -l)
    count=$((count - 3))  # Subtract the header lines we added

    # If there are updates, return just the package manager and count
    if [ "$count" -gt 0 ]; then
        echo >&2 "  [FOUND] $pkgmgr: $count updates available."
        echo "$pkgmgr:$count"
    else
        echo >&2 "  [OK] $pkgmgr: No updates available."
    fi
}

echo "Checking for updates across all package managers..."
echo "--------------------------------------------------"

# Check which package managers are available and have updates
updates_info=""
while IFS= read -r entry; do
    pkgmgr=$(echo "$entry" | cut -d '^' -f 1)
    update_check_cmd=$(echo "$entry" | cut -d '^' -f 2)
    update_all_cmd=$(echo "$entry" | cut -d '^' -f 3)

    # Check for updates
    result=$(check_updates "$pkgmgr" "$update_check_cmd" "$update_all_cmd")
    if [ -n "$result" ]; then
        updates_info="$updates_info$result"$'\n'
    fi
done <<< "$pkg_managers"

echo "--------------------------------------------------"

# Exit if no package managers with updates are found
if [ -z "$updates_info" ]; then
    echo "No updates available for any package manager."
    exit 0
fi

# Prepare the FZF menu items (only package managers with updates)
menu_items=""
while IFS= read -r info; do
    pkgmgr=$(echo "$info" | cut -d ':' -f 1)
    count=$(echo "$info" | cut -d ':' -f 2)
    menu_items="$menu_items$pkgmgr ($count updates)"$'\n'
done <<< "$updates_info"

# Add the "all" option separately
menu_items="$menu_items""all (update all package managers)"$'\n'

# Create preview script
preview_script="$SCRIPT_DIR/preview.sh"
cat > "$preview_script" << 'EOF'
#!/bin/bash
selection="$1"
CACHE_DIR="/tmp/package_updates"

if [ "$selection" = "all (update all package managers)" ]; then
    cat "$CACHE_DIR/all"
else
    pkgmgr=$(echo "$selection" | cut -d '(' -f1 | sed 's/ *$//')
    cat "$CACHE_DIR/$pkgmgr" 2>/dev/null || echo "No updates found for $pkgmgr"
fi
EOF
chmod +x "$preview_script"

# Use FZF to present the menu with full terminal and preview
echo "Select a package manager to update:"
selected_cmd=$(printf "%s" "$menu_items" | fzf --prompt="Select a package manager to update: " \
    --height=100% \
    --preview-window=right:60%:wrap \
    --preview="$preview_script {}")

echo "Selected: $selected_cmd"

# Exit if no selection is made
if [ -z "$selected_cmd" ]; then
    echo "No package manager selected."
    exit 0
fi

# Handle the selection
MANAGER=$(echo "$selected_cmd" | cut -d '(' -f1 | sed 's/ *$//')

if [ "$MANAGER" = "all" ]; then
    echo "Updating all package managers..."
    while IFS= read -r info; do
        pkgmgr=$(echo "$info" | cut -d ':' -f 1)
        # Get the update command from the original definitions
        entry=$(echo "$pkg_managers" | grep "^$pkgmgr^")
        update_all_cmd=$(echo "$entry" | cut -d '^' -f 3)
        echo "Running for $pkgmgr: $update_all_cmd"
        # eval "$update_all_cmd"  # Disabled for testing
    done <<< "$updates_info"
else
    # Find the corresponding entry and get the update command
    entry=$(echo "$pkg_managers" | grep "^$MANAGER^")
    update_all_cmd=$(echo "$entry" | cut -d '^' -f 3)
    echo "Running for $MANAGER: $update_all_cmd"
    eval "$update_all_cmd"  # Disabled for testing
fi