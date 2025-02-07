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
apt install -y flatpak net-tools htop git ca-certificates vim curl openssh-server
systemctl enable --now ssh
systemctl start ssh

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
flatpak install -y flathub com.github.tchx84.Flatseal



# Define the download URL for JetBrains Toolbox (Latest Version)
TOOLBOX_URL="https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.3.37797.tar.gz"
INSTALL_DIR="/opt/jetbrains-toolbox"
sudo apt update -y
sudo apt install -y fuse libfuse2
wget -O jetbrains-toolbox.tar.gz "$TOOLBOX_URL"
tar -xzf jetbrains-toolbox.tar.gz
EXTRACTED_DIR=$(find . -maxdepth 1 -type d -name "jetbrains-toolbox*" | head -n 1)
sudo mv "$EXTRACTED_DIR" "$INSTALL_DIR"
sudo ln -sf "$INSTALL_DIR/jetbrains-toolbox" /usr/local/bin/jetbrains-toolbox
wget -O "$INSTALL_DIR/jetbrains-toolbox.png" "https://img.icons8.com/?size=100&id=vQoQDtNbTLVE&format=png&color=000000"
cat <<EOF | sudo tee /usr/share/applications/jetbrains-toolbox.desktop
[Desktop Entry]
Name=JetBrains Toolbox
Exec=$INSTALL_DIR/jetbrains-toolbox
Icon=$INSTALL_DIR/jetbrains-toolbox.png
Type=Application
Categories=Development;
EOF

rm -f jetbrains-toolbox.tar.gz



# Install Visual Studio Code
wget -O vscode.deb "https://go.microsoft.com/fwlink/?LinkID=760868"
dpkg -i vscode.deb || true
apt-get install -f -y
rm -f vscode.deb

# Install Docker Desktop
wget -O docker-desktop-amd64.deb "https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb"
chown $USER:$USER ./docker-desktop-amd64.deb
apt-get install -y ./docker-desktop-amd64.deb

#removing the docker-desktop installation file
rm -f docker-desktop-amd64.deb

# Path to the autostart folder
AUTOSTART_DIR=/home/flycatch/.config/autostart

if [ -f "$AUTOSTART_DIR/docker-desktop.desktop" ]; then
    rm -f "$AUTOSTART_DIR/docker-desktop.desktop"
    echo "Existing Docker Desktop autostart entry removed."
else
    echo "No existing Docker Desktop autostart entry found."
fi


if [ ! -f "$AUTOSTART_DIR/docker-desktop.desktop" ]; then
    # Create the .desktop file for Docker Desktop
    cat <<EOL > "$AUTOSTART_DIR/docker-desktop.desktop"
[Desktop Entry]
Name=Docker Desktop
Comment=Start Docker Desktop on login
Exec=/opt/docker-desktop/bin/docker-desktop
Type=Application
X-GNOME-Autostart-enabled=true
EOL
    echo "Docker Desktop has been added to startup applications."
else
    echo "Docker Desktop startup entry already exists."
fi

ufw enable
echo "Firewall is active"

echo "Base software installation completed. Please restart your system."
