# PKI Lab Environment Build - VMware on Windows or macOS

## Purpose

This precursor exercise builds the environment required for the Three-VM
Public-Key Infrastructure Lab. You will install three Ubuntu 24.04 LTS virtual
machines in VMware Workstation on Windows or VMware Fusion on an Apple Silicon
Mac, configure two independent network adapters on each VM, and deploy a
personalized HTTP website.

Whenever a procedure is labeled by host platform, complete only the subsection
for your host. Commands entered inside Ubuntu are identical on both platforms.

At the end of this exercise:

- All three VMs can communicate on an isolated VMware network.
- All three VMs also have operational outbound Internet access through NAT.
- The web server serves `http://abc1234.psu.edu`, replacing `abc1234` with
  your Penn State user ID.
- The web server does not provide HTTPS and does not listen on TCP port 443.
- No certificates, CSRs, or private keys have been created.

The first action in the PKI lab will be to disconnect each NAT adapter. Do not
disconnect NAT during this precursor exercise.

## Safety and scope

- Use VMware NAT networking, never Bridged networking.
- On Windows, use a Workstation LAN Segment. On macOS, use a Fusion custom
  network with host connection, NAT, and DHCP disabled.
- Do not configure port forwarding on the NAT adapter.
- Do not expose Apache to the physical network.
- Do not use these VMs for unrelated work after the PKI lab.

## Required resources

- Windows 10 or Windows 11 on an Intel or AMD 64-bit system, **or** a supported
  macOS release on an Apple Silicon Mac
- VMware Workstation Pro 17 or VMware Fusion Pro 13, or a later compatible
  release
- 16 GB host RAM
- 50 GB free host storage
- Administrator permission to install the appropriate VMware product
- Internet access during this precursor exercise

> **Older Intel-based Mac:** These instructions use the current Apple Silicon
> and ARM64 path. If `uname -m` reports `x86_64`, stop and see your instructor
> for alternative Intel Mac instructions and installation media.

## Ubuntu architecture

- **Windows:** use Ubuntu 24.04 LTS AMD64 media and the **Ubuntu 64-bit** guest
  type.
- **Apple Silicon macOS:** use Ubuntu 24.04 LTS ARM64 media and the **Ubuntu
  64-bit Arm** guest type. In macOS Terminal, `uname -m` must report `arm64`.

## Address plan

| Role | VM name | Ubuntu edition | RAM | vCPU | Disk | Lab address |
|---|---|---|---:|---:|---:|---|
| CA | `pki-ca` | Server 24.04 LTS | 1536 MB | 1 | 8 GB | `10.77.0.10/24` |
| Web server | `pki-server` | Server 24.04 LTS | 2048 MB | 2 | 10 GB | `10.77.0.20/24` |
| Client | `pki-client` | Desktop 24.04 LTS | 4096 MB | 2 | 20 GB | `10.77.0.30/24` |

The NAT adapter receives its address, gateway, and DNS configuration from
VMware. The lab adapter has no gateway and no DNS server.

## Evidence guidance

Provide an annotated screenshot for each numbered section. Mark the relevant
VM name, address, interface, service result, or webpage in each screenshot.
One screenshot per section is normally sufficient; use more if one image
cannot show the required evidence legibly. Do not include passwords.

# Section 1: Obtain the software

## 1.1 Install VMware

Complete only the subsection for your host platform.

### Windows - VMware Workstation

Download VMware Workstation Pro from the official Broadcom distribution
channel provided by your course. Install it with the default virtual-network
components. Restart Windows if requested. Record the version from **Help >
About VMware Workstation**.

### Apple Silicon macOS - VMware Fusion

Download VMware Fusion Pro from the official Broadcom distribution channel
provided by your course. Move Fusion to Applications, open it, approve the
requested macOS permissions, and complete its first-run configuration. Record
the version from **VMware Fusion > About VMware Fusion**.

## 1.2 Download Ubuntu

Download the latest point release for your host:

