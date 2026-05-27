#!/usr/bin/env bash
# Runs inside a test VM. Installs chezmoi (if missing), applies the
# repo synced to ~/dotfiles, then runs smoke checks and reports.
#
# Intentionally not `set -e`: we want every check to run and produce a
# single PASS/FAIL summary at the end.
set -u

results=()  # "PASS: <name>" or "FAIL: <name> — <reason>"

record_pass() { results+=("PASS: $1"); }
record_fail() { results+=("FAIL: $1 — $2"); }

step() { printf '\n=== %s ===\n' "$*"; }

check() {
    local name=$1
    shift
    local out rc
    out=$("$@" 2>&1)
    rc=$?
    if ((rc == 0)); then
        record_pass "$name"
    else
        record_fail "$name" "exit $rc${out:+: ${out//$'\n'/ }}"
    fi
}

uname_s=$(uname -s)

step "Bootstrap prerequisites (curl needed to install chezmoi)"
if [[ $uname_s == Linux ]] && ! command -v curl >/dev/null 2>&1; then
    sudo apt-get update -qq
    sudo apt-get install -y curl
fi

step "Ensure chezmoi installed"
if ! command -v chezmoi >/dev/null 2>&1; then
    sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi
export PATH="$HOME/.local/bin:$PATH"
command -v chezmoi || { echo "chezmoi not on PATH after install"; exit 2; }

step "Apply chezmoi from ~/dotfiles"
# `chezmoi apply --source` is used instead of `chezmoi init --apply`
# because `init` invokes git, which on macOS is a stub that triggers
# Xcode Command Line Tools install (unavailable in a GUI-less ssh).
if chezmoi apply --source "$HOME/dotfiles"; then
    record_pass "chezmoi apply"
else
    record_fail "chezmoi apply" "non-zero exit"
fi

step "Smoke checks"

# Default shell is zsh.
case "$uname_s" in
    Linux)
        if getent passwd "$USER" | grep -q '/zsh$'; then
            record_pass "default shell is zsh"
        else
            record_fail "default shell is zsh" "getent shows $(getent passwd "$USER" | cut -d: -f7)"
        fi
        ;;
    Darwin)
        cur=$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')
        if [[ $cur == */zsh ]]; then
            record_pass "default shell is zsh"
        else
            record_fail "default shell is zsh" "dscl shows $cur"
        fi
        ;;
esac

# Tools on PATH inside a fresh login zsh (so brew shellenv runs).
for tool in brew starship tmux nvim direnv fzf mc; do
    if zsh -lc "command -v $tool" >/dev/null 2>&1; then
        record_pass "$tool on PATH"
    else
        record_fail "$tool on PATH" "command -v failed"
    fi
done

check "nvim --headless +qa"  zsh -lc 'nvim --headless +qa'
check "tmux -V"              zsh -lc 'tmux -V'

# Plugin/data directories.
for dir in \
    "$HOME/.config/zsh/plugins/zsh-autosuggestions" \
    "$HOME/.config/zsh/plugins/fzf-tab" \
    "$HOME/.config/tmux/plugins/tpm" \
    "$HOME/.local/share/nvim/lazy/lazy.nvim"
do
    if [[ -d $dir ]]; then
        record_pass "dir $dir"
    else
        record_fail "dir $dir" "not found"
    fi
done

step "Summary"
pass=0
fail=0
for r in "${results[@]}"; do
    printf '%s\n' "$r"
    if [[ $r == PASS:* ]]; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
    fi
done
total=$((pass + fail))
printf '\n=== %d/%d passed ===\n' "$pass" "$total"

((fail == 0))
