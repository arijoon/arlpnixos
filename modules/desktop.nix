# Two desktop sessions, selectable at the SDDM login screen:
#   - KDE Plasma 6   (full DE)
#   - dwm            (suckless dynamic WM, patched bindings in ./dwm/config.h)
#
# X11 is used as the server (safest with the NVIDIA proprietary driver and
# required by dwm). KDE still offers both X11 and Wayland sessions.
{ pkgs, ... }:
let
  # Real suckless dwm with our config.h baked into the derivation.
  # nixpkgs' dwm accepts a `conf` string which it writes to config.h at build.
  dwm-arlp = pkgs.dwm.override {
    conf = builtins.readFile ./dwm/config.h;
  };
in
{
  services.xserver.enable = true;

  # UK keyboard for X11 (SDDM, Plasma, dwm). `console.keyMap = "uk"` in
  # configuration.nix only covers the text consoles; the X layout code is "gb".
  services.xserver.xkb.layout = "gb";

  # Login manager (also installs the SDDM/Plasma session picker).
  services.displayManager.sddm.enable = true;

  # KDE Plasma 6.
  services.desktopManager.plasma6.enable = true;

  # dwm session.
  services.xserver.windowManager.dwm = {
    enable = true;
    package = dwm-arlp;
  };

  # Launchers/tools dwm spawns by name — installed system-wide so they resolve
  # in the bare X session regardless of the home-manager profile state.
  #   - rofi: X11 build; solarized theme set system-wide below.
  #   - flameshot: bound to PrintScreen in dwm/config.h.
  #   - kitty terminal comes from home-manager (config requirement); xterm is a
  #     first-boot fallback before `home-manager switch`.
  environment.systemPackages = with pkgs; [
    rofi
    flameshot
    xterm
  ];

  # System-wide rofi config: solarized theme for every rofi invocation (read via
  # /etc/xdg in XDG_CONFIG_DIRS). `solarized` is a theme bundled with rofi.
  environment.etc."xdg/rofi/config.rasi".text = ''
    configuration {
      modi: "drun,run,window";
      show-icons: true;
    }
    @theme "solarized"
  '';

  # Audio (PipeWire) + Bluetooth — laptop baseline.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth.enable = true;
  services.printing.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.ubuntu-mono
    noto-fonts
  ];
}
