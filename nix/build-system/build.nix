{...}: {
  imports = [./compile.nix ./docs.nix];
  perSystem = {
    system,
    inputs',
    config,
    pkgs,
    ...
  }: let
    inherit (config) artifact;
  in {
    packages.default = artifact;
    packages.jardin = artifact;
  };
}
