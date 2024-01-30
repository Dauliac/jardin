{ options
, config
, ...
}:
let
  inherit (lib) mkOption mkPackageOption types mdDoc;
  inherit (flake-parts-lib) mkPerSystemOption;
in
{
  imports = [ ./operations/deploy.nix ];
  options.nixCluster = {
    cluster = {
      name = mkOption {
        description = mdDoc "The human readable name of your cluster";
        type = types.singleLineStr;
      };
      dns = {
        zone = mkOption {
          description = mdDoc "The root dns zone of your cluster";
          type = types.singleLineStr;
        };
        provider = mkOption {
          description = mdDoc "";
          type = types.enum [ "cloudflare" ];
        };
      };
      nodes = mkOption {
        default = { };
        description = mdDoc "";
        type = types.attrsOf (types.submodule ({ config, ... }: {
          options = {
            role = mkOption {
              description = mdDoc "";
              type = types.enum [ "node" ];
            };
            ip = mkOption {
              description = mdDoc "";
              type = types.singleLineStr;
            };
            resources = mkOption {
              default = null;
              description = mdDoc "";
              type = types.nullOr types.submodule ({ config, ... }: {
                options = {
                  cpu = mkOption {
                    description = mdDoc "";
                    type = types.ints.positive;
                  };
                  memory = mkOption {
                    description = mdDoc "";
                    type = types.ints.positive;
                  };
                  storage = mkOption {
                    description = mdDoc "";
                    type = types.attrsOf types.anything;
                  };
                };
              });
            };
          };
        }));
      };
    };
    pipeline = { fresh_install = mkOption { }; };
  };
}
