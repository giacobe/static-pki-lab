#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: sudo bash $0 {ca|server|client}" >&2
    exit 2
}

[[ ${EUID} -eq 0 ]] || { echo "Run this script with sudo." >&2; exit 1; }
[[ $# -eq 1 ]] || usage

role=$1
case "$role" in
    ca)
        packages=(openssl openssh-server curl)
        ;;
    server)
        packages=(openssl apache2 openssh-client curl)
        ;;
    client)
        packages=(openssl openssh-client curl firefox)
        ;;
    *)
        usage
        ;;
esac

. /etc/os-release
if [[ ${ID:-} != ubuntu || ${VERSION_ID:-} != 24.04 ]]; then
    echo "This lab requires Ubuntu 24.04 LTS; detected ${PRETTY_NAME:-unknown}." >&2
    exit 1
fi

echo "Installing packages for role: $role"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"

if [[ $role == ca ]]; then
    systemctl enable --now ssh
else
    if systemctl list-unit-files ssh.service >/dev/null 2>&1; then
        systemctl disable --now ssh 2>/dev/null || true
    fi
fi

if [[ $role == server ]]; then
    systemctl enable apache2
fi

echo "Package installation for $role is complete."

