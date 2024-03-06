{ flake-parts-lib
, lib
, ...
}:
let
  inherit (lib) mkOption types mkIf mdDoc;
  inherit (flake-parts-lib) mkSubmoduleOptions;
in
{ imports = [ ./dns.nix ]; }
