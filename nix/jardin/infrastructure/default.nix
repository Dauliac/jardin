{ flake-parts-lib
, config
, pkgs
, inputs
, ...
}: {
  imports = [ ./back/octodns.nix ];
  # flake = { lib.domain = import ./domain.nix; };
}
