{ config
, pkgs
, inputs
, ...
}: {
  imports = [ ./build.nix ./checks.nix ./formatter.nix ];
}