- **Windows:** Ubuntu Server and Ubuntu Desktop 24.04 LTS, AMD64.
- **Apple Silicon macOS:** Ubuntu Server and Ubuntu Desktop 24.04 LTS, ARM64.

Use only official Ubuntu download servers. Download the published `SHA256SUMS`
file and calculate each local file's digest with the command for your host.

Windows PowerShell:

```powershell
Get-FileHash -Algorithm SHA256 .\ubuntu-24.04*-live-server-amd64.iso
Get-FileHash -Algorithm SHA256 .\ubuntu-24.04*-desktop-amd64.iso
```

macOS Terminal:

```bash
shasum -a 256 ~/Downloads/ubuntu-24.04*-live-server-arm64.iso
shasum -a 256 ~/Downloads/ubuntu-24.04*-desktop-arm64.iso
```

Compare the complete values. Do not continue if either digest differs.

## Questions

1. Why does checking a published hash provide more assurance than checking
   only the ISO filename?
2. Which CPU architecture will your Ubuntu guests use, and why?

# Section 2: Create and install the CA VM

## 2.1 Create the virtual machine

### Windows - VMware Workstation

1. Select **File > New Virtual Machine**.
2. Select **Custom (advanced)** so each resource can be reviewed.
3. Accept the current Workstation hardware compatibility.
4. Select **I will install the operating system later**.
5. Select **Linux**, then **Ubuntu 64-bit**.
6. Name the VM `pki-ca` and choose a storage location with adequate space.
7. Assign 1 processor with 1 core.
8. Assign 1536 MB RAM.
9. Select **Use network address translation (NAT)**.
10. Accept the recommended controller types.
11. Create a new 8 GB dynamically allocated virtual disk stored as a single
    file unless course policy requires split files.
12. Finish the wizard, then open **VM > Settings**.
13. Attach the Ubuntu Server ISO to **CD/DVD** and select **Connect at power
    on**.

### Apple Silicon macOS - VMware Fusion

1. Select **File > New** and **Install from disc or image**.
2. Select the Ubuntu Server ARM64 ISO.
3. Disable Linux Easy Install if Fusion offers it.
4. Select **Ubuntu 64-bit Arm** as the guest type.
5. Choose **Customize Settings**, save the VM as `pki-ca`, and open Settings.
6. Configure 1 processor core, 1536 MB RAM, and an 8 GB virtual disk.
7. Configure the existing Network Adapter as **Share with my Mac**, ensure it
   is connected, and start the VM.

Do not clone this VM to create the other roles. Separate installations avoid
duplicate machine identifiers and MAC addresses.

## 2.2 Install Ubuntu Server

Start the VM and complete the Ubuntu Server installer:

- Language and keyboard: appropriate for your system
- Installation type: Ubuntu Server
- Network: accept DHCP on the NAT adapter
- Proxy: blank unless your institution requires one
- Mirror: accept the working default
- Storage: use the entire 8 GB virtual disk
- Profile hostname: `pki-ca`
- Username: your normal lab administration username
- Password: unique to the lab and not shown in screenshots
- OpenSSH Server: select it
- Additional server snaps: none required

Reboot when prompted and disconnect the installation ISO if VMware does not do
so automatically.

## 2.3 Update and verify

```bash
sudo apt update
sudo apt full-upgrade -y
sudo apt install -y git openssl openssh-server curl net-tools
git clone https://github.com/giacobe/static-pki-lab.git ~/pki-lab
test -f ~/pki-lab/scripts/preflight-precursor-vm.sh
sudo reboot
```

After reboot:

```bash
hostnamectl
cat /etc/os-release
uname -m
ip -brief address
ip route
systemctl is-active ssh
curl -I https://archive.ubuntu.com/
```

Expected: Ubuntu 24.04, architecture `x86_64` on Windows or `aarch64` on Apple
Silicon, active SSH, a DHCP address and default route on the NAT adapter, a
successful response from the Ubuntu archive, and the lab repository at
`~/pki-lab`.

