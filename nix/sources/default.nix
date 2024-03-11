# SPDX-License-Identifier: AGPL-3.0-or-later
{
  flake-parts-lib,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (flake-parts-lib) mkSubmoduleOptions;
in {
  imports = [./app ./infra ./domain];
  options = {
    flake = mkSubmoduleOptions {
      lib = mkSubmoduleOptions {
        infra = mkOption {description = "Infrastructure layer lib";};
        # app = mkOption {
        #   type = types.lazyAttrsOf types.raw;
        #   description = "Application layer lib";
        # };
        domain = mkSubmoduleOptions {
          cluster = mkOption {description = "Cluster lib";};
        };
      };
    };
  };
  config = {debug = true;};
}
