#!/usr/bin/env bash
# SSH/rsync helpers. Sourced by run-vm-tests.sh.
#
# Expects the caller to have defined:
#   REPO       — absolute path to the dotfiles repo root
#   SSH_USER   — username on the test VMs

SSH_OPTS=(
    -i "$REPO/.ssh/test_vms"
    -o IdentitiesOnly=yes
    -o IdentityAgent=none
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
    -o GlobalKnownHostsFile=/dev/null
    -o LogLevel=ERROR
    -o BatchMode=yes
    -o ConnectTimeout=5
    -o ServerAliveInterval=15
)

vm_ssh() {
    local ip=$1
    shift
    ssh "${SSH_OPTS[@]}" "$SSH_USER@$ip" "$@"
}

wait_for_ssh() {
    local ip=$1
    local deadline=$((SECONDS + 120))
    while ((SECONDS < deadline)); do
        if ssh "${SSH_OPTS[@]}" "$SSH_USER@$ip" true 2>/dev/null; then
            return 0
        fi
        sleep 2
    done
    return 1
}

# Send the local working tree to ~/dotfiles on the VM via tar-over-ssh.
# tar is universally available; rsync is not (and the macOS-bundled rsync
# 2.6.9 has protocol mismatches against Linux's rsync 3.x anyway).
vm_send_repo() {
    local ip=$1
    # COPYFILE_DISABLE=1 + --no-mac-metadata silence the
    # `LIBARCHIVE.xattr.com.apple.provenance` warnings GNU tar prints
    # when unpacking a tarball produced by bsdtar.
    COPYFILE_DISABLE=1 tar -C "$REPO" --no-mac-metadata -czf - \
        --exclude='./.git' \
        --exclude='./.ssh' \
        --exclude='./test' \
        . \
        | vm_ssh "$ip" \
            'rm -rf dotfiles && mkdir -p dotfiles && tar -C dotfiles -xzf -'
}

vm_scp_remote_runner() {
    local ip=$1
    scp "${SSH_OPTS[@]}" \
        "$REPO/test/remote/run-test.sh" \
        "$SSH_USER@$ip:run-test.sh"
}
