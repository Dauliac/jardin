{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.jardin;
in
  mkIf cfg.enable {
    security.sudo = {
      wheelNeedsPassword = true;
    };
    nix.settings.allowed-users = [cfg.account.admin.group];
    services.openssh.settings.AllowGroups = [cfg.account.admin.group];
    users = {
      mutableUsers = false;
      groups = {
        ${cfg.account.admin.group} = {};
      };
      users =
        builtins.mapAttrs
        (userName: user:
          {
            isNormalUser = true;
            createHome = true;
            description = "Admin ${userName} user account";
            extraGroups = ["wheel" cfg.account.admin.group];
          }
          // user)
        cfg.account.admin.users;
    };
  }
