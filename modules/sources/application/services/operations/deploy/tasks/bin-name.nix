# TODO: build this file with jardin rust and nix ast
# TODO: find way to import this without arguments
_:
let
  prefix = "deploy";
  separator = "-";
in
{ mkBinName = { name }: "${prefix}${separator}${name}"; }
