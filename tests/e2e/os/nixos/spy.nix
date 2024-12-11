{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    systemctl-tui
    htop
    k9s
  ];
  users.users.jardin = {
    password = "jardin";
    extraGroups = ["wheel" "networkmanager" "audio" "video"];
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./id_ed25519.pub)
    ];
  };
}
