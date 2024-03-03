{ lib
, pkgs
, inputs
, ...
}:
let
  inherit (lib) mkOption mdDoc types;
in
{
  imports = [ ./commons.nix ./node.nix ];
  options = {
    infra.nixOs = {
      nodes = mkOption {
        type = types.attrsOf (types.attrsOf types.attrs);
        description = mdDoc "NixOs nodes manifests";
      };
    };
  };
}
