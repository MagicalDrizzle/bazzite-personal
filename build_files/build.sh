#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos

# PowerShell
mkdir -p "/var/opt" && ln -s "/var/opt" "/opt"
mkdir -p "/var/usrlocal" && ln -s "/var/usrlocal" "/usr/local"

#if timeout 5s ping -qc 3 packages.microsoft.com; then
#    dnf5 config-manager addrepo --from-repofile=https://packages.microsoft.com/config/rhel/9/prod.repo --save-filename=microsoft-prod.repo
#    dnf5 install -y powershell
#    sed -zi 's@enabled=1@enabled=0@' /etc/yum.repos.d/microsoft-prod.repo
#else
    pwver=$(curl -s https://api.github.com/repos/PowerShell/PowerShell/tags | grep -Pom 1 '[0-9]+\.[0-9]+\.[0-9](?=")')
    dnf5 install -y https://github.com/PowerShell/PowerShell/releases/download/v7.5.4/powershell-7.5.4-1.rh.x86_64.rpm
#fi

# VS Code
rpm --import https://packages.microsoft.com/keys/microsoft.asc
dnf5 config-manager addrepo --from-repofile=https://packages.microsoft.com/yumrepos/vscode/config.repo --save-filename=vscode.repo
dnf5 install -y code
sed -zi 's@enabled=1@enabled=0@' /etc/yum.repos.d/vscode.repo

# Syncthing Tray
dnf5 config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:mkittler/Fedora_42/home:mkittler.repo
dnf5 install -y syncthingtray-qt6 syncthingplasmoid-qt6 syncthingfileitemaction-qt6 syncthingctl-qt6
sed -zi 's@enabled=1@enabled=0@' /etc/yum.repos.d/home:mkittler.repo

# Other softwares
echo defaultyes=True | tee -a /etc/dnf/dnf.conf
# Enable Terra
sed -zi 's@enabled=0@enabled=1@' /etc/yum.repos.d/terra.repo
sed -zi 's@enabled=0@enabled=1@' /etc/yum.repos.d/terra-extras.repo
# Enable RPM Fusion
dnf5 config-manager unsetopt rpmfusion-free.enabled rpmfusion-free-updates.enabled rpmfusion-nonfree.enabled rpmfusion-nonfree-updates.enabled
# Topgrade
dnf5 config-manager setopt terra.exclude='nerd-fonts' terra-extras.exclude='nerd-fonts'
dnf5 upgrade -y topgrade
# wavemon (removed in F43)
dnf5 install -y https://dl.fedoraproject.org/pub/fedora/linux/releases/42/Everything/x86_64/os/Packages/w/wavemon-0.9.6-3.fc42.x86_64.rpm

dnf5 install -y gparted gsmartcontrol btdu btrfs-heatmap \
                android-tools java-21-openjdk usbview \
                cascadia-fonts-all coolercontrol playerctl cmus \
                kitty konsole ksystemlog byobu golly ucblogo ddccontrol ddccontrol-gtk \
                rmlint cava vkmark iotop powertop \
                plasma-workspace-x11
dnf5 install -y --setopt=install_weak_deps=False plasma-discover \
                        plasma-discover-flatpak plasma-discover-kns
# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

# systemctl enable podman.socket
