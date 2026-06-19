# Intel iGPU + NVIDIA dGPU (Optimus laptop).
#
# Default here is PRIME *offload*: the Intel GPU drives the display (best
# battery), and you opt apps onto the NVIDIA GPU with the wrapper:
#   nvidia-offload glxinfo | grep vendor
#   nvidia-offload <some-game>
#
# !!! Two values MUST be set on-device before this evaluates correctly.
#     Find them with:  lspci | grep -E 'VGA|3D'
#     e.g. "00:02.0 VGA ... Intel"  -> intelBusId  = "PCI:0:2:0"
#          "01:00.0 3D  ... NVIDIA" -> nvidiaBusId = "PCI:1:0:0"
{ config, pkgs, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # VAAPI on recent Intel
      vpl-gpu-rt
    ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    # `open = true` only on Turing (RTX 20xx / GTX 16xx) or newer. Leave false
    # for older GPUs; flip to true if your card supports the open modules.
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # provides the `nvidia-offload` wrapper
      };
      # ---- CHANGE ME (see header) ----
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # If offload misbehaves or bus IDs are wrong, you can fall back by commenting
  # the whole `prime` block above and instead running the NVIDIA GPU as primary
  # (more power draw, no bus IDs needed): set `hardware.nvidia.prime.sync.enable`
  # OR just remove the prime block entirely.
}
