# Linux Auto Update

Automatic system updates for Linux distributions.

## Features
- Automatic distribution and package-manager detection.
- APT, DNF, Pacman, Zypper, APK, XBPS and Portage.
- Optional Flatpak, Snap and fwupd integrations.
- No automatic reboot by default.
- systemd timer support.
- Reboot-required detection.
- Locking against concurrent updates.

## Usage
```bash
linux-auto-update check
linux-auto-update update
linux-auto-update status
```

## Installation
```bash
git clone https://github.com/AnARCHIS12/Linux-auto-update.git
cd Linux-auto-update
sudo ./install.sh
sudo systemctl enable --now linux-auto-update.timer
```

The updater runs every 6 hours with a randomized delay.

## Supported systems
Debian/Ubuntu/Mint (APT), Fedora/RHEL/Rocky/Alma (DNF), Arch/Manjaro (Pacman), openSUSE (Zypper), Alpine (APK), Void (XBPS), Gentoo (Portage).

## License
MIT
