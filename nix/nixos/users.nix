{
  config,
  pkgs,
  ...
}:
{
  services.displayManager.autoLogin.user = "jardin";
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
