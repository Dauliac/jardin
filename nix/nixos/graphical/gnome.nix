{
  pkgs,
  lib,
  ...
}:
{
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      autoSuspend = false;
    };
    desktopManager.gnome.enable = true;
    xkb = {
      layout = "fr";
    };
    xkbOptions = "terminate:ctrl_alt_bksp";
  };

  environment.gnome.excludePackages = with pkgs; [
    orca
    evince
    gnome-backgrounds
    gnome-tour
    gnome-user-docs
    baobab
    epiphany
    gnome-text-editor
    gnome-calculator
    gnome-calendar
    gnome-characters
    gnome-console
    gnome-contacts
    gnome-font-viewer
    gnome-logs
    gnome-maps
    gnome-music
    gnome-weather
    gnome-connections
    simple-scan
    snapshot
    totem
    yelp
    gnome-software
  ];
  programs.dconf = {
    enable = true;
    profiles.gdm.databases = [
      {
        settings = {
          "org/gnome/desktop/interface".scaling-factor = lib.gvariant.mkUint32 4;
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
  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
  ];
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };
}
