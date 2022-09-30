{ config, lib, pkgs, ... }:
with lib; {
  options.astral.roles.pc.enable = mkOption {
    description = "A graphics-enabled PC I would directly use";
    default = false;
    type = types.bool;
  };

  config = mkIf config.astral.roles.pc.enable {
    # haskell.nix binary cache
    nix.settings.trusted-public-keys =
      [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
    nix.settings.substituters = [ "https://cache.iog.io" ];

    fonts.fonts = with pkgs; [
      corefonts
      dejavu_fonts
      dina-font
      fira-code
      fira-code-symbols
      noto-fonts
      noto-fonts-emoji
      open-fonts
      proggyfonts
      redhat-official-fonts
      vistafonts
    ];

    environment.systemPackages = with pkgs; [
      home-manager
      openconnect
      ventoy-bin
      exfatprogs
      exfat
    ];

    users.mutableUsers = true;
    documentation = {
      man.enable = true;
      dev.enable = true;
      nixos.enable = true;
    };

    services.geoclue2 = {
      enable = true;
      enableWifi = true;
    };

    services.gvfs.enable = true;

    astral = {
      program-sets = {
        browsers = true;
        cad = true;
        chat = true;
        dev = true;
        office = true;
        security = true;
        x11 = true;
      };
      hw.kb-flashing.enable = true;
      hw.logitech-unifying.enable = true;
      virt = {
        docker.enable = true;
        libvirt = {
          enable = true;
          virt-manager.enable = true;
        };
      };
      net = {
        xrdp.enable = true;
        sshd.enable = true;
      };
      zfs-utils.enable = true;
      # infra-update = {
      #   enable = true;
      #   dates = "*-*-* 3:00:00 US/Pacific";
      # };
      xmonad.enable = true;
    };

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    services.printing = {
      enable = true;
      drivers = with pkgs; [ gutenprint gutenprintBin ];
    };

    services.xserver = {
      enable = true;

      displayManager = { lightdm.enable = true; };

      desktopManager = {
        xterm.enable = false;
        plasma5 = {
          enable = true;
          useQtScaling = true;
        };
      };
    };

    hardware.hackrf.enable = true;
    hardware.rtl-sdr.enable = true;
    services.sdrplayApi.enable = true;

    services.udev.packages = [ pkgs.android-udev-rules ];

    services.flatpak.enable = true;

    services.resolved = {
      enable = true;
      dnssec = "false";
      domains = [ "~id.astrid.tech" ];
    };
  };
}
