_: {
  imports = [
    ./firefox.nix
    ./theme.nix
    ./gnome.nix
  ];
  config = {
    home.stateVersion = "24.11";
  };
}