# Section 3: Create and install the web-server VM

Create a separate VM from the same Server ISO. Do not duplicate the CA VM. Use:

- VM name and Ubuntu hostname: `pki-server`
- RAM: 2048 MB
- CPU: 2 cores
- Disk: 10 GB, dynamically allocated
- OpenSSH Server: do not select it
- NAT networking: **NAT** in Workstation or **Share with my Mac** in Fusion

After installation:

```bash
sudo apt update
sudo apt full-upgrade -y
sudo apt install -y git openssl apache2 openssh-client curl net-tools
git clone https://github.com/giacobe/static-pki-lab.git ~/pki-lab
test -f ~/pki-lab/scripts/preflight-precursor-vm.sh
sudo systemctl enable --now apache2
sudo reboot
```

Verify:

```bash
hostnamectl
cat /etc/os-release
uname -m
ip -brief address
ip route
systemctl is-active apache2
curl -I http://127.0.0.1/
```

Do not enable `mod_ssl` and do not configure HTTPS.

# Section 4: Create and install the client VM

## 4.1 Create the virtual machine

Create a third, independent VM with:

- VM name: `pki-client`
- Guest type: **Ubuntu 64-bit** on Windows or **Ubuntu 64-bit Arm** on macOS
- Ubuntu Desktop 24.04 LTS ISO matching the host architecture
- 2 processor cores
- 4096 MB RAM
- 20 GB dynamically allocated disk
- NAT networking

## 4.2 Install Ubuntu Desktop

Use the interactive graphical installer. Select a normal installation, erase
only the VM's virtual disk, and create a normal administrative account. Set
the computer name to `pki-client` if the installer presents that option.

After the installation:

```bash
sudo hostnamectl set-hostname pki-client
sudo apt update
sudo apt full-upgrade -y
sudo apt install -y git openssl openssh-client curl net-tools
git clone https://github.com/giacobe/static-pki-lab.git ~/pki-lab
test -f ~/pki-lab/scripts/preflight-precursor-vm.sh
sudo reboot
```

Verify that Firefox opens, then record:

```bash
hostnamectl
cat /etc/os-release
uname -m
ip -brief address
ip route
curl -I https://archive.ubuntu.com/
```

# Section 5: Create the isolated VMware network

## 5.1 Create the isolated network

Power off all three VMs, then complete only the subsection for your host.

### Windows - VMware Workstation LAN Segment

1. Select `pki-ca`, then **VM > Settings**.
2. Select its existing **Network Adapter**.
3. Click **LAN Segments**.
4. Click **Add**, name the segment `PKI-LAB`, and click **OK**.
5. Leave the existing adapter set to NAT.

A Workstation LAN Segment is shared only by VMs assigned to it and does not
provide DHCP. Do not substitute Host-only or Bridged networking.

### Apple Silicon macOS - VMware Fusion custom network

1. Select **VMware Fusion > Settings** or **Preferences**, then **Network**.
2. Unlock the pane with the macOS administrator password if requested.
3. Click **+** to create a custom network and name it `PKI-LAB` if permitted.
   Record its assigned `vmnet` identifier.
4. Disable **Allow virtual machines on this network to connect to external
   networks (using NAT)**.
5. Disable **Connect the host Mac to this network**.
6. Disable **Provide addresses on this network via DHCP**.
7. Set subnet `10.77.0.0` and mask `255.255.255.0` if Fusion requests them,
   then click **Apply**.

Do not substitute Fusion's default **Private to my Mac** network. The custom
network must provide no gateway, DHCP, physical-network path, or host access.

# Section 6: Add a second adapter to every VM

For each powered-off VM, follow the instructions for your host.

### Windows - VMware Workstation

1. Open **VM > Settings**.
2. Confirm the existing adapter is **NAT** and **Connect at power on** is
   selected. This is Adapter 1.
