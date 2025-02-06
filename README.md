# Installation Script

This repository contains an automated installation script to set up essential software and virtualization tools on a Linux system.

## Usage
You can run this script directly from the repository without downloading it manually:

### **Run via `curl`**
```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/akhil-flycatch/Scripts/main/installation-script.sh)"
```

### **Run via `wget`**
```bash
wget -qO- https://raw.githubusercontent.com/akhil-flycatch/Scripts/main/installation-script.sh | sudo bash
```

## Features
- Checks if CPU supports virtualization (VT-x for Intel, AMD-V for AMD).
- Installs required virtualization packages (QEMU, KVM, Libvirt, etc.).
- Configures `libvirtd` service and user permissions.
- Installs essential software including:
  - `flatpak`, `net-tools`, `htop`, `git`, `docker` , `curl` , `vim`
  - `Chrome`, `Brave`, `Firefox`, `DBeaver`, `Postman`, `OBS Studio`, `Flatseal`
- Sets up Flatpak and adds the Flathub repository.

## Requirements
- **Linux-based system** (Debian/Ubuntu-based distributions recommended).
- **Internet connection** to download necessary packages.
- **Root privileges** to install software and configure the system.

## Notes
- If CPU virtualization is not enabled, the script will prompt you to enable VT-x/AMD-V in BIOS before proceeding.
- After running the script, **restart your system** to apply changes properly.

