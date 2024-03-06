{ flake-parts-lib
, lib
, config
, ...
}:
let
  inherit (lib) mkOption mdDoc types mkIf;
  inherit (flake-parts-lib) mkPerSystemOption;
  cfg = config.infra.octodns;
  inherit (config) infra;
in
{
  options = {
    infra.octodns = {
      enable = mkOption {
        description = mdDoc "Enable the octodns task";
        type = types.bool;
        default = false;
      };
      records = mkOption {
        type = types.list (types.attrsOf types.str);
        description = mdDoc "List of DNS records to create";
      };
      provider = mkOption {
        description = mdDoc "The dns cloud provider to use";
        type = types.enum [ "gandi" "hetzner" ];
      };
      zone = mkOption {
        description = mdDoc "The root dns zone of your cluster";
        type = types.singleLineStr;
      };
    };
    perSystem = mkPerSystemOption ({ config'
                                   , lib
                                   , pkgs'
                                   , system
                                   , ...
                                   }:
      let
        systemInfra = config.infra;
      in
      {
        options = {
          infra.octodns = {
            package = mkOption {
              description = mdDoc "The octodns package";
              type = types.package;
              default = "octodns";
            };
            providerPackage = mkOption {
              description = mdDoc "The octodns provider package";
              type = types.package;
            };
            mkJob = mkOption {
              description = mdDoc "The task to run";
              type = types.package;
              default = systemInfra.job.mkJob {
                name = "octodns";
                runTimeDependencies =
                  # TODO: export it in config
                  let
                    provider = pkgs'.octodns-providers.${cfg.provider};
                  in
                  [ cfg.package provider ];
              };
            };
          };
        };
      });
  };
  config = {
    perSystem = {
      # octodns = {
      #   enable = cfg.enabled;
      #   records = cfg.records;
      #   provider = cfg.provider;
      #   zone = cfg.zone;
      # };
    };
    # flake = {
    #   lib = mkMerge [
    #     {
    #       # la = 123;
    #       # mkOctoDnsJob = config.flake.lib.infra.mkJob {
    #       #   inherit lib;
    #       #   name = "octodns";
    #       #   runTimeDependencies = [ ];
    #       # };
    #     }
    #   ];
    # };
    # jardin.infra.octodns.task = mkIf cfg.enabled cfg.lib.mkOctoDnsJob;
    # jardin = mkMerge [{ infra = mkMerge [{ octodns = { }; }]; }];
  };
}
