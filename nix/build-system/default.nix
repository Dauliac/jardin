{
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    ./docs.nix
    ./options.nix
    ./dev.nix
    ./treefmt.nix
  ];
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        overlays = config.nixpkgsConfig.overlays ++ [
          inputs.deadnix.overlays.default
        ];
        inherit system;
        inherit (config.nixpkgsConfig) config;
      };
    };
}
