{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    systemctl-tui
    htop
    k9s
  ];
  users.users.admin = {
    password = "admin";
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./id_ed25519.pub)
    ];
  };
}
