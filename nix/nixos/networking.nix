_: {
  networking = {
    nameservers = [
      "9.9.9.9"
      "1.1.1.1"
    ];
    # dhcpcd.enable = true;
    interfaces.wlp0s20f3 = {
      ipv4.addresses = [
        {
          address = "10.10.0.20";
          prefixLength = 24;
        }
        {
          address = "10.10.0.21";
          prefixLength = 24;
        }
      ];
    };
  };
}
