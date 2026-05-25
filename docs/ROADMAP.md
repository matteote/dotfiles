# Roadmap

Candidate additions to evaluate one at a time. Nothing here is implemented yet; pick and choose as needed.

> Note: this lives under `docs/` which is already in [.chezmoiignore](../.chezmoiignore), so it stays a repo-only artifact.

---

## Tmux

### tmux-yank

**Use case.** When you select text in tmux copy mode — a command's output, an error message, a file path — by default it only lands in tmux's internal paste buffer. To paste into a browser, chat, or another app, you'd have to use shift-drag (terminal-native selection) or pipe through `pbcopy` / `xclip` manually. tmux-yank wires the system clipboard into copy mode so a yank in tmux is immediately available everywhere.

**Key bindings (vi mode).**
- `y` — yank current selection to system clipboard
- `Y` — yank selection and paste it on the command line
- `prefix + y` — yank the current shell command line to clipboard

**Install.**
```tmux
set -g @plugin 'tmux-plugins/tmux-yank'
```
On Linux, needs `xclip` or `xsel` installed. On macOS, `pbcopy` is built-in.

---

### tmux-resurrect + tmux-continuum

**Use case.** Your tmux session has 5 windows with various panes, layouts, and possibly long-running processes. After a reboot (or accidental `tmux kill-server`), recreating that state manually is friction. tmux-resurrect saves session state on demand (`prefix + Ctrl-s` to save, `prefix + Ctrl-r` to restore). tmux-continuum builds on it: auto-save every 15 minutes and (optionally) auto-restore the last saved session when the tmux server starts.

**Tradeoff.** Feels magical when it works — you sit down, run `tmux`, and yesterday's setup is back. Some users find it intrusive (don't want to restore state, prefer fresh starts). Some processes (REPLs, SSH sessions) don't survive the save/restore cycle by default and need explicit configuration (`@resurrect-processes`).

**Install.**
```tmux
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @continuum-restore 'on'   # auto-restore on tmux server start
```

---

### tmux-fzf

**Use case.** Built-in session/window/pane pickers (`prefix + s`, `prefix + w`) show a tree view that gets clunky once you have more than a handful of sessions. tmux-fzf gives a fuzzy-finder UI on top, plus quick actions: switch, rename, kill, attach, send keys.

**Requires.** `fzf` installed on the system. Not currently in the install-packages script.

**Install.**
```tmux
set -g @plugin 'sainnhe/tmux-fzf'
```

Bound by default to `prefix + F`.

---

### tmux-which-key

**Use case.** The tmux analog of nvim's which-key.nvim: press the prefix and a popup menu lists the bindings you can hit next, with descriptions and nested submenus for grouped actions (e.g. "git" → "status / log / blame"). Useful both as a memory aid and as a discoverability surface for less-common bindings.

**Tradeoff.** Tmux's `bind-key` doesn't expose a description field the way `vim.keymap.set` does, so unlike nvim's which-key there's no auto-discovery — you list every entry you want to appear in the plugin's YAML config. Worth it once the binding catalogue is large enough to forget.

**No-plugin alternatives.**
- `prefix + ?` (built-in) — scrollable list of every binding, raw command names, no descriptions. Functional but ugly.
- `display-menu` (tmux 3.0+) — create your own popup menu and bind it to any key. Lighter than the plugin, same manual-definition cost.

**Install.**
```tmux
set -g @plugin 'alexwforsythe/tmux-which-key'
```

---

## Neovim — Tier 1 (transformative, originally excluded from the port)

### Fuzzy finder — Telescope vs fzf-lua

**Use case.** A single keystroke for: open file by name, switch buffer, live-grep across the codebase, jump to a symbol, browse git status, search LSP references, view command history, etc. The single biggest QoL add for any nvim setup.

