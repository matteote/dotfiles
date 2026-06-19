# Dotfiles

Personal environment configuration managed with [chezmoi](https://www.chezmoi.io/), synced across Debian and macOS machines.

## Prerequisites

### sudo

The Debian package-install script uses `apt-get` and bootstraps Homebrew, both of which require `sudo`. Make sure the current user is in the `sudo` group (or equivalent) before running `chezmoi apply`. macOS users get `sudo` out of the box.

### chezmoi

Install chezmoi:

```shell
sh -c "$(curl -fsLS https://get.chezmoi.io)"
```

## Initial setup on a new machine

Install chezmoi and apply this repo in one command:

```shell
sh -c "$(curl -fsLS https://get.chezmoi.io)" -- init --apply matteote/dotfiles
```

If chezmoi is already installed, just init and apply:

```shell
chezmoi init --apply https://github.com/matteote/dotfiles.git
```

This clones the repo into chezmoi's source directory (`~/.local/share/chezmoi` on Linux, `~/Library/Application Support/chezmoi` on macOS) and renders the source files into `$HOME`.

If you already have the repo cloned locally and want chezmoi to use it as its source directory, point chezmoi at it via its config file. The `--source` flag on `chezmoi init` only applies to that single invocation — it does **not** persist, so subsequent commands fall back to the default `~/.local/share/chezmoi`.

```shell
mkdir -p ~/.config/chezmoi
cat > ~/.config/chezmoi/chezmoi.toml <<'EOF'
sourceDir = "/home/matteo/repo/dotfiles"
EOF
chezmoi apply
```

Alternative: symlink the default source directory at your existing clone:

```shell
ln -s /home/matteo/repo/dotfiles ~/.local/share/chezmoi
chezmoi apply
```

## Day-to-day usage

Source files live in the chezmoi source directory — **edit those, not the rendered files in `$HOME`**. Jump there with:

```shell
chezmoi cd      # opens a subshell in the source directory; exit to return
```

Common commands:

```shell
chezmoi diff             # preview pending changes before applying
chezmoi apply            # render source → home directory
chezmoi apply -v         # same, with verbose output
chezmoi status           # show files that differ between source and home
chezmoi edit ~/.zshrc    # edit the source file for a given target
chezmoi add ~/.foorc     # start tracking a file currently in $HOME
chezmoi re-add           # pull edits made directly in $HOME back into source
chezmoi forget ~/.foorc  # stop tracking a file (leaves the home copy in place)
```

## Syncing across machines

```shell
chezmoi cd
git pull                 # fetch updates from the remote
exit
chezmoi apply            # apply them to this machine
```

Or in one shot:

```shell
chezmoi update           # equivalent to: cd + git pull + apply
```

## nix-direnv

[direnv](https://direnv.net/) loads a per-directory environment from a project's `.envrc`. On its own, an `.envrc` that calls `use nix` re-evaluates `nix-shell` on every new shell (several seconds). [nix-direnv](https://github.com/nix-community/nix-direnv) replaces `use nix`/`use flake` with a caching version that stores the evaluated environment under the project's `.direnv/` and pins a GC root, so later shells load it in well under a second.

This repo wires it up for you:

- The package-install script runs `nix profile install nixpkgs#nix-direnv`, but only on machines that have nix — nix itself is not managed here.
- `dot_config/direnv/direnvrc` (→ `~/.config/direnv/direnvrc`) sources nix-direnv globally, guarded so it's a harmless no-op where nix-direnv isn't installed.

To use it in a project, drop an `.envrc` in the project root and allow it:

```shell
echo 'use nix' > .envrc     # or: use flake
direnv allow
```

The first load builds and caches the environment; subsequent shells reuse the cache. nix-direnv writes that cache to `.direnv/` in the project, so add it to the project's `.gitignore`:

```shell
echo '.direnv/' >> .gitignore
```

## Naming conventions (cheat sheet)

Source filenames encode the target file's path and attributes. The most common prefixes:

| Source name              | Becomes              | Notes                               |
| ------------------------ | -------------------- | ----------------------------------- |
| `dot_zshrc`              | `~/.zshrc`           | `dot_` → leading `.`                |
| `private_dot_ssh/`       | `~/.ssh/` (mode 700) | `private_` → mode `0600`/`0700`     |
| `executable_dot_bin/foo` | `~/.bin/foo` (+x)    | `executable_` → mode `0755`         |
| `run_once_install.sh`    | (script)             | Executed once on `apply`            |
| `run_onchange_brew.sh`   | (script)             | Re-run when its contents change     |
| `dot_zshrc.tmpl`         | `~/.zshrc`           | `.tmpl` → rendered as a Go template |

For OS-specific content, branch inside `.tmpl` files:

```gotemplate
{{ if eq .chezmoi.os "darwin" }}
# macOS-only lines
{{ else if eq .chezmoi.os "linux" }}
# Linux-only lines
{{ end }}
```

Full reference: <https://www.chezmoi.io/reference/source-state-attributes/>
