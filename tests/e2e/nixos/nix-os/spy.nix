{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    systemctl-tui
    htop
    k9s
  ];
  users.users.test = {
    password = "test";
    isNormalUser = true;
    group = "test";
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./id_ed25519.pub)
    ];
  };
  users.groups.test = {};
}
