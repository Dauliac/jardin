{ pkgs, name, command }:
let
  separator = " "; 
  in {
    command = pkgs.writers.writeBash "${name}" "${command}";
}
