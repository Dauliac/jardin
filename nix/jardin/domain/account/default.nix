{ config
, lib
, ...
}:
let
  inherit (lib) mkOption types mdDoc;
  cfg = config.domain;
in
{
  options = {
    domain.cluster.account = {
      users = {
        adminGroup = mkOption {
          description = mdDoc "Linux cluster admin group";
          type = types.singleLineStr;
          default = "admin";
        };
        admins = mkOption {
          description = mdDoc "Linux cluster admin user accounts";
          type = types.attrsOf (types.submodule (_: {
            options = {
              publicKey = mkOption {
                description = mdDoc "Public key for the admin account";
                type = types.singleLineStr;
              };
            };
          }));
        };
      };
    };
  };
}
