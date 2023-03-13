# A graphics-enabled PC I would directly use.
{ config, lib, pkgs, inputs, ... }:
with lib;
let extraHosts = "/var/extraHosts";
in {
  imports = [ ./astral ];

  # haskell.nix binary cache
  nix.settings.trusted-public-keys =
    [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
  nix.settings.substituters = [ "https://cache.iog.io" ];

  # Enable SSH in initrd for debugging or disk key entry
  boot.initrd.network.ssh = {
    enable = true;
    authorizedKeys = [ inputs.self.lib.sshKeyDatabase.users.astrid ];
  };

  fonts.fonts = with pkgs; [
    corefonts
    dejavu_fonts
    dina-font
    dosemu_fonts
    fira-code
    fira-code-symbols
    freefont_ttf
    gyre-fonts
    helvetica-neue-lt-std
    liberation_ttf
    libertine
    mplus-outline-fonts.githubRelease
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-extra
    open-fonts
    oxygenfonts
    powerline-fonts
    proggyfonts
    redhat-official-fonts
    roboto
    stix-two
    ubuntu_font_family
    vistafonts
  ];

  environment.systemPackages = with pkgs; [
    ark
    exfat
    exfatprogs
    gajim
    home-manager
    nextcloud-client
    openconnect
    ventoy-bin
    wine
    wine64
    winetricks

    opensc
    pcsclite
    pcsctools
    yubico-piv-tool
    yubikey-manager
    yubikey-manager-qt
    yubikey-personalization
    yubikey-personalization-gui
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

  services.pcscd = {
    enable = true;
    plugins = with pkgs; [ ccid libacr38u ];
  };

  services.gvfs.enable = true;

  astral = {
    ci.needs = [ "nixos-system-__basePC" ];
    ci.prune-runner = true;

    custom-tty.enable = true;
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
    tailscale.enable = true;
    virt = {
      docker.enable = true;
      libvirt = {
        enable = true;
        virt-manager.enable = true;
      };
    };
    net.sshd.enable = true;
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

  # Use dnsmasq to allow live hosts editing in development
  services.dnsmasq = {
    enable = true;
    settings = {
      server = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ];
      listen-address = "127.0.0.1";
      addn-hosts = extraHosts;
    };
  };

  systemd.services.create-extra-hosts = {
    description = "Make extraHosts";

    wantedBy = [ "dnsmasq.service" ];
    before = [ "dnsmasq.service" ];

    script = ''
      touch ${extraHosts}
      chmod 664 ${extraHosts}
      chown dnsmasq:dnsmasq-extra-hosts ${extraHosts}
    '';

    serviceConfig.Type = "oneshot";
  };

  users = {
    users.dnsmasq.extraGroups = [ "dnsmasq-extra-hosts" ];
    groups.dnsmasq-extra-hosts = { };
  };

  virtualisation.anbox.enable = true;

  i18n.inputMethod.enabled = "fcitx";
}
