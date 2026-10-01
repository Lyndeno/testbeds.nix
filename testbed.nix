{
  nixosConfig,
  writeShellApplication,
  lib,
  stdenv,
}: let
    base = nixosConfig.extendModules {
      modules = [
        ({lib, ...}: {
          nixpkgs.hostPlatform = lib.mkForce stdenv.hostPlatform.system;
        })
      ];
    };

    headlessConfig = base.extendModules {
      modules = [
        {
          virtualisation.vmVariant.virtualisation.graphics = false;
        }
      ];
    };

    headless = mkHost { host = headlessConfig; };

    mkHost = {
      host,
      extraPassthru ? {},
    }: writeShellApplication {
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
          ${lib.getExe host.config.system.build.vm}
      '';
      passthru = {
        inherit headless;
      } // extraPassthru;
    };

    default = mkHost { host = base; };
in default
