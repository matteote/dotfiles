#!/usr/bin/env bash
# End-to-end chezmoi test on Parallels VMs.
#
# For each VM: revert to snapshot "dotfiles_test", boot it, sync the
# local working tree, run chezmoi apply + smoke checks via SSH, stop.
#
# See test/README.md for the one-time snapshot setup this script assumes.
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO=$(cd "$SCRIPT_DIR/.." && pwd)

SSH_USER=matteo
VMS=("Debian 12" "Debian 13" "macOS")
SNAPSHOT="dotfiles_test"

# Argv (space-separated) to run inside the guest via `prlctl exec`,
# printing the guest's IPv4 on stdout. `prlctl list -o ip` is unreliable
# even with Parallels Tools installed, so we ask the guest directly.
# Output is post-processed in wait_for_ip (first field of first line)
# because `prlctl exec` does not honor a `sh -c "..."` wrapper.
ip_cmd_for() {
    case $1 in
        "Debian 12"|"Debian 13") echo "hostname -I" ;;
        "macOS")                 echo "ipconfig getifaddr en0" ;;
        *) echo "no IP discovery command for VM: $1" >&2; return 1 ;;
    esac
}

# shellcheck source=lib/parallels.sh
source "$SCRIPT_DIR/lib/parallels.sh"
# shellcheck source=lib/ssh.sh
source "$SCRIPT_DIR/lib/ssh.sh"

KEEP_ON_FAILURE=0
declare -a ONLY=()

usage() {
    cat <<EOF
Usage: $(basename "$0") [--only "VM Name"]... [--keep-on-failure]

Options:
  --only "VM Name"    Restrict to one VM. Repeatable.
  --keep-on-failure   Leave a failing VM running for debugging.
  -h, --help          This help.

Available VMs: ${VMS[*]}
EOF
}

while (($#)); do
    case $1 in
        --only)
            [[ $# -ge 2 ]] || { echo "--only needs an argument" >&2; exit 2; }
            ONLY+=("$2"); shift 2 ;;
        --keep-on-failure) KEEP_ON_FAILURE=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
done

if ((${#ONLY[@]})); then
    VMS=("${ONLY[@]}")
fi

# Parallel to VMS — RESULTS[i] is the outcome for VMS[i].
RESULTS=()
vm_to_cleanup=""

cleanup() {
    if [[ -n $vm_to_cleanup ]]; then
        echo "[cleanup] stopping $vm_to_cleanup" >&2
        vm_stop "$vm_to_cleanup"
    fi
}
trap cleanup EXIT INT TERM

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }

run_one() {
    local vm=$1
    log "=== $vm ==="

    # set -e is suspended inside functions called from `if run_one ...`
    # (bash 3.2 behavior), so every step needs an explicit error return.
    log "stop (idempotent guard)"
    vm_stop "$vm"

    log "snapshot-switch → $SNAPSHOT"
    snapshot_revert "$vm" || { log "snapshot revert failed"; return 1; }

    log "start"
    vm_start "$vm" || { log "VM start failed"; return 1; }
    vm_to_cleanup=$vm

    log "wait for IP"
    local ip
    ip=$(wait_for_ip "$vm") || { log "no IP within timeout"; return 1; }
    log "IP: $ip"

    log "wait for sshd"
    wait_for_ssh "$ip" || { log "sshd did not come up"; return 1; }

    log "send working tree → ~/dotfiles on VM"
    vm_send_repo "$ip" || { log "tar sync failed"; return 1; }
    vm_scp_remote_runner "$ip" || { log "scp of remote runner failed"; return 1; }

    log "run remote test"
    vm_ssh "$ip" bash run-test.sh
}

overall_rc=0
for i in "${!VMS[@]}"; do
    vm=${VMS[$i]}
    if run_one "$vm"; then
        RESULTS[$i]=PASS
        log "$vm: PASS — stopping"
        vm_stop "$vm"
    else
        RESULTS[$i]=FAIL
        overall_rc=1
        if ((KEEP_ON_FAILURE)); then
            log "$vm: FAIL — leaving running (--keep-on-failure)"
        else
            log "$vm: FAIL — stopping"
            vm_stop "$vm"
        fi
    fi
    vm_to_cleanup=""
done

echo
echo "=== Summary ==="
for i in "${!VMS[@]}"; do
    printf '  %-12s %s\n' "${VMS[$i]}" "${RESULTS[$i]:-SKIPPED}"
done

exit $overall_rc
