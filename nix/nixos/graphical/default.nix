{ pkgs, ... }:
{
  imports = [
    ./sound.nix
    ./gaming.nix
    ./bluetooth.nix
    ./gnome.nix
    ./hyprland.nix
    ./display.nix
  ];
}
