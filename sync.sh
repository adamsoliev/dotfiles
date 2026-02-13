#!/bin/bash
set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORIGINAL_DIR="$(pwd)"

echo "Syncing dotfiles from home directory..."

# Change to the dotfiles repo directory
cd "$SCRIPT_DIR"

# Copy dotfiles to repo
cp ~/.zshrc .zshrc
cp ~/.vimrc .vimrc
cp ~/.claude/CLAUDE.md CLAUDE.md

# Ensure ZSH theme is always set to "evan" in the repo
sed -i '' 's/^ZSH_THEME=".*"/ZSH_THEME="evan"/' .zshrc

# Commit and push changes
git add .zshrc .vimrc CLAUDE.md
if git diff --quiet --cached; then
    echo "No changes to commit"
    exit 0
fi

git commit -m "Update dotfiles $(date '+%Y-%m-%d %H:%M')"
git push

echo "Dotfiles synced and pushed to git"

cd "$ORIGINAL_DIR"

