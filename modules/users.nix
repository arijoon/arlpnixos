# The laptop user `arlp` plus system-wide shell setup.
#
# Home-level config (kitty/vim/zsh/rofi/vpn scripts) is applied separately and
# independently via the standalone home-manager flake in ~/.dotfiles/home-manager:
#   nix run .#home-manager -- switch --flake .#arlp
{ pkgs, ... }:
{
  users.users.arlp = {
    isNormalUser = true;
    description = "arlp";
    extraGroups = [
      "wheel" # sudo (vopono escalates via sudo)
      "docker"
      "networkmanager"
      "video"
      "audio"
    ];
    shell = pkgs.zsh;
    # Set an initial password at install time, or use `passwd` on first login.
    # initialPassword = "changeme";
  };

  # zsh must be enabled system-wide so it is a valid login shell and so global
  # completion/compinit is wired up. The home-manager zsh config layers on top.
  programs.zsh.enable = true;

  # Passwordless-ish sudo for wheel is the NixOS default (asks once). Keep the
  # password prompt; vopono will call sudo as needed.
  security.sudo.enable = true;

  # /code — top-level projects directory, owned by arlp (full owner rwx).
  # Created/enforced on every boot by systemd-tmpfiles.
  systemd.tmpfiles.rules = [
    "d /code 0755 arlp users - -"
  ];
}
