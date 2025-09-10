#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos

# PowerShell
#mkdir -p "/var/opt" && ln -s "/var/opt" "/opt"
#mkdir -p "/var/usrlocal" && ln -s "/var/usrlocal" "/usr/local"

#dnf5 install -y https://packages.microsoft.com/config/rhel/9/packages-microsoft-prod.rpm
#dnf5 install -y powershell

# VS Code
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/vscode.repo > /dev/null
dnf5 install -y code

# Other softwares
echo defaultyes=True | tee -a /etc/dnf/dnf.conf
dnf5 config-manager setopt terra.enabled=1
dnf5 install -y gparted gsmartcontrol cascadia-fonts-all coolercontrol android-tools java-21-openjdk usbview

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

# systemctl enable podman.socket
