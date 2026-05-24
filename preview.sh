#!/bin/bash
selection="$1"
CACHE_DIR="/tmp/package_updates"

if [ "$selection" = "all (update all package managers)" ]; then
    cat "$CACHE_DIR/all"
else
    pkgmgr=$(echo "$selection" | cut -d '(' -f1 | sed 's/ *$//')
    cat "$CACHE_DIR/$pkgmgr" 2>/dev/null || echo "No updates found for $pkgmgr"
fi
