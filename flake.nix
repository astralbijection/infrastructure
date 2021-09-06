{
  description = "astralbijection's infrastructure flake";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-21.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, ... }@inputs:
    let
      installerResult = (import ./nixos/systems/installerISO.nix) inputs;
    in
    {
      nixosConfigurations = {
        bongusHV = (import ./nixos/systems/bongusHV.nix) inputs;
        installerISO = installerResult;
      };

      nixosModules = {
        bm-server = (import ./nixos/modules/bm-server.nix);
        ext4-ephroot = (import ./nixos/modules/ext4-ephroot.nix);
        stable-flake = (import ./nixos/modules/stable-flake.nix);
        libvirt = (import ./nixos/modules/libvirt.nix);
        sshd = (import ./nixos/modules/sshd.nix);
        zfs-boot = (import ./nixos/modules/zfs-boot.nix);
      };

      packages = {
        "x86_64-linux" = {
          # note: unstable needs GC_DONT_GC=1 (https://github.com/NixOS/nix/issues/4246)
          installerISO = installerResult.config.system.build.isoImage;
        };
      };
    };
}
