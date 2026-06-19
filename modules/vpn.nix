# System support for vopono (used by your `with-vpn` script in home-manager's
# network.nix, which wraps `pkgs-latest.vopono`).
#
# vopono runs as your user and escalates with sudo to create a temporary network
# namespace, start OpenVPN inside it, and install an iptables/nftables killswitch.
# The system only needs to provide the binaries it shells out to + the TUN device.
#
# One-time runtime setup (NOT in nix — credentials are secrets):
#   vopono sync                 # fetch PrivateInternetAccess server lists/configs
#   $EDITOR ~/.config/vopono/pia/openvpn/auth.txt
#     line 1: PIA username
#     line 2: PIA password
#
# Then (from the home-manager `with-vpn` wrapper):
#   with-vpn -- curl -s ifconfig.me        # defaults to the switzerland server
#   with-vpn 'us-*' -- firefox
#   with-vpn --check-xtables -- some-cmd   # use while docker is running
{ pkgs, ... }:
{
  # OpenVPN provider backend + the tools vopono invokes.
  # wireguard-tools is also here for the PIA-WireGuard-via-NetworkManager path
  # (see the comment block at the bottom of this file) — `wg` for key/config
  # generation, plus it lets `nmcli connection import` parse a wg-quick config.
  environment.systemPackages = with pkgs; [
    openvpn
    iproute2
    iptables
    wireguard-tools
    jq # used by PIA's manual-connections scripts
  ];

  # TUN device for the OpenVPN tunnel inside the namespace.
  boot.kernelModules = [ "tun" ];

  # vopono manages its own per-namespace firewall rules; the host firewall stays
  # as configured elsewhere. Nothing else is required here — vopono escalates via
  # sudo (arlp is in the `wheel` group, see users.nix).

  # --- PIA via WireGuard + NetworkManager (the "app-like" full tunnel) ---------
  # NetworkManager has native WireGuard support and Plasma's network applet shows
  # it as a toggle. There's no PIA package in nixpkgs, so generate the config once
  # with PIA's official scripts, then import it into NetworkManager:
  #
  #   git clone https://github.com/pia-foss/manual-connections
  #   cd manual-connections
  #   sudo PIA_USER=pXXXXXXX PIA_PASS='your-pia-password' \
  #        VPN_PROTOCOL=wireguard DISABLE_IPV6=yes AUTOCONNECT=false \
  #        PIA_PF=false PIA_DNS=true ./run_setup.sh
  #     # pick a region; it writes /etc/wireguard/pia.conf
  #
  #   sudo nmcli connection import type wireguard file /etc/wireguard/pia.conf
  #   nmcli connection modify pia connection.autoconnect no   # optional
  #
  # After import, connect/disconnect from the KDE network/VPN tray applet.
  # Note: PIA rotates the WireGuard key server-side, so if it stops connecting
  # after a while, re-run run_setup.sh and re-import (or `nmcli connection up pia`).
}
