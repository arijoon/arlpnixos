# Docker (rootful) + compose v2.
#
# Note on VPN interaction: dockerd holds /run/xtables.lock while configuring
# iptables. vopono (via your `with-vpn` script) also touches iptables when
# setting up the network namespace, and the two can race. `with-vpn` already
# ships a `--check-xtables` flag (see network.nix in your home-manager repo)
# that aborts if the lock is held — use it while docker is running.
{ pkgs, ... }:
{
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # `docker compose ...` (v2 plugin) + the standalone binary.
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
