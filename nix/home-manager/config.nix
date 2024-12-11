_: {
  imports = [
    ./firefox.nix
    ./theme.nix
    ./gnome.nix
    ./kdeconnect.nix
    ./packages.nix
  ];
  config = {
    home.stateVersion = "24.11";
  };
}
