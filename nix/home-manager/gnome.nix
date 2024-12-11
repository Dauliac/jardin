{ pkgs, lib, ... }:
{
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface".scaling-factor = lib.gvariant.mkUint32 4;
      "org/gnome/desktop/a11y/applications".screen-keyboard-enabled = true;
      "org/gnome/shell" = {
        favorite-apps = [
          "firefox.desktop"
          "org.gnome.Nautilus.desktop"
        ];
      };
      "org/gnome/desktop/screensaver" = {
        lock-enabled = false;
      };
      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-ac-timeout = 0;
        sleep-inactive-battery-timeout = 0;
        sleep-inactive-battery-type = "nothing:";
      };
    };
  };
  programs.gnome-shell = {
    enable = true;
    extensions = [{ package = pkgs.gnomeExtensions.gsconnect; }];
  };
}
