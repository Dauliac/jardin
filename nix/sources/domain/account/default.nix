{lib, ...}: let
  inherit (lib) mkOption types mdDoc;
in {
  options = {
    domain.cluster.account = {
      adminGroup = mkOption {
        description = mdDoc "Cluster admin group";
        type = types.singleLineStr;
        default = "admin";
      };
      users = {
        admins = mkOption {
          description = mdDoc "Linux cluster admin user accounts";
          type = types.attrsOf (types.submodule (_: {
            options = {
              publicKey = mkOption {
                description = mdDoc "Ssh public key for one admin account";
                type = types.singleLineStr;
              };
            };
          }));
          default = {
            admin = {
              publicKey = "";
            };
          };
        };
      };
    };
  };
}
