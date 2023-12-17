{}:
let
  prefix = "deploy";
  separator = "-";
in
{ name }:
let
  # TODO: add way to iterate on name and to concat it with prefix and separator
  suffix = name;
in
"${prefix}${separator}${suffix}" de
