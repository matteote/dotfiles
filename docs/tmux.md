# Tmux

Theme: catppuccin mocha. Plugin manager: TPM. Default-shell pinned to zsh.

## Keybindings

Prefix: `C-b` (default, unchanged).

| Key           | Action                                                                    |
|---------------|---------------------------------------------------------------------------|
| `Alt+←/↓/↑/→` | Move between panes (forwards to nvim splits when nvim owns the pane)      |
| `Alt+c`       | Open agent CLI in right-side split (forwards to nvim when nvim is active) |
| `Alt+Shift+H` | Toggle the active-pane background tint                                    |
| `prefix + \|` | Split horizontally, inheriting cwd                                        |
| `prefix + -`  | Split vertically, inheriting cwd                                          |
| `prefix + I`  | Install TPM plugins (also auto-runs on `chezmoi apply`)                   |
| `prefix + [`  | Enter copy mode (vi keys; `Alt+arrows` still move panes from here)        |

Non-prefix bindings use `bind -n`. The vim-aware forwarding for `Alt+←/↓/↑/→` and `Alt+c` is gated on a shell test against the pane's process (`is_vim` helper).

## Plugins (TPM)

| Plugin                       | Purpose                                                                |
|------------------------------|------------------------------------------------------------------------|
| `tmux-plugins/tpm`           | Plugin manager                                                         |
| `tmux-plugins/tmux-sensible` | Sensible defaults (`escape-time 0`, `focus-events on`, bigger history) |
| `catppuccin/tmux#v2.1.3`     | Theme — status bar, window list, palette variables                     |

Installed location: `~/.config/tmux/plugins/`. `chezmoi apply` re-runs `tpm/bin/install_plugins` automatically whenever `tmux.conf.tmpl` changes (see [run_onchange_after_install-tmux-plugins.sh.tmpl](../run_onchange_after_install-tmux-plugins.sh.tmpl)).

## Status bar

- **Left**: empty
- **Right**: application name · session · date/time (`%Y-%m-%d %H:%M`)
- Catppuccin flavour: mocha; window-status style: rounded

## Pane styling (catppuccin palette)

After TPM sources catppuccin, the following pull from its variables:

| Option                     | Value                          | Notes                                                  |
|----------------------------|--------------------------------|--------------------------------------------------------|
| `window-style`             | `bg=@thm_bg`                   | Catppuccin base for inactive panes                     |
| `window-active-style`      | (unset by default)             | Toggle on/off with `Alt+Shift+H` → `bg=@thm_surface_0` |
| `pane-border-style`        | `fg=@thm_overlay_0,bg=@thm_bg` | Inactive borders                                       |
| `pane-active-border-style` | `fg=@thm_lavender,bg=@thm_bg`  | Active border                                          |

## Other options

- `mouse on` — click-to-focus, drag-resize, scroll into copy mode; hold Shift to bypass tmux for native terminal selection
- `base-index 1`, `pane-base-index 1`, `renumber-windows on` — start indexes at 1 and keep them gap-free
- `default-terminal screen-256color` + `xterm-256color:RGB` for true colour
- `default-shell` pinned to `$(which zsh)` at chezmoi-apply time
- TPM plugins under XDG via `TMUX_PLUGIN_MANAGER_PATH=~/.config/tmux/plugins/`
- `escape-time 0`, `focus-events on`, `history-limit 50000` — applied by `tmux-sensible`

## Agent CLI (`$AGENT_CMD`)

`Alt+c` outside nvim spawns `$AGENT_CMD` in a right split. `$AGENT_CMD` is exported by zsh's [.zshenv](../dot_config/zsh/dot_zshenv) with default `claude`; override per machine by setting it in `~/.config/zsh/.zshenv.local`.

Tmux's argument parser expands `${VAR}` itself and doesn't understand the POSIX `:-default` idiom, so the binding uses bare `$AGENT_CMD` — relying on zsh to guarantee the variable is set.

## Reloading

```sh
tmux source-file ~/.config/tmux/tmux.conf
```

## Files

- [dot_config/tmux/tmux.conf.tmpl](../dot_config/tmux/tmux.conf.tmpl) — main config (chezmoi template)
- [run_onchange_install-tpm.sh](../run_onchange_install-tpm.sh) — installs TPM if missing
- [run_onchange_after_install-tmux-plugins.sh.tmpl](../run_onchange_after_install-tmux-plugins.sh.tmpl) — auto-installs TPM plugins on config changes
