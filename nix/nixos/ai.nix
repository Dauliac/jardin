{ pkgs, ... }:
{
  services.ollama = {
    # package = pkgs.unstable.ollama; # If you want to use the unstable channel package for example
    enable = true;
    acceleration = "cuda"; # Or "rocm"
    # environmentVariables = { # I haven't been able to get this to work, but please see the serviceConfig workaround below
    # HOME = "/home/ollama";
    # OLLAMA_MODELS = "/home/ollama/models";
    # OLLAMA_HOST = "0.0.0.0:11434"; # Make Ollama accesible outside of localhost
    # OLLAMA_ORIGINS = "http://localhost:8080,http://192.168.0.10:*"; # Allow access, otherwise Ollama returns 403 forbidden due to CORS
    #};
  };

  # The Ollama environment variables, as mentioned in the comments section
  systemd.services.ollama.serviceConfig = {
    Environment = [ "OLLAMA_HOST=0.0.0.0:11434" ];
  };

  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434/api";
      OLLAMA_BASE_URL = "http://127.0.0.1:11434";
    };
  };

  # Add oterm to the systemPackages
  environment.systemPackages = with pkgs; [
    oterm
  ];
}
