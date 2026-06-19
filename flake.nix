{
  description = "NixOS system for the arlp laptop (Intel + NVIDIA), with an installer ISO";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      # The actual laptop system. Installed on-device via `install-laptop`.
      nixosConfigurations.arlp-laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit self; };
        modules = [
          disko.nixosModules.disko
          ./disko.nix
          ./hardware-configuration.nix
          ./configuration.nix
        ];
      };

      # Live installer ISO. Embeds this flake + an `install-laptop` helper.
      nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit self; };
        modules = [
          (
            { modulesPath, ... }:
            {
              imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
            }
          )
          disko.nixosModules.disko
          ./modules/installer.nix
        ];
      };

      # `nix build .#installer-iso` -> result/iso/*.iso
      packages.${system} = {
        installer-iso = self.nixosConfigurations.installer.config.system.build.isoImage;
        default = self.nixosConfigurations.installer.config.system.build.isoImage;
      };
    };
}
