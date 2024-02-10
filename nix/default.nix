{ flake-parts-lib
, config
, pkgs
, inputs
, ...
}: {
  imports = [
    ./build-system
    ./development
    ./flakeModules
    ./pkgs
    ./lib/maintainers.nix
  ];
}
