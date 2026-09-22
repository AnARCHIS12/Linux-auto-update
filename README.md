<p align="center">
  <img src="assets/linux-auto-update.svg" alt="Linux Auto Update" width="180">
</p>

<h1 align="center">Linux Auto Update</h1>

<p align="center">
  Automatic system updates for Linux distributions.
</p>

<p align="center">
  <a href="https://github.com/AnARCHIS12/Linux-auto-update/blob/main/LICENSE"><img src="https://img.shields.io/github/license/AnARCHIS12/Linux-auto-update?style=flat-square" alt="License"></a>
  <a href="https://github.com/AnARCHIS12/Linux-auto-update"><img src="https://img.shields.io/github/repo-size/AnARCHIS12/Linux-auto-update?style=flat-square" alt="Repository size"></a>
  <a href="https://github.com/AnARCHIS12/Linux-auto-update/commits/main"><img src="https://img.shields.io/github/last-commit/AnARCHIS12/Linux-auto-update?style=flat-square" alt="Last commit"></a>
  <a href="https://github.com/AnARCHIS12/Linux-auto-update"><img src="https://img.shields.io/github/stars/AnARCHIS12/Linux-auto-update?style=flat-square" alt="Stars"></a>
</p>

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

## Logo

The project logo is a red-and-black penguin representing Linux and automatic update cycles.

## License

MIT
