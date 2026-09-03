# Instructor Notes

## Scope

This lab intentionally omits the MITM and compromised-CA phases of the SEED
PKI lab. It focuses on environment construction, enrollment, issuance,
deployment, trust establishment, and validation failures.

## Required platform validation

Before release, test the complete instructions on:

1. VMware Workstation on Windows with AMD64 Ubuntu media.
2. VMware Fusion on Intel macOS, if Intel Mac support is required.
3. VMware Fusion on Apple Silicon with ARM64 Ubuntu media.

The principal platform-specific risk is creating a guest network that is
shared by the three VMs but is not reachable by the host. VMware product
labels and available custom-network modes differ. Supply separately tested UI
instructions rather than relying on a generic "host-only" label.

## Grading boundary

Use the detailed 50-point rubrics in `lab/GRADING-RUBRICS.md`. Each rubric
assigns 30 points to evidence of completed work and 20 points to qualitative
assessment of annotations, answers, interpretation, and reflection.

The scripts may install prerequisites, set infrastructure hostnames, write
static network configuration, and perform read-only preflight checks. They do
not perform the graded PKI work.

Suggested grading allocation:

| Area | Weight |
|---|---:|
| VM creation and isolated networking | 20% |
| Root CA construction and explanation | 20% |
| Server key, CSR, and artifact custody | 15% |
| CA review and certificate issuance | 15% |
| Apache deployment | 10% |
| Client trust and validation testing | 15% |
| Cleanup and reflection | 5% |

## Known points requiring a pilot run

- Confirm Ubuntu Server's generated Netplan renderer and VMware interface
  naming on both architectures.
- Confirm Ubuntu Desktop networking remains manageable after the script writes
  a systemd-networkd Netplan file. If NetworkManager ownership is desired,
  modify the configuration script for the client.
- Confirm the installed Firefox certificate import UI and whether enterprise
  roots or OS trust integration changes the expected initial result.
- Confirm OpenSSL `ca -extfile` behavior on the packaged Ubuntu 24.04 OpenSSL.
- Confirm Apache starts with the generated PKCS#8 deployment key.
- Confirm the internal VMware network provides neither DHCP nor a host-side
  interface.

## Academic-integrity note

Personalizing the site hostname makes reports less static but does not prove
independent completion. Consider requiring randomly assigned certificate
serial starting values, short instructor-provided challenge text on the web
page, or a live check of the student's three-VM environment.
