{ flake-parts-lib
, config
, pkgs
, inputs
, ...
}: {
  imports = [ ./build-system ./development ./flakeModules ];
  flake = { lib.domain = import ./domain.nix; };
}
