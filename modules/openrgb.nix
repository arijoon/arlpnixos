# OpenRGB — RGB peripheral control.
#
# `services.hardware.openrgb.enable` does three things we want:
#   - installs the `openrgb` package system-wide (so you can drop the manual
#     `nix build` + ./result symlink in the repo root and just run `openrgb`);
#   - installs the udev rules into the system udev path, which clears the
#     "OpenRGB udev rules are not installed" warning. The rules tag devices
#     with `uaccess`, so your logged-in user gets access — no extra group;
#   - runs the OpenRGB server as a systemd service (harmless; lets clients
#     like the GUI or `openrgb --client` talk to a persistent daemon).
{ ... }:
{
  services.hardware.openrgb.enable = true;

  # Motherboard/RAM/SMBus controllers need the i2c-dev module loaded. Rarely
  # useful on a laptop (the original complaint was just USB peripherals), so
  # left off. To detect motherboard RGB, set this to "amd" or "intel":
  # services.hardware.openrgb.motherboard = "amd";
}
