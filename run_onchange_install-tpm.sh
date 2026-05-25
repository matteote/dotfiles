#!/bin/sh
set -eu

TPM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
