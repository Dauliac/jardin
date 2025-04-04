{ inputs, ... }:
{
  imports = [
    inputs.hyprpanel.homeManagerModules.hyprpanel
    ./firefox.nix
    ./theme.nix
    ./gnome.nix
    ./packages.nix
    ./wayland.nix
    ./widget.nix
  ];
  config = {
    home.stateVersion = "24.11";
  };
}