3. Click **Add > Network Adapter > Finish**.
4. Select the new adapter.
5. Select **LAN segment**, then choose `PKI-LAB`.
6. Select **Connect at power on**. This is Adapter 2.
7. Click **OK**.

### Apple Silicon macOS - VMware Fusion

1. Open **Virtual Machine > Settings**.
2. Confirm Adapter 1 uses **Share with my Mac** and is enabled.
3. Click **Add Device > Network Adapter**.
4. Configure Adapter 2 to use the custom `PKI-LAB` network and enable it.

Each VM must now have exactly two network adapters: one NAT adapter and one
adapter attached to the isolated `PKI-LAB` network.

# Section 7: Configure static lab addresses

Start all three VMs. On each VM, identify the two guest interfaces:

```bash
ip -brief link
ip -4 -brief address
ip route
```

The NAT interface already has a DHCP address and owns the default route. The
new isolated-network interface normally has no IPv4 address. Record both
interface names. Do not assume names such as `ens33` or `ens37`; yours may
differ.

If the course setup scripts are installed in `~/pki-lab`, configure only the
isolated-network interface. Replace `ens37` with the interface you identified:

```bash
cd ~/pki-lab
sudo bash scripts/configure-lab-network.sh ca abc1234 ens37
sudo bash scripts/configure-lab-network.sh server abc1234 ens37
sudo bash scripts/configure-lab-network.sh client abc1234 ens37
```

Run only the command matching that VM, and replace `abc1234` with your user
ID. The script does not alter the NAT interface.

Verify the result on every VM:

```bash
hostname
ip -4 -brief address
ip route
getent hosts abc1234.psu.edu
```

Expected:

- The role's `10.77.0.x/24` address is on the isolated-network interface.
- A different interface retains its VMware NAT address.
- The default route uses the NAT interface, not the lab interface.
- `abc1234.psu.edu` resolves to `10.77.0.20`.

# Section 8: Verify dual-network operation

Run these tests on every VM:

```bash
ping -c 2 10.77.0.10
ping -c 2 10.77.0.20
ping -c 2 10.77.0.30
getent hosts archive.ubuntu.com
curl -I https://archive.ubuntu.com/
```

All lab addresses must respond, DNS must work through NAT, and the HTTPS
request to the Ubuntu archive must succeed. The lab interface must not have a
default gateway.

## Questions

1. Which adapter carries traffic to `10.77.0.0/24`?
2. Which adapter carries Internet traffic?
3. Why must the lab interface omit a default gateway?

# Section 9: Build the personalized HTTP site

Perform this section on `pki-server`.

## 9.1 Create the content

```bash
STUDENT_ID=abc1234
SERVER_NAME="${STUDENT_ID}.psu.edu"

sudo install -d -o root -g root -m 755 "/var/www/${SERVER_NAME}"
sudo nano "/var/www/${SERVER_NAME}/index.html"
```

Replace `abc1234` below with your student ID, then enter this content in
`nano`:

```html
<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><title>abc1234 HTTP Lab</title></head>
<body>
  <h1>abc1234 HTTP Web Server</h1>
  <p>Prepared for the Three-VM PKI Lab.</p>
  <p>This precursor site uses HTTP, not HTTPS.</p>
</body>
</html>
```

Save the file by pressing **Ctrl+O**, press **Enter** to confirm the filename,
and then press **Ctrl+X** to exit `nano`.

The student ID must be obvious in both the browser title and page heading.

## 9.2 Configure an HTTP-only virtual host

```bash
sudo nano /etc/apache2/sites-available/pki-lab-http.conf
```

Replace every occurrence of `abc1234` with your student ID, then enter:

```apache
<VirtualHost *:80>
    ServerName abc1234.psu.edu
    DocumentRoot /var/www/abc1234.psu.edu
    DirectoryIndex index.html

    ErrorLog ${APACHE_LOG_DIR}/pki-lab-http-error.log
    CustomLog ${APACHE_LOG_DIR}/pki-lab-http-access.log combined

    <Directory /var/www/abc1234.psu.edu>
        Require all granted
    </Directory>
</VirtualHost>
```

