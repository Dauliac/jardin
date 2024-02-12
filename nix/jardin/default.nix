{ flake-parts-lib
, lib
, config
, pkgs
, inputs
, ...
}:
let
  inherit (lib) mkOption types;
  inherit (flake-parts-lib) mkSubmoduleOptions;
in
{
  imports = [
    ./app
    # ./infra
    ./domain
  ];
  options = {
    flake = mkSubmoduleOptions {
      lib = mkSubmoduleOptions {
        # infra = mkOption {
        #   type = types.lazyAttrsOf types.raw;
        #   description = "Infrastructure layer lib";
        #   default = { };
        # };
        # app = mkOption {
        #   type = types.lazyAttrsOf types.raw;
        #   description = "Application layer lib";
        # };
        domain = mkSubmoduleOptions {
          cluster = mkOption {
            type = types.lazyAttrsOf types.raw;
            description = "Cluster lib";
          };
        };
      };
    };
  };
}
