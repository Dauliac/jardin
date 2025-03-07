{
  pkgs,
  lib,
  config,
  ...
}:
{
  jardin.clusterName = "test";
  environment.systemPackages = with pkgs; [
    systemctl-tui
    htop
    k9s
  ];
  virtualisation.sharedDirectories = {
    host-share = {
      source = "/tmp/jardin";
      target = "/mnt/host-share";
    };
  };
  sops = {
    age.keyFile = lib.mkForce "${config.virtualisation.sharedDirectories.host-share.target}/age.txt";
  };
  programs.dconf = {
    profiles.gdm.databases = lib.mkForce [
      {
        settings = {
          "org/gnome/desktop/interface".scaling-factor = lib.gvariant.mkUint32 1;
          "org/gnome/desktop/a11y/applications".screen-keyboard-enabled = true;
          "org/gnome/desktop/session" = {
            idle-delay = lib.gvariant.mkUint32 0;
          };
          "org/gnome/desktop/screensaver" = {
            lock-enabled = false;
          };
          "org/gnome/settings-daemon/plugins/power" = {
            sleep-inactive-ac-type = "nothing";
            sleep-inactive-battery-type = "nothing";
            idle-dim = false;
          };
        };
      }
    ];
  };
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
      openssh.authorizedKeys.keys = [
        (builtins.readFile ./id_ed25519.pub)
      ];
    };
  };
}
