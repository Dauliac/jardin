{ pkgs, ... }:
{
  imports = [
    ./sound.nix
    ./gaming.nix
    ./bluetooth.nix
    ./gnome.nix
  ];
}
