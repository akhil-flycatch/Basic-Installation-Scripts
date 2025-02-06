#!/bin/bash

# Ensure the script is run as sudo
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Use sudo." >&2
    exit 1
fi

# Check if CPU supports virtualization
VIRT_COUNT=$(egrep -c '(vmx|svm)' /proc/cpuinfo)

if [[ $VIRT_COUNT -gt 0 ]]; then
    echo "Virtualization is supported. Proceeding with installation."
    
    # Install required packages
    apt update && apt install -y \
        qemu-kvm qemu-system qemu-utils \
        python3 python3-pip \
        libvirt-clients libvirt-daemon-system \
        bridge-utils virtinst libvirt-daemon virt-manager

    # Ensure libvirtd service is started
    systemctl enable --now libvirtd

    # Start and enable default network in virsh
    virsh net-start default
    virsh net-autostart default

    # Add current user to necessary groups
    USERNAME=$(logname)
    usermod -aG libvirt "$USERNAME"
    usermod -aG libvirt-qemu "$USERNAME"
    usermod -aG kvm "$USERNAME"
    usermod -aG input "$USERNAME"
    usermod -aG disk "$USERNAME"

    echo "Installation and configuration completed. Please restart your system."
else
    echo "Virtualization is not enabled. Please enable VT-x (Intel) or AMD-V (AMD) in BIOS and rerun this script."
    exit 1
fi

# Install base software
apt install -y flatpak net-tools htop git ca-certificates vim curl

# Add Flatpak repository
add-apt-repository ppa:flatpak/stable -y
apt update
apt install -y flatpak gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install applications using Flatpak
flatpak install -y flathub com.google.Chrome
flatpak install -y flathub com.brave.Browser
flatpak install -y flathub io.dbeaver.DBeaverCommunity
flatpak install -y flathub com.getpostman.Postman
flatpak install -y flathub com.obsproject.Studio
flatpak install -y flathub com.visualstudio.code
flatpak install flathub com.jetbrains.IntelliJ-IDEA-Community
flatpak install flathub com.jetbrains.PyCharm-Community
flatpak install -y flathub com.github.tchx84.Flatseal

# Install Docker using official method
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to Docker group
usermod -aG docker "$USERNAME"

# Install Docker Desktop
apt-get install -y ./docker-desktop-amd64.deb

# Enable and start Docker Desktop service
systemctl --user start docker-desktop
systemctl --user enable docker-desktop

#removing the docker-desktop installation file
rm -f docker-desktop-amd64.deb

echo "Base software installation completed. Please restart your system."

