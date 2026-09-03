#!/usr/bin/env bash
set -u

usage() {
    echo "Usage: sudo bash $0 {ca|server|client} STUDENT_ID" >&2
    exit 2
}

[[ ${EUID} -eq 0 ]] || { echo "Run this script with sudo." >&2; exit 1; }
[[ $# -eq 2 ]] || usage

role=$1
student_id=${2,,}
[[ $student_id =~ ^[a-z][a-z0-9-]*$ ]] || usage

case "$role" in
    ca) expected_host=pki-ca; expected_ip=10.77.0.10; commands=(openssl sshd curl) ;;
    server) expected_host=pki-server; expected_ip=10.77.0.20; commands=(openssl apache2 ssh curl) ;;
    client) expected_host=pki-client; expected_ip=10.77.0.30; commands=(openssl ssh curl) ;;
    *) usage ;;
esac

failures=0
warnings=0

pass() { printf '[PASS] %s\n' "$*"; }
fail() { printf '[FAIL] %s\n' "$*"; failures=$((failures + 1)); }
warn() { printf '[WARN] %s\n' "$*"; warnings=$((warnings + 1)); }

if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    [[ ${ID:-} == ubuntu && ${VERSION_ID:-} == 24.04 ]] &&
        pass "Ubuntu 24.04 detected" || fail "Ubuntu 24.04 is required"
else
    fail "/etc/os-release is unavailable"
fi

[[ $(hostname) == "$expected_host" ]] &&
    pass "Hostname is $expected_host" || fail "Expected hostname $expected_host; found $(hostname)"

if ip -4 -o address show | awk '{print $4}' | grep -qx "${expected_ip}/24"; then
    pass "Static address ${expected_ip}/24 is configured"
else
    fail "Static address ${expected_ip}/24 is not configured"
fi

for command_name in "${commands[@]}"; do
    command -v "$command_name" >/dev/null 2>&1 &&
        pass "$command_name is installed" || fail "$command_name is not installed"
done

for peer in 10.77.0.10 10.77.0.20 10.77.0.30; do
    if [[ $peer == "$expected_ip" ]]; then
        continue
    fi
    ping -c 1 -W 1 "$peer" >/dev/null 2>&1 &&
        pass "Peer $peer is reachable" || fail "Peer $peer is not reachable"
done

resolved=$(getent ahostsv4 "${student_id}.psu.edu" 2>/dev/null | awk 'NR==1 {print $1}')
[[ $resolved == 10.77.0.20 ]] &&
    pass "${student_id}.psu.edu resolves to 10.77.0.20" ||
    fail "${student_id}.psu.edu resolved to ${resolved:-nothing}"

if ip -4 route show default | grep -q .; then
    fail "A default IPv4 route is still configured"
else
    pass "No default IPv4 route is configured"
fi

if ip -6 route show default | grep -q .; then
    fail "A default IPv6 route is still configured"
else
    pass "No default IPv6 route is configured"
fi

if command -v ufw >/dev/null 2>&1; then
    ufw status | grep -qi '^Status: inactive' &&
        pass "UFW is inactive" || fail "UFW is active or its state is unknown"
else
    pass "UFW is not installed"
fi

if [[ $role == ca ]]; then
    systemctl is-active --quiet ssh && pass "SSH server is active" || fail "SSH server is not active"
else
    if systemctl is-active --quiet ssh 2>/dev/null; then
        fail "SSH server should not be active on this role"
    else
        pass "SSH server is not active"
    fi
fi

if [[ $role == server ]]; then
    systemctl is-enabled --quiet apache2 2>/dev/null &&
        pass "Apache is enabled" || warn "Apache is not enabled"
fi

if [[ $role == client ]]; then
    if command -v firefox >/dev/null 2>&1 || snap list firefox >/dev/null 2>&1; then
        pass "Firefox is installed"
    else
        fail "Firefox is not installed"
    fi
fi

login_user=${SUDO_USER:-root}
login_home=$(getent passwd "$login_user" | cut -d: -f6)
if [[ -e /etc/apache2/pki-lab/server.key || -e "$login_home/pki-lab-ca/ca/private/ca.key" ]]; then
    warn "PKI private-key material already exists; confirm this is intentional"
else
    pass "No standard-path PKI private keys exist before the PKI phase"
fi

echo
printf 'Preflight completed: %d failure(s), %d warning(s).\n' "$failures" "$warnings"
[[ $failures -eq 0 ]]
