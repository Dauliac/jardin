{ lib, ... }:
let
  inherit (lib) types mkOption mkOptionType;
in
{ imports = [ ./disks.nix ]; }
