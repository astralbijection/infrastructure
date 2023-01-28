# Home media server, hooked up directly to the TV.
{ config, pkgs, lib, ... }:
let vs = config.vault-secrets.secrets.media-server;
in with lib; {
  # vault kv put kv/media-server/secrets ovpn_conf=@ ovpn_userpass=@
  #  - ovpn_conf: the full config file provided by surfshark
  #  - ovpn_userpass: a string of USERNAME <newline> PASSWORD
  vault-secrets.secrets."media-server" = {
    group = "root";
    services = mkForce [ "openvpn-surfshark.service" ];
  };

  services.nginx.virtualHosts."deluge.s02.astrid.tech" = {
    locations."/".proxyPass =
      "http://localhost:${toString config.services.deluge.web.port}";
  };

  services.nginx.virtualHosts."transmission.s02.astrid.tech" = {
    locations."/" = {
      proxyPass = "http://localhost:"
        + toString config.services.transmission.settings.rpc-port;
      proxyWebsockets = true;
    };
  };

  services.xserver = {
    enable = true;

    displayManager.autoLogin = {
      enable = true;
      user = "tv";
    };

    desktopManager.kodi.enable = true;
  };

  systemd.services.media-server-secrets = {
    requiredBy = [ "openvpn-surfshark.service" ];
    before = [ "openvpn-surfshark.service" ];
  };

  services.deluge = {
    enable = true;
    web.enable = true;
  };

  users.users.tv = {
    group = "users";
    extraGroups = [ "deluge" "transmission" ];
    isNormalUser = true;
  };

  services.transmission.enable = true;

  services.openvpn.servers.surfshark = {
    config = ''
      config ${vs}/ovpn_conf
      auth-user-pass ${vs}/ovpn_userpass
    '';
  };

  services.resolved = {
    enable = true;
    # From surfshark conf
    fallbackDns = [ "162.252.172.57" "149.154.159.92" ];
  };

  networking = {
    useHostResolvConf = false;

    # Point to the VPN
    defaultGateway.address = "10.16.50.3";
    defaultGateway6.address = "fc00::3";

    firewall = {
      enable = true;

      # Transmission must route its traffic through the VPN.
      extraCommands = ''
        iptables -t filter -A OUTPUT -m owner --uid-owner transmission -o lo -j ACCEPT
        iptables -t filter -A OUTPUT -m owner --uid-owner transmission -o tun0 -j ACCEPT
        iptables -t filter -A OUTPUT -m owner --uid-owner transmission -j REJECT
      '';
      extraStopCommands = ''
        iptables -t filter -D OUTPUT -m owner --uid-owner transmission -o lo -j ACCEPT || true
        iptables -t filter -D OUTPUT -m owner --uid-owner transmission -o tun0 -j ACCEPT || true
        iptables -t filter -D OUTPUT -m owner --uid-owner transmission -j REJECT || true
      '';
    };
  };

  services.getty.autologinUser = "root";

  environment.systemPackages = with pkgs; [ tcpdump ];
}