| Aspect         | Telescope                                                         | fzf-lua                            |
|----------------|-------------------------------------------------------------------|------------------------------------|
| Backend        | Pure Lua + optional `fzy`/`fzf-native` sorter                     | Wraps the `fzf` binary directly    |
| Speed          | Fine up to ~200k files; slows on huge monorepos                   | Faster on huge codebases           |
| Ecosystem      | Massive — undo history, file browser, symbols, dap, project, etc. | Smaller but covers the essentials  |
| Feel           | Nvim-native, Lua-configurable                                     | Slightly closer to the raw fzf TUI |
| Native deps    | `ripgrep` + `fd` recommended                                      | `fzf` + `ripgrep` required         |
| Maintainership | Multiple active maintainers                                       | Single very active author          |

**Recommendation: Telescope.** The ecosystem and idiomatic Lua API win at typical project sizes. Switch to fzf-lua only if you hit performance issues on a giant monorepo.

**Typical keymaps.**
- `<leader>ff` — find files
- `<leader>fg` — live grep
- `<leader>fb` — buffers
- `<leader>fh` — help tags
- `<leader>fs` — document/workspace symbols (requires LSP)

---

### LSP stack — nvim-lspconfig + mason.nvim + nvim-cmp + LuaSnip

**Use case.** Without LSP, nvim is a syntax-highlighting text editor. With LSP, it gains: go-to-definition, hover documentation, in-line diagnostics, rename across files, code actions, find references, signature help. Adding completion (nvim-cmp) on top gives autocomplete fed by the LSP plus snippets.

**Components.**

| Plugin                   | Role                                                                 |
|--------------------------|----------------------------------------------------------------------|
| `nvim-lspconfig`         | Pre-baked config for ~100 language servers (Rust, Go, TS, Python, …) |
| `mason.nvim`             | Cross-platform installer for LSP servers, DAPs, linters, formatters  |
| `mason-lspconfig`        | Bridge: tells lspconfig where Mason installed each server            |
| `nvim-cmp`               | Completion engine (the popup, the sorting, the key handling)         |
| `cmp-nvim-lsp`           | nvim-cmp source for LSP completions                                  |
| `cmp-buffer`, `cmp-path` | Extra cmp sources (buffer words, filesystem paths)                   |
| `LuaSnip`                | Snippet engine                                                       |
| `cmp_luasnip`            | nvim-cmp source for LuaSnip snippets                                 |
| `friendly-snippets`      | Pre-made snippet collection for many languages                       |

**Tradeoff.** This is the single biggest setup-complexity add — multiple plugins, per-language tweaks, key handling for snippet jumps, hover keys, etc. Worth it if you want nvim to stand on its own as a coding environment; arguably redundant if you route all "smart code stuff" through the agent CLI (`Alt+c`).

**Alternative for less surface area.** Just `nvim-lspconfig` + `mason.nvim` (no completion) — gives diagnostics, hover, go-to-def, but you type identifiers manually. Half the value at a third of the config.

---

### conform.nvim (formatter)

**Use case.** Format-on-save with system formatters (prettier, stylua, black, gofmt, ruff, etc.) so saved files match team conventions automatically. Mason can install the formatters; conform wires them in.

**Alternative.** `none-ls.nvim` (the maintained fork of the archived null-ls.nvim) — also handles linters and code actions, but with a broader scope.

**Recommendation: conform.nvim.** Focused on formatting only, smaller API, actively maintained. Use Mason for installing the formatter binaries.

---

## Neovim — Tier 2 (small additions, universally beneficial)

### which-key.nvim

**Use case.** After typing `<leader>` and pausing for ~500ms, a popup at the bottom of the screen shows every `<leader>...` binding with its description. Removes the need to grep `keymaps.lua` to remember what you wired up. Also works for other prefixes (`g`, `[`, `]`, etc.).

Particularly valuable now that every keymap in this repo has a `desc = ...` field — which-key uses those descriptions verbatim.

---

### Surround — mini.surround vs nvim-surround

