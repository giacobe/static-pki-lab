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
    ca) expected_host=pki-ca; expected_ip=10.77.0.10 ;;
    server) expected_host=pki-server; expected_ip=10.77.0.20 ;;
    client) expected_host=pki-client; expected_ip=10.77.0.30 ;;
    *) usage ;;
esac

failures=0
warnings=0
pass() { printf '[PASS] %s\n' "$*"; }
fail() { printf '[FAIL] %s\n' "$*"; failures=$((failures + 1)); }
warn() { printf '[WARN] %s\n' "$*"; warnings=$((warnings + 1)); }

. /etc/os-release
[[ ${ID:-} == ubuntu && ${VERSION_ID:-} == 24.04 ]] &&
    pass "Ubuntu 24.04 detected" || fail "Ubuntu 24.04 is required"

[[ $(hostname) == "$expected_host" ]] &&
    pass "Hostname is $expected_host" || fail "Expected $expected_host; found $(hostname)"

lab_interface=$(ip -4 -o address show | awk -v ip="$expected_ip" '$4 == ip"/24" {print $2; exit}')
[[ -n ${lab_interface:-} ]] && pass "Lab address ${expected_ip}/24 is configured on $lab_interface" ||
    fail "Lab address ${expected_ip}/24 is missing"

default_interface=$(ip -4 route show default | awk 'NR==1 {print $5}')
if [[ -z ${default_interface:-} ]]; then
    fail "No NAT default route is configured"
elif [[ $default_interface == "${lab_interface:-missing}" ]]; then
    fail "The default route incorrectly uses the lab interface"
else
    pass "NAT default route uses $default_interface"
fi

interface_count=$(ip -4 -o address show scope global | awk '{print $2}' | sort -u | wc -l)
[[ $interface_count -ge 2 ]] && pass "At least two IPv4 interfaces are active" ||
    fail "Two active IPv4 interfaces are required"

for peer in 10.77.0.10 10.77.0.20 10.77.0.30; do
    [[ $peer == "$expected_ip" ]] && continue
    ping -c 1 -W 1 "$peer" >/dev/null 2>&1 && pass "Peer $peer is reachable" ||
        fail "Peer $peer is not reachable"
done

resolved=$(getent ahostsv4 "${student_id}.psu.edu" 2>/dev/null | awk 'NR==1 {print $1}')
[[ $resolved == 10.77.0.20 ]] && pass "${student_id}.psu.edu resolves to 10.77.0.20" ||
    fail "Student hostname resolved to ${resolved:-nothing}"

getent ahostsv4 archive.ubuntu.com >/dev/null 2>&1 && pass "Public DNS resolution works" ||
    fail "Public DNS resolution failed"

curl -fsSI --max-time 10 https://archive.ubuntu.com/ >/dev/null 2>&1 &&
    pass "Outbound NAT HTTPS works" || fail "Outbound NAT HTTPS failed"

if [[ $role == ca ]]; then
    systemctl is-active --quiet ssh && pass "SSH server is active" || fail "SSH server is inactive"
fi

if [[ $role == server ]]; then
    page=$(curl -fsS --max-time 5 -H "Host: ${student_id}.psu.edu" http://127.0.0.1/ 2>/dev/null || true)
    [[ $page == *"$student_id"* ]] && pass "Local HTTP page contains $student_id" ||
        fail "Local HTTP page does not contain $student_id"
    ss -lnt | awk '{print $4}' | grep -Eq '(^|:)443$' &&
        fail "A process is listening on TCP 443" || pass "No process listens on TCP 443"
fi

if [[ $role == client ]]; then
    page=$(curl -fsS --max-time 5 "http://${student_id}.psu.edu/" 2>/dev/null || true)
    [[ $page == *"$student_id"* ]] && pass "Remote HTTP page contains $student_id" ||
        fail "Remote HTTP page is unavailable or not personalized"
    curl -ksS --connect-timeout 3 "https://${student_id}.psu.edu/" >/dev/null 2>&1 &&
        fail "HTTPS unexpectedly succeeded" || pass "HTTPS is not available"
fi

echo
printf 'Precursor preflight: %d failure(s), %d warning(s).\n' "$failures" "$warnings"
[[ $failures -eq 0 ]]

