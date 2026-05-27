#!/usr/bin/env bash
# Parallels Desktop helpers. Sourced by run-vm-tests.sh.
#
# Expects the caller to have defined:
#   SNAPSHOT       — snapshot name to revert to
#   ip_cmd_for()   — function: VM name → shell command (run inside guest)
#                    that prints the guest's IPv4 on stdout.

snapshot_revert() {
    local vm=$1
    local snap_id
    snap_id=$(prlctl snapshot-list "$vm" -j 2>/dev/null \
        | jq -r --arg name "$SNAPSHOT" \
            'to_entries[] | select(.value.name==$name) | .key')
    if [[ -z $snap_id ]]; then
        echo "no snapshot named '$SNAPSHOT' for VM '$vm'" >&2
        return 1
    fi
    prlctl snapshot-switch "$vm" --id "$snap_id"
}

vm_start() {
    local vm=$1
    prlctl start "$vm"
}

vm_stop() {
    local vm=$1
    prlctl stop "$vm" --kill 2>/dev/null || true
}

# Poll the guest for its IPv4 via `prlctl exec`. `prlctl list -o ip` has
# proven unreliable even with Parallels Tools installed, so we ask the
# guest directly. `prlctl exec` itself fails until the guest agent comes
# up after boot — the same loop handles both that and "no DHCP yet".
wait_for_ip() {
    local vm=$1
    local cmd_str
    cmd_str=$(ip_cmd_for "$vm") || return 1
    # `prlctl exec` does not honor a shell wrapper — `sh -c "hostname -I"`
    # is parsed as `sh -c hostname -I` (the quotes don't survive), giving
    # the wrong result. So we pass argv directly and post-process here.
    local -a cmd
    read -ra cmd <<<"$cmd_str"
    local deadline=$((SECONDS + 180))
    local ip
    while ((SECONDS < deadline)); do
        ip=$(prlctl exec "$vm" "${cmd[@]}" 2>/dev/null \
            | awk 'NR==1 {print $1; exit}' | tr -d '\r\n ')
        if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "$ip"
            return 0
        fi
        sleep 3
    done
    return 1
}
