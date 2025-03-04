{
  pkgs,
  config,
  ...
}:
{
  services.displayManager.autoLogin = {
    enable = true;
    user = "jardin";
  };
  security.sudo.extraRules = [
    {
      users = [ "admin" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  users = {
    mutableUsers = false;
    groups = {
      jardin = {
      };
      admin = {
      };
    };
    users = {
      jardin = {
        isNormalUser = true;
        description = "Jardin 🏡";
        group = "jardin";
        initialPassword = "jardin";
        extraGroups = [
          "networkmanager"
          "audio"
          "video"
        ];
        shell = pkgs.bashInteractive;
      };
      admin = {
        isNormalUser = true;
        description = "Admin";
        group = "admin";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        openssh.authorizedKeys.keys = [
          (builtins.readFile ./id_ed25519.pub)
        ];
        hashedPasswordFile = config.sops.secrets.admin_hashed_password.path;
      };
    };
  };
}
