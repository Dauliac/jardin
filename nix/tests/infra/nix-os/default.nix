{
  moduleWithSystem,
  config,
  ...
}: let
  inherit (config) flake;
in {
  config.flake.nixosModules.test = moduleWithSystem (
    {
      config,
      inputs,
      pkgs,
      system,
    }: {
      lib,
      pkgs,
      system,
      ...
    }: {
      imports = [
        flake.nixosModules.jardin
        ./spy.nix
        ./mock.nix
      ];
    }
  );
}
