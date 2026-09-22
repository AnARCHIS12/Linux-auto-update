# Linux Auto Update

<p align="center">
  <img src="assets/linux-auto-update.svg" alt="Linux Auto Update" width="180">
</p>

<p align="center">
  Automatic system updates for Linux distributions.
</p>

<p align="center">

[![License](https://img.shields.io/github/license/AnARCHIS12/Linux-auto-update?style=flat-square)](https://github.com/AnARCHIS12/Linux-auto-update/blob/main/LICENSE)
[![Repository size](https://img.shields.io/github/repo-size/AnARCHIS12/Linux-auto-update?style=flat-square)](https://github.com/AnARCHIS12/Linux-auto-update)
[![Last commit](https://img.shields.io/github/last-commit/AnARCHIS12/Linux-auto-update?style=flat-square)](https://github.com/AnARCHIS12/Linux-auto-update/commits/main)
[![Stars](https://img.shields.io/github/stars/AnARCHIS12/Linux-auto-update?style=flat-square)](https://github.com/AnARCHIS12/Linux-auto-update)

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

## Optional integrations

### Flatpak

Flatpak updates are **enabled by default** when Flatpak is installed.

```bash
linux-auto-update update
```

### Snap

Snap support is available but **disabled by default**.

Enable Snap updates for a manual update:

```bash
sudo LINUX_AUTO_UPDATE_ENABLE_SNAP=1 linux-auto-update update
```

To enable Snap updates for the systemd timer:

```bash
sudo systemctl edit linux-auto-update.service
```

Add:

```ini
[Service]
Environment=LINUX_AUTO_UPDATE_ENABLE_SNAP=1
```

Then reload systemd:

```bash
sudo systemctl daemon-reload
```

### fwupd

fwupd firmware updates are available but **disabled by default**.

Enable fwupd for a manual update:

```bash
sudo LINUX_AUTO_UPDATE_ENABLE_FWUPD=1 linux-auto-update update
```

To enable fwupd for the systemd timer:

```bash
sudo systemctl edit linux-auto-update.service
```

Add:

```ini
[Service]
Environment=LINUX_AUTO_UPDATE_ENABLE_FWUPD=1
```

Then reload systemd:

```bash
sudo systemctl daemon-reload
```

You can check which optional integrations are installed and enabled with:

```bash
linux-auto-update status
```

Example:

```text
Flatpak      : oui (activé)
Snap         : oui (désactivé)
fwupd        : oui (désactivé)
```

## Supported systems

Debian/Ubuntu/Mint (APT), Fedora/RHEL/Rocky/Alma (DNF), Arch/Manjaro (Pacman), openSUSE (Zypper), Alpine (APK), Void (XBPS), Gentoo (Portage).

## Logo

The project logo is a red-and-black penguin representing Linux and automatic update cycles.

## License

MIT
