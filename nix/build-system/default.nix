{
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    ./options.nix
    ./dev.nix
    ./treefmt.nix
    ./checks.nix
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
