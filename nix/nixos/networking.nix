_: {
  networking = {
    nameservers = [
      "9.9.9.9"
      "1.1.1.1"
    ];
    firewall = rec {
      enable = false; # TODO: enable firewall
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = allowedTCPPortRanges;
    };
    dhcpcd.enable = true;
  };
}
