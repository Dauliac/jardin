{ lib
, config
, ...
}:
let
  inherit (lib) mkOption mdDoc types mkIf mkMerge;
  cfg = config.jardin.infra.back.octodns;
in
{
  options = {
    jardin.infra.octodns = {
      enabled = mkOption {
        description = mdDoc "Enable the octodns task";
        type = types.bool;
      };
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
      octodns = mkOption {
        description = mdDoc "The octodns package";
        type = types.package;
        default = "octodns";
      };
    };
  };
  config = {
    debug = true;
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
