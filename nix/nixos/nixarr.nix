_: {
  nixarr = {
    enable = true;
    mediaUsers = [ "jardin" ];
    jellyfin.enable = true;
    prowlarr.enable = true;
    radarr.enable = true;
    jellyseerr.enable = true;
    transmission.enable = true;
    ddns.njalla = {
      enable = false;
      keysFile = "/data/.secret/njalla/keys-file.json";
    };
    # vpn = {
    #   enable = true;
    #   # WARNING: This file must _not_ be in the config git directory
    #   # You can usually get this wireguard file from your VPN provider
    #   wgConf = "/data/.secret/wg.conf";
    # };
  };
}
