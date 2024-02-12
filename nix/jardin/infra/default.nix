{ flake-parts-lib
, config
, pkgs
, inputs
, ...
}: {
  imports = [ ./octodns.nix ./job.nix ];
}
