{
  moduleWithSystem,
  config,
  ...
}:
let
  inherit (config) flake;
in
{
  config.flake.nixosModules.test = moduleWithSystem (
    { config }:
    nixos: {
      imports = [
        flake.nixosModules.jardin
        ./spy.nix
      ];
    }
  );
}
