{ pkgs, ... }:
{
  imports = [
    ./sound.nix
    # ./gaming.nix # TODO: add unfree option to get steam
    ./bluetooth.nix
    ./gnome.nix
  ];
}
