{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
  };

  outputs = {self, nixpkgs, ...}: let
    systems = builtins.attrNames nixpkgs.legacyPackages;
    forEachSystem = nixpkgs.lib.genAttrs systems;
  in {

    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      modules = [
        {
          nixpkgs.hostPlatform.system = "x86_64-linux";
        }
      ];
    };

    packages.x86_64-linux.default = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      inherit (pkgs) lib;
    in pkgs.writeShellApplication {
      name = "default";
      text = ''
        cleanup() {
          if rm --recursive "$directory"; then
            printf '%s\n' 'Virtualisation disk image removed.'
          fi
        }

        directory="$(mktemp --directory)"
        trap cleanup EXIT

        NIX_DISK_IMAGE="$directory/nixos.qcow2" \
          ${lib.getExe self.nixosConfigurations.default.config.system.build.vm}
      '';
    };
  };
}
