# Neovim

Plugin manager: lazy.nvim. Theme: catppuccin mocha. Plugins auto-sync on `chezmoi apply`.

## Keymaps

Leader: `\` (default, unchanged).

### Editor

| Key             | Mode | Action                                        |
|-----------------|------|-----------------------------------------------|
| `<F1>`          | n, i | Esc (so accidental F1 doesn't open `:help`)   |
| `<BS>`          | v    | Delete selection                              |
| `<` / `>`       | v    | Indent and re-select (chainable)              |
| `<leader>a`     | n    | Select all (`ggVG`)                           |
| `<leader>\`     | n    | Clear search highlight                        |
| `` <leader>` `` | n    | Re-select last visual block                   |
| `<leader>h`     | n    | Highlight word at cursor without moving       |
| `<leader>i`     | n    | Toggle invisibles (`:set list!`)              |
| `<leader>n`     | n    | Toggle relative line numbers (hybrid when on) |

### Window navigation

| Key           | Action                                                                  |
|---------------|-------------------------------------------------------------------------|
| `Alt+←/↓/↑/→` | Move between nvim splits (and out to tmux panes via vim-tmux-navigator) |

Active in normal, insert, and terminal modes — so navigation still works from inside the agent CLI terminal.

### Plugin keymaps

| Key                                | Action                                          |
|------------------------------------|-------------------------------------------------|
| `<leader>t`                        | Toggle neo-tree file explorer                   |
| `Alt+c`                            | Toggle agent CLI side panel (toggleterm)        |
| `gcc`, `gc{motion}`, `gc` (visual) | Comment.nvim                                    |
| `<C-n>`, `<C-Up>`, `<C-Down>`      | vim-visual-multi multi-cursor (plugin defaults) |
| `:Neogit`                          | Open Neogit (magit-style git UI)                |
| `:Neotree toggle`                  | Same as `<leader>t`                             |

## Plugins

Each lives under [dot_config/nvim/lua/plugins/](../dot_config/nvim/lua/plugins/) as a single-purpose spec file.

| Plugin                            | File                       | Purpose                                                     |
|-----------------------------------|----------------------------|-------------------------------------------------------------|
| `folke/lazy.nvim`                 | bootstrapped in `init.lua` | Plugin manager                                              |
| `catppuccin/nvim`                 | `colorscheme.lua`          | Mocha theme + integrations (neo-tree, gitsigns, treesitter) |
| `nvim-treesitter` (master branch) | `treesitter.lua`           | Syntax & indent                                             |
| `HiPhish/rainbow-delimiters.nvim` | `treesitter.lua`           | Colored bracket pairs                                       |
| `nvim-neo-tree/neo-tree.nvim`     | `neo-tree.lua`             | File explorer                                               |
| `nvim-lualine/lualine.nvim`       | `lualine.lua`              | Statusline (theme: `catppuccin-nvim`)                       |
| `numToStr/Comment.nvim`           | `comment.lua`              | Toggle comments                                             |
| `mg979/vim-visual-multi`          | `visual-multi.lua`         | Multi-cursor                                                |
| `lewis6991/gitsigns.nvim`         | `git.lua`                  | Gutter hunk indicators                                      |
| `NeogitOrg/neogit`                | `git.lua`                  | Magit-style git UI                                          |
| `christoomey/vim-tmux-navigator`  | `tmux-navigator.lua`       | Alt+arrow nav across splits + tmux panes                    |
| `akinsho/toggleterm.nvim`         | `toggleterm.lua`           | Agent CLI side panel via `$AGENT_CMD`                       |

### Treesitter parsers

Ensured: `lua`, `vim`, `vimdoc`, `bash`, `json`, `yaml`, `markdown`. Compilation requires a C compiler (`build-essential` on Debian, Xcode CLT on macOS — installed by `run_onchange_install-packages.sh.tmpl`).

If parsers don't appear after `chezmoi apply`, run `:TSInstallSync <lang>` once — `:TSUpdate` only updates *existing* parsers, it doesn't backfill missing ones.

### nvim-treesitter branch pin

The plugin's `master` branch is pinned because the new `main` branch dropped `nvim-treesitter.configs` (the API used in the spec). The `master` branch is archived but functional.

## Agent CLI (`$AGENT_CMD`)

`Alt+c` (in any nvim mode) toggles a vertical right-side terminal split running `$AGENT_CMD` (default `claude`, set by zsh's [.zshenv](../dot_config/zsh/dot_zshenv)). The terminal persists across toggles so the agent session continues. Override the harness per machine in `~/.config/zsh/.zshenv.local`.

Same `Alt+c` key works in tmux outside nvim (spawns a pane instead of toggling a panel).

## Options ([options.lua](../dot_config/nvim/lua/options.lua))

- **Indent**: 4 spaces (`expandtab`, `shiftwidth=4`, `softtabstop=4`, `tabstop=4`)
- **Display**: `number`, `cursorline`, `colorcolumn=80`, `nowrap`, `termguicolors`
- **Search**: `ignorecase`, `gdefault` (substitutions are global by default — add `g` to undo)
- **Editing**: `whichwrap` includes arrows, `selection=exclusive`, `mousemodel=popup`
- **Mouse**: all modes
- **Bell**: visual, not error

## Useful commands

| Command                               | Purpose                                       |
|---------------------------------------|-----------------------------------------------|
| `:Lazy`                               | Plugin manager UI                             |
| `:Lazy sync`                          | Update all plugins                            |
| `:Lazy reload <plugin>`               | Reload a single plugin after editing its spec |
| `:TSUpdate` / `:TSInstallSync <lang>` | Treesitter parser ops                         |
| `:checkhealth`                        | Diagnose providers / treesitter / runtime     |
| `:Neotree toggle`                     | File explorer                                 |
| `:Neogit`                             | Git UI                                        |

## Files

- [dot_config/nvim/init.lua](../dot_config/nvim/init.lua) — bootstraps lazy.nvim, requires options + keymaps, calls `lazy.setup`
- [dot_config/nvim/lua/options.lua](../dot_config/nvim/lua/options.lua) — global `vim.opt` settings
- [dot_config/nvim/lua/keymaps.lua](../dot_config/nvim/lua/keymaps.lua) — editor keymaps (non-plugin)
- [dot_config/nvim/lua/plugins/](../dot_config/nvim/lua/plugins/) — one file per plugin spec
- [run_onchange_after_install-nvim-plugins.sh.tmpl](../run_onchange_after_install-nvim-plugins.sh.tmpl) — auto-syncs plugins on `chezmoi apply`
