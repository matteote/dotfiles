# VM tests

End-to-end test for this chezmoi config. For each VM, the orchestrator reverts to a known snapshot, syncs the local working tree (uncommitted edits included), runs `chezmoi apply` over SSH, and runs smoke checks.

## Usage

From the repo root on the macOS host:

```sh
./test/run-vm-tests.sh                       # all three VMs
./test/run-vm-tests.sh --only "Debian 13"    # just one
./test/run-vm-tests.sh --keep-on-failure     # leave a failing VM running for debug
```

The script is sequential — one VM at a time.

## One-time snapshot setup

The orchestrator assumes each Parallels VM ("Debian 12", "Debian 13", "macOS") has a snapshot named `dotfiles_test` in which:

1. **The test SSH key is authorized.** Install `.ssh/test_vms.pub` (from this repo) into `~matteo/.ssh/authorized_keys` (mode 600, owner matteo). sshd must start on boot.
2. **`matteo` has passwordless sudo.** The chezmoi `before_install-packages` and `set-default-shell` scripts use `sudo` non-interactively and will hang otherwise. On Debian:

   ```sh
   echo 'matteo ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/matteo
   sudo chmod 440 /etc/sudoers.d/matteo
   ```

3. **Parallels Tools is installed in the guest.** Required for `prlctl exec`, which the script uses to discover the guest's IP.

Re-take the `dotfiles_test` snapshot once the above is in place.

On macOS, Homebrew and Xcode Command Line Tools do **not** need to be preinstalled — the chezmoi `before_install-packages` script bootstraps both via `NONINTERACTIVE=1` brew install. The macOS apply takes ~5 minutes on a snapshot without them.

## Layout

- `run-vm-tests.sh` — host orchestrator. Entry point.
- `lib/parallels.sh` — `prlctl` helpers (snapshot revert, start/stop, IP discovery).
- `lib/ssh.sh` — `SSH_OPTS` array plus `ssh`/`rsync` wrappers using `.ssh/test_vms`.
- `remote/run-test.sh` — runs inside the VM; applies chezmoi and runs smoke checks.

The whole `test/` directory is listed in `.chezmoiignore`, so `chezmoi apply` ignores it.
