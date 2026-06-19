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
  environment.systemPackages = with pkgs; [
    openvpn
    iproute2
    iptables
  ];

  # TUN device for the OpenVPN tunnel inside the namespace.
  boot.kernelModules = [ "tun" ];

  # vopono manages its own per-namespace firewall rules; the host firewall stays
  # as configured elsewhere. Nothing else is required here — vopono escalates via
  # sudo (arlp is in the `wheel` group, see users.nix).
}
