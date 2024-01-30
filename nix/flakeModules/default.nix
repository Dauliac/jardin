{ config
, inputs
, pkgs
, flake-parts-lib
, ...
}: {
  flake.flakeModules = {
    nixCluster = ../jardin/application;
    default = config.flake.flakeModules.nixCluster;
  };
}