**Use case.** Mutate the characters surrounding a text object: `cs"'` to change `"foo"` to `'foo'`; `ds(` to delete the parens around `(bar)` leaving `bar`; `ysiw"` to wrap the inner word with quotes. Direct port of tpope's vim-surround idea.

| Aspect     | `nvim-surround` (kylechui)              | `mini.surround` (echasnovski)                 |
|------------|-----------------------------------------|-----------------------------------------------|
| Style      | Direct port of vim-surround semantics   | Part of the mini.nvim family — consistent API |
| Defaults   | `ys` / `cs` / `ds` operators (familiar) | Same operators, configurable                  |
| Footprint  | Standalone                              | One module in a larger plugin suite           |
| Treesitter | Optional treesitter targets             | Optional treesitter targets                   |

**Recommendation: nvim-surround.** Coming from vim/vimrc, the muscle memory transfers exactly. Pick `mini.surround` only if you plan to adopt the broader mini.nvim suite (mini.pairs, mini.ai, mini.statusline, …) over time.

---

### Auto-pairs — nvim-autopairs vs mini.pairs

**Use case.** When you type `(`, the matching `)` is inserted with the cursor between them. Same for `[`, `{`, `"`, `'`, and backticks. Smart enough to not double-close when typing inside an existing pair, to handle quote balancing, and to support fast-wrap (wrap the next word in pairs with one keystroke).

