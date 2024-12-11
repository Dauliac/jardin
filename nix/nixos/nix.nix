_: {
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      system-features = [
        "big-parallel"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      persistent = true;
      dates = "012:15";
      options = "-d";
    };
  };
}
