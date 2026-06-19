# Declarative disk layout for the arlp laptop.
#
#   UEFI ESP (/boot, vfat, unencrypted)
#   LUKS2 container -> btrfs root with subvolumes (@, @home, @nix)
#   No swap (sufficient RAM; avoids SSD write wear).
#
# Applied at install time with:
#   disko --mode disko /etc/nixos-config/disko.nix
#
# !!! SET THE DEVICE BELOW before installing — find it with `lsblk`.
#     A wrong device here WILL erase the wrong disk.
{
  disko.devices = {
    disk.main = {
      type = "disk";
      # ---- CHANGE ME ---- (e.g. /dev/nvme0n1, /dev/sda)
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            name = "ESP";
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              # interactive passphrase prompt at boot
              settings.allowDiscards = true;
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  # No swap — plenty of RAM, and avoiding swapfile write wear.
                };
              };
            };
          };
        };
      };
    };
  };
}
