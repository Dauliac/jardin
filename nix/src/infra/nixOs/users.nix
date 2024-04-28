{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkOption;
  inherit (config.domain) cluster;
  inherit (inputs.flake-parts.lib) mkPerSystemOption;
in {
  options.perSystem =
    mkPerSystemOption
    (_: {
      options = {
        infra.nixOs = {
          mkUserConfig = mkOption {
            description = "NixOS configuration for the cluster nodes";
            default = admins: {
              security.sudo = {
                # NOTE: this is unescure, we maybe need to define debug boolean argument
                wheelNeedsPassword = false;
              };
              users =
                {
                  mutableUsers = false;
                }
                // {
                  users =
                    builtins.mapAttrs
                    (userName: node: {
                      isNormalUser = true;
                      createHome = true;
                      description = "Admin ${userName} user account";
                      extraGroups = ["wheel" cluster.account.adminGroup];
                    })
                    admins;
                };
            };
          };
          # users = mkOption {
          #   type = types.attrsOf types.attrs;
          #   description = "Basic and constant nixOS configuration for the cluster nodes";
          #   default = cfg.mkUserConfig cluster.account.admins;
          # };
        };
      };
    });
}
