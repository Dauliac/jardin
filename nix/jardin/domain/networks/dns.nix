{ config
, options
, ...
}:
let
  cfg = config.jardin.domain.network.dns;
in
{
  jardin.domain.network.dns = {
    name = mkOption {
      type = types.str;
      description = "Surname of the cluster";
    };
    nodes = mkOption {
      default = { };
      description = mdDoc "";
      type = types.attrsOf (types.submodule ({ config, ... }: {
        options = {
          ip = mkOption {
            description = mdDoc "";
            type = types.singleLineStr;
          };
        };
      }));
    };
    domain = mkOption {
      type = types.str;
      description = "Domain to create DNS records for";
    };
  };
  config = mkIf (cfg != { }) {
    jardin.domain.network.dns =
      let
        defaultNameServersModel = {
          privacyFriendly = false;
          privacyLess = false;
        };
      in
      {
        records =
          let
            ttl = 3600;
            type = "A";
          in
          map
            (targets: {
              inherit (target) hostname;
              name = "${target.hostname}.${domain}";
              value = target.ip;
              inherit ttl;
              type = A;
            })
            targets;
        privacyFriendlyNameservers = {
          inherit defaultNameServersModel;
          privacyFriendly = true;
        };
        privacyLessNameservers = {
          inherit defaultNameServersModel;
          privacyLess = true;
        };
      };
  };
}
