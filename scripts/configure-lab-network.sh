#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: sudo bash $0 {ca|server|client} STUDENT_ID [INTERFACE]" >&2
    exit 2
}

[[ ${EUID} -eq 0 ]] || { echo "Run this script with sudo." >&2; exit 1; }
[[ $# -ge 2 && $# -le 3 ]] || usage

role=$1
student_id=${2,,}
specified_interface=${3:-}

[[ $student_id =~ ^[a-z][a-z0-9-]*$ ]] || {
    echo "Student ID must be a lowercase DNS label beginning with a letter." >&2
    exit 1
}

case "$role" in
    ca)
        address=10.77.0.10
        lab_hostname=pki-ca
        ;;
    server)
        address=10.77.0.20
        lab_hostname=pki-server
        ;;
    client)
        address=10.77.0.30
        lab_hostname=pki-client
        ;;
    *)
        usage
        ;;
esac

if [[ -n $specified_interface ]]; then
    interface=$specified_interface
else
    interface=$(ip -o link show | awk -F': ' '$2 != "lo" {print $2; exit}')
fi

[[ -n ${interface:-} ]] || { echo "No Ethernet interface was found." >&2; exit 1; }
ip link show "$interface" >/dev/null 2>&1 || {
    echo "Interface '$interface' does not exist." >&2
    exit 1
}

echo "Role:       $role"
echo "Hostname:   $lab_hostname"
echo "Interface:  $interface"
echo "Address:    $address/24"
echo "Web name:   ${student_id}.psu.edu"
echo
read -r -p "Write and apply this network configuration? [y/N] " answer
[[ $answer =~ ^[Yy]$ ]] || { echo "No changes made."; exit 0; }

hostnamectl set-hostname "$lab_hostname"

cat > /etc/netplan/99-pki-lab.yaml <<EOF
network:
  version: 2
  ethernets:
    ${interface}:
      dhcp4: false
      dhcp6: false
      addresses:
        - ${address}/24
      optional: true
EOF
chmod 600 /etc/netplan/99-pki-lab.yaml

sed -i '/# BEGIN PKI LAB/,/# END PKI LAB/d' /etc/hosts
cat >> /etc/hosts <<EOF
# BEGIN PKI LAB
10.77.0.10 pki-ca
10.77.0.20 pki-server ${student_id}.psu.edu
10.77.0.30 pki-client
# END PKI LAB
EOF

netplan generate
netplan apply

echo "Network configuration applied. Run the role preflight script next."

