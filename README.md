# Three-VM Public-Key Infrastructure Lab

Student repository: https://github.com/giacobe/static-pki-lab

This repository contains a student-built, non-containerized PKI lab derived
from the learning sequence used by the SEED Public-Key Infrastructure Lab.

The laboratory uses three Ubuntu 24.04 LTS virtual machines:

| Role | Operating system | Address |
|---|---|---|
| Certificate authority | Ubuntu Server | `10.77.0.10/24` |
| HTTPS web server | Ubuntu Server | `10.77.0.20/24` |
| Web client | Ubuntu Desktop | `10.77.0.30/24` |

Students install and configure all three systems. The server certificate uses
the student's Penn State email ID. For example, `abc1234@psu.edu` produces the
website `https://abc1234.psu.edu/`.

## Contents

- [Printable student lab PDF](output/pdf/Three-VM-PKI-Lab.pdf)
- [Student lab manual](lab/PKI-LAB.md)
- [Instructor notes](lab/INSTRUCTOR-NOTES.md)
- [Two 50-point grading rubrics](lab/GRADING-RUBRICS.md)
- [Canvas rubric import instructions](lab/CANVAS-RUBRIC-IMPORT.md)
- [Canvas precursor rubric CSV](output/canvas/PKI-Environment-Precursor-Canvas-Rubric.csv)
- [Canvas PKI lab rubric CSV](output/canvas/Three-VM-PKI-Lab-Canvas-Rubric.csv)
- [Windows/macOS VMware precursor](precursor/PRECURSOR-LAB.md)
- [Printable VMware precursor PDF](output/pdf/PKI-Precursor-VMware.pdf)
- [NAT-phase package installation script](scripts/install-role-packages.sh)
- [Internal-network configuration script](scripts/configure-lab-network.sh)
- [Precursor dual-network preflight script](scripts/preflight-precursor-vm.sh)
- [Role preflight script](scripts/preflight-lab-vm.sh)

The scripts configure prerequisites only. They do not create keys,
certificates, CSRs, certificate trust, or the final Apache virtual host.

## Acknowledgment

The learning sequence is adapted from Wenliang Du's SEED Public-Key
Infrastructure Lab. SEED permits noncommercial educational use of its lab
materials; consult the original material for its complete copyright notice.
This implementation replaces the prepared SEED VM/container environment with
three student-built, non-containerized Ubuntu systems and omits the MITM
phases.

- [SEED Ubuntu 16.04 PKI Lab](https://seedsecuritylabs.org/Labs_16.04/Crypto/Crypto_PKI/)
- [SEED Ubuntu 20.04 PKI Lab](https://seedsecuritylabs.org/Labs_20.04/Crypto/Crypto_PKI/)
