_: {
  networking = {
    nameservers = [
      "9.9.9.9"
      "1.1.1.1"
    ];
    dhcpcd.enable = true;
    firewall.enable = true;
  };
}