| Aspect          | `nvim-autopairs`                            | `mini.pairs`                  |
|-----------------|---------------------------------------------|-------------------------------|
| Edge cases      | Quote balance, fast-wrap, contextual rules  | Simpler rules                 |
| Treesitter      | Treesitter-aware (knows you're in a string) | Not treesitter-aware          |
| Footprint       | Standalone, ~1.5k LOC                       | One small module in mini.nvim |
| Configurability | Many knobs                                  | Few knobs                     |

**Recommendation: nvim-autopairs.** The treesitter awareness and fast-wrap (`<M-e>`) are real wins; the larger codebase pays for itself in fewer "this should have worked" moments.

---

### Motion — flash.nvim vs leap.nvim

**Use case.** Jump to any visible character on the screen in 2–3 keystrokes (vs hunting with `f`/`F`/`/`). Press the trigger, type the target char, type the label that appears next to the match you want.

| Aspect       | `flash.nvim` (folke)                                         | `leap.nvim` (ggandor)     |
|--------------|--------------------------------------------------------------|---------------------------|
| Modes        | Search, jump, char (`f`/`t` upgrade), treesitter, remote ops | Bidirectional 2-char jump |
| Integrations | Enhances `/` search, treesitter nodes as jump targets        | Standalone motion         |
| Author       | folke (lazy.nvim author — very active)                       | ggandor (active, focused) |
| Default keys | `s` in normal/visual/operator                                | `s` and `S`               |

**Recommendation: flash.nvim.** More capable in one package — same plugin upgrades `/`, gives a treesitter-node picker, and replaces `f`/`t` with labelled versions. The folke author overlap with lazy.nvim is a small but real plus.

---

### indent-blankline.nvim

**Use case.** Renders subtle vertical lines at each indentation level. Hugely helps in YAML, deeply-nested Python, and any code where matching `if/end` or `{}` blocks visually is hard. Catppuccin has built-in integration so the lines blend with the theme.

---

## Zsh — Tier 1 (plugin-driven, high impact)

### Plugin manager — manual sourcing vs antidote vs zinit

**Use case.** With more than 2–3 zsh plugins, manually `git clone`-ing each and adding `source` lines to `.zshrc` becomes friction: updates, ordering, lazy-loading. A plugin manager handles install/update, can lazy-load to keep startup fast, and gives a single config surface.

| Aspect           | Manual git clone                     | antidote                               | zinit                                  |
|------------------|--------------------------------------|----------------------------------------|----------------------------------------|
| Startup speed    | Slowest (everything sourced eagerly) | Fast (static loading + caching)        | Fastest (turbo / lazy mode)            |
| Setup complexity | Very low                             | Low (one-line bundle file)             | High (DSL of `wait`/`lucid`/`ice` ops) |
| Lazy loading     | None                                 | Limited                                | First-class                            |
| Plugin ecosystem | Any zsh plugin                       | OMZ plugins, prezto modules, raw repos | Same + complex hooks                   |
| Maintenance      | Manual updates                       | `antidote update`                      | `zinit update`                         |
| Best for         | ≤3 plugins                           | 5–15 plugins, mainstream setup         | Power users, heavy customization       |

**Recommendation: antidote.** Sweet spot of simplicity and capability — closest fit to this repo's "small, explicit, version-pinned" style. Stay with manual sourcing if you'd add only 2–3 plugins; reach for zinit only if startup time becomes a measurable problem.

For chezmoi-friendliness, install via a `run_onchange_install-zsh-plugins.sh` that mirrors the existing TPM/Lazy install pattern.

---

### zsh-autosuggestions

> **Status:** implemented. Cloned by [run_onchange_install-zsh-plugins.sh](../run_onchange_install-zsh-plugins.sh), sourced in `.zshrc` after fzf-tab. See [zsh.md](zsh.md).

**Use case.** As you type, zsh shows a grey "ghost text" continuation based on your shell history (fish-style). Press `→` (or `End`) to accept the whole suggestion, `Alt+f` to accept word-by-word. Saves real keystrokes on commands you've run before.

```
$ git stat[us]                    ← grey ghost text from history
```

---

### Syntax highlighting — zsh-syntax-highlighting vs fast-syntax-highlighting

**Use case.** Colors your command line as you type: command names green when on `PATH`, red when not found, strings/paths/options coloured, redirection operators highlighted. Catches typos before you hit Enter.

| Aspect       | `zsh-syntax-highlighting` (zsh-users) | `fast-syntax-highlighting` (zdharma-continuum) |
|--------------|---------------------------------------|------------------------------------------------|
| Speed        | Adequate on short lines               | ~10x faster on long lines / long pastes        |
| Highlighting | Conservative, accurate                | More feature-rich (regex, themes)              |
| Maintenance  | Stable, the canonical option          | Active fork-of-fork lineage                    |
| Defaults     | Plain                                 | Slightly more opinionated                      |

**Recommendation: fast-syntax-highlighting.** Same visual result on short commands, noticeably snappier when pasting long lines or editing multi-line constructs.

---

### fzf + fzf-tab

> **Status:** implemented. `Ctrl+T` (file picker), `Ctrl+R` (history), `Alt+J` (cd; moved off `Alt+C` to keep `Alt+c` free for the agent CLI). fzf-tab loaded after `compinit`. See [zsh.md](zsh.md).

**Use case.** Two huge UX additions wrapped together:

- **fzf shell integration**: `Ctrl+R` becomes a fuzzy history search (replacing zsh's default reverse-i-search), `Ctrl+T` opens a fuzzy file picker that inserts the path at cursor, `Alt+C` jumps to a fuzzy-picked directory.
- **fzf-tab**: replaces zsh's stock tab-completion menu with an fzf popup. `git checkout <Tab>` becomes a fuzzy-searchable, scrollable branch list; `kill <Tab>` becomes a fuzzy process picker; etc.

Requires the `fzf` binary on the system (add to the install-packages script).

---

### zoxide

**Use case.** Smarter `cd`. Tracks how often you visit each directory and lets you jump to the best match by partial name. `z dot` jumps to your dotfiles repo regardless of where you are.

```sh
$ z dot              # jumps to /home/me/repo/dotfiles
$ z dot tmux         # narrows to /home/me/repo/dotfiles/dot_config/tmux
$ zi                 # fzf-style interactive picker over visited dirs
```

Replaces `autojump`, `z.sh`, `fasd`. Pairs natively with fzf (`zi`).

---

## Zsh — Tier 2 (no-plugin tweaks)

### History settings

> **Status:** implemented in [.zshrc](../dot_config/zsh/dot_zshrc) (HISTSIZE/SAVEHIST=50000, HISTFILE under `$ZDOTDIR`, all seven setopts). See [zsh.md](zsh.md).

**Use case.** Zsh's defaults keep a small (1000-entry) history, retain duplicates, and don't share between sessions. A handful of `setopt`s makes shell history actually useful for recall and analysis.

```zsh
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=$ZDOTDIR/.zsh_history

setopt HIST_IGNORE_DUPS          # don't record consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS      # purge older duplicates when a new one is added
setopt HIST_IGNORE_SPACE         # don't record commands prefixed with a space
setopt HIST_REDUCE_BLANKS        # squeeze interior whitespace before saving
setopt SHARE_HISTORY             # share history across simultaneous sessions
setopt EXTENDED_HISTORY          # store timestamp + duration per command
setopt HIST_VERIFY               # `!!` expands but doesn't auto-execute
```

---

### Completion enhancements

> **Status:** implemented in [.zshrc](../dot_config/zsh/dot_zshrc) — `compinit`, the three `zstyle`s, plus `dircolors -b` to populate `LS_COLORS` so the listing actually colorises. See [zsh.md](zsh.md).

**Use case.** Zsh's completion system is powerful but not initialized in a minimal config. A few lines turn on rich tab completion, case-insensitive matching, and an arrow-navigable menu.

```zsh
autoload -Uz compinit && compinit

zstyle ':completion:*' menu select                            # arrow-key menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'     # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"       # colorise listing
```

If `fzf-tab` is added (Tier 1), it takes over the menu rendering — but the `matcher-list` rule still drives what matches.

---

### Directory stack tweaks

**Use case.** Light navigation upgrades that pay off after a week of muscle memory:

- `AUTO_CD` lets you change directory by typing just the path (no `cd` prefix).
- `AUTO_PUSHD` pushes every `cd` onto a stack — view it with `dirs -v`, jump back with `cd -<N>`.

```zsh
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
```

---

## Optional / later

These come up regularly in shared configs but are more niche — skim and decide if any speak to your workflow.

| Plugin                                | One-line pitch                                                             |
|---------------------------------------|----------------------------------------------------------------------------|
| `trouble.nvim`                        | Pretty list view for LSP diagnostics, references, todo comments, quickfix  |
| `noice.nvim`                          | Replaces the cmdline / messages / popup UI with a modern floating design   |
| `dressing.nvim`                       | Better `vim.ui.select` and `vim.ui.input` prompts (rename, code action UI) |
| `persistence.nvim`                    | Save/restore session per cwd — `:lua require("persistence").load()`        |
| `mini.bufremove` / `bufdelete.nvim`   | Close a buffer without closing its window                                  |
| `nvim-notify`                         | Animated, persistent notification popups (pairs with noice.nvim)           |
| `todo-comments.nvim`                  | Highlight and search `TODO:` / `FIXME:` / `HACK:` / `NOTE:` markers        |
| `mini.ai`                             | Smarter `i{` / `a{` text objects, treesitter-powered                       |
| `gitsigns.nvim` hunks UI              | Already installed — bind `<leader>hp` (preview), `<leader>hs` (stage hunk) |
| `zsh-completions` (zsh)               | 50+ extra completion files for tools missing them upstream                 |
| `zsh-history-substring-search` (zsh)  | Type a partial command, `Up`/`Down` walks history entries matching it      |
| `alias-tips` / `you-should-use` (zsh) | Prints a reminder when you type the long form of a command you've aliased  |
| `zsh-vi-mode` (zsh)                   | Polished vi mode — block cursor on normal-mode, surround keymaps, undo     |
