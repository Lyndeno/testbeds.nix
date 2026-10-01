{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
  };

  outputs = {self, nixpkgs, ...}: let
    systems = builtins.filter (nixpkgs.lib.hasSuffix "-linux") (builtins.attrNames nixpkgs.legacyPackages);
    forEachSystem = f: nixpkgs.lib.genAttrs systems (system: f system nixpkgs.legacyPackages.${system});
  in {

    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      modules = [
        {
          nixpkgs.hostPlatform.system = "x86_64-linux";
        }
      ];
    };

    packages = forEachSystem (system: pkgs: 
      {
        default = let
          host = self.nixosConfigurations.default.extendModules {
            modules = [
              ({lib, ...}: {
                nixpkgs.hostPlatform = lib.mkForce system;
              })
            ];
          };
        in  pkgs.writeShellApplication{
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
              ${pkgs.lib.getExe host.config.system.build.vm}
          '';
        };
      }
    );
  };
}
