# Live installer ISO.
#
# Embeds this flake at /etc/nixos-config and ships an `install-laptop` helper
# that partitions+encrypts (disko), then installs the `arlp-laptop` config.
#
# Build + flash:
#   nix build .#installer-iso
#   sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M conv=fsync status=progress
#
# On the laptop (booted from USB): connect wifi (`nmtui`), then:
#   sudo install-laptop /dev/nvme0n1     # pass your target disk
# An internet connection is needed during install to fetch the package closure
# (standard NixOS flake install).
{
  self,
  pkgs,
  lib,
  ...
}:
let
  disko-cli = self.inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko;

  install-laptop = pkgs.writeShellScriptBin "install-laptop" ''
    set -eu
    SRC=/etc/nixos-config
    WORK=/tmp/nixos-config
    DEV="''${1:-}"

    echo "== arlp laptop installer =="
    rm -rf "$WORK"
    # -L dereferences the /etc/nixos-config store symlink so we get real,
    # writable files (a plain `cp -r` copies the symlink and lands back in the
    # read-only Nix store).
    cp -rL "$SRC" "$WORK"
    chmod -R u+w "$WORK"

    if [ -n "$DEV" ]; then
      sed -i "s|device = \"/dev/nvme0n1\";|device = \"$DEV\";|" "$WORK/disko.nix"
    fi

    echo
    echo "Disk to be ERASED: $(grep -m1 'device =' "$WORK/disko.nix")"
    echo "NVIDIA/Intel bus IDs in $WORK/modules/nvidia.nix:"
    grep -nE 'intelBusId|nvidiaBusId' "$WORK/modules/nvidia.nix" || true
    echo
    echo "Edit files under $WORK now if any of the above is wrong"
    echo "(disk device, PCI bus IDs from 'lspci | grep -E \"VGA|3D\"')."
    echo
    printf 'Type ERASE to partition + encrypt + install: '
    read -r ans
    [ "$ans" = "ERASE" ] || { echo "aborted."; exit 1; }

    # destroy + format (incl. LUKS prompt) + mount under /mnt
    ${disko-cli}/bin/disko --mode disko "$WORK/disko.nix"

    # Optional: capture exact hardware (disko already owns the filesystems):
    #   nixos-generate-config --no-filesystems --root /mnt --dir /tmp/hw
    #   cp /tmp/hw/hardware-configuration.nix "$WORK/hardware-configuration.nix"

    nixos-install --flake "$WORK#arlp-laptop"

    # Leave an EDITABLE copy of this flake on the installed system so you can
    # make changes + `nixos-rebuild switch` later without the USB.
    install -d -m 0755 /mnt/etc/nixos
    cp -rT "$WORK" /mnt/etc/nixos
    rm -f /mnt/etc/nixos/flake.lock.bak 2>/dev/null || true

    echo
    echo "Install complete."
    echo "  - Set the user password:  nixos-enter --root /mnt -c 'passwd arlp'"
    echo "  - Your config now lives at /etc/nixos on the new system. After reboot,"
    echo "    edit it and apply with:"
    echo "      sudo nixos-rebuild switch --flake /etc/nixos#arlp-laptop"
  '';
in
{
  # The flake source, available on the booted ISO.
  environment.etc."nixos-config".source = self.outPath;

  environment.systemPackages = with pkgs; [
    install-laptop
    disko-cli
    git
    gptfdisk
    cryptsetup
    networkmanager
  ];

  # Wifi from the ISO for the online install step.
  networking.networkmanager.enable = true;
  networking.wireless.enable = lib.mkForce false; # avoid clash with NM on the ISO

  # Flakes for nixos-install.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # The upstream installer profile pulls in ZFS support, which warns about this
  # default. We don't use ZFS; adopt the safer 26.11 default to silence it.
  boot.zfs.forceImportRoot = false;

  image.fileName = lib.mkForce "arlp-installer.iso";
}
