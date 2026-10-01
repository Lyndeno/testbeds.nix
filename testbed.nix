{
  nixosConfig,
  writeShellApplication,
  lib,
  stdenv,
}: let
    host = nixosConfig.extendModules {
      modules = [
        ({lib, ...}: {
          nixpkgs.hostPlatform = lib.mkForce stdenv.hostPlatform.system;
        })
      ];
    };
  in  writeShellApplication{
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
  }
