#!/bin/sh
set -eu

# Clone zsh plugins managed manually (no plugin manager). Each `git clone`
# is guarded by an existence check so the script is idempotent. Add a new
# block here when adopting another plugin; chezmoi re-runs this on any
# script-content change.

PLUGINS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins"
mkdir -p "$PLUGINS_DIR"

if [ ! -d "$PLUGINS_DIR/fzf-tab" ]; then
    git clone --depth 1 https://github.com/Aloxaf/fzf-tab "$PLUGINS_DIR/fzf-tab"
fi

if [ ! -d "$PLUGINS_DIR/zsh-autosuggestions" ]; then
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$PLUGINS_DIR/zsh-autosuggestions"
fi
