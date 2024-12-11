{
  pkgs,
  ...
}: {
  xdg.mime.enable = true;
  home.packages = with pkgs; [
    firefox
  ];
}
