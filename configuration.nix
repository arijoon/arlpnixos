# Top-level system configuration for the arlp laptop.
# Pulls in the focused modules under ./modules.
{ pkgs, self, ... }:
{
  imports = [
    ./modules/users.nix
    ./modules/docker.nix
    ./modules/hardening.nix
    ./modules/vpn.nix
    ./modules/nvidia.nix
    ./modules/desktop.nix
    ./modules/ssh.nix
  ];

  # Bootloader — UEFI / systemd-boot.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "arlp";
  networking.networkmanager.enable = true;

  # Locale / time — adjust to taste.
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";

  nixpkgs.config.allowUnfree = true;

  # Flakes are how this system is built; keep them on for rebuilds.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "arlp"
  ];

  # Pin `nixpkgs` (registry + nix-path) to THIS system's nixpkgs input, so that
  # `nix run/shell/build nixpkgs#...` and `<nixpkgs>` resolve to the pinned
  # 26.05 nixpkgs (matching the running system) instead of fetching unstable
  # from GitHub. Covers root/sudo too. (Your home-manager profile separately
  # pins these in the user registry for the arlp user.)
  nix.registry.nixpkgs.flake = self.inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];

  # A few baseline tools available before home-manager is switched.
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    htop
    btop
  ];

  # Do not change lightly — matches the release this config targets.
  system.stateVersion = "26.05";
}
