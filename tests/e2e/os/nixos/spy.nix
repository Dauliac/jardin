{
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    systemctl-tui
    htop
    k9s
  ];
  home-manager.users.jardin = {
    dconf = {
      settings = {
        "org/gnome/desktop/interface".scaling-factor = lib.mkForce (lib.gvariant.mkUint32 1);
      };
    };
    programs.firefox = {
      profiles.default = {
        settings = {
          "layout.css.devPixelsPerPx" = lib.mkForce "1";
        };
      };
    };
  };
  users.users = {
    jardin = {
      password = "jardin";
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "video"
      ];
      openssh.authorizedKeys.keys = [
        (builtins.readFile ./id_ed25519.pub)
      ];
    };
    admin = {
      password = "admin";
      openssh.authorizedKeys.keys = [
        (builtins.readFile ./id_ed25519.pub)
      ];
    };
  };
}