Press **Ctrl+O**, **Enter**, and **Ctrl+X** to save and exit. Then enable the
site:

```bash
sudo a2dissite 000-default
sudo a2ensite pki-lab-http
sudo apache2ctl configtest
sudo systemctl restart apache2
```

Expected configuration result: `Syntax OK`.

## 9.3 Prove that HTTPS is absent

```bash
sudo a2query -m ssl
sudo ss -lntp | grep -E ':(80|443)\b'
```

Expected: `ssl` is not enabled, Apache listens on TCP port 80, and no process
listens on TCP port 443.

# Section 10: Test the HTTP site from the client

Perform these tests on `pki-client`, replacing the example ID:

```bash
getent hosts abc1234.psu.edu
curl -v http://abc1234.psu.edu/
curl -vk --connect-timeout 5 https://abc1234.psu.edu/
```

The HTTP request must return the personalized page. The HTTPS connection must
fail because nothing listens on port 443; `-k` affects certificate validation
only and cannot make an absent HTTPS service work.

Open Firefox and visit:

```text
http://abc1234.psu.edu/
```

Capture an annotated screenshot showing the personalized student ID in the
page and the `http://` URL in Firefox. Do not proceed if Firefox silently
changes the URL to HTTPS; enter the complete HTTP URL again and confirm the
server has no listener on port 443.

## Questions

1. Which machine resolved the personalized name?
2. Which machine supplied the webpage?
3. Why is this connection unsuitable for confidential data?

# Section 11: Final readiness check

Run the precursor preflight script on each VM before using the checklist:

```bash
sudo bash scripts/preflight-precursor-vm.sh ca abc1234
sudo bash scripts/preflight-precursor-vm.sh server abc1234
sudo bash scripts/preflight-precursor-vm.sh client abc1234
```

Run only the command matching that VM and replace the example ID. Resolve
every failure before taking the final snapshots.

The environment is ready for the PKI lab only if every item passes:

| Check | Required result |
|---|---|
| Three independent VMs | `pki-ca`, `pki-server`, `pki-client` |
| Ubuntu versions | 24.04 LTS |
| NAT adapters | Connected and Internet-capable |
| Lab adapters | Connected to the isolated `PKI-LAB` network |
| Host-specific isolation | Workstation LAN Segment, or Fusion custom network with host connection, NAT, and DHCP disabled |
| Static lab addresses | `.10`, `.20`, and `.30` as assigned |
| Lab routing | Direct `/24`; no gateway on lab interface |
| Name resolution | Student hostname maps to `10.77.0.20` |
| HTTP | Personalized page loads from the client |
| HTTPS | No listener on TCP 443 |
| CA state | No CA key or certificate exists yet |

Shut down all three VMs cleanly. Take one snapshot of each VM named
`Precursor complete - NAT still connected`.

Do not disconnect or delete the NAT adapters yet. The PKI lab begins by
disconnecting Adapter 1 on all three VMs and then proving that only the
isolated `10.77.0.0/24` network remains.

## References

- VMware Workstation Pro 17 User Guide:
  https://techdocs2-prod.adobecqms.net/content/dam/broadcom/techdocs/us/en/pdf/vmware/desktop-hypervisors/workstation/vmware-workstation-pro-17-0.pdf
- VMware Fusion Pro 13 User Guide:
  https://techdocs2-prod.adobecqms.net/content/dam/broadcom/techdocs/us/en/pdf/vmware/desktop-hypervisors/fusion/vmware-fusion-pro-13.pdf
- VMware Fusion networking types:
  https://knowledge.broadcom.com/external/article/303393/
- Ubuntu 24.04 LTS AMD64 downloads: https://releases.ubuntu.com/24.04/
- Ubuntu 24.04 LTS ARM64 downloads:
  https://cdimage.ubuntu.com/ubuntu/releases/24.04/release/
