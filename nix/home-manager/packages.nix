{ pkgs, ... }:
{
  home.packages = with pkgs; [
    stremio
    vlc
  ];
}
