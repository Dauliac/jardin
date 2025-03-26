{ pkgs, ... }:
{
  home.packages = with pkgs; [
    stremio
    vlc
    ryujinx
    shadps4
    google-chrome
  ];
}
