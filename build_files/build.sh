#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos

mkdir -p "/var/opt" && ln -s "/var/opt" "/opt"
mkdir -p "/var/usrlocal" && ln -s "/var/usrlocal" "/usr/local"
# PowerShell, VSCode
if rpm --import https://packages.microsoft.com/keys/microsoft.asc; then
    dnf5 config-manager addrepo --from-repofile=https://packages.microsoft.com/config/rhel/9/prod.repo --save-filename=microsoft-prod.repo
    dnf5 install -y powershell
    # dnf5 install -y https://github.com/PowerShell/PowerShell/releases/download/v7.5.4/powershell-7.5.4-1.rh.x86_64.rpm
    sed -zi 's@enabled=1@enabled=0@' /etc/yum.repos.d/microsoft-prod.repo

    dnf5 config-manager addrepo --from-repofile=https://packages.microsoft.com/yumrepos/vscode/config.repo --save-filename=vscode.repo
    dnf5 install -y code
    sed -zi 's@enabled=1@enabled=0@' /etc/yum.repos.d/vscode.repo
fi

# Sublime Text
rpm --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
dnf5 config-manager addrepo --from-repofile=https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
dnf5 download -y sublime-text
rpm -i --nodigest sublime-text-*.rpm
sed -zi 's@enabled=1@enabled=0@' /etc/yum.repos.d/sublime-text.repo

# Beyond Compare
dnf5 config-manager addrepo --from-repofile=https://www.scootersoftware.com/scootersoftware.repo
dnf5 install -y bcompare
sed -zi 's@enabled=1@enabled=0@' /etc/yum.repos.d/scootersoftware.repo

# VirtIO paravirtualization drivers for Windows
dnf5 config-manager addrepo --from-repofile=https://fedorapeople.org/groups/virt/virtio-win/virtio-win.repo
# dnf5 install -y virtio-win        # you can get ISOs easily
sed -zi 's@enabled=1@enabled=0@' /etc/yum.repos.d/virtio-win.repo

# Syncthing Tray
dnf5 config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:mkittler/Fedora_42/home:mkittler.repo
dnf5 install -y syncthingtray-qt6 syncthingplasmoid-qt6 syncthingfileitemaction-qt6 syncthingctl-qt6
sed -zi 's@enabled=1@enabled=0@' /etc/yum.repos.d/home:mkittler.repo

# Faugus Launcher
dnf5 -y copr enable faugus/faugus-launcher
dnf5 -y install faugus-launcher
sed -zi 's@enabled=1@enabled=0@' /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:faugus:faugus-launcher.repo

# FirefoxPWA
tee /etc/yum.repos.d/firefoxpwa.repo > /dev/null <<EOF
[firefoxpwa]
name=FirefoxPWA
metadata_expire=7d
baseurl=https://packagecloud.io/filips/FirefoxPWA/rpm_any/rpm_any/\$basearch
gpgkey=https://packagecloud.io/filips/FirefoxPWA/gpgkey
       https://packagecloud.io/filips/FirefoxPWA/gpgkey/filips-FirefoxPWA-912AD9BE47FEB404.pub.gpg
repo_gpgcheck=1
gpgcheck=1
enabled=1
EOF
dnf5 install -y firefoxpwa
sed -zi 's@enabled=1@enabled=0@' /etc/yum.repos.d/firefoxpwa.repo

# Other softwares
echo defaultyes=True | tee -a /etc/dnf/dnf.conf
# Enable Terra
sed -zi 's@enabled=0@enabled=1@' /etc/yum.repos.d/terra.repo
sed -zi 's@enabled=0@enabled=1@' /etc/yum.repos.d/terra-extras.repo
# Enable RPM Fusion
dnf5 config-manager unsetopt rpmfusion-free.enabled rpmfusion-free-updates.enabled rpmfusion-nonfree.enabled rpmfusion-nonfree-updates.enabled
# Topgrade
dnf5 config-manager setopt terra.exclude='nerd-fonts scx-scheds steam python3-protobuf' terra-extras.exclude='nerd-fonts scx-scheds steam python3-protobuf'
dnf5 upgrade -y topgrade
# wavemon (removed in F43)
if ! dnf5 install -y https://web.archive.org/web/20251206132707/https://kojipkgs.fedoraproject.org/packages/wavemon/0.9.6/4.fc43/x86_64/wavemon-0.9.6-4.fc43.x86_64.rpm; then
  dnf5 install -y https://dl.fedoraproject.org/pub/fedora/linux/releases/42/Everything/x86_64/os/Packages/w/wavemon-0.9.6-3.fc42.x86_64.rpm
fi
# https://kojipkgs.fedoraproject.org/packages/wavemon/0.9.6/4.fc43/x86_64/wavemon-0.9.6-4.fc43.x86_64.rpm

dnf5 install -y gparted gsmartcontrol btdu btrfs-heatmap \
                android-tools java-21-openjdk usbview podman-compose \
                cascadia-fonts-all coolercontrol playerctl cmus \
                kitty konsole ksystemlog byobu golly ucblogo ddccontrol ddccontrol-gtk \
                rmlint cava vkmark iotop powertop kcm_systemd firejail earlyoom \
                plasma-workspace-x11 \
                pandoc pandoc-pdf weasyprint cups-pdf \
                android-udev-rules chkconfig cpuinfo gcc-c++ plocate
                # cmake fakeroot mujs patch pigz rhash (included in brew)
                # systemd-standalone-shutdown (incompatible with systemd)
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
