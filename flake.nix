{
  description = "astralbijection's infrastructure flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixos-vscode-server = {
      url = "github:msteen/nixos-vscode-server/master";
      flake = false;
    };

    nixos-hardware = {
      # Pin to 5.13 kernel, since ZFS does not seem to support 5.16 yet.
      # 5.16 update: https://github.com/NixOS/nixos-hardware/commit/3e4d52da0a4734225d292667a735dcc67dcef551
      url =
        "github:NixOS/nixos-hardware/c3c66f6db4ac74a59eb83d83e40c10046ebc0b8c";
      # url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    powerlevel10k = {
      url = "github:romkatv/powerlevel10k/master";
      flake = false;
    };

    # For auto-updating udev rules
    qmk_firmware = {
      url = "github:astralbijection/qmk_firmware/master";
      flake = false;
    };
  };

  outputs = { self, nixpkgs-unstable, nixos-vscode-server, flake-utils
    , home-manager-unstable, qmk_firmware, nixos-hardware, ... }@inputs:
    let
      astralModule =
        import ./nixos/modules { inherit nixos-hardware qmk_firmware; };

      astralHome = import ./home-manager/astral { inherit powerlevel10k; };

      nixpkgs = nixpkgs-unstable;
      home-manager = home-manager-unstable;
      alib = import ./nixos/lib {
        inherit nixpkgs;
        baseModules = [ astralModule home-manager.nixosModule ];
      };

    in (flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system: {
      devShell =
        import ./shell.nix { pkgs = nixpkgs.legacyPackages.${system}; };
    }) // {
      homeModule = astralHome;
      homeModules.astral = astralHome;

      homeConfigurations = let
        mkAstridConfig = { imports }:
          home-manager.lib.homeManagerConfiguration {
            system = "x86_64-linux";
            homeDirectory = "/home/astrid";
            username = "astrid";
            configuration.imports = imports;
          };
      in {
        "astrid@aliaconda" = mkAstridConfig {
          imports = [
            self.homeModules.astrid_cli_full
            self.homeModules.astrid_vi_full
            self.homeModules.conda-hooks
          ];
        };

        "astrid@banana" = mkAstridConfig {
          imports = [
            self.homeModules.astrid_cli_full
            self.homeModules.astrid_vi_full
            self.homeModules.astrid_x11
            self.homeModules.i3-xfce
          ];
        };

        "astrid@cracktop-pc" = mkAstridConfig {
          imports = [
            self.homeModules.astrid_cli_full
            self.homeModules.astrid_vi_full
            self.homeModules.astrid_x11
            self.homeModules.i3-xfce
          ];
        };

        "astrid@shai-hulud" = mkAstridConfig {
          imports = [
            self.homeModules.astrid_cli_full
            self.homeModules.astrid_vi_full
            self.homeModules.astrid_x11
            self.homeModules.i3-xfce
          ];
        };
      };

      nixosModule = astralModule;
      nixosModules.astral = astralModule;

      nixosConfigurations = (alib.mkSystemEntries {
        banana = import ./nixos/systems/banana inputs;
        donkey = import ./nixos/systems/donkey inputs;
        gfdesk = import ./nixos/systems/gfdesk inputs;
        shai-hulud = import ./nixos/systems/shai-hulud inputs;
        thonkpad = import ./nixos/systems/thonkpad inputs;
      }) // (alib.mkPiJumpserverEntries {
        jonathan-js = { };
        joseph-js = { };
      });

      diskImages = let
        installerSystem = alib.mkSystem {
          hostName = "astral-installer";
          module =
            import ./nixos/systems/installer-iso.nix { inherit nixpkgs; };
        };
      in { installer-iso = installerSystem.config.system.build.isoImage; };

      wallpapers = import ./home-manager/wallpapers;

      sshKeys = import ./ssh_keys;
    });
}
