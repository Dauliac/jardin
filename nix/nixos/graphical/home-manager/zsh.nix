_: {
  programs.bash = {
    enable = true;
    enableCompletion = true;
  };
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };
}
