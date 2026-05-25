# Zsh

XDG-style layout via `ZDOTDIR`: a stub at `~/.zshenv` points zsh at `~/.config/zsh/` for every other file. Prompt: starship.

## Layout

```
~/.zshenv                              # stub in $HOME — sets ZDOTDIR then sources $ZDOTDIR/.zshenv
$ZDOTDIR/.zshenv                       # env vars (loaded for ALL zsh invocations, including non-interactive)
$ZDOTDIR/.zprofile                     # login shell (homebrew shellenv, direnv hook)
$ZDOTDIR/.zshrc                        # interactive shell (history, fzf, prompt, aliases)
$ZDOTDIR/starship.toml                 # prompt config
$ZDOTDIR/plugins/fzf-tab/              # fzf-tab plugin (cloned by run_onchange_install-zsh-plugins.sh)
$ZDOTDIR/.zshrc.local                  # per-machine overrides (untracked)
$ZDOTDIR/.zshenv.local                 # per-machine env overrides (untracked)
$ZDOTDIR/.zprofile.local               # per-machine login overrides (untracked)
$ZDOTDIR/.zsh_history                  # shell history (untracked)
```

## Key bindings

| Key        | Action                                                                    |
|------------|---------------------------------------------------------------------------|
| `Ctrl+T`   | fzf file picker — insert selected path at the cursor                      |
| `Ctrl+R`   | fzf history search (replaces the default reverse-i-search)                |
| `Alt+J`    | fzf cd widget — jump to a fuzzy-picked directory                          |
| `Alt+c`    | Toggle agent CLI side panel — see [nvim.md](nvim.md) / [tmux.md](tmux.md) |
| `<Tab>`    | Completion menu rendered by fzf-tab as a fuzzy popup                      |
| `→`, `End` | Accept the full zsh-autosuggestions suggestion                            |
| `Alt+F`    | Accept the suggestion one word at a time (zsh's forward-word widget)      |
| `Ctrl+A`   | Beginning of line (works in both viins and vicmd)                         |
| `Ctrl+E`   | End of line (works in both viins and vicmd)                               |

`Alt+C` (lowercase, the fzf default for the cd widget) is intentionally unbound so the `Alt+c` agent CLI binding owns it across nvim, tmux, and zsh.

## Vi-mode editing

Zsh runs in vi-mode (`bindkey -v` in `.zshrc`, with `KEYTIMEOUT=1` for snappy Esc transitions). Starship's prompt symbol reflects the active sub-mode:

| Symbol | Mode                   | How to enter                                                     |
|--------|------------------------|------------------------------------------------------------------|
| `❯`    | viins (insert)         | Default; press `i`, `a`, `A`, `I`, `o`, `O` from vicmd to return |
| `❮`    | vicmd (normal/command) | Press `Esc` from viins                                           |

Everyday vicmd commands:

| Keys            | Action                                                |
|-----------------|-------------------------------------------------------|
| `h j k l`       | Cursor motion                                         |
| `w b e`         | Word forward / back / end                             |
| `0 $`           | Beginning / end of line (same as `Ctrl+A` / `Ctrl+E`) |
| `dd / D`        | Delete line / delete to end of line                   |
| `cc / C`        | Change line / change to end                           |
| `cw / ciw`      | Change word / change inner word                       |
| `yy / p`        | Yank line / paste                                     |
| `u / Ctrl+R`    | Undo / redo                                           |
| `v`             | Open the current command line in `$EDITOR` (nvim)     |
| `/text` `Enter` | Search command history backward                       |
| `n / N`         | Next / previous search match                          |

`Ctrl+R` (fzf history) and `Ctrl+T` (fzf file picker) work in both modes; fzf binds them in `viins` and `vicmd` explicitly.

## Plugins

| Plugin                | Install path                            | Purpose                                    |
|-----------------------|-----------------------------------------|--------------------------------------------|
| `fzf-tab`             | `$ZDOTDIR/plugins/fzf-tab/`             | Fuzzy popup for tab completion             |
| `zsh-autosuggestions` | `$ZDOTDIR/plugins/zsh-autosuggestions/` | Inline ghost-text suggestions from history |

Cloned by [run_onchange_install-zsh-plugins.sh](../run_onchange_install-zsh-plugins.sh) on `chezmoi apply`. Add more plugins by extending that script and sourcing them in `.zshrc`.

## History

Persisted under `$ZDOTDIR/.zsh_history`, 50k entries.

| Setting    | Value                   |
|------------|-------------------------|
| `HISTSIZE` | 50000                   |
| `SAVEHIST` | 50000                   |
| `HISTFILE` | `$ZDOTDIR/.zsh_history` |

setopts: `HIST_IGNORE_DUPS`, `HIST_IGNORE_ALL_DUPS`, `HIST_IGNORE_SPACE`, `HIST_REDUCE_BLANKS`, `SHARE_HISTORY`, `EXTENDED_HISTORY`, `HIST_VERIFY`.

## Environment variables

| Variable           | Default                  | Where set                               |
|--------------------|--------------------------|-----------------------------------------|
| `EDITOR`, `VISUAL` | `nvim`                   | `.zshenv`                               |
| `AGENT_CMD`        | `claude`                 | `.zshenv` — override in `.zshenv.local` |
| `STARSHIP_CONFIG`  | `$ZDOTDIR/starship.toml` | `.zshrc`                                |

## Aliases

| Alias | Expansion                                           | Notes                                |
|-------|-----------------------------------------------------|--------------------------------------|
| `ll`  | `ls -lah --color=auto` (Linux) / `ls -lahG` (macOS) | Split per platform (BSD vs GNU `-G`) |

## Other config

- **Prompt**: starship, configured via `$ZDOTDIR/starship.toml`
- **`PATH`**: prepends `$HOME/.local/bin` and `$HOME/bin` if they exist (deduplicated with `typeset -U path`)
- **direnv**: hooked in `.zprofile` (auto-loads `.envrc` per project)
- **Homebrew (macOS)**: `brew shellenv` initialised in `.zprofile`
- **Completion**: `autoload -Uz compinit && compinit` runs in `.zshrc` (required by fzf-tab). Configured via three `zstyle`s — `menu select` (arrow-key menu fallback when fzf-tab isn't in play), `matcher-list` (lowercase prefixes match uppercase candidates), `list-colors` (colorise the listing from `LS_COLORS`)
- **`LS_COLORS`**: populated via `dircolors -b` (GNU coreutils; install via `brew install coreutils` on macOS if missing) so both `ls --color=auto` and the completion listing use the same palette

## Per-machine overrides

These files are not tracked by chezmoi. Create them on a specific host:

| File                            | Purpose                              |
|---------------------------------|--------------------------------------|
| `~/.config/zsh/.zshenv.local`   | Env vars (e.g. override `AGENT_CMD`) |
| `~/.config/zsh/.zshrc.local`    | Interactive shell tweaks             |
| `~/.config/zsh/.zprofile.local` | Login-shell tweaks                   |

## Files

- [dot_zshenv](../dot_zshenv) — bootstrap stub in `$HOME` that sets `ZDOTDIR`
- [dot_config/zsh/dot_zshenv](../dot_config/zsh/dot_zshenv) — main env config
- [dot_config/zsh/dot_zprofile.tmpl](../dot_config/zsh/dot_zprofile.tmpl) — login-shell config (chezmoi template, branches on macOS)
- [dot_config/zsh/dot_zshrc](../dot_config/zsh/dot_zshrc) — interactive shell config
- [dot_config/zsh/starship.toml](../dot_config/zsh/starship.toml) — prompt config
- [run_onchange_install-zsh-plugins.sh](../run_onchange_install-zsh-plugins.sh) — clones zsh plugins on apply
