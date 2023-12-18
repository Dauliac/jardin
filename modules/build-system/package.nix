{
  inputs,
  lib,
  ...
}: {
  perSystem = {pkgs, ...}: let
    craneLib = crane.lib;
  in {
    packages = rec {
      jardin = jardinPackage;
      default = jardin;
      coverage = craneLib.cargoLlvmCov (commonArgs
        // {
          inherit cargoArtifacts;
          cargoExtraArgs = "nextest";
        });
    };
  };
}
