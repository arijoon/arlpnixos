# arlp laptop — NixOS

NixOS system flake for an Intel + NVIDIA laptop, delivered as a custom installer
ISO. Full-disk LUKS encryption, Docker, kernel hardening, vopono VPN support, and
two desktop sessions (KDE Plasma 6 + suckless dwm).

User-level config (kitty, neovim, zsh, the `with-vpn`/vopono wrapper, rofi theme,
flameshot) lives in the **separate** standalone home-manager flake at
`~/.dotfiles/home-manager` (profile `arlp`), so `home-manager switch` runs
independently of `nixos-rebuild`.

## Layout

| File | Purpose |
|------|---------|
| `flake.nix` | `nixosConfigurations.arlp-laptop`, `.installer`, `packages.installer-iso` |
| `disko.nix` | UEFI ESP + LUKS → btrfs (`@`,`@home`,`@nix`) + encrypted swapfile |
| `hardware-configuration.nix` | Intel+NVIDIA laptop initrd/microcode (no `fileSystems` — disko owns those) |
| `configuration.nix` | bootloader, hostname, locale, imports modules |
| `modules/docker.nix` | rootful Docker + compose v2 |
| `modules/hardening.nix` | blacklisted kernel modules + sysctls + latest kernel |
| `modules/vpn.nix` | openvpn/tun/iptables for vopono |
| `modules/nvidia.nix` | NVIDIA proprietary + Intel, PRIME offload |
| `modules/desktop.nix` | X11, SDDM, Plasma 6, dwm session, pipewire, bluetooth |
| `modules/dwm/config.h` | patched dwm bindings (Alt+1-9, Alt+j/k, Alt+p rofi, Alt+c close, Print→flameshot, kitty) |
| `modules/installer.nix` | ISO that embeds this flake + the `install-laptop` helper |

## Build & flash the installer

```sh
nix build .#installer-iso
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M conv=fsync status=progress
```

## Install on the laptop

Boot the USB, then:

```sh
nmtui                              # connect wifi (needed to fetch packages)
sudo install-laptop /dev/nvme0n1   # your target disk (lsblk)
```

### What is `install-laptop`?

It's a one-time bootstrap helper that **only exists inside the live USB
environment** — it is not part of the installed system. It just automates the
three manual steps you'd otherwise type by hand:

1. copies this flake to a writable dir and lets you review/edit the disk device
   and PCI bus IDs,
2. runs `disko` to partition + LUKS-encrypt + mount the disk (prompts for your
   new disk passphrase),
3. runs `nixos-install --flake …#arlp-laptop`, then **copies the flake to
   `/etc/nixos` on the new system** so you have an editable copy to rebuild from.

(If you'd rather do it manually instead of using the script, those three
commands are all there is to it.)

Set the user password before rebooting:

```sh
nixos-enter --root /mnt -c 'passwd arlp'
```

## Making changes after install — `nixos-rebuild`

You do **not** need the USB again. The flake lives at `/etc/nixos` on the
installed system. Edit it and apply:

```sh
sudo $EDITOR /etc/nixos/modules/desktop.nix   # or whatever you want to change
sudo nixos-rebuild switch --flake /etc/nixos#arlp-laptop
```

Recommended: push this repo to a git remote and `git clone` it on the laptop
(e.g. into `~/projects/laptop`), so `/etc/nixos` and your dev copy stay in sync.
You can rebuild from any path:

```sh
sudo nixos-rebuild switch --flake ~/projects/laptop#arlp-laptop
```

Rebuilding the ISO is only needed if you want a fresh installer for another
machine — day-to-day changes are just `nixos-rebuild switch`.

## Before installing — fill these placeholders

1. **Disk device** — `disko.nix` (`device = "/dev/nvme0n1"`). `install-laptop`
   can override it via its argument; confirm with `lsblk`.
2. **PRIME bus IDs** — `modules/nvidia.nix` `intelBusId` / `nvidiaBusId`.
   `lspci | grep -E 'VGA|3D'` → `00:02.0` ⇒ `PCI:0:2:0`, `01:00.0` ⇒ `PCI:1:0:0`.
3. **`hardware.nvidia.open`** — `modules/nvidia.nix`. `false` (proprietary) is
   safe; set `true` only on Turing (RTX 20xx / GTX 16xx) or newer.

## First boot

SDDM offers **Plasma** and **dwm** sessions.

dwm bindings (Alt = mod): `Alt+1..9` workspaces, `Alt+j/k` focus, `Alt+p` rofi,
`Alt+c` close, `Alt+Shift+Return` kitty, `PrintScreen` flameshot.

Then apply your home config:

```sh
git clone <your dotfiles> ~/.dotfiles
cd ~/.dotfiles/home-manager
nix run .#home-manager -- switch --flake .#arlp
```

## VPN (vopono / PIA) — one-time runtime setup

The `with-vpn` wrapper ships from home-manager (`network.nix`). On the laptop:

```sh
vopono sync                                   # fetch PIA configs
$EDITOR ~/.config/vopono/pia/openvpn/auth.txt # line1 PIA user, line2 password
with-vpn -- curl -s ifconfig.me               # defaults to switzerland
with-vpn --check-xtables -- firefox           # use --check-xtables while docker runs
```

## Hardening notes

`modules/hardening.nix` blacklists exploit-prone modules (ksmbd, dccp, sctp,
n_gsm, rds, tipc, rare filesystems, vivid, …), tracks the latest stable kernel,
and sets conservative sysctls. Disabling unprivileged user namespaces (a strong
CVE-2024-1086-class mitigation) is left commented out because it breaks the
Chromium/Electron sandbox and the landrun `sandbox-run` helper — opt in there if
you want it.
