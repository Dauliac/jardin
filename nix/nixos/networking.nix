_: {
  networking = {
    nameservers = [
      "9.9.9.9"
      "1.1.1.1"
    ];
    networkmanager.enable = true;
    dhcpcd.enable = false;
    firewall.enable = false;
    interfaces.wlp0s20f3 = {
      ipv4.addresses = [
        {
          address = "10.10.0.2";
          prefixLength = 24;
        }
      ];
    };
  };
}
