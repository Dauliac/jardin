{config, pkgs, ...}: {
  services.displayManager.autoLogin.user = "jardin";
  users = {
    mutableUsers = false;
    users = {
      jardin = {
        isNormalUser = true;
        description = "Jardin 🏡";
        group = "jardin";
        extraGroups = [
          "networkmanager"
          "audio"
          "video"
        ];
        shell = pkgs.bashInteractive;
      };
      security.sudo.extraRules = [
        {
          users = [ "admin" ];
          commands = [ { command = "ALL"; options = [ "NOPASSWD" ]; } ];
        }
      ];
      admin = {
        isNormalUser = true;
        description = "Jardin 🏡";
        group = "jardin";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        shell = pkgs.bashInteractive;
        openssh.authorizedKeys.keys = [
          (builtins.readFile ./id_ed25519.pub)
        ];
        hashedPasswordFile = config.sops.secrets.dauliac_hashed_password.path;
      };
    };
  };
}
