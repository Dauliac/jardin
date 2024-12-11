{pkgs, ...}: {
  imports = [
    ./zsh.nix
  ];
  xdg.mime.enable = true;
  home.packages = with pkgs; [
    firefox
  ];
}
