#!/usr/bin/env bash
# Update plugins in a controlled, reproducible manner
# Similar to 'nix flake update' workflow

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCKFILE="$SCRIPT_DIR/lazy-lock.json"
LOCKFILE_BACKUP="$SCRIPT_DIR/lazy-lock.json.backup"

echo "=== Kickstart.nvim Plugin Updater ==="
echo ""

# Check if lockfile exists
if [ ! -f "$LOCKFILE" ]; then
  echo "ERROR: lazy-lock.json not found at $LOCKFILE"
  echo "Run: nvim --headless -c 'luafile generate-lockfile.lua' -c 'qa' to create it"
  exit 1
fi

# Backup current lockfile
echo "1. Backing up current lockfile..."
cp "$LOCKFILE" "$LOCKFILE_BACKUP"
echo "   Backup saved to: $LOCKFILE_BACKUP"
echo ""

# Update plugins using lazy.nvim
echo "2. Updating plugins via lazy.nvim..."
nvim --headless -c "Lazy sync" -c "qa" 2>&1 | grep -v "^$" || true
echo ""

# Regenerate lockfile with new versions
echo "3. Regenerating lockfile with updated commit hashes..."
nvim --headless -c "luafile $SCRIPT_DIR/generate-lockfile.lua" -c "qa" 2>&1 | tail -2
echo ""

# Show diff if available
if command -v git &> /dev/null; then
  echo "4. Changes to lockfile:"
  echo ""
  git diff --no-index --color=always "$LOCKFILE_BACKUP" "$LOCKFILE" || true
  echo ""
else
  echo "4. Git not found, skipping diff display"
  echo ""
fi

# Prompt for confirmation
echo "=== Update Summary ==="
echo ""
read -p "Do you want to keep these changes? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo ""
  echo "✓ Lockfile updated successfully!"
  echo ""
  echo "Next steps:"
  echo "  1. Review the changes: cat $LOCKFILE"
  echo "  2. Test your config: nvim"
  echo "  3. Commit the changes: jj commit -m 'chore: update nvim plugins'"
  echo ""
  echo "To revert: mv $LOCKFILE_BACKUP $LOCKFILE"
else
  echo ""
  echo "✗ Reverting changes..."
  mv "$LOCKFILE_BACKUP" "$LOCKFILE"
  echo "  Lockfile restored to previous state"
  echo ""
fi

echo "Done!"
