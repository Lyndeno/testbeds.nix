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
        default = pkgs.callPackage ./testbed.nix {
          nixosConfig = self.nixosConfigurations.default;
        };
      }
    );
  };
}
