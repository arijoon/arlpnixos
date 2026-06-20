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
    ./modules/openrgb.nix
    ./modules/tuxedo.nix
    ./modules/rhino-cache.nix
  ];

  # Bootloader — UEFI / systemd-boot.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Intel Wi-Fi 6E AX211: on ~every other cold boot the WiFi PCIe function
  # (0000:00:14.3) enumerates on the bus but `iwlwifi` never binds to it — the
  # journal shows the PCI device but zero iwlwifi lines, while Bluetooth (the
  # other half of the same CNVi module) comes up fine. A reboot "fixes" it.
  # Root cause is a PCIe Active-State Power Management race that leaves the
  # WiFi function in a bad link/power state during early probe. Disabling ASPM
  # removes the race. (Minor cost: slightly higher idle power draw.)
  boot.kernelParams = [ "pcie_aspm=off" ];

  networking.hostName = "arlp";
  networking.networkmanager.enable = true;

  # DNS: prefer Cloudflare (1.1.1.1 primary, 1.0.0.1 secondary). insertNameservers
  # prepends these to whatever DHCP hands out, so they're the main resolvers but
  # DHCP DNS still works as a fallback.
  # To force ONLY these (ignore DHCP DNS entirely — can break captive portals /
  # corporate split-DNS), instead use:
  #   networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  #   networking.networkmanager.dns = "none";
  networking.networkmanager.insertNameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];

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
