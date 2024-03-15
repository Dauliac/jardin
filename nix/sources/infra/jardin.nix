{
  jardin,
  config,
  action,
  globalFlags,
  localFlags,
}: let
  command = ../adapters/command.nix;
  bin = "${jardin}/bin/jardin";
  configArg = {
    key = "--config";
    value = "${config}/config.toml";
  };
  command = command.build {
    inherit bin action localFlags;
    globalFlags = [configArg] ++ globalFlags;
  };
in {}
