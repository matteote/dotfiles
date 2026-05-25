# Dotfiles

Personal environment configuration managed with [chezmoi](https://www.chezmoi.io/), synced across Debian and macOS machines.

## chezmoi conventions

Source files in this repo follow chezmoi's [naming conventions](https://www.chezmoi.io/reference/source-state-attributes/):

- `dot_foo` → `~/.foo` (chezmoi strips the `dot_` prefix on apply)
- `private_` → file is given mode `0600`
- `executable_` → file is given mode `0755`
- `run_` → script executed by `chezmoi apply` (`run_once_`, `run_onchange_` for variants)
- `.tmpl` suffix → file is rendered as a Go template; use `{{ .chezmoi.os }}` for OS-specific branching
- `.chezmoiignore` → patterns to skip; supports template syntax for per-OS exclusions
- `.chezmoidata.<ext>` → variables exposed to templates

Edit source files in this repo directly, then run `chezmoi apply` on the target machine — do **not** edit the rendered files in `$HOME`.

## Cross-platform guidance

- This config must work on both Debian and macOS. When adding tooling, prefer cross-platform options or gate OS-specific bits with templates (`{{ if eq .chezmoi.os "darwin" }}`) or `.chezmoiignore`.
- Package install lists belong in `run_onchange_` scripts (e.g. apt for Debian, brew for macOS), keyed so chezmoi re-runs them when the list changes.

## Layout conventions

- **zsh uses `ZDOTDIR`**: `~/.zshenv` is a stub that sets `ZDOTDIR=$HOME/.config/zsh`; all other zsh config (`.zshrc`, future `.zprofile`, plugins, history) lives under `~/.config/zsh/`. The stub must stay in `$HOME` because zsh reads it before learning about `ZDOTDIR`. Source paths: `dot_zshenv` and `dot_config/zsh/dot_*`.
- New tools should follow the same XDG-style pattern when they support it — keep `$HOME` clean.

## Workflow

- `chezmoi apply` — render source → home directory
- `chezmoi diff` — preview changes before applying
- `chezmoi cd` — drop into this repo from anywhere
- `chezmoi re-add` — pull edits made directly in `$HOME` back into the source
