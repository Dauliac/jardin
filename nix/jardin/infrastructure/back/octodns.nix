{ lib, ... }:
let
  cfg = config.jardin.infra.back.octodns;
in
{
  imports = [ ./adapters/job.nix ];
  options = {
    jardin.infra.back.octodns = {
      records = mkOption {
        type = types.list (types.attrsOf types.str);
        description = mdDoc "List of DNS records to create";
      };
      provider = mkOption {
        description = mdDoc "";
        type = types.enum [ "cloudflare" ];
      };
      zone = mkOption {
        description = mdDoc "The root dns zone of your cluster";
        type = types.singleLineStr;
      };
    };
  };
  config = {
    flake = {
      lib.jardin.infra.octodns = {
        mkTask =
          { lib
          , octodnsPkg
          , records
          , provider
          , zone
          ,
          }:
          lib.jardin.infra.mkJob {
            # lib, name, runTimeDependencies, files, tasks,
            inherit lib;
            name = "octodns";
            runTimeDependencies = [ ];
          };
      };
      perSystem =
        mkIf (cfg != null)
          { pkgs, ... }: {
            apps.jardin.tasks.dns = lib.jardin.infra.octodns.mkTask { inherit (cfg) records provider zone; };
          };
    };
  };
}
