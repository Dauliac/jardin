_: {
  nixarr = {
    enable = true;
    mediaUsers = [ "jardin" ];
    jellyfin = {
      enabled = true;
      vpn.enable = true;
    };
    bazarr = {
      enable = true;
      vpn.enable = true;
    };
    sonarr = {
      enable = true;
      vpn.enable = true;
    };
    prowlarr = {
      enable = true;
      vpn.enable = true;
    };
    transmission = {
      enable = true;
      vpn.enable = true;
    };
    vpn = {
      enable = true;
      # WARNING: This file must _not_ be in the config git directory
      # You can usually get this wireguard file from your VPN provider
      wgConf = "/data/.secret/wg.conf";
    };
  };
}
