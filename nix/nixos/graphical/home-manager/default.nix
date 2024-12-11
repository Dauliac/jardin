_: {
  # imports = [
  #   ./home.nix
  # ];
  config = {
    home.stateVersion = "24.11";
    # home.file."${config.xdg.configHome}" = {
    #   recursive = true;
    # };
    nixpkgs = {
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
    };
    fonts.fontconfig.enable = true;
    xdg.enable = true;
    home.sessionVariables = {
      # BROWSER = "firefox-devedition";
    };
  };
}
